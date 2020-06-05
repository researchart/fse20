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
import gov.nasa.jpf.symbc.numeric.MinMax;

import gov.nasa.jpf.util.Pair;
import gov.nasa.jpf.listener.IdleFilter;

import java.io.PrintWriter;
import java.util.*;

public class BoundedSymbolicListener extends SymbolicListener implements PublisherExtension {

    /*
     * Locals to preserve the value that was held by JPF prior to changing it in order to turn off state matching during
     * symbolic execution no longer necessary because we run spf stateless
     */

    protected String methodToAnalyze ="";
    protected int maxJumps = 0;
    protected PathCondition pcRightAfterBackJump = null;
    protected Map<Instruction,Pair<Integer,Boolean>> backJumps = new HashMap<>();
    Object resultAttr;
    Pair<String, String> pcPair = null;
    String returnString = "";
    Expression result = null;


    public BoundedSymbolicListener(Config conf, JPF jpf) {
        //Here do something to distinguished between already bounded and unbounded loop
        super(conf,jpf);
        maxJumps = conf.getInt("symbolic.loop_bound", 5);
        methodToAnalyze=conf.getString("symbolic.method","").split("\\(")[0];
    }

    @Override
    public void instructionExecuted(VM vm, ThreadInfo currentThread, Instruction nextInstruction,
                                    Instruction executedInstruction) {

        if (!vm.getSystemState().isIgnored()) {
            Instruction insn = executedInstruction;
            //System.out.println("Instruction: "+insn.getLineNumber()+"  "+insn);
            // SystemState ss = vm.getSystemState();
            ThreadInfo ti = currentThread;
            Config conf = vm.getConfig();
            //Added from IdleFilter
            if(!currentMethodName.isEmpty()){
              //  System.out.println(methodToAnalyze+"  "+currentMethodName);
                String name = currentMethodName.split("\\(")[0];
                if(insn.isBackJump() && methodToAnalyze.endsWith(name)) {
                    StackFrame stack = ti.getTopFrame(); // ti is of type ThreadInfo
                    Expression expression = (Expression) stack.getLocalAttr(1);
                    if(expression != null) {
                        System.out.println("The symbolic bound : " + expression);
                        SymbolicInteger symI = (SymbolicInteger) expression;
                        System.out.println("The minimun value of x : " + symI._min);
                    }
                    //System.out.println("Line number: "+insn.getLineNumber()+"  Next : "+((nextInstruction!=null)?nextInstruction.getLineNumber():" "));
                    Pair info = backJumps.get(insn);
                    Integer backJump = null;
                    Boolean mustBeBounded = null;
                    if(info == null){
                        backJump = 1;
                        pcRightAfterBackJump = PathCondition.getPC(vm);
                        System.out.println("PC right after the backjump : "+pcRightAfterBackJump+"  Must be bounded : "+mustBeBounded);
                       // System.out.println("With get PC : "+pc);
                        //Here we can get the bound from the top of the pc, then we parse the index and get the associated condition
                        StackFrame stackFrame = ti.getTopFrame(); // ti is of type ThreadInfo
                        Expression expressionOfBound = (Expression) stackFrame.getLocalAttr(1);
                        if(expressionOfBound != null) {
                            System.out.println("The symbolic bound : "+expressionOfBound);
                            SymbolicInteger sym = (SymbolicInteger)expressionOfBound;
                            System.out.println("The minimun value of x : "+sym._min);
                            sym._max = 24;
                        }
                        else
                            System.out.println("We got nulll");
                    }
                    else{
                        backJump = (Integer)info._1 + 1;
                        mustBeBounded = (Boolean)info._2;
                        if(mustBeBounded == null){
                            //It's the second execution of the loop and we never went through that loop before
                            PathCondition oldPC = pcRightAfterBackJump;
                            pcRightAfterBackJump = getPCSoFAR(vm,conf,insn);
                            /*if(oldPC == null && pcRightAfterBackJump == null ||
                                    oldPC.equals(pcRightAfterBackJump))
                                mustBeBounded = false;
                            else*/
                                mustBeBounded = false;
                            System.out.println("PC right after the backjump : "+pcRightAfterBackJump+"  Must be bounded : "+mustBeBounded);
                        }
                    }
                   //After one iteration, check if the loop is concrete or not
                    //maybe add if mustBeBounded = null
                    if(mustBeBounded!= null && mustBeBounded && backJump > maxJumps){
                       backJump = 0;
                        //Here we just want to skip to the next instruction instead of the goto
                        StackFrame sf = ti.popAndGetModifiableTopFrame();
                        Instruction nextIns = sf.getPC().getNext();
                        // System.out.println("We saw too many back jumps: "+backJumps+"  "+executedInstruction+"  "+nextInstruction+"  "+nextIns);
                        //ti.breakTransition("breakIdleLoop");
                        vm.getCurrentThread().skipInstruction(nextIns);
                    }
                    int dest = Integer.parseInt(insn.toString().split("\\s")[1]);
                    for(Instruction i: backJumps.keySet()){
                        if(!i.equals(insn)){
                            //We reset the counters for the inner loops
                            int destI = Integer.parseInt(i.toString().split("\\s")[1]);
                            if(destI > dest && insn.getInstructionIndex() > i.getInstructionIndex()){
                                Pair prevInfo = backJumps.get(i);
                                if(prevInfo == null)
                                    prevInfo = new Pair(0,null);
                                else
                                    prevInfo = new Pair(0,(Boolean)prevInfo._2);
                                backJumps.put(i,prevInfo);
                            }
                        }
                    }
                    backJumps.put(insn,new Pair(backJump,mustBeBounded));
                }
                System.out.println("Bound for X : "+MinMax.getVarMinInt("x"));
                /*if(nextInstruction!= null && nextInstruction.isBackJump()  && methodToAnalyze.endsWith(name)){


                }*/
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
                       // System.out.println("Current method : "+methodName);
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

    public PathCondition getPCSoFAR(VM vm,Config conf,Instruction insn){
        MethodInfo mi = insn.getMethodInfo();
        ClassInfo ci = mi.getClassInfo();
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
                // System.out.println("Current method : "+methodName);
                if ((cg instanceof PCChoiceGenerator) && ((PCChoiceGenerator) cg).getCurrentPC() != null) {
                    PathCondition pc = ((PCChoiceGenerator) cg).getCurrentPC();
                    return pc;
                }
            }
        }
            return null;
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