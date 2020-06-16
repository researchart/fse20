//#define C5


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
using Microsoft.Basetypes;

namespace Microsoft.Boogie.Houdini {

    public static class ExtractLBool
    {
        public static bool getBool(this LBool lb)
        {
            Debug.Assert(lb != LBool.Undef);
            if (lb == LBool.True)
                return true;
            if (lb == LBool.False)
                return false;
            Debug.Assert(false);

            return false;
        }
    }

    public class Z3Context
    {
        public Context context;
        public Config config;
        public Sort intSort;
        public Sort boolSort;

        public Z3Context()
        {
            config = new Config();
            config.SetParamValue("MODEL", "true");
            config.SetParamValue("MODEL_V2", "true");
            config.SetParamValue("MODEL_COMPLETION", "true");
            config.SetParamValue("MBQI", "false");
            config.SetParamValue("TYPE_CHECK", "true");
            int timeout = 10000;    // timeout = 10 seconds
            config.SetParamValue("SOFT_TIMEOUT", timeout.ToString());
            
            context = new Context(config);
            intSort = context.MkIntSort();
            boolSort = context.MkBoolSort();                 
        }        
    }

    public class ICEHoudini
    {
        Dictionary<string, Function> existentialFunctions;
        Program program;
        Dictionary<string, Implementation> name2Impl;
        Dictionary<string, VCExpr> impl2VC;
        Dictionary<string, List<Tuple<string, Function, NAryExpr>>> impl2FuncCalls;
        // constant -> the naryexpr that it replaced
        Dictionary<string, NAryExpr> constant2FuncCall;

        // function -> its abstract value
        Dictionary<string, ICEDomain> function2Value;

        // impl -> functions assumed/asserted
        Dictionary<string, HashSet<string>> impl2functionsAsserted, impl2functionsAssumed;

        // funtions -> impls where assumed/asserted
        Dictionary<string, HashSet<string>> function2implAssumed, function2implAsserted;

        // impl -> handler, collector
        Dictionary<string, Tuple<ProverInterface.ErrorHandler, ICEHoudiniCounterexampleCollector>> impl2ErrorHandler;

        // Essentials: VCGen, Prover
        VCGen vcgen;
        ProverInterface prover;

        string filename;

        // Stats
        TimeSpan proverTime;
        int numProverQueries;
        TimeSpan z3LearnerTime;
        int numZ3LearnerQueries;

        int numPosExamples;
        int numNegCounterExamples;
        int numImplications;

        // Z3 context for implementing the SMT-based ICE learner.
        HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>> counterExamples;
        Z3Context z3Context;
        int constantRange;

#if C5
        // Data structures for storing and creating C5 sample
        List<Tuple<int, int>> C5implications;
        Dictionary<dataPoint, int> C5samplePointToClassAttr;
        Dictionary<dataPoint, int> C5samplePointToIndex;                
        string C5FunctionName;
        int C5index;
        int C5repeatedPoints;
#endif          

        // flags to track the outcome of validity of a VC
        bool VCisValid;
        bool realErrorEncountered;
        bool newSamplesAdded;   // tracks whether new ICE samples added in a round or not?

        public ICEHoudini(Program program, string defaultDomainName, string filename)
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
            this.impl2ErrorHandler = new Dictionary<string, Tuple<ProverInterface.ErrorHandler, ICEHoudiniCounterexampleCollector>>();
            this.constant2FuncCall = new Dictionary<string, NAryExpr>();

            // Find the existential functions
            foreach (var func in program.TopLevelDeclarations.OfType<Function>()
                .Where(f => QKeyValue.FindBoolAttribute(f.Attributes, "existential")))
                existentialFunctions.Add(func.Name, func);

            // extract the constants in the program to determine the range for the template domain elements
            var extractConstants = new ExtractConstants();
            extractConstants.Visit(program);
            constantRange = extractConstants.maxConst + 1;

            TemplateParser.DSInit();
            this.function2Value = new Dictionary<string, ICEDomain>();
            counterExamples = new HashSet<Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>>>();
            
            existentialFunctions.Keys.Iter(f => function2implAssumed.Add(f, new HashSet<string>()));
            existentialFunctions.Keys.Iter(f => function2implAsserted.Add(f, new HashSet<string>()));

            // type check
            existentialFunctions.Values.Iter(func =>
                {
                    if (func.OutParams.Count != 1 || !func.OutParams[0].TypedIdent.Type.IsBool)
                        throw new ICEHoudiniInternalError(string.Format("Existential function {0} must return bool", func.Name));
                    if(func.Body != null)
                        throw new ICEHoudiniInternalError(string.Format("Existential function {0} should not have a body", func.Name));
                    func.InParams.Iter(v =>
                    {
                        if (!v.TypedIdent.Type.IsInt)
                        {
                            throw new ICEHoudiniInternalError("TypeError: Illegal tpe, expecting int");
                        }
                    });     
                });

            //if (CommandLineOptions.Clo.ProverKillTime > 0)
            //    CommandLineOptions.Clo.ProverOptions.Add(string.Format("TIME_LIMIT={0}", CommandLineOptions.Clo.ProverKillTime));

            Inline();

            this.vcgen = new VCGen(program, CommandLineOptions.Clo.SimplifyLogFilePath, CommandLineOptions.Clo.SimplifyLogFileAppend, new List<Checker>());
            this.prover = ProverInterface.CreateProver(program, CommandLineOptions.Clo.SimplifyLogFilePath, CommandLineOptions.Clo.SimplifyLogFileAppend, CommandLineOptions.Clo.ProverKillTime);

            this.proverTime = TimeSpan.Zero;
            this.numProverQueries = 0;
            this.z3LearnerTime = TimeSpan.Zero;
            this.numZ3LearnerQueries = 0;

            this.numPosExamples = 0;
            this.numNegCounterExamples = 0;
            this.numImplications = 0;

#if C5
            this.C5index = 0;
            this.C5implications = new List<Tuple<int, int>>();
            this.C5samplePointToClassAttr = new Dictionary<dataPoint, int>();
            this.C5samplePointToIndex = new Dictionary<dataPoint, int>();
            this.C5repeatedPoints = 0;
#endif 
            this.filename = filename;

