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

import com.microsoft.z3.*;
import equiv.checking.SymbolicExecutionRunner;
import javafx.util.Pair;

import java.util.*;
import java.util.regex.Pattern;

import static equiv.checking.Utils.DEBUG;


public class SymParserSMTLib extends AbstractSymParser{
    //Needed to reuse the same variables throughout the formulas
    protected HashMap<String,FuncDecl> variablesDeclaration;
    protected String functionsDefinitions;
    //The list of all observed uFunctions, we reset it for each program summary (sames as uIFunctions.keySet()).
    // We need it for functions that are defined only in this program since uIFunctions is kept across all programs
    //All the uninterpreted functions mapped to their declaration
    //probably to be changed since not needed anymore

    /**
     * Add parsing arrays in parseElem
     * Consider <- in the parse formula as well ? it's basically , array[i] becomes i, check how to do mutation ??
     * We have that val[i] is mapped to (select val i)
     * We have that val[i] <- a is mapped to (store val i a) which returns a new array with a at the pos i
     * If it is an array than [i] could be an index instead of just the addtional data added to every variable
     * @param context
     */


    public SymParserSMTLib(Context context) {
        super(context);
        variablesDeclaration = new HashMap<>();
        allInstances = new HashMap<>();
        interprocCalls = new HashSet<>();
        initFunctionDefinitions();
    }

    public void initFunctionDefinitions(){
        functionsDefinitions = "(define-fun exp ((x Real)) Real (^ 2.718281828459045 x)) \n" +
                "(define-fun sqrt ((x Real)) Real (^ 0.5 x)) \n" +
                "(declare-fun log (Real) Real) \n";
        //"(assert (forall ((x Real)) (= (log (exp x)) x))) \n "+
        //"(assert (forall ((x Real)) (= (exp (log x)) x))) \n";
        /*functionsDefinitions = "(define-fun exp ((x Real)) Real (^ 2.718281828459045 x)) \n" +
                "(define-fun sqrt ((x Real)) Real (^ 0.5 x)) \n";*/
    }

    public String functionsDefinitions(){
        return functionsDefinitions;
    }

    // I can give a list of function declarations and of symbol to the parse lib functions
    //To be checked


    //Grammar
    //F :=  E (=|<=|>=|<|>) E
    //var := [a-z][A_Z]*
    //E := E + T | E - T | T
    //T := T * F | T / F | F
    //F := var | U | (E) | -F
    //U /:= var(args)
    //args := empty | F(,F)*

    public Context context() {
        return context;
    }

    public Set<String> variableNames() {
        return variables.keySet();
    }

    public HashMap<String,FuncDecl> varDecl(){
        return variablesDeclaration;
    }

    public String parseConstraint(String spf) throws Exception {
        spfOutput = spf;
        if(spfOutput == null)
            return null;
        reader = new SymLexer(spf);
        reader.nextChar();
        //each line is a formula
        String formula = parseFormula();
            //Check that the formula is Empty, not necessary
            // if(reader.current != -1) throw new Exception("Syntax error end");
            if(DEBUG) System.out.println("Parsed formula !");
            return formula;
    }

    public String parseFormula() throws Exception {
        Pair<String,String> left = parseArithm();
        // ArithExpr left=parseFactor();
        if (reader.eat('='))
            return "= "+left.getValue()+" "+parseArithm().getValue()+"";
        if (reader.eat('!')) {
            if (reader.eat('='))
                return "not ( = "+left.getValue()+" "+parseArithm().getValue()+")";;
            throw new Exception("Syntax error");
        }
        if (reader.eat('<')) {
            if (reader.eat('='))
                return "<= "+left.getValue()+" "+parseArithm().getValue()+"";;
            return "< "+left.getValue()+" "+parseArithm().getValue()+"";

        }
        if (reader.eat('>')) {
            if (reader.eat('='))
                return ">= "+left.getValue()+" "+parseArithm().getValue()+"";;
            return "> "+left.getValue()+" "+parseArithm().getValue()+"";
        }
        throw new Exception("Syntax error");
    }

