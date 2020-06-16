using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Boogie;
using Microsoft.Boogie.VCExprAST;
using VC;
using Outcome = VC.VCGen.Outcome;
using Bpl = Microsoft.Boogie;
using System.Diagnostics;
using System.Diagnostics.Contracts;
using Microsoft.Boogie.GraphUtil;
using Microsoft.Z3;

namespace Microsoft.Boogie.Houdini
{

    /* LR grammar:
     *  S -> T
     *  T -> ( T )      // rule 1
     *  T -> T ; T      // rule 2 -- disjunction
     *  T -> T , T      // rule 3 -- conjunction
     *  T -> Int        // rule 4
     *  
     * LR Table worked out manually for this grammar is
     *      (   )   ;   ,   Int $   T
     *  0   s2              s3      1               state 0 corresponds to  {S -> .T  | T -> .(T) | T -> .T;T | T -> .T,T | T -> .Int }
     *  1           s4  s5      acc                 state 1 corresponds to  {S -> T. | T -> T.;T | T -> T.,T }
     *  2   s2              s3      6               state 2 corresponds to  {T -> (.T) | T -> .(T) | T -> .T;T | T -> .T,T | T -> .Int }
     *  3   r4  r4  r4  r4  r4  r4                  state 3 corresponds to  {T -> Int. }
     *  4   s2              s3      7               state 4 corresponds to  {T -> T;.T | T -> .(T) | T -> .T;T | T -> .T,T | T -> .Int }
     *  5   s2              s3      8               state 5 corresponds to  {T -> T,.T | T -> .(T) | T -> .T;T | T -> .T,T | T -> .Int }
     *  6       s9  s4  s5                          state 6 corresponds to  {T -> (T.) | T -> T.;T | T -> T.,T }
     *  7   r2  r2  r2  r2  r2  r2                  state 7 corresponds to  {T -> T;T. | T -> T.;T | T -> T.,T }
     *  8   r3  r3  r3  r3  r3  r3                  state 8 corresponds to  {T -> T,T. | T -> T.;T | T -> T.,T }
     *  9   r1  r1  r1  r1  r1  r1                  state 9 corresponds to  {T -> (T).}
     * 
     */ 
    public static class TemplateParser
    {
        public static Dictionary<int, Dictionary<char, int>> shift = new Dictionary<int,Dictionary<char,int>>();
        public static Dictionary<int, Dictionary<char, int>> reduce = new Dictionary<int,Dictionary<char,int>>();
        public static Dictionary<int, Dictionary<char, int>> goto_actions = new Dictionary<int,Dictionary<char,int>>();

        public static Stack<StackElement> stack = new Stack<StackElement>();
        public static string str;

        public static void DSInit()
        {
            shift.Add(0, new Dictionary<char, int>()); shift[0].Add('(', 2); shift[0].Add('i', 3);
            shift.Add(1, new Dictionary<char, int>()); shift[1].Add(';', 4); shift[1].Add(',', 5);
            shift.Add(2, new Dictionary<char, int>()); shift[2].Add('(', 2); shift[2].Add('i', 3);
            shift.Add(4, new Dictionary<char, int>()); shift[4].Add('(', 2); shift[4].Add('i', 3);
            shift.Add(5, new Dictionary<char, int>()); shift[5].Add('(', 2); shift[5].Add('i', 3);
            shift.Add(6, new Dictionary<char, int>()); shift[6].Add(')', 9); shift[6].Add(';', 4); shift[6].Add(',', 5);

            reduce.Add(3, new Dictionary<char, int>()); reduce[3].Add('(', 4); reduce[3].Add(')', 4); reduce[3].Add(';', 4); reduce[3].Add(',', 4); reduce[3].Add('i', 4); reduce[3].Add('$', 4);
            reduce.Add(7, new Dictionary<char, int>()); reduce[7].Add('(', 2); reduce[7].Add(')', 2); reduce[7].Add(';', 2); reduce[7].Add(',', 2); reduce[7].Add('i', 2); reduce[7].Add('$', 2);
            reduce.Add(8, new Dictionary<char, int>()); reduce[8].Add('(', 3); reduce[8].Add(')', 3); reduce[8].Add(';', 3); reduce[8].Add(',', 3); reduce[8].Add('i', 3); reduce[8].Add('$', 3);
            reduce.Add(9, new Dictionary<char, int>()); reduce[9].Add('(', 1); reduce[9].Add(')', 1); reduce[9].Add(';', 1); reduce[9].Add(',', 1); reduce[9].Add('i', 1); reduce[9].Add('$', 1);

            goto_actions.Add(0, new Dictionary<char, int>()); goto_actions[0].Add('t', 1);
            goto_actions.Add(2, new Dictionary<char, int>()); goto_actions[2].Add('t', 6);
            goto_actions.Add(4, new Dictionary<char, int>()); goto_actions[4].Add('t', 7);
            goto_actions.Add(5, new Dictionary<char, int>()); goto_actions[5].Add('t', 8);
        }

