#define C5


using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using Microsoft.Boogie;
using Microsoft.Boogie.VCExprAST;
using VC;
using Outcome = VC.VCGen.Outcome;
using Bpl = Microsoft.Boogie;
using System.Diagnostics.Contracts;
using Microsoft.Boogie.GraphUtil;
//using Microsoft.Z3;
using Microsoft.Basetypes;
using Newtonsoft.Json;

namespace Microsoft.Boogie.Houdini {
    
    public class C5TreeNode
    {
        public string attribute;
        public int cut;
        public string classification;
        //public C5TreeNode left, right;
        public C5TreeNode[] children;
        //public bool isLeaf;

        public C5TreeNode()
        {
        }

        /*
        public bool Equals(C5TreeNode other)
        {

            if (isLeaf && other.isLeaf)
            {
                return classification.Equals(other.classification);
            }
            else if (!isLeaf && !other.isLeaf)
            {
                return attribute.Equals(other.attribute) && cut == other.cut && left.Equals(other.left) && right.Equals(other.right);
            }
            else
            {
                return false;
            }
        }
        */

        /*
        public Dictionary<string, List<List<Expr>>> constructBoogieExpr(List<Expr> stack, string pc, List<string> functionNames, Dictionary<string, Dictionary<string, Expr>> attr2Expr, Dictionary<string, int> functionID)
        {

        }
        */

        public List<List<Expr>> constructBoogieExpr(List<Expr> stack, Dictionary<string, Expr> attr2Expr)
        {
            Expr decisionExpr = null;
            var finalFormula = new List<List<Expr>>();
            // processing Leaf node
            if (this.children == null)
            {
                if (classification.Equals("true") || classification.Equals("True"))
                {
                    List<Expr> newConjunct = new List<Expr>(stack);
                    finalFormula.Add(newConjunct);
                    return finalFormula;
                }
                else if (classification.Equals("false") || classification.Equals("False"))
                    return finalFormula;
            }
            // processing an internal node
            else
            {                
                Expr attExpr = attr2Expr[this.attribute];
                Debug.Assert(attExpr != null);

                if (attExpr.ShallowType.IsBool)
                {
                    decisionExpr = Expr.Not((attr2Expr[this.attribute].Clone()) as Expr);
                    Debug.Assert(this.cut == 0);
                }
                else if (attExpr.ShallowType.IsInt)
                {
                    Expr attr = (attr2Expr[this.attribute].Clone()) as Expr;
                    Expr threshold = Expr.Literal(this.cut);
                    decisionExpr = Expr.Le(attr, threshold);
                }
                else
                {
                    throw new MLHoudiniInternalError("While constructing a Boogie expression from JSON, encountered a unknown type of attribute");
                }

                stack.Add(decisionExpr);
                Debug.Assert(this.children.Length == 2);
                List<List<Expr>> finalformulaLeft = this.children[0].constructBoogieExpr(stack, attr2Expr);
                stack.RemoveAt(stack.Count() - 1);
                stack.Add(Expr.Not(decisionExpr));
                List<List<Expr>> finalformulaRight = this.children[1].constructBoogieExpr(stack, attr2Expr);
                stack.RemoveAt(stack.Count() - 1);
                finalformulaLeft.AddRange(finalformulaRight);
                return finalformulaLeft;
            }

            return finalFormula;
        }
    }

    public static class ExtendsExpr
    {
        public static Expr replace(Expr expr, List<string> oldvars, List<Expr> newvars)
        {
            if (expr is LiteralExpr)
            {               
                LiteralExpr literalExpr = expr as LiteralExpr;
                return (literalExpr.Clone() as Expr);
            }
            else if (expr is IdentifierExpr)
            {
                IdentifierExpr identExpr = expr as IdentifierExpr;
                Debug.Assert(identExpr != null);
                int index = oldvars.IndexOf(identExpr.Name);
                Debug.Assert(index >= 0 && index < newvars.Count());
                Expr newExpr = newvars.ElementAt(index);                            
                return (newExpr.Clone() as Expr);
            }
            else if (expr is NAryExpr)
            {
                NAryExpr naryExpr = expr as NAryExpr;
                List<Expr> newargs = new List<Expr>();
                foreach (var exprarg in naryExpr.Args)
                {
                    newargs.Add(replace(exprarg, oldvars, newvars));                    
                }
                return new NAryExpr(Token.NoToken, naryExpr.Fun, newargs);
            }

            throw new MLHoudiniInternalError("Error: learned invariant is an expression of unexpected type!");
        }

        public static Expr conjunction(List<Expr> exprs)
        {
            if (exprs.Count() == 0)
            {
                return Expr.False;
            }
            else if (exprs.Count() == 1)
            {
                return exprs.ElementAt(0);
            }
            else
            {
                Expr lhs = exprs.ElementAt(0);
                exprs.RemoveAt(0);
                Expr rhs = conjunction(exprs);
                return Expr.And(lhs, rhs);
            }
        }

        /*
         * Assume that the argument has atleast one list of exprs in it.
         */
        public static Expr disjunction(List<List<Expr>> exprs)
        {
            Debug.Assert(exprs.Count() > 0);
            if (exprs.Count() == 1)
            {
                return conjunction(exprs.ElementAt(0));
            }
            else
            {
                Expr lhs = conjunction(exprs.ElementAt(0));
                exprs.RemoveAt(0);
                Expr rhs = disjunction(exprs);
                return Expr.Or(lhs, rhs);
            }            
        }

        public static bool EqualityComparer(Expr model, Expr newmodel)
        {
            /*
            if (model is LiteralExpr && newmodel is LiteralExpr)
            {
                LiteralExpr litmodel = model as LiteralExpr;
                LiteralExpr litnewmodel = newmodel as LiteralExpr;
                if (litnewmodel.Val.GetType() == typeof(bool) && litmodel.Val.GetType() == typeof(bool))
                {
                    return litnewmodel.Val == litmodel.Val;
                }
                else if (litnewmodel.Val.GetType() == typeof(BigNum) && litmodel.Val.GetType() == typeof(BigNum))
                {
                    return litnewmodel.Val.Equals(litmodel);
                }
                else if (litnewmodel.Val.GetType() == typeof(BigDec) && litmodel.Val.GetType() == typeof(BigDec))
                {
                    litnewmodel.Val.
                }


                return (literalExpr.Clone() as Expr);
            }
            else if (model is IdentifierExpr && newmodel is IdentifierExpr)
            {
                IdentifierExpr identExpr = expr as IdentifierExpr;
                Debug.Assert(identExpr != null);
                int index = oldvars.IndexOf(identExpr.Name);
                Debug.Assert(index >= 0 && index < newvars.Count());
                Expr newExpr = newvars.ElementAt(index);
                return (newExpr.Clone() as Expr);
            }
            else if (expr is NAryExpr)
            {
                NAryExpr naryExpr = expr as NAryExpr;
                List<Expr> newargs = new List<Expr>();
                foreach (var exprarg in naryExpr.Args)
                {
                    newargs.Add(replace(exprarg, oldvars, newvars));
                }
                return new NAryExpr(Token.NoToken, naryExpr.Fun, newargs);
            }*/
            return model.ToString() == newmodel.ToString();            
        }
    }

    public class dataPoint
    {
        public List<int> value;
        public string functionName;
        
        public dataPoint(string funcName, List<Model.Element> lm)
        {
            try
            {
                List<int> ret = new List<int>();
                foreach (var m in lm)
                {
                    if (m.Kind == Model.ElementKind.Boolean)
                    {
                        bool val = (m as Model.Boolean).Value;
                        if (val)
                        {
                            ret.Add(1);
                        }
                        else
                        {
                            ret.Add(0);
                        }
                    }
                    else if (m.Kind == Model.ElementKind.DataValue)
                    {
                        Model.DatatypeValue dv = (m as Model.DatatypeValue);
                        Debug.Assert(dv != null);
                        Debug.Assert(dv.Arguments.Count() == 1);
                        Model.Element arg = dv.Arguments[0];
                        Debug.Assert(arg.Kind == Model.ElementKind.Integer);
                        if (dv.ConstructorName.Equals("-"))
                        {
                            ret.Add(-1 * arg.AsInt());
                        }
                        else if (dv.ConstructorName.Equals("+"))
                        {
                            ret.Add(arg.AsInt());
                        }
                        else
                        {
                            throw new MLHoudiniInternalError("Unexpected constructor name in the data value returned by the model\n");
                        }
                    }
                    else
                    {
                        Debug.Assert(m.Kind == Model.ElementKind.Integer);
                        ret.Add(m.AsInt());
                    }
                }
                value = ret;
                functionName = funcName;
            }
            catch(Exception e)
            {
                Console.WriteLine("Exception caught while converting model into a list of integer");
                throw e;
            }
        }

        public override int GetHashCode()
        {
                if (this.value != null && this.functionName != null)
                    return this.value.Count + 100 * this.functionName.GetHashCode();
                else return 0;
        }

        public override bool Equals(object obj)
        {
                dataPoint other = obj as dataPoint;
                if (other == null)
                    return false;
                return this.value.SequenceEqual(other.value) && this.functionName.Equals(other.functionName);
        }

        public string print()
        {
            string ret = this.functionName + ":";
            if(value.Count() == 0)
            {
                ret += "empty";
            }
            else
            {
                ret += value[0].ToString();
            }
            for(int i = 1; i < value.Count(); i++)
            {
                ret += "," + value[i].ToString();
            }
            return ret;
        }
    }

    public class MLHoudini
    {
        Dictionary<string, Function> existentialFunctions;
        Program program;
        Dictionary<string, Implementation> name2Impl;
        Dictionary<string, VCExpr> impl2VC;
        Dictionary<string, List<Tuple<string, Function, NAryExpr>>> impl2FuncCalls;
        // constant -> the naryexpr that it replaced
        Dictionary<string, NAryExpr> constant2FuncCall;

        // function -> its abstract value
        Dictionary<string, MLICEDomain> function2Value;
        
        Dictionary<string, Dictionary<string, Expr>> attribute2Expr;
        Dictionary<string, int> functionID;

        public const string attrPrefix = "$";
        public const string pcAttrName = "$pc";

        // impl -> functions assumed/asserted
        Dictionary<string, HashSet<string>> impl2functionsAsserted, impl2functionsAssumed;

        // funtions -> impls where assumed/asserted
        Dictionary<string, HashSet<string>> function2implAssumed, function2implAsserted;

        // impl -> handler, collector
        Dictionary<string, Tuple<ProverInterface.ErrorHandler, MLHoudiniCounterexampleCollector>> impl2ErrorHandler;