            var impls = program.TopLevelDeclarations.OfType<Implementation>().Where(
                    impl => impl != null && CommandLineOptions.Clo.UserWantsToCheckRoutine(cce.NonNull(impl.Name)) && !impl.SkipVerification);

            /*
            program.TopLevelDeclarations.OfType<Implementation>()
                .Where(impl => !impl.SkipVerification)
                .Iter(impl => name2Impl.Add(impl.Name, impl));
            */

            impls.Iter(impl => name2Impl.Add(impl.Name, impl));

            // Let's do VC Gen (and also build dependencies)
            name2Impl.Values.Iter(GenVC);          
        }

        enum ICEOutcome
        {
            Timeout,
            ErrorFound,
            InvariantFound,
            InvariantNotFound
        };

        private ICEOutcome LearnInvFromTemplate(Dictionary<string, int> impl2Priority, Template t, int range, out VCGenOutcome overallOutcome)
        {
            overallOutcome = null;            

            // create a new z3 context
            if (z3Context != null)
            {
                z3Context.context.Dispose();
                z3Context.config.Dispose();
            }
            z3Context = new Z3Context();

            foreach (var func in existentialFunctions.Values)
            {
                // initialize function to an "Octagons" instance with the given template "t".
                function2Value[func.Name] = ICEDomainFactory.GetInstance("Octagons", t, ref z3Context, func.Name, range);
            }

            // add counterexamples into the z3Context. These are obtained from the earlier iterations of the template.
            foreach (var cex in counterExamples)
            {
                AddCounterExampleToZ3Context(cex);
            }

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
                
                #region bound_value_of_cexs
#if false
                finalVC = vc;

#else               
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
#endif                
                #endregion bound_value_of_cexs
                

                var handler = impl2ErrorHandler[impl].Item1;
                var collector = impl2ErrorHandler[impl].Item2;
                collector.Reset(impl);
                VCisValid = true;   // set to false if control reaches HandleCounterExample
                realErrorEncountered = false;
                newSamplesAdded = false;

                var start = DateTime.Now;

                prover.Push();
                prover.Assert(gen.Not(finalVC), true);
                prover.FlushAxiomsToTheoremProver();
                prover.Check();
                ProverInterface.Outcome proverOutcome = prover.CheckOutcomeCore(handler);

                //prover.BeginCheck(impl, vc, handler);
                //ProverInterface.Outcome proverOutcome = prover.CheckOutcomeCore(handler);

                var inc = (DateTime.Now - start);
                proverTime += inc;
                numProverQueries++;

                if (CommandLineOptions.Clo.Trace)
                    Console.WriteLine("Prover Time taken = " + inc.TotalSeconds.ToString());

                if (proverOutcome == ProverInterface.Outcome.TimeOut || proverOutcome == ProverInterface.Outcome.OutOfMemory)
                {
                    Console.WriteLine("Z3 Prover for implementation {0} times out or runs out of memory !", impl);
                    z3Context.context.Dispose();
                    z3Context.config.Dispose();
                    
                    overallOutcome = new VCGenOutcome(proverOutcome, new List<Counterexample>());
                    return ICEOutcome.Timeout;
                }

                if (CommandLineOptions.Clo.Trace)
                    Console.WriteLine(!VCisValid ? "SAT" : "UNSAT");

                if (!VCisValid)
                {
                    if (realErrorEncountered)
                    {
                        overallOutcome = new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.real_errors);
                        return ICEOutcome.ErrorFound;
                    }

                    Debug.Assert(newSamplesAdded);
                    HashSet<string> funcsChanged;
                    if (!learn(out funcsChanged))
                    {
                        // learner timed out or there is no valid conjecture in the current given template
                        overallOutcome = new VCGenOutcome(ProverInterface.Outcome.Invalid, collector.conjecture_errors);
                        prover.Pop();
                        return ICEOutcome.InvariantNotFound;                       
                    }
                    // propagate dependent guys back into the worklist, including self
                    var deps = new HashSet<string>();
                    deps.Add(impl);
                    funcsChanged.Iter(f => deps.UnionWith(function2implAssumed[f]));
                    funcsChanged.Iter(f => deps.UnionWith(function2implAsserted[f]));

                    deps.Iter(s => worklist.Add(Tuple.Create(impl2Priority[s], s)));
                }

