//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package equiv.checking;
import java.util.*;
import java.io.*;
import br.usp.each.saeg.asm.defuse.*;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.NodeList;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.expr.Expression;
import com.github.javaparser.ast.expr.MethodCallExpr;
import com.github.javaparser.ast.nodeTypes.NodeWithBody;
import com.github.javaparser.ast.stmt.BlockStmt;
import com.github.javaparser.ast.stmt.ExpressionStmt;
import com.github.javaparser.ast.stmt.IfStmt;
import com.github.javaparser.ast.stmt.Statement;

import org.apache.commons.collections4.map
		.MultiKeyMap;
import org.objectweb.asm.tree.*;
import org.objectweb.asm.tree.analysis.AnalyzerException;

import javafx.util.Pair;

import static equiv.checking.Utils.DEBUG;
import static equiv.checking.Utils.mathFunctions;

/**
 * This class conducts all the operations regarding def-use relations in a program
 */

public class DefUseExtractor {
	protected static boolean isStatic = false;
	private static Map<Integer,Pair<Integer,Integer>> variableScopes = null;
	private static Map<Integer,String[]> outputsPerBlock = null;
	private static MultiKeyMap variablesNamesMapping = null;
	private static Map<String,String> lossyMapping = null;
	private static Map<String,String> variablesNameTypeMapping = null;
	private static Map<Integer,ArrayList<Pair<String,Pair<Integer,Integer>>>> scopes = null;
	private static Map<Integer,Map<Integer,Pair<String,int[]>>> statementInfoPerBlock = null;


	/**Getters**/
	public static Map<Integer, String[]> outputsPerBlock() {
		return outputsPerBlock;
	}

	public static Map<Integer, Map<Integer, Pair<String, int[]>>> getStatementInfoPerBlock() {
		return statementInfoPerBlock;
	}
	public Map<String, String> getVariableTypesMapping() throws IOException, AnalyzerException {
		return variablesNameTypeMapping;
	}



	/**
	 * This function returns all the variables of a given method
	 * @param method a method
	 * @return array of variables
	 * @throws AnalyzerException
	 */
	public static Variable[] getVariables(MethodNode method) throws AnalyzerException{
		///////////////////////////////////////////
        DefUseInterpreter interpreter = new DefUseInterpreter();
        FlowAnalyzer<Value> flowAnalyzer = new FlowAnalyzer<Value>(interpreter);
        DefUseAnalyzer analyzer = new DefUseAnalyzer(flowAnalyzer, interpreter);
        analyzer.analyze("package/ClassName", method);
        ///////////////////////////////////////////
        Variable[] variables = analyzer.getVariables();
		variableInfo(method,variables);
        return variables;
	}

	/**
	 * This function fills maps with the information about each variables (scope, name,type)
	 * @param method a method
	 * @param vars the variables inside that method
	 */
	private static void variableInfo(MethodNode method, Variable[] vars){
	if(DEBUG)System.out.println(method.attrs);
	HashMap<Integer, Integer> lineInst = instructionToLine(method);
	scopes = new HashMap<>();
	variablesNamesMapping = new MultiKeyMap();
	variablesNameTypeMapping = new HashMap<>();
	statementInfoPerBlock = new HashMap<>();
	lossyMapping = new HashMap<>();
	for(LocalVariableNode node : method.localVariables){
		if(node!=null){
			ArrayList<Pair<String,Pair<Integer,Integer>>> variables = new ArrayList<>();
			if(scopes.containsKey(node.index)){
				variables = scopes.get(node.index);
			}
			Integer start = lineInst.get(method.instructions.indexOf(node.start));
			Integer end = lineInst.get(method.instructions.indexOf(node.end));
			if(start == null ){
				start = Integer.MIN_VALUE;
			}
			if(start != null && end != null){
				variables.add(new Pair(node.name,new Pair(start,end)));
				scopes.put(node.index,variables);
			}
			variablesNamesMapping.put("L@"+node.index,start,node.name);
			lossyMapping.put("L@"+node.index,node.name);
			variablesNameTypeMapping.put(node.name,node.desc);
			if(lossyMapping.containsValue("this"))
				isStatic = false;
			else
				isStatic = true;
		}
	}
	for(Variable var : vars){
		if(var.toString().contains(".")){
			String variable = var.toString();
			String[] splits = variable.split("\\.");
			String name = lossyMapping.get(splits[0])+"."+splits[splits.length - 1];
			if(name != null){
				lossyMapping.put(variable,name);
				variablesNameTypeMapping.put(name,var.type.toString());
			}
		}
	}
}

