//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package DSE;

import br.usp.each.saeg.asm.defuse.Variable;
import com.microsoft.z3.Params;
import com.microsoft.z3.Solver;
import com.microsoft.z3.Status;
import com.microsoft.z3.Tactic;
import equiv.checking.*;
import equiv.checking.SymbolicExecutionRunner.SMTSummary;
import javafx.util.Pair;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.MethodNode;

import java.io.*;
import java.util.*;

import static equiv.checking.Paths.z3;
import static equiv.checking.Utils.DEBUG;


public class DSE {
    /** The class to run DSE **/
    protected String path;
    protected String MethodPath1,MethodPath2;
    protected String ClassPath1,ClassPath2;
    protected ArrayList<Integer> changes;
    protected ArrayList<ArrayList<Integer>> blocks;
    protected Map<Integer,String[]> outputsPerBlock1,outputsPerBlock2;
    protected Map<Integer, Map<Integer, Pair<String, int[]>>> statementInfoPerBlock1,statementInfoPerBlock2;
    protected ArrayList<LinkedHashMap<String, Pair<Boolean,HashSet<String>>>> blockResults,blockResults2;
    protected long[] times = new long[5];
    protected int bound;
    protected int timeout;
    protected boolean debug = false;
    protected String toolName;
    protected String SMTSolver;
    protected int minInt, maxInt;
    protected double minDouble, maxDouble;
    protected long minLong,  maxLong;
    protected boolean parseFromSMTLib;
    protected boolean ranByUser = false;
    protected boolean Z3_TERMINAL = false;

    public DSE(String path, String path1, String path2,int bound, int timeout, String tool, String SMTSolver, int minint, int maxint, double mindouble, double maxdouble, long minlong, long maxlong,boolean parseFromSMTLib,boolean ranByUser,boolean z3_TERMINAL){
        MethodPath1 = path1;
        MethodPath2 = path2;
        this.path = path;
        this.bound = bound;
        this.timeout = timeout;
        this.toolName = tool;
        this.SMTSolver = SMTSolver;
        this.minInt = minint;
        this.maxInt = maxint;
        this.minDouble = mindouble;
        this.maxDouble = maxdouble;
        this.minLong = minlong;
        this.maxLong = maxlong;
        this.parseFromSMTLib = parseFromSMTLib;
        this.ranByUser = ranByUser;
        this.Z3_TERMINAL = z3_TERMINAL;
    }

    public DSE(String path1, String path2,int bound, int timeout, String tool, String SMTSolver){
        MethodPath1 = path1;
        MethodPath2 = path2;
        this.bound = bound;
        this.timeout = timeout;
        this.toolName = tool;
        this.SMTSolver = SMTSolver;
        times = new long[5];
        this.minInt = -100;
        this.maxInt = 100;
        this.minDouble = -100;
        this.maxDouble = 100;
        this.minLong = -100;
        this.maxLong = 100;
        this.parseFromSMTLib = true;
        ranByUser = true;
    }

    public DSE(){
        this.bound = 5;
        this.toolName="";
        initVariables();
    }

    public void initVariables(){
        /*MethodPath1 = "./src/examples/demo/original/motivationEg1.java";
        MethodPath2 = "src/examples/demo/original/motivationEg2.java";*/

        MethodPath1 = "src/examples/demo/original/newV.java";
        MethodPath2 = "src/examples/demo/original/test2.java";
        path = "src/examples/demo/instrumented";
        initClassPath();
    }

    public void initClassPath(){
        String v1 = MethodPath1.substring(MethodPath1.lastIndexOf("/") + 1).split("\\.")[0];
        String v2 = MethodPath2.substring(MethodPath2.lastIndexOf("/") + 1).split("\\.")[0];
        ClassPath1 = "target/classes/demo/original/"+v1+".class";
        ClassPath2 = "target/classes/demo/original/"+v2+".class";

    }

