//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package Runner;
import DSE.DSE;
import GradDiff.GradDiff;
import IMPs.ImpactedS;
import com.microsoft.z3.Context;
import com.sun.javafx.PlatformUtil;
import equiv.checking.Utils;
import javafx.application.Platform;

import java.io.File;
import java.io.FileNotFoundException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;

import static equiv.checking.Paths.z3;
import static equiv.checking.Utils.*;

public class Runner{
    /** This is the main class to run each of the three tools **/
    protected String path;
    protected String MethodPath1,MethodPath2;
    protected ArrayList<Integer> changes;
    protected String OutputsPath1;
    protected Context context;

    public void setup(String path1, String path2) throws Exception {
        if(PlatformUtil.isWindows() && path1.contains("\\") || path2.contains("\\")){
            path1 = path1.replace("\\","/");
            path2 = path2.replace("\\","/");
        }
        int index = path1.lastIndexOf("/");
        if (index == -1)
            path = "";
        else {
            path = path1.substring(0,index + 1);
            MethodPath1 = path1;
            MethodPath2 = path2;
        }
        if(PlatformUtil.isLinux()) {
            File file = new File(z3);
            if(!file.canExecute()){
                boolean success = file.setExecutable(true);
                if(!success){
                    System.out.println(ANSI_RED + "Please make the z3 file in the current folder executable before proceeding" + ANSI_RESET);
                    System.exit(1);
                }
            }
            z3 = "./z3";
        }
    }

    public void setup(String path) throws Exception {
        this.path = path;
        if(!path.endsWith("/"))
            this.path+="/";
            String path1 = this.path + "oldV.java";
            String path2 = this.path + "newV.java";
        MethodPath1 = path1;
        MethodPath2 = path2;
        if(PlatformUtil.isLinux()) {
            File file = new File(z3);
            if(!file.canExecute()){
                boolean success = file.setExecutable(true);
                if(!success){
                    System.out.println(ANSI_RED + "Please make the z3 file in the current folder executable before proceeding" + ANSI_RESET);
                    System.exit(1);
                }
            }
            z3 = "./z3";
        }
    }

    private static void checkBound(Runner runner,int bound) throws FileNotFoundException {
        int minRange = 5,maxRange = 6;
        long time = System.currentTimeMillis();
        int numLoops = Math.max(Utils.extractLoops(runner.MethodPath1),Utils.extractLoops(runner.MethodPath2));
        long end = System.currentTimeMillis();
        int factor = 2, shift = 1;
        minRange = factor*numLoops + shift;
        maxRange = factor*numLoops + shift;
        if(bound < maxRange)
            System.out.println("[WARNING] If you want to have a complete summary (exercise all behaviors), make sure your bound is big enough.");
    }