	/**
	 * This function returns the parameters of a given method
	 * @param method a method
	 * @return an array of parameters
	 * @throws AnalyzerException
	 */
	public String[] extractParams(MethodNode method) throws AnalyzerException {
		DefUseInterpreter interpreter = new DefUseInterpreter();
		FlowAnalyzer<Value> flowAnalyzer = new FlowAnalyzer<Value>(interpreter);
		DefUseAnalyzer analyzer = new DefUseAnalyzer(flowAnalyzer, interpreter);
		analyzer.analyze("package/ClassName", method);
		Variable[] variables = analyzer.getVariables();
		if(DEBUG)System.out.println(Arrays.toString(variables));
		DefUseFrame[] frames = analyzer.getDefUseFrames();
		int inputSize = frames[0].getDefinitions().size();
		int shift = 0;
		if(isStatic == false){
			inputSize --;
			shift = 1;
		}
		String[] inputVariables = new String[inputSize];
		for (int j=0; j<inputSize;j++) {
			inputVariables[j] = lossyMapping.get(variables[j+shift].toString());
		}
		return inputVariables;
	}

	/**
	 * This function extracts the parameters of the constructor of a class
	 * @param method the constructor
	 * @return an array of parameters
	 * @throws AnalyzerException
	 */
	public String[] extractParamsConstructor(MethodNode method) throws AnalyzerException {
		DefUseInterpreter interpreter = new DefUseInterpreter();
		FlowAnalyzer<Value> flowAnalyzer = new FlowAnalyzer<Value>(interpreter);
		DefUseAnalyzer analyzer = new DefUseAnalyzer(flowAnalyzer, interpreter);
		analyzer.analyze("package/ClassName", method);
		Variable[] variables = analyzer.getVariables();
		if(DEBUG)System.out.println(Arrays.toString(variables));
		DefUseFrame[] frames = analyzer.getDefUseFrames();
		int inputSize = frames[0].getDefinitions().size();
		String[] inputVariables = new String[inputSize];
		ArrayList<Variable> paramTypes = new ArrayList<>();
		for (int j=0; j<inputSize;j++) {
			String var = variables[j].toString();
			if (!var.contains("L@0")) {
				paramTypes.add(variables[j]);
			}
		}
			inputVariables = new String[paramTypes.size()];
			for(int i = 0;i<inputVariables.length;i++){
				inputVariables[i] = paramTypes.get(i).type.getDescriptor();
			}
		if(DEBUG)System.out.println(Arrays.toString(variables));
		if(DEBUG)System.out.println(Arrays.toString(inputVariables));
		return inputVariables;
	}


	/**
	 * This function returns the index of a variable given its name
	 * @param varName a variable name in the form L@1
	 * @return the index of the variable
	 */
	public static int getIndexFromVarName(String varName){
		String number = varName.split("@")[1];
		if(number.contains("."))
			number = number.split("\\.")[0];
		return Integer.parseInt(number);
	}

	/**
	 * This function maps each bytecode instruction for a given method to a line number
	 * @param method a method
	 * @return a map from instruction to line number
	 */
	public static HashMap<Integer,Integer> instructionToLine(MethodNode method){
		//mapping instruction number to line number
		HashMap<Integer,Integer> lineInst = new HashMap<>() ;
		for (int i = 0; i < method.instructions.size(); i++) {
			int idx = method.instructions.indexOf(method.instructions.get(i));
			ListIterator<AbstractInsnNode> insnIt = method.instructions.iterator(idx);
			while (insnIt.hasPrevious()) {
				AbstractInsnNode node = insnIt.previous();
				if (node instanceof LineNumberNode) {
					lineInst.put(idx, ((LineNumberNode) node).line);
					break;
				}
			}
		}
		return lineInst;
	}