    /**
     * This is a setup method to set the correct file paths
     * @param classpath
     */
    public void setPathToDummy(String classpath){
        if(ranByUser){
            path = this.path+"instrumented";
            int index = MethodPath1.lastIndexOf("/");
            int index2 = MethodPath2.lastIndexOf("/");
            String package1 = MethodPath1.substring(index + 1);
            String package2 = MethodPath2.substring(index2 + 1);
            MethodPath1 = path +"/"+ package1;
            MethodPath2 = path +"/"+ package2;
            ClassPath1 = "target/classes/"+classpath+"/"+package1.split("\\.")[0]+".class";
            ClassPath2 = "target/classes/"+classpath+"/"+package2.split("\\.")[0]+".class";
        }
        else {
            path += "instrumented";
            int index = MethodPath1.lastIndexOf("/");
            MethodPath1 = path + MethodPath1.substring(index);
            MethodPath2 = path + MethodPath2.substring(index);
            String package1 = MethodPath1.split("benchmarks/")[1].split("\\.")[0];
            String package2 = MethodPath2.split("benchmarks/")[1].split("\\.")[0];
            String classPath1 = "target/classes/demo/benchmarks/" + package1 + ".class";
            String classPath2 = "target/classes/demo/benchmarks/" + package2 + ".class";
            ClassPath1 = classPath1;
            ClassPath2 = classPath2;
        }
    }

    /**
     * The main method to run DSE
     * @return
     */
    public boolean runTool(){
        boolean gumTreePassed = false;
        try {
            ChangeExtractor changeExtractor = new ChangeExtractor();
            if(ranByUser) {
                String path = this.path +"instrumented";
                this.changes = changeExtractor.obtainChanges(MethodPath1, MethodPath2, ranByUser, path);
            }
            else this.changes = changeExtractor.obtainChanges(MethodPath1, MethodPath2, ranByUser, path);
            setPathToDummy(changeExtractor.getClasspath());
            gumTreePassed = true;
            SMTSummary summary= runEquivalenceChecking();
            String result = equivalenceResult(summary);
            System.out.println(result);
            String outputs = path.split("instrumented")[0];
            File newFile = new File(outputs+"outputs/DSE.txt");
            newFile.getParentFile().mkdir();
            if(!newFile.exists())
                newFile.createNewFile();
            FileWriter fwNew=new FileWriter(newFile);
            BufferedWriter writer=new BufferedWriter(fwNew);
            writer.write(result);
            writer.close();
            fwNew.close();
            File file = new File(outputs+"z3models/DSE.txt");
            file.getParentFile().mkdir();
            if(!file.exists())
                file.createNewFile();
            BufferedWriter br = new BufferedWriter(new FileWriter(file));
            br.write(summary.toWrite);
            br.close();
        } catch (Exception e) {
            if(!gumTreePassed)
                System.out.println("An error/exception occurred when identifying changes between the two methods.\n" +
                        "Please double-check your examples or report this issue to us as the GumTree module is still under development.\n\n");
            else System.out.println("An error/exception occurred when instrumenting the files or running the equivalence checking. Please report this issue to us.\n\n");
            e.printStackTrace();
        }
        return true;
    }

