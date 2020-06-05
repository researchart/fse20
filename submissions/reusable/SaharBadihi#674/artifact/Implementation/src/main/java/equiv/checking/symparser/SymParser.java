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
import javafx.util.Pair;

import java.util.*;
import java.util.regex.Pattern;

import static equiv.checking.Utils.DEBUG;


public class SymParser extends AbstractSymParser{

    public SymParser(Context context) {
        super(context);
    }


    //Grammar
    //F :=  E (=|<=|>=|<|>) E
    //var := [a-z][A_Z]*
    //E := E + T | E - T | T
    //T := T * F | T / F | F
    //F := var | U | (E) | -F
    //U /:= var(args)
    //args := empty | F(,F)*

    public BoolExpr parseConstraint(String spf) {
        spfOutput = spf;
        reader = new SymLexer(spf);
        reader.nextChar();
        //each line is a formula
        try {
            BoolExpr formula = parseFormula();
            //Check that the formula is Empty, not necessary
            // if(reader.current != -1) throw new Exception("Syntax error end");
            if(DEBUG) System.out.println("Parsed formula !");
            return formula;

        } catch (Exception e) {
            e.printStackTrace();
        }
        if(DEBUG) System.out.println("Nope !");
        // if(pos< str)
        return null;
    }

    public BoolExpr parseFormula() throws Exception {
        ArithExpr left = parseArithm();
        // ArithExpr left=parseFactor();
        if (reader.eat('='))
            return context.mkEq(left, parseArithm());
        if (reader.eat('!')) {
            if (reader.eat('='))
                return context.mkNot(context.mkEq(left, parseArithm()));
            throw new Exception("Syntax error");
        }
        if (reader.eat('<')) {
            if (reader.eat('='))
                return context.mkLe(left, parseArithm());
            return context.mkLt(left, parseArithm());

        }
        if (reader.eat('>')) {
            if (reader.eat('='))
                return context.mkGe(left, parseArithm());
            return context.mkGt(left, parseArithm());
        }
        throw new Exception("Syntax error");

    }

    public ArithExpr parseArithm() throws Exception {
        ArithExpr left = parseTerm();
        if (reader.eat('+')) {
            left = context.mkAdd(left, parseArithm());
        } else if (reader.eat('-')) {
            left = context.mkSub(left, parseArithm());
        }
        return left;
    }

    public ArithExpr parseTerm() throws Exception {
        ArithExpr left = parseFactor();
        if (reader.eat('*')) {
            return context.mkMul(left, parseTerm());
        }
        if (reader.eat('/')) {
            return context.mkDiv(left, parseTerm());
        }
        if (reader.eat('%')) {
            //does not accept arithmetic expressions, only integer expressions
            return context.mkMod((IntExpr) left, (IntExpr) parseTerm());
        }
        if(reader.eat('^')){
            return context.mkPower(left,parseTerm());

        }
        return left;
        //else throw new Exception("Syntax error");
    }


    public ArithExpr parseFactor() throws Exception {
        if (reader.eat('-'))
            return parseFactor();
        ArithExpr e;
        int start = reader.index;
        if (reader.eat('(')) {
            e = parseArithm();
            reader.eat(')');
            return e;
        }
        //check for the closing brace maybe not the best way to do it
        while (reader.current != ' ' && reader.current != -1 && reader.current != '(' && reader.current != ',' && reader.current != ')')
            reader.nextChar();
        String var = spfOutput.substring(start, reader.index);
        //System.out.println("Variable : "+var);
        return (ArithExpr) parseElem(var);
    }


