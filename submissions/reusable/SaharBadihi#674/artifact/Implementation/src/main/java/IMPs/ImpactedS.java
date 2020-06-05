//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package IMPs;

import br.usp.each.saeg.asm.defuse.Variable;
import com.microsoft.z3.Status;
import equiv.checking.*;
import static equiv.checking.Utils.DEBUG;
import equiv.checking.SymbolicExecutionRunner.SMTSummary;
import org.objectweb.asm.ClassReader;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.MethodNode;
import org.objectweb.asm.tree.analysis.AnalyzerException;

import java.io.*;
import java.util.*;

public class ImpactedS {
    protected String MethodPath1,MethodPath2;
    protected String ClassPath1,ClassPath2;
    protected String path;
    protected long[] times;
    protected int bound;
    protected int timeout;
    protected String toolName;
    protected String SMTSolver;
    protected int minInt, maxInt;
    protected double minDouble, maxDouble;
    protected long minLong,  maxLong;
    protected boolean parseFromSMTLib;
    protected  ArrayList<Integer> changes;
    //Variable to put true to include dummy statements
    protected boolean dummy = false;
    protected boolean ranByUser = false;
    protected boolean Z3_TERMINAL = true;

    public ImpactedS(){
        this.bound = 5;
        initVariables();
    }

    public ImpactedS(String path,String path1, String path2,int bound, int timeout, String toolName, String SMTSolver, int minint, int maxint, double mindouble, double maxdouble, long minlong, long maxlong,boolean parseFromSMTLib,boolean ranByUser, boolean z3Terminal){
        MethodPath1 = path1;
        MethodPath2 = path2;
        this.path = path;
        this.bound = bound;
        this.timeout = timeout;
        times = new long[5];
        this.toolName = toolName;
        this.SMTSolver = SMTSolver;
        this.minInt = minint;
        this.maxInt = maxint;
        this.minDouble = mindouble;
        this.maxDouble = maxdouble;
        this.minLong = minlong;
        this.maxLong = maxlong;
        this.parseFromSMTLib = parseFromSMTLib;
        //initClassPath();
        this.ranByUser = ranByUser;
        this.Z3_TERMINAL = z3Terminal;
    }

