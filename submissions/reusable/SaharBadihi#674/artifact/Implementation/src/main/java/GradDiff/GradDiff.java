//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package GradDiff;

import DSE.DSE;
import com.google.common.collect.MapDifference;
import com.google.common.collect.Maps;
import com.microsoft.z3.*;
import equiv.checking.ChangeExtractor;
import equiv.checking.SymbolicExecutionRunner.SMTSummary;
import equiv.checking.Utils;
import javafx.util.Pair;

import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

import static equiv.checking.Paths.z3;
import static equiv.checking.Utils.DEBUG;

public class GradDiff extends DSE {
    /** This class runs ARDiff **/
    private boolean onGoing = true;
    private Map<Integer, Pair<String, HashSet<String>>> defUsePerLine;
    private boolean H1 = true;
    private boolean H2 = true;
    private boolean H31 = true;
    private boolean H32 = true;
    private String strategy = "";

    public GradDiff(){
        super();
    }

    public GradDiff(String path,String path1, String path2, int bound, int timeout, String toolName, String SMTSolver, int minint, int maxint, double mindouble, double maxdouble, long minlong, long maxlong,boolean parseFromSMTLib, boolean H1, boolean H2, boolean H31, boolean H32, String strategy,boolean ranbyuser,boolean z3Terminal){
        super(path,path1,path2,bound, timeout, toolName,SMTSolver, minint,  maxint,  mindouble,  maxdouble,  minlong,  maxlong,parseFromSMTLib, ranbyuser,z3Terminal);
        this.H1 = H1;
        this.H2 = H2;
        this.H31 = H31;
        this.H32 = H32;
        this.strategy = strategy;
    }

    public GradDiff(String path1, String path2,int bound, int timeout, String tool, String SMTSolver){
        super(path1,path2,bound,timeout,tool,SMTSolver);
        this.H1 = true;
        this.H2 = true;
        this.H31 = true;
        this.H32 = true;
        this.strategy = "H123";
    }