                prover.Pop();
            }
            // The program was verified with the current template!
            overallOutcome = new VCGenOutcome(ProverInterface.Outcome.Valid, new List<Counterexample>());
            return ICEOutcome.InvariantFound;          
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
                    
            string[] templates = {"(1)", "(1;1)", "(2)", "((1;1);1)", "((1;1),1)", "(1;2)", "(3)", "(1;3)", "(4)", "(5;2)"};

            if (CommandLineOptions.Clo.Trace)
            {
                Console.WriteLine("Max integral value in the program: " + constantRange);
            }

            for (int i = 0; i < templates.Count(); i++)
            {
                var template = templates[i];
                TemplateParser.initialize(template);
                Template t = TemplateParser.Parse();

                List<int> cvalues = new List<int>();
                cvalues.Add(2);
                int maxRange = constantRange > i ? constantRange : i;
                if (maxRange > 2)
                    cvalues.Add(maxRange);

                foreach (var cvalue in cvalues)
                {
                    if (CommandLineOptions.Clo.Trace)
                    {
                        Console.WriteLine("Inferring Invariants in the template Octagons" + template + " with constantRange = " + cvalue);
                    }

                    ICEOutcome result = LearnInvFromTemplate(impl2Priority, t, cvalue, out overallOutcome);

                    // The program was verified with the current template!
                    if (result == ICEOutcome.InvariantFound)
                    {
                        if (CommandLineOptions.Clo.Trace)
                        {
                            Console.WriteLine("Inferred Invariants in the template Octagons" + template + " with constantRange = " + cvalue);
                        }
                        if (cvalue <= 2)
                            goto exit;

                        int min = 2;
                        int max = cvalue;
                        int mid = (min + max) / 2;
                        while (min <= max)
                        {
                            VCGenOutcome overallOutcomePrime = null;

                            if (CommandLineOptions.Clo.Trace)
                            {
                                Console.WriteLine("Inferring Invariants in the template Octagons" + template + " with constantRange = " + mid);
                            }
                            ICEOutcome resultPrime = LearnInvFromTemplate(impl2Priority, t, mid, out overallOutcomePrime);
                            if (resultPrime == ICEOutcome.InvariantFound)
                            {
                                max = mid - 1;
                                mid = (max + min) / 2;
                                if (CommandLineOptions.Clo.Trace)
                                {
                                    Console.WriteLine("Inferred Invariants in the template Octagons" + template + " with constantRange = " + mid);
                                }
                            }
                            else if (resultPrime == ICEOutcome.InvariantNotFound)
                            {
                                min = mid + 1;
                                mid = (min + max) / 2;
                            }
                            else if (resultPrime == ICEOutcome.ErrorFound)
                            {
                                throw new AbsHoudiniInternalError("Contrary results: Invariant found for constants < " + cvalue + "; error found for constants <" + mid);
                            }
                            else if (resultPrime == ICEOutcome.Timeout)
                            {
                                break;
                            }
                        }
                        // last iteration did not work. So try min again.
                        if (min != mid)
                        {
                            ICEOutcome resultPrime = LearnInvFromTemplate(impl2Priority, t, min, out overallOutcome);
                            Debug.Assert(resultPrime == ICEOutcome.InvariantFound);
                        }
                        goto exit;
                    }
                    else if (result == ICEOutcome.ErrorFound)
                        goto exit;

                    else if (result == ICEOutcome.Timeout)
                        return overallOutcome;

                    Debug.Assert(result == ICEOutcome.InvariantNotFound);

                } // end of loop over template constants

            } // end of loop over boolean (structure of the) templates

            exit:

            z3Context.context.Dispose();
            z3Context.config.Dispose();

            if (true)
            {
                Console.WriteLine("Prover time = {0}", proverTime.TotalSeconds.ToString("F2"));
                Console.WriteLine("Number of prover queries = " + numProverQueries);
                Console.WriteLine("Z3 Learner time = {0}", z3LearnerTime.TotalSeconds.ToString("F2"));
                Console.WriteLine("Number of Z3 Learner queries = " + numZ3LearnerQueries);

                Console.WriteLine("Total time: {0}", proverTime.Add(z3LearnerTime).TotalSeconds.ToString("F2"));

                Console.WriteLine("Number of examples:" + this.numPosExamples);
                Console.WriteLine("Number of counter-examples:" + this.numNegCounterExamples);
                Console.WriteLine("Number of implications:" + this.numImplications);
                Console.WriteLine("Total size of sample: " + (int)(this.numPosExamples + this.numNegCounterExamples + 2 * this.numImplications));
#if C5
                Console.WriteLine("Total points repeated in the sample: " + this.C5repeatedPoints);
#endif
                //Console.WriteLine("Range of constants in the template = " + constantRange);
            }

            if (CommandLineOptions.Clo.PrintAssignment)
            {
                // Print the answer
                existentialFunctions.Values.Iter(PrintFunction);
            }

#if C5
            generateC5Files();
#endif

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

        private void PrintFunction(Function function)
        {
            var tt = new TokenTextWriter(Console.Out);
            var invars = new List<Expr>(function.InParams.OfType<Variable>().Select(v => Expr.Ident(v)));
            function.Body = function2Value[function.Name].Gamma(invars);
            function.Emit(tt, 0);
            tt.Close();
        }

        public string ParseListOfModel(List<Model.Element> ml)
        {
            string ret = "";
            foreach (var m in ml)
            {
                int mval = m.AsInt();
                ret += mval.ToString() + ",";
            }
            return ret;
        }

        public string ParseListOfModel(List<int> ml)
        {
            string ret = "";
            foreach (var m in ml)
            {                
                ret += m.ToString() + ",";
            }
            return ret;
        }

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