    public static void runTool(String tool, String p1, String p2, String solver,int b,int t, int minInt,int maxInt,double minDouble,double maxDouble,boolean z3Terminal) throws Exception {
        try {
            //the path to two target versions
            ////************************************************************************+////
            //the depth limit
            int bound = b;
            ////************************************************************************+////
            //the range of values
            long minLong = (long)minInt;
            long maxLong = (long)maxInt;
            ////************************************************************************+////
            //the time out for the constraint solving
            int timeout = t;// (100 seconds * 1000 ms) for z3. and jpf which both are in MS
            ////************************************************************************+////
            //the choice of the constraint solvers
            String SMTSolver = solver;
            //String SMTSolver = "coral";
            //String SMTSolver = "z3inc";
            //String SMTSolver = "choco";
            //String SMTSolver = "cvc3";
            ////************************************************************************+////
            Runner runner = new Runner();
            runner.setup(p1,p2);
            if(System.getProperty("os.name").contains("Windows"))
                System.out.println("\n[NOTE] If you want to have a complete summary (exercise all behaviors), make sure your bound is big enough.");

            else System.out.println(ANSI_GREEN + "[NOTE] If you want to have a complete summary (exercise all behaviors), make sure your bound is big enough."+ANSI_RESET);
            ////*******************************************************************************************************************************************+////
            if(tool.contains("D")) {
                System.out.println("*****************************************************************************");
                System.out.println("------------------------------------DSE-----------------------------------");
                System.out.println("*****************************************************************************");
                boolean parseFromSMTLib = true;// to parse the jpf output into a string similar to the terminal version of Z3 (true for the terminal version when you have Math.XXXX)
                DSE dse = new DSE(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "DSE", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong, parseFromSMTLib,true,z3Terminal);
                boolean finished1 = dse.runTool();
                if (finished1==true)
                    System.exit(0);
                try
                {
                    Thread.sleep(timeout);
                }
                catch (InterruptedException e)
                {
                    // log the exception.
                }
                System.exit(0);
            }
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            if(tool.contains("A")) {
                System.out.println("*****************************************************************************");
                System.out.println("------------------------------------ARDIFF-----------------------------------");
                System.out.println("*****************************************************************************");
                boolean H1 = true;
                boolean H2 = true;
                boolean H31 = true;
                boolean H32 = true;
                String strategy = "H123";
                boolean parseFromSMTLib = true ;
                GradDiff gradDiff = new GradDiff(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "ARDiff", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong, parseFromSMTLib, H1, H2, H31, H32, strategy, true,z3Terminal);
                boolean finished2 = gradDiff.runTool();
                if (finished2==true)
                    System.exit(0);
                try
                {
                    Thread.sleep(timeout);
                }
                catch (InterruptedException e)
                {
                    // log the exception.
                }
                System.exit(0);
            }
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            if(tool.contains("I")) {
                System.out.println("*****************************************************************************");
                System.out.println("------------------------------------IMP-S-----------------------------------");
                System.out.println("*****************************************************************************");
                boolean parseFromSMTLib = true ;
                ImpactedS impactedS = new ImpactedS(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "Imp", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong, parseFromSMTLib, true,z3Terminal);
                boolean finished3 = impactedS.runTool();
                if (finished3==true)
                    System.exit(0);
                try
                {
                    Thread.sleep(timeout);
                }
                catch (InterruptedException e)
                {
                    // log the exception.
                }
                System.exit(0);
            }

        }
        catch (Exception e){

        }
    }


