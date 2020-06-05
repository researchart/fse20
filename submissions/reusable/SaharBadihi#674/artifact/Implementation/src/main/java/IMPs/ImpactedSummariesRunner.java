//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package IMPs;

import com.microsoft.z3.BoolExpr;
import com.microsoft.z3.Context;
import com.microsoft.z3.FuncDecl;
import com.microsoft.z3.Symbol;
import equiv.checking.SymbolicExecutionRunner;
import equiv.checking.symparser.AbstractSymParser;
import equiv.checking.symparser.SymParserSMTLib;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import static equiv.checking.Utils.DEBUG;

public class ImpactedSummariesRunner extends SymbolicExecutionRunner {
    /** This class runs symbolic execution for the Impacted tool **/
    ArrayList<Integer> impacted; //the list of impacted statements

    public ImpactedSummariesRunner(String path, String packageName,String oldFile, String newFile, String targetMethod, int methodInputs, ArrayList<Integer> impacted, ArrayList<Integer> impacted2,int bound, int timeout, String SMTSolver, int minint, int maxint, double mindouble, double maxdouble, long minlong, long maxlong,boolean parseFromSMTLib,boolean z3Terminal) {
        super(path,packageName,oldFile, newFile, targetMethod, methodInputs,bound, timeout, SMTSolver,  minint,  maxint,  mindouble,  maxdouble,  minlong,  maxlong,parseFromSMTLib,z3Terminal);
        this.impacted=new ArrayList<>(impacted);
    }

    public ImpactedSummariesRunner(String oldFile, String newFile, String targetMethod, int methodInputs, ArrayList<Integer> impacted, ArrayList<Integer> impacted2) {
        super(oldFile, newFile, targetMethod, methodInputs);
        this.impacted=new ArrayList<>(impacted);
    }

    /**
     * This functions parse a constraint if it is linked to an impacted statement, returns null otherwise
     * @param st a JPF constraint as a string
     * @return a string or null
     */
    @Override
    public String obtainConstraint(String st){
        //here we need to keep only what is impacted
        String[] split=st.split(":");
        //check if the line is in impacted
        if(impacted.contains(Integer.parseInt(split[0]))) {
            if(DEBUG)System.out.println("Contained " + split[0]+"  "+split[1]);
            return split[1].split("&&")[0];
        }
       return null;
    }

    /**
     * This functions parse a return constraint if it is linked to an impacted statement, returns null otherwise
     * @param st
     * @return a string or null;
     */
    @Override
    public String obtainReturn(String st) {
        String[] split=st.split(": Ret = ");
        if(impacted.contains(Integer.parseInt(split[0]))) {
            if(DEBUG) System.out.println("Contained " + split[0]+"  "+split[1]);
            return split[1];
        }
        return null;
    }
}