    /**
     * This is the main function to run ARDiff
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
            else changes = changeExtractor.obtainChanges(MethodPath1, MethodPath2, ranByUser, path);
            setPathToDummy(changeExtractor.getClasspath());
            gumTreePassed = true;
            String outputs = path.split("instrumented")[0];
            File newFile = new File(outputs+"outputs/ARDiff"+this.strategy+".txt");
            newFile.getParentFile().mkdir();
            if(!newFile.exists())
                newFile.createNewFile();
            FileWriter fwNew=new FileWriter(newFile);
            BufferedWriter writer=new BufferedWriter(fwNew);
            SMTSummary summary = null;
            String result = "";
            int index =0;
            String finalRes = "";
            while(onGoing){
               result +="-----------------------Iteration : "+ index + " -------------------------------------------\n";
               summary = runEquivalenceChecking();
               finalRes = equivalenceResult(summary);
               result += finalRes;
               index ++;

            }
            System.out.println(finalRes);
            writer.write(result);
            writer.close();
            fwNew.close();

            File file = new File(outputs+"z3models/ARDiff.txt");
            file.getParentFile().mkdir();
            if(!file.exists())
                file.createNewFile();
            BufferedWriter br = new BufferedWriter(new FileWriter(file));
            br.write(summary.toWrite);
            br.close();

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
     * This function outputs the result for the equivalence of two programs
     * @param smtSummary the summaries for both programs to be compared
     * @return the equivalence result as a string
     * @throws IOException
     */
    public String equivalenceResult(SMTSummary smtSummary) throws IOException {
        if(debug) System.out.println("-----------------------The current status-------------------------------------------\n");
        if(debug) System.out.println(smtSummary.status);
        String result ="-----------------------Results-------------------------------------------\n";
        if(smtSummary.status == Status.UNSATISFIABLE) {
            onGoing = false;
            result +="  -Initialization : "+times[0]/ (Math.pow(10,6))+" ms\n";
            result +="  -Def-use and uninterpreted functions : "+times[1]/ (Math.pow(10,6))+" ms\n";
            result +="  -Symbolic execution  : "+times[2]/ (Math.pow(10,6))+" ms\n";
            result +="  -Creating Z3 expressions  : "+times[3]/ (Math.pow(10,6))+" ms\n";
            result+="   -Constraint solving : "+times[4]/ (Math.pow(10,6))+" ms\n";
            result += "Output : EQUIVALENT";
            result +="\n------------------------------END----------------------------------------\n";
            smtSummary.context.close();
            return result;
        }
        else if (smtSummary.status == Status.UNKNOWN) {
            result += "  -Initialization : " + times[0] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Def-use and uninterpreted functions : " + times[1] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Symbolic execution  : " + times[2] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Creating Z3 expressions  : " + times[3] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Constraint solving : " + times[4] / (Math.pow(10, 6)) + " ms\n";
            result +="Output : UNKNOWN \n";
            result +="Reason: "+smtSummary.reasonUnknown;
            if(smtSummary.reasonUnknown.contains("JPF-symbc") || smtSummary.noUFunctions){
                onGoing = false;
                result +="\n------------------------------NOTHING To REFINE---------------------------------------\n";
                result +="\n------------------------------END Of REFINEMENT----------------------------------------\n";
                result +="\n------------------------------END----------------------------------------\n";
                smtSummary.context.close();
                return result;
            }
                result += "\n------------------------------To be continued (REFINING)----------------------------------------\n";
                //Here we should not run the first heuristic thus ?
                //H1 = false;
        }
        else {// SAT
            result += "  -Initialization : " + times[0] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Def-use and uninterpreted functions : " + times[1] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Symbolic execution  : " + times[2] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Creating Z3 expressions  : " + times[3] / (Math.pow(10, 6)) + " ms\n";
            result += "  -Constraint solving : " + times[4] / (Math.pow(10, 6)) + " ms\n";
            result += "Output : NOT EQUIVALENT\n";
            if(smtSummary.noUFunctions) {
                onGoing = false;
                result +="\n------------------------------NOTHING To REFINE---------------------------------------\n";
                result +="\n------------------------------END Of REFINEMENT----------------------------------------\n";
                result +="\n------------------------------END----------------------------------------\n";
                smtSummary.context.close();
                return result;
            }
            ////////////////////////////////refinement might help//////////////////////////////////
            long beg = System.nanoTime();
            //check for SATISFAIABLITY: the possiblity to be equivalent
            Status status = checkForSatisfiability(smtSummary);
            long endF = System.nanoTime() - beg;
            if(debug) System.out.println("checking for satisfiability");
            BoolExpr exp = smtSummary.functionalDelta();
            //System.out.println(exp);
            if(debug) System.out.println(status.toString());
            if (status == Status.UNSATISFIABLE) {// no chance to be EQUIVALENT
                onGoing = false;
                if(debug) {
                    result += "After checking for satisfiability : \n";
                    result += "-----------------------FINAL RESULTS-------------------------------------------\n";
                    result += "   -Constraint solving : " + endF / (Math.pow(10, 6)) + " ms\n";
                    result += "Output : NOT EQUIVALENT";
                    result += "\n------------------------------END----------------------------------------\n";
                }
                else{
                    result +="\n------------------------------NOTHING To REFINE---------------------------------------\n";
                    result +="\n------------------------------END Of REFINEMENT----------------------------------------\n";
                    result +="\n------------------------------END----------------------------------------\n";
                }
                smtSummary.context.close();
                return result;
            }
        }
        result += "\n------------------------------To be continued (REFINING)----------------------------------------\n";
            long start = System.nanoTime();
            String s = getNextToRefine(smtSummary);
            long end = System.nanoTime();
            if(s.isEmpty()){
                if(debug) System.out.println("Nothing to refine");
                onGoing = false;
                times[3] +=end-start;
                result +="\n------------------------------NOTHING To REFINE---------------------------------------\n";
                result +="\n------------------------------END Of REFINEMENT----------------------------------------\n";
                result +="\n------------------------------END----------------------------------------\n";
                smtSummary.context.close();
            }
            else{
                if(debug) System.out.println("----------------------------refining----------------------------");
                expandFunction(s);
                end = System.nanoTime();
                times[3]+=end-start;
            }
        return result;
    }

