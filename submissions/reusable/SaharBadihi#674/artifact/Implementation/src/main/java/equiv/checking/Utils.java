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
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.Node;
import com.github.javaparser.ast.NodeList;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.MethodDeclaration;
import com.github.javaparser.ast.body.TypeDeclaration;
import com.github.javaparser.ast.nodeTypes.NodeWithBody;
import com.github.javaparser.ast.stmt.*;
import javafx.util.Pair;

import javax.tools.JavaCompiler;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;
import javax.tools.ToolProvider;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;

public interface Utils {
    /** This is an helper interface with global variables and helper methods **/
    boolean DEBUG = false;
    boolean Z3_TERMINAL = true;
    String ANSI_GREEN = "\u001B[32m", ANSI_RESET="\u001B[0m";
    String ANSI_RED = "\u001B[31m";
    HashSet<String> mathFunctions = new HashSet<String>(Arrays.asList("cos","sin","pow","exp","sqrt","pow","sqrt","asin","acos","atan","atan2","abs","log","tan"));

    /**
     * To compile a java program
     * @param classpath the destination
     * @param newFile the program
     * @throws IOException
     */
    default void compile(String classpath,File newFile) throws IOException {
        File path = new File(classpath);
        path.getParentFile().mkdirs();
        //Think about whether to do it for the classpaths in the tool as well (maybe folder instrumented not automatically created)
        if(!path.exists())
            path.mkdir();
        ArrayList<String> options = new ArrayList<>();
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        StandardJavaFileManager fileManager = compiler.getStandardFileManager(null, null, null);
        options.addAll(Arrays.asList("-g", "-d", classpath));
        Iterable<? extends JavaFileObject> cpu =
                fileManager.getJavaFileObjectsFromFiles(Arrays.asList(new File[]{newFile}));
        compiler.getTask(null, fileManager, null, options, null, cpu).call();
    }

    /**
     * To extract the number of loops from a program
     * @param methodPath the program
     * @return
     * @throws FileNotFoundException
     */
    static int extractLoops(String methodPath) throws FileNotFoundException {
        ClassOrInterfaceDeclaration c=(ClassOrInterfaceDeclaration)StaticJavaParser.parse(new File(methodPath)).getType(0);
        MethodDeclaration method=(MethodDeclaration)c.getMethods().get(0);
        int res = 0;
        if(method.getBody().isPresent()) {
            BlockStmt root = method.getBody().get().asBlockStmt();
            res = extractStatsAux(root);
        }
        return res;
    }

   static int extractStatsAux(Node statement) {
        int stats = 0;
        if (statement != null) {
            NodeList<Statement> statements;
            if (statement instanceof BlockStmt)
                statements = ((BlockStmt) statement).getStatements();
            else if(statement instanceof SwitchEntry)
                statements = ((SwitchEntry) statement).getStatements();
            else if(statement instanceof Statement){
                BlockStmt block = new BlockStmt(new NodeList<Statement>((Statement)statement));
                statements = block.getStatements();
            }
            else return stats;
            for (Statement st : statements) {
                if (isLoop(st)) {
                    int  inside = extractStatsAux(((NodeWithBody)st).getBody());
                    stats +=  1 + inside;
                }
                else if (isControl(st)) {
                    if (st instanceof IfStmt) {
                        IfStmt ist = st.asIfStmt();
                        // BlockStmt trueControlled = new BlockStmt(new NodeList<>(ist.getThenStmt()));
                        Statement trueControlled = ist.getThenStmt();
                        int res = extractStatsAux(trueControlled);
                        if (ist.hasElseBranch()) {
                            //BlockStmt falseControlled = new BlockStmt(new NodeList<>(ist.getElseStmt().get()));
                            Statement falseControlled = ist.getElseStmt().get();
                            int res2 = extractStatsAux(falseControlled);
                            stats += res2;
                        }
                        stats += res;
                    } else if (st instanceof SwitchStmt) {
                        SwitchStmt switchStmt = st.asSwitchStmt();
                        for (SwitchEntry entry : switchStmt.getEntries()) {
                            int res = extractStatsAux(entry);
                            stats += res;
                        }
                    } else if (st instanceof TryStmt) {
                        TryStmt tryStmt = st.asTryStmt();
                        for (CatchClause c : tryStmt.getCatchClauses()) {
                            int res = extractStatsAux(c.getBody());
                            stats += res;
                        }
                        int res = extractStatsAux(tryStmt.getTryBlock());
                        int res2 = 0;
                        if(tryStmt.getFinallyBlock().isPresent())
                            res2 = extractStatsAux(tryStmt.getFinallyBlock().get());
                        stats += res + res2;
                    }
                }
            }
        }
        return stats;
    }

    static boolean isLoop(Statement stmt) {
        return (stmt instanceof NodeWithBody);
    }

   static boolean isControl(Statement stmt) {
        return (stmt instanceof IfStmt || stmt instanceof TryStmt || stmt instanceof SwitchStmt);
    }
}
