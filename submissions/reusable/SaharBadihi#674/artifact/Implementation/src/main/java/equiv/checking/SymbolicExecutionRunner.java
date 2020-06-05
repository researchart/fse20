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

import com.microsoft.z3.*;
import equiv.checking.symparser.AbstractSymParser;
import equiv.checking.symparser.SymParser;
import equiv.checking.symparser.SymParserSMTLib;
import javafx.util.Pair;

import java.io.*;
import java.util.*;

import static equiv.checking.Paths.*;
import static equiv.checking.Utils.DEBUG;

public class SymbolicExecutionRunner {
	/** This class runs the symbolic execution with JPF-symbc **/
	protected String oldFileName;
	protected String newFileName;
	protected String targetMethod;
	protected String path;
	protected int methodInputs;
	protected int bound;
	protected int timeout;
	protected String SMTSolver;
	public long z3time;
	protected int minInt, maxInt;
	protected double minDouble, maxDouble;
	protected long minLong,  maxLong;
    protected String packageName;
    protected boolean Error = true, reachedEnd = false, boundEnough = true;
    protected boolean parseFromSMTLib,Z3_TERMINAL;
    protected String terminalInput = "", errorInJPF = "";
    protected String firstSummary = "",secondSummary = "";

	public SymbolicExecutionRunner(String path,String packageName,String oldFile,String newFile,String targetMethod, int methodInputs,int bound, int timeout, String SMTSolver, int minint, int maxint, double mindouble, double maxdouble, long minlong, long maxlong,boolean parseFromSMTLib,boolean z3Terminal){
		this.oldFileName=oldFile;
		this.newFileName=newFile;
		this.path = path+"/";
		this.packageName = packageName;
		this.targetMethod=targetMethod;
		this.methodInputs=methodInputs;
		this.bound = bound;
		this.timeout = timeout;
		this.SMTSolver = SMTSolver;
		this.minInt = minint;
		this.maxInt = maxint;
		this.minDouble = mindouble;
		this.maxDouble = maxdouble;
		this.minLong = minlong;
		this.maxLong = maxlong;
		this.parseFromSMTLib = parseFromSMTLib;
		this.Z3_TERMINAL = z3Terminal;
	}

	public SymbolicExecutionRunner(String oldFile,String newFile,String targetMethod, int methodInputs){
		this.oldFileName=oldFile;
		this.newFileName=newFile;
		this.path ="src/examples/demo/instrumented/";
		this.packageName = "demo.instrumented";
		this.targetMethod=targetMethod;
		this.methodInputs=methodInputs;
		bound = 5;
		this.timeout = 100000;
		this.SMTSolver = "z3";
		this.minInt = -100;
		this.maxInt = 100;
		this.minDouble = -100.0;
		this.maxDouble = 100.0;
		this.minLong = -100;
		this.maxLong= 100;
		this.parseFromSMTLib = false;
	}

	/** This class collects all the information from constraint solving **/
	public class SMTSummary {
		public BoolExpr summaryOld, summaryNew;
		public Status status;
		public HashMap<Expr, Integer> uFunctionsOld, uFunctionsNew;
		public HashSet<Expr> procCalls;
		public Map<String, Expr> variables;
		public Map<String, Pair<FuncDecl, HashSet<Expr>>> functionsInstances;
		public Context context;
		public Solver solver;
		public Tactic tactic;
		public String toWrite, reasonUnknown, declarations, firstSummary, secondSummary;
		public AbstractSymParser parser;
		public boolean noUFunctions;

		public SMTSummary() {
			uFunctionsOld = new HashMap<>();
			uFunctionsNew = new HashMap<>();
			toWrite = "";
		}