	/**
	 * This function creates a list of outputs and inputs variables for each line in a block
	 * We have as outputs of the block, the variables which are defined or used outside the block
	 * We have as inputs of the block the variable that exist outside of the block
	 * We also need to think about where the first definition of the variable should be:
	 * If it is not defined in the current block, then it is either defined in a previous block or in a changed statement
	 * There is no need to do additional checks since, if it is defined in a previous block then it is necessarily an output of that previous block (see definition of isOutputOftheBlock)
	 * 	If not, it is defined in a changed statement and no need to define it
	 * @param root the ast node corresponding to the method
	 * @param method the method
	 * @param commonBlocks the list of common block
	 * @return a list of maps from output variable to inputs (each map corresponds to a block)
	 * @throws AnalyzerException
	 * @throws NumberFormatException
	 * @throws IOException
	 */
	public static ArrayList<LinkedHashMap<String,Pair<Boolean,HashSet<String>>>> extractBlocksInputsOutputs(MethodDeclaration root, MethodNode method, ArrayList<ArrayList<Integer>> commonBlocks) throws AnalyzerException, NumberFormatException, IOException {
		ArrayList<LinkedHashMap<String, Pair<Boolean,HashSet<String>>>> blockResults = new ArrayList<>();
		outputsPerBlock = new HashMap<>();
		statementInfoPerBlock = new HashMap<>();
		DefUseInterpreter interpreter = new DefUseInterpreter();
		FlowAnalyzer<Value> flowAnalyzer = new FlowAnalyzer<Value>(interpreter);
		DefUseAnalyzer analyzer = new DefUseAnalyzer(flowAnalyzer, interpreter);
		analyzer.analyze("package/ClassName", method);
		Variable[] variables = analyzer.getVariables();
		HashMap<Integer, Integer> lineInst = instructionToLine(method);
		DefUseChain[] chains = new DepthFirstDefUseChainSearch().search(
				analyzer.getDefUseFrames(),
				analyzer.getVariables(),
				flowAnalyzer.getSuccessors(),
				flowAnalyzer.getPredecessors());

		TreeMap<Integer, Pair<String, HashSet<String>>> defUsePerLine = DefUseExtractor.defUsePerLine(method, lineInst, chains, variables);
		int line = root.getBegin().get().line;
		backwardControlDependence(root.getBody().get(), line,line, defUsePerLine,commonBlocks);
		getDepthPerBlock(root.getBody().get(),1,defUsePerLine,commonBlocks,0);
		if(DEBUG)System.out.println("Information : "+statementInfoPerBlock);
		HashSet<String> definedInSomePreviousBlock = new HashSet<>();
		int block_ID = 1;
		if(DEBUG)System.out.println(defUsePerLine.toString());
		if(DEBUG)System.out.println(scopes);
		for (ArrayList<Integer> block : commonBlocks) {
			if (block.isEmpty()) continue;
			int block_start = block.get(0);
			int block_end = block.get(block.size() - 1);
			LinkedHashMap<String, Pair<Boolean,HashSet<String>>> perBlock = new LinkedHashMap();
			String[] outputs = new String[(block_end-block_start) + 1];
			for (int i = block_start; i <= block_end; i++) {
				Pair<String, HashSet<String>> matches = defUsePerLine.get(i);
				if (matches != null && matches.getKey()!= null) {
					int varIndex = getIndexFromVarName(matches.getKey());
					//We check if the variable should be an output of the block (either used after or redefined after)
					HashSet<String> inputs = new HashSet<>();
					/*Integer start =  scopeStart(varIndex, method, lineInst);
					Integer end = scopeEnd(varIndex,method,lineInst);
					String name = lossyMapping.get(matches.getKey());*/
					Integer start = scopeStart(varIndex, i, method);
					Integer end = scopeEnd(varIndex, i, method);
					String name = (String) variablesNamesMapping.get(matches.getKey(), start);
					if (name != null) {
						outputs[i - block_start] = name;
						Boolean mustBeDefined = start >= block_start || end < i;
						for (String obj : matches.getValue()) {
							int index = getIndexFromVarName(obj);
							//If the variable still exists outside of the block (loops)
							//Integer startI =  scopeStart(index, method, lineInst);
							//String var = lossyMapping.get(obj);
							Integer startI = scopeStart(index, i, method);
							String var = (String) variablesNamesMapping.get(obj, startI);
							if (var != null && (name != var || !mustBeDefined))
								inputs.add(var);
						}
						if (!perBlock.containsKey(name)) {
							perBlock.put(name, new Pair(mustBeDefined, inputs));
						} else {
							removeUsedBeforeRedefinition(name, inputs, perBlock);
						}
					}
				}
				}
			outputsPerBlock.put(block_ID,outputs);
			blockResults.add(perBlock);
			block_ID ++;
		}
		if(DEBUG)System.out.println(blockResults);
		return blockResults;
	}