        // Essentials: VCGen, Prover
        VCGen vcgen;
        ProverInterface prover;
        // List that contains the bounds for values in cex to try.
        List<int> bounds4cex;
                       

        // name of the Boogie program being verified: used for generating C5 files.
        string filename;
        string config;
        bool useBounds;

        // Stats
        TimeSpan proverTime;
        int numProverQueries;
        TimeSpan c5LearnerTime;
        int c5LearnerQueries;
        TimeSpan totaltime;
        TimeSpan jsontime;

        int numPosExamples;
        int numNegCounterExamples;
        int numImplications;
        int totalTreeSize;
        int lastTreeSize;
        int total_truetrue_implications;
        int last_truetrue_implications;
        int total_falsetrue_implications;
        int last_falsetrue_implications;
        int total_falsefalse_implications;
        int last_falsefalse_implications;
        //bool posNegCexAdded;

        // Z3 context for implementing the SMT-based ICE learner.
        HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> counterExamples;
        HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> implicationCounterExamples;        

#if C5
        // Data structures for storing and creating C5 sample
        Dictionary<dataPoint, int> c5samplePointToClassAttr;
        Dictionary<dataPoint, int> c5samplePointToIndex;                        
        List<Tuple<int, int>> c5implications;
        int c5DataPointsIndex;
#endif          

        // flags to track the outcome of validity of a VC
        bool VCisValid;
        //bool realErrorEncountered;
        //bool newSamplesAdded;   // tracks whether new ICE samples added in a round or not?

        public MLHoudini(Program program, string config, string filename, bool useBounds)
        {
            this.program = program;
            this.impl2VC = new Dictionary<string, VCExpr>();
            this.impl2FuncCalls = new Dictionary<string, List<Tuple<string, Function, NAryExpr>>>();
            this.existentialFunctions = new Dictionary<string, Function>();
            this.name2Impl = new Dictionary<string, Implementation>();
            this.impl2functionsAsserted = new Dictionary<string, HashSet<string>>();
            this.impl2functionsAssumed = new Dictionary<string, HashSet<string>>();
            this.function2implAsserted = new Dictionary<string, HashSet<string>>();
            this.function2implAssumed = new Dictionary<string, HashSet<string>>();
            this.impl2ErrorHandler = new Dictionary<string, Tuple<ProverInterface.ErrorHandler, MLHoudiniCounterexampleCollector>>();
            this.constant2FuncCall = new Dictionary<string, NAryExpr>();

            // Find the existential functions
            foreach (var func in program.TopLevelDeclarations.OfType<Function>()
                .Where(f => QKeyValue.FindBoolAttribute(f.Attributes, "existential")))
                existentialFunctions.Add(func.Name, func);

            // extract the constants in the program to determine the range for the template domain elements
            this.function2Value = new Dictionary<string, MLICEDomain>();
            foreach (var func in existentialFunctions.Values)
            {
                function2Value[func.Name] = new C5Domain(func.InParams);
            }

            counterExamples = new HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>>();
            implicationCounterExamples = new HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>>();
            bounds4cex = new List<int>();
            this.filename = filename;
            this.config = config;
            this.useBounds = useBounds;

            // config = alg1, alg2, alg3, alg4, smallcex_alg1, smallcex_alg2, ...

            if (this.useBounds)
            {
                bounds4cex.Add(2);
                bounds4cex.Add(5);
                bounds4cex.Add(10);
            }

            existentialFunctions.Keys.Iter(f => function2implAssumed.Add(f, new HashSet<string>()));
            existentialFunctions.Keys.Iter(f => function2implAsserted.Add(f, new HashSet<string>()));

            // type check
            existentialFunctions.Values.Iter(func =>
                {
                    if (func.OutParams.Count != 1 || !func.OutParams[0].TypedIdent.Type.IsBool)
                        throw new MLHoudiniInternalError(string.Format("Existential function {0} must return bool", func.Name));
                    if (func.Body != null)
                        throw new MLHoudiniInternalError(string.Format("Existential function {0} should not have a body", func.Name));
                    func.InParams.Iter(v =>
                    {
                        if (!v.TypedIdent.Type.IsInt && !v.TypedIdent.Type.IsBool)
                        {
                            throw new MLHoudiniInternalError("TypeError: Illegal tpe, expecting int or bool");
                        }
                    });
                });
           
            Inline();

            this.vcgen = new VCGen(program, CommandLineOptions.Clo.SimplifyLogFilePath, CommandLineOptions.Clo.SimplifyLogFileAppend, new List<Checker>());
            this.prover = ProverInterface.CreateProver(program, CommandLineOptions.Clo.SimplifyLogFilePath, CommandLineOptions.Clo.SimplifyLogFileAppend, CommandLineOptions.Clo.ProverKillTime);

            this.proverTime = TimeSpan.Zero;
            this.numProverQueries = 0;
            this.c5LearnerTime = TimeSpan.Zero;
            this.c5LearnerQueries = 0;
            this.totaltime = TimeSpan.Zero;
            this.jsontime = TimeSpan.Zero;

            this.numPosExamples = 0;
            this.numNegCounterExamples = 0;
            this.numImplications = 0;
            this.total_falsefalse_implications = 0;
            this.total_falsetrue_implications = 0;
            this.total_truetrue_implications = 0;
            this.totalTreeSize = 0;
            this.last_falsefalse_implications = 0;
            this.last_falsetrue_implications = 0;
            this.last_truetrue_implications = 0;
            this.lastTreeSize = 0;
            //this.posNegCexAdded = false;

#if C5
            this.c5DataPointsIndex = 0;
            this.c5samplePointToClassAttr = new Dictionary<dataPoint, int>();
            this.c5samplePointToIndex = new Dictionary<dataPoint, int>();
            this.c5implications = new List<Tuple<int, int>>();
#endif


            var impls = program.TopLevelDeclarations.OfType<Implementation>().Where(
                    impl => impl != null && CommandLineOptions.Clo.UserWantsToCheckRoutine(cce.NonNull(impl.Name)) && !impl.SkipVerification);

            /*
            program.TopLevelDeclarations.OfType<Implementation>()
                .Where(impl => !impl.SkipVerification)
                .Iter(impl => name2Impl.Add(impl.Name, impl));
            */

            impls.Iter(impl => name2Impl.Add(impl.Name, impl));

            // Call setupC5 only after the filename has been initialized!
            setupC5();

            // Let's do VC Gen (and also build dependencies)
            name2Impl.Values.Iter(GenVC);
        }

        private void generateAttributes(int num)
        {
            int[] array = new int[num];
            for (int i = 0; i < num; i++)
                array[i] = 0;

            

        }