        public static void initialize(string s)
        {
            str = s;
            stack.Clear();
            return;
        }

        public static void invokeLexer(out char lookahead, out int intVal)
        {
            if(str.Length == 0)
            {
                lookahead = '$';
                intVal = 0;
                return;
            }
            if(str.ElementAt(0) == '(' || str.ElementAt(0) == ')' || str.ElementAt(0) == ';' || str.ElementAt(0) == ',')
            {
                lookahead = str.ElementAt(0);
                intVal = 0;                
                return;
            }
            Debug.Assert(str.ElementAt(0) <= '9' && str.ElementAt(0) >= '0');
            int pos = str.IndexOfAny("();,".ToCharArray(), 0);
            lookahead = 'i';
            if (pos > -1)
            {
                intVal = Int32.Parse(str.Substring(0, pos));
            }
            else
            {
                intVal = Int32.Parse(str);
            }
        }
        public static void processOneStep(char lookahead, int intVal)
        {
            Debug.Assert(stack.Count() > 0);
            StackElement topElement = stack.Peek();
            Dictionary<char, int> tableRow;
            if(shift.TryGetValue(topElement.state, out tableRow))
            {
                int tableValue;
                if(tableRow.TryGetValue(lookahead, out tableValue))
                {
                    if(lookahead == 'i')
                    {
                        StackElement st = new StackElement(intVal);
                        st.state = tableValue;
                        stack.Push(st);

                        // remove the integer at the beginning of the string str
                        Debug.Assert(str.ElementAt(0) <= '9' && str.ElementAt(0) >= '0');
                        int pos = str.IndexOfAny("();,".ToCharArray(), 0);
                        if (pos > -1)
                        {
                            str = str.Substring(pos);
                        }
                        else
                        {
                            str = str.Substring(str.Length);
                        }
                    }
                    else
                    {
                        StackElement st = new StackElement(lookahead);
                        st.state = tableValue;
                        stack.Push(st);
                        str = str.Substring(1);
                    }
                    return;
                }
                // else case 
                Console.WriteLine("Error encountered while parsing the template!");
                Console.WriteLine("Shift rule not defined for lookahead char {0} in state {1}", lookahead, topElement.state);
                Debug.Assert(false);
            }
            // reduce operation
            if (reduce.TryGetValue(topElement.state, out tableRow))
            {
                int tableValue;
                if (tableRow.TryGetValue(lookahead, out tableValue))
                {
                    switch (tableValue)
                    {
                        // which reduce rule do we have to apply?
                        case 1:
                            {
                                StackElement rightBracket = stack.Pop();
                                Debug.Assert(rightBracket.t == StackElementType.charType);
                                Debug.Assert(rightBracket.charVal == ')');
                                StackElement template = stack.Pop();
                                Debug.Assert(template.t == StackElementType.templateType);
                                StackElement leftBracket = stack.Pop();
                                Debug.Assert(leftBracket.t == StackElementType.charType);
                                Debug.Assert(leftBracket.charVal == '(');
                                int newState = goto_actions[stack.Peek().state]['t'];
                                StackElement st = new StackElement(template.tempVal);
                                st.state = newState;

                                template.tempVal = null;
                                
                                stack.Push(st);
                                break;
                            }

                        case 2:
                            {
                                StackElement rightTemp = stack.Pop();
                                Debug.Assert(rightTemp.t == StackElementType.templateType);
                                StackElement semi_colon = stack.Pop();
                                Debug.Assert(semi_colon.t == StackElementType.charType);
                                Debug.Assert(semi_colon.charVal == ';');
                                StackElement leftTemp = stack.Pop();
                                Debug.Assert(leftTemp.t == StackElementType.templateType);
                                StackElement st = new StackElement(new Template(TemplateOperator.DisjunctionOp, leftTemp.tempVal, rightTemp.tempVal));
                                int newState = goto_actions[stack.Peek().state]['t'];
                                st.state = newState;

                                leftTemp.tempVal = null;
                                rightTemp.tempVal = null;
                                
                                stack.Push(st);
                                break;
                            }
                        case 3:
                            {
                                StackElement rightTemp = stack.Pop();
                                Debug.Assert(rightTemp.t == StackElementType.templateType);
                                StackElement comma = stack.Pop();
                                Debug.Assert(comma.t == StackElementType.charType);
                                Debug.Assert(comma.charVal == ',');
                                StackElement leftTemp = stack.Pop();
                                Debug.Assert(leftTemp.t == StackElementType.templateType);
                                StackElement st = new StackElement(new Template(TemplateOperator.ConjunctionOp, leftTemp.tempVal, rightTemp.tempVal));
                                int newState = goto_actions[stack.Peek().state]['t'];
                                st.state = newState;

                                leftTemp.tempVal = null;
                                rightTemp.tempVal = null;

                                stack.Push(st);
                                break;
                            }
                        case 4:
                            {
                                StackElement intElement = stack.Pop();
                                Debug.Assert(intElement.t == StackElementType.intType);
                                int newstate = goto_actions[stack.Peek().state]['t'];
                                StackElement st = new StackElement(new Template(intElement.intVal));
                                st.state = newstate;

                                stack.Push(st);
                                break;
                            }
                        default:
                            Console.WriteLine("Error encountered while parsing the template!");
                            Console.WriteLine("Unknown reduction rule sought.");
                            Debug.Assert(false);
                            break;
                    }
                    return;
                }
                else
                {                 
                    Console.WriteLine("Error encountered while parsing the template!");
                    Console.WriteLine("reduce rule not defined for lookahead char {0} in state {1}", lookahead, topElement.state);
                    Debug.Assert(false);
                }
            }
            else
            {
                Console.WriteLine("Error encountered while parsing template!");
                Console.WriteLine("No entry in ParserTable corresponding to the current state {0} on top of the stack.", topElement.state);
                Debug.Assert(false);
            }
            return;
        }