    public ImpactedS(String path1, String path2,int bound, int timeout, String tool, String SMTSolver){
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

    public void initVariables(){
        MethodPath1 = "src/examples/demo/benchmarks/oldV.java";
        MethodPath2 = "src/examples/demo/benchmarks/newV.java";
        String v1 = MethodPath1.substring(MethodPath1.lastIndexOf("/") + 1).split("\\.")[0];
        String v2 = MethodPath2.substring(MethodPath2.lastIndexOf("/") + 1).split("\\.")[0];
        ClassPath1 = "target/classes/demo/benchmarks/"+v1+".class";
        ClassPath2 = "target/classes/demo/benchmarks/"+v2+".class";
        this.path = "src/examples/demo/benchmarks/";
        times = new long[4];
    }

    /**
     * This functions sets up all the file paths
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
     * This is the main function to run the tool
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
            else changes = changeExtractor.obtainChanges(MethodPath1, MethodPath2,ranByUser,path);
            setPathToDummy(changeExtractor.getClasspath());
            gumTreePassed = true;
            SMTSummary summary= runEquivalenceChecking();
            String result = equivalenceResult(summary);
            System.out.println(result);
            String outputs = path.split("instrumented")[0];
            File newFile = new File(outputs+"outputs/Impacted.txt");
            newFile.getParentFile().mkdir();
            if(!newFile.exists())
                newFile.createNewFile();
            FileWriter fwNew=new FileWriter(newFile);
            BufferedWriter writer=new BufferedWriter(fwNew);
            writer.write(result);
            writer.close();
            fwNew.close();;
        } catch (Exception e) {
            if(!gumTreePassed)
                System.out.println("An error/exception occurred when identifying the changes between the two methods.\n" +
                        "The GumTree module is still under development. Please check your examples or report this issue to us.\n\n");
            else System.out.println("An error/exception occurred when instrumenting the files or running the equivalence checking. Please report this issue to us.\n\n");
            e.printStackTrace();
        }
        return true;
    }


    /**
     * This method runs all steps of the equivalence checking
     * Change extraction
     * Program slicing for impacted statements extraction
     * JPF inputs creation and symbolic execution on those
     * Z3 constraint solving on JPF output returning a summary of the execution
     * @return A SMT summary object corresponding to the information and results obtained while running JPF + Z3
     * @throws Exception
     */
    public SMTSummary runEquivalenceChecking() throws Exception {
            long start,end;
            start = System.nanoTime();

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

            end = System.nanoTime();
            times[0] = end - start;

            /************** To obtain the methods parameters ***********/
            start = System.nanoTime();
            DefUseExtractor def = new DefUseExtractor();
            Variable[] variables = def.getVariables(method2);
            Map<String, String> variablesNamesTypesMapping = def.getVariableTypesMapping(); ////(x, I)
            String[] methodParams = def.extractParams(method2);
            String[] constructorParams = def.extractParamsConstructor(Methods2.get(0));

            /******To be replaced , after running more tests******/
            //Overwrite the files instead of creating new files or adjust the paths given to commonBlockExtractor
            if(DEBUG) System.out.println("changes are "+ changes);
            ///////////////////////////////////////////////////
            ProgramSlicer programSlicer = new ProgramSlicer(changes);
            programSlicer.impactedStatements(MethodPath1,method1);
            ArrayList<Integer> listOne = new ArrayList<Integer>(programSlicer.getImpactedStatements());
            //////////////////////////////////////////////////////
            ProgramSlicer programSlicerNew = new ProgramSlicer(changes);
            programSlicer.impactedStatements(MethodPath2,method2);
            ArrayList<Integer> listTwo = new ArrayList<Integer>(programSlicerNew.getImpactedStatements());
            //////////////////////////////////////////////////////
            Set<Integer> set = new LinkedHashSet<>(listOne);
            set.addAll(listTwo);
            programSlicer.impactedStatements = new ArrayList<Integer>(set);
            Collections.sort(programSlicer.impactedStatements);
            if(DEBUG)
                System.out.println("Impacted statements combined "+programSlicer.getImpactedStatements());

            /******End ******/

            Instrumentation instrument = new Instrumentation(path, toolName);
           // instrument.setBlocks(common.blocks);

            /*****Generating the main methods of each class ******/
            String mainMethod1 = instrument.getMainProcedure(v1ClassName, method1.name, methodParams, constructorParams,variablesNamesTypesMapping);
            String mainMethod2 = instrument.getMainProcedure(v2ClassName, method2.name, methodParams, constructorParams,variablesNamesTypesMapping);

            /**************Creating the new class files with the added main method ***************/
            instrument.setMethods(Methods1);
            instrument.saveNewProcedure(MethodPath1,v1ClassName,null,null,mainMethod1);
            //int numParam1=instrument.getNumParameters();
            instrument.setMethods(Methods2);
            instrument.saveNewProcedure(MethodPath2,v2ClassName,null,null,mainMethod2);

            end = System.nanoTime();
            times[1] = end - start;
            /**********************Running the symbolic execution ******************/
            start = System.nanoTime();
            ImpactedSummariesRunner symbEx = new ImpactedSummariesRunner(path,instrument.packageName(),v1ClassName+toolName, v2ClassName+toolName, method2.name, methodParams.length,programSlicer.getImpactedStatements(),null,bound, timeout, SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib,Z3_TERMINAL);
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
            File file = new File(outputs+"z3models/Impacted.txt");
            file.getParentFile().mkdir();
            if(!file.exists())
                file.createNewFile();
            BufferedWriter br = new BufferedWriter(new FileWriter(file));
            br.write(summary.toWrite);
            br.close();
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
        result +="  -Initialization : "+times[0]/ (Math.pow(10,6))+" ms\n";
        result +="  -Program slicing : "+times[1]/ (Math.pow(10,6))+" ms\n";
        result +="  -Symbolic execution  : "+times[2]/ (Math.pow(10,6))+" ms\n";
        result +="  -Creating Z3 expressions  : "+times[3]/ (Math.pow(10,6))+" ms\n";
        result+="   -Constraint solving : "+times[4]/ (Math.pow(10,6))+" ms\n";
        if(smtSummary.status == Status.UNSATISFIABLE)
            result +="Output : EQUIVALENT";
        else if(smtSummary.status == Status.UNKNOWN) {
            result +="Output : UNKNOWN \n";
            result +="Reason: "+smtSummary.reasonUnknown;
        }
        else
            //smtSummary.functionalDelta();
            result += "Output : NOT EQUIVALENT";
        smtSummary.context.close();
        result +="\n-----------------------END-------------------------------------------\n";
        return result;
    }

    

    public static void main(String[] args) throws Exception {
        ImpactedS impactedS = new ImpactedS("src/examples/demo/benchmarks/oldV.java","src/examples/demo/benchmarks/newV.java",100,300*100,"Imp","z3");
        System.out.println(impactedS.MethodPath1+"  "+impactedS.MethodPath2);
        ChangeExtractor changeExtractor = new ChangeExtractor();
        impactedS.changes = changeExtractor.obtainChanges(impactedS.MethodPath1, impactedS.MethodPath2,impactedS.ranByUser,impactedS.path);
        impactedS.setPathToDummy(changeExtractor.getClasspath());
        System.out.println(impactedS.MethodPath1+"  "+impactedS.MethodPath2);
        System.out.println(impactedS.equivalenceResult(impactedS.runEquivalenceChecking()));
    }
}