        private void setupC5()
        {
            string namesFile = "";
            string intervalsFile = "";
            int lowerInterval = 2, upperInterval = 2;

            namesFile += "invariant.\n";
            // output pcs
            // pc : pc1,pc2,pc3,pc4.
            namesFile += pcAttrName + " : ";
            {
                int i = 0;
                foreach (var functionName in existentialFunctions.Keys)
                {
                    namesFile += functionName + (i < existentialFunctions.Keys.Count - 1 ? "," : "");
                    i++;
                }

                // If there exists only one existential function, we need to add a dummy function to fool the C5 learner, which does not allow a discrete attribute with just one attribute value
                if (i == 1)
                {
                    namesFile += "," + pcAttrName + "_dummy";
                }

                namesFile += "." + Environment.NewLine;

            }

            attribute2Expr = new Dictionary<string, Dictionary<string, Expr>>();
            functionID = new Dictionary<string, int>();

            foreach (var funTup in existentialFunctions)
            {
                Dictionary<string, Expr> newentry = new Dictionary<string, Expr>();
                List<Variable> args = funTup.Value.InParams;

                foreach (var variable in args)
                {
                    if (variable.TypedIdent.Type.IsBool || variable.TypedIdent.Type.IsInt)
                    {
                        newentry[funTup.Key + "$" + variable.Name] = Expr.Ident(variable);
                        Debug.Assert(newentry[funTup.Key + "$" + variable.Name].ShallowType.IsInt || newentry[funTup.Key + "$" + variable.Name].ShallowType.IsBool);
                        namesFile += funTup.Key + "$" + variable.Name + ": continuous.\n";
                        upperInterval++;
                    }
                    else
                    {
                        throw new MLHoudiniInternalError("Existential Functions should have either Boolean or Int typed arguments!");
                    }
                }


                // Commented out right now
                #region Introducing attributes with arbitrary number of variables
                /*
                int num = args.Count();
                int[] array = new int[num];
                for (int i = 0; i < num; i++)
                    array[i] = 0;

                int done = 0;
                while (true)
                {
                    for (int i = 0; i < num; i++)
                    {
                        if (array[i] < 2)
                        {
                            array[i]++;
                            break;
                        }
                        else if (i == num - 1)
                        {
                            done = 1;
                            break;
                        }
                        else
                        {
                            array[i] = 0;
                        }
                    }

                    if (done == 1)
                        break;
                    
                    int numArgs = 0;
                    for (int i = 0; i < num; i++)
                    {
                        if (array[i] != 0)
                            numArgs++;                        
                    }

                    if (numArgs == 1)
                        continue;

                    int j = 0;
                    Expr attrexpr = null;
                    string lhs = null;
                    string rhs = null;

                   
                        foreach (var variable in args)
                        {
                            if (array[j] == 1)
                            {
                                Variable var = args.ElementAt(j);
                                if (attrexpr == null)
                                {
                                    attrexpr = Expr.Ident(var);
                                }
                                else
                                {
                                    attrexpr = Expr.Add(attrexpr, Expr.Ident(var));
                                }

                                if (lhs == null)
                                {
                                    lhs = attrPrefix + funTup.Key + "$" + "+" + var.Name;
                                }
                                else
                                {
                                    lhs = lhs + "+" + var.Name;
                                }

                                if (rhs == null)
                                {
                                    rhs = "+" + funTup.Key + "$" + var.Name;
                                }
                                else
                                {
                                    rhs = rhs + "+" + funTup.Key + "$" + var.Name;
                                }

                                
                            }

                            else if (array[j] == 2)
                            {
                                Variable var = args.ElementAt(j);
                                if (attrexpr == null)
                                {
                                    attrexpr = Expr.Sub(Expr.Literal(0), Expr.Ident(var));
                                }
                                else
                                {
                                    attrexpr = Expr.Sub(attrexpr, Expr.Ident(var));
                                }

                                if (lhs == null)
                                {
                                    lhs = attrPrefix + funTup.Key + "$" + "-" + var.Name;
                                }
                                else
                                {
                                    lhs = lhs + "-" + var.Name;
                                }

                                if (rhs == null)
                                {
                                    rhs = "-" + funTup.Key + "$" + var.Name;
                                }
                                else
                                {
                                    rhs = rhs + "-" + funTup.Key + "$" + var.Name;
                                }                                
                            }
                            j++;
                        }

                        newentry[lhs] = attrexpr;
                        Debug.Assert(newentry[lhs].ShallowType.IsInt || newentry[lhs].ShallowType.IsBool);
                        namesFile += lhs + ":= " + rhs + ".\n";

                        upperInterval++;
                        

                }
                 * */
#endregion Introducing attributes with arbitrary number of variables



                // Add implicitly defined attributes of the form x1 +/- x2
                for (int i = 0; i < args.Count; i++)
                {
                    for (int j = i + 1; j < args.Count; j++)
                    {
                        Variable var1 = args.ElementAt(i);
                        Variable var2 = args.ElementAt(j);
                        if (var1.TypedIdent.Type.IsInt && var2.TypedIdent.Type.IsInt)
                        {
                            newentry[attrPrefix + funTup.Key + "$" + var1.Name + "+" + var2.Name] = Expr.Add(Expr.Ident(var1), Expr.Ident(var2));
                            Debug.Assert(newentry[attrPrefix + funTup.Key + "$" + var1.Name + "+" + var2.Name].ShallowType.IsInt || newentry[attrPrefix + funTup.Key + "$" + var1.Name + "+" + var2.Name].ShallowType.IsBool);
                            newentry[attrPrefix + funTup.Key + "$" + var1.Name + "-" + var2.Name] = Expr.Sub(Expr.Ident(var1), Expr.Ident(var2));
                            Debug.Assert(newentry[attrPrefix + funTup.Key + "$" + var1.Name + "-" + var2.Name].ShallowType.IsInt || newentry[attrPrefix + funTup.Key + "$" + var1.Name + "-" + var2.Name].ShallowType.IsBool);
                            namesFile += attrPrefix + funTup.Key + "$" + var1.Name + "+" + var2.Name + ":= " + funTup.Key + "$" + var1.Name + " + " + funTup.Key + "$" + var2.Name + ".\n";
                            namesFile += attrPrefix + funTup.Key + "$" + var1.Name + "-" + var2.Name + ":= " + funTup.Key + "$" + var1.Name + " - " + funTup.Key + "$" + var2.Name + ".\n";
                            upperInterval += 2;
                        }
                    }
                }


                attribute2Expr[funTup.Key] = newentry;
                functionID[funTup.Key] = functionID.Count;                
                intervalsFile += lowerInterval.ToString() + " " + (upperInterval-1).ToString() + "\n";
                lowerInterval = upperInterval;
                upperInterval = lowerInterval;
            }

            namesFile += "invariant: true, false.\n";
            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".names"))
            {
                sw.WriteLine(namesFile);
            }
            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".intervals"))
            {
                if (existentialFunctions.Count == 1)
                {
                    intervalsFile += "2 2";
                }
                sw.WriteLine(intervalsFile);
            }
            return;
        }

        private VCGenOutcome LearnInv(Dictionary<string, int> impl2Priority)
        {
            var worklist = new SortedSet<Tuple<int, string>>();
            name2Impl.Keys.Iter(k => worklist.Add(Tuple.Create(impl2Priority[k], k)));
            
            while (worklist.Any())
            {
                var impl = worklist.First().Item2;
                worklist.Remove(worklist.First());

                #region vcgen

                var gen = prover.VCExprGen;
                var terms = new List<Expr>();
                foreach (var tup in impl2FuncCalls[impl])
                {
                    var controlVar = tup.Item2;
                    var exprVars = tup.Item3;
                    var varList = new List<Expr>();
                    exprVars.Args.OfType<Expr>().Iter(v => varList.Add(v));

                    var args = new List<Expr>();
                    controlVar.InParams.Iter(v => args.Add(Expr.Ident(v)));
                    Expr term = Expr.Eq(new NAryExpr(Token.NoToken, new FunctionCall(controlVar), args),
                                 function2Value[tup.Item1].Gamma(varList));

                    if (controlVar.InParams.Count != 0)
                    {
                        term = new ForallExpr(Token.NoToken, new List<Variable>(controlVar.InParams.ToArray()),
                            new Trigger(Token.NoToken, true, new List<Expr> { new NAryExpr(Token.NoToken, new FunctionCall(controlVar), args) }),
                            term);
                    }
                    terms.Add(term);

                    /*
                    foreach (var variable in varList)
                    {
                        terms.Add(Expr.Le(variable, Expr.Literal(10)));
                        terms.Add(Expr.Ge(variable, Expr.Literal(-10)));
                    }
                    */
                }
                var env = BinaryTreeAnd(terms, 0, terms.Count - 1);

                env.Typecheck(new TypecheckingContext((IErrorSink)null));
                var envVC = prover.Context.BoogieExprTranslator.Translate(env);
                var vc = gen.Implies(envVC, impl2VC[impl]);

                if (CommandLineOptions.Clo.Trace)
                {
                    Console.WriteLine("Verifying {0}: ", impl);
                    //Console.WriteLine("env: {0}", envVC);
                    var envFuncs = new HashSet<string>();
                    impl2FuncCalls[impl].Iter(tup => envFuncs.Add(tup.Item1));
                    envFuncs.Iter(f => PrintFunction(existentialFunctions[f]));
                }

                #endregion vcgen

                VCExpr finalVC;
                bool hasIntegerVariable = true;

                for (int i = 0; i <= bounds4cex.Count(); i++)
                {
#region boundcexvalues
                    // If there are no integer variables, then ensure the loop is only run once.
                    if (!hasIntegerVariable)
                        continue;

                    /* Last iteration is when there are enforced no bounds on the cex values. */
                    if (i < bounds4cex.Count())
                    {
                        int bound = bounds4cex.ElementAt(i);
                        terms.Clear();
                        foreach (var tup in impl2FuncCalls[impl])
                        {
                            var exprVars = tup.Item3;
                            var varList = new List<Expr>();
                            exprVars.Args.OfType<Expr>().Where(v => v.Type.IsInt).Iter(v => varList.Add(v));
                            foreach (var variable in varList)
                            {
                                terms.Add(Expr.Le(variable, Expr.Literal(bound)));
                                terms.Add(Expr.Ge(variable, Expr.Literal(-1 * bound)));
                                //terms.Add(Expr.Ge(variable, Expr.Literal(0)));
                            }
                        }
                        if (terms.Count == 0)
                        {
                            // There is no integer argument to the function to learn
                            hasIntegerVariable = false;
                        }

                        var boundcex = BinaryTreeAnd(terms, 0, terms.Count - 1);
                        boundcex.Typecheck(new TypecheckingContext((IErrorSink)null));
                        var boundcexVC = prover.Context.BoogieExprTranslator.Translate(boundcex);

                        finalVC = gen.Implies(boundcexVC, vc);
                    }
                    else
                    {
                        if (!this.useBounds)
                        {
                            finalVC = vc;
                        }
                        else
                        {
                            int bound = 1000000;
                            terms.Clear();
                            foreach (var tup in impl2FuncCalls[impl])
                            {
                                var exprVars = tup.Item3;
                                var varList = new List<Expr>();
                                exprVars.Args.OfType<Expr>().Where(v => v.Type.IsInt).Iter(v => varList.Add(v));
                                foreach (var variable in varList)
                                {
                                    terms.Add(Expr.Le(variable, Expr.Literal(bound)));
                                    terms.Add(Expr.Ge(variable, Expr.Literal(-1 * bound)));
                                    //terms.Add(Expr.Ge(variable, Expr.Literal(0)));
                                }
                            }
                            var boundcex = BinaryTreeAnd(terms, 0, terms.Count - 1);
                            boundcex.Typecheck(new TypecheckingContext((IErrorSink)null));
                            var boundcexVC = prover.Context.BoogieExprTranslator.Translate(boundcex);

                            finalVC = gen.Implies(boundcexVC, vc);
                        }
                    }
#endregion boundcexvalues

                    var handler = impl2ErrorHandler[impl].Item1;
                    var collector = impl2ErrorHandler[impl].Item2;
                    collector.Reset(impl);
                    implicationCounterExamples.Clear();
                    VCisValid = true;   // set to false if control reaches HandleCounterExample
                    //realErrorEncountered = false;
                    //newSamplesAdded = false;
                    //this.posNegCexAdded = false;

                    var start = DateTime.Now;

                    prover.Push();
                    prover.Assert(gen.Not(finalVC), true);
                    prover.FlushAxiomsToTheoremProver();
                    prover.Check();
                    ProverInterface.Outcome proverOutcome = prover.CheckOutcomeCore(handler);

                    var inc = (DateTime.Now - start);
                    proverTime += inc;
                    numProverQueries++;

                    if (CommandLineOptions.Clo.Trace)
                        Console.WriteLine("Prover Time taken = " + inc.TotalSeconds.ToString());

                    if (proverOutcome == ProverInterface.Outcome.TimeOut || proverOutcome == ProverInterface.Outcome.OutOfMemory)
                    {
                        Console.WriteLine("Z3 Prover for implementation {0} times out or runs out of memory !", impl);
                        return new VCGenOutcome(proverOutcome, new List<Counterexample>());
                    }

                    if (!VCisValid)
                    {
                        /* There was a counterexample found and acted upon while proving the method. */
                        if (collector.real_errors.Count > 0)
                        {
                            return new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.real_errors);
                        }

                        if (collector.conjecture_errors.Count == 0)
                        {
                            // No positive or negative counter-example added. Need to add implication counter-examples
                            Debug.Assert(collector.implication_errors.Count > 0);
                            foreach (var cex in implicationCounterExamples)
                            {
                                AddCounterExample(cex);
                            }
                        }

                        //Debug.Assert(newSamplesAdded);
                        HashSet<string> funcsChanged;

                        if (!learn(out funcsChanged))
                        {
                            // learner timed out, ran into some errors, or if there is no consistent conjecture
                            prover.Pop();
                            if(collector.conjecture_errors.Count > 0)
                                return new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.conjecture_errors);
                            else
                                return new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.implication_errors);
                        }
                        // propagate dependent guys back into the worklist, including self
                        var deps = new HashSet<string>();
                        deps.Add(impl);
                        funcsChanged.Iter(f => deps.UnionWith(function2implAssumed[f]));
                        funcsChanged.Iter(f => deps.UnionWith(function2implAsserted[f]));

                        deps.Iter(s => worklist.Add(Tuple.Create(impl2Priority[s], s)));

                        // break out of the loop that iterates over various bounds.
                        prover.Pop();
                        break;
                    }
                    else
                    {
                        prover.Pop();
                    }
                }
            }
            // The program was verified
            return new VCGenOutcome(ProverInterface.Outcome.Valid, new List<Counterexample>());            
        }


        public VCGenOutcome ComputeSummaries()
        {
            // Compute SCCs and determine a priority order for impls
            var Succ = new Dictionary<string, HashSet<string>>();
            var Pred = new Dictionary<string, HashSet<string>>();
            name2Impl.Keys.Iter(s => Succ[s] = new HashSet<string>());
            name2Impl.Keys.Iter(s => Pred[s] = new HashSet<string>());

            foreach(var impl in name2Impl.Keys) {
                Succ[impl] = new HashSet<string>();
                impl2functionsAsserted[impl].Iter(f => 
                    function2implAssumed[f].Iter(succ =>
                        {
                            Succ[impl].Add(succ);
                            Pred[succ].Add(impl);
                        }));
            }

            var sccs = new StronglyConnectedComponents<string>(name2Impl.Keys,
                new Adjacency<string>(n => Pred[n]),
                new Adjacency<string>(n => Succ[n]));
            sccs.Compute();
            
            // impl -> priority
            var impl2Priority = new Dictionary<string, int>();
            int p = 0;
            foreach (var scc in sccs)
            {
                foreach (var impl in scc)
                {
                    impl2Priority.Add(impl, p);
                    p++;
                }
            }

            VCGenOutcome overallOutcome = null;

            var start = DateTime.Now;

            overallOutcome = LearnInv(impl2Priority);

            var elapsed = DateTime.Now;
            this.totaltime = elapsed - start;

            if (true)
            {
                Console.WriteLine("Prover time = {0}", proverTime.TotalSeconds.ToString("F2"));
                Console.WriteLine("Number of prover queries = " + numProverQueries);
                Console.WriteLine("C5 Learner time = {0}", c5LearnerTime.TotalSeconds.ToString("F2"));
                //Console.WriteLine("time to parse JSON and construct Boogie Model = {0}", jsontime.TotalSeconds.ToString("F2"));
                Console.WriteLine("Number of C5 Learner queries = " + c5LearnerQueries);

                //Console.WriteLine("Total time: {0}", proverTime.Add(c5LearnerTime).TotalSeconds.ToString("F2"));
                Console.WriteLine("Total time: {0}", totaltime.Subtract(jsontime).TotalSeconds.ToString("F2"));

                Console.WriteLine("Number of examples:" + this.numPosExamples);
                Console.WriteLine("Number of counter-examples:" + this.numNegCounterExamples);
                Console.WriteLine("Number of implications:" + this.numImplications);

                /*Console.WriteLine("Average tree size: " + ((double)this.totalTreeSize / (double)this.c5LearnerQueries));
                Console.WriteLine("Last tree size: " + this.lastTreeSize);
                Console.WriteLine("Average truetrue implications: " + ((double)this.total_truetrue_implications / (double)this.c5LearnerQueries));
                Console.WriteLine("last truetrue implications: " + this.last_truetrue_implications);
                Console.WriteLine("Average falsetrue implications: " + ((double)this.total_falsetrue_implications/ (double)this.c5LearnerQueries));
                Console.WriteLine("last falsetrue implications: " + this.last_falsetrue_implications);
                Console.WriteLine("Average falsefalse implications: " + ((double)this.total_falsefalse_implications / (double)this.c5LearnerQueries));
                Console.WriteLine("last falsefalse implications: " + this.last_falsefalse_implications);                */
            }

            if (CommandLineOptions.Clo.PrintAssignment)
            {
                // Print the existential functions
                existentialFunctions.Values.Iter(PrintFunction);
            }
            
            return overallOutcome;
        }

        private static Expr BinaryTreeAnd(List<Expr> terms, int start, int end)
        {
            if (start > end)
                return Expr.True;
            if (start == end)
                return terms[start];
            if (start + 1 == end)
                return Expr.And(terms[start], terms[start + 1]);
            var mid = (start + end) / 2;
            return Expr.And(BinaryTreeAnd(terms, start, mid), BinaryTreeAnd(terms, mid + 1, end));
        }

        /*
        public IEnumerable<Function> GetAssignment()
        {
            var ret = new List<Function>();
            foreach (var func in existentialFunctions.Values)
            {
                var invars = new List<Expr>(func.InParams.OfType<Variable>().Select(v => Expr.Ident(v)));
                func.Body = function2Value[func.Name].Gamma(invars);
                ret.Add(func);
            }
            return ret;
        }
        */

        private void PrintFunction(Function function)
        {
            var tt = new TokenTextWriter(Console.Out);
            var invars = new List<Expr>(function.InParams.OfType<Variable>().Select(v => Expr.Ident(v)));
            function.Body = function2Value[function.Name].Gamma(invars);
            function.Emit(tt, 0);
            tt.Close();
        }

        public string outputDataPoint(dataPoint p)
        {
            string funcName = p.functionName;
            List<int> attrVals = p.value;
            string ret = funcName;
            foreach (var exFunc in existentialFunctions)
            {
                if (exFunc.Key.Equals(funcName))
                {
                    foreach (var x in attrVals)
                    {
                        ret += "," + x.ToString();
                    }
                }
                else
                {
                    foreach (var arg in exFunc.Value.InParams)
                    {
                        ret += ",?";
                    }
                }
            }
            return ret;
        }

        /*
        public void RecordCounterExamples2File(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            string ret = "";
            
            if (lhs.Count == 0)
            {
                Debug.Assert(rhs.Count == 1);
                ret += ParseListOfModel(rhs.ElementAt(0).Item2);
                ret += ";accept";
            }
            else if (rhs.Count == 0)
            {
                Debug.Assert(lhs.Count == 1);
                ret += ParseListOfModel(lhs.ElementAt(0).Item2);
                ret += ";reject";
            }
            else
            {
                Debug.Assert(lhs.Count == 1);
                Debug.Assert(rhs.Count == 1);
                ret += ParseListOfModel(lhs.ElementAt(0).Item2);
                ret += ";antecedent\n";
                ret += ParseListOfModel(rhs.ElementAt(0).Item2);
                ret += ";consequent";
            }
            if (!System.IO.File.Exists("samples.txt"))
            {
                // Create a file to write to. 
                using (System.IO.StreamWriter sw = System.IO.File.CreateText("samples.txt"))
                {
                    sw.WriteLine("// x y -- empty line");                    
                }
            }

            // This text is always added, making the file longer over time 
            // if it is not deleted. 
            using (System.IO.StreamWriter sw = System.IO.File.AppendText("samples.txt"))
            {                
                sw.WriteLine(ret);
            }
            return;
        }
         * */