#if C5        
        class dataPoint
        {
            public List<int> value;
            public dataPoint(List<Model.Element> lm)
            {
                List<int> ret = new List<int>();
                foreach (var m in lm)
                {
                    ret.Add(m.AsInt());
                }
                value = ret;
            }
            public override int GetHashCode()
            {
                if (this.value != null)
                    return this.value.Count;
                else return 0;
            }

            public override bool Equals(object obj)
            {
                dataPoint other = obj as dataPoint;
                if (other == null)
                    return false;
                return this.value.SequenceEqual(other.value);
            }
        }


        List<int> ModelToInt(List<Model.Element> lm)
        {
            List<int> ret = new List<int>();
            foreach (var m in lm)
            {
                ret.Add(m.AsInt());
            }
            return ret;
        }

        public void RecordCexForC5(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            if (lhs.Count == 0)
            {
                Debug.Assert(rhs.Count == 1);
                if (C5index == 0)
                {
                    C5FunctionName = rhs.ElementAt(0).Item1;
                }
                else
                {
                    Debug.Assert(C5FunctionName == rhs.ElementAt(0).Item1);
                }

                dataPoint argsval = new dataPoint(rhs.ElementAt(0).Item2);
                if (C5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(C5samplePointToClassAttr[argsval] != 2); // should be unknown
                    C5samplePointToClassAttr[argsval] = 1;
                    C5repeatedPoints++;
                }
                else
                {
                    C5samplePointToIndex[argsval] = C5index;
                    C5index++;
                    C5samplePointToClassAttr[argsval] = 1;
                }
            }
            else if (rhs.Count == 0)
            {
                Debug.Assert(lhs.Count == 1);
                if (C5index == 0)
                {
                    C5FunctionName = lhs.ElementAt(0).Item1;
                }
                else
                {
                    Debug.Assert(C5FunctionName == lhs.ElementAt(0).Item1);
                }

                dataPoint argsval = new dataPoint(lhs.ElementAt(0).Item2);                
                if (C5samplePointToIndex.ContainsKey(argsval))
                {
                    Debug.Assert(C5samplePointToClassAttr[argsval] != 1); // should be unknown
                    C5samplePointToClassAttr[argsval] = 2;
                    C5repeatedPoints++;
                }
                else
                {
                    C5samplePointToIndex[argsval] = C5index;
                    C5index++;
                    C5samplePointToClassAttr[argsval] = 2;
                }
            }
            else
            {
                Debug.Assert(lhs.Count == 1);
                Debug.Assert(rhs.Count == 1);
                if (C5index == 0)
                {
                    C5FunctionName = rhs.ElementAt(0).Item1;
                }
                else
                {
                    Debug.Assert(C5FunctionName == rhs.ElementAt(0).Item1);
                }
                int antecedent, consequent;

                dataPoint argsval1 = new dataPoint(lhs.ElementAt(0).Item2);
                dataPoint argsval2 = new dataPoint(rhs.ElementAt(0).Item2);                
                
                if (C5samplePointToIndex.ContainsKey(argsval1))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval1] == 0); // is unknown
                    antecedent = C5samplePointToIndex[argsval1];
                    C5repeatedPoints++;
                }
                else
                {
                    C5samplePointToIndex[argsval1] = C5index;
                    antecedent = C5index;
                    C5index++;
                    C5samplePointToClassAttr[argsval1] = 0;
                }
                if (C5samplePointToIndex.ContainsKey(argsval2))
                {
                    //Debug.Assert(C5samplePointToClassAttr[argsval2] == 0); // is unknown
                    consequent = C5samplePointToIndex[argsval2];
                    C5repeatedPoints++;
                }
                else
                {
                    C5samplePointToIndex[argsval2] = C5index;
                    consequent = C5index;
                    C5index++;
                    C5samplePointToClassAttr[argsval2] = 0;
                }
                Tuple<int, int> t = new Tuple<int, int>(antecedent, consequent);
                C5implications.Add(t);
            }
        }

        public void generateC5Files()
        {
            string dataFile = "";
            string namesFile = "";
            string implicationsFile = "";

            foreach (var model in C5samplePointToClassAttr.Keys)
            {
                dataFile += ParseListOfModel(model.value);
                switch (C5samplePointToClassAttr[model])
                {
                    case 0: dataFile += "?\n"; break;
                    case 1: dataFile += "true\n"; break;
                    case 2: dataFile += "false\n"; break;

                    default: Debug.Assert(false); break;
                }
            }

            foreach (var implication in C5implications)
            {
                implicationsFile += implication.Item1;
                implicationsFile += " ";
                implicationsFile += implication.Item2;
                implicationsFile += "\n";
            }

            namesFile += "invariant.\n";
            Debug.Assert(existentialFunctions.ContainsKey(C5FunctionName));
            List<Variable> args = existentialFunctions[C5FunctionName].InParams;
            foreach(var variable in args)
            {
                namesFile += variable.Name + ": continuous.\n";
            }
            namesFile += "invariant: true, false.\n";
            
            for (int i = 0; i < args.Count; i++ )
            {
                for (int j = i+1; j < args.Count; j++)
                {                    
                    Variable var1 = args.ElementAt(i);
                    Variable var2 = args.ElementAt(j);
                    namesFile += "+ " + var1.Name + " " + var2.Name + ":= " + var1.Name + " + " + var2.Name + ".\n";
                    namesFile += "- " + var1.Name + " " + var2.Name + ":= " + var1.Name + " - " + var2.Name + ".\n";                    
                }
            }
            
                // Create a file to write to. 
                using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".data"))
                {
                    sw.WriteLine(dataFile);
                }
                using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".names"))
                {
                    sw.WriteLine(namesFile);
                }
                using (System.IO.StreamWriter sw = System.IO.File.CreateText(filename + ".implications"))
                {
                    sw.WriteLine(implicationsFile);
                }
           
            return;
        }

