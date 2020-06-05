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

import java.io.*;
import java.util.*;

import javafx.util.Pair;
import org.objectweb.asm.tree.MethodNode;
import sun.management.MethodInfo;

import static equiv.checking.Paths.classpath;

public class Instrumentation implements Utils{

	/** This class is in charge of creating the uninterpreted functions and JPF input **/
	private Map<String, String> typesMapping;
	private ArrayList<ArrayList<Integer>> blocks;
	private List<MethodNode> methods;
	private String signature="";
	private int numParameters;
	private String sourcePath;
	private String packageName;
	private String toolName;

	public Instrumentation(String sourcePath, String tool){
		this.sourcePath = sourcePath;
		typesMapping= new HashMap<>();
		typesMapping.put("I", "int");
		typesMapping.put("Z", "boolean");
		typesMapping.put("C", "char");
		typesMapping.put("F", "float");
		typesMapping.put("D", "double");
		typesMapping.put("J", "long");
		typesMapping.put("[D", "double[]");
		typesMapping.put("[I", "int[]");
		typesMapping.put("Ljava/lang/String;", "String");//not handled
		this.toolName = tool;
	}

	public Instrumentation(){
		typesMapping= new HashMap<>();
		typesMapping.put("I", "int");
		typesMapping.put("Z", "boolean");
		typesMapping.put("C", "char");
		typesMapping.put("F", "float");
		typesMapping.put("D", "double");
		typesMapping.put("J", "long");
		this.sourcePath = "src/examples/demo/instrumented";
		this.toolName = "";
	}

	/**Getters**/
	public int getNumParameters(){
		return numParameters;
	}

	public String packageName(){
		return packageName;
	}


	/**Setters**/
	public void setBlocks(ArrayList<ArrayList<Integer>> blocks) {
		this.blocks = blocks;
	}

	public void setMethods(List<MethodNode> methods){
		this.methods = methods;
	}

	/**
	 * This function retrieves the common blocks as a list of lines from the block file
	 * @param commonBlocksFilePath, the file where the blocks were saved
	 * @return
	 * @throws IOException
	 */
	public ArrayList<ArrayList<Integer>> retrieveBlocks(String commonBlocksFilePath) throws IOException{
		if(commonBlocksFilePath==null) return null;
		File file = new File(commonBlocksFilePath);
		BufferedReader br = new BufferedReader(new FileReader(file));
		String st;
		ArrayList<ArrayList<Integer>> blocks=new ArrayList<>();
		while((st = br.readLine()) != null) {//for each common block
			ArrayList<Integer> block = new ArrayList<>();
			String[] info = st.split(":");
			String[] values = info[1].split(",\\s*");
			String block_start_string = values[0];
			int block_start = Integer.parseInt(block_start_string);
			String block_end_string = values[1];
			int block_end = Integer.parseInt(block_end_string);
			for (int i = block_start; i <= block_end; i++)
				block.add(i);
			blocks.add(block);
		}
			return blocks;
	}

	/**
	 * This function provides values based on type, 0 for integer,'a' for char and true for boolean
	 * @param returnType
	 * @return
	 */
	private String valueBasedOnType(String returnType){
		String returnValue="1";
		if(returnType.equals("boolean")) returnValue="true";
		else if(returnType.equals("char")) returnValue="'a'";
		else if(returnType.equals("String")) returnValue="\"test\"";
		else if(returnType.equals("double[]")) returnValue="new double[]{5,6,7,8,9};";
		else if(returnType.equals("int[]")) returnValue="new int[]{5,6,7,8,9};";
		else if(returnType.equals("String[]")) returnValue="new String[]{\"yes\",\"no\"};";
		return returnValue;
	}

	/**
	 * This function creates the uninterpreted functions and returns the strings that will be added to the programs
	 * @param blockResultsWithVariableNames, the inputs and outputs of each block
	 * @param variablesTypesMapping,
	 * @param methodParams, the parameters of the given method,
	 * @return a pair of the uninterpreted functions and the replacement strings for each variables in a common block
	 */