		/**
		 * This function checks the equivalence of two programs using the program summaries fields
		 */
		public void checkEquivalence() throws IOException {
			context = new Context();
			Tactic qfnra = context.mkTactic("qfnra-nlsat");
			//Tactic simplifyTactic = context.mkTactic("ctx-solver-simplify");
			Tactic simplifyTactic = context.mkTactic("simplify");
			Tactic smtTactic = context.mkTactic("smt");
			Tactic aig = context.mkTactic("aig");
			Tactic solveeqs = context.mkTactic("solve-eqs");
			Tactic or = context.andThen(smtTactic, context.parOr(new Tactic[]{simplifyTactic, solveeqs, aig, qfnra}));
			if (DEBUG) System.out.println(Arrays.toString(context.getTacticNames()));
			if (parseFromSMTLib) {
				terminalInput += "The summary for the old method (in z3 stmt2 format)\n";
				parser = new SymParserSMTLib(context);
				summaryOld = createSMTSummaryProgram(oldFileName, (SymParserSMTLib) parser);
				if (!Error) {
					uFunctionsOld.putAll(parser.uFunctions());
					parser.emptyUF();
					File file = new File(path + oldFileName + "Terminal.txt");
					if (!file.exists())
						file.createNewFile();
					BufferedWriter bw = new BufferedWriter(new FileWriter(file));
					bw.write(terminalInput);
					bw.close();
					terminalInput = "The summary for the new method\n";
					summaryNew = createSMTSummaryProgram(newFileName, (SymParserSMTLib) parser);
					file = new File(path + newFileName + "Terminal.txt");
					if (!file.exists())
						file.createNewFile();
					bw = new BufferedWriter(new FileWriter(file));
					bw.write(terminalInput);
					bw.close();
				} else
					summaryNew = null;
			} else {
				parser = new SymParser(context);
				summaryOld = createSMTSummaryProgram(oldFileName, (SymParser) parser);
				if (!Error) {
					uFunctionsOld.putAll(parser.uFunctions());
					parser.emptyUF();
					summaryNew = createSMTSummaryProgram(newFileName, (SymParser) parser);
				} else
					summaryNew = null;
			}
			noUFunctions = parser.noUFunctions();
			if ((summaryNew == null || summaryOld == null) && Error) {
				status = Status.UNKNOWN;
				if (!reachedEnd) {
					String error = "";
					if (summaryOld == null) error = parseErrorFile(oldFileName);
					else error = parseErrorFile(newFileName);
					toWrite += "INFO: There was an error while running JPF";
					reasonUnknown = "Error while running JPF-symbc";
					if (!error.isEmpty()) {
						reasonUnknown += " : " + error;
						reasonUnknown += " (refer to JPFError.txt)";
						if (error.contains("OutOfMemoryError")) {
							reasonUnknown += "\n Try increasing your heap memory";
						} else if (error.contains("Z3")) {
							reasonUnknown += "\n Maybe try with a different solver";
						}
					}
				} else {
					if (!boundEnough) {
						toWrite += "INFO: There was an error while running JPF";
						reasonUnknown = "[WARNING] Your bound is either too low to execute the program or you have an infinite loop";
					} else {
						toWrite += "INFO: There was an error while parsing the JPF output to Z3 formulas ...";
						reasonUnknown = "Unsupported operator by Z3 parser";
					}
				}
				return;
			} else if ((summaryNew == summaryOld && summaryNew == null) && Error == false) {
				toWrite += "INFO: The return statements are not impacted or the summaries are empty, thus the programs are equivalent";
				status = Status.UNSATISFIABLE;
				return;
			}
			toWrite += "-------------------The Z3 formula for the old method (z3 smt format) -------------------------\n";
			toWrite += summaryOld.toString();
			toWrite += "\n-----------------------------------------------------------------------------------------------\n";
			toWrite += "\n-------------------The Z3 formula for the new method ------------------------------------------\n";
			toWrite += summaryNew.toString();
			toWrite += "\n-----------------------------------------------------------------------------------------------\n";
			//////////////
			uFunctionsNew.putAll(parser.uFunctions());
			variables = parser.varNames();
			functionsInstances = parser.functionInstances();
			procCalls = parser.getInterprocCalls();
			//here maybe add everything to the solver, not just the final thing
			final BoolExpr t = (context.mkNot(context.mkEq(summaryOld, summaryNew)));
			toWrite += "\n-------------------The final Z3 formula for constraint solving -------------------------\n";
			toWrite += parser.declarations();
			toWrite += t.toString();
			toWrite += "\n-----------------------------------------------------------------------------------------------\n";
			if (Z3_TERMINAL)
				runZ3FromTerminal(t, parser);
			else {
				solver = context.mkSolver(or);
				if (DEBUG) System.out.println(Arrays.toString(context.getTacticNames()));
				Params p = context.mkParams();
				p.add("timeout", timeout);
				solver.setParameters(p);
				solver.add(summaryOld);
				solver.add(t);
				long start = System.nanoTime();
				status = solver.check();
				long end = System.nanoTime();
				z3time = end - start;
				if (DEBUG) System.out.println("Solver : " + status);
				if (status == Status.SATISFIABLE) {
					toWrite = "----------------------------------------------------Model (the counterexample in z3 smt2 format): ---------------------------------\n" + solver.getModel().toString()
							+ "\n-----------------------------------------------------------------------------------------------\n"
							+ "\n" + toWrite;
				} else if (status == Status.UNKNOWN) {
					reasonUnknown = solver.getReasonUnknown();
				}
			}
		}