    /**
     * This method runs all steps of the equivalence checking
     * Change extraction
     * Common-block extraction
     * Def-use extraction to create the uninterpreted functions
     * JPF inputs creation and symbolic execution on those
     * Z3 constraint solving on JPF output returning a summary of the execution
     * @return A SMT summary object corresponding to the information and results obtained while running JPF + Z3
     * @throws Exception
     */
    public SMTSummary runEquivalenceChecking() throws Exception{
            //Think about which one to do defUse on
            long start = System.nanoTime();
            ClassNode ClassNode1 = new ClassNode();
            ClassReader classReader1 = new ClassReader(new FileInputStream(ClassPath1));
            classReader1.accept(ClassNode1, 0);
            List<MethodNode> Methods1 = (List<MethodNode>) ClassNode1.methods;
            MethodNode method1 = Methods1.get(1);//method 0 is by default the "init" method

            ClassNode ClassNode2 = new ClassNode();
            ClassReader classReader2 = new ClassReader(new FileInputStream(ClassPath2));
            classReader2.accept(ClassNode2, 0);
            List<MethodNode> Methods2 = (List<MethodNode>) ClassNode2.methods;
            MethodNode method2 = Methods2.get(1);//method 0 is by default the "init" method
            String v1ClassName = "I" + ClassNode1.name.substring(ClassNode1.name.lastIndexOf("/") + 1);
            String v2ClassName = "I" + ClassNode2.name.substring(ClassNode2.name.lastIndexOf("/") + 1);
            long end = System.nanoTime();
            times[0] = end - start;

            start = System.nanoTime();
            CommonBlockExtractor common = new CommonBlockExtractor(path);
            if(debug) System.out.println("Blocks : "+blocks);
            String commonBlocks = common.saveCommonBlocks(MethodPath1, MethodPath2, changes);
            /*************************For method 1**********************/
            DefUseExtractor def = new DefUseExtractor();
            Variable[] variables = def.getVariables(method1);
            Map<String, String> variablesNamesTypesMapping1 = def.getVariableTypesMapping(); ////(x, I)
            if(debug)  System.out.println(variablesNamesTypesMapping1);
            String[] methodParams = def.extractParams(method1);
            String[] constructorParams = def.extractParamsConstructor(Methods1.get(0));
            if(debug)  System.out.println("Constructor" +Arrays.toString(constructorParams));
            blockResults = def.extractBlocksInputsOutputs(common.root1,method1,common.blocks);
            outputsPerBlock1 = def.outputsPerBlock();
            statementInfoPerBlock1 = def.getStatementInfoPerBlock();
            /*************************For method 2**********************/
            Variable[] variables2 = def.getVariables(method2);
            String[] methodParams2 = def.extractParams(method2);
            String[] constructorParams2 = def.extractParamsConstructor(Methods2.get(0));
            Map<String, String> variablesNamesTypesMapping2 = def.getVariableTypesMapping(); ////(x, I)
            if(debug)  System.out.println(variablesNamesTypesMapping2);
            blockResults2 = def.extractBlocksInputsOutputs(common.root2,method2,common.blocks);
            outputsPerBlock2 = def.outputsPerBlock();
            statementInfoPerBlock2 = def.getStatementInfoPerBlock();
            /**********************************************************/
            if(DEBUG) System.out.println(blockResults);
            Instrumentation instrument = new Instrumentation(path, toolName);
            instrument.setBlocks(common.blocks);
            blocks = common.blocks;
            /*************Mapping each block index to a list of actual variable names ***********/
            Pair<ArrayList<String>, Map<Integer, ArrayList<String>>> uF = instrument.creatingUninterpretedFunction(blockResults, variablesNamesTypesMapping1, methodParams);
            Pair<ArrayList<String>, Map<Integer, ArrayList<String>>> uF2 = instrument.creatingUninterpretedFunction(blockResults2, variablesNamesTypesMapping2, methodParams);
            /*****Generating the main methods of each class ******/
           String mainMethod1 = instrument.getMainProcedure(v1ClassName, method2.name, methodParams, constructorParams,variablesNamesTypesMapping1);
           String mainMethod2 = instrument.getMainProcedure(v2ClassName, method2.name, methodParams, constructorParams,variablesNamesTypesMapping2);
            /**************Creating the new class files and the modified procedures ***************/
            instrument.setMethods(Methods1);
            instrument.saveNewProcedure(MethodPath1,v1ClassName,uF.getKey(),uF.getValue(),mainMethod1);
            instrument.setMethods(Methods2);
           instrument.saveNewProcedure(MethodPath2,v2ClassName,uF2.getKey(),uF2.getValue(),mainMethod2);

            end = System.nanoTime();
            times[1] = end - start;
            //int numParam2=instrument.getNumParameters();

            /**********************Running the symbolic execution ******************/
            start = System.nanoTime();
            SymbolicExecutionRunner symbEx = new SymbolicExecutionRunner( path,instrument.packageName(),v1ClassName+toolName,v2ClassName+toolName, method2.name, methodParams.length,this.bound, this.timeout, this.SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib,Z3_TERMINAL);
            symbEx.creatingJpfFiles();
            symbEx.runningJavaPathFinder();
            end = System.nanoTime();
            times[2] = end - start;
            start = System.nanoTime();
            SMTSummary summary = symbEx.createSMTSummary();
            end = System.nanoTime();
            times[3] = end - start;
            times[4] = symbEx.z3time;
            String outputs = path.split("instrumented")[0];
            return summary;
    }