    public Expr parseElem(String var) throws Exception {
        if (var.startsWith("CONST")) {
            //maybe make real or make double instead !!
            String num = var.split("CONST_")[1];
            if (num.contains(".")) return context.mkReal(num);
            return context.mkInt(Integer.parseInt(var.split("CONST_")[1]));
        } else if (var.startsWith("UF_") || var.startsWith("AF_")) {
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

    protected Expr parseMathFunc(String funcName) throws Exception{
        //TODO
        reader.eat('(');
        Object[] args = parseArgs().toArray();
        reader.eat(')');
        int length = (args == null)?0:args.length;
        Expr[] params = new Expr[length];
        Symbol[] arguments = new Symbol[length];
        FuncDecl[] funcDecls = new FuncDecl[length];
        Sort[] typeArgs = new Sort[arguments.length];
        //String formula = "(assert ( = ("+funcName +" ";
        for (int i = 0; i < length; i++) {
            Expr e = (Expr)args[i];
            params[i] = e;
            arguments[i] = context.mkSymbol(e.toString());
            typeArgs[i] = params[i].getSort();
            funcDecls[i] = e.getFuncDecl();
        }
        if(funcName.equals("pow")){
            return context.mkPower((ArithExpr)params[0],(ArithExpr)params[1]);
        }
        else {
            FuncDecl f = context.mkFuncDecl(funcName, typeArgs, context.mkRealSort());
            declarations += f.toString() + "\n";
            if (DEBUG) System.out.println(f.toString());
            return context.mkApp(f, params);
        }
    }

    protected Expr parseFunc(String funcName) throws Exception {
        String[] name = funcName.split("_SYM");
        if (name.length == 2) {
            boolean actualUF = name[0].startsWith("UF_");
            if(actualUF)
                noUFunctions = false;
            reader.eat('(');
            Expr[] arguments = null;
            if (reader.eat(')')) {
                arguments = new Expr[0];
            } else {
                Object[] args = parseArgs().toArray();
                arguments = new Expr[args.length];
                for (int i = 0; i < args.length; i++) {
                    Object o = args[i];
                    arguments[i] = (Expr) o;
                }
                reader.eat(')');
            }

            FuncDecl f = null;
            String func = name[0];
            Pair<FuncDecl, HashSet<Expr>> instances = allInstances.get(name[0]);
            if (instances != null) {
                int size = instances.getKey().getDomainSize();
                if (size == arguments.length) {
                    f = instances.getKey();
                } else {
                    //Same function with different number of parameters
                    func += "*";
                }
            }
            if (f == null) {
                Sort[] typeArgs = new Sort[arguments.length];
                for (int i = 0; i < arguments.length; i++) {
                    typeArgs[i] = arguments[i].getSort();
                }
                Sort ret = null;
                if (name[1].equals("INT"))
                    ret = context.mkIntSort();
                else ret = context.mkRealSort();
                f = context.mkFuncDecl(func, typeArgs, ret);
                declarations += f.toString() + "\n";
                if (DEBUG) System.out.println(f.toString());
                if(actualUF) {
                    instances = new Pair(f, new HashSet<>());
                    allInstances.put(func, instances);
                }
            }
            Expr e = context.mkApp(f, arguments);
            if (actualUF) {
                instances.getValue().add(e);
                //Expr bound = context.mkBound(instances.getValue().size(),)
                Integer occurences = uFunctions.get(e);
                if (occurences == null)
                    uFunctions.put(e, 1);
                else uFunctions.put(e, occurences + 1);
            }
            else
                interprocCalls.add(e);
            return e;
        }
        return null;
    }

    public ArrayList<Expr> parseArgs() throws Exception {
        ArrayList<Expr> args = new ArrayList<>();
        args.add(parseFactor());
        if (reader.eat(',')) {
            args.addAll(parseArgs());
        }
        return args;
    }




    public Expr parseVar(String var) {
        String regex = "_[0-9]+_SYM";
        if(!var.contains("SYM"))
            return parseCast(var);
        String[] name = var.split(regex);
        return parseVariable(name);
    }

    public Expr parseCast(String string){
        String[] name = string.split("_");
        if(name[0].contains("REAL")){
            String var = "REAL_"+name[1].substring(0,1);
            if (!variables.containsKey(var)) {
                Expr e = context.mkRealConst(var);
                declarations+="(declare-fun "+e.toString()+" () Real)\n";
                variables.put(var, e);
                return e;
            }
            return variables.get(var);
        }
        String var = "INT_"+name[1].substring(0,1);
        if (!variables.containsKey(var)) {
            Expr e = context.mkIntConst(var);
            declarations+="(declare-fun "+e.toString()+" () Int)\n";
            variables.put(var, e);
            return e;
        }
        return variables.get(var);
    }

    public Expr parseVariable(String[] name) {
        if (name[1].contains("REAL")) {
            if (!variables.containsKey(name[0])) {
                Expr e = context.mkRealConst(name[0]);
                declarations+="(declare-fun "+e.toString()+" () Real)\n";
                variables.put(name[0], e);
                return e;
            }
            return variables.get(name[0]);
        } else {
            if (!variables.containsKey(name[0])) {
                Expr e = context.mkIntConst(name[0]);
                declarations+="(declare-fun "+e.toString()+" () Int)\n";
                variables.put(name[0], e);
                return e;
            }
            return variables.get(name[0]);
        }
    }


    public void createDecl(String name, String type) {
        if (!variables.containsKey(name)) {
            if (type.equals("int"))
                variables.put(name, context.mkIntConst(name));
            else
                variables.put(name, context.mkRealConst(name));
        }
    }

}