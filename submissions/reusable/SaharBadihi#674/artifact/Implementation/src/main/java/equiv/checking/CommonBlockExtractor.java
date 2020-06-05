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

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.ast.NodeList;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.nodeTypes.NodeWithBody;
import com.github.javaparser.ast.stmt.*;


import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;

public class CommonBlockExtractor {
	/** This class extracts the common blocks between two methods **/
	public ArrayList<ArrayList<Integer>> blocks;
	public MethodDeclaration root1,root2;
	private String path;

	public CommonBlockExtractor(String path){
		this.path = path;
	}

	/**
	 * This function extracts the common blocks between two programs and save it to a file
	 * @param oldProcPath, the path to the first program
	 * @param newProcPath, the path to the second program
	 * @param changedLines, the lines that were changed between the two programs
	 * @return the path to file where the common blocks are saved
	 * @throws IOException
	 */
	public String saveCommonBlocks(String oldProcPath, String newProcPath, ArrayList<Integer> changedLines) throws IOException {
		ClassOrInterfaceDeclaration c1=(ClassOrInterfaceDeclaration)StaticJavaParser.parse(new File(oldProcPath)).getType(0);
		ClassOrInterfaceDeclaration c=(ClassOrInterfaceDeclaration)StaticJavaParser.parse(new File(newProcPath)).getType(0);
		root2=(MethodDeclaration)c.getMethods().get(0);
		root1 =(MethodDeclaration)c1.getMethods().get(0);
		int line = root2.getBegin().get().line;
		blocks = saveCommonBlocksAux(root2.getBody().get(),line,changedLines);
		String blockPath=path+File.separator+"block"+c.getNameAsString()+".txt";
		File blockInfo=new File(blockPath);
        blockInfo.getParentFile().mkdir();
		if(!blockInfo.exists())
			blockInfo.createNewFile();
		FileWriter writer=new FileWriter(blockInfo);
		String toWrite="";
		if(blocks.size()>0){
			blocks.get(0).remove(new Integer(line));
		}
		for(int i=1;i<=blocks.size();i++){
			ArrayList<Integer> block=blocks.get(i-1);
			toWrite+=i+":"+block.get(0)+","+block.get(block.size()-1)+"\n";
		}
		writer.write(toWrite);
		writer.close();
		changedLines.remove(new Integer(-1));
		//return blocks;
		return blockPath;
	}

	/**
	 * This is an auxiliary function to create the common blocks given
	 * @param controlledStatements a control statement
	 * @param controlLocation a line number
	 * @param changes the list of changes
	 * @return the list of blocks between two programs
	 */
	private static ArrayList<ArrayList<Integer>> saveCommonBlocksAux(Statement controlledStatements, int controlLocation, ArrayList<Integer> changes){
		ArrayList<ArrayList<Integer>> blocks = new ArrayList<>();
		final ArrayList<Integer>[] block = new ArrayList[]{new ArrayList<>()};
		if(controlledStatements!=null) {
			if (!(controlledStatements instanceof BlockStmt))
				controlledStatements = new BlockStmt(new NodeList<>(controlledStatements));
			for (Statement st : controlledStatements.asBlockStmt().getStatements()) {
				if (!(st instanceof ReturnStmt)) {
					int i = st.getBegin().get().line;
					if (isControlSmt(st)) {
						com.github.javaparser.ast.stmt.Statement trueControlled;
						com.github.javaparser.ast.stmt.Statement falseControlled = null;
						int line = st.getBegin().get().line;
						if (st instanceof IfStmt) {
							IfStmt ist = st.asIfStmt();
							trueControlled = ist.getThenStmt();
							if (ist.hasElseBranch()){
								falseControlled = ist.getElseStmt().get();
							}
						}
						else trueControlled = ((NodeWithBody) st).getBody();
						ArrayList<ArrayList<Integer>> trueCommon = saveCommonBlocksAux(trueControlled, st.getBegin().get().line, changes);

						ArrayList<ArrayList<Integer>> falseCommon = saveCommonBlocksAux(falseControlled, st.getBegin().get().line, changes);
						boolean seenReturn = changes.contains(-1);
						if(seenReturn)
							changes.remove(new Integer(-1));
						if (!changes.contains(i) && !seenReturn) {
							block[0].add(i);
							for (ArrayList<Integer> b : trueCommon)
								if(!b.isEmpty()) block[0].addAll(b);
							for (ArrayList<Integer> b : falseCommon) {
								if(!b.isEmpty()) block[0].addAll(b);
							}
							int end = st.getEnd().get().line;
							if(!(block[0].contains(end)))
								block[0].add(end);

						} else {
							if(!block[0].isEmpty())
								blocks.add(block[0]);
							blocks.addAll(trueCommon);
							blocks.addAll(falseCommon);
							block[0] = new ArrayList<>();
						}
					} else {
						if (!changes.contains(i))
							block[0].add(i);
						else {
							if(!block[0].isEmpty())
								blocks.add(block[0]);
							block[0] = new ArrayList<>();
						}
					}
					if (changes.contains(i)) {
						if (!(changes).contains(controlLocation)) {
							changes.add(controlLocation);
						}
					}
				}
				else changes.add(-1);
			}
		}
		if(!(block[0].isEmpty()))
			blocks.add(block[0]);
		return blocks;
	}

	/**
	 * This function checks whether the given statement is a control statement
	 * @param st a statement
	 * @return true if the statement controls other statement, false otherwise
	 */
	public static boolean isControlSmt(Statement st){
		//can be completed : try,foreach, break,continue
		return (st instanceof IfStmt || st instanceof ForStmt || st instanceof WhileStmt || st instanceof DoStmt);
	}

	public static void main(String[] args) throws IOException {
		CommonBlockExtractor common = new CommonBlockExtractor("src/examples/demo/benchmarks/tsafe/Eq/");
		ArrayList<Integer> changes = new ArrayList<>();
		changes.add(17);
		 common.saveCommonBlocks("src/examples/demo/benchmarks/tsafe/Eq/newV.java","src/examples/demo/benchmarks/tsafe/Eq/test2.java",changes);
		//for(ArrayList<Integer> block : common.blocks)
			//System.out.println(block);
	}

}