#endif

        public void AddCounterExample(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            counterExamples.Add(cex);
#if true
            if (lhs.Count > 0 && rhs.Count > 0)
                this.numImplications++;
            else if (lhs.Count > 0)
                this.numNegCounterExamples++;
            else this.numPosExamples++;
#endif

#if false
            RecordCounterExamples2File(cex);
#endif

#if C5
            RecordCexForC5(cex);
#endif
        }

        public void AddCounterExampleToZ3Context(Tuple<List<Tuple<string, List<Model.Element>>>, List<Tuple<string, List<Model.Element>>>> cex)
        {
            List<Tuple<string, List<Model.Element>>> lhs = cex.Item1;
            List<Tuple<string, List<Model.Element>>> rhs = cex.Item2;

            Term lhs_constr, rhs_constr;

            if (lhs.Count > 0)
            {
                List<Term> args = new List<Term>();
                foreach (var tup in lhs)
                {
                    args.Add(function2Value[tup.Item1].constructSMTConstraint(tup.Item2, ref z3Context));
                }
                lhs_constr = z3Context.context.MkAnd(args.ToArray());
            }
            else
            {
                lhs_constr = z3Context.context.MkTrue();
            }

            if (rhs.Count > 0)
            {
                Debug.Assert(rhs.Count == 1);
                List<Term> args = new List<Term>();
                foreach (var tup in rhs)
                {
                    args.Add(function2Value[tup.Item1].constructSMTConstraint(tup.Item2, ref z3Context));
                }
                rhs_constr = z3Context.context.MkAnd(args.ToArray());
            }
            else
            {
                rhs_constr = z3Context.context.MkFalse();
            }

            z3Context.context.AssertCnstr(z3Context.context.MkImplies(lhs_constr, rhs_constr));
        }

        /*
        public void AddNewInvConstraintToZ3Context()
        {
            List<Term> args = new List<Term>();
            foreach(var funcName in function2Value.Keys)
            {
                args.Add(function2Value[funcName].currLearnedInvAsTerm(ref z3Context));
            }

            Context context = z3Context.context;
            context.AssertCnstr(context.MkNot(context.MkAnd(args.ToArray())));
        }*/


        public bool HandleCounterExample(string impl, Counterexample error)
        {
            // return true if a true error encountered.
            // return false if the error is due to a wrong choice of current conjecture.

            VCisValid = false;
            var cex = P_ExtractState(impl, error);

            // the counter-example does not involve any existential function ==> Is a real counter-example !
            if (cex.Item1.Count == 0 && cex.Item2.Count == 0)
            {
                realErrorEncountered = true;
                return true;
            }

            AddCounterExample(cex);
            AddCounterExampleToZ3Context(cex);
            /*
            AddNewInvConstraintToZ3Context();
            */ 
            newSamplesAdded = true;          
            return false;
        }

        public bool learn(out HashSet<string> funcsChanged)
        {            
            Microsoft.Z3.Model m;

            var start = DateTime.Now;

            LBool result = z3Context.context.CheckAndGetModel(out m);

            var inc = (DateTime.Now - start);
            z3LearnerTime += inc;
            numZ3LearnerQueries++;

            if (CommandLineOptions.Clo.Trace)
            {
                Console.WriteLine("Learner (Z3) Time taken = " + inc.TotalSeconds.ToString());
                Console.WriteLine("Size of the sample = " + counterExamples.Count());
            }

            funcsChanged = new HashSet<string>();
            if (result == LBool.True)
            {
                Debug.Assert(m != null);
                // extract the value for the existential functions from the model.
                foreach (var functionName in function2Value.Keys)
                {
                    if(function2Value[functionName].initializeFromModel(m, ref z3Context))
                        funcsChanged.Add(functionName);
                }
                m.Dispose();
                return true;
                //Debug.Assert(funcsChanged.Count > 0);
            }

            if (result == LBool.False)
            {
                // Unsat or no values exist for the existential functions
                Debug.Assert(m == null);
                if (CommandLineOptions.Clo.Trace)
                {
                    Console.WriteLine("No valid conjecture exists in the given concept class !");
                }
                return false;
            }

            if (result == LBool.Undef)
            {
                Debug.Assert(m == null);
                Console.WriteLine("SMT based learner times out or runs out of memory !");
                return false;
            }
            return false;
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
            return ret;
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

                var reporter = new ICEHoudiniErrorReporter();
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

        class ICEHoudiniCounterexampleCollector : VerifierCallback
        {
            /*public HashSet<string> funcsChanged;            
            public int numErrors;
             */
            public string currImpl;
            public List<Counterexample> real_errors;
            public List<Counterexample> conjecture_errors;

            ICEHoudini container;

            public ICEHoudiniCounterexampleCollector(ICEHoudini container)
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
            }

            public override void OnCounterexample(Counterexample ce, string reason)
            {
                //numErrors++;
                if (container.HandleCounterExample(currImpl, ce))
                {
                    real_errors.Add(ce);
                }
                else
                {
                    conjecture_errors.Add(ce);
                }
                //funcsChanged.UnionWith(
                //    container.HandleCounterExample(currImpl, ce));
            }
        }

        private void GenVC(Implementation impl)
        {
            ModelViewInfo mvInfo;
            Dictionary<int, Absy> label2absy;
            var collector = new ICEHoudiniCounterexampleCollector(this);
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

    class ExtractConstants : StandardVisitor
    {
        public int maxConst;

        public ExtractConstants()
        {
            maxConst = 0;
        }

        public override LiteralExpr VisitLiteralExpr(LiteralExpr node)
        {
            if (node.Type == Type.Int)
            {
                int value = ((BigNum)(node.Val)).ToIntSafe;
                value = Math.Abs(value);
                if (value > maxConst)
                    maxConst = value;
            }

            return base.VisitLiteralExpr(node);
        }

    }

    public interface ICEDomain
    {
        Term constructSMTConstraint(List<Model.Element> states, ref Z3Context z3Context);
        bool initializeFromModel(Z3.Model model, ref Z3Context z3Context);  // returns whether the abstract value has changed?
        Expr Gamma(List<Expr> vars);
        bool TypeCheck(List<Type> argTypes, out string msg);
        /*
        Term currLearnedInvAsTerm(ref Z3Context z3Context);
        */
    }   

    public class ICEIntervals : ICEDomain
    {
        int upperLimit;     // \in [-10,10]
        int lowerLimit;     // \in [-10,10]
        bool hasUpperLimit; // if true only then x <= upperLimit
        bool hasLowerLimit; // if true only then x >= lowerLimit
        //int sampleID;       // incremented with every sample added to the z3Context
        string str;

        public ICEIntervals(ref Z3Context z3Context, string str, int constantRange)
        {
            // Initialize the invariant function with "true".
            this.upperLimit = 0;
            this.lowerLimit = 0;
            this.hasUpperLimit = false;
            this.hasLowerLimit = false;
            //this.sampleID = 0;
            this.str = str;

            // enter the variables in the z3Context
            Context context = z3Context.context;

            Term termUpperLimit = context.MkConst(this.str + "_ul", z3Context.intSort);
            Term termLowerLimit = context.MkConst(this.str + "_ll", z3Context.intSort);
            Term termHasUpperLimit = context.MkConst(this.str + "_hul", z3Context.boolSort);
            Term termHasLowerLimit = context.MkConst(this.str + "_hll", z3Context.boolSort);

            // assert -constantRange <= lowerLimit <= upperLimit <= constantRange
            context.AssertCnstr(context.MkLe(context.MkNumeral(-1*constantRange, z3Context.intSort), termLowerLimit));
            context.AssertCnstr(context.MkLe(termLowerLimit, termUpperLimit));
            context.AssertCnstr(context.MkLe(termUpperLimit, context.MkNumeral(constantRange, z3Context.intSort)));
        }

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

        public Expr Gamma(List<Expr> vars)
        {
            Debug.Assert(vars.Count == 1);
            var v = vars[0];
            Expr ret = Expr.True;
            if (hasLowerLimit)
            {
                ret = Expr.And(ret, Expr.Le(Expr.Literal(lowerLimit), v));
            }
            if (hasUpperLimit)
            {
                ret = Expr.And(ret, Expr.Le(v, Expr.Literal(upperLimit)));
            }
            return ret;
        }

        public bool TypeCheck(List<Type> argTypes, out string msg)
        {
            msg = "";
            if (argTypes.Count != 1)
            {
                msg = "Illegal number of arguments";
                return false;
            }
            if (!argTypes[0].IsInt)
            {
                msg = "Illegal type, expecting int";
                return false;
            }
            return true;
        }

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

    public class ICEOctagons : ICEDomain
    {
        // s1 v1 + s2 v2 {=,<=} c
        bool numVarsInitialized;
        //bool hasPredicate;  // false means predicate is "True"
        bool hasFirst;      // guard for the first term s1.v1
        bool hasSecond;     // guard for the second term s2.v2
        bool sign1;         // {+1, -1}
        bool sign2;         // {+1, -1}
        int var1;
        int var2;
        int numVars;
        bool op;            // true is ==, false is <=
        int constant;       // \in [-10, 10]
        
        string str;

        public ICEOctagons(ref Z3Context z3Context, string str, int constantRange)
        {
            // Initialize the invariant function with "true".
            this.hasFirst = false;
            this.hasSecond = false;
            this.sign1 = false;
            this.sign2 = false;
            this.var1 = 0;
            this.var2 = 0;
            this.numVars = 0;
            this.numVarsInitialized = false;    // will be initialized after the first counter-example is processed.            
            this.op = true;
            this.constant = 0;
            this.str = str;

            // enter the variables in the z3Context
            Context context = z3Context.context;

            Term termHasFirst = context.MkConst(this.str + "_hf", z3Context.boolSort);
            Term termHasSecond = context.MkConst(this.str + "_hs", z3Context.boolSort);
            Term termSign1 = context.MkConst(this.str + "_s1", z3Context.boolSort);
            Term termSign2 = context.MkConst(this.str + "_s2", z3Context.boolSort);
            Term termVar1 = context.MkConst(this.str + "_v1", z3Context.intSort);
            Term termVar2 = context.MkConst(this.str + "_v2", z3Context.intSort);
            Term termOp = context.MkConst(this.str + "_op", z3Context.boolSort);
            Term termConstant = context.MkConst(this.str + "_c", z3Context.intSort);

            // assert -constantRange <= constant <= constantRange
            context.AssertCnstr(context.MkLe(context.MkNumeral(-1*constantRange, z3Context.intSort), termConstant));            
            context.AssertCnstr(context.MkLe(termConstant, context.MkNumeral(constantRange, z3Context.intSort)));
            // assert hasSecond => hasFirst
            context.AssertCnstr(context.MkImplies(termHasSecond, termHasFirst));
            // assert 0 <= var1, var2 <= numVars-1 when the first counter-example is processed.
        }

        public Term constructSMTConstraint(List<Model.Element> states, ref Z3Context z3Context)
        {
            Context context = z3Context.context;
            Term termHasFirst = context.MkConst(this.str + "_hf", z3Context.boolSort);
            Term termHasSecond = context.MkConst(this.str + "_hs", z3Context.boolSort);
            Term termSign1 = context.MkConst(this.str + "_s1", z3Context.boolSort);
            Term termSign2 = context.MkConst(this.str + "_s2", z3Context.boolSort);
            Term termVar1 = context.MkConst(this.str + "_v1", z3Context.intSort);
            Term termVar2 = context.MkConst(this.str + "_v2", z3Context.intSort);
            Term termOp = context.MkConst(this.str + "_op", z3Context.boolSort);
            Term termConstant = context.MkConst(this.str + "_c", z3Context.intSort);
            
            if(!this.numVarsInitialized)
            {
                this.numVars = states.Count;
                this.numVarsInitialized = true;
                // assert 0 <= var1, var2 <= numVars-1
                context.AssertCnstr(context.MkLe(context.MkNumeral(0, z3Context.intSort), termVar1));     
                context.AssertCnstr(context.MkLe(termVar1, context.MkNumeral(this.numVars-1, z3Context.intSort)));
                context.AssertCnstr(context.MkLe(context.MkNumeral(0, z3Context.intSort), termVar2));     
                context.AssertCnstr(context.MkLe(termVar2, context.MkNumeral(this.numVars-1, z3Context.intSort)));                

                if(this.numVars > 1)
                {
                    context.AssertCnstr(context.MkNot(context.MkEq(termVar1, termVar2)));
                }
                else
                {
                    Debug.Assert(this.numVars == 1);
                    context.AssertCnstr(context.MkNot(termHasSecond));
                }
            }
            else
            {
                Debug.Assert(states.Count == this.numVars);
            }
            
            Term firstVal = context.MkNumeral(0, z3Context.intSort);            
            for(int i = this.numVars-1; i >= 0; i--)
            {
                var state = states[i] as Model.Integer;
                if (state == null)
                    throw new ICEHoudiniInternalError("Incorrect type, expected int");
                var intval = state.AsInt();

                firstVal = context.MkIte(context.MkEq(termVar1, context.MkNumeral(i, z3Context.intSort)), context.MkNumeral(intval, z3Context.intSort), firstVal);                
            }
            firstVal = context.MkIte(termSign1, firstVal, context.MkUnaryMinus(firstVal));
            firstVal = context.MkIte(termHasFirst, firstVal, context.MkNumeral(0, z3Context.intSort));

            Term secondVal = context.MkNumeral(0, z3Context.intSort);
            if(this.numVars > 1) {                
                for(int i = this.numVars-1; i >= 0; i--)
                {
                    var state = states[i] as Model.Integer;
                    if (state == null)
                        throw new ICEHoudiniInternalError("Incorrect type, expected int");
                    var intval = state.AsInt();

                    secondVal = context.MkIte(context.MkEq(termVar2, context.MkNumeral(i, z3Context.intSort)), context.MkNumeral(intval, z3Context.intSort), secondVal);                
                }
                secondVal = context.MkIte(termSign2, secondVal, context.MkUnaryMinus(secondVal));
                secondVal = context.MkIte(termHasSecond, secondVal, context.MkNumeral(0, z3Context.intSort));            
            }
            // else hasSecond = false and secondVal = 0 in this case already

            Term lhs = context.MkAdd(firstVal, secondVal);
            return context.MkIte(termOp, context.MkEq(lhs, termConstant), context.MkLe(lhs, termConstant));
        }

        public bool initializeFromModel(Z3.Model model, ref Z3Context z3Context)
        {
            Debug.Assert(model != null);
            Context context = z3Context.context;
            Term termHasFirst = context.MkConst(this.str + "_hf", z3Context.boolSort);
            Term termHasSecond = context.MkConst(this.str + "_hs", z3Context.boolSort);
            Term termSign1 = context.MkConst(this.str + "_s1", z3Context.boolSort);
            Term termSign2 = context.MkConst(this.str + "_s2", z3Context.boolSort);
            Term termVar1 = context.MkConst(this.str + "_v1", z3Context.intSort);
            Term termVar2 = context.MkConst(this.str + "_v2", z3Context.intSort);
            Term termOp = context.MkConst(this.str + "_op", z3Context.boolSort);
            Term termConstant = context.MkConst(this.str + "_c", z3Context.intSort);

            bool ret = false;

            bool hf = context.GetBoolValue(model.Eval(termHasFirst)).getBool();
            bool hs = context.GetBoolValue(model.Eval(termHasSecond)).getBool();
            bool s1 = context.GetBoolValue(model.Eval(termSign1)).getBool();
            bool s2 = context.GetBoolValue(model.Eval(termSign2)).getBool();
            int v1 = context.GetNumeralInt(model.Eval(termVar1));
            int v2 = context.GetNumeralInt(model.Eval(termVar2));
            bool op = context.GetBoolValue(model.Eval(termOp)).getBool();
            int c = context.GetNumeralInt(model.Eval(termConstant));

            if (this.hasFirst != hf)
            {
                ret = true;
                goto init;
            }
            if (!this.hasFirst && !hf)
            {
                bool oldVal = this.op ? 0 == this.constant : 0 <= this.constant;
                bool newVal = op ? 0 == c : 0 <= c;
                if (oldVal != newVal)
                {
                    ret = true;                    
                }
                goto init;
            }
            // hf && this.hasFirst
            if (this.sign1 != s1 || this.var1 != v1)
            {
                ret = true;
                goto init;
            }
            if (this.hasSecond != hs)
            {
                ret = true;
                goto init;
            }
            if (this.hasSecond && hs)
            {
                if (this.sign2 != s2 || this.var2 != v2)
                {
                    ret = true;
                    goto init;
                }
            }
            if (this.op != op || this.constant != c)
            {
                ret = true;
                goto init;
            }

        init:
            this.hasFirst = hf;
            this.hasSecond = hs;
            this.sign1 = s1;
            this.sign2 = s2;
            this.var1 = v1;
            this.var2 = v2;
            this.op = op;
            this.constant = c;

            return ret;
        }

        public Expr Gamma(List<Expr> vars)
        {
            if (!this.numVarsInitialized)
                return Expr.True;

            if (this.numVars != vars.Count)
                throw new ICEHoudiniInternalError(
                    string.Format("Got illegal number of arguments ({0}), expected {1}", vars.Count, numVars));

            if (!this.hasFirst && !this.hasSecond)
            {
                bool value = this.op ? 0 == this.constant : 0 <= this.constant;
                return value ? Expr.True : Expr.False;
            }

            Expr ret, lhs, firstVal, secondVal;
            var v1 = vars[this.var1];
            firstVal = this.sign1 ? v1 : Expr.Unary(new Token(0, 0), UnaryOperator.Opcode.Neg, v1);
            if (this.hasSecond)
            {
                var v2 = vars[this.var2];
                secondVal = this.sign2 ? v2 : Expr.Unary(new Token(0, 0), UnaryOperator.Opcode.Neg, v2);
                lhs = Expr.Add(firstVal, secondVal);
            }
            else
            {
                lhs = firstVal;
            }
            if (this.op)
            {
                ret = Expr.Eq(lhs, Expr.Literal(this.constant));
            }
            else
            {
                ret = Expr.Le(lhs, Expr.Literal(this.constant));
            }
            return ret;
        }
                       
        public bool TypeCheck(List<Type> argTypes, out string msg)
        {
            msg = "";
            if (this.numVarsInitialized && argTypes.Count != this.numVars)
            {
                msg = "Illegal number of arguments";
                return false;
            }
            foreach (var t in argTypes)
            {
                if (!t.IsInt)
                {
                    msg = "Illegal type, expecting int";
                    return false;
                }
            }
            return true;
        }

        /*
        public Term currLearnedInvAsTerm(ref Z3Context z3Context)
        {
            Context context = z3Context.context;
            Term termHasFirst = context.MkConst(this.str + "_hf", z3Context.boolSort);
            Term termHasSecond = context.MkConst(this.str + "_hs", z3Context.boolSort);
            Term termSign1 = context.MkConst(this.str + "_s1", z3Context.boolSort);
            Term termSign2 = context.MkConst(this.str + "_s2", z3Context.boolSort);
            Term termVar1 = context.MkConst(this.str + "_v1", z3Context.intSort);
            Term termVar2 = context.MkConst(this.str + "_v2", z3Context.intSort);
            Term termOp = context.MkConst(this.str + "_op", z3Context.boolSort);
            Term termConstant = context.MkConst(this.str + "_c", z3Context.intSort);

            List<Term> args = new List<Term>();
            args.Add(this.hasFirst ? termHasFirst : context.MkNot(termHasFirst));
            args.Add(this.hasSecond ? termHasSecond : context.MkNot(termHasSecond));
            args.Add(this.sign1 ? termSign1 : context.MkNot(termSign1));
            args.Add(this.sign2 ? termSign2 : context.MkNot(termSign2));
            args.Add(this.op ? termOp : context.MkNot(termOp));
            args.Add(context.MkEq(termVar1, context.MkNumeral(this.var1, z3Context.intSort)));
            args.Add(context.MkEq(termVar2, context.MkNumeral(this.var2, z3Context.intSort)));
            args.Add(context.MkEq(termConstant, context.MkNumeral(this.constant, z3Context.intSort)));

            return context.MkAnd(args.ToArray());            
        }*/
    }

    public class ConjunctionDomain : ICEDomain
    {
        public List<ICEDomain> args;
        string str;     // is "b1" for functionname == "b1"

        public ConjunctionDomain(string baseDomain, int numConjuncts, ref Z3Context z3Context, string str, int constantRange)
        {
            Debug.Assert(numConjuncts > 0);
            args = new List<ICEDomain>();
            this.str = str;
            for (int i = 0; i < numConjuncts; i++)
            {
                if (baseDomain == "Intervals")
                {
                    this.args.Add(new ICEIntervals(ref z3Context, this.str + "_" + i.ToString(), constantRange) as ICEDomain);
                }
                else if (baseDomain == "Octagons")
                {
                    this.args.Add(new ICEOctagons(ref z3Context, this.str + "_" + i.ToString(), constantRange) as ICEDomain);
                }
                else throw new ICEHoudiniInternalError("Domain not found");
            }
        }

        public ConjunctionDomain(string baseDomain, Template left, Template right, ref Z3Context z3Context, string str, int constantRange)
        {
            this.str = str;
            args = new List<ICEDomain>();
            args.Add(ICEDomainFactory.GetInstance(baseDomain, left, ref z3Context, str + "_1", constantRange));
            args.Add(ICEDomainFactory.GetInstance(baseDomain, right, ref z3Context, str + "_2", constantRange));
        }

        public Term constructSMTConstraint(List<Model.Element> states, ref Z3Context z3Context)
        {
            //Debug.Assert(states.Count == 1);
            List<Term> terms = new List<Term>();
            for (int i = 0; i < this.args.Count; i++)
            {
                terms.Add(this.args.ElementAt(i).constructSMTConstraint(states, ref z3Context));
            }
            return z3Context.context.MkAnd(terms.ToArray());
        }

        public bool initializeFromModel(Z3.Model model, ref Z3Context z3Context)
        {
            Debug.Assert(model != null);
            bool ret = false;
            for (int i = 0; i < args.Count; i++)
            {
                if (this.args.ElementAt(i).initializeFromModel(model, ref z3Context))
                    ret = true;
            }
            return ret;
        }

        public Expr Gamma(List<Expr> vars)
        {
            Expr ret = Expr.True;
            for (int i = 0; i < args.Count; i++)
            {
                ret = Expr.And(ret, args.ElementAt(i).Gamma(vars));
            }
            return ret;
        }

        public bool TypeCheck(List<Type> argTypes, out string msg)
        {
            msg = "";
            for (int i = 0; i < this.args.Count; i++)
            {
                if (!args.ElementAt(i).TypeCheck(argTypes, out msg))
                    return false;
            }
            return true;
        }
        /*
        public Term currLearnedInvAsTerm(ref Z3Context z3Context)
        {
            List<Term> terms = new List<Term>();
            for (int i = 0; i < this.args.Count; i++)
            {
                terms.Add(this.args.ElementAt(i).currLearnedInvAsTerm(ref z3Context));
            }
            return z3Context.context.MkAnd(terms.ToArray());
        }*/
    }

    public class DisjunctionDomain : ICEDomain
    {
        public ICEDomain arg1;
        public ICEDomain arg2;

        string str;     

        public DisjunctionDomain(string baseDomain, Template left, Template right, ref Z3Context z3Context, string str, int constantRange)
        {
            this.str = str;
            this.arg1 = ICEDomainFactory.GetInstance(baseDomain, left, ref z3Context, str + "_1", constantRange);
            this.arg2 = ICEDomainFactory.GetInstance(baseDomain, right, ref z3Context, str + "_2", constantRange);
        }

        public Term constructSMTConstraint(List<Model.Element> states, ref Z3Context z3Context)
        {
            return z3Context.context.MkOr(arg1.constructSMTConstraint(states, ref z3Context), arg2.constructSMTConstraint(states, ref z3Context));
        }

        public bool initializeFromModel(Z3.Model model, ref Z3Context z3Context)
        {
            Debug.Assert(model != null);
            bool ret = false;
            if (this.arg1.initializeFromModel(model, ref z3Context))
                ret = true;
            if (this.arg2.initializeFromModel(model, ref z3Context))
                ret = true;
            
            return ret;
        }

        public Expr Gamma(List<Expr> vars)
        {
            return Expr.Or(this.arg1.Gamma(vars), this.arg2.Gamma(vars));            
        }

        public bool TypeCheck(List<Type> argTypes, out string msg)
        {
            msg = "";
            if (!this.arg1.TypeCheck(argTypes, out msg))
                    return false;
            if (!this.arg2.TypeCheck(argTypes, out msg))
                return false;
            
            return true;
        }

        /*
        public Term currLearnedInvAsTerm(ref Z3Context z3Context)
        {            
            return z3Context.context.MkAnd(arg1.currLearnedInvAsTerm(ref z3Context), arg2.currLearnedInvAsTerm(ref z3Context));
        }*/
    }

    public class ICEDomainFactory
    {
        public static ICEDomain GetInstance(string domainName, ref Z3Context z3Context, string str, int constantRange)
        {
            if (domainName == "Intervals")
            {
                return new ICEIntervals(ref z3Context, str, constantRange) as ICEDomain;
            }
            else if (domainName == "Octagons")
            {
                return new ICEOctagons(ref z3Context, str, constantRange) as ICEDomain;
            }

            int pos = domainName.IndexOf("(");
            if (pos <= 0)
            {
                Console.WriteLine("Domain {0} not found", domainName);
                Console.WriteLine("Supported domains are:");
                Console.WriteLine("  {Intervals}");
                throw new ICEHoudiniInternalError("Domain not found");
            }
            else{
                string baseDomain = domainName.Substring(0, pos);
                string templateString = domainName.Substring(pos);                
                TemplateParser.initialize(templateString);
                Template t = TemplateParser.Parse();            
                return GetInstance(baseDomain, t, ref z3Context, str, constantRange);
            }
        }

        public static ICEDomain GetInstance(string baseDomain, Template t, ref Z3Context z3Context, string str, int constantRange)
        {
            if (t.op == TemplateOperator.None)
            {
                if (t.value == 1)
                {
                    if (baseDomain == "Intervals")
                    {
                        return new ICEIntervals(ref z3Context, str, constantRange);
                    }
                    else if (baseDomain == "Octagons")
                    {
                        return new ICEOctagons(ref z3Context, str, constantRange);
                    }
                    else throw new ICEHoudiniInternalError("Domain not found");
                }
                else
                {
                    return new ConjunctionDomain(baseDomain, t.value, ref z3Context, str, constantRange);
                }
            }

            if (t.op == TemplateOperator.ConjunctionOp)
            {
                return new ConjunctionDomain(baseDomain, t.left, t.right, ref z3Context, str, constantRange);
            }
            
            Debug.Assert(t.op == TemplateOperator.DisjunctionOp);
            return new DisjunctionDomain(baseDomain, t.left, t.right, ref z3Context, str, constantRange);           
        }
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
                    throw new ICEHoudiniInternalError("Recursion detected in function declarations");
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

    public class ICEHoudiniInternalError : System.ApplicationException
    {
        public ICEHoudiniInternalError(string msg) : base(msg) { }

    };

    
    class ICEHoudiniErrorReporter : ProverInterface.ErrorHandler
    {
        public Model model;

        public ICEHoudiniErrorReporter()
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