	/**
	 * This function returns map from line number to a pair <defined variable,used variables>
	 * When a new variable is defined, we check if this is where the scope starts, if not, we need to add a definition for the beginning of the scope
	 * @param method the method
	 * @param lineInst the mapping from bytecode instructions to line numbers
	 * @param chains the def-use chains
	 * @param variables the variables of the method
	 * @return a map from line number to pair <defined variable,used variables> (e.g 15 --> <val, [x,i] for int val = x*i)
	 */
	public static TreeMap<Integer,Pair<String,HashSet<String>>> defUsePerLine(MethodNode method,HashMap<Integer, Integer> lineInst,DefUseChain[] chains,Variable[] variables) {
		TreeMap<Integer, Pair<String, HashSet<String>>> defUsePerLine = new TreeMap<>();
		for (int i = 0; i < chains.length; i++) {
			DefUseChain chain = chains[i];
			Integer defLine = lineInst.get(chain.def);
			Integer useLine = lineInst.get(chain.use);
			//Here only add if it is a variable not like out and stuff
			//in case we saw a use on a certain line before the definition on that same line;
			if(defLine != null) {
				String var = variables[chain.var].toString();

				int index = getIndexFromVarName(var);
				Integer start = scopeStart(index,defLine,method);
				HashSet<String> inputs = new HashSet<>();

				if (defUsePerLine.containsKey(defLine))
					inputs = defUsePerLine.get(defLine).getValue();
				defUsePerLine.put(defLine,new Pair(var,inputs));
				//Here we look at whether we should add start as well
				if(defLine != start){
					inputs = new HashSet<>();
					if(defUsePerLine.containsKey(start))
						inputs = defUsePerLine.get(start).getValue();
					defUsePerLine.put(start,new Pair(var,inputs));
				}
			}
			if(useLine != null) {
				String s = variables[chain.var].toString();
				if (isStatic || chain.var != 0) {
					if (defUsePerLine.containsKey(useLine)) {
						HashSet<String> inputs = defUsePerLine.get(useLine).getValue();
						if (!inputs.contains(s)){
							//Here I deal with where this variable s is defined;
							inputs.add(s);
						}
					} else {
						HashSet<String> inputs = new HashSet<>();
						inputs.add(s);
						defUsePerLine.put(useLine, new Pair(null, inputs));
					}
				}
			}
		}
		return defUsePerLine;
	}