#if C5                
        public void RecordCexForC5(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex, 
                                                                                    bool recordImplications = true)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            if (lhs.Count == 0)
            {
                Debug.Assert(rhs.Count == 1);
                
                dataPoint argsval = new dataPoint(rhs.ElementAt(0).Item1, rhs.ElementAt(0).Item2);                
                if (this.c5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(c5samplePointToClassAttr[argsval] != 2); // should be unknown
                    this.c5samplePointToClassAttr[argsval] = 1;
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Overwrote: " + argsval.print() + ": positive");
                    }
                }
                else
                {
                    c5samplePointToIndex[argsval] = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval] = 1;
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Added: " + argsval.print() + ": positive");
                    }
                }
            }
            else if (rhs.Count == 0)
            {
                if(lhs.Count > 1)
                {
                    List<Tuple<string, List<Model.Element>>> newlhs = new List<Tuple<string, List<Model.Element>>>();
                    newlhs.Add(lhs.ElementAt(lhs.Count - 1));
                    lhs = newlhs;
                }
                Debug.Assert(lhs.Count == 1);
                
                dataPoint argsval = new dataPoint(lhs.ElementAt(0).Item1, lhs.ElementAt(0).Item2);
                if (c5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(c5samplePointToClassAttr[argsval] != 1); // should be unknown
                    c5samplePointToClassAttr[argsval] = 2;
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Overwrote: " + argsval.print() + ": negative");
                    }
                }
                else
                {
                    c5samplePointToIndex[argsval] = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval] = 2;
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Added: " + argsval.print() + ": negative");
                    }
                }
            }
            else
            {
                if (lhs.Count > 1)
                {
                    List<Tuple<string, List<Model.Element>>> newlhs = new List<Tuple<string, List<Model.Element>>>();
                    newlhs.Add(lhs.ElementAt(lhs.Count - 1));
                    lhs = newlhs;
                }
                Debug.Assert(lhs.Count == 1);
                Debug.Assert(rhs.Count == 1);
                
                int antecedent, consequent;

                dataPoint argsval1 = new dataPoint(lhs.ElementAt(0).Item1, lhs.ElementAt(0).Item2);
                dataPoint argsval2 = new dataPoint(rhs.ElementAt(0).Item1, rhs.ElementAt(0).Item2);

                if (c5samplePointToIndex.ContainsKey(argsval1))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval1] == 0); // is unknown
                    antecedent = c5samplePointToIndex[argsval1];                    
                }
                else
                {
                    c5samplePointToIndex[argsval1] = c5DataPointsIndex;
                    antecedent = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval1] = 0;
                }
                if (c5samplePointToIndex.ContainsKey(argsval2))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval2] == 0); // is unknown
                    consequent = c5samplePointToIndex[argsval2];                    
                }
                else
                {
                    c5samplePointToIndex[argsval2] = c5DataPointsIndex;
                    consequent = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval2] = 0;
                }
                if (recordImplications)
                {
                    Tuple<int, int> t = new Tuple<int, int>(antecedent, consequent);
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Added implication: " + antecedent + "," + consequent);
                    }
                    c5implications.Add(t);
                }
            }
        }

        public void generateC5Files()
        {
            string dataFile = "";
            string implicationsFile = "";

            foreach (var model in c5samplePointToClassAttr.Keys)
            {
                dataFile += outputDataPoint(model);
                switch (c5samplePointToClassAttr[model])
                {
                    case 0: dataFile += ",?\n"; break;
                    case 1: dataFile += ",true\n"; break;
                    case 2: dataFile += ",false\n"; break;

                    default: Debug.Assert(false); break;
                }
            }

            foreach (var implication in c5implications)
            {
                implicationsFile += implication.Item1;
                implicationsFile += " ";
                implicationsFile += implication.Item2;
                implicationsFile += "\n";
            }

            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".data"))
            {
                sw.WriteLine(dataFile);
            }
            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".implications"))
            {
                sw.WriteLine(implicationsFile);
            }
            
            return;
        }