    public static void runBenchMarks(){
        try {
            //the path to two target versions
            String path = "../../ARDiff/benchmarks/Airy/Sign/Eq";
            ////************************************************************************+////
            //the depth limit
            int bound = 20;
            ////************************************************************************+////
            //the range of values
            int minInt = -100;
            int maxInt = 100;
            double minDouble = -100.0;
            double maxDouble = 100.0;
            long minLong = -100;
            long maxLong = 100;
            ////************************************************************************+////
            //the time out for the constraint solving
            int timeout = 300*1000;// (100 seconds * 1000 ms) for z3. and jpf which both are in MS
            ////************************************************************************+////
            //the choice of the constraint solvers
            //String SMTSolver = "z3";
            String SMTSolver = "coral";
            //String SMTSolver = "z3inc";
            //String SMTSolver = "choco";
            //String SMTSolver = "cvc3";
            ////************************************************************************+////
            Runner runner = new Runner();
            runner.setup(path);
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------DSE-----------------------------------");
            System.out.println("*****************************************************************************");
            boolean parseFromSMTLib = true ;// to parse the jpf output into a string similar to the terminal version of Z3 (true for the terminal version when you have Math.XXXX)
            DSE dse = new DSE(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout,"DSE", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib, false,Z3_TERMINAL);
            boolean finished1 = dse.runTool();
            if (finished1==true)
                System.exit(0);
            try
            {
                Thread.sleep(timeout);
            }
            catch (InterruptedException e)
            {
                // log the exception.
            }
            //System.exit(0);
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------ARDIFF-----------------------------------");
            System.out.println("*****************************************************************************");
            boolean H1 = false;
            boolean H2 = true;
            boolean H31 = true;
            boolean H32 = true;
            String strategy = "H123";
            //boolean parseFromSMTLib = true ;
            GradDiff gradDiff = new GradDiff(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "ARDiff", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib, H1, H2, H31, H32, strategy, false,Z3_TERMINAL);
            long start2 = System.currentTimeMillis();
            long end2 = start2 + 300*1000; // 300 seconds * 1000 ms/sec like CLEVER
            boolean finished2 = gradDiff.runTool();
            while (System.currentTimeMillis() < end2  && finished2!=true) {
                //running GradDiff
            }
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------H3-----------------------------------");
            System.out.println("*****************************************************************************");
            H1 = false;
            H2 = false;
            H31 = true;
            H32 = true;
            strategy = "H3";
            gradDiff = new GradDiff(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "ARDiff", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib, H1, H2, H31, H32, strategy, false,Z3_TERMINAL);
            start2 = System.currentTimeMillis();
            end2 = start2 + 300*1000; // 300 seconds * 1000 ms/sec like CLEVER
            finished2 = gradDiff.runTool();
            while (System.currentTimeMillis() < end2  && finished2!=true) {
                //running GradDiff
            }
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------Random-----------------------------------");
            System.out.println("*****************************************************************************");
            strategy = "R";
            gradDiff = new GradDiff(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "ARDiff", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib, H1, H2, H31, H32, strategy,false,Z3_TERMINAL);
            start2 = System.currentTimeMillis();
            end2 = start2 + 300*1000; // 300 seconds * 1000 ms/sec like CLEVER
            finished2 = gradDiff.runTool();
            while (System.currentTimeMillis() < end2  && finished2!=true) {
                //running GradDiff
            }
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------Random-----------------------------------");
            System.out.println("*****************************************************************************");
            strategy = "R2";
            gradDiff = new GradDiff(runner.path, runner.MethodPath1, runner.MethodPath2, bound, timeout, "ARDiff", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib, H1, H2, H31, H32, strategy,false,Z3_TERMINAL);
            start2 = System.currentTimeMillis();
            end2 = start2 + 300*1000; // 300 seconds * 1000 ms/sec like CLEVER
            finished2 = gradDiff.runTool();
            while (System.currentTimeMillis() < end2  && finished2!=true) {
                //running GradDiff
            }
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            ////*******************************************************************************************************************************************+////
            System.out.println("*****************************************************************************");
            System.out.println("------------------------------------IMP-S-----------------------------------");
            System.out.println("*****************************************************************************");
            ImpactedS impactedS = new ImpactedS(runner.path, runner.MethodPath1, runner.MethodPath2,  bound, timeout, "Imp", SMTSolver, minInt, maxInt, minDouble, maxDouble, minLong, maxLong,parseFromSMTLib,false,Z3_TERMINAL);
            long start3 = System.currentTimeMillis();
            long end3 = start3 + 300*1000; // 300 seconds * 1000 ms/sec like CLEVER
            boolean finished3 = impactedS.runTool();
            while (System.currentTimeMillis() < end3  && finished3!=true) {
                //running IMP-S
            }

        }
        catch (Exception e){

        }
    }