	/**
	 * This function serves to get the start of the scope of a given variable based on its index
	 * @param varIndex the index of the variable
	 * @param ins the instruction where this variable is used or define
	 * @param method the method
	 * @return the start of the scope of a variable
	 */
	private static int scopeStart(Integer varIndex,Integer ins,MethodNode method) {
		ArrayList<Pair<String,Pair<Integer,Integer>>> vars = scopes.get(varIndex);
		if(vars != null) {
			for (Pair<String, Pair<Integer, Integer>> var : vars) {
				Integer scopeStart = var.getValue().getKey();
				Integer scopeEnd = var.getValue().getValue();
				if (scopeStart != null && scopeEnd != null) {
					if (scopeStart <= ins && ins <= scopeEnd)
						return scopeStart;
				}
			}
		}
		return Integer.MIN_VALUE;
	}

	/**
	 * This function serves to get the end of the scope of a given variable based on its index
	 * @param varIndex the index of the variable
	 * @param ins the instruction where this variable is used or define
	 * @param method the method
	 * @return the end of the scope of a variable
	 */
	private static int scopeEnd(Integer varIndex,Integer ins,MethodNode method) {
		ArrayList<Pair<String,Pair<Integer,Integer>>> vars = scopes.get(varIndex);
		if(vars != null) {
			for (Pair<String, Pair<Integer, Integer>> var : vars) {
				Integer scopeStart = var.getValue().getKey();
				Integer scopeEnd = var.getValue().getValue();
				if (scopeStart != null && scopeEnd != null) {
					if (scopeStart <= ins && ins <= scopeEnd)
						return scopeEnd;
				}
			}
		}
		return Integer.MIN_VALUE;
	}

	/**
	 * This function returns the start of the scope of the first variable that matches the index
	 * @param varIndex the index of the variable
	 * @param method the method the variable is defined/used in
	 * @return the start of the scope
	 */
	private static int scopeStart(Integer varIndex,MethodNode method) {
		Integer startId = scopes.get(varIndex).get(0).getValue().getKey();
		if (startId != null) {
			return startId;
		}
		return Integer.MIN_VALUE;
	}

	/**
	 * This function returns the end of the scope of the first variable that matches the index
	 * @param varIndex the index of the variable
	 * @param method the method the variable is defined/used in
	 * @return the end of the scope
	 */
	private static int scopeEnd(Integer varIndex,MethodNode method) {
		Integer endId = scopes.get(varIndex).get(0).getValue().getValue();
		if (endId != null) {
			return endId;
		}
		return Integer.MIN_VALUE;
	}


	/**
	 * This function is to add all the variables used in statements that a given statement is control dependent on in a block
	 * @param st the statement
	 * @param method the method
	 * @param location the line number for the statement ?
	 * @param defUsePerLine the list of def-use pairs for each line
	 * @param commonBlocks the list of common blocks
	 */
	private static void backwardControlDependence(Statement st, int method, int location,  Map<Integer,Pair<String,HashSet<String>>> defUsePerLine, ArrayList<ArrayList<Integer>> commonBlocks) {
		//boolean impacted = impactedStatements.contains(location);
		if(st!=null) {
			ArrayList<Integer> additions = new ArrayList<>();
			if(!(st instanceof BlockStmt))
				st=new BlockStmt(new NodeList<>(st));
			BlockStmt root=st.asBlockStmt();
			for (Statement statement : root.getStatements()) {
				int i = statement.getBegin().get().line;
				//We add all the used variables in the parent to those of the child
				if(location != method && containedInSameBlock(i,location,commonBlocks)) {
					Pair<String, HashSet<String>> rootL = defUsePerLine.get(location);
					if (rootL != null) {
						Pair<String, HashSet<String>> inputs = defUsePerLine.get(i);
						if (inputs != null) {
							inputs.getValue().addAll(rootL.getValue());
						}
					}
				}
				if (CommonBlockExtractor.isControlSmt(statement)) {
					Statement trueControlled = (statement instanceof IfStmt) ? (statement.asIfStmt()).getThenStmt(): ((NodeWithBody) statement).getBody();
					backwardControlDependence(trueControlled, method,statement.getBegin().get().line,defUsePerLine,commonBlocks);
					if (statement instanceof IfStmt) {
						IfStmt ist = statement.asIfStmt();
						if (ist.hasElseBranch())
							backwardControlDependence(ist.getElseStmt().get(), method,statement.getBegin().get().line,defUsePerLine,commonBlocks);
					}
				}
			}
		}
	}