        public static Template Parse()
        {
            StackElement st = new StackElement();
            st.state = 0;
            stack.Push(st);
            char lookahead;
            int intVal;
            invokeLexer(out lookahead, out intVal);
            while(stack.Peek().state != 1 || lookahead != '$')
            {
                processOneStep(lookahead, intVal);
                invokeLexer(out lookahead, out intVal);
            }
            Template ret = stack.Peek().tempVal;
            stack.Peek().tempVal = null;
            return ret;
        }

    }

    public enum StackElementType
    {
        templateType,
        intType,
        charType,
        NoneType
    }

    public class StackElement
    {
        public Template tempVal;
        public int intVal;
        public char charVal;
        public StackElementType t;
        public int state;          // state of the LR parser

        public StackElement(int i)
        {
            tempVal = null;
            intVal = i;            
            t = StackElementType.intType;
        }
        public StackElement(char c)
        {
            tempVal = null;
            charVal = c;
            t = StackElementType.charType;
        }
        public StackElement(Template temp)
        {
            Debug.Assert(temp != null);
            tempVal = temp;
            t = StackElementType.templateType;
        }
        public StackElement()
        {
            tempVal = null;
            t = StackElementType.NoneType;
        }
    }


    public enum TemplateOperator
    {
        DisjunctionOp,
        ConjunctionOp,
        None,        
    } ;

    public class Template
    {   
        public TemplateOperator op;
        public int value;
        public Template left;
        public Template right;
        /*
        public Template(string templateString)
        {
            this.op = TemplateOperator.None;
            this.value = 1;
            this.left = null;
            this.right = null;
        }*/
        /*
        public Template(TemplateOperator op)
        {
            this.op = op;
            this.value = 0;
            this.left = null;
            this.right = null;
        }
        */
        public Template(int v)
        {
            Debug.Assert(v > 0);
            this.op = TemplateOperator.None;
            this.value = v;
            this.left = null;
            this.right = null;
        }

        public Template(TemplateOperator op, Template left, Template right)
        {
            this.op = op;
            this.left = left;
            this.right = right;
            this.value = 0;
        }
    }

}