    public Pair<String,String> parseArithm() throws Exception {
        Pair<String,String> left = parseTerm();
        if (reader.eat('+')) {
            left = new Pair(left.getKey(),"+ "+left.getValue()+" "+parseArithm().getValue()+"");
        } else if (reader.eat('-')) {
            left = new Pair(left.getKey(),"- "+left.getValue()+" "+parseArithm().getValue()+"");
        }
        return left;
    }

    public Pair<String,String> parseTerm() throws Exception {
        Pair<String,String> left = parseFactor();
        if (reader.eat('*')) {
            return new Pair(left.getKey(),"* "+left.getValue()+" "+parseTerm().getValue()+"");
        }
        if (reader.eat('/')) {
            return new Pair(left.getKey(),"div "+left.getValue()+" "+parseTerm().getValue()+"");
        }
        if (reader.eat('%')) {
            //does not accept arithmetic expressions, only integer expressions
            return new Pair("Int","mod "+left.getValue()+" "+parseTerm().getValue()+"");
        }
        if(reader.eat('^')){
            return new Pair(left.getKey(),"^ "+left.getValue()+" "+parseTerm().getValue()+"");

        }
        return left;
        //else throw new Exception("Syntax error");
    }


    public Pair<String,String> parseFactor() throws Exception {
        if (reader.eat('-'))
            return parseFactor();
        String e ="";
        int start = reader.index;
        if (reader.eat('(')) {
            Pair<String, String> info = parseArithm();
            e = "( "+info.getValue()+" )";
            reader.eat(')');
            return new Pair(info.getKey(),e);
        }
        //check for the closing brace maybe not the best way to do it
        while (reader.current != ' ' && reader.current != -1 && reader.current != '(' && reader.current != ',' && reader.current != ')')
            reader.nextChar();
        String var = spfOutput.substring(start, reader.index);
        //System.out.println("Variable : "+var);
        return parseElem(var);
    }


    public Pair<String,String> parseElem(String var) throws Exception {
        if (var.startsWith("CONST")) {
            //maybe make real or make double instead !!

            String num = var.split("CONST_")[1];
            if (num.contains("E")) {// num 2.49958057E13
                String base = num.split("E")[0]; //base = 2.49958057
                String num2 = num.split("E")[1]; // num2 = 13
                num = "(* " +base +" (^ 10 (* -1 "+num2+")))";
            }
            if(var.contains("REAL"))
                return new Pair("Real",num);
            else
                return new Pair("Int",num);
        }
        else if (var.startsWith("UF_") || var.startsWith("AF_")) {
            //function
            return parseFunc(var);
        }
        else if (mathFunctions.contains(var)){
            return parseMathFunc(var);
        }
        else{
            //  (currentTime_1_SYMINT[-100]
            return parseVar(var);
        }
    }

    protected Pair<String,String> parseMathFunc(String funcName) throws Exception{
        //TODO
        reader.eat('(');
        ArrayList<Pair<String,String>> arguments = parseArgs();
        reader.eat(')');
        String formula = " ( ";
        if(funcName.equals("pow")){
            formula+= "^ ";
        }
        else formula+= funcName+" ";
        if(arguments != null && arguments.size()>0) {
            for (Pair<String, String> s : arguments) {
                formula += s.getValue() + " ";
            }
        }
        formula += ")";
        return new Pair("Real",formula);
    }