	/**
	 * This function serves to get the depth of each statement inside a common blocks (the number of loops it is inside of)
	 * This function could have been merged with the previous one, but was separated for clarity
	 * @param st the statement
	 * @param prevID the current block id
	 * @param defUsePerLine the def-use pairs for each line
	 * @param blocks the list of blocks
	 * @param depth the current depth
	 */
	private  static void getDepthPerBlock(Statement st,int prevID, Map<Integer,Pair<String,HashSet<String>>> defUsePerLine, ArrayList<ArrayList<Integer>> blocks, int depth) {
		if (st != null) {
			int controlDepth = depth;
			if (!(st instanceof BlockStmt))
				st = new BlockStmt(new NodeList<>(st));
			BlockStmt root = st.asBlockStmt();
			for (Statement statement : root.getStatements()) {
				int i = statement.getBegin().get().line;
				if(DEBUG)System.out.println("Here : "+i+"  "+statement.toString());
				//Here we need to add to our list for the current block
				Integer id = containedInBlock(i, blocks);
				int block_id = prevID;
				//We check if the current statement is part of a block
				if(DEBUG)System.out.println("Block id : "+id+" prev : "+block_id);
				if (id != -1) {
					if (block_id != id) {
						block_id = id;
						controlDepth = 0;
					}
					//ArrayList<Integer> block = blocks.get(id - 1);
					Map<Integer, Pair<String, int[]>> statements = statementInfoPerBlock.get(id);
					if (statements == null) {
						statements = new HashMap<>();
					}
					Pair<String, int[]> info = statements.get(i);
					if (info == null) {
						Pair<String, HashSet<String>> line = defUsePerLine.get(i);
						if (line != null) {
							String name = lossyMapping.get(line.getKey());
							HashSet<String> inputs = line.getValue();
							HashSet<String> inputsName = new HashSet<>();
							inputs.forEach((key) -> inputsName.add(lossyMapping.get(key)));
							if(DEBUG)System.out.println("Names : " + inputsName + "   " + name);
							int[] values = new int[3];
							//here we only count the depth if the statement it is control dependent on is in the block
							values[0] = controlDepth;
							if (CommonBlockExtractor.isControlSmt(statement) && !(statement instanceof IfStmt)) {
								values[0] ++;
							}
							getNonLinearArithm(statement, name, inputsName, values);
							info = new Pair(name, values);
							if(DEBUG)System.out.println(Arrays.toString(values));
						}
					}
					//Here we add to the list of statements
					statements.put(i, info);
					statementInfoPerBlock.put(block_id,statements);
				}
				//Now here we need to handle the control statement and augment the depth if it is a for or a while loop
				if (CommonBlockExtractor.isControlSmt(statement)) {
					Statement trueControlled = (statement instanceof IfStmt) ? (statement.asIfStmt()).getThenStmt() : ((NodeWithBody) statement).getBody();
					if (statement instanceof IfStmt) {
						//should I do + 1 here ?
						getDepthPerBlock(trueControlled, block_id, defUsePerLine, blocks, controlDepth);
						IfStmt ist = statement.asIfStmt();
						if (ist.hasElseBranch())
							getDepthPerBlock(ist.getElseStmt().get(), block_id, defUsePerLine, blocks, controlDepth);
					} else {
						getDepthPerBlock(trueControlled, block_id, defUsePerLine, blocks, controlDepth + 1);
					}
				}
			}
		}
	}

	/**
	 * This function checks whether a given line number is inside the block
	 * @param i
	 * @param commonBlocks
	 * @return
	 */
	private static int containedInBlock(int i,ArrayList<ArrayList<Integer>> commonBlocks) {
		int id = 1;
		for(ArrayList<Integer> block: commonBlocks){
			if (block.isEmpty()) continue;
			int block_start = block.get(0);
			int block_end = block.get(block.size() - 1);
			if(block_start<= i && i<=block_end)
				return id;
			id ++;
		}
		return -1;
	}