    /**
     * This function is to determine the next uninterpreted function to refine
     * @param summary
     * @return the next function to refine
     * @throws IOException
     */
    public String getNextToRefine(SMTSummary summary) throws IOException {
        /****To be added for trigo functions ******/
        if(debug) System.out.println("***********Start to Refine*************");
        if(this.parseFromSMTLib) {
            createInstances(summary.summaryOld, summary.functionsInstances,summary.uFunctionsOld,summary.procCalls);
            createInstances(summary.summaryNew,summary.functionsInstances,summary.uFunctionsNew,summary.procCalls);
        }
        if (this.strategy.equals("R")){
            /*************************************************************Random*********************************************************************/
            String pick =  randomStrategy(summary);
            if(pick != null)
                return pick;
        }
        /*************************************************************Heuristics*********************************************************************/
        ArrayList<String> functions = new ArrayList<String>();//the list of Uc
        /*****************************First********************************/
        if(this.H1) {
           heuristicH1(summary,functions);
        }//end of H1
        //System.out.println("all possible functions from H1 :" + functions);
        /*****************************H Second********************************/
        if(this.H2) {
           heuristicH2(summary,functions);
        }
        /*****************************Intersection of H1 and H2********************************/
        List<String> functionsWithoutDuplicates = functions.stream().distinct().collect(Collectors.toList());
        if(debug) System.out.println("all possible functions from H1 and H2:" + functionsWithoutDuplicates);
        /**add everyting left*****/
        if(functionsWithoutDuplicates.size() == 0) {
            Set<String> both = new HashSet<>();
            summary.uFunctionsNew.keySet().forEach(expr -> both.add(expr.getFuncDecl().getName().toString()));
            summary.uFunctionsOld.keySet().forEach(expr -> both.add(expr.getFuncDecl().getName().toString()));
            functionsWithoutDuplicates =getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, both), true);
        }
        if(functionsWithoutDuplicates.size()!=0) {//UNFunc left?
            /****************************************H Third********************************/
            if (this.H31 && this.H32) {//both scores
                HashMap<String, Integer> H3 = new HashMap<>();
                for (int i = 0; i < functionsWithoutDuplicates.size(); i++) {
                    Map<Integer, Pair<String, int[]>> statements = getStatementsFromFunction(functionsWithoutDuplicates.get(i));
                    for (Integer line : statements.keySet()) {
                        Pair<String, int[]> statementInfo = statements.get(line);
                        //System.out.println(line + " : "+statementInfo.getValue()[0]);
                        H3.put(Integer.toString(line), statementInfo.getValue()[0] + statementInfo.getValue()[1]);
                    }
                }
                Map<String, Integer> h3Sorted = sortByValue(H3);
                if(debug) System.out.println("R: "+h3Sorted);
                Map.Entry<String, Integer> entry = h3Sorted.entrySet().iterator().next();
                String key = entry.getKey();
                if(debug) System.out.println("the candidate based on H3: "+key);
                return key;
            } /*******************************/
            else if (this.H31 && (!this.H32)) {
                HashMap<String, Integer> H3 = new HashMap<>();
                for (int i = 0; i < functionsWithoutDuplicates.size(); i++) {
                    Map<Integer, Pair<String, int[]>> statements = getStatementsFromFunction(functionsWithoutDuplicates.get(i));
                    for (Integer line : statements.keySet()) {
                        Pair<String, int[]> statementInfo = statements.get(line);
                        H3.put(Integer.toString(line), statementInfo.getValue()[0]);
                    }
                }
                Map<String, Integer> h3Sorted = sortByValue(H3);
                Map.Entry<String, Integer> entry = h3Sorted.entrySet().iterator().next();
                String key = entry.getKey();
                if(debug) System.out.println("the candidate based on H3.1: "+key);
                return key;
            } /*******************************/
            else if (this.H32 && (!this.H31)) {
                HashMap<String, Integer> H3 = new HashMap<>();
                for (int i = 0; i < functionsWithoutDuplicates.size(); i++) {
                    Map<Integer, Pair<String, int[]>> statements = getStatementsFromFunction(functionsWithoutDuplicates.get(i));
                    for (Integer line : statements.keySet()) {
                        Pair<String, int[]> statementInfo = statements.get(line);
                        H3.put(Integer.toString(line), statementInfo.getValue()[1]);
                    }
                }
                Map<String, Integer> h3Sorted = sortByValue(H3);
                Map.Entry<String, Integer> entry = h3Sorted.entrySet().iterator().next();
                String key = entry.getKey();
                if(debug) System.out.println("the candidate based on H3.2: "+key);
                return key;
            } /*****************************without H3********************************/
            else {
                /*****************************Randomly pick one********************************/
                Random rand = new Random();
                String radnomFunc = functionsWithoutDuplicates.get(rand.nextInt(functionsWithoutDuplicates.size()));
                if(debug) System.out.println("the candidate UNFunc based on H12: "+radnomFunc);
                Map<Integer, Pair<String, int[]>> statements = getStatementsFromFunction(radnomFunc);
                List<Integer> keysAsArray = new ArrayList<Integer>(statements.keySet());
                Integer line = keysAsArray.get(rand.nextInt(keysAsArray.size()));
                if(debug) System.out.println("the candidate based on H12: "+line);
                return Integer.toString(line);
            }
        }//end of picking one from functionlist
        return "";//nothing left
    }

    /**
     * This function picks an uninterpreted function randomly
     * @param summary
     * @return the chosen uninterpreted function
     */
    public String randomStrategy(SMTSummary summary){
        Set<String> both = new HashSet<>();
        summary.uFunctionsNew.keySet().forEach(expr -> both.add(expr.getFuncDecl().getName().toString()));
        summary.uFunctionsOld.keySet().forEach(expr -> both.add(expr.getFuncDecl().getName().toString()));
        List<String> functionsWithoutDuplicates =getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, both), true);
        if (functionsWithoutDuplicates.size()!=0) {
            if(debug) System.out.println("all functions:" + functionsWithoutDuplicates);
            /***************************pick a random***************************************/
            Random rand = new Random();
            String radnomFunc = functionsWithoutDuplicates.get(rand.nextInt(functionsWithoutDuplicates.size()));
            if(debug) System.out.println("the random candidate UNFunc: "+radnomFunc);
            Map<Integer, Pair<String, int[]>> statements = getStatementsFromFunction(radnomFunc);
            List<Integer> keysAsArray = new ArrayList<Integer>(statements.keySet());
            Integer line = keysAsArray.get(rand.nextInt(keysAsArray.size()));
            if(debug) System.out.println("the random candidate statement based: "+line);
            return Integer.toString(line);
        }
        return null;
    }

    /**
     * This function applies the first heuristic
     * It checks if there exists a uninterpreted function for which a fixed value would make both programs equivalent no matter the values of the other variables
     * @param summary the summary of JPF + z3
     * @param functions the list of uninterpreted functions
     * @throws IOException
     */
    public void heuristicH1(SMTSummary summary,ArrayList<String> functions) throws IOException {
        /*********************make the solver***************************************/
        Set<String> both = new HashSet<>();
        summary.uFunctionsOld.keySet().forEach(expr -> both.add(expr.getFuncDecl().getName().toString()));
        ArrayList<String> temp = getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, both), true);
        Context ctx = summary.context;
        /***************************variables*********************************/
        List<Expr> varList = new ArrayList<>();
        List<Expr> substList = new ArrayList<>();
        if(debug) System.out.println("Functions : "+temp);
        for (String func : temp) {
            HashSet<Expr> instances2 = summary.functionsInstances.get(func).getValue(); //We need to get all the functions that will be substituted
            int j = 0;
            Iterator<Expr> it2 = instances2.iterator();
            while (it2.hasNext()) {
                Expr e = it2.next();
                varList.add(e); // the original function symbol
                substList.add(ctx.mkConst(func + "_" + j, e.getSort()));//for substitution
                j++;
            }
            j = 0;
            for(Expr e: summary.procCalls){//we add all the uninterpreted functions related to interprocedural calls
                varList.add(e);
                substList.add(ctx.mkConst(func+"_"+j,e.getSort()));
            }
        }
        //System.out.println("All UNFunc : " + substList);
        Expr[] apps = varList.toArray(new Expr[varList.size()]);
        Expr[] sub = substList.toArray(new Expr[substList.size()]);
        BoolExpr equiv = ctx.mkEq(summary.summaryOld, summary.summaryNew);
        if (DEBUG) System.out.println("Before substition in Quantifiable : " + equiv.toString());
        Expr quantifiableExp = equiv.substitute(apps, sub);
        if (DEBUG) System.out.println("After substition Quantifiable : " + quantifiableExp.toString());
        /************add variables***********/
        substList.addAll(summary.variables.values());//add variables
        Expr[] vars = substList.toArray(new Expr[substList.size()]);
        //System.out.println("All Vars : " + Arrays.toString(vars));
        /************************************************************/
        for (String s : temp) {
            List<Expr> quantiferslist = new ArrayList<>();
            Expr[] target = new Expr[1];
            for (Expr e : vars) {//we add the variables
                if (!e.toString().contains(s))
                    quantiferslist.add(e);
                else
                    target[0] = e;
            }
            //System.out.println("All Vars except for the target: " + Arrays.toString(quantiferslist.toArray(new Expr[quantiferslist.size()])));
            /************add variables***********/
            BoolExpr forAll = ctx.mkForall(quantiferslist.toArray(new Expr[quantiferslist.size()]), quantifiableExp, 1, null, null, null, null);
            /**********************************************/
            //run from command
            List<Expr> targetList = new ArrayList<>();
            HashSet<Expr> instances2 = summary.functionsInstances.get(s).getValue(); //We need to get all the functions that will be substituted
            int j = 0;
            Iterator<Expr> it2 = instances2.iterator();
            while (it2.hasNext()) {
                Expr e = it2.next();
                targetList.add(ctx.mkConst(s + "_" + j, e.getSort()));//for substitution
                j++;
            }
            //System.out.println("after:" +forAll.toString());
            FileWriter fw = new FileWriter(this.path + "/H1Checking.smt2");
            BufferedWriter bw = new BufferedWriter(fw);
            //(declare-const UF_bess_1_0 Real) (assert + forall + ) (check-sat)
            /****************Get Type************/
            FuncDecl f = summary.functionsInstances.get(s).getKey();//usage?
            String type = f.toString();
            ArrayList<Integer> indexes = new ArrayList<Integer>();
            for (int index = type.indexOf(")"); index >= 0; index = type.indexOf(")", index + 1))
                indexes.add(index);
            type = type.substring(indexes.get(indexes.size()-2)+1);
            type = type.substring(0, type.indexOf(")"));
            /**************************************/
            for (int i = 0; i < targetList.size(); i++)
                bw.write("(declare-const " + targetList.get(i) + " "+type+" )" + '\n');//TODO change with the type.
            bw.write("(assert " + "\n");
            bw.write(forAll.toString());
            bw.write(") " + "\n");//end of assert
            bw.write("(check-sat)");
            bw.close();
            fw.close();
            String mainCommand = z3+" -smt2 " + this.path + "/H1Checking.smt2 -T:"+timeout/1000;
            if (debug) System.out.println(mainCommand);
            Process p = Runtime.getRuntime().exec(mainCommand);
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = null;
            String answer = in.readLine();
            if (debug) System.out.println(answer);
            /**********************************************/
            if (answer!= null && answer.equals("sat")) {
                if(debug) System.out.println("The possible refined function based on H1 is : " + s);
                functions.add(s);
            }
        }
    }

    /**
     * This function applies the second heuristic
     * It collects all the functions that appear only in one of the summaries
     * @param summary a summary of JPF+z3
     * @param functions a list of uninterpreted functions
     */
    public void heuristicH2(SMTSummary summary,ArrayList<String> functions){
        MapDifference<Expr, Integer> diff = Maps.difference(summary.uFunctionsOld, summary.uFunctionsNew);
        /*******************************/
        Set<Expr> left = diff.entriesOnlyOnLeft().keySet();
        Set<String> leftNames = new HashSet<>();
        left.forEach((expr) -> leftNames.add(expr.getFuncDecl().getName().toString()));
        ArrayList<String> tempLeft = getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, leftNames), true);
        for (String s : tempLeft) {
            if(debug) System.out.println("The refined function based on H2 is : " + s);
            functions.add(s);
        }/*******************************/
        Set<Expr> right = diff.entriesOnlyOnRight().keySet();
        Set<String> rightNames = new HashSet<>();
        right.forEach((expr) -> rightNames.add(expr.getFuncDecl().getName().toString()));
        ArrayList<String> tempRight = getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, rightNames), false);
        for (String s : tempRight) {
            if(debug) System.out.println("The refined function based on H2 is : " + s);
            functions.add(s);
        }/*******************************/
        Map<Expr, MapDifference.ValueDifference<Integer>> occurences = diff.entriesDiffering();
        Set<String> differing = new HashSet<>();
        occurences.keySet().forEach((expr) -> differing.add(expr.getFuncDecl().getName().toString()));
        ArrayList<String> tempDiff  = getOrderedFunctionsList(getRestrictedInstances(summary.functionsInstances, differing), true);
        for (String s : tempDiff) {
            if(debug) System.out.println("The refined function based on H2 is : " + s);
            functions.add(s);
        }
        /*******************************/
    }

    /***************************Helper functions *********************************/
    /**
     * This function creates the map from every uninterpreted function in the set, to its declaration and to all its applications
     * For example UF_val_1 --> Pair (define-fun UF_val Int Int) ; List {(UF_val_1 x); (UF_val_1 y)}
     * @param instances
     * @param set
     * @return
     */
    public Map<String,Pair<FuncDecl,HashSet<Expr>>> getRestrictedInstances(Map<String,Pair<FuncDecl,HashSet<Expr>>> instances, Set<String> set){
        //TODO must be changed for the new z3 parser parsing strings instead
        Map<String,Pair<FuncDecl,HashSet<Expr>>> results = new HashMap<>();
        for(String s : set){
            results.put(s,instances.get(s));
        }
        return results;
    }


    /**
     * This function fills the map object that describes the unintepreted functions inside an expression expr
     * @param expr a Z3 expression
     * @param map a map from a function name to the actual function declaration and all its ocurrences
     * @param occurences the list of occurences of each expression
     * @param procCalls a list of function calls
     */
    public void createInstances(Expr expr, Map<String, Pair<FuncDecl, HashSet<Expr>>> map, Map<Expr, Integer> occurences, HashSet<Expr> procCalls){
        if(expr.isApp()){
            FuncDecl func = expr.getFuncDecl();
            String funcName = func.getName().toString();
            Expr[] args = expr.getArgs();
            for(Expr arg : args){
                createInstances(arg,map,occurences, procCalls);
            }
            if(funcName.startsWith("UF_")){
                if(map.containsKey(funcName)){
                    map.get(funcName).getValue().add(expr);
                    Integer num = occurences.get(expr);
                    if(num !=null)
                        occurences.put(expr,num + 1);
                    else
                        occurences.put(expr,1);
                }
                else{
                    HashSet<Expr> set = new HashSet<>();
                    set.add(expr);
                    map.put(funcName,new Pair(func,set));
                    occurences.put(expr,1);
                }
            }
            else if(funcName.startsWith("AF_")){
                procCalls.add(expr);
            }
        }
    }


    /**
     *This is a helper function to obtain every statement mapped to a given uninterpreted function
     * The output is in the form Map : Line number --> Pair (variable, [Number of control statements, Number of non linear arithmetic, Is mixed ?]
     * 1 if mixed, 0 otherwise
     * @param func
     * @return
     */
    public Map<Integer,Pair<String,int[]>> getStatementsFromFunction(String func){
        Map<Integer,Pair<String,int[]>> statements = new HashMap<>();

        String[] temp = getInfoFromUFunc(func); //Example : func = UF_val_1
        Integer block_id = Integer.parseInt(temp[1]);//Here we obtain 1
        String name = temp[0];   //Here we obtain val

        //Here we get all the outputs for the lines contained in block 1 for program1 and program2
        Map<Integer,Pair<String,int[]>> blockInfoV1 = statementInfoPerBlock1.get(block_id);
        for(Integer line : blockInfoV1.keySet()) {
            //We have a pair (val, [number of control statements, number of non-linear arithmetic, is mixed ?]
            //Here you have access to the information you want with statementInfo.getValue();
            //We check that there is an output for this line (if the line is a declaration statement)
            Pair<String, int[]> statementInfo = blockInfoV1.get(line);
            if (statementInfo != null) {
                String val = statementInfo.getKey();
                if (val != null && val.equals(name))
                    statements.put(line, new Pair(val, statementInfo.getValue()));

            }
        }
        Map<Integer,Pair<String,int[]>> blockInfoV2 = statementInfoPerBlock2.get(block_id);
        for(Integer line : blockInfoV2.keySet()) {
            Pair<String, int[]> statementInfo = blockInfoV2.get(line);
            if (statementInfo != null) {
                String val = statementInfo.getKey();
                if (val != null && val.equals(name))
                    statements.put(line, new Pair(val, statementInfo.getValue()));

            }
        }
        return statements;
    }

    /**
     * This is the function where you expand the lines related to a given uninterpreted function (add the lines to the change set)
     * @param statement
     * @throws IOException
     * First we get the variable name from the uninterpreted function, then
     */
    public void expandFunction(String statement) throws IOException {
        changes.add(Integer.parseInt(statement));
        Collections.sort(changes);
        if(debug) System.out.println(changes);
    }



    /**
     * This is the function to obtain the block number and the variable name from the uninterpreted function
     * @param func
     * @return
     */
    public String[] getInfoFromUFunc(String func){
        int index = func.lastIndexOf("_");
        if(func.endsWith("*"))
            func = func.substring(0,func.length() - 1);
        String[] temp =  {func.substring(3, index), func.substring(index+1)};
        return temp;
    }


    /**
     * This function sorts the uninterpreted functions based on the order of appearance
     * The priority is given to the outermost functions, which are likely to not be the inputs of any other function
     * @param instances
     * @param old
     * @return
     */
    public ArrayList<String> getOrderedFunctionsList(Map<String,Pair<FuncDecl,HashSet<Expr>>> instances, boolean old){
        ArrayList<String> functions = getInputsOfSomeFunctionsList(instances,old);
        ArrayList<String> inputsOfNoFunctions = getInputsOfNoFunctionsList(functions,instances.keySet(),old);
        inputsOfNoFunctions.addAll(functions);
        return inputsOfNoFunctions;
    }

    /**
     * This function retrieves every function which is the input of some other uninterpreted function
     * @param instances
     * @param old
     * @return
     */
    public  ArrayList<String> getInputsOfSomeFunctionsList(Map<String,Pair<FuncDecl,HashSet<Expr>>> instances, boolean old){
        HashSet<String> inputsOfSomeFunction = new HashSet<>();
        for(String var : instances.keySet()){
            HashSet<Expr> application = instances.get(var).getValue();
            for(Expr expr : application) {
                Expr[] args = expr.getArgs();
                for(Expr arg : args) {
                    String name = arg.getFuncDecl().getName().toString();
                    if (name.startsWith("UF_"))
                        inputsOfSomeFunction.add(name);
                }
            }
        }
        return sortFunctionsByOrder(inputsOfSomeFunction,old);
    }

    /**
     * This function retrieves every function which is the input of no other function
     * @param inputsOfSomeFunctions
     * @param allFunctions
     * @param old whether we are considering the old or the new program
     * @return
     */
    public ArrayList<String> getInputsOfNoFunctionsList(ArrayList<String> inputsOfSomeFunctions, Set<String> allFunctions, boolean old){
        HashSet<String> inputsOfNoFunctions = new HashSet<>(allFunctions);
        inputsOfNoFunctions.removeAll(inputsOfSomeFunctions);
        return sortFunctionsByOrder(inputsOfNoFunctions,old);
    }

    /**
     * This function sorts the uninterpreted functions by reverse order of occurence in the program
     * @param functions the functions to sort
     * @param old if true it's the old program, otherwise the new program
     * @return the sorted list of the functions
     */
    public ArrayList<String> sortFunctionsByOrder(Set<String> functions, boolean old){
        if(DEBUG)System.out.println("Set : "+functions);
        ArrayList<LinkedHashMap<String, Pair<Boolean,HashSet<String>>>> blocks = (old)?blockResults:blockResults2;
        if(DEBUG)System.out.println("Blocks : "+blocks+"  "+blocks.size());
        ArrayList<String> orderedList = new ArrayList<>();
        for(int i = blocks.size();i > 0; i --) {
            Map<String, Pair<Boolean, HashSet<String>>> info = blocks.get(i - 1);
            ArrayList<String> outputs = new ArrayList<>();
            for (String var : info.keySet()) {
                outputs.add("UF_" + var + "_" + i);
            }
            for (int j = outputs.size() - 1; j >= 0; j--) {
                String func = outputs.get(j);
                if (functions.contains(func)) {
                    orderedList.add(func);
                }
                else if(functions.contains(func+"*"))
                    orderedList.add(func+"*");
            }
        }
        return orderedList;
    }

    /**
     * This function sorts the uninterpreted functions by increasing complexity score
     * @param hm a map from a function to a complexity score
     * @return the sorted map
     */
    public static HashMap<String, Integer> sortByValue(HashMap<String, Integer> hm){
        List<Map.Entry<String, Integer> > list =  new LinkedList<Map.Entry<String, Integer> >(hm.entrySet());
        Collections.sort(list, new Comparator<Map.Entry<String, Integer> >() {
            public int compare(Map.Entry<String, Integer> o1,
                               Map.Entry<String, Integer> o2) {
                return (o1.getValue()).compareTo(o2.getValue());
            }
        });
        HashMap<String, Integer> temp = new LinkedHashMap<String, Integer>();
        for (Map.Entry<String, Integer> aa : list) {
            temp.put(aa.getKey(), aa.getValue());
        }
        return temp;
    }

    /*******************Helpers*****************************************/



	public static void main(String[] args){
	    GradDiff gradDiff = new GradDiff();
        /******End ******/
        try {
            gradDiff.changes = new ChangeExtractor().obtainChanges(gradDiff.MethodPath1, gradDiff.MethodPath2,gradDiff.ranByUser,gradDiff.path);
            if(DEBUG)System.out.println(gradDiff.changes);
            long start = System.nanoTime();
            //int i =0;
            while(gradDiff.onGoing){
                //add a return somehow
                if(DEBUG)System.out.println(gradDiff.equivalenceResult(gradDiff.runEquivalenceChecking()));
            }
            long end = System.nanoTime() - start;
            if(DEBUG)System.out.println(end);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