	public Pair<ArrayList<String>,Map<Integer,ArrayList<String>>> creatingUninterpretedFunction(ArrayList<LinkedHashMap<String, Pair<Boolean,HashSet<String>>>> blockResultsWithVariableNames, Map<String, String> variablesTypesMapping, String[] methodParams) {
		ArrayList<String> UninterpretedFunctions = new ArrayList<>();
		Map<Integer, ArrayList<String>> replacementStrings = new LinkedHashMap<>();
		//Somewhere get Rid of the empty inputs functions
		for (int i = 0; i < blockResultsWithVariableNames.size(); i++) {
			int blockID = i + 1;
			Map<String, Pair<Boolean,HashSet<String>>> content = blockResultsWithVariableNames.get(i);
			ArrayList<String> perBlock = new ArrayList<>();
			Set<String> keys = content.keySet();
			for (String output : keys) {
				boolean mustBeDefined = content.get(output).getKey();
				HashSet<String> inputs = content.get(output).getValue();
				String returnType = typesMapping.get(variablesTypesMapping.get(output));
				//here do something with the name
				String out = output.replace(".","");
				String funcName = "UF_" + out + "_" + blockID;
				String returnValue = valueBasedOnType(returnType);
				String parameters = "", replacement = "";
				for (String input : inputs) {
						String returnT = typesMapping.get(variablesTypesMapping.get(input));
						parameters += returnT + " " + "Un" + input + ",";
						replacement += input + ",";
				}
				if (parameters.length() > 0) parameters = parameters.substring(0, parameters.length() - 1);
				if (replacement.length() > 0) replacement = replacement.substring(0, replacement.length() - 1);
				String injectedUninterpreted = "";
				//adding array handeling
				injectedUninterpreted = "@UnInterpreted\npublic static " + returnType + " " + funcName + "(" + parameters + "){\nreturn " + returnValue + ";\n}\n";

				String replace = output + " = " + funcName + "(" + replacement + ");\n";
				signature += "," + returnType + " " + funcName;
				if (mustBeDefined) {
					replace = returnType + " " + replace;
				}
				UninterpretedFunctions.add(injectedUninterpreted);
				if (replacementStrings.containsKey(blockID))
					replacementStrings.get(blockID).add(replace);
				else {
					perBlock.add(replace);
					replacementStrings.put(blockID, perBlock);
				}

			}
			//System.out.println(replacementStrings);
		}
		if(DEBUG) System.out.println("UF "+UninterpretedFunctions);
		if(DEBUG) System.out.println("REPLACEMENT "+replacementStrings);
		return new Pair(UninterpretedFunctions, replacementStrings);
	}


	/**
	 * This function creates the main in the class to be instrumented, which call the given method
	 * @param newClassName the class to be instrumented
	 * @param methodName the method to be called
	 * @param methodParams the parameters of the method
	 * @param variablesTypesMapping the type of each variable in the method
	 * @return a string containing the main method
	 */
	public String getMainProcedure(String newClassName,String methodName,String[] methodParams, String[] constructorParams,Map<String, String> variablesTypesMapping){
		String mainProcedure="public static void main(String[] args){\n" +
				newClassName+toolName+" temp = new "+newClassName+toolName+"(";
		if(DEBUG) System.out.println("Parameters : "+Arrays.toString(methodParams) +"  "+Arrays.toString(constructorParams));
		for(String type : constructorParams){
			String paramType = typesMapping.get(type);
			mainProcedure += valueBasedOnType(paramType) + ",";
		}
		//check here if it shouldn't be superior to 1
		if(constructorParams!=null && constructorParams.length>0)
			mainProcedure=mainProcedure.substring(0,mainProcedure.length()-1);
				mainProcedure+=");\n" +
				"temp."+methodName+"(";
		for(String param:methodParams){
			String paramType=typesMapping.get(variablesTypesMapping.get(param));
			mainProcedure+=valueBasedOnType(paramType)+",";
		}
		//System.out.println(methodParams.length);
		numParameters = methodParams.length;
		if(methodParams!=null && methodParams.length>0) mainProcedure=mainProcedure.substring(0,mainProcedure.length()-1);
		mainProcedure+=");\n" +
				//"Debug.printPC(\"Path conditions \");" +
				"}\n";
		return mainProcedure;
	}

