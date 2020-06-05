//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package equiv.checking.symparser;

import com.microsoft.z3.Context;
import com.microsoft.z3.Expr;
import com.microsoft.z3.FuncDecl;
import equiv.checking.Utils;
import javafx.util.Pair;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

public class AbstractSymParser {
    protected SymLexer reader;
    protected String spfOutput;
    protected final Context context;
    protected String declarations;
    protected boolean noUFunctions;
    //Needed to reuse the same variables throughout the formulas
    protected final HashSet<String> mathFunctions;
    protected HashMap<Expr,Integer> uFunctions;
    protected HashSet<Expr> interprocCalls;
    protected Map<String, Expr> variables;
    //All the uninterpreted functions mapped to their declaration
    protected Map<String, Pair<FuncDecl, HashSet<Expr>>> allInstances;


    public AbstractSymParser(Context context){
        this.context = context;
        declarations = "";
        uFunctions = new HashMap<>();
        allInstances = new HashMap<>();
        variables = new HashMap<>();
        interprocCalls = new HashSet<>();
        mathFunctions = Utils.mathFunctions;
        noUFunctions = true;
        //initMathFunctions();
    }

    public void initMathFunctions(){
        mathFunctions.add("cos"); //yes
        mathFunctions.add("sin"); //yes
        mathFunctions.add("pow"); //yes
        mathFunctions.add("sqrt"); //yes
        mathFunctions.add("asin");
        mathFunctions.add("exp"); //yes
        mathFunctions.add("asin");
        mathFunctions.add("acos");
        mathFunctions.add("atan");
        mathFunctions.add("atan2");
        mathFunctions.add("abs");
        mathFunctions.add("log"); //yes
        mathFunctions.add("tan"); //yes
    }

    public Context context() {
        return context;
    }

    public HashMap<Expr, Integer> uFunctions() {
        return uFunctions;
    }

    public String declarations(){
        return declarations;
    }

    public void emptyUF() {
        uFunctions = new HashMap<>();
    }

    public Map<String, Expr> varNames() {
        return variables;
    }

    public HashSet<Expr> getInterprocCalls(){
        return interprocCalls;
    }

    public Map<String, Pair<FuncDecl, HashSet<Expr>>> functionInstances() {
        return allInstances;
    }

    public boolean noUFunctions() {
        return noUFunctions;
    }
}
