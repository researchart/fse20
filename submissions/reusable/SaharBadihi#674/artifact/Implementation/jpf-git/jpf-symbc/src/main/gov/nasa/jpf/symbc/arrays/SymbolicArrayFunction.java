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

//
//Copyright (C) 2005 United States Government as represented by the
//Administrator of the National Aeronautics and Space Administration
//(NASA).  All Rights Reserved.
//
//This software is distributed under the NASA Open Source Agreement
//(NOSA), version 1.3.  The NOSA has been approved by the Open Source
//Initiative.  See the file NOSA-1.3-JPF at the top of the distribution
//directory tree for the complete NOSA document.
//
//THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY OF ANY
//KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT
//LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM TO
//SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
//A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
//THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT
//DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE.
//

package gov.nasa.jpf.symbc.arrays;
// support for arbitrary external functions

import gov.nasa.jpf.symbc.numeric.ConstraintExpressionVisitor;
import gov.nasa.jpf.symbc.numeric.Expression;
import gov.nasa.jpf.symbc.numeric.IntegerExpression;
import gov.nasa.jpf.symbc.numeric.SymbolicInteger;
import gov.nasa.jpf.symbc.numeric.PathCondition;
import gov.nasa.jpf.symbc.numeric.RealExpression;
import gov.nasa.jpf.util.FileUtils;
import gov.nasa.jpf.vm.ClassLoaderInfo;
import gov.nasa.jpf.symbc.numeric.SymbolicFunction;

import java.util.ArrayList;
import java.util.Map;
import java.lang.reflect.*;
//import java.net.MalformedURLException;
//import java.net.URI;
import java.net.URL;
import java.net.URLClassLoader;

public class SymbolicArrayFunction  extends ArrayExpression implements SymbolicFunction
{
    String class_name;
    String method_name;
    Class<?>[] argTypes;
    public Expression [] sym_args;
    static URLClassLoader clsLoader = null;
    ArrayList<PathCondition> conditions;

    // what happens when there are no arguments?
    public SymbolicArrayFunction (String cls, String mth, Class<?>[] ast,
                                Expression [] sym_as, ArrayList<PathCondition> conditions)
    {
        super(mth+"_SYMARRAY",cls.split("\\[\\]")[0]);
        System.out.println("Class name : "+cls);
        class_name = cls;
        method_name = mth+"_SYMARRAY";
        assert(ast != null && sym_as != null && sym_as.length == ast.length);
        // do we need a deep copy here or a shallow copy is enough?
        argTypes = ast;
        sym_args = sym_as;
        this.conditions = conditions;
    }

    public void getVarsVals(Map<String,Object> varsVals) {
        if (sym_args!=null)
            for (int i = 0; i < sym_args.length; i++)
                sym_args[i].getVarsVals(varsVals);
    }

    public String stringPC () {
        String result="";
        if (sym_args!=null)
            for (int i = 0; i < sym_args.length; i++)
                result = result + sym_args[i].stringPC() + ",";
        if(result.length() >0)
            result = result.substring(0,result.length() -1 );
        //here use caps on type and add _SYMARRAYTYPE
        return  method_name + "(" + result + ")";
    }

    public String toString () {
        String result="";
        if (sym_args!=null)
            for (int i = 0; i < sym_args.length; i++)
                result = result + sym_args[i].toString() + ",";
        if(result.length() >0)
            result = result.substring(0,result.length() -1 );
        return  method_name +"(" + result + ")";
    }


}