	/**
	 * This function writes the new program file obtained after inserting the unidentified functions
	 * @param procPath, the path to the program file
	 * @param newClassName, the class name given to the new program
	 * @param uFunctions, the list of unidentified functions
	 * @param replacement, the list of the replacement strings in the form x=UF_...
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public void saveNewProcedure(String procPath, String newClassName,ArrayList<String> uFunctions, Map<Integer,ArrayList<String>> replacement,String mainMethod) throws FileNotFoundException, IOException{
		String newProgram = "";
		String oldClassName = newClassName.substring(1);
		BufferedReader br = new BufferedReader(new FileReader(new File(procPath)));
		int last=1;
		String line=br.readLine();
		//To retrieve and modify the class name
		while(line!=null && !line.contains("class")){
			if(!line.contains("package"))
				newProgram+=line+"\n";
			else {
				String[] packageLine = line.split(";")[0].split("package ");
				this.packageName = (packageLine.length > 1) ? packageLine[1] : packageLine[0];
				newProgram+=line+"\n";
			}
			line=br.readLine();
			last++;
		}
		//Line can not be null, otherwise it is not a valid class file
		if(line==null) throw new IllegalArgumentException();
		String[] aroundClass=line.split("class ");
		String [] beforeBrace = aroundClass[aroundClass.length - 1].split("\\s*\\{");
		newProgram+=aroundClass[0]+"class "+"I"+beforeBrace[0]+toolName+"{\n";
		last ++;
		if(blocks != null) {
			for (int i = 0; i < blocks.size(); i++) {
				for (int j = last; j < blocks.get(i).get(0); j++) {
					String st = br.readLine();
					st = st.replace(oldClassName,newClassName+toolName);
					newProgram += st + "\n";
				}
				int replacementSize = 0;
				ArrayList<String> rep = replacement.get(i+1);
				if(rep != null) {
					for (String s : rep) {
						br.readLine();
						newProgram += s;
					}
					replacementSize = rep.size();
				}
				ArrayList<Integer> block = blocks.get(i);
				int size = (1 + block.get(block.size() - 1) - block.get(0)) - replacementSize;
				for (int a = 0; a < size; a++)
					br.readLine();

				last = block.get(block.size() - 1) + 1;
			}
		}
		line=br.readLine();
		String remainingProgram ="";
		while(line!=null){
			//In order not to copy the last closing bracket
			String nextLine=null;
			if(!line.trim().contains("}") || (nextLine=br.readLine())!= null && !nextLine.trim().isEmpty()){
				//Here check if contains some signature
				if(line.contains("public") || line.contains("private") || line.contains("static")) {
					for (int i = 2; i<methods.size();i++){
						MethodNode method = methods.get(i);
						String meth = method.name;
						if (line.contains(meth) ){
							remainingProgram+="@UnInterpreted\n";
						}
					}
				}
				remainingProgram += line + "\n";
				if(nextLine==null){
					line=br.readLine();
					continue;
				}
			}
			line=nextLine;
		}
		remainingProgram = remainingProgram.replace(oldClassName,newClassName+toolName);
		newProgram+=remainingProgram;
		if(uFunctions != null) {
			for (String func : uFunctions)
				newProgram += func;
		}
		newProgram+=mainMethod+"}\n";
		File newFile = new File(sourcePath+"/"+newClassName+toolName+".java");
		newFile.getParentFile().mkdir();
		if(!newFile.exists())
			newFile.createNewFile();
		FileWriter writer = new FileWriter(newFile);
		writer.write(newProgram);
		writer.close();
		compile(classpath,newFile);
	}
}