		/**
		 * This function runs Z3 constraint solver from the terminal
		 * @param t the boolean expression to solve
		 * @param parser a Z3 parser object
		 * @throws IOException
		 */
		public void runZ3FromTerminal(final BoolExpr t,AbstractSymParser parser) throws IOException {
			declarations = parser.declarations()+((SymParserSMTLib)parser).functionsDefinitions();
			this.firstSummary = SymbolicExecutionRunner.this.firstSummary;
			this.secondSummary = SymbolicExecutionRunner.this.secondSummary;
			File expr = new File(path+newFileName+"ToSolve.txt");
			if(!expr.exists())
				expr.createNewFile();
			BufferedWriter bw2 = new BufferedWriter(new FileWriter(expr));
			String toSolve = parser.declarations()+((SymParserSMTLib) parser).functionsDefinitions()+"(assert ("+firstSummary+"))\n(assert (not (= ("+firstSummary+") ("
					+secondSummary+"))))\n(check-sat-using (then smt (par-or simplify aig solve-eqs qfnra-nlsat)))\n(get-info:reason-unknown)\n(get-model)";
			bw2.write(toSolve);
			bw2.close();
			String mainCommand = z3+" -smt2 " + path+newFileName+"ToSolve.txt -T:"+timeout/1000;
			if (DEBUG) System.out.println(mainCommand);
			long start = System.nanoTime();
			Process p1 = Runtime.getRuntime().exec(mainCommand);
			long end = System.nanoTime();
			z3time = end - start;
			BufferedReader in = new BufferedReader(new InputStreamReader(p1.getInputStream()));
			BufferedReader err = new BufferedReader(new InputStreamReader(p1.getErrorStream()));
			String line = null;
			String answer = in.readLine();
			if(answer == null){
				status = Status.UNKNOWN;
				String error = err.readLine();
				reasonUnknown = (answer == null)?"Error while running z3"+((error != null)?" : "+error:""):answer;
			}
			else if(answer.equals("timeout")){
				//maybe read err line ?
				status = Status.UNKNOWN;
				reasonUnknown = "timeout";
			}
			else {
				String reason = in.readLine();
				String model = "";
				while ((line = in.readLine()) != null) {
					model += line+"\n";
				}
				switch (answer) {
					case "sat":
						status = Status.SATISFIABLE;
						toWrite = "\n\n----------------------------------------------------Model (the counterexample in z3 smt2 format): ---------------------------------\n" + model
						+ "\n-----------------------------------------------------------------------------------------------\n"+ toWrite;;
						break;
					case "unsat":
						status = Status.UNSATISFIABLE;
						break;
					case "unknown":
						status = Status.UNKNOWN;
						if (reason != null)
							reason = reason.replace(":reason-unknown ", "");
						reasonUnknown = reason;
						break;
				}
			}
			in.close();
			err.close();
			if(DEBUG) System.out.println("Solver : "+status);
		}