    /**
     * This function outputs the result of equivalence checking based on the input
     * @param smtSummary the summary of the runs
     * @return the final output
     * @throws IOException
     */
    public String equivalenceResult(SMTSummary smtSummary) throws IOException {
        //check the status here
        String result ="-----------------------Results-------------------------------------------\n";
        result +="  -Def-use and uninterpreted functions : "+times[1] / (Math.pow(10,6))+"\n";
        result +="  -Symbolic execution  : "+times[2] / (Math.pow(10,6))+" ms\n";
        result +="  -Creating Z3 expressions  : "+times[3] / (Math.pow(10,6))+" ms\n";
        result +="  -Constraint solving : "+times[4] / (Math.pow(10,6))+" ms\n";
        if(smtSummary.status == Status.UNSATISFIABLE)
           result +="Output : EQUIVALENT";
        else if(smtSummary.status == Status.UNKNOWN) {
                result +="Output : UNKNOWN \n";
                result +="Reason: "+smtSummary.reasonUnknown;
        }
        else {
            if(debug) System.out.println(smtSummary.solver.getModel());
            //Here we are going to check for satisfiability
            Status status = checkForSatisfiability(smtSummary);
            if(status == Status.UNSATISFIABLE){//No chance to be EQUIVALENT
                result += "Output : NOT EQUIVALENT";
            }
            else{
                result += "Output : UNKNOWN \n";
                result +="Reason : solver found a counterexample, but it could be due to too much abstraction";
            }
        }

        smtSummary.context.close();
         result +="\n-----------------------END-------------------------------------------\n";
        return result;
    }

    /**
     * This is an helper function to check for the satisfiability of the formulas contained in the input
     * @param smtSummary
     * @return
     * @throws IOException
     */
    public Status checkForSatisfiability(SMTSummary smtSummary) throws IOException {
        if(smtSummary.noUFunctions)
            return Status.UNSATISFIABLE;
        if(Z3_TERMINAL)
            return runZ3FromTerminal(smtSummary);
        else {
            Tactic qfnra = smtSummary.context.mkTactic("qfnra-nlsat");
            Tactic simplifyTactic = smtSummary.context.mkTactic("ctx-solver-simplify");
            Tactic smtTactic = smtSummary.context.mkTactic("smt");
            Tactic aig = smtSummary.context.mkTactic("aig");
            Tactic solveeqs = smtSummary.context.mkTactic("solve-eqs");
            Tactic or = smtSummary.context.andThen(smtTactic, smtSummary.context.parOr(new Tactic[]{simplifyTactic, solveeqs, aig, qfnra}));
            final Solver solver = smtSummary.context.mkSolver(or);
            Params p = smtSummary.context.mkParams();
            p.add("timeout", timeout);
            solver.setParameters(p);
            solver.add(smtSummary.summaryOld);
            solver.add(smtSummary.context.mkEq(smtSummary.summaryOld, smtSummary.summaryNew));
            return solver.check();
        }
    }

    public Status runZ3FromTerminal(SMTSummary smtSummary) throws IOException {
        Status status = null;
        String toSolve = smtSummary.declarations+"(assert ("+smtSummary.firstSummary+"))\n(assert (= ("+smtSummary.firstSummary
                +") ("+smtSummary.secondSummary+")))\n(check-sat-using (then smt (par-or simplify aig solve-eqs qfnra-nlsat)))";
        String tmp2 = MethodPath1.replace("/","").replace(".","");
        File tmp = File.createTempFile(toolName+tmp2+"SATCHECK", null);
        BufferedWriter bw2 = new BufferedWriter(new FileWriter(tmp));
        bw2.write(toSolve);
        bw2.close();
        String mainCommand = z3+" -smt2 " + tmp.getAbsolutePath()+" -t:"+timeout;
        if (DEBUG) System.out.println(mainCommand);
        Process p1 = Runtime.getRuntime().exec(mainCommand);
        BufferedReader in = new BufferedReader(new InputStreamReader(p1.getInputStream()));
        String answer = in.readLine();
        switch (answer){
            case "sat":
                status = Status.SATISFIABLE;
                break;
            case "unsat":
                status = Status.UNSATISFIABLE;
                break;
            default:
                status = Status.UNKNOWN;
                break;
        }
        tmp.deleteOnExit();
        return status;
    }


    public static void main(String[] args) {
        DSE dse = new DSE();
        /******To be replaced , after running more tests******/
        //Overwrite the files instead of creating new files or adjust the paths given to commonBlockExtractor
        try {
            dse.changes = new ChangeExtractor().obtainChanges(dse.MethodPath1, dse.MethodPath2,dse.ranByUser,dse.path);
            //dse.setPathToDummy();
            if(DEBUG) System.out.println(dse.equivalenceResult(dse.runEquivalenceChecking()));
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
