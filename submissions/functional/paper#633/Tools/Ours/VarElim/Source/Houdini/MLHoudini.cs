#define C5


using System;
//using System.Collections;
//using System.Collections.Specialized;
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
    static class Constants{
        public const int BOUND_VALUE = 100001;
    }
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
            return model.ToString() == newmodel.ToString();            
        }
    }

    public class dataPoint
    {
        public List<int> value;
        public string functionName;
        public bool isAbstract;
        public int bound;
        
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
                //bound = b;
                bound = 0;
                isAbstract = false;
            }
            catch(Exception e)
            {
                Console.WriteLine("Exception caught while converting model into a list of integer");
                throw e;
            }
        }

        public dataPoint(string funcName, List<int> lm) {
            List<int> ret = new List<int>();
            foreach (var m in lm)
            {
                ret.Add(m);
            }
            value = ret;
            //value = lm;
            functionName = funcName;
            bound = 0;
            isAbstract = false;
        }

        public dataPoint(string funcName, List<int> lm, int bound, bool isAbstract = false)
        {
            List<int> ret = new List<int>();
            foreach (var m in lm)
            {
                ret.Add(m);
            }
            value = ret;
            //value = lm;
            functionName = funcName;
            this.bound = bound;
            this.isAbstract = isAbstract;
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
                //&& this.bound == other.bound
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
            //ret += ":bound = " + bound.ToString();
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
        Dictionary<string, string> funcNameMap; 

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

        // impl -> constansAssumed
        Dictionary<string, HashSet<string>> impl2constantsAssumed;

        // Essentials: VCGen, Prover
        VCGen vcgen;
        ProverInterface prover;
        // List that contains the bounds for values in cex to try.
        List<int> bounds4cex;
                       

        // name of the Boogie program being verified: used for generating C5 files.
        string learnerDir;
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

        int currentBound; // record current global bound value

        // Z3 context for implementing the SMT-based ICE learner.
        HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> counterExamples;
        HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> implicationCounterExamples; 
       
        //counterexample to sample point state
        Dictionary<Counterexample, Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> cexToPointState;
        // record counterexample's integer bound
        Dictionary<Counterexample, int> cexToBound; 

#if C5
        // Data structures for storing and creating C5 sample
        Dictionary<dataPoint, int> c5samplePointToClassAttr;
        Dictionary<dataPoint, int> c5samplePointToIndex;
        Dictionary<dataPoint, int> dupc5samplePointToClassAttr;
        Dictionary<dataPoint, int> dupc5samplePointToIndex;
        Dictionary<int, dataPoint> indexToDupc5samplePoint;
        Dictionary<int, dataPoint> indexToc5samplePoint;
        List<Tuple<int, int>> c5implications;
        UnionFind<int> equlityClass;
        int c5DataPointsIndex;
        //int generalziedIndex;
        //Dictionary<dataPoint, HashSet<dataPoint>> setOfGeneralizedSample;
        Dictionary<int, HashSet<int>> setOfGeneralizedSample;
#endif          

        // flags to track the outcome of validity of a VC
        bool VCisValid;

        //debug info
        //string debugInfo;
        int callTimes;
        int succedTimes;
        TokenTextWriter debugInfo;

        bool debug = true;

        public MLHoudini(Program program, string config, string filename, bool useBounds, string learnerDir="./")
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
            this.impl2constantsAssumed = new Dictionary<string, HashSet<string>>();
            this.funcNameMap = new Dictionary<string,string>(); 
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
            cexToPointState = new Dictionary<Counterexample, Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>>();
            cexToBound = new Dictionary<Counterexample, int>();
            bounds4cex = new List<int>();
            this.filename = filename;
            this.config = config;
            this.useBounds = useBounds;
            this.learnerDir = learnerDir;
            this.currentBound = -1;
            this.callTimes = 0;
            this.succedTimes = 0;
            // config = alg1, alg2, alg3, alg4, smallcex_alg1, smallcex_alg2, ...

            if (this.useBounds)
            {
                bounds4cex.Add(2);
                bounds4cex.Add(6);//5
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
            //this.generalziedIndex = 0;
            this.c5samplePointToClassAttr = new Dictionary<dataPoint, int>();
            this.c5samplePointToIndex = new Dictionary<dataPoint, int>();
            this.dupc5samplePointToClassAttr = new Dictionary<dataPoint, int>();
            this.dupc5samplePointToIndex = new Dictionary<dataPoint, int>();
            this.indexToDupc5samplePoint = new Dictionary<int, dataPoint>();
            this.indexToc5samplePoint = new Dictionary<int, dataPoint>();
            this.c5implications = new List<Tuple<int, int>>();
            this.equlityClass = new UnionFind<int>();
            this.setOfGeneralizedSample = new Dictionary<int, HashSet<int>>();
#endif
            if (debug)
            {
                this.debugInfo = new TokenTextWriter(filename + ".debug");
            }
            this.callTimes = 0;


            var impls = program.TopLevelDeclarations.OfType<Implementation>().Where(
                    impl => impl != null && CommandLineOptions.Clo.UserWantsToCheckRoutine(cce.NonNull(impl.Name)) && !impl.SkipVerification);


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

        private VCGenOutcome LearnInv(Dictionary<string, int> impl2Priority, int method = 0)
        {
            var worklist = new SortedSet<Tuple<int, string>>();
            name2Impl.Keys.Iter(k => worklist.Add(Tuple.Create(impl2Priority[k], k)));

            HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> prevCex = null;
            int prevBound = 0;
            
            while (worklist.Any())
            {
                var impl = worklist.First().Item2;
                worklist.Remove(worklist.First());

                #region vcgen

                var gen = prover.VCExprGen;
                var terms = new List<Expr>();
                int conBound = 0;
                foreach (var tup in impl2FuncCalls[impl])
                {
                    var controlVar = tup.Item2;
                    var exprVars = tup.Item3;
                    var varList = new List<Expr>();
                    exprVars.Args.OfType<Expr>().Iter(v => varList.Add(v));

                    var args = new List<Expr>();
                    controlVar.InParams.Iter(v => args.Add(Expr.Ident(v)));

                    Expr varConstriants = function2Value[tup.Item1].Gamma(varList);
                    Expr term = Expr.Eq(new NAryExpr(Token.NoToken, new FunctionCall(controlVar), args),
                                 varConstriants);

                    if (controlVar.InParams.Count != 0)
                    {
                        term = new ForallExpr(Token.NoToken, new List<Variable>(controlVar.InParams.ToArray()),
                            new Trigger(Token.NoToken, true, new List<Expr> { new NAryExpr(Token.NoToken, new FunctionCall(controlVar), args) }),
                            term);
                    }
                    terms.Add(term);
                }
                var env = BinaryTreeAnd(terms, 0, terms.Count - 1);

                env.Typecheck(new TypecheckingContext((IErrorSink)null));
                var envVC = prover.Context.BoogieExprTranslator.Translate(env);
                var vc = gen.Implies(envVC, impl2VC[impl]);

                ++callTimes;
                //if (CommandLineOptions.Clo.Trace)
                //{
                //    debugInfo.WriteLine("Iteration " + callTimes.ToString() + ": \n");
                //}

                if (CommandLineOptions.Clo.Trace)
                {
                    Console.WriteLine("Verifying {0}: ", impl);
                    //Console.WriteLine("env: {0}", envVC);
                    var envFuncs = new HashSet<string>();
                    impl2FuncCalls[impl].Iter(tup => envFuncs.Add(tup.Item1));
                    envFuncs.Iter(f => PrintFunction(existentialFunctions[f]));
                    envFuncs.Iter(f => PrintFunction(existentialFunctions[f], debugInfo));
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

                    int bound = -1;
                    /* Last iteration is when there are enforced no bounds on the cex values. */
                    if (i < bounds4cex.Count())
                    {
                        bound = bounds4cex.ElementAt(i);
                        //if (bound < conBound) continue;
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
                            bound = 1000000;
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
                    currentBound = bound;
#endregion boundcexvalues

                    var handler = impl2ErrorHandler[impl].Item1;
                    var collector = impl2ErrorHandler[impl].Item2;
                    collector.Reset(impl);
                    implicationCounterExamples.Clear();
                    counterExamples.Clear();
                    VCisValid = true;   // set to false if control reaches HandleCounterExample
                    //maybe should let cex record in collector
                    cexToBound.Clear(); 
                    cexToPointState.Clear();
                    setOfGeneralizedSample.Clear();

                    var start = DateTime.Now;

                    prover.Push();
                    prover.Assert(gen.Not(finalVC), true);
                    prover.FlushAxiomsToTheoremProver();
                    prover.Check();

                    ProverInterface.Outcome proverOutcome;
                    
#region GetCounterExample
                    // @Xu: Actually CheckOutcomeCore and ExtendedCheckOutcomeCore is equivalent
                    if (method == 0) {
                        proverOutcome = prover.CheckOutcomeCore(handler);
                    }else{
                        //my extned counter example version
                        bool continueVerify;
                        proverOutcome = prover.ExtendedCheckOutcomeCore(handler, envVC, out continueVerify, bound);
                    }
#endregion


                    /* There was a counterexample found and acted upon while proving the method. */
                    if (collector.real_errors.Count > 0)
                    {
                        return new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.real_errors);
                    }
                    //在最后的时候才加入蕴含例，优先加入了正负例，如果一次迭代中，同时有蕴含和正负例，蕴含例子就会被隐藏掉
                    //这里先暂时在这里注释掉，为避免之后不方便对蕴含例进行扩展
                    //if (collector.conjecture_errors.Count == 0)
                    //{
                    //    // No positive or negative counter-example added. Need to add implication counter-examples
                    //    //Debug.Assert(collector.implication_errors.Count > 0);
                    //    foreach (var cex in implicationCounterExamples)
                    //    {
                    //        AddCounterExample(cex);
                    //    }
                    //}

#region GeneralizeCounterExample

                    //start ask solver whether we can generilize this cex to a set?
                    if (proverOutcome != ProverInterface.Outcome.Undetermined && proverOutcome != ProverInterface.Outcome.Valid)
                    {
                        var solverRes = prover.ExtendedCounterexamples(handler, envVC, bound, -1);
                        callTimes += solverRes.Item1;
                        succedTimes += solverRes.Item2;
                    }
#endregion

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

                    if (!VCisValid) //  &&(!continueVerify || bound == 1000000)
                    {
                        

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

            VCGenOutcome overallOutcome = null, overallOutcome1 = null;

            var start = DateTime.Now;

            overallOutcome = LearnInv(impl2Priority, 1);

            if (CommandLineOptions.Clo.Trace)
            {
                debugInfo.Close();
            }
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

                Console.WriteLine("Number of positive examples:" + this.numPosExamples);
                Console.WriteLine("Number of negative counter-examples:" + this.numNegCounterExamples);
                Console.WriteLine("Number of implications:" + this.numImplications);
                Console.WriteLine("Number of unsat core solver queries :" + this.callTimes);
                Console.WriteLine("Number of succeed unsat core solver queries :" + this.succedTimes);
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
                //existentialFunctions.Values.Iter(PrintFunction);
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
        private void PrintFunction(Function function, TokenTextWriter tt = null)
        {
            //var tt = new TokenTextWriter(Console.Out);
            bool flag = false;
            if (tt == null) { 
                tt = new TokenTextWriter(Console.Out);
                flag = true;
            }
            var invars = new List<Expr>(function.InParams.OfType<Variable>().Select(v => Expr.Ident(v)));
            function.Body = function2Value[function.Name].Gamma(invars);
            function.Emit(tt, 0);
            if(flag == true)
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
                    
//                    foreach (var x in attrVals)
//                    {
//                        if (x == Constants.BOUND_VALUE)
//                        {
//                            ret += ",(-" + p.bound.ToString() + "," + p.bound.ToString() +")";
////                            ret += ",(-" + Constants.BOUND_VALUE + "," + Constants.BOUND_VALUE +")";//XU: Immediately largest test
//                        }
//                        else {
//                            ret += "," + x.ToString();
//                        }
//                       
//                    }
//                    
                    for(int i = 0;i<attrVals.Count;++i)
                    {
                        if (attrVals[i] == Constants.BOUND_VALUE)
                        {
//                            if(minBound[p.functionName][i]==maxBound[p.functionName][i])
//                                ret += "," + minBound[p.functionName][i];
//                            else
//                            ret += ",(" +  -(int)Math.Pow(p.bound/10*10,1.2) + "," +
//                            (int)Math.Pow(p.bound/10*10,1.2) +")";              
//                            ret += ",(" +  Math.Max(2*minBound[p.functionName][i],-(int)Math.Pow(p.bound/10*10,1.2)) + "," +
//                                   Math.Min(2*maxBound[p.functionName][i],(int)Math.Pow(p.bound/10*10,1.2)) +")";
                            ret += ",(" + (-p.bound) + "," +(p.bound) +")";
//                            ret += ",(-" + Constants.BOUND_VALUE + "," + Constants.BOUND_VALUE +")";//XU: Immediately largest test
                        }
                        else {
                            ret += "," + attrVals[i].ToString();
                        }
                       
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
        // Comment@Xu: dfsExtendEachPointAfterGeneralized => is used to extend 5 points
        public void dfsExtendEachPointAfterGeneralized(dataPoint p, List<int> attrVals, List<int> cur, int start, List<int> ori, Dictionary<string, int> argVals, List<string> arguments, HashSet<string> extendVars)
        {
            //while (true) ;
            if (start >= attrVals.Count())
            {
                if (!setOfGeneralizedSample.ContainsKey(this.dupc5samplePointToIndex[p]))
                {
                    setOfGeneralizedSample[this.dupc5samplePointToIndex[p]] = new HashSet<int>();
                }

                if (!cur.SequenceEqual(ori))
                {
                    dataPoint extendedPoint = new dataPoint(p.functionName, cur);
                     
                    if (dupc5samplePointToIndex.ContainsKey(extendedPoint))
                    {
                        setOfGeneralizedSample[this.dupc5samplePointToIndex[p]].Add(dupc5samplePointToIndex[extendedPoint]);
                        if (dupc5samplePointToClassAttr[extendedPoint] != 0 && dupc5samplePointToClassAttr[p] == 0) {
                            Console.WriteLine("The ori point has been assigened from " + extendedPoint.print() + "  to class " + dupc5samplePointToClassAttr[extendedPoint]);
                            dupc5samplePointToClassAttr[p] = dupc5samplePointToClassAttr[extendedPoint];
                        }
                    }
                    else {
                        dupc5samplePointToIndex[extendedPoint] = this.c5DataPointsIndex;
                        indexToDupc5samplePoint[this.c5DataPointsIndex] = extendedPoint;
                        //dupc5samplePointToClassAttr[extendedPoint] = dupc5samplePointToClassAttr[p];
                        dupc5samplePointToClassAttr[extendedPoint] = 0;
                        setOfGeneralizedSample[this.dupc5samplePointToIndex[p]].Add(this.c5DataPointsIndex++);
                    }
                    //equlityClass.union(this.dupc5samplePointToIndex[p], this.dupc5samplePointToIndex[extendedPoint]);
                }
                return;
            }
            if (attrVals[start] == Constants.BOUND_VALUE)
            {
                int d = 2 * currentBound / 4;//需要考虑浮点变为整数吗
                //int d = 1; // 
                int s = 0 - currentBound;
                //while (s <= currentBound) {
                //    cur.Add(s);
                //    int prev = argVals[arguments[start]];
                //    argVals[arguments[start]] = s;
                //    dfsExtendEachPointAfterGeneralized(p, attrVals, cur, start + 1, ori, argVals, arguments, extendVars);
                //    cur.RemoveAt(cur.Count - 1);
                //    argVals[arguments[start]] = prev;
                //    ++s;
                //    Console.WriteLine("iterate ", s);
                //}
                for (int i = 0; i <= 4; ++i)
                {
                    int sp = s + i * d;
                    cur.Add(sp);
                    int prev = argVals[arguments[start]];
                    argVals[arguments[start]] = sp;
                    dfsExtendEachPointAfterGeneralized(p, attrVals, cur, start + 1, ori, argVals, arguments, extendVars);
                    cur.RemoveAt(cur.Count - 1);
                    argVals[arguments[start]] = prev;
                }
            }
            else
            {
                if (isSingleVar(arguments[start]) || notIncludeExtendVar(arguments[start], extendVars))
                {
                    cur.Add(attrVals[start]);
                    dfsExtendEachPointAfterGeneralized(p, attrVals, cur, start + 1, ori, argVals, arguments, extendVars);
                    cur.RemoveAt(cur.Count - 1);
                }
                else {
                    int val = getCurNArayExprVal(arguments[start], argVals);
                    cur.Add(val);
                    int prev = argVals[arguments[start]];
                    argVals[arguments[start]] = val;
                    dfsExtendEachPointAfterGeneralized(p, attrVals, cur, start + 1, ori, argVals, arguments, extendVars);
                    cur.RemoveAt(cur.Count - 1);
                    argVals[arguments[start]] = prev;
                }
                
            }
        }
        public bool isSingleVar(string expr)
        {
            if(expr.IndexOf('(') == -1 && expr.IndexOf(')') == -1)  return true;
            return false;
        }
        public bool notIncludeExtendVar(string expr, HashSet<string> extendVars)
        {
            string delimStr = " ()";
            char[] delimiters = delimStr.ToCharArray();
            string[] substrings = expr.Split(delimiters);
            Stack<string> exprStack;
            for (int i = 0; i < substrings.Count(); ++i) {
                if (extendVars.Contains(substrings[i])) return false;
            }
            return true;
        }
        public int getCurNArayExprVal(string expr, Dictionary<string, int> argVals)
        {
//            if (argVals.ContainsKey(expr)) return argVals[expr]; // Comment@Xu: This makes some example worse
            string delimStr = " ()";
            char[] delimiters = delimStr.ToCharArray();
            string[] substrings = expr.Split(delimiters);
            //int res = 0;
            Stack<string> exprStack = new Stack<string>();
            for (int i = 0; i < substrings.Count(); ++i)
            {
                if (substrings[i].Equals("")) continue;
                if (exprStack.Count > 0 && !isOp(exprStack.Peek()) && !isOp(substrings[i]))
                {
                    string oprands1 = exprStack.Pop(), op = exprStack.Pop(), oprands2 = substrings[i];
                    int tempVal = 0;
                    switch (op) { 
                        case "+":
                            tempVal  = argVals[oprands1] + argVals[oprands2];
                            exprStack.Push(tempVal.ToString());
                            break;
                        case "-":
                            tempVal = argVals[oprands1] - argVals[oprands2];
                            exprStack.Push(tempVal.ToString());
                            break;
                        case "*":
                            tempVal = argVals[oprands1] * argVals[oprands2];
                            exprStack.Push(tempVal.ToString());
                            break;
                        case "/":
                            tempVal = argVals[oprands1] / argVals[oprands2];
                            exprStack.Push(tempVal.ToString());
                            break;
                        default:
                            // not implemented yet
                            Contract.Assert(false);
                            break;
                    }
                    argVals[tempVal.ToString()] = tempVal;
                }
                else {
                    exprStack.Push(substrings[i]);
                }
            }
            try
            {
                int res = Int32.Parse(exprStack.Pop());
                return res;
            }
            catch (FormatException e)
            {
                Console.WriteLine(e.Message);
            }
            catch (Exception e) {
                Console.WriteLine(e.Message);
            }
            return 0;
        }

        private bool isOp(string s) {
            return s.Equals("+") || s.Equals("-") || s.Equals("*") || s.Equals("/");
        }
      
        public void extendDupDataPoint(dataPoint p, dataPoint ori, List<string> arguments)
        {
            string funcName = p.functionName;
            List<int> attrVals = p.value;
            List<int> vals = new List<int>();
            Dictionary<string, int> argVals = new Dictionary<string, int>();
            HashSet<string> extendVars = new HashSet<string>();
            foreach (var exFunc in existentialFunctions)
            {
                if (exFunc.Key.Equals(funcName))
                {
                    bool isSet = false;
                    for (int i = 0; i < attrVals.Count; ++i) {
                        if (attrVals[i] == Constants.BOUND_VALUE) {
                            isSet = true;
                            extendVars.Add(arguments[i]);
                        }
                        argVals[arguments[i]] = attrVals[i];
                    }
                    if (isSet)
                    {
                        //ExprParser ep = new ExprParser(arguments, extendVars, argVals);
                        dfsExtendEachPointAfterGeneralized(p, attrVals, vals, 0, ori.value, argVals, arguments, extendVars);
                    }
                }
            }
        }

#if C5 
        public void RemoveCexForC5(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex, int bound, bool recordImplications = true)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            if (lhs.Count == 0)
            {
                Debug.Assert(rhs.Count == 1);

                // current bound will be a problem
                dataPoint argsval = new dataPoint(rhs.ElementAt(0).Item1, rhs.ElementAt(0).Item2);
                Debug.Assert(c5samplePointToIndex.ContainsKey(argsval));
                Debug.Assert(c5samplePointToClassAttr.ContainsKey(argsval));
                c5samplePointToIndex.Remove(argsval);
                c5samplePointToClassAttr.Remove(argsval);
                dupc5samplePointToClassAttr.Remove(argsval);
                dupc5samplePointToIndex.Remove(argsval);
            }
            else if (rhs.Count == 0)
            {
                if (lhs.Count > 1)
                {
                    List<Tuple<string, List<Model.Element>>> newlhs = new List<Tuple<string, List<Model.Element>>>();
                    newlhs.Add(lhs.ElementAt(lhs.Count - 1));
                    lhs = newlhs;
                }
                Debug.Assert(lhs.Count == 1);

                dataPoint argsval = new dataPoint(lhs.ElementAt(0).Item1, lhs.ElementAt(0).Item2);
                Debug.Assert(c5samplePointToIndex.ContainsKey(argsval));
                Debug.Assert(c5samplePointToClassAttr.ContainsKey(argsval));
                c5samplePointToIndex.Remove(argsval);
                c5samplePointToClassAttr.Remove(argsval);
                dupc5samplePointToClassAttr.Remove(argsval);
                dupc5samplePointToIndex.Remove(argsval);
            }
            else
            {
                Debug.Assert(false); // not reachable
            }
        }       
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
                    if (debug)
                    {
                        debugInfo.WriteLine("Ori Dup Add Pos :" + argsval.print());
                    }
                }
                else
                {
                    c5samplePointToIndex[argsval] = c5DataPointsIndex;
                    //dupc5samplePointToIndex[argsval] = c5DataPointsIndex;
                    indexToc5samplePoint[c5DataPointsIndex] = argsval;
                    //indexToDupc5samplePoint[c5DataPointsIndex] = argsval;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval] = 1;
                    //dupc5samplePointToClassAttr[argsval] = 1;

                    if (debug)
                    {
                        debugInfo.WriteLine("Ori Add Pos :" + argsval.print() + ", index = " + (c5DataPointsIndex - 1).ToString());
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
                //|| this.dupc5samplePointToIndex.ContainsKey(argsval)
                if (this.c5samplePointToIndex.ContainsKey(argsval))
                {
                    //if (!this.c5samplePointToIndex.ContainsKey(argsval))
                    //{
                    //    this.c5samplePointToIndex[argsval] = this.dupc5samplePointToIndex[argsval];
                    //    Debug.Assert(dupc5samplePointToClassAttr[argsval] != 1);
                    //}
                    //else
                    //{
                        Debug.Assert(c5samplePointToClassAttr[argsval] != 1); // should be unknown
                    //}
                    
                    c5samplePointToClassAttr[argsval] = 2;
                    //dupc5samplePointToClassAttr[argsval] = 2;
                    if (debug)
                    {
                        //debugInfo += "Ori Dup Add Neg :" + argsval.print() + "\n";
                        //Console.WriteLine("Ori Dup Add Neg :" + argsval.print());
                        debugInfo.WriteLine("Ori Dup Add Neg :" + argsval.print());
                    }
                }
                else
                {
                    c5samplePointToIndex[argsval] = c5DataPointsIndex;
                    //dupc5samplePointToIndex[argsval] = c5DataPointsIndex;
                    indexToc5samplePoint[c5DataPointsIndex] = argsval;
                    //indexToDupc5samplePoint[c5DataPointsIndex] = argsval;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval] = 2;
                    //dupc5samplePointToClassAttr[argsval] = 2;

                    if (debug)
                    {
                        debugInfo.WriteLine("Ori Add Neg :" + argsval.print() + ", index = " + (c5DataPointsIndex - 1).ToString());
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

                //|| this.dupc5samplePointToIndex.ContainsKey(argsval1)
                if (this.c5samplePointToIndex.ContainsKey(argsval1))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval1] == 0); // is unknown
                    //if (!this.c5samplePointToIndex.ContainsKey(argsval1))
                    //{
                    //    this.c5samplePointToIndex[argsval1] = this.dupc5samplePointToIndex[argsval1];
                    //    c5samplePointToClassAttr[argsval1] = dupc5samplePointToClassAttr[argsval1];
                    //    indexToc5samplePoint[c5samplePointToIndex[argsval1]] = argsval1;
                    //}
                    //Debug.Assert(c5samplePointToIndex[argsval1] == dupc5samplePointToIndex[argsval1]
                    //    && c5samplePointToClassAttr[argsval1] == dupc5samplePointToClassAttr[argsval1]);
                    antecedent = c5samplePointToIndex[argsval1];
                    if (debug)
                    {
                        debugInfo.WriteLine("Overwrote implication left: " + argsval1.print());
                    }
                }
                else
                {
                    c5samplePointToIndex[argsval1] = c5DataPointsIndex;
                    //dupc5samplePointToIndex[argsval1] = c5DataPointsIndex;
                    indexToc5samplePoint[c5DataPointsIndex] = argsval1;
                    //indexToDupc5samplePoint[c5DataPointsIndex] = argsval1;
                    antecedent = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval1] = 0;
                    //dupc5samplePointToClassAttr[argsval1] = 0;
                    if (debug)
                    {
                        debugInfo.WriteLine("Ori Added Implications left: " + argsval1.print());
                    }
                }
                //|| this.dupc5samplePointToIndex.ContainsKey(argsval2)
                if (this.c5samplePointToIndex.ContainsKey(argsval2))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval1] == 0); // is unknown
                    //if (!this.c5samplePointToIndex.ContainsKey(argsval2))
                    //{
                    //    this.c5samplePointToIndex[argsval2] = this.dupc5samplePointToIndex[argsval2];
                    //    c5samplePointToClassAttr[argsval2] = dupc5samplePointToClassAttr[argsval2];
                    //    indexToc5samplePoint[c5samplePointToIndex[argsval2]] = argsval2;
                    //}
                    //Debug.Assert(c5samplePointToIndex[argsval2] == dupc5samplePointToIndex[argsval2]
                    //    && c5samplePointToClassAttr[argsval2] == dupc5samplePointToClassAttr[argsval2]);
                    consequent = c5samplePointToIndex[argsval2];
                    if (debug)
                    {
                        debugInfo.WriteLine("Overwrote implication right: " + argsval2.print());
                        //debugInfo.WriteLine("Added old implication right:" + argsval2.print())
                    };
                }
                else
                {
                    c5samplePointToIndex[argsval2] = c5DataPointsIndex;
                    //dupc5samplePointToIndex[argsval2] = c5DataPointsIndex;
                    indexToc5samplePoint[c5DataPointsIndex] = argsval2;
                    //indexToDupc5samplePoint[c5DataPointsIndex] = argsval2;
                    consequent = c5DataPointsIndex;
                    c5DataPointsIndex++;
                    c5samplePointToClassAttr[argsval2] = 0;
                    //dupc5samplePointToClassAttr[argsval2] = 0;
                    if (debug)
                    {
                        debugInfo.WriteLine("Ori Added Implications right: " + argsval2.print());
                        //debugInfo.WriteLine("Added new implication right:" + argsval2.print());
                    }
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

        List<int> getRoot(int x) { 
            List<int> res = new List<int>();
            int root = equlityClass.find(x);
            if (setOfGeneralizedSample.ContainsKey(root))
            {
                res = setOfGeneralizedSample[root].ToList();
            }
            res.Add(x);
            return res;
        }
        // there constranits is equal constranits
        public void propagateImplication(int reason, int result, List<Tuple<int, int>> constraints) {
            List<int> reasons = new List<int>(), results = new List<int>();
            if (setOfGeneralizedSample.ContainsKey(reason)) {
                reasons = setOfGeneralizedSample[reason].ToList();
            }
            if (setOfGeneralizedSample.ContainsKey(result)) {
                results = setOfGeneralizedSample[result].ToList();
            }
            reasons.Add(reason);
            results.Add(result);
            //debugInfo.WriteLine("Start propagate from " + indexToDupc5samplePoint[reason].print() + " to " + indexToDupc5samplePoint[result].print());
            foreach (int left in reasons) {
                foreach (int right in results) {
                    dataPoint sleft = indexToDupc5samplePoint[left], sright = indexToDupc5samplePoint[right];
                    if (indexToc5samplePoint.ContainsKey(left)) {
                        sleft = indexToc5samplePoint[left];
                    }
                    if (indexToc5samplePoint.ContainsKey(right)) {
                        sright = indexToc5samplePoint[right];
                    }
                    bool added = true;
                    foreach (var cons in constraints) {
                        if (sleft.value[cons.Item1] != sright.value[cons.Item2]) {
                            added = false;
                            break;
                        }
                    }
                    if (added == true)
                    {   
                        Debug.Assert(!(dupc5samplePointToClassAttr[indexToDupc5samplePoint[left]] == 1 && dupc5samplePointToClassAttr[indexToDupc5samplePoint[right]] == 2));
                        c5implications.Add(Tuple.Create(left, right));
                    }
                }
            }
        }
        private void propagateClassLabels(dataPoint s) {
            Debug.Assert(setOfGeneralizedSample.ContainsKey(dupc5samplePointToIndex[s]));
            foreach (var gindex in setOfGeneralizedSample[dupc5samplePointToIndex[s]]) {
                dataPoint gmodel = indexToDupc5samplePoint[gindex];
                Debug.Assert(!(dupc5samplePointToClassAttr[gmodel] != 0 && dupc5samplePointToClassAttr[gmodel] != dupc5samplePointToClassAttr[s]));
                if (dupc5samplePointToClassAttr[gmodel] == 0)
                {
                    dupc5samplePointToClassAttr[gmodel] = dupc5samplePointToClassAttr[s];
                }
                
            }
        }
        public string outputDataPointWithLabel(dataPoint p, Dictionary<dataPoint, int> labels) {
            string res = "";
            res += outputDataPoint(p);
            switch (labels[p])
            {
                case 0: res += ",?\n"; break;
                case 1: res += ",true\n"; break;
                case 2: res += ",false\n"; break;

                default: Debug.Assert(false); break;
            }
            return res;
        }
        public void generateC5Files()
        {
            string dataFile = "";
            string implicationsFile = "";
            string dupDataFile = "";
            string debugDataStr = "";

            foreach (var model in c5samplePointToClassAttr.Keys)
            {
                dataFile += outputDataPointWithLabel(model, c5samplePointToClassAttr);
            }
            //int count = 0;
            //foreach (var index in indexToDupc5samplePoint.Keys) {
            //    if (indexToc5samplePoint.ContainsKey(index))
            //    {
            //        string s = outputDataPointWithLabel(indexToc5samplePoint[index], c5samplePointToClassAttr);
            //        dupDataFile += s;
            //        debugDataStr += count.ToString() + " " + s;
            //    }
            //    else {
            //        string s = outputDataPointWithLabel(indexToDupc5samplePoint[index], dupc5samplePointToClassAttr);
            //        dupDataFile += s;
            //        debugDataStr += count.ToString() + " " + s;
            //    }
            //    ++count;
            //}
            HashSet<int> implicationPoints = new HashSet<int>();
            c5implications.Iter(e => { implicationPoints.Add(e.Item1); implicationPoints.Add(e.Item2); });

            for (int index = 0; index < c5DataPointsIndex; ++index) {
                string s = "";
                if (indexToDupc5samplePoint.ContainsKey(index))
                {
                    if (!indexToc5samplePoint.ContainsKey(index) || !implicationPoints.Contains(index))
                    {
                        s = outputDataPointWithLabel(indexToDupc5samplePoint[index], dupc5samplePointToClassAttr);
                    }
                    else {
                        s = outputDataPointWithLabel(indexToc5samplePoint[index], c5samplePointToClassAttr);
                    }
                }
                else {
                    s = outputDataPointWithLabel(indexToc5samplePoint[index], c5samplePointToClassAttr);
                }
                dupDataFile += s;
            }
            foreach (var implication in c5implications)
            {
                implicationsFile += implication.Item1;
                implicationsFile += " ";
                implicationsFile += implication.Item2;
                implicationsFile += "\n";
                //implicationsFile += propagateImplications(implication.Item1, implication.Item2);

            }

            if (CommandLineOptions.Clo.Trace) {
                debugInfo.WriteLine();
                debugInfo.WriteText(debugDataStr);
                debugInfo.WriteLine();
                debugInfo.WriteText(implicationsFile);
                debugInfo.WriteLine();
            }
           

            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".data"))
            {
                sw.WriteLine(dataFile);
            }
            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".dup.data"))
            {
                sw.WriteLine(dupDataFile);
            }
            using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".implications"))
            {
                sw.WriteLine(implicationsFile);
            }
            
            return;
        }