		public BoolExpr functionalDelta(){
			BoolExpr delta = this.context.mkAnd(this.summaryOld,this.context.mkNot(this.summaryNew));
			return delta;
		}
	}

	/**
	 * This functions creates the .jpf files for symbolic execution
	 * @throws IOException
	 */
	public void creatingJpfFiles() throws IOException{
		String JPFMethodInputs=createSymbolicInputParametersForInstrumentedJPF();
		String fixed=
        "classpath="+classpath+" \n"+
		"symbolic.min_int="+this.minInt+"\n"+
        "symbolic.max_int="+this.maxInt+"\n"+
        "symbolic.min_long="+this.minLong+"\n"+
        "symbolic.max_long="+this.maxLong+"\n"+
        "symbolic.min_double="+this.minDouble+"\n"+
        "symbolic.max_double="+this.maxDouble+"\n"+
		"symbolic.debug = false \n"+
		"symbolic.optimizechoices = false \n"+
		//"search.class = .search.heuristic.BFSHeuristic \n"+
		"symbolic.lazy=on \n"+
		"symbolic.arrays=true \n"+
		"symbolic.strings = true \n"+
        "symbolic.dp="+this.SMTSolver+" \n"+
		"symbolic.string_dp_timeout_ms=" + this.timeout+"\n"+
		"search.depth_limit="+this.bound+"\n"+
		"listener = gov.nasa.jpf.symbc.SymbolicListener \n"+
		"search.multiple_errors=true \n";

		File newFile = new File(path+this.oldFileName+".jpf");
		newFile.getParentFile().mkdir();
		if(!newFile.exists())
			newFile.createNewFile();
		FileWriter fwOld=new FileWriter(newFile);
		BufferedWriter writerOld=new BufferedWriter(fwOld);
		String target="target = "+packageName+"."+this.oldFileName+"\n";
		String symbolic_method="symbolic.method = "+packageName+"."+oldFileName+"."+targetMethod+JPFMethodInputs+"\n";
		String jpfString=target+symbolic_method+fixed;
		writerOld.write(jpfString);
		writerOld.close();
		fwOld.close();
		newFile = new File(path+this.newFileName+".jpf");
		newFile.getParentFile().mkdir();
		if(!newFile.exists())
			newFile.createNewFile();
		FileWriter fwNew=new FileWriter(newFile);
		BufferedWriter writerNew=new BufferedWriter(fwNew);
		target="target = "+this.packageName+"."+this.newFileName+"\n";
		symbolic_method="symbolic.method = "+packageName+"."+newFileName+"."+targetMethod+JPFMethodInputs+"\n";
		jpfString=target+symbolic_method+fixed;
		writerNew.write(jpfString);
		writerNew.close();
		fwNew.close();;
	}

	/**
	 * This function creates the proper JPF representation for the target method
	 * @return (sym#sym#sym) for a method with 3 arguments
	 */
	public String createSymbolicInputParametersForInstrumentedJPF() {
		//(sym#sym#sym#sym#sym#sym#sym#sym)
   	    String result ="(";
        ////////////////////////////////////////
        //adding input parameters
		if(methodInputs>0) {
			for (int i = 0; i < methodInputs - 1; i++) {
				result = result + "sym#";
			}
			result = result + "sym";
		}
     	////////////////////////
        result =result+")";
	    return result;
	}

	/**
	 * This functions runs JPF on both programs
	 */
	public void runningJavaPathFinder() throws IOException{
			runningOnProgram( oldFileName);
			runningOnProgram( newFileName);
	}