    protected Pair<String,String> parseFunc(String funcName) throws Exception {
        //I could store in the list all of the inputs from here using arguments and just take the uf_ thing
        String[] name = funcName.split("_SYM");
        String func = name[0];
        String formula = "";
        //here I need to check if the number of arguments of the list matches
        String sort = "(";
        if (name.length == 2) {
            if(func.startsWith("UF"))
                noUFunctions = false;
            ArrayList<Pair<String,String>> arguments;
            reader.eat('(');
            if (reader.eat(')')) {
                arguments = new ArrayList<>();
            }
            else {
                arguments = parseArgs();
                for(Pair<String,String> s : arguments) {
                    formula += s.getValue()+" ";
                    sort += s.getKey()+" ";
                }
                //formula = formula.substring(0,formula.length() - 1);
                reader.eat(')');
            }
            sort += ")";
            String ret = "";
            Sort retS = null;
            if (name[1].equals("INT")) {
                ret = "Int";
                retS = context.mkIntSort();
            }
            else{
                ret = "Real";
                retS = context.mkRealSort();
            }
            FuncDecl f = null, funcDecl = variablesDeclaration.get(func);
            if(funcDecl != null){
                int size = funcDecl.getDomainSize();
                if(size == arguments.size()){
                    f = funcDecl;
                }
                else{
                    func+="*";
                }
            }
            if(arguments.size() > 0){
                formula = " ( "+func+" "+formula+")";
            }
            else{
                formula = func+" "+formula;
            }

            if(f == null){
                Sort[] typeArgs = new Sort[arguments.size()];
                for (int i = 0; i < arguments.size(); i++) {
                    String type = arguments.get(i).getKey();
                    typeArgs[i] = (type.equals("Int"))?context.mkIntSort():context.mkRealSort();
                }
                f = context.mkFuncDecl(func,typeArgs,retS);
                declarations += "(declare-fun "+func+" "+sort+" "+ret + ")\n";
                variablesDeclaration.put(func,f);

            }
           /* Integer occurences = uFunctions.get(func);
            if (occurences == null)
                uFunctions.put(func, 1);
            else uFunctions.put(func, occurences + 1);*/
            return new Pair(ret,formula);
        }
        return null;
    }

    public ArrayList<Pair<String,String>> parseArgs() throws Exception {
        ArrayList<Pair<String,String>> args = new ArrayList<>();
        args.add(parseFactor());
        if (reader.eat(',')) {
            args.addAll(parseArgs());
        }
        return args;
    }




    public Pair<String,String> parseVar(String var) {
        String regex = "_[0-9]+_SYM";
        if(!var.contains("SYM"))
            return parseCast(var);
        String[] name = var.split(regex);
        return parseVariable(name);
    }

    public Pair<String,String> parseCast(String string){
        String[] name = string.split("_");
        if(name[0].contains("REAL")){
            String var = "REAL_"+name[1].substring(0,1);
            //To be checked
            if (!variables.containsKey(var)) {
                declarations += "(declare-fun " + var + " () Real)\n";
                Expr e = context.mkRealConst(var);
                variables.put(var,e);
                variablesDeclaration.put(var,e.getFuncDecl());
            }
            return new Pair("Real",var);
        }
        String var = "INT_"+name[1].substring(0,1);
        if (!variables.containsKey(var)) {
            declarations += "(declare-fun " + var + " () Int)\n";
            Expr e = context.mkIntConst(var);
            variables.put(var,e);
            variablesDeclaration.put(var,e.getFuncDecl());
        }
        return new Pair("Int",var);
    }

    public Pair<String,String> parseVariable(String[] name) {
        String ret = "Int";
        if (name[1].contains("REAL")) {
            if (!variables.containsKey(name[0])) {
                declarations+="(declare-fun "+name[0]+" () Real)\n";
                Expr e = context.mkRealConst(name[0]);
                variables.put(name[0],e);
                variablesDeclaration.put(e.toString(),e.getFuncDecl());
            }
            ret = "Real";
        } else {
            if (!variables.containsKey(name[0])) {
                declarations+="(declare-fun "+name[0]+" () Int)\n";
                Expr e = context.mkIntConst(name[0]);
                variables.put(name[0],e);
                variablesDeclaration.put(e.toString(),e.getFuncDecl());
            }
        }
        return new Pair(ret,name[0]);
    }


    public void createDecl(String name, String type) {
        if (!variables.containsKey(name)) {
            if (type.equals("int")){
                Expr e = context.mkIntConst(name);
                variables.put(name,e);
                variablesDeclaration.put(e.toString(),e.getFuncDecl());
            }
            else{
                Expr e = context.mkRealConst(name);
                variables.put(name,e);
                variablesDeclaration.put(e.toString(),e.getFuncDecl());
            }
        }
    }

}