    public static void main(String[] args) throws Exception {
        //To run on the benchmarks
        //System.out.println("hello");
        if(args.length == 0) {
            runBenchMarks();
        }
        else{
            System.out.println("Arguments:");
            System.out.println("--path1 path/to/the/first/method --path2 path/to/the/second/method --tool ToolName --s SMTSolverName --t timeout --b bound --minint minInt --maxint maxInt --mindouble minDouble --maxdouble maxDouble");
            System.out.println("*****************");
            System.out.println("--tool ToolName: to choose the tool to run (Default is ARDiff):");
            System.out.println("--tool D: Run DSE");
            System.out.println("--tool I: Run IMP-S");
            System.out.println("--tool A: Run ARDiff");
            if(DEBUG) {
                System.out.println("*****************");
                System.out.println("--s SMTSolverName: to choose the SMTSolver (Default is coral):");
                System.out.println("--s z3");
                System.out.println("--s coral");
                System.out.println("--s choco");
                System.out.println("--s cvc3");
                System.out.println("*****************");
            }
            System.out.println("--t timeout: to choose the timeout for constraint solving in millisecond (Default is 300000 MS):");
            System.out.println("*****************");
            System.out.println("--b bound: to choose the loop bound (Default is 5)");
            System.out.println("*****************");
            System.out.println("--minint: the minimum value of integers in the program (Default is -100):");
            System.out.println("*****************");
            System.out.println("--maxint: the maximum value of integers in the program (Default is 100):");
            System.out.println("*****************");
            System.out.println("--mindouble: the minimum value of doubles in the program (Default is -100.0):");
            System.out.println("*****************");
            System.out.println("--maxdouble: the maximum value of doubles in the program (Default is 100.0):");
            System.out.println("*****************");
            if(args.length<4){
                System.out.println("Arguments are missing, you should AT LEAST specify the paths to both methods!");
                System.exit(1);
            }
            String path1 = "";
            String path2 = "";
            /**************/
            String tool = "A";
            String solver = "coral";
            int bound = 5;//loop bound
            int timeout = 300 * 1000;
            int minint = -100;
            int maxint = 100;
            double mindouble = -100.0;
            double maxdouble = 100.0;
            boolean z3Terminal = true;
            /**************/
            for(int i = 0; i < 23; i+=2) {
                if (args.length > i) {
                    if(args[i].equals("--path1")){
                        path1 = args[i+1];
                    }
                    if(args[i].equals("--path2")){
                        path2 = args[i+1];
                    }
                    if (args[i].equals("--tool")) {
                        if (args.length < i + 2) {
                            System.out.println("You need to specify the tool you want to use. If not remove the argument --tool");
                            System.exit(1);
                        }
                        tool = args[i + 1];
                    }
                    if(DEBUG) {
                        if (args[i].equals("--s")) {
                            if (args.length < i + 2) {
                                System.out.println("You need to specify the solver you want to use. If not remove the argument --s");
                                System.exit(1);
                            }
                            solver = args[i + 1];
                        }
                    }
                    else if(args[i].equals("--t")){
                        if (args.length < i + 2) {
                            System.out.println("You need to specify the timeout. If not, remove the argument --t");
                            System.exit(1);
                        }
                        timeout = Integer.parseInt(args[i + 1]);
                    }
                    else if (args[i].equals("--b")) {
                        if (args.length < i + 2) {
                            System.out.println("You need to specify the loop bounds. If not, remove the argument --b");
                            System.exit(1);
                        }
                        bound = Integer.parseInt(args[i + 1]);
                    }
                    else if(args[i].equals("--minint")){
                        if(args.length < i + 2){
                            System.out.println("You need to specify the min int value.If not, remove the argument --minint");
                            System.exit(1);
                        }
                        minint = Integer.parseInt(args[i+1]);
                    }
                    else if(args[i].equals("--maxint")){
                        if(args.length < i + 2){
                            System.out.println("You need to specify the max int value.If not, remove the argument --maxint");
                            System.exit(1);
                        }
                        maxint = Integer.parseInt(args[i+1]);
                    }
                    else if(args[i].equals("--mindouble")){
                        if(args.length < i + 2){
                            System.out.println("You need to specify the min double value.If not, remove the argument --mindouble");
                            System.exit(1);
                        }
                        mindouble = Double.parseDouble(args[i+1]);
                    }
                    else if(args[i].equals("--maxdouble")) {
                        if (args.length < i + 2) {
                            System.out.println("You need to specify the max double value.If not, remove the argument --maxdouble");
                            System.exit(1);
                        }
                        maxdouble = Double.parseDouble(args[i + 1]);
                    }
                    else if(args[i].equals("--z3Terminal")){
                        if(args.length < i+2){
                            System.out.println("You need to specify if you want to run z3 from the terminal or not.If not, remove the argument --maxdouble");
                            System.exit(1);
                        }
                        z3Terminal = Boolean.parseBoolean(args[i+1]);
                    }
                }
            }
            if(path1.isEmpty() || path2.isEmpty()){
                System.out.println("\nPlease provide proper paths");
                System.exit(1);
            }
            runTool(tool,path1,path2,solver,bound,timeout,minint,maxint,mindouble,maxdouble,z3Terminal);
        }
    }
}