	/**
	 * This function runs JPF on a program
	 * @param fileName the program
	 * @throws IOException
	 */
	public void runningOnProgram(String fileName) throws IOException {

		String mainCommand = "java -jar -Djava.library.path="+ dp +" "+jpf_core+"/build/RunJPF.jar "
				+ path+fileName+".jpf";

		if(DEBUG) System.out.println(mainCommand);
		Process p = Runtime.getRuntime().exec(mainCommand);
		BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
		BufferedReader err = new BufferedReader(new InputStreamReader(p.getErrorStream()));
		FileWriter fw = new FileWriter(path+fileName+"JPFOutput.txt");
		BufferedWriter bw = new BufferedWriter(fw);
		String line = null;
		while((line = in.readLine()) != null)
			bw.write(line+"\n");
		bw.close();
		fw.close();
		in.close();
		fw = new FileWriter(path+fileName+"JPFError.txt");
		bw = new BufferedWriter(fw);
		while((line = err.readLine()) != null)
			bw.write(line+"\n");
		bw.close();
		fw.close();
		err.close();
	}


	/** Function to run JPF-symbc + Z3 constraint solving **/
	public SMTSummary createSMTSummary() throws IOException{
		SMTSummary result = new SMTSummary();
		result.checkEquivalence();
		return result;
	}


	/**
	 * This function creates a Z3 input from JPF output
	 * @param fileName the file for the output
	 * @param parser a Z3 parser object
	 * @return a BoolExpr (Z3 object)
	 * @throws IOException
	 */
	public BoolExpr createSMTSummaryProgram(String fileName,SymParser parser) throws IOException {
		File file = new File(path + fileName + "JPFOutput.txt");
		BufferedReader br = new BufferedReader(new FileReader(file));
		String st;
		Context context=parser.context();
		int index = 0;
		boolean reachedEnd = false;
		boundEnough = true;
		BoolExpr previousSum=null, TotalSum=null;
		while((st=br.readLine()) != null){
			if(st.isEmpty())
				continue;
			if(st.contains("Method Summaries")){
				reachedEnd = true;
				//Here if Error= true, then the loop bound might be too low
				if(Error == true){
					boundEnough = false;
				}
				break;
			}
			if (st.contains("Summary")) {
				index++;
				Error = false;
				st = br.readLine();
				BoolExpr prevPCs = null, currentPC = null, pathSummary = null;
				if (st != null) {
					if (st.startsWith("PC is")) {
						st = br.readLine();
					}
					if (st != null) {
						while (st != null && !st.contains("Ret_0_SYM")) {
							String constraint = obtainConstraint(st);
							//parsedConstraints.add(constraint);
							if (constraint != null) {
								currentPC = parser.parseConstraint(constraint);
								if (prevPCs != null)
									currentPC = context.mkAnd(prevPCs, currentPC);
								prevPCs = currentPC;
							}
							st = br.readLine();
						} // I am return statement
						if (st !=null) {
							String returnConstraint = obtainConstraint(st);
							if (returnConstraint != null) {
								BoolExpr ret = parser.parseConstraint(returnConstraint);
								if (currentPC != null)
									pathSummary = context.mkAnd(currentPC, ret);
								else
									pathSummary = ret;
							} else {
								pathSummary = null;
							}
						}
					}
				}// we are done with the path summary of this path => pathSystem.out.println(index + pathSummary.toString());
				if (previousSum != null && pathSummary != null) {
					TotalSum = context.mkOr(previousSum, pathSummary);
					previousSum = TotalSum;
				}
				else if (previousSum == null && pathSummary != null) {
					previousSum = pathSummary;
					TotalSum = previousSum;
				}
			} //we update the total summary with the summary of this path
		}//we reach end of the file
		if(!reachedEnd || Error) {
			Error = true;
			return null;
		}
		return TotalSum; // (pc1 ^ ret1 ) or (pc2 ^ ret2)

	}