#endif
        public void RemoveCounterExample(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex, int bound) {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            //counterExamples.Add(cex);
#if true
            if (lhs.Count > 0 && rhs.Count > 0)
            {
                this.numImplications--;
            }
            else if (lhs.Count > 0)
            {
                this.numNegCounterExamples--;
            }
            else
            {
                this.numPosExamples--;
            }
#endif

#if C5
            RemoveCexForC5(cex, bound);
#endif
        
        }
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

        public bool HandleCounterExample(string impl, Counterexample error, out CounterExampleType cexAdded)
        {
            // return true if a true error encountered.
            // return false if the error is due to a wrong choice of current conjecture.
            VCisValid = false;
            var cex = P_ExtractState(impl, error);
            cexToBound.Add(error, currentBound);
            cexToPointState.Add(error, cex);

            // the counter-example does not involve any existential function ==> Is a real counter-example !
            if (cex.Item1.Count == 0 && cex.Item2.Count == 0)
            {
                //realErrorEncountered = true;
                cexAdded = CounterExampleType.REAL;
                return true;
            }

#if true
            if (cex.Item1.Count == 0 || cex.Item2.Count == 0)
            {
                if (cex.Item1.Count == 0)
                    cexAdded = CounterExampleType.POSTIVE;
                else
                    cexAdded = CounterExampleType.NEGATIVE;
                AddCounterExample(cex);
                counterExamples.Add(cex);
                return false;
            }
            else
            {
                cexAdded = CounterExampleType.IMPLICATION;
                implicationCounterExamples.Add(cex);
                //这里先加入蕴含例，之后可能会去掉
                AddCounterExample(cex);
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
            //.\\old\\c5.0.


            // @Xu
            /* Old
            process.FileName = ".\\c5.0." + this.config;
            */
            // New
            //process.FileName = "./IDT4Inv";
            //process.FileName = ".\\c5.0." + this.config;

            //process.FileName = "c5.0dbg.exe";
            //process.FileName = "C:\\work\\Strand\\svn\\Strand\\Boogie\\Binaries\\c5.0";
            //process.FileName = "..\\..\\..\\Binaries\\c5.0";

            // @Xu
            /* Old
            process.Arguments = "-I 1 -m 1 -f " + filename;
            */
            // New
            //process.Arguments = filename;
            //process.Arguments = "-I 1 -m 1 -f " + filename;

            if(this.config == "dt_entropy" || this.config == "dt_penalty")
            {
                // process.FileName = this.learnerDir + "c5.0." + this.config;
                // process.Arguments = "-I 1 -m 1 -f " + filename;
                throw new ArgumentException("Unsupported learner config setting.");
            }
            else if(this.config == "IDT4Inv")
            {
                process.FileName = this.learnerDir + "IDT4Inv";
                process.Arguments = "-o " + filename + ".tree.json " + filename;
            }
            else throw new ArgumentException("Unknown learner config setting.");

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
            
            
            // @Xu
            /* Old
            string c5JSONTree = System.IO.File.ReadAllText(filename + ".json");
            */
            // New
            string c5JSONTree = System.IO.File.ReadAllText(filename + ".tree.json");
            //string c5JSONTree = System.IO.File.ReadAllText(filename + ".json");

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



        private Tuple<List<Tuple<string, List<string>>>, List<Tuple<string, List<string>>>> extractAbstractState(string impl, Counterexample error)
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
            List<Tuple<string, List<string>>> lhs = new List<Tuple<string, List<string>>>();
            foreach (var cmd in error.AssumedCmds)
            {
                AssumeCmd assumeCmd = cmd as AssumeCmd;
                Debug.Assert(assumeCmd != null);
                lhs.AddRange(P_ExtractAbstractState(impl, assumeCmd.Expr, error.Model));
            }

            List<Tuple<string, List<string>>> rhs = new List<Tuple<string, List<string>>>();
            rhs = P_ExtractAbstractState(impl, failingAssert.Expr, error.Model);
            return Tuple.Create(lhs, rhs);
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

        private List<Tuple<string, List<string>>> P_ExtractAbstractState(string impl, Expr expr, Model model)
        {
            var funcsUsed = FunctionCollector.Collect(expr);

            var ret = new List<Tuple<string, List<string>>>();

            foreach (var tup in funcsUsed.Where(t => t.Item2 == null))
            {
                var constant = tup.Item1;
                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                var func = constant2FuncCall[constant.Name];
                var funcName = (func.Fun as FunctionCall).FunctionName;
                var vals = new List<string>();
                prover.Context.BoogieExprTranslator.Translate(func.Args).Iter(ve => vals.Add(ve.ToString()));
                ret.Add(Tuple.Create(constant.Name, vals));
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

            public static int count = 0;

            public Dictionary<string, VCExpr> cex_path_vc_dict;// leave it to become a  hash function convert the long block list name to a short string 
            public Dictionary<Counterexample, Tuple<CounterExampleType, IList<string>, IList<VCExpr>, IList<Block>>> info_of_cex; //record all cex's type and labels on this iteration
            MLHoudini container;
            

            public MLHoudiniCounterexampleCollector(MLHoudini container)
            {
                this.container = container;
                this.cex_path_vc_dict = new Dictionary<string, VCExpr>(); 
                Reset(null);
            }

            public void Reset(string impl)
            {
                //funcsChanged = new HashSet<string>();
                currImpl = impl;
                //numErrors = 0;
                info_of_cex = new Dictionary<Counterexample, Tuple<CounterExampleType, IList<string>, IList<VCExpr>, IList<Block>>>();
                real_errors = new List<Counterexample>();
                conjecture_errors = new List<Counterexample>();
                implication_errors = new List<Counterexample>();
               
            }

            public override void OnCounterexample(Counterexample ce, IList<string/*!*/>/*!*/ labels,  IList<Block> blocks, string reason)
            {                        
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
                CounterExampleType cexAdded;
                if (container.HandleCounterExample(currImpl, ce, out cexAdded))
                {
                    real_errors.Add(ce);
                }
                else
                {
                    if (cexAdded == CounterExampleType.NEGATIVE || cexAdded == CounterExampleType.POSTIVE)
                    {
                        conjecture_errors.Add(ce);
                    }
                    else
                    {
                        implication_errors.Add(ce);
                    }
                }
                IList<VCExpr> stateVaribales =  container.GetCounterexampleState(currImpl, ce, cexAdded, blocks);
                info_of_cex.Add(ce, Tuple.Create(cexAdded, labels, stateVaribales, blocks));
            }


            public override string SetCurrentCounterexamplePathExpr(Counterexample ce)
            {
                string funcName = "";
                CounterExampleType cur_type = info_of_cex[ce].Item1;
                Contract.Assert(cur_type != null);
                if (cur_type == CounterExampleType.NEGATIVE)
                {
                    funcName = currImpl + "NegMacro";
                }
                else if (cur_type == CounterExampleType.POSTIVE)
                {
                    funcName = currImpl + "PosMacro";
                }
                else if (cur_type == CounterExampleType.IMPLICATION)
                {
                    funcName = currImpl + "ImpMacro";
                }

                funcName += count++;

                string pathName = "";
                foreach (Block b in ce.Trace)
                {
                    pathName += b.Label;
                }
                
                // Use dictionary to prevent multiple compute the same kind of cex's VC 
                if (cex_path_vc_dict.ContainsKey(pathName))
                {
                    container.SetMacro(funcName, cex_path_vc_dict[pathName]);
                }
                else {
                    
                    VCExpr res = container.GetCounterexamplePathExpr(ce, currImpl, funcName, info_of_cex[ce].Item4);
                    cex_path_vc_dict.Add(pathName, res);
                }

                return funcName;
            }

            public override IEnumerable<Counterexample> GetAllCounterexamples()
            {
                if (real_errors.Count > 0)
                {
                    return real_errors;
                }
                else if (conjecture_errors.Count > 0)
                {
                    return conjecture_errors;
                }
                else if (implication_errors.Count > 0)
                {
                    return implication_errors;
                }
                else return null;
                // return conjecture_errors.Concat(implication_errors);
            }

            public override IList<string> GetCounterexampleLabels(Counterexample ce)
            {
                if (info_of_cex.ContainsKey(ce))
                {
                    return info_of_cex[ce].Item2;
                }
                return null;
            }

            public override IList<Block> GetCounterexampleBlocks(Counterexample ce)
            {
                if (info_of_cex.ContainsKey(ce))
                {
                    return info_of_cex[ce].Item4;
                }
                return null;
            }

            public override IList<VCExpr> GetCounterexampleState(Counterexample ce)
            {
                if (info_of_cex.ContainsKey(ce))
                {
                    return info_of_cex[ce].Item3;
                }
                return null;
            }

            public override void ExtendCounterexample(Counterexample ce, IList<VCExpr> frees)
            {
                container.ExtendCounterexample(currImpl, ce, frees);
            }
        }

        int GetModelElementIntValue(Model.Element m) {
            if (m.Kind == Model.ElementKind.Boolean)
            {
                bool val = (m as Model.Boolean).Value;
                if (val)
                {
                    return 1;
                }
                else
                {
                    return 0;
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
                    return -1 * arg.AsInt();
                }
                else if (dv.ConstructorName.Equals("+"))
                {
                    return arg.AsInt();
                }
                else
                {
                    throw new MLHoudiniInternalError("Unexpected constructor name in the data value returned by the model\n");
                }
            }
            else
            {
                Debug.Assert(m.Kind == Model.ElementKind.Integer);
                return m.AsInt();
            }
        }

        public Dictionary<string, List<int>> maxBound = new Dictionary<string, List<int>>();
        public Dictionary<string, List<int>> minBound = new Dictionary<string, List<int>>();

        void recordMaxMinBound(dataPoint dp) {
            if (!maxBound.ContainsKey(dp.functionName)) {
                maxBound.Add(dp.functionName, new List<int>());
                minBound.Add(dp.functionName, new List<int>());
                for (int i = 0; i < dp.value.Count; ++i) {
                    maxBound[dp.functionName].Add(Int32.MinValue);
                    minBound[dp.functionName].Add(Int32.MaxValue);
                }
            }
            for (int i = 0; i < dp.value.Count; ++i) {
                if (dp.value[i] > maxBound[dp.functionName][i]) maxBound[dp.functionName][i] = dp.value[i];
                if (dp.value[i] < minBound[dp.functionName][i]) minBound[dp.functionName][i] = dp.value[i];
            }
        }
        public void ExtendCounterexample(string impl, Counterexample ce, IList<VCExpr> frees, bool recordImplications = true)
        {
            Debug.Assert(cexToBound.Keys.Contains(ce));
            Debug.Assert(cexToPointState.Keys.Contains(ce));

            var handler = impl2ErrorHandler[impl].Item1;
            

            List<Tuple<string, NAryExpr, string>> funcCalls = new List<Tuple<string, NAryExpr, string>>();
            IList<Block> blocks = handler.GetCounterExampleBlocks(ce);
            foreach (Block b in blocks) {
                foreach (var cmd in b.Cmds.OfType<PredicateCmd>()) {
                    var funcsUsed = FunctionCollector.Collect(cmd.Expr);
                    foreach (var tup in funcsUsed.Where(t => t.Item2 == null))
                    {
                        var constant = tup.Item1;
                        if (!constant2FuncCall.ContainsKey(constant.Name))
                            continue;
                        NAryExpr func = constant2FuncCall[constant.Name];
                        funcCalls.Add(Tuple.Create(funcNameMap[constant.Name], func, constant.Name));
                    }
                }
            }

            int bound = cexToBound[ce];
            Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex = cexToPointState[ce];
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1, rhs = cex.Item2;
            Tuple<List<Tuple<string, List<string>>>, List<Tuple<string, List<string>>>> absCex = extractAbstractState(impl, ce);
            List<Tuple<string, List<string>>> absLhs = absCex.Item1, absRhs = absCex.Item2;

            //Dictionary<string, List<int>> matchPositions = new Dictionary<string, List<int>>();
            Dictionary<string, List<Tuple<int, string>>> matchFuncAndVars = new Dictionary<string, List<Tuple<int, string>>>();

            foreach (VCExpr expr in frees) {
                VCExprNAry equalExpr = expr as VCExprNAry;
                Debug.Assert(equalExpr != null && equalExpr.Arity == 2);
                VCExpr argument = equalExpr[0];
                bool match = false;
                for(int j = 0; j < funcCalls.Count; ++j)
                {
                    var funcName = funcCalls[j].Item1;
                    var func = funcCalls[j].Item2;
                    for (int i = 0; i < func.Args.Count; ++i) {
                        VCExpr ve = prover.Context.BoogieExprTranslator.Translate(func.Args[i]);
                        if (ve.ToString() == argument.ToString()) {
                            match = true;
                            if (!matchFuncAndVars.Keys.Contains(funcCalls[j].Item3)) {
                                matchFuncAndVars.Add(funcCalls[j].Item3, new List<Tuple<int, string>>());
                            }
                            matchFuncAndVars[funcCalls[j].Item3].Add(Tuple.Create(i, func.Args[i].ToString()));
                            break;
                        }
                    }                                                                                                                                                                            
                }
//                Debug.Assert(match);
                if (!match) return; //复杂变量情况
            }
            //debugInfo.WriteLine("Start Extend: ");
            if (lhs.Count == 0)
            {
                Debug.Assert(rhs.Count == 1);
                //Debug.Assert(matchPositions.Count() == 1);
                
                string funcName = rhs[0].Item1;
                string absFuncName = absRhs[0].Item1;
                Debug.Assert(matchFuncAndVars.ContainsKey(absFuncName));
                List<int> currentVals = new List<int>();
                foreach (var m in rhs.ElementAt(0).Item2)
                {
                    int mv = GetModelElementIntValue(m);
                    currentVals.Add(mv);
                }
                dataPoint oriPoint = new dataPoint(funcName, currentVals);
                //XU:
                recordMaxMinBound(oriPoint);
                int prevIndex = c5samplePointToIndex[oriPoint];

                foreach (var tup in matchFuncAndVars[absFuncName])
                {
                    currentVals[tup.Item1] = Constants.BOUND_VALUE;
                }
                dataPoint argsval = new dataPoint(funcName, currentVals, bound, true);
                // temp: replace c5samplePointToIndex to dupc5samplePointToIndex
                if (dupc5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(dupc5samplePointToClassAttr[argsval] != 2); // should be unknown
                    this.dupc5samplePointToClassAttr[argsval] = 1;
                    
                }
                else
                {
                    dupc5samplePointToClassAttr[argsval] = 1;
                    this.dupc5samplePointToIndex[argsval] = prevIndex;
                    this.indexToDupc5samplePoint[prevIndex] = argsval;
                }

                // List<string> arguments = new List<string>();
                // prover.Context.BoogieExprTranslator.Translate(constant2FuncCall[absFuncName].Args).Iter(ve => arguments.Add(ve.ToString()));
                // extendDupDataPoint(argsval, oriPoint, arguments);
                // propagateClassLabels(argsval);
            }
            else if (rhs.Count == 0)
            {
                if (lhs.Count > 1)
                {
                    List<Tuple<string, List<Model.Element>>> newlhs = new List<Tuple<string, List<Model.Element>>>();
                    newlhs.Add(lhs.ElementAt(lhs.Count - 1));
                    lhs = newlhs;
                }
                if (absLhs.Count > 1)
                {
                    List<Tuple<string, List<string>>> newAbsLhs = new List<Tuple<string, List<string>>>();
                    newAbsLhs.Add(absLhs.ElementAt(absLhs.Count - 1));
                    absLhs = newAbsLhs;
                }

                Debug.Assert(lhs.Count == 1);
                //Debug.Assert(matchPositions.Count() == 1);
                string funcName = lhs[0].Item1;
                string absFuncName = absLhs[0].Item1;
                Debug.Assert(matchFuncAndVars.ContainsKey(absFuncName));
                List<int> currentVals = new List<int>();
                foreach (var m in lhs.ElementAt(0).Item2)
                {
                    int mv = GetModelElementIntValue(m);
                    currentVals.Add(mv);
                }
                dataPoint oriPoint = new dataPoint(funcName, currentVals);
                //XU:
                recordMaxMinBound(oriPoint);
                int prevIndex = c5samplePointToIndex[oriPoint];

                foreach (var tup in matchFuncAndVars[absFuncName])
                {
                    currentVals[tup.Item1] = Constants.BOUND_VALUE;
                }
                dataPoint argsval = new dataPoint(funcName, currentVals, bound, true);


                if (dupc5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(dupc5samplePointToClassAttr[argsval] != 1); // should be unknown
                    this.dupc5samplePointToClassAttr[argsval] = 2;
                }
                else
                {
                    dupc5samplePointToClassAttr[argsval] = 2;
                    dupc5samplePointToIndex[argsval] = prevIndex;
                    this.indexToDupc5samplePoint[prevIndex] = argsval;
                }
                // List<string> arguments = new List<string>();
                // prover.Context.BoogieExprTranslator.Translate(constant2FuncCall[absFuncName].Args).Iter(ve => arguments.Add(ve.ToString()));
                // extendDupDataPoint(argsval, oriPoint, arguments);
                // propagateClassLabels(argsval);
            }
            else {
                return;//XU: no extend implication try
                if (lhs.Count > 1)
                {
                    List<Tuple<string, List<Model.Element>>> newlhs = new List<Tuple<string, List<Model.Element>>>();
                    newlhs.Add(lhs.ElementAt(lhs.Count - 1));
                    lhs = newlhs;
                }
                if (absLhs.Count > 1) {
                    List<Tuple<string, List<string>>> newAbsLhs = new List<Tuple<string, List<string>>>();
                    newAbsLhs.Add(absLhs.ElementAt(absLhs.Count - 1));
                    absLhs = newAbsLhs;
                }
                Debug.Assert(lhs.Count == 1);
                Debug.Assert(rhs.Count == 1);


                string funcNamel = lhs[0].Item1, funcNamer = rhs[0].Item1;
                
                string absFuncNamel = absLhs[0].Item1, absFuncNamer = absRhs[0].Item1;
                Debug.Assert(matchFuncAndVars.ContainsKey(absFuncNamel) || matchFuncAndVars.ContainsKey(absFuncNamer));

                // inv1 and inv2 at least have one extended
                int antecedent, consequent;
                List<int> currentValsl = new List<int>();
                foreach (var m in lhs.ElementAt(0).Item2)
                {
                    int mv = GetModelElementIntValue(m);
                    currentValsl.Add(mv);
                }  
                dataPoint oriPointl = new dataPoint(funcNamel, currentValsl);
                //XU:
                recordMaxMinBound(oriPointl);
//                antecedent = c5samplePointToIndex[oriPointl];
//                dataPoint argsvall = oriPointl;
//                bool isAbstract = false;
//                if (matchFuncAndVars.ContainsKey(absFuncNamel)) {
//                    isAbstract = true;
//                    foreach (var tup in matchFuncAndVars[absFuncNamel])
//                    {
//                        currentValsl[tup.Item1] = Constants.BOUND_VALUE;
//                    }
//                    argsvall = new dataPoint(funcNamel, currentValsl, bound, isAbstract);
//                }
//               
//
                List<int> currentValsr = new List<int>();
                foreach (var m in rhs.ElementAt(0).Item2)
                {
                    int mv = GetModelElementIntValue(m);
                    currentValsr.Add(mv);
                }
                dataPoint oriPointr = new dataPoint(funcNamer, currentValsr);
                //XU:
                recordMaxMinBound(oriPointr);
                return;
                /*
                consequent = c5samplePointToIndex[oriPointr];
                dataPoint argsvalr = oriPointr;
                isAbstract = false;
                if (matchFuncAndVars.ContainsKey(absFuncNamer))
                {
                    isAbstract = true;
                    foreach (var tup in matchFuncAndVars[absFuncNamer])
                    {
                        currentValsr[tup.Item1] = Constants.BOUND_VALUE;
                    }
                    argsvalr = new dataPoint(funcNamer, currentValsr, bound, isAbstract);
                }

                //find some vars that same exits in 2 funcs and will be extend
                List<Tuple<int, int>> sameUnchangedVars = new List<Tuple<int, int>>();
                if (matchFuncAndVars.ContainsKey(absFuncNamel) && matchFuncAndVars.ContainsKey(absFuncNamer))
                {
                    //because vars are not so many ,so just use 2 nested loops
                    foreach (var tupl in matchFuncAndVars[absFuncNamel])
                    {
                        foreach (var tupr in matchFuncAndVars[absFuncNamer])
                        {
                            if (tupl.Item2 == tupr.Item2)
                            {
                                sameUnchangedVars.Add(Tuple.Create(tupl.Item1, tupr.Item1));
                            }
                        }
                    }
                }
                
                // how about there will are some cases that the same original point become different set after serveral times extending
                // I just need to check if there are two points have same int index
                
                if (!dupc5samplePointToClassAttr.ContainsKey(argsvall))
                {
                    dupc5samplePointToClassAttr.Add(argsvall, c5samplePointToClassAttr[oriPointl]);
                    dupc5samplePointToIndex.Add(argsvall, antecedent);
                }

                List<string> argumentsl = new List<string>();
                prover.Context.BoogieExprTranslator.Translate(constant2FuncCall[absFuncNamel].Args).Iter(ve => argumentsl.Add(ve.ToString()));
                extendDupDataPoint(argsvall, oriPointl, argumentsl);
                indexToDupc5samplePoint[antecedent] = argsvall;


//                if (dupc5samplePointToClassAttr[argsvall] != 0 && matchFuncAndVars.ContainsKey(absFuncNamel))
//                {
//                    propagateClassLabels(argsvall);
//                }
               
                if (!dupc5samplePointToClassAttr.ContainsKey(argsvalr))
                {
                    dupc5samplePointToClassAttr.Add(argsvalr, c5samplePointToClassAttr[oriPointr]);
                    dupc5samplePointToIndex.Add(argsvalr, consequent);
                }

                List<string> argumentsr = new List<string>();
                prover.Context.BoogieExprTranslator.Translate(constant2FuncCall[absFuncNamer].Args).Iter(ve => argumentsr.Add(ve.ToString()));
                extendDupDataPoint(argsvalr, oriPointr, argumentsr);
                indexToDupc5samplePoint[consequent] = argsvalr;
//                if (dupc5samplePointToClassAttr[argsvalr] != 0 && matchFuncAndVars.ContainsKey(absFuncNamer))
//                {
//                    propagateClassLabels(argsvalr);
//                }
                
                propagateImplication(dupc5samplePointToIndex[argsvall], dupc5samplePointToIndex[argsvalr], sameUnchangedVars);
                //}
*/
            }
        }
        public VCExpr GetCounterexamplePathExpr(Counterexample ce, string impl, string pathname, IList<Block> blocks)
        {
            bool isPositiveContext = true;
            Dictionary<int, Absy> label2absy = new Dictionary<int, Absy>(); ;
            HashSet<string> constantsAssumed = impl2constantsAssumed[impl];
            //impl2functionsAssumed[impl].Contains(tup.Item1)).Iter(tup => constantsAssumed.Add(tup.Item2.Name);


            //List<Block> blocks = ce.Trace;
            var blocksSet = new HashSet<Block>(blocks);
            Graph<Block> dag = new Graph<Block>();
            dag.AddSource(blocks[0]);
            foreach (Block b in blocks)
            {
                GotoCmd gtc = b.TransferCmd as GotoCmd;
                if (gtc != null)
                {
                    Contract.Assume(gtc.labelTargets != null);
                    foreach (Block dest in gtc.labelTargets)
                    {
                        Contract.Assert(dest != null);
                        if (blocksSet.Contains(dest))
                            dag.AddEdge(dest, b);
                    }
                }
            }

//            IEnumerable<Block> sortedNodes = dag.TopologicalSort();
            List<Block> sortedNodes = dag.TopologicalSort().ToList();
            Contract.Assert(sortedNodes != null);

            var proverCtxt = prover.Context;
            VCExpressionGenerator gen = proverCtxt.ExprGen;
            Contract.Assert(gen != null);
            VCExpr controlFlowVariableExpr = CommandLineOptions.Clo.UseLabels ? null : gen.Integer(Microsoft.Basetypes.BigNum.ZERO);


            Dictionary<Block, VCExprVar> blockVariables = new Dictionary<Block, VCExprVar>();
            List<VCExprLetBinding> bindings = new List<VCExprLetBinding>();
            
            foreach (Block block in sortedNodes.ToList())
            {

//                //@Xu: calc all assume restrictions //ERROR
//                foreach (var cmd in block.Cmds) {
//                    if (cmd is AssumeCmd acmd) {
//                        assumeCmds.Add(proverCtxt.BoogieExprTranslator.Translate(acmd.Expr));
//                    }
//                }
//                assumeRestrictions = gen.NAry(VCExpressionGenerator.AndOp, assumeCmds);
                

                VCExpr SuccCorrect;
                GotoCmd gotocmd = block.TransferCmd as GotoCmd;
                if (gotocmd == null)
                {
                    ReturnExprCmd re = block.TransferCmd as ReturnExprCmd;
                    if (re == null)
                    {
                        SuccCorrect = VCExpressionGenerator.True;
                    }
                    else
                    {
                        SuccCorrect = proverCtxt.BoogieExprTranslator.Translate(re.Expr);
                        if (isPositiveContext)
                        {
                            SuccCorrect = gen.Not(SuccCorrect);
                        }
                    }
                }
                else
                {
                    Contract.Assert(gotocmd.labelTargets != null);
                    List<VCExpr> SuccCorrectVars = new List<VCExpr>(gotocmd.labelTargets.Count);
                    foreach (Block successor in gotocmd.labelTargets)
                    {
                        Contract.Assert(successor != null);
                        if (blocksSet.Contains(successor))
                        {
                            VCExpr s = blockVariables[successor];
                            if (controlFlowVariableExpr != null)
                            {
                                VCExpr controlFlowFunctionAppl = gen.ControlFlowFunctionApplication(controlFlowVariableExpr, gen.Integer(BigNum.FromInt(block.UniqueId)));
                                VCExpr controlTransferExpr = gen.Eq(controlFlowFunctionAppl, gen.Integer(BigNum.FromInt(successor.UniqueId)));
                                s = gen.Implies(controlTransferExpr, s);
                            }
                            SuccCorrectVars.Add(s);
                        }
                    }
                    SuccCorrect = gen.NAry(VCExpressionGenerator.AndOp, SuccCorrectVars);
                }

                VCContext context = new VCContext(label2absy, proverCtxt, controlFlowVariableExpr, isPositiveContext);
                VCExpr vc = Wlp.P_Block(block, constantsAssumed, SuccCorrect, context);
                VCExprVar v = gen.Variable(block.Label + "_correct", Bpl.Type.Bool);

                VCExprLetBinding binding = gen.LetBinding(v, vc);
                bindings.Add(binding);
                blockVariables.Add(block, v);
            }

            var vcexpr = proverCtxt.ExprGen.Let(bindings, blockVariables[blocks[0]]);
            //Macro macro = new Macro(Token.NoToken, pathname, new List<Variable>(), new Formal(Token.NoToken, new TypedIdent(Token.NoToken, "", Bpl.Type.Bool), false));
            //prover.DefineMacro(macro, vcexpr);
            SetMacro(pathname, vcexpr);
            //return proverCtxt.ExprGen.Let(bindings, blockVariables[blocks[0]]);
            return vcexpr;
        }
        

        public void SetMacro(string name, VCExpr vcexpr)
        {
            Macro macro = new Macro(Token.NoToken, name, new List<Variable>(), new Formal(Token.NoToken, new TypedIdent(Token.NoToken, "", Bpl.Type.Bool), false));
            prover.DefineMacro(macro, vcexpr);
        }

        public VCExpr ComputeNAryExprEqulityRelation(VCExpr ve, Model model) {
            var gen = prover.VCExprGen;
            Model.Element val = getValue(ve, model);
            // m is of type Element.Model 
            if (val.Kind == Model.ElementKind.Boolean)
            {
                bool v = (val as Model.Boolean).Value;
                if (v)
                {
                    return gen.Eq(ve, VCExpressionGenerator.True);
                }
                else
                {
                    return gen.Eq(ve, VCExpressionGenerator.False);
                }
            }
            else if (val.Kind == Model.ElementKind.DataValue)
            {
                Model.DatatypeValue dv = (val as Model.DatatypeValue);
                Debug.Assert(dv != null);
                //Debug.Assert(dv.Arguments.Count() == 1);
                Model.Element arg = dv.Arguments[0];
                //Debug.Assert(arg.Kind == Model.ElementKind.Integer);
                if (arg.Kind == Model.ElementKind.Integer)
                {
                    if (dv.ConstructorName.Equals("-"))
                    {
                        VCExpr valExpr = gen.Integer(Microsoft.Basetypes.BigNum.FromInt(-1 * arg.AsInt()));
                        return gen.Eq(ve, valExpr);
                    }
                    else if (dv.ConstructorName.Equals("+"))
                    {
                        VCExpr valExpr = gen.Integer(Microsoft.Basetypes.BigNum.FromInt(arg.AsInt()));
                        return gen.Eq(ve, valExpr);
                    }
                    else
                    {
                        throw new MLHoudiniInternalError("Unexpected constructor name in the data value returned by the model\n");
                    }
                }
                else return null;
            }
            else
            {
                Debug.Assert(val.Kind == Model.ElementKind.Integer);
                VCExpr valExpr = gen.Integer(Microsoft.Basetypes.BigNum.FromInt(val.AsInt()));
                return gen.Eq(ve, valExpr);
            }
        
        }

        public List<VCExpr> P_ExtractExpr(string impl, Expr expr, Model model)
        {
            var gen = prover.VCExprGen;
            var funcsUsed = FunctionCollector.Collect(expr);
            var ret = new List<VCExpr>();

            foreach (var tup in funcsUsed.Where(t => t.Item2 == null))
            {
                var constant = tup.Item1;
                if (!constant2FuncCall.ContainsKey(constant.Name))
                    continue;

                NAryExpr func = constant2FuncCall[constant.Name];
                

                var VarCollector = new VariableCollector();
                VarCollector.VisitExpr(func);
                HashSet<Variable> vars = VarCollector.usedVars;
                foreach(Variable var in vars){
                    Expr ex = new IdentifierExpr(var.tok, var);
                    VCExpr varExpr =prover.Context.BoogieExprTranslator.Translate(ex);
                    ret.Add(ComputeNAryExprEqulityRelation(varExpr, model));
                }
                var funcName = (func.Fun as FunctionCall).FunctionName;

                //List<Expr> filter = new List<Expr>(func.Args.OfType<IdentifierExpr>());
                foreach (VCExpr ve in prover.Context.BoogieExprTranslator.Translate(func.Args))
                {
                    ret.Add(ComputeNAryExprEqulityRelation(ve, model));

                }
            }
            ret.RemoveAll(item => item == null);
            return ret;
        }

        public AssertCmd P_ExtractFailingAssert(Counterexample error)
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
            return failingAssert;
        }

        public IList<VCExpr> GetCounterexampleState(string impl, Counterexample ce, CounterExampleType type, IList<Block> blocks)
        {
            List<VCExpr> res = new List<VCExpr>();
            //add all asume non-invariant cmd variables to state
            //HashSet<Variable> footprint = new HashSet<Variable>();
            //IVariableDependenceAnalyser varDepAnalyser;
            //varDepAnalyser = new VariableDependenceAnalyser(this.program);
            //varDepAnalyser.Analyse();
            //HashSet<AssumeCmd> useableAssumeCmds = new HashSet<AssumeCmd>();
          

            //for (int i = 0; i < blocks.Count - 1; ++i){
            //    Block b = blocks[i];
            //    foreach (var cmd in b.Cmds.OfType<AssumeCmd>())
            //    {
            //        useableAssumeCmds.Add(cmd);
            //        ////if (QKeyValue.FindBoolAttribute(cmd.Attributes, "partition")) {
            //        var VarCollector = new VariableCollector();
            //        VarCollector.VisitExpr(cmd.Expr);
            //        footprint.UnionWith(VarCollector.usedVars.Where(Item => varDepAnalyser.VariableRelevantToAnalysis(Item, impl)));
            //        //}

            //    }
            //}
            // when there is a assert in a loop
            /*var lastBlock = blocks.Last();
            AssertCounterexample assertCounterexample = ce as AssertCounterexample;
            if (assertCounterexample != null)
            {
                foreach (var cmd in lastBlock.Cmds) {
                    if (cmd is AssertCmd && cmd == assertCounterexample.FailingAssert) break;
                    if (cmd is AssumeCmd) {
                        var assumeCmd = cmd as AssumeCmd;
                        useableAssumeCmds.Add(assumeCmd);
                        var VarCollector = new VariableCollector();
                        VarCollector.VisitExpr(assumeCmd.Expr);
                        footprint.UnionWith(VarCollector.usedVars.Where(Item => varDepAnalyser.VariableRelevantToAnalysis(Item, impl)));
                    }
                }
            }
            foreach (var v in footprint)
            {
                Expr ve = new IdentifierExpr(Token.NoToken, v);
                res.Add(ComputeNAryExprEqulityRelation(prover.Context.BoogieExprTranslator.Translate(ve), ce.Model));
            }
          */

            HashSet<AssumeCmd> useableAssumeCmds = new HashSet<AssumeCmd>();
            foreach (var b in blocks)
            {
                foreach (var cmd in b.Cmds.OfType<AssumeCmd>())
                {
                    useableAssumeCmds.Add(cmd);
                }
            }
            foreach (var cmd in ce.AssumedCmds.OfType<AssumeCmd>())
            {
                if (!useableAssumeCmds.Contains(cmd)) continue;
                res.AddRange(P_ExtractExpr(impl, cmd.Expr, ce.Model));
            }
            res.AddRange(P_ExtractExpr(impl, P_ExtractFailingAssert(ce).Expr, ce.Model));

            return res;

        }

        private void GenVC(Implementation impl)
        {
            ModelViewInfo mvInfo;
            Dictionary<int, Absy> label2absy;
            Dictionary<Block, VCExpr> block2Expr;
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
            fv.functionsUsed.Iter(tup => funcNameMap.Add(tup.Item2.Name, tup.Item1));

            HashSet<string> constantsAssumed = new HashSet<string>();
            fv.functionsUsed.Where(tup => impl2functionsAssumed[impl.Name].Contains(tup.Item1)).Iter(tup => constantsAssumed.Add(tup.Item2.Name));

            impl2constantsAssumed.Add(impl.Name, constantsAssumed);

            var gen = prover.VCExprGen;
            VCExpr controlFlowVariableExpr = CommandLineOptions.Clo.UseLabels ? null : gen.Integer(Microsoft.Basetypes.BigNum.ZERO);

            var vcexpr = vcgen.P_GenerateVC(impl, constantsAssumed, controlFlowVariableExpr, out label2absy, prover.Context);
            //var vcexpr = vcgen.GenerateVC(impl, controlFlowVariableExpr, out label2absy, prover.Context);
            //var vcexpr = vcgen.E_GenerateVC(impl, constantsAssumed, controlFlowVariableExpr, out label2absy, out block2Expr, prover.Context);
            
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

       
        //first version : just compute through the block's label
        private void Get3VCOfImpl(Implementation impl, Dictionary<Block, VCExpr> block2Expr, out List<VCExpr> results)
        {
            results = new List<VCExpr>();
            for (int i = 0; i < 3; i++ )
                results.Add(VCExpressionGenerator.True);
            //results[1] = VCExpressionGenerator.True;
            //results[2] = VCExpressionGenerator.True;
            List<Block> blocks = impl.Blocks;
            Graph<Block> dag = new Graph<Block>();
            dag.AddSource(blocks[0]);
            foreach (Block b in blocks)
            {
                GotoCmd gtc = b.TransferCmd as GotoCmd;
                if (gtc != null)
                {
                    Contract.Assume(gtc.labelTargets != null);
                    foreach (Block dest in gtc.labelTargets)
                    {
                        Contract.Assert(dest != null);
                        dag.AddEdge(dest, b);
                    }
                }
            }
            IEnumerable<Block> sortedNodes = dag.TopologicalSort();
            Contract.Assert(sortedNodes != null);
            int status = 0;
            foreach (Block b in sortedNodes)
            {
                Console.WriteLine(b.Label);
                if (b.Label.IndexOf("LoopBody") > 0) {
                    results[1] = prover.VCExprGen.And(results[1], block2Expr[b]);
                }
                else if (b.Label.IndexOf("LoopHead") > 0) {
                    results[1] = prover.VCExprGen.And(results[1], block2Expr[b]);
                    results[2] = prover.VCExprGen.And(results[2], block2Expr[b]);
                    status = 2;
                }
                else if (b.Label.IndexOf("LoopDone") > 0) {
                    results[2] = prover.VCExprGen.And(results[2], block2Expr[b]);
                    status = 1;
                }
                else if (0 == status) {
                    results[2] = prover.VCExprGen.And(results[2], block2Expr[b]);
                }
                else if (1 == status)
                {
                    results[1] = prover.VCExprGen.And(results[1], block2Expr[b]);
                }
                else {
                    Contract.Assert(status == 2);
                    results[0] = prover.VCExprGen.And(results[0], block2Expr[b]);
                }
            }

            //int status = 0;
            //foreach (Block b in blocks)
            //{
            //    if (b.Label.IndexOf("Entry") > 0) {
            //        results[0] = prover.VCExprGen.And(results[0], block2Expr[b]);
            //        continue;
            //    }
            //    GotoCmd gtc = b.TransferCmd as GotoCmd;
            //    if (gtc != null) {
            //        Contract.Assume(gtc.labelTargets != null);
            //        foreach (Block dest in gtc.labelTargets) {
            //            Contract.Assert(dest != null);

            //        }
            //    }
            //}


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