#endif

        public void AddCounterExample(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex, 
                                                                                                                bool recordImplications = true)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            //counterExamples.Add(cex);
#if true
            if (lhs.Count > 0 && rhs.Count > 0)
            {
                this.numImplications++;
                if(recordImplications && CommandLineOptions.Clo.Trace) 
                    Console.WriteLine("Implication added");
                else if (CommandLineOptions.Clo.Trace)
                    Console.WriteLine("Implication points added as unknowns (no edge added!)");                
            }
            else if (lhs.Count > 0)
            {
                this.numNegCounterExamples++;
                if (CommandLineOptions.Clo.Trace)
                    Console.WriteLine("Negative example added");
            }
            else
            {
                this.numPosExamples++;
                if (CommandLineOptions.Clo.Trace)
                    Console.WriteLine("Positive example added");
            }
#endif

#if C5
            RecordCexForC5(cex, recordImplications);
#endif
        }
        
#if Pranav
        public bool HandleCounterExample(string impl, Counterexample error, out bool counterExampleAdded)
        {
            // return true if a true error encountered.
            // return false if the error is due to a wrong choice of current conjecture.
            counterExampleAdded = false;

            VCisValid = false;
            var cex = P_ExtractState(impl, error);

            // the counter-example does not involve any existential function ==> Is a real counter-example !
            if (cex.Item1.Count == 0 && cex.Item2.Count == 0)
            {
                realErrorEncountered = true;
                return true;
            }
            if (!newSamplesAdded || (cex.Item1.Count == 1 && cex.Item2.Count == 0) || (cex.Item2.Count == 1 && cex.Item1.Count == 0))
            {
                AddCounterExample(cex);
                counterExampleAdded = true;
            }
            newSamplesAdded = true;          
            return false;
        }
