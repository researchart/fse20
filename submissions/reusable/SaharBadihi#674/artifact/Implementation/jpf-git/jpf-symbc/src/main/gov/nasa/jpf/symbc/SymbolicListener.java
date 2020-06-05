/*
 * Copyright (C) 2014, United States Government, as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All rights reserved.
 *
 * Symbolic Pathfinder (jpf-symbc) is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package gov.nasa.jpf.symbc;

import gov.nasa.jpf.Config;
import gov.nasa.jpf.JPF;
import gov.nasa.jpf.PropertyListenerAdapter;

import gov.nasa.jpf.vm.ChoiceGenerator;
import gov.nasa.jpf.vm.ClassInfo;
import gov.nasa.jpf.vm.Instruction;
import gov.nasa.jpf.vm.LocalVarInfo;
import gov.nasa.jpf.vm.MethodInfo;
import gov.nasa.jpf.vm.StackFrame;
import gov.nasa.jpf.vm.ThreadInfo;
import gov.nasa.jpf.vm.Types;
import gov.nasa.jpf.vm.AnnotationInfo;
import gov.nasa.jpf.vm.VM;

import gov.nasa.jpf.jvm.bytecode.EXECUTENATIVE;
import gov.nasa.jpf.jvm.bytecode.ARETURN;
import gov.nasa.jpf.jvm.bytecode.DRETURN;
import gov.nasa.jpf.jvm.bytecode.FRETURN;
import gov.nasa.jpf.jvm.bytecode.IRETURN;
import gov.nasa.jpf.jvm.bytecode.LRETURN;
import gov.nasa.jpf.symbc.bytecode.BytecodeUtils;
import gov.nasa.jpf.symbc.bytecode.INVOKESTATIC;
import gov.nasa.jpf.jvm.bytecode.JVMInvokeInstruction;
import gov.nasa.jpf.jvm.bytecode.JVMReturnInstruction;
import gov.nasa.jpf.jvm.bytecode.IfInstruction;
import gov.nasa.jpf.jvm.bytecode.GOTO;

import gov.nasa.jpf.report.ConsolePublisher;
import gov.nasa.jpf.report.Publisher;
import gov.nasa.jpf.report.PublisherExtension;
import gov.nasa.jpf.search.Search;
import gov.nasa.jpf.symbc.bytecode.BytecodeUtils;
import gov.nasa.jpf.symbc.bytecode.INVOKESTATIC;
import gov.nasa.jpf.symbc.concolic.PCAnalyzer;

import gov.nasa.jpf.symbc.numeric.Comparator;
import gov.nasa.jpf.symbc.numeric.Expression;
import gov.nasa.jpf.symbc.numeric.IntegerConstant;
import gov.nasa.jpf.symbc.numeric.IntegerExpression;
import gov.nasa.jpf.symbc.numeric.PCChoiceGenerator;
import gov.nasa.jpf.symbc.numeric.Expression;
import gov.nasa.jpf.symbc.numeric.PathCondition;
import gov.nasa.jpf.symbc.numeric.RealConstant;
import gov.nasa.jpf.symbc.numeric.RealExpression;
import gov.nasa.jpf.symbc.numeric.SymbolicInteger;
import gov.nasa.jpf.symbc.numeric.SymbolicReal;
import gov.nasa.jpf.symbc.numeric.SymbolicFunction;
import gov.nasa.jpf.symbc.numeric.SymbolicIntFunction;
import gov.nasa.jpf.symbc.numeric.SymbolicRealFunction;
import gov.nasa.jpf.symbc.numeric.PathCondition;
import gov.nasa.jpf.symbc.numeric.SymbolicConstraintsGeneral;

import gov.nasa.jpf.util.Pair;
import gov.nasa.jpf.listener.IdleFilter;

import java.io.PrintWriter;
import java.util.*;

public class SymbolicListener extends PropertyListenerAdapter implements PublisherExtension {

    /*
     * Locals to preserve the value that was held by JPF prior to changing it in order to turn off state matching during
     * symbolic execution no longer necessary because we run spf stateless
     */

    protected Map<String, MethodSummary> allSummaries;
    protected String currentMethodName = "";
    protected String methodToAnalyze ="";
    protected int maxJumps = 0;
    protected int backJumps = 0;
    protected HashSet<Integer> loopStatements = new HashSet<>();
    Object resultAttr;
    Pair<String, String> pcPair = null;
    String returnString = "";
    Expression result = null;

    public SymbolicListener(Config conf, JPF jpf) {
        jpf.addPublisherExtension(ConsolePublisher.class, this);
        allSummaries = new HashMap<String, MethodSummary>();
        methodToAnalyze=conf.getString("symbolic.method","").split("\\(")[0];
    }

    // Writes the method summaries to a file for use in another application
    // private void writeTable(){
    // try {
    // BufferedWriter out = new BufferedWriter(new FileWriter("outFile.txt"));
    // Iterator it = allSummaries.entrySet().iterator();
    // String line = "";
    // while (it.hasNext()){
    // Map.Entry me = (Map.Entry)it.next();
    // String methodName = (String)me.getKey();
    // MethodSummary ms = (MethodSummary)me.getValue();
    // line = "METHOD: " + methodName + "," +
    // ms.getMethodName() + "(" + ms.getArgValues() + ")," +
    // ms.getMethodName() + "(" + ms.getSymValues() + ")";
    // out.write(line);
    // out.newLine();
    // Vector<Pair> pathConditions = ms.getPathConditions();
    // if (pathConditions.size() > 0){
    // Iterator it2 = pathConditions.iterator();
    // while(it2.hasNext()){
    // Pair pcPair = (Pair)it2.next();
    // String pc = (String)pcPair.a;
    // String errorMessage = (String)pcPair.b;
    // line = pc;
    // if (!errorMessage.equalsIgnoreCase(""))
    // line = line + "$" + errorMessage;
    // out.write(line);
    // out.newLine();
    // }
    // }
    // }
    // out.close();
    // } catch (Exception e) {
    // }
    // }

    @Override
    public void propertyViolated(Search search) {

        VM vm = search.getVM();

        ChoiceGenerator<?> cg = vm.getChoiceGenerator();
        if (!(cg instanceof PCChoiceGenerator)) {
            ChoiceGenerator<?> prev_cg = cg.getPreviousChoiceGenerator();
            while (!((prev_cg == null) || (prev_cg instanceof PCChoiceGenerator))) {
                prev_cg = prev_cg.getPreviousChoiceGenerator();
            }
            cg = prev_cg;
        }
        if ((cg instanceof PCChoiceGenerator) && ((PCChoiceGenerator) cg).getCurrentPC() != null) {
            PathCondition pc = ((PCChoiceGenerator) cg).getCurrentPC();
            String error = search.getLastError().getDetails();
            error = "\"" + error.substring(0, error.indexOf("\n")) + "...\"";
            // C: not clear where result was used here -- to review
            // PathCondition result = new PathCondition();
            // IntegerExpression sym_err = new SymbolicInteger("ERROR");
            // IntegerExpression sym_value = new SymbolicInteger(error);
            // result._addDet(Comparator.EQ, sym_err, sym_value);
            // solve the path condition, then print it
            // pc.solve();
            if (SymbolicInstructionFactory.concolicMode) { // TODO: cleaner
                SymbolicConstraintsGeneral solver = new SymbolicConstraintsGeneral();
                PCAnalyzer pa = new PCAnalyzer();
                pa.solve(pc, solver);
            } else
                pc.solve();

            Pair<String, String> pcPair = new Pair<String, String>(pc.toString(), error);// (pc.toString(),error);

            // String methodName = vm.getLastInstruction().getMethodInfo().getName();
            MethodSummary methodSummary = allSummaries.get(currentMethodName);
            if (methodSummary == null)
                methodSummary = new MethodSummary();
            methodSummary.addPathCondition(pcPair);
            allSummaries.put(currentMethodName, methodSummary);
            System.out.println("Property Violated: PC is " + pc.toString());
            System.out.println("Property Violated: result is  " + error);
            System.out.println("****************************");
        }
        // }
    }

    @Override
    public void stateAdvanced(Search search) {
        super.stateAdvanced(search);
        ChoiceGenerator<?> cg = search.getVM().getChoiceGenerator();
        // ChoiceGenerator<?> cg = vm.getChoiceGenerator();
        if (!(cg instanceof PCChoiceGenerator)) {
            ChoiceGenerator<?> prev_cg = cg.getPreviousChoiceGenerator();
            while (!((prev_cg == null) || (prev_cg instanceof PCChoiceGenerator))) {
                prev_cg = prev_cg.getPreviousChoiceGenerator();
            }
            cg = prev_cg;
        }
        if ((cg instanceof PCChoiceGenerator) && ((PCChoiceGenerator) cg).getCurrentPC() != null) {
            PathCondition pc = ((PCChoiceGenerator) cg).getCurrentPC();
            if(pc!= null && pc.header!= null) {
                int topLineNumber = pc.header.getLineNumber();
                if (!loopStatements.contains(topLineNumber)) {
                    search.setDepth(search.getDepth() - 1);
                }
            }
            else{
                search.setDepth(search.getDepth() - 1);
            }
            //Here we want to check if the top one is related to a loop or not
            //Keep a list of line numbers related to loops and check if in there otherwise decrease the depth
        }
        else{
            search.setDepth(search.getDepth() - 1);
        }
        if(search.getDepth() < 0){
            search.setDepth(0);
        }
    }

    @Override
    public void stateBacktracked(Search search) {
        super.stateBacktracked(search);
        ChoiceGenerator<?> cg = search.getVM().getChoiceGenerator();
        // ChoiceGenerator<?> cg = vm.getChoiceGenerator();
        if (!(cg instanceof PCChoiceGenerator)) {
            ChoiceGenerator<?> prev_cg = cg.getPreviousChoiceGenerator();
            while (!((prev_cg == null) || (prev_cg instanceof PCChoiceGenerator))) {
                prev_cg = prev_cg.getPreviousChoiceGenerator();
            }
            cg = prev_cg;
        }
        if ((cg instanceof PCChoiceGenerator) && ((PCChoiceGenerator) cg).getCurrentPC() != null) {
            PathCondition pc = ((PCChoiceGenerator) cg).getCurrentPC();
            if(pc!= null && pc.header!=null) {
                int topLineNumber = pc.header.getLineNumber();
                if (!loopStatements.contains(topLineNumber)) {
                    search.setDepth(search.getDepth() + 1);
                }
            }
            else{
                search.setDepth(search.getDepth() - 1);
            }
        }
        else{
            search.setDepth(search.getDepth() + 1);
        }
        if(search.getDepth() < 0){
            search.setDepth(0);
        }
    }


    @Override
    public void instructionExecuted(VM vm, ThreadInfo currentThread, Instruction nextInstruction,
                                    Instruction executedInstruction) {

        if (!vm.getSystemState().isIgnored()) {

            Instruction insn = executedInstruction;
            // SystemState ss = vm.getSystemState();
            ThreadInfo ti = currentThread;
            Config conf = vm.getConfig();
            //Here I want to take any condition
            if(!currentMethodName.isEmpty()) {
                String name = currentMethodName.split("\\(")[0];
                if (insn.isBackJump() && methodToAnalyze.endsWith(name)) {
                    Instruction dest = null;
                    if (insn instanceof GOTO) {
                        GOTO expr = (GOTO) insn;
                        dest = expr.getTarget();
                    } else if (insn instanceof IfInstruction) {
                        //for a do-while I guess
                        IfInstruction expr = (IfInstruction) insn;
                        dest = insn;
                    }
                    if (dest != null) {
                        int lineNumber = dest.getLineNumber();
                        loopStatements.add(dest.getLineNumber());
                    }
                }
            }
            if (insn instanceof JVMInvokeInstruction) {
                JVMInvokeInstruction md = (JVMInvokeInstruction) insn;
                MethodInfo mi = md.getInvokedMethod();
                String name = mi.getName();
                //boolean foundAnote = false;
                boolean foundAnote = checkUnInterpretedAnnotation(mi);
                if (foundAnote) {
                    StackFrame sf = ti.popAndGetModifiableTopFrame();
                    SymbolicFunction result =
                            generateFunctionExpression(mi, md, currentThread);
                    checkReturnType(ti, mi, result);
                    // PathCondition.flagSolved = true;
                    Instruction nextIns = sf.getPC().getNext();
                    vm.getCurrentThread().skipInstruction(nextIns);
                } else {
                    String methodName = md.getInvokedMethodName();
                    int numberOfArgs = md.getArgumentValues(ti).length;
                    ClassInfo ci = mi.getClassInfo();
                    String className = ci.getName();

                    StackFrame sf = ti.getTopFrame();
                    String shortName = methodName;
                    String longName = mi.getLongName();
                    if (methodName.contains("("))
                        shortName = methodName.substring(0, methodName.indexOf("("));

                    if (!mi.equals(sf.getMethodInfo()))
                        return;

                    if ((BytecodeUtils.isClassSymbolic(conf, className, mi, methodName))
                            || BytecodeUtils.isMethodSymbolic(conf, mi.getFullName(), numberOfArgs, null)) {

                        MethodSummary methodSummary = new MethodSummary();

                        methodSummary.setMethodName(className + "." + shortName);
                        Object[] argValues = md.getArgumentValues(ti);
                        String argValuesStr = "";
                        for (int i = 0; i < argValues.length; i++) {
                            argValuesStr = argValuesStr + argValues[i];
                            if ((i + 1) < argValues.length)
                                argValuesStr = argValuesStr + ",";
                        }
                        methodSummary.setArgValues(argValuesStr);
                        byte[] argTypes = mi.getArgumentTypes();
                        String argTypesStr = "";
                        for (int i = 0; i < argTypes.length; i++) {
                            argTypesStr = argTypesStr + argTypes[i];
                            if ((i + 1) < argTypes.length)
                                argTypesStr = argTypesStr + ",";
                        }
                        methodSummary.setArgTypes(argTypesStr);

                        // get the symbolic values (changed from constructing them here)
                        String symValuesStr = "";
                        String symVarNameStr = "";

                        LocalVarInfo[] argsInfo = mi.getArgumentLocalVars();

                        if (argsInfo == null)
                            throw new RuntimeException("ERROR: you need to turn debug option on");

                        int sfIndex = 1; // do not consider implicit param "this"
                        int namesIndex = 1;
                        if (md instanceof INVOKESTATIC) {
                            sfIndex = 0; // no "this" for static
                            namesIndex = 0;
                        }

                        for (int i = 0; i < numberOfArgs; i++) {
                            Expression expLocal = (Expression) sf.getLocalAttr(sfIndex);
                            if (expLocal != null) // symbolic
                                symVarNameStr = expLocal.toString();
                            else
                                symVarNameStr = argsInfo[namesIndex].getName() + "_CONCRETE" + ",";
                            // TODO: what happens if the argument is an array?
                            symValuesStr = symValuesStr + symVarNameStr + ",";
                            sfIndex++;
                            namesIndex++;
                            if (argTypes[i] == Types.T_LONG || argTypes[i] == Types.T_DOUBLE)
                                sfIndex++;

                        }

                        // get rid of last ","
                        if (symValuesStr.endsWith(",")) {
                            symValuesStr = symValuesStr.substring(0, symValuesStr.length() - 1);
                        }
                        methodSummary.setSymValues(symValuesStr);

                        currentMethodName = longName;
                        allSummaries.put(longName, methodSummary);
                    }
                }
            } else if (insn instanceof JVMReturnInstruction) {
                MethodInfo mi = insn.getMethodInfo();
                ClassInfo ci = mi.getClassInfo();
                String returnType = mi.getReturnTypeName().toUpperCase();
                if (returnType.equals("DOUBLE") || returnType.equals("FLOAT")) returnType = "REAL";
                if (null != ci) {
                    String className = ci.getName();
                    String methodName = mi.getName();
                    String longName = mi.getLongName();
                    int numberOfArgs = mi.getNumberOfArguments();

                    if (((BytecodeUtils.isClassSymbolic(conf, className, mi, methodName))
                            || BytecodeUtils.isMethodSymbolic(conf, mi.getFullName(), numberOfArgs, null))) {
                        ChoiceGenerator<?> cg = vm.getChoiceGenerator();
                        if (!(cg instanceof PCChoiceGenerator)) {
                            ChoiceGenerator<?> prev_cg = cg.getPreviousChoiceGenerator();
                            while (!((prev_cg == null) || (prev_cg instanceof PCChoiceGenerator))) {
                                prev_cg = prev_cg.getPreviousChoiceGenerator();
                            }
                            cg = prev_cg;
                        }
                        if ((cg instanceof PCChoiceGenerator) && ((PCChoiceGenerator) cg).getCurrentPC() != null) {
                            PathCondition pc = ((PCChoiceGenerator) cg).getCurrentPC();
                            // pc.solve(); //we only solve the pc
                            if (SymbolicInstructionFactory.concolicMode) { // TODO: cleaner
                                SymbolicConstraintsGeneral solver = new SymbolicConstraintsGeneral();
                                PCAnalyzer pa = new PCAnalyzer();
                                pa.solve(pc, solver);
                            } else
                                pc.solve();

                            if (!PathCondition.flagSolved) {
                                return;
                            }
                            handleReturnType(insn, ti);

                            // after the following statement is executed, the pc loses its solution

                            String pcString = pc.toString();
                            pcPair = new Pair<String, String>(pcString, returnString);
                            MethodSummary methodSummary = allSummaries.get(longName);
                            Vector<Pair> pcs = methodSummary.getPathConditions();
                            if ((!pcs.contains(pcPair)) &&
                                    (pcString.contains("SYM"))) {
                                methodSummary.addPathCondition(pcPair);
                            }

                            if (allSummaries.get(longName) != null) // recursive call longName = longName +
                                methodSummary.hashCode(); // differentiate the key for recursive calls
                            allSummaries.put(longName, methodSummary);
                            System.out.println("*************Summary***************");
                            //System.out.println("PC is:" + pc.toString()); //old pccd ../
                            String newpcString = pc.toString();
                            newpcString = newpcString.replace("%NonLinInteger% ", "");
                            System.out.println("PC is:" + newpcString);
                            if (result != null) {
                                System.out.println(insn.getLineNumber() + ": " + "Ret_0_SYM" + returnType + " = " + result);
                                System.out.println("***********************************");
                            }
                        }
                        else {
                            handleReturnType(insn, ti);
                            System.out.println("*************Summary***************");
                            if (result != null) {
                                System.out.println(insn.getLineNumber() + ": " + "Ret_0_SYM" + returnType + " = " + result);
                                System.out.println("***********************************");
                            }
                        }
                        // YN
                    }
                }
            }
        }
    }

    public void handleReturnType(Instruction insn,ThreadInfo ti) {
        if (insn instanceof IRETURN) {
            IRETURN ireturn = (IRETURN) insn;
            int returnValue = ireturn.getReturnValue();
            IntegerExpression returnAttr = (IntegerExpression) ireturn.getReturnAttr(ti);
            if (returnAttr != null) {
                returnString = "Return Value: " + String.valueOf(returnAttr.solution());
                result = returnAttr;
            } else { // concrete
                returnString = "Return Value: " + String.valueOf(returnValue);
                result = new IntegerConstant(returnValue);
            }
        } else if (insn instanceof LRETURN) {
            LRETURN lreturn = (LRETURN) insn;
            long returnValue = lreturn.getReturnValue();
            IntegerExpression returnAttr = (IntegerExpression) lreturn.getReturnAttr(ti);
            if (returnAttr != null) {
                returnString = "Return Value: " + String.valueOf(returnAttr.solution());
                result = returnAttr;
            } else { // concrete
                returnString = "Return Value: " + String.valueOf(returnValue);
                result = new IntegerConstant((int) returnValue);
            }
        } else if (insn instanceof DRETURN) {
            DRETURN dreturn = (DRETURN) insn;
            double returnValue = dreturn.getReturnValue();
            RealExpression returnAttr = (RealExpression) dreturn.getReturnAttr(ti);
            if (returnAttr != null) {
                returnString = "Return Value: " + String.valueOf(returnAttr.solution());
                result = returnAttr;
            } else { // concrete
                returnString = "Return Value: " + String.valueOf(returnValue);
                result = new RealConstant(returnValue);
            }
        } else if (insn instanceof FRETURN) {

            FRETURN freturn = (FRETURN) insn;
            double returnValue = freturn.getReturnValue();
            RealExpression returnAttr = (RealExpression) freturn.getReturnAttr(ti);
            if (returnAttr != null) {
                returnString = "Return Value: " + String.valueOf(returnAttr.solution());
                result = returnAttr;
            } else { // concrete
                returnString = "Return Value: " + String.valueOf(returnValue);
                result = new RealConstant(returnValue);
            }

        } else if (insn instanceof ARETURN) {
            ARETURN areturn = (ARETURN) insn;
            IntegerExpression returnAttr = (IntegerExpression) areturn.getReturnAttr(ti);
            if (returnAttr != null) {
                returnString = "Return Value: " + String.valueOf(returnAttr.solution());
                result = returnAttr;
            } else {// concrete
                Object val = areturn.getReturnValue(ti);
                returnString = "Return Value: " + String.valueOf(val);
                // DynamicElementInfo val = (DynamicElementInfo)areturn.getReturnValue(ti);
                String tmp = String.valueOf(val);
                tmp = tmp.substring(tmp.lastIndexOf('.') + 1);
                result = new SymbolicInteger(tmp);

            }
        } else // other types of return
            returnString = "Return Value: --";
        System.out.println("Return String "+returnString);
        // pc.solve();
        // not clear why this part is necessary
        /*
         * if (SymbolicInstructionFactory.concolicMode) { //TODO: cleaner SymbolicConstraintsGeneral
         * solver = new SymbolicConstraintsGeneral(); PCAnalyzer pa = new PCAnalyzer();
         * pa.solve(pc,solver); } else pc.solve();
         */

    }

    /*
     * The way this method works is specific to the format of the methodSummary data structure
     */

    // TODO: needs to be changed not to use String representations
    protected void printMethodSummary(PrintWriter pw, MethodSummary methodSummary) {

        System.out.println("Inputs: " + methodSummary.getSymValues());
        Vector<Pair> pathConditions = methodSummary.getPathConditions();
        if (pathConditions.size() > 0) {
            Iterator it = pathConditions.iterator();
            String allTestCases = "";
            while (it.hasNext()) {
                String testCase = methodSummary.getMethodName() + "(";
                Pair pcPair = (Pair) it.next();
                String pc = (String) pcPair._1;
                String errorMessage = (String) pcPair._2;
                String symValues = methodSummary.getSymValues();
                String argValues = methodSummary.getArgValues();
                String argTypes = methodSummary.getArgTypes();

                StringTokenizer st = new StringTokenizer(symValues, ",");
                StringTokenizer st2 = new StringTokenizer(argValues, ",");
                StringTokenizer st3 = new StringTokenizer(argTypes, ",");
                if (!argTypes.isEmpty() && argValues.isEmpty()) {
                    continue;
                }
                while (st2.hasMoreTokens()) {
                    String token = "";
                    String actualValue = st2.nextToken();
                    byte actualType = Byte.parseByte(st3.nextToken());
                    if (st.hasMoreTokens())
                        token = st.nextToken();
                    if (pc.contains(token)) {
                        String temp = pc.substring(pc.indexOf(token));
                        if (temp.indexOf(']') < 0) {
                            continue;
                        }

                        String val = temp.substring(temp.indexOf("[") + 1, temp.indexOf("]"));

                        // if(actualType == Types.T_INT || actualType == Types.T_FLOAT || actualType == Types.T_LONG ||
                        // actualType == Types.T_DOUBLE)
                        // testCase = testCase + val + ",";
                        if (actualType == Types.T_INT || actualType == Types.T_FLOAT || actualType == Types.T_LONG
                                || actualType == Types.T_SHORT || actualType == Types.T_BYTE
                                || actualType == Types.T_CHAR || actualType == Types.T_DOUBLE) {
                            String suffix = "";
                            if (actualType == Types.T_LONG) {
                                suffix = "l";
                            } else if (actualType == Types.T_FLOAT) {
                                val = String.valueOf(Double.valueOf(val).floatValue());
                                suffix = "f";
                            }
                            if (val.endsWith("Infinity")) {
                                boolean isNegative = val.startsWith("-");
                                val = ((actualType == Types.T_DOUBLE) ? "Double" : "Float");
                                val += isNegative ? ".NEGATIVE_INFINITY" : ".POSITIVE_INFINITY";
                                suffix = "";
                            }
                            testCase = testCase + val + suffix + ",";
                        } else if (actualType == Types.T_BOOLEAN) { // translate boolean values represented as ints
                            // to "true" or "false"
                            if (val.equalsIgnoreCase("0"))
                                testCase = testCase + "false" + ",";
                            else
                                testCase = testCase + "true" + ",";
                        } else if (actualType == Types.T_ARRAY) {
                            //suffix = "a";
                            // val = String.valueOf(Arra)
                            // TODO: to extend with arrays
                        }
                    }else {
                        // need to check if value is concrete
                        if (token.contains("CONCRETE"))
                            testCase = testCase + actualValue + ",";
                        else
                            testCase = testCase + SymbolicInteger.UNDEFINED + "(don't care),";// not correct in concolic
                        // mode
                    }
                }
                if (testCase.endsWith(","))
                    testCase = testCase.substring(0, testCase.length() - 1);
                testCase = testCase + ")";
                // process global information and append it to the output

                if (!errorMessage.equalsIgnoreCase(""))
                    testCase = testCase + "  --> " + errorMessage;
                // do not add duplicate test case
                if (!allTestCases.contains(testCase))
                    allTestCases = allTestCases + "\n" + testCase;
            }
            pw.println(allTestCases);
        } else {
            pw.println("No path conditions for " + methodSummary.getMethodName() + "(" + methodSummary.getArgValues()
                    + ")");
        }
    }

    protected void printMethodSummaryHTML(PrintWriter pw, MethodSummary methodSummary) {
        pw.println("<h1>Test Cases Generated by Symbolic JavaPath Finder for " + methodSummary.getMethodName()
                + " (Path Coverage) </h1>");

        Vector<Pair> pathConditions = methodSummary.getPathConditions();
        if (pathConditions.size() > 0) {
            Iterator it = pathConditions.iterator();
            String allTestCases = "";
            String symValues = methodSummary.getSymValues();
            StringTokenizer st = new StringTokenizer(symValues, ",");
            while (st.hasMoreTokens())
                allTestCases = allTestCases + "<td>" + st.nextToken() + "</td>";
            allTestCases = "<tr>" + allTestCases + "<td>RETURN</td></tr>\n";
            while (it.hasNext()) {
                String testCase = "<tr>";
                Pair pcPair = (Pair) it.next();
                String pc = (String) pcPair._1;
                String errorMessage = (String) pcPair._2;
                // String symValues = methodSummary.getSymValues();
                String argValues = methodSummary.getArgValues();
                String argTypes = methodSummary.getArgTypes();
                // StringTokenizer
                st = new StringTokenizer(symValues, ",");
                StringTokenizer st2 = new StringTokenizer(argValues, ",");
                StringTokenizer st3 = new StringTokenizer(argTypes, ",");
                while (st2.hasMoreTokens()) {
                    String token = "";
                    String actualValue = st2.nextToken();
                    byte actualType = Byte.parseByte(st3.nextToken());
                    if (st.hasMoreTokens())
                        token = st.nextToken();
                    if (pc.contains(token)) {
                        String temp = pc.substring(pc.indexOf(token));
                        if (temp.indexOf(']') < 0) {
                            continue;
                        }

                        String val = temp.substring(temp.indexOf("[") + 1, temp.indexOf("]"));
                        if (actualType == Types.T_INT || actualType == Types.T_FLOAT || actualType == Types.T_LONG
                                || actualType == Types.T_SHORT || actualType == Types.T_BYTE
                                || actualType == Types.T_DOUBLE)
                            testCase = testCase + "<td>" + val + "</td>";
                        else if (actualType == Types.T_BOOLEAN) { // translate boolean values represented as ints
                            // to "true" or "false"
                            if (val.equalsIgnoreCase("0"))
                                testCase = testCase + "<td>false</td>";
                            else
                                testCase = testCase + "<td>true</td>";
                        } else
                            throw new RuntimeException(
                                    "## Error: listener does not support type other than int, long, short, byte, float, double and boolean");

                    } else {
                        // need to check if value is concrete
                        if (token.contains("CONCRETE"))
                            testCase = testCase + "<td>" + actualValue + "</td>";
                        else
                            testCase = testCase + "<td>" + SymbolicInteger.UNDEFINED + "(don't care)</td>"; // not
                        // correct
                        // in
                        // concolic
                        // mode
                    }
                }

                // testCase = testCase + "</tr>";
                // process global information and append it to the output

                if (!errorMessage.equalsIgnoreCase(""))
                    testCase = testCase + "<td>" + errorMessage + "</td>";
                // do not add duplicate test case
                if (!allTestCases.contains(testCase))
                    allTestCases = allTestCases + testCase + "</tr>\n";
            }
            pw.println("<table border=1>");
            pw.print(allTestCases);
            pw.println("</table>");
        } else {
            pw.println("No path conditions for " + methodSummary.getMethodName() + "(" + methodSummary.getArgValues()
                    + ")");
        }

    }

    // -------- the publisher interface
    @Override
    public void publishFinished(Publisher publisher) {
        String[] dp = SymbolicInstructionFactory.dp;
        if (dp[0].equalsIgnoreCase("no_solver") || dp[0].equalsIgnoreCase("cvc3bitvec"))
            return;

        PrintWriter pw = publisher.getOut();

        publisher.publishTopicStart("Method Summaries");
        Iterator it = allSummaries.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry me = (Map.Entry) it.next();
            MethodSummary methodSummary = (MethodSummary) me.getValue();
            printMethodSummary(pw, methodSummary);
        }

        publisher.publishTopicStart("Method Summaries (HTML)");
        it = allSummaries.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry me = (Map.Entry) it.next();
            MethodSummary methodSummary = (MethodSummary) me.getValue();
            printMethodSummaryHTML(pw, methodSummary);
        }
    }

    protected class MethodSummary {
        private String methodName = "";
        private String argTypes = "";
        private String argValues = "";
        private String symValues = "";
        private Vector<Pair> pathConditions;

        public MethodSummary() {
            pathConditions = new Vector<Pair>();
        }

        public void setMethodName(String mName) {
            this.methodName = mName;
        }

        public String getMethodName() {
            return this.methodName;
        }

        public void setArgTypes(String args) {
            this.argTypes = args;
        }

        public String getArgTypes() {
            return this.argTypes;
        }

        public void setArgValues(String vals) {
            this.argValues = vals;
        }

        public String getArgValues() {
            return this.argValues;
        }

        public void setSymValues(String sym) {
            this.symValues = sym;
        }

        public String getSymValues() {
            return this.symValues;
        }

        public void addPathCondition(Pair pc) {
            pathConditions.add(pc);
        }

        public Vector<Pair> getPathConditions() {
            return this.pathConditions;
        }

    }

    private boolean checkUnInterpretedAnnotation(MethodInfo mi) {
        AnnotationInfo[] ai = mi.getAnnotations();
        if (ai == null || ai.length == 0) return false;
        for (int aIndex = 0; aIndex < ai.length; aIndex++) {
            AnnotationInfo annotation = ai[aIndex];
            if (annotation.getName().equals
                    ("equiv.checking.symbex.UnInterpreted")) {
                //System.out.println("The annotation was found !");
                return true;

            }
        }
        return false;
    }

    private SymbolicFunction generateFunctionExpression(MethodInfo mi,
                                                        JVMInvokeInstruction ivk, ThreadInfo ti) {
        Object[] attrs = ivk.getArgumentAttrs(ti);
        Object[] values = ivk.getArgumentValues(ti);
        String[] types = mi.getArgumentTypeNames();
        assert (attrs != null);

        assert (attrs.length == values.length &&
                values.length == types.length);
        if(attrs == null)
            attrs = new Object[0];
        int size = attrs.length;
        Class<?>[] args_type = new Class<?>[size];
        Expression[] sym_args = new Expression[size];

        Map<String, Expression> expressionMap =
                new HashMap<String, Expression>();
        LocalVarInfo[] localVars = mi.getLocalVars();
        for (int argIndex = 0; argIndex < size; argIndex++) {
            Object attribute = attrs[argIndex];
            //The object has no attributes, so it is a constant (int double boolean, so on)
            if (attribute == null) {
                sym_args[argIndex] = this.generateConstant(
                        types[argIndex],
                        values[argIndex]);
            } else {
                sym_args[argIndex] = (Expression) attribute;
                if (localVars.length > argIndex)
                    expressionMap.put(localVars[argIndex].getName(),
                            sym_args[argIndex]);


            }
            args_type[argIndex] = checkArgumentTypes(types[argIndex]);
        }
        ArrayList<PathCondition> conditions = null;
        String retTypeName = mi.getReturnTypeName();
        if (retTypeName.equals("int") || retTypeName.equals("short") || retTypeName.equals("boolean") || retTypeName.equals("long")) {
            return new SymbolicIntFunction(
                    mi.getClassName(), mi.getName(), args_type, sym_args, conditions);
        }
        if (retTypeName.equals("double") || retTypeName.equals("float")) {
            return new SymbolicRealFunction(
                    mi.getClassName(), mi.getName(), args_type, sym_args, conditions);
        }
        //if()
        else {
            return null;
            //strings ? arrays ?
        }
    }


    private void checkReturnType(ThreadInfo ti, MethodInfo mi, SymbolicFunction resultAttr) {
        String retTypeName = mi.getReturnTypeName();
        StackFrame sf = ti.getModifiableTopFrame();
        sf.removeArguments(mi);
        if (retTypeName.equals("double") || retTypeName.equals("long")) {
            sf.pushLong(1);
            sf.setLongOperandAttr(resultAttr);
        } else {
            sf.push(1);
            sf.setOperandAttr(resultAttr);
        }
    }


    private Class<?> checkArgumentTypes(String typeVal) {
        if (typeVal.equals("int")) {
            return Integer.TYPE;
        } else if (typeVal.equals("double")) {
            return Double.TYPE;
        } else if (typeVal.equals("float")) {
            return Float.TYPE;
        } else if (typeVal.equals("long")) {
            return Long.TYPE;
        } else if (typeVal.equals("short")) {
            return Short.TYPE;
        } else if (typeVal.equals("boolean")) {
            return Boolean.TYPE;
        } else {
            throw new RuntimeException("the type not handled :" + typeVal);
        }
    }

    private Expression generateConstant(String typeVal, Object value) {
        if (typeVal.equals("int")) {
            return new IntegerConstant(Integer.parseInt
                    (value.toString()));
        } else if (typeVal.equals("double")) {
            return new RealConstant(Double.parseDouble
                    (value.toString()));
        } else if (typeVal.equals("float")) {
            return new RealConstant(Float.parseFloat
                    (value.toString()));
        } else if (typeVal.equals("long")) {
            return new IntegerConstant((int) Long.parseLong
                    (value.toString()));
        } else if (typeVal.equals("short")) {
            return new IntegerConstant((int) Short.parseShort
                    (value.toString()));
        } else if (typeVal.equals("boolean")) {
            if (value.toString().equals("true")) {
                return new IntegerConstant(1);
            } else {
                return new IntegerConstant(0);
            }
        } else {
            throw new RuntimeException("the type not handled :" + typeVal);
        }
    }
}