	/**
	 * This functions creates a Z3 input from JPF output
	 * @param fileName the file for the output
	 * @param parser a Z3 parser that works on strings
	 * @return
	 * @throws IOException
	 */
	public BoolExpr createSMTSummaryProgram(String fileName, SymParserSMTLib parser) throws IOException {
		File file = new File(path + fileName + "JPFOutput.txt");
		BufferedReader br = new BufferedReader(new FileReader(file));
		String st;
		Context context=parser.context();
		int index = 0;
		reachedEnd = false;
		boundEnough = true;
		try {
			String previousSum = null, TotalSum = null;
			while ((st = br.readLine()) != null) {
				if (st.contains("Method Summaries")) {
					if(Error == true){
						boundEnough = false;
					}
					reachedEnd = true;
					break;
				}
				if (st.isEmpty())
					continue;
				if (st.contains("Summary")) {
					Error = false;
					index++;
					st = br.readLine();
					String prevPCs = null, currentPC = null, pathSummary = null;
					if (st != null) {
						if (st.startsWith("PC is")) {
							st = br.readLine();
						}
						if (st != null) {
							while (st != null && !st.contains("Ret_0_SYM")) {
								String constraint = obtainConstraint(st);
								//parsedConstraints.add(constraint);
								if (constraint != null) {
									currentPC = parser.parseConstraint(constraint);
									if (prevPCs != null)
										currentPC = "and ( " + prevPCs + ") ( " + currentPC + " )";
									prevPCs = currentPC;
								}
								st = br.readLine();
							} // I am return statement
							if (st != null) {
								String returnConstraint = obtainConstraint(st);
								if (returnConstraint != null) {
									String ret = parser.parseConstraint(returnConstraint);
									if (currentPC != null)
										pathSummary = "and ( " + currentPC + " ) ( " + ret + " )";
									else
										pathSummary = ret;
								} else {
									pathSummary = null;
								}
							}
						}
					}// we are done with the path summary of this path => pathSystem.out.println(index + pathSummary.toString());
					if (previousSum != null && pathSummary != null) {
						TotalSum = "or ( " + previousSum + ") ( " + pathSummary + " )";
						previousSum = TotalSum;
					} else if (previousSum == null && pathSummary != null) {
						previousSum = pathSummary;
						TotalSum = previousSum;
					}
				} //we update the total summary with the summary of this path
			}//we reach end of the file

			if(Error || !reachedEnd){
				Error = true;
				return null;
			}
			if(firstSummary == "")
				firstSummary = TotalSum;
			else secondSummary = TotalSum;
			if(TotalSum == null)
				return null;
			TotalSum = parser.functionsDefinitions()+" (assert ( "+TotalSum+" ))";
			if(DEBUG) System.out.println(TotalSum);
			Object[] func = parser.varDecl().values().toArray();
			Symbol[] symbols = new Symbol[func.length];
			FuncDecl[] functions = new FuncDecl[func.length];
			for(int i = 0; i<functions.length;i++) {
				symbols[i] = ((FuncDecl)func[i]).getName();
				functions[i] = (FuncDecl)func[i];
			}
			if(DEBUG)System.out.println(Arrays.toString(symbols)+"  "+Arrays.toString(functions));
			if(DEBUG)System.out.println(TotalSum);
			this.terminalInput += TotalSum+"\n";
			BoolExpr summary = context.parseSMTLIB2String(TotalSum, null, null, symbols, functions)[0];
			return summary;
		}
		catch (Exception e){
			Error = true;
			return null;
		}
	}

	/**
	 * This functions returns eventual errors/exceptions from running JPF-symbc
	 * @param fileName source file
	 * @return
	 */
	public String parseErrorFile(String fileName){
		try {
			File file = new File(path + fileName + "JPFError.txt");
			BufferedReader br = new BufferedReader(new FileReader(file));
			String st;
			while((st = br.readLine())!=null){
				if(st.startsWith("java.") && (st.contains("Error") || st.contains("Exception")));
					return st;
			}
		}
		catch (Exception e){
			if(DEBUG)
				e.printStackTrace();
		}
		return "";
	}

	/**
	 * This is a helper method to parse a JPF constraint
	 * @param st a JPF constraint as a string
	 * @return
	 */
	public String obtainConstraint(String st){
		String[] split=st.split(":")[1].split("&&");
		return split[0];
	}

	public String obtainReturn(String st) {
		return st.split("Return is: ")[1];
	}

}