#endif

        public bool HandleCounterExample(string impl, Counterexample error, out bool cexAdded)
        {
            // return true if a true error encountered.
            // return false if the error is due to a wrong choice of current conjecture.
            VCisValid = false;
            var cex = P_ExtractState(impl, error);

            // the counter-example does not involve any existential function ==> Is a real counter-example !
            if (cex.Item1.Count == 0 && cex.Item2.Count == 0)
            {
                //realErrorEncountered = true;
                cexAdded = false;
                return true;
            }

#if true
            if (cex.Item1.Count == 0 || cex.Item2.Count == 0)
            {
                cexAdded = true;
                AddCounterExample(cex);
                return false;
            }
            else
            {
                cexAdded = false;
                implicationCounterExamples.Add(cex);
                return false;
            }

            /*
            if (!this.posNegCexAdded || (cex.Item1.Count == 0 || cex.Item2.Count == 0))
            {
                // Record the cex. Is a positive or negative cex or is the first occurence of the implications
                if(cex.Item1.Count == 0 || cex.Item2.Count == 0)
                    this.posNegCexAdded = true;

                cexAdded = true;
                AddCounterExample(cex);
                newSamplesAdded = true;
                return false;
            }
            else
            {
#if false
                AddCounterExample(cex, false);
#endif
                cexAdded = false;
                return false;
            }
            */
#else
            cexAdded = true;
            AddCounterExample(cex);
            newSamplesAdded = true;
            return false;
#endif
        }

        public bool learn(out HashSet<string> funcsChanged)
        {
            funcsChanged = null;

            // Call C5 on the names/data file
            generateC5Files();

            var start = DateTime.Now;
            var inc = start - start;

            // Prepare the C5 process to run
            ProcessStartInfo process = new ProcessStartInfo();
            //process.FileName = "C:\\work\\machine learning\\svn\\C50\\c5.0." + this.config;
            process.FileName = ".\\c5.0." + this.config;
            //process.FileName = "c5.0dbg";
            //process.FileName = "C:\\work\\Strand\\svn\\Strand\\Boogie\\Binaries\\c5.0";
            //process.FileName = "..\\..\\..\\Binaries\\c5.0";
            process.Arguments = "-I 1 -m 1 -f " + filename;
            if (CommandLineOptions.Clo.Trace)
            {
                Console.WriteLine("c5 filename: " + process.FileName);
            }
            process.WindowStyle = ProcessWindowStyle.Hidden;
            process.CreateNoWindow = true;
            process.UseShellExecute = false;
            process.RedirectStandardOutput = true;

            // Run the external process & wait for it to finish
            Process proc = Process.Start(process);
            string output = proc.StandardOutput.ReadToEnd();
            proc.WaitForExit();
            inc = (DateTime.Now - start);
            c5LearnerTime += inc;
            c5LearnerQueries++;

            // Retrieve the app's exit code
            int exitCode = proc.ExitCode;
            if (exitCode < 0)
            {
                Console.WriteLine("The learner seems to have run into an error!");
                return false;
            }                            

            if (CommandLineOptions.Clo.Trace)
                Console.WriteLine("Learner (c5) Time taken = " + inc.TotalSeconds.ToString());

            start = DateTime.Now;
#if false
            using (System.IO.TextReader reader = System.IO.File.OpenText(filename + ".out"))
            {
                /*int truetrue_implications = int.Parse(reader.ReadLine());
                int falsetrue_implications = int.Parse(reader.ReadLine());
                int falsefalse_implications = int.Parse(reader.ReadLine());*/
                int truetrue_implications = 0, falsefalse_implications = 0, falsetrue_implications = 0;
                int totaltreesize = int.Parse(reader.ReadLine());
                this.total_truetrue_implications += truetrue_implications;
                this.total_falsetrue_implications += falsetrue_implications;
                this.total_falsefalse_implications += falsefalse_implications;
                this.totalTreeSize += totaltreesize;

                this.last_falsefalse_implications = falsefalse_implications;
                this.last_falsetrue_implications = falsetrue_implications;
                this.last_truetrue_implications = truetrue_implications;
                this.lastTreeSize = totaltreesize;
            }
#endif   
            string c5JSONTree = System.IO.File.ReadAllText(filename + ".json");
            
            funcsChanged = new HashSet<string>();
            // extract the value for the existential functions from the model.            
            C5TreeNode root = JsonConvert.DeserializeObject<C5TreeNode>(c5JSONTree);
            //Debug.Assert(root.attribute.Equals(pcAttrName));

            foreach (var functionName in function2Value.Keys)
            {
                if (function2Value[functionName].constructModel(functionName, root, attribute2Expr, functionID))
                    funcsChanged.Add(functionName);
            }
            this.jsontime += (DateTime.Now - start);

            if (funcsChanged.Count() == 0)
                return false;

            return true;
            //Debug.Assert(funcsChanged.Count > 0);            
        }



        private List<Tuple<string, List<Model.Element>>> ExtractState(string impl, Counterexample error)
        {
            var lastBlock = error.Trace.Last() as Block;
            AssertCmd failingAssert = null;

            CallCounterexample callCounterexample = error as CallCounterexample;
            if (callCounterexample != null)
            {
                Procedure failingProcedure = callCounterexample.FailingCall.Proc;
                Requires failingRequires = callCounterexample.FailingRequires;
                failingAssert = lastBlock.Cmds.OfType<AssertRequiresCmd>().FirstOrDefault(ac => ac.Requires == failingRequires);
            }
            ReturnCounterexample returnCounterexample = error as ReturnCounterexample;
            if (returnCounterexample != null)
            {
                Ensures failingEnsures = returnCounterexample.FailingEnsures;
                failingAssert = lastBlock.Cmds.OfType<AssertEnsuresCmd>().FirstOrDefault(ac => ac.Ensures == failingEnsures);
            }
            AssertCounterexample assertCounterexample = error as AssertCounterexample;
            if (assertCounterexample != null)
            {
                failingAssert = lastBlock.Cmds.OfType<AssertCmd>().FirstOrDefault(ac => ac == assertCounterexample.FailingAssert);
            }

            Debug.Assert(failingAssert != null);
            return ExtractState(impl, failingAssert.Expr, error.Model);
        }

        private Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> P_ExtractState(string impl, Counterexample error)
        {
            var lastBlock = error.Trace.Last() as Block;
            AssertCmd failingAssert = null;

            CallCounterexample callCounterexample = error as CallCounterexample;
            if (callCounterexample != null)
            {
                Procedure failingProcedure = callCounterexample.FailingCall.Proc;
                Requires failingRequires = callCounterexample.FailingRequires;
                failingAssert = lastBlock.Cmds.OfType<AssertRequiresCmd>().FirstOrDefault(ac => ac.Requires == failingRequires);
            }
            ReturnCounterexample returnCounterexample = error as ReturnCounterexample;
            if (returnCounterexample != null)
            {
                Ensures failingEnsures = returnCounterexample.FailingEnsures;
                failingAssert = lastBlock.Cmds.OfType<AssertEnsuresCmd>().FirstOrDefault(ac => ac.Ensures == failingEnsures);
            }
            AssertCounterexample assertCounterexample = error as AssertCounterexample;
            if (assertCounterexample != null)
            {
                failingAssert = lastBlock.Cmds.OfType<AssertCmd>().FirstOrDefault(ac => ac == assertCounterexample.FailingAssert);
            }
            Debug.Assert(failingAssert != null);

            // extract the lhs of the returned tuple from the AssumeCmds
            List<Tuple<string, List<Model.Element>>> lhs = new List<Tuple<string, List<Model.Element>>>();
            foreach (var cmd in error.AssumedCmds) 
            {
                AssumeCmd assumeCmd = cmd as AssumeCmd;
                Debug.Assert(assumeCmd != null);
                lhs.AddRange(P_ExtractState(impl, assumeCmd.Expr, error.Model));
            }

            List<Tuple<string, List<Model.Element>>> rhs = new List<Tuple<string, List<Model.Element>>>();
            rhs = P_ExtractState(impl, failingAssert.Expr, error.Model);
            return Tuple.Create(lhs, rhs);
        }

        private List<Tuple<string, List<Model.Element>>> P_ExtractState(string impl, Expr expr, Model model)
        {
            /*
            var funcsUsed = P_FunctionCollector.Collect(expr);

            var ret = new List<Tuple<string, List<Model.Element>>>();

            foreach (var fn in funcsUsed)
            {
                var fnName = fn.Name;
                if (!constant2FuncCall.ContainsKey(fnName))
                    continue;

                var func = constant2FuncCall[fnName];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<Model.Element>();
                prover.Context.BoogieExprTranslator.Translate(func.Args).Iter(ve => vals.Add(getValue(ve, model)));
                ret.Add(Tuple.Create(funcName, vals));
            }
             */
            
            var funcsUsed = FunctionCollector.Collect(expr);

            var ret = new List<Tuple<string, List<Model.Element>>>();

            foreach (var tup in funcsUsed.Where(t => t.Item2 == null))
            {
                var constant = tup.Item1;
                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                var func = constant2FuncCall[constant.Name];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<Model.Element>();
                prover.Context.BoogieExprTranslator.Translate(func.Args).Iter(ve => vals.Add(getValue(ve, model)));
                ret.Add(Tuple.Create(funcName, vals));
            }

            foreach (var tup in funcsUsed.Where(t => t.Item2 != null))
            {
                var constant = tup.Item1;
                var boundExpr = tup.Item2;

                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                // There are some bound variables (because the existential function was inside an \exists).
                // We must find an assignment for bound varibles 

                // First, peice apart the existential functions
                var cd = new Duplicator();
                var tup2 = ExistentialExprModelMassage.Massage(cd.VisitExpr(boundExpr.Body));
                var be = tup2.Item1;
                Expr env = Expr.True;
                foreach (var ahFunc in tup2.Item2)
                {
                    var tup3 = impl2FuncCalls[impl].First(t => t.Item2.Name == ahFunc.Name);
                    var varList = new List<Expr>();
                    tup3.Item3.Args.OfType<Expr>().Iter(v => varList.Add(v));

                    env = Expr.And(env, function2Value[tup3.Item1].Gamma(varList));
                }
                be = Expr.And(be, Expr.Not(env));

                // map formals to constants
                var formalToConstant = new Dictionary<string, Constant>();
                foreach (var f in boundExpr.Dummies.OfType<Variable>())
                    formalToConstant.Add(f.Name, new Constant(Token.NoToken, new TypedIdent(Token.NoToken, f.Name + "@subst@" + (existentialConstCounter++), f.TypedIdent.Type), false));
                be = Substituter.Apply(new Substitution(v => formalToConstant.ContainsKey(v.Name) ? Expr.Ident(formalToConstant[v.Name]) : Expr.Ident(v)), be);
                formalToConstant.Values.Iter(v => prover.Context.DeclareConstant(v, false, null));

                var reporter = new AbstractHoudiniErrorReporter();
                var ve = prover.Context.BoogieExprTranslator.Translate(be);
                prover.Assert(ve, true);
                prover.Check();
                var proverOutcome = prover.CheckOutcomeCore(reporter);
                if (proverOutcome != ProverInterface.Outcome.Invalid)
                    continue;
                model = reporter.model;

                var func = constant2FuncCall[constant.Name];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<Model.Element>();
                foreach (var funcArg in func.Args.OfType<Expr>())
                {
                    var arg = Substituter.Apply(new Substitution(v => formalToConstant.ContainsKey(v.Name) ? Expr.Ident(formalToConstant[v.Name]) : Expr.Ident(v)), funcArg);
                    vals.Add(getValue(prover.Context.BoogieExprTranslator.Translate(arg), model));
                }
                ret.Add(Tuple.Create(funcName, vals));

            }
            
            return ret;
        }

        private static int existentialConstCounter = 0;

        private List<Tuple<string, List<Model.Element>>> ExtractState(string impl, Expr expr, Model model)
        {
            var funcsUsed = FunctionCollector.Collect(expr);

            var ret = new List<Tuple<string, List<Model.Element>>>();

            foreach (var tup in funcsUsed.Where(t => t.Item2 == null))
            {
                var constant = tup.Item1;
                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                var func = constant2FuncCall[constant.Name];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<Model.Element>();
                prover.Context.BoogieExprTranslator.Translate(func.Args).Iter(ve => vals.Add(getValue(ve, model)));
                ret.Add(Tuple.Create(funcName, vals));
            }

            foreach (var tup in funcsUsed.Where(t => t.Item2 != null))
            {
                var constant = tup.Item1;
                var boundExpr = tup.Item2;

                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                // There are some bound variables (because the existential function was inside an \exists).
                // We must find an assignment for bound varibles 

                // First, peice apart the existential functions
                var cd = new Duplicator();
                var tup2 = ExistentialExprModelMassage.Massage(cd.VisitExpr(boundExpr.Body));
                var be = tup2.Item1;
                Expr env = Expr.True;
                foreach (var ahFunc in tup2.Item2)
                {
                    var tup3 = impl2FuncCalls[impl].First(t => t.Item2.Name == ahFunc.Name);
                    var varList = new List<Expr>();
                    tup3.Item3.Args.OfType<Expr>().Iter(v => varList.Add(v));

                    env = Expr.And(env, function2Value[tup3.Item1].Gamma(varList));
                }
                be = Expr.And(be, Expr.Not(env));

                // map formals to constants
                var formalToConstant = new Dictionary<string, Constant>();
                foreach (var f in boundExpr.Dummies.OfType<Variable>())
                    formalToConstant.Add(f.Name, new Constant(Token.NoToken, new TypedIdent(Token.NoToken, f.Name + "@subst@" + (existentialConstCounter++), f.TypedIdent.Type), false));
                be = Substituter.Apply(new Substitution(v => formalToConstant.ContainsKey(v.Name) ? Expr.Ident(formalToConstant[v.Name]) : Expr.Ident(v)), be);
                formalToConstant.Values.Iter(v => prover.Context.DeclareConstant(v, false, null));

                var reporter = new MLHoudiniErrorReporter();
                var ve = prover.Context.BoogieExprTranslator.Translate(be);
                prover.Assert(ve, true);
                prover.Check();
                var proverOutcome = prover.CheckOutcomeCore(reporter);
                if (proverOutcome != ProverInterface.Outcome.Invalid)
                    continue;
                model = reporter.model;

                var func = constant2FuncCall[constant.Name];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<Model.Element>();
                foreach (var funcArg in func.Args.OfType<Expr>())
                {
                    var arg = Substituter.Apply(new Substitution(v => formalToConstant.ContainsKey(v.Name) ? Expr.Ident(formalToConstant[v.Name]) : Expr.Ident(v)), funcArg);
                    vals.Add(getValue(prover.Context.BoogieExprTranslator.Translate(arg), model));
                }
                ret.Add(Tuple.Create(funcName, vals));

            }

            return ret;
        }

        private Model.Element getValue(VCExpr arg, Model model)
        {

            if (arg is VCExprLiteral)
            {
                //return model.GetElement(arg.ToString());
                return model.MkElement(arg.ToString());
            }

            else if (arg is VCExprVar)
            {
                var el = model.TryGetFunc(prover.Context.Lookup(arg as VCExprVar));
                if (el != null)
                {
                    Debug.Assert(el.Arity == 0 && el.AppCount == 1);
                    return el.Apps.First().Result;
                }
                else
                {
                    // Variable not defined; assign arbitrary value
                    if (arg.Type.IsBool)
                        return model.MkElement("false");
                    else if (arg.Type.IsInt)
                        return model.MkIntElement(0);
                    else
                        return null;
                }
            }
            else if (arg is VCExprNAry && (arg as VCExprNAry).Op is VCExprBvOp)
            {
                // support for BV constants
                var bvc = (arg as VCExprNAry)[0] as VCExprLiteral;
                if (bvc != null)
                {
                    var ret = model.TryMkElement(bvc.ToString() + arg.Type.ToString());
                    if (ret != null && (ret is Model.BitVector)) return ret;
                }
            }
           
            var val = prover.Evaluate(arg);
            if (val is int || val is bool || val is Microsoft.Basetypes.BigNum)
            {
                return model.MkElement(val.ToString());
            }
            else
            {
                Debug.Assert(false);
            }
            return null;
        }

        // Remove functions AbsHoudiniConstant from the expressions and substitute them with "true"
        class ExistentialExprModelMassage : StandardVisitor
        {
            List<Function> ahFuncs;

            public ExistentialExprModelMassage()
            {
                ahFuncs = new List<Function>();
            }

            public static Tuple<Expr, List<Function>> Massage(Expr expr)
            {
                var ee = new ExistentialExprModelMassage();
                expr = ee.VisitExpr(expr);
                return Tuple.Create(expr, ee.ahFuncs);
            }

            public override Expr VisitNAryExpr(NAryExpr node)
            {
                if (node.Fun is FunctionCall && (node.Fun as FunctionCall).FunctionName.StartsWith("AbsHoudiniConstant"))
                {
                    ahFuncs.Add((node.Fun as FunctionCall).Func);
                    return Expr.True;
                }

                return base.VisitNAryExpr(node);
            }
        }

        class FunctionCollector : StandardVisitor
        {
            public List<Tuple<Function, ExistsExpr>> functionsUsed;
            ExistsExpr existentialExpr;

            public FunctionCollector()
            {
                functionsUsed = new List<Tuple<Function, ExistsExpr>>();
                existentialExpr = null;
            }

            public static List<Tuple<Function, ExistsExpr>> Collect(Expr expr)
            {
                var fv = new FunctionCollector();
                fv.VisitExpr(expr);
                return fv.functionsUsed;
            }

            public override QuantifierExpr VisitQuantifierExpr(QuantifierExpr node)
            {
                var oldE = existentialExpr;

                if (node is ExistsExpr)
                    existentialExpr = (node as ExistsExpr);

                node = base.VisitQuantifierExpr(node);

                existentialExpr = oldE;
                return node;
            }

            public override Expr VisitNAryExpr(NAryExpr node)
            {
                if (node.Fun is FunctionCall)
                {
                    var collector = new VariableCollector();
                    collector.Visit(node);

                    if(existentialExpr != null && existentialExpr.Dummies.Intersect(collector.usedVars).Any())
                        functionsUsed.Add(Tuple.Create((node.Fun as FunctionCall).Func, existentialExpr));
                    else
                        functionsUsed.Add(Tuple.Create<Function, ExistsExpr>((node.Fun as FunctionCall).Func, null));
                }

                return base.VisitNAryExpr(node);
            }
        }

        class P_FunctionCollector : StandardVisitor
        {
            public List<Function> functionsUsed;
            
            public P_FunctionCollector()
            {
                functionsUsed = new List<Function>();
            }

            public static List<Function> Collect(Expr expr)
            {
                var fv = new P_FunctionCollector();
                fv.VisitExpr(expr);
                return fv.functionsUsed;
            }

            public override BinderExpr VisitBinderExpr(BinderExpr node)
            {
                Debug.Assert(false);
 	            return base.VisitBinderExpr(node);
            }
                 
            public override Expr VisitNAryExpr(NAryExpr node)
            {
                if (node.Fun is FunctionCall)
                {
                    var collector = new VariableCollector();
                    collector.Visit(node);

                    functionsUsed.Add((node.Fun as FunctionCall).Func);
                }

                return base.VisitNAryExpr(node);
            }
        }

        class MLHoudiniCounterexampleCollector : VerifierCallback
        {
            /*public HashSet<string> funcsChanged;            
            public int numErrors;
             */
            public string currImpl;
            public List<Counterexample> real_errors;
            public List<Counterexample> conjecture_errors;
            public List<Counterexample> implication_errors;

            MLHoudini container;

            public MLHoudiniCounterexampleCollector(MLHoudini container)
            {
                this.container = container;
                Reset(null);
            }

            public void Reset(string impl)
            {
                //funcsChanged = new HashSet<string>();
                currImpl = impl;
                //numErrors = 0;
                real_errors = new List<Counterexample>();
                conjecture_errors = new List<Counterexample>();
                implication_errors = new List<Counterexample>();
            }

            public override void OnCounterexample(Counterexample ce, string reason)
            {                
                //numErrors++;                
#if Pranav
                bool counterExampleAdded;
                if (container.HandleCounterExample(currImpl, ce, out counterExampleAdded))
                {
                    real_errors.Add(ce);
                }
                else
                {
                    if (counterExampleAdded)
                    {
                        conjecture_errors.Add(ce);
                    }
                }
#endif
                bool cexAdded;
                if (container.HandleCounterExample(currImpl, ce, out cexAdded))
                {
                    real_errors.Add(ce);
                }
                else
                {
                    if (cexAdded)
                    {
                        conjecture_errors.Add(ce);
                    }
                    else
                    {
                        implication_errors.Add(ce);
                    }
                }
                //funcsChanged.UnionWith(
                //    container.HandleCounterExample(currImpl, ce));
            }
        }

        private void GenVC(Implementation impl)
        {
            ModelViewInfo mvInfo;
            Dictionary<int, Absy> label2absy;
            var collector = new MLHoudiniCounterexampleCollector(this);
            collector.OnProgress("HdnVCGen", 0, 0, 0.0);

            if (CommandLineOptions.Clo.Trace)
            {
                Console.WriteLine("Generating VC of {0}", impl.Name);
            }

            vcgen.ConvertCFG2DAG(impl);
            var gotoCmdOrigins = vcgen.PassifyImpl(impl, out mvInfo);

            // Inline functions
            (new InlineFunctionCalls()).VisitBlockList(impl.Blocks);

            ExtractQuantifiedExprs(impl);
            StripOutermostForall(impl);

            //CommandLineOptions.Clo.PrintInstrumented = true;
            //var tt = new TokenTextWriter(Console.Out);
            //impl.Emit(tt, 0);
            //tt.Close();

            // Intercept the FunctionCalls of the existential functions, and replace them with Boolean constants
            var existentialFunctionNames = new HashSet<string>(existentialFunctions.Keys);
            var fv = new ReplaceFunctionCalls(existentialFunctionNames);
            fv.VisitBlockList(impl.Blocks);

            impl2functionsAsserted.Add(impl.Name, fv.functionsAsserted);
            impl2functionsAssumed.Add(impl.Name, fv.functionsAssumed);

            fv.functionsAssumed.Iter(f => function2implAssumed[f].Add(impl.Name));
            fv.functionsAsserted.Iter(f => function2implAsserted[f].Add(impl.Name));

            impl2FuncCalls.Add(impl.Name, fv.functionsUsed);
            fv.functionsUsed.Iter(tup => constant2FuncCall.Add(tup.Item2.Name, tup.Item3));

            HashSet<string> constantsAssumed = new HashSet<string>();
            fv.functionsUsed.Where(tup => impl2functionsAssumed[impl.Name].Contains(tup.Item1)).Iter(tup => constantsAssumed.Add(tup.Item2.Name));

            var gen = prover.VCExprGen;
            VCExpr controlFlowVariableExpr = CommandLineOptions.Clo.UseLabels ? null : gen.Integer(Microsoft.Basetypes.BigNum.ZERO);

            var vcexpr = vcgen.P_GenerateVC(impl, constantsAssumed, controlFlowVariableExpr, out label2absy, prover.Context);
            //var vcexpr = vcgen.GenerateVC(impl, controlFlowVariableExpr, out label2absy, prover.Context);

            if (!CommandLineOptions.Clo.UseLabels)
            {
                VCExpr controlFlowFunctionAppl = gen.ControlFlowFunctionApplication(gen.Integer(Microsoft.Basetypes.BigNum.ZERO), gen.Integer(Microsoft.Basetypes.BigNum.ZERO));
                VCExpr eqExpr = gen.Eq(controlFlowFunctionAppl, gen.Integer(Microsoft.Basetypes.BigNum.FromInt(impl.Blocks[0].UniqueId)));
                vcexpr = gen.Implies(eqExpr, vcexpr);
            }

            ProverInterface.ErrorHandler handler = null;
            if (CommandLineOptions.Clo.vcVariety == CommandLineOptions.VCVariety.Local)
                handler = new VCGen.ErrorReporterLocal(gotoCmdOrigins, label2absy, impl.Blocks, vcgen.incarnationOriginMap, collector, mvInfo, prover.Context, program);
            else
                handler = new VCGen.ErrorReporter(gotoCmdOrigins, label2absy, impl.Blocks, vcgen.incarnationOriginMap, collector, mvInfo, prover.Context, program);

            impl2ErrorHandler.Add(impl.Name, Tuple.Create(handler, collector));

            //Console.WriteLine("VC of {0}: {1}", impl.Name, vcexpr);

            // Create a macro so that the VC can sit with the theorem prover
            Macro macro = new Macro(Token.NoToken, impl.Name + "Macro", new List<Variable>(), new Formal(Token.NoToken, new TypedIdent(Token.NoToken, "", Bpl.Type.Bool), false));
            prover.DefineMacro(macro, vcexpr);

            //Console.WriteLine("Function " + impl.Name + ":\n" + vcexpr.ToString());

            // Store VC
            impl2VC.Add(impl.Name, gen.Function(macro));

            // HACK: push the definitions of constants involved in function calls
            // It is possible that some constants only appear in function calls. Thus, when
            // they are replaced by Boolean constants, it is possible that (get-value) will 
            // fail if the expression involves such constants. All we need to do is make sure
            // these constants are declared, because otherwise, semantically we are doing
            // the right thing.
            foreach (var tup in fv.functionsUsed)
            {
                // Ignore ones with bound varibles
                if (tup.Item2.InParams.Count > 0) continue;
                var tt = prover.Context.BoogieExprTranslator.Translate(tup.Item3);
                tt = prover.VCExprGen.Or(VCExpressionGenerator.True, tt);
                prover.Assert(tt, true);
            }
        }

        // convert "foo(... forall e ...) to:
        //    (p iff forall e) ==> foo(... p ...) 
        // where p is a fresh boolean variable and foo is an existential constant
        private void ExtractQuantifiedExprs(Implementation impl)
        {
            var funcs = new HashSet<string>(existentialFunctions.Keys);
            foreach (var blk in impl.Blocks)
            {
                foreach (var acmd in blk.Cmds.OfType<AssertCmd>())
                {
                    var ret = ExtractQuantifiers.Extract(acmd.Expr, funcs);
                    acmd.Expr = ret.Item1;
                    impl.LocVars.AddRange(ret.Item2);
                }
            }
        }

        // convert "assert e1 && forall x: e2" to
        //    assert e1 && e2[x <- x@bound]
        private void StripOutermostForall(Implementation impl)
        {
            var funcs = new HashSet<string>(existentialFunctions.Keys);
            foreach (var blk in impl.Blocks)
            {
                foreach (var acmd in blk.Cmds.OfType<AssertCmd>())
                {
                    var ret = StripQuantifiers.Run(acmd.Expr, funcs);
                    acmd.Expr = ret.Item1;
                    impl.LocVars.AddRange(ret.Item2);
                }
            }
        }

        private void Inline()
        {
            if (CommandLineOptions.Clo.InlineDepth < 0)
                return;

            var callGraph = BuildCallGraph();

            foreach (Implementation impl in callGraph.Nodes)
            {
                InlineRequiresVisitor inlineRequiresVisitor = new InlineRequiresVisitor();
                inlineRequiresVisitor.Visit(impl);
            }

            foreach (Implementation impl in callGraph.Nodes)
            {
                FreeRequiresVisitor freeRequiresVisitor = new FreeRequiresVisitor();
                freeRequiresVisitor.Visit(impl);
            }

            foreach (Implementation impl in callGraph.Nodes)
            {
                InlineEnsuresVisitor inlineEnsuresVisitor = new InlineEnsuresVisitor();
                inlineEnsuresVisitor.Visit(impl);
            }

            foreach (Implementation impl in callGraph.Nodes)
            {
                impl.OriginalBlocks = impl.Blocks;
                impl.OriginalLocVars = impl.LocVars;
            }
            foreach (Implementation impl in callGraph.Nodes)
            {
                CommandLineOptions.Inlining savedOption = CommandLineOptions.Clo.ProcedureInlining;
                CommandLineOptions.Clo.ProcedureInlining = CommandLineOptions.Inlining.Spec;
                Inliner.ProcessImplementationForHoudini(program, impl);
                CommandLineOptions.Clo.ProcedureInlining = savedOption;
            }
            foreach (Implementation impl in callGraph.Nodes)
            {
                impl.OriginalBlocks = null;
                impl.OriginalLocVars = null;
            }

            Graph<Implementation> oldCallGraph = callGraph;
            callGraph = new Graph<Implementation>();
            foreach (Implementation impl in oldCallGraph.Nodes)
            {
                callGraph.AddSource(impl);
            }
            foreach (Tuple<Implementation, Implementation> edge in oldCallGraph.Edges)
            {
                callGraph.AddEdge(edge.Item1, edge.Item2);
            }
            int count = CommandLineOptions.Clo.InlineDepth;
            while (count > 0)
            {
                foreach (Implementation impl in oldCallGraph.Nodes)
                {
                    List<Implementation> newNodes = new List<Implementation>();
                    foreach (Implementation succ in callGraph.Successors(impl))
                    {
                        newNodes.AddRange(oldCallGraph.Successors(succ));
                    }
                    foreach (Implementation newNode in newNodes)
                    {
                        callGraph.AddEdge(impl, newNode);
                    }
                }
                count--;
            }
        }

        private Graph<Implementation> BuildCallGraph()
        {
            Graph<Implementation> callGraph = new Graph<Implementation>();
            Dictionary<Procedure, HashSet<Implementation>> procToImpls = new Dictionary<Procedure, HashSet<Implementation>>();
            foreach (Declaration decl in program.TopLevelDeclarations)
            {
                Procedure proc = decl as Procedure;
                if (proc == null) continue;
                procToImpls[proc] = new HashSet<Implementation>();
            }
            foreach (Declaration decl in program.TopLevelDeclarations)
            {
                Implementation impl = decl as Implementation;
                if (impl == null || impl.SkipVerification) continue;
                callGraph.AddSource(impl);
                procToImpls[impl.Proc].Add(impl);
            }
            foreach (Declaration decl in program.TopLevelDeclarations)
            {
                Implementation impl = decl as Implementation;
                if (impl == null || impl.SkipVerification) continue;
                foreach (Block b in impl.Blocks)
                {
                    foreach (Cmd c in b.Cmds)
                    {
                        CallCmd cc = c as CallCmd;
                        if (cc == null) continue;
                        foreach (Implementation callee in procToImpls[cc.Proc])
                        {
                            callGraph.AddEdge(impl, callee);
                        }
                    }
                }
            }
            return callGraph;
        }
    }   

    public interface MLICEDomain
    {
        bool constructModel(string funcName, C5TreeNode root, Dictionary<string, Dictionary<string, Expr>> attr2Expr, Dictionary<string, int> functionID);  // returns whether the abstract value has changed?
        Expr Gamma(List<Expr> vars);
        //bool TypeCheck(List<Type> argTypes, out string msg);     
    }   

    public class C5Domain : MLICEDomain
    {
        List<string> vars;
        Expr model;
        
        public C5Domain(List<Variable> functionFormalParams)
        {            
            // Initialize the invariant function with "true".
            vars = new List<string>();
            foreach (var v in functionFormalParams)
            {
                vars.Add(v.Name);
            }
            model = Expr.True;            
            //model = Expr.False;
        }

        public Expr Gamma(List<Expr> newvars)
        {
            return ExtendsExpr.replace(model, vars, newvars);            
        }

        /*
        public bool TypeCheck(List<Type> argTypes, out string msg)
        {
            msg = "";
            foreach(var argType in argTypes)
            {
                if (!argType.IsInt || !argType.IsBool)
                {
                    msg = "Illegal type, expecting int or bool";
                    return false;
                }
            }
            return true;
        }
        */

        public bool constructModel(string funcName, C5TreeNode root, Dictionary<string, Dictionary<string, Expr>> attr2Expr, Dictionary<string, int> functionID)
        {
            Debug.Assert(attr2Expr.Keys.Contains(funcName));
            Debug.Assert(functionID.Keys.Contains(funcName));
            return constructModel(root.children[functionID[funcName]], attr2Expr[funcName]);
        }


        public bool constructModel(C5TreeNode node, Dictionary<string, Expr> attr2Expr)
        {
            Debug.Assert(attr2Expr != null);
            Expr oldmodel = model;
            List<Expr> stack = new List<Expr>();
            stack.Add(Expr.True);
            List<List<Expr>> finalformula = node.constructBoogieExpr(stack, attr2Expr);
            if (finalformula.Count() == 0)
            {
                model = Expr.False;
                return !ExtendsExpr.EqualityComparer(model, oldmodel);
            }

            model = ExtendsExpr.disjunction(finalformula);
            if (ExtendsExpr.EqualityComparer(model, oldmodel))
            {
                //Console.WriteLine("old model: ");
                //Console.WriteLine(oldmodel.ToString());
                //Console.WriteLine("new model: ");
                //Console.WriteLine(model.ToString());                
                return false;
            }
            else
                return true;
        }
        
        /*
        public Term constructSMTConstraint(List<Model.Element> states, ref Z3Context z3Context)
        {
            Debug.Assert(states.Count == 1);
            var state = states[0] as Model.Integer;
            if (state == null)
                throw new ICEHoudiniInternalError("Incorrect type, expected int");
            var intval = state.AsInt();

            Context context = z3Context.context;

            Term termUpperLimit = context.MkConst(this.str + "_ul", z3Context.intSort);
            Term termLowerLimit = context.MkConst(this.str + "_ll", z3Context.intSort);
            Term termHasUpperLimit = context.MkConst(this.str + "_hul", z3Context.boolSort);
            Term termHasLowerLimit = context.MkConst(this.str + "_hll", z3Context.boolSort);

            Term c1_id = context.MkImplies(termHasLowerLimit, context.MkLe(termLowerLimit, context.MkNumeral(intval, z3Context.intSort)));
            Term c2_id = context.MkImplies(termHasUpperLimit, context.MkLe(context.MkNumeral(intval, z3Context.intSort), termUpperLimit));

            return context.MkAnd(c1_id, c2_id);
        }

        public bool initializeFromModel(Z3.Model model, ref Z3Context z3Context)
        {
            Debug.Assert(model != null);
            Context context = z3Context.context;

            Term termUpperLimit = context.MkConst(this.str + "_ul", z3Context.intSort);
            Term termLowerLimit = context.MkConst(this.str + "_ll", z3Context.intSort);
            Term termHasUpperLimit = context.MkConst(this.str + "_hul", z3Context.boolSort);
            Term termHasLowerLimit = context.MkConst(this.str + "_hll", z3Context.boolSort);

            bool ret = false;

            int ul = context.GetNumeralInt(model.Eval(termUpperLimit));
            int ll = context.GetNumeralInt(model.Eval(termLowerLimit));
            bool hul = context.GetBoolValue(model.Eval(termHasUpperLimit)).getBool();
            bool hll = context.GetBoolValue(model.Eval(termHasLowerLimit)).getBool();

            if((hasUpperLimit != hul) || (hasUpperLimit && hul && (upperLimit != ul)))
                ret = true;

            if ((hasLowerLimit != hll) || (hasLowerLimit && hll && (lowerLimit != ll)))
                ret = true;

            upperLimit = ul;
            lowerLimit = ll;
            hasUpperLimit = hul;
            hasLowerLimit = hll;
            return ret;
        }
        */

        /*
        public Term currLearnedInvAsTerm(ref Z3Context z3Context)
        {
            Context context = z3Context.context;
            Term termUpperLimit = context.MkConst(this.str + "_ul", z3Context.intSort);
            Term termLowerLimit = context.MkConst(this.str + "_ll", z3Context.intSort);
            Term termHasUpperLimit = context.MkConst(this.str + "_hul", z3Context.boolSort);
            Term termHasLowerLimit = context.MkConst(this.str + "_hll", z3Context.boolSort);

            List<Term> args = new List<Term>();
            args.Add(this.hasUpperLimit ? termHasUpperLimit : context.MkNot(termHasUpperLimit));
            args.Add(this.hasLowerLimit ? termHasLowerLimit : context.MkNot(termHasLowerLimit));
            args.Add(context.MkEq(termUpperLimit, context.MkNumeral(this.upperLimit, z3Context.intSort)));
            args.Add(context.MkEq(termLowerLimit, context.MkNumeral(this.lowerLimit, z3Context.intSort)));            

            return context.MkAnd(args.ToArray());
        }*/

    }

    /*
    class InlineFunctionCalls : StandardVisitor
    {
        public Stack<string> inlinedFunctionsStack;

        public InlineFunctionCalls()
        {
            inlinedFunctionsStack = new Stack<string>();
        }

        public override Expr VisitNAryExpr(NAryExpr node)
        {
            var fc = node.Fun as FunctionCall;
            if (fc != null && fc.Func.Body != null && QKeyValue.FindBoolAttribute(fc.Func.Attributes, "inline"))
            {
                if (inlinedFunctionsStack.Contains(fc.Func.Name))
                {
                    // recursion detected
                    throw new MLHoudiniInternalError("Recursion detected in function declarations");
                }

                // create a substitution
                var subst = new Dictionary<Variable, Expr>();
                for (int i = 0; i < node.Args.Count; i++)
                {
                    subst.Add(fc.Func.InParams[i], node.Args[i]);
                }

                var e =
                    Substituter.Apply(new Substitution(v => subst.ContainsKey(v) ? subst[v] : Expr.Ident(v)), fc.Func.Body);

                inlinedFunctionsStack.Push(fc.Func.Name);

                e = base.VisitExpr(e);

                inlinedFunctionsStack.Pop();

                return e;
            }
            return base.VisitNAryExpr(node);
        }
    }
     */
 
    public class MLHoudiniInternalError : System.ApplicationException
    {
        public MLHoudiniInternalError(string msg) : base(msg) { }

    };


    class InlineFunctionCalls : StandardVisitor
    {
        public Stack<string> inlinedFunctionsStack;

        public InlineFunctionCalls()
        {
            inlinedFunctionsStack = new Stack<string>();
        }

        public override Expr VisitNAryExpr(NAryExpr node)
        {
            var fc = node.Fun as FunctionCall;
            if (fc != null && fc.Func.Body != null && QKeyValue.FindBoolAttribute(fc.Func.Attributes, "inline"))
            {
                if (inlinedFunctionsStack.Contains(fc.Func.Name))
                {
                    // recursion detected
                    throw new MLHoudiniInternalError("Recursion detected in function declarations");
                }

                // create a substitution
                var subst = new Dictionary<Variable, Expr>();
                for (int i = 0; i < node.Args.Count; i++)
                {
                    subst.Add(fc.Func.InParams[i], node.Args[i]);
                }

                var e =
                    Substituter.Apply(new Substitution(v => subst.ContainsKey(v) ? subst[v] : Expr.Ident(v)), fc.Func.Body);

                inlinedFunctionsStack.Push(fc.Func.Name);

                e = base.VisitExpr(e);

                inlinedFunctionsStack.Pop();

                return e;
            }
            return base.VisitNAryExpr(node);
        }
    }
 
    
    class MLHoudiniErrorReporter : ProverInterface.ErrorHandler
    {
        public Model model;

        public MLHoudiniErrorReporter()
        {
            model = null;
        }

        public override void OnModel(IList<string> labels, Model model)
        {
            Debug.Assert(model != null);
            if(CommandLineOptions.Clo.PrintErrorModel >= 1) model.Write(Console.Out);
            this.model = model;
        }
    }

}