	/**
	 * This function checks whether two statements are contained in the same block
	 * @param i
	 * @param location
	 * @param commonBlocks
	 * @return
	 */
	private static boolean containedInSameBlock(int i, int location,ArrayList<ArrayList<Integer>> commonBlocks) {
		for(ArrayList<Integer> block: commonBlocks){
			if (block.isEmpty()) continue;
			int block_start = block.get(0);
			int block_end = block.get(block.size() - 1);
			if(block_start<= i && i<=block_end && block_start<= location && location<=block_end)
				return true;
		}
		return false;
	}

	/**
	 * This function serves to get the number of non-linear arithmetic operations per statement
	 * @param st a statement
	 * @param output the name of the output variable in the case of a declaration/definition
	 * @param inputs the inputs to the statement / variables used in the statement
	 * @param values the array to fill value[0] contains the depth, value[1] the non arithmetic, value[2] specifies whether the operations are mixed or not(integer + real)
	 */
	private static void getNonLinearArithm(Statement st, String output,HashSet<String> inputs,int[] values){
		if(st instanceof ExpressionStmt){
			Expression expr = st.asExpressionStmt().getExpression();
			String string = expr.toString();
			long numArith = string.chars().filter(ch -> (ch == '*' || ch == '/')).count();
			//here count the number of times I see a map function as well (put the functions list in the Utils class)
			values[2] = 0;
			for(String func:mathFunctions){
				values[1] += Math.max(0,string.split(func).length -1);
			}
			if(output != null) {
				if (variablesNameTypeMapping.get(output).equals("D") && numArith > 0) {
					//here we check if it is mixed arithmetic
					boolean seenInt = false;
					boolean seenDouble = false;
					for (String input : inputs) {
						if (variablesNameTypeMapping.get(input).equals("I")) {
							seenInt = true;
							if (seenDouble) {
								values[2] = 1;
								break;
							}
						} else if (variablesNameTypeMapping.get(input).equals("D")) {
							seenDouble = true;
							if (seenInt) {
								values[2] = 1;
								break;
							}
						}
					}
				}
			}
			/************************/
			List<Node> nodes= expr.getChildNodes();
			values[1] += countMethodCalls(nodes);
			//System.out.println(countMethodCalls(nodes));
            /************************/
			values[1] += (int)numArith;
		}
	}

	/**
	 * This function counts the number of method calls in a statement
	 * @param nodes
	 * @return
	 */
    private static int countMethodCalls(List<Node> nodes){
		int res = 0;
		for (Node n: nodes){
			if (n instanceof MethodCallExpr) {
				//System.out.println("method is" + n);
				res++;
			}
			res+=countMethodCalls(n.getChildNodes());
		}
		return res;
	}


	/**
	 * Inside a block, we only keep the last definition of a given variable
	 * We need to remove that variable from the inputs of any line preceding its final declaration since it does not exist yet
	 * @param name the variable defined
	 * @param varInputs the inputs
	 * @param blockResults the current mappings in a given block
	 */
	private static void removeUsedBeforeRedefinition(String name, HashSet<String> varInputs,Map<String,Pair<Boolean,HashSet<String>>> blockResults){
		Pair<Boolean,HashSet<String>> inputs = blockResults.get(name);
		if(!inputs.getKey()){//not the first definition (defined before the block)
			inputs.getValue().addAll(varInputs);
			blockResults.remove(name);
			blockResults.put(name,inputs);
			return;
		}
		//The variable was defined inside the block
		blockResults.remove(name);
		for(String output : blockResults.keySet()){
			Pair<Boolean,HashSet<String>> params = blockResults.get(output);
			params.getValue().remove(name);
		}
		varInputs.remove(name);
		inputs.getValue().addAll(varInputs);
		blockResults.put(name,inputs);
	}
}
