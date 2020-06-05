//MIT-LICENSE
//Copyright (c) 2020-, Sahar Badihi, The University of British Columbia, and a number of other of contributors
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package equiv.checking.custom;

import com.github.gumtreediff.actions.model.*;
import com.github.gumtreediff.matchers.Mapping;
import com.github.gumtreediff.matchers.MappingStore;
import com.github.gumtreediff.tree.ITree;
import com.github.gumtreediff.tree.TreeContext;
import com.google.common.collect.BiMap;
import com.google.common.collect.HashBiMap;

import java.io.IOException;
import java.io.Writer;
import java.util.*;

import static equiv.checking.Utils.DEBUG;

public class CustomSerializer{
final TreeContext context1,context2;
final MappingStore mappings;
final List<Action> actions;
Map<Integer, String[]> changes=new TreeMap<>();
BiMap<Integer,Integer> insertedControl = HashBiMap.create();
BiMap<Integer,Integer> deletedControl = HashBiMap.create();
int INSERTOLD = 0, INSERTNEW = 0;

public CustomSerializer(TreeContext context1,TreeContext context2,List<Action> actions, MappingStore mappings ) {
    this.context1 = context1;
    this.context2=context2;
    this.mappings = mappings;
    this.actions = actions;
}


public CustomFormatter newFormatter(TreeContext ctx1,TreeContext ctx2,Writer writer) throws Exception {
    return new CustomFormatter(ctx1,ctx2, writer);
}

public Map<Integer, String[]> writeTo(Writer writer) throws Exception {
    CustomFormatter fmt = this.newFormatter(context1,context2,writer);
    Map<Integer,List<Action>> orderMap = orderActions(writer,fmt);
    for(List<Action> actions : orderMap.values()) {
        Iterator var3 = actions.iterator();
        while (var3.hasNext()) {
            Action a = (Action) var3.next();
            ITree src = a.getNode();
            ITree dst;
            if (a instanceof Move) {
                dst = this.mappings.getDst(src);
                fmt.moveAction(src, dst);
            } else if (a instanceof Update) {
                dst = this.mappings.getDst(src);
                fmt.updateAction(src, dst);
            } else if (a instanceof Insert) {
                dst = a.getNode();
                if (dst.isRoot()) {
                    fmt.insertRoot(dst);
                } else {
                    fmt.insertAction(dst, dst.getParent());
                }
            } else if (a instanceof Delete) {
                fmt.deleteAction(src);
            }
        }
    }
    fmt.updateAllControlDependentsForInserts();
    fmt.updateAllControlDependentsForDeletes();
    if(DEBUG)
        for(Integer i: changes.keySet())
            System.out.println(i+"  "+Arrays.toString(changes.get(i)));
    return changes;

}


public Map<Integer, String[]> writeTo2(Writer writer) throws Exception {
    CustomFormatter fmt = this.newFormatter(context1,context2,writer);
    Iterator var3 = this.actions.iterator();
    fmt.startMatches();
    for(Mapping m : mappings)
        fmt.match(m.first,m.second);
    fmt.endMatches();
    while(var3.hasNext()) {
        Action a = (Action)var3.next();
        ITree src = a.getNode();
        ITree dst;
        if (a instanceof Move) {
            dst = this.mappings.getDst(src);
            fmt.moveAction(src, dst);
        } else if (a instanceof Update) {
            dst = this.mappings.getDst(src);
            fmt.updateAction(src, dst);
        } else if (a instanceof Insert) {
            dst = a.getNode();
            if (dst.isRoot()) {
                fmt.insertRoot(dst);
            } else {
                fmt.insertAction(dst, dst.getParent());
            }
        } else if (a instanceof Delete) {
            fmt.deleteAction(src);
        }
    }
    fmt.updateAllControlDependentsForInserts();
    fmt.updateAllControlDependentsForDeletes();
    if(DEBUG)
        for(Integer i: changes.keySet())
        System.out.println(i+"  "+Arrays.toString(changes.get(i)));
    return changes;

}

public Map<Integer,List<Action>> orderActions(Writer writer,CustomFormatter fmt) throws Exception {
    Iterator var3 = this.actions.iterator();
    TreeMap<Integer,List<Action>> orderedMap = new TreeMap<>();
    fmt.startMatches();
    for(Mapping m : mappings)
        fmt.match(m.first,m.second);
    fmt.endMatches();
    while(var3.hasNext()) {
        Action a = (Action) var3.next();
        ITree src = a.getNode();
        List<Action> list = orderedMap.get(src.getPos());
        if (list == null)
            list = new ArrayList<>();
        list.add(a);
        orderedMap.put(src.getPos(), list);
    }
    return orderedMap;
}

private class CustomFormatter {
    private final TreeContext context1, context2;
    private final Writer writer;


    public CustomFormatter(TreeContext ctx1, TreeContext ctx2, Writer writer) {
        this.context1 = ctx1;
        this.context2 = ctx2;
        this.writer = writer;
    }


    private String toS(ITree node, TreeContext context) {
        return String.format("%s", node.toPrettyString(context));
    }

    private void write(String fmt, Object... objs) throws IOException {
        this.writer.append(String.format(fmt, objs));
        this.writer.append("\n");
    }

    public void startMatches() throws IOException {
        writer.append("Matches : \n");
    }

    public void endMatches() throws IOException {
        writer.append("End matches \n");
    }

    public void match(ITree srcNode, ITree destNode) throws IOException {
        write("[Match,%d,%d,%s,%s]", srcNode.getPos(), destNode.getPos(), this.toS(srcNode, context1), this.toS(destNode, context2));
    }

    public void startActions() throws Exception {

    }

    public void updateAllControlDependentsForInserts() {
        for (int start : CustomSerializer.this.insertedControl.keySet()) {
            int end = CustomSerializer.this.insertedControl.get(start);
            String cond = checkInfoDependentStmt(start, end, "I");
            String[] info = CustomSerializer.this.changes.get(start);
            if (info != null && info.length == 2 && info[0] == "I") {
                info[1] = info[1].replace("false", cond);
            }
        }
    }

    public void updateAllControlDependentsForDeletes() {
        for (int start : CustomSerializer.this.deletedControl.keySet()) {
            int end = CustomSerializer.this.deletedControl.get(start);
            String cond = checkInfoDependentStmt(start, end, "D");
            String[] info = CustomSerializer.this.changes.get(start);
            if (info != null && info.length == 2 && info[0] == "D") {
                info[1] = info[1].replace("false", cond);
            }
        }
    }


    public String checkInfoDependentStmt(int start, int end, String type) {
        String cond = "false";
        for (int i = start + 1; i < end; i++) {
            //Here we check if everything inside is deleted as well
            String[] infoDependantSmt = CustomSerializer.this.changes.get(i);
            if (infoDependantSmt == null || (infoDependantSmt[0] != type)) {
                if (infoDependantSmt != null && infoDependantSmt[0] == "u") { //TO DOUBLE CHECK
                    CustomSerializer.this.changes.remove(new Integer(i));
                }
                //In this case we just remove the condition and not the content
                else
                    cond = "true";
            }
        }
        if (cond == "false") {
            for (int i = start + 1; i < end; i++) {
                //Here we check if everything inside is deleted as well
                CustomSerializer.this.changes.putIfAbsent(i, new String[]{"C" + type});
            }
        }
        return cond;
    }

    public void updateAction(ITree src, ITree dest) throws Exception {
        String[] info = {"U"};
        CustomSerializer.this.changes.put(src.getPos() + INSERTOLD, info);
        this.write("[Update,%d,%d,%s]", src.getPos(), dest.getPos(), this.toS(src, context1));

    }

    public void moveAction(ITree iTree, ITree iTree1) throws Exception {
        int source = iTree.getPos(), dest = iTree1.getPos();
        int from = source + INSERTOLD, to = dest + INSERTNEW;
        String type = this.toS(iTree, context1);
        //String[] info = {"M",Integer.toString(source),Integer.toString(dest)};
        String[] info = {"U"}, info2;
        String[] value = CustomSerializer.this.changes.get(from);
        if (value == null || value[0] == "u" || value[0] == "M") {
            if (type.contains("Statement")) {
                //We can also have the case where an expression was changed in a move
                if (deletedControl.containsValue(from + 1)) {//where we started was the end of a if condition
                    //it only applies in the case an else was replace with an if (so only one statement under the else, otherwise it would be a block)
                    //here what I am going to do is keep both the if and the else
                    if (to - 1 == from) {
                        int start = deletedControl.inverse().get(from + 1); //the start of the if
                        if (from - start == 1) {
                            //A if got replaced with an else (GumTree report delete but it's just an update since line numbers are unchanged
                           if(type.contains("Expression")){
                               info = new String[]{"D", "Assignment", iTree.getChild(0).getChild(0).getLabel()};
                               info2 = new String[]{"I", "Assignment", iTree.getChild(0).getChild(0).getLabel()};
                           }
                           else{
                               info = new String[]{"D",type};
                               info2 = new String[]{"I",type};
                           }
                           String[] ifToPush = changes.get(start);
                           deletedControl.remove(start);
                           changes.remove(start);
                           //Here we want to keep the else first
                            CustomSerializer.this.changes.put(start,new String[]{"I","else"});
                            CustomSerializer.this.changes.put(start +1 ,info2);
                            INSERTOLD += 2;
                           //wherever we use from we call also use to - 1
                           CustomSerializer.this.changes.put(start +2,ifToPush); //we have deleted the statement that was moved
                            CustomSerializer.this.changes.put(start +3,info);
                            INSERTNEW ++;
                           //we need to add the else as an insertion to the new program
                            this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));
                            return;
                            //To deal with cases where a if got replace with else (insert but line did not change)
                        }
                    }
                }
                if (insertedControl.containsValue(to + 1)) {//the destination is the end of the if condition
                    int start = insertedControl.inverse().get(to + 1); //the start of the if, to is the end of the if
                    if (from - 1 == to) {
                        if (to - start == 1) {
                            //A else got replaced with an if (GumTree report insert but it's just an update since line numbers are unchanged
                            if(type.contains("Expression")){
                                info = new String[]{"I", "Assignment", iTree.getChild(0).getChild(0).getLabel()};
                                info2 = new String[]{"D", "Assignment", iTree.getChild(0).getChild(0).getLabel()};
                            }
                            else{
                                info = new String[]{"I",type};
                                info2 = new String[]{"D",type};
                            }
                            String[] iftoPush = changes.get(start);
                            insertedControl.remove(start);
                            changes.remove(start);
                            //Here we want to keep the else first //note from - 2 = start
                            CustomSerializer.this.changes.put(start, new String[]{"D","else"}); //we have inserted a statement under the if
                            CustomSerializer.this.changes.put(start + 1, info2);
                            INSERTNEW += 2;
                            CustomSerializer.this.changes.put(start + 2, iftoPush);
                            CustomSerializer.this.changes.put(start + 3, info);
                            INSERTOLD ++;
                            //no need to do old ++;
                            this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));
                            return;
                        }
                    }
                }
                if (from != to) {
                    int min = Math.min(from, dest), max = from + dest - min;
                    if (changes.containsKey(min) && changes.containsKey(max)) {
                        CustomSerializer.this.changes.put(min, info);
                        CustomSerializer.this.changes.put(max, info);
                        for (int i = min + 1; i < max; i++) {
                            String[] content = changes.get(i);
                            if (content != null && content[0].contains("M"))
                                changes.remove(i);
                        }
                    } else {
                        for (int i = min; i <= max; i++)
                            CustomSerializer.this.changes.put(i, new String[]{"M"});
                    }
                } else {
                    // CustomSerializer.this.changes.remove(from);
                }
                this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));
                return;
            }
            if (value == null && from != to) {
                changes.put(from, new String[]{"M"});
                this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));

                return;
            }
            if (type.equals("Block")) {
                //CustomSerializer.this.changes.put(from, info);
                this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));

                return;
            }
        }//we matched nothing before, let's check the destination
        String[] valueDest = CustomSerializer.this.changes.get(to);
        if (valueDest == null && from != to)
            changes.put(to, new String[]{"M"});
        this.write("[Move,%d,%d,%s]", iTree.getPos(), iTree1.getPos(), this.toS(iTree, context1));
    }

    public void deleteAction(ITree node) throws Exception {
        deleteActionAux(node, node.getParent(), context1);
        this.write("[Delete,%d,%d,%s]", node.getPos(), node.getEndPos(), this.toS(node, context1));
    }

    public void deleteActionAux(ITree node, ITree parent, TreeContext context) {
        String action = "D";
        String type = context.getTypeLabel(node);
        int start = node.getPos() + INSERTOLD, end = node.getEndPos() + INSERTOLD;
        String[] info = CustomSerializer.this.changes.get(start);
        //Either we never add an action on this line or only a partial update
        if (info == null || info[0] != "U") {
            //TODO Here find a way to deal with insert and delete of a statement (which happends when a if is changed to a else and there is an update)
            // The insert should be at the previous line, VERY SIMILAR TO WHAT IS DONE FOR IF
            if (type.equals("VariableDeclarationStatement") || type.equals("ReturnStatement")) {
                INSERTNEW++;
                String[] prev = CustomSerializer.this.changes.get(start - 1);
                if (prev != null && prev[0] == "I") {
                    if (prev[1].contains("false")) {
                        //If  something is inserted inside a deleted if condition, then something is wrong
                        int endIf = insertedControl.get(start - 1);
                        insertedControl.remove(start - 1);
                        String[] content = changes.get(start - 1);
                        String[] endControl = changes.get(endIf);
                        CustomSerializer.this.changes.remove(endIf);
                        //We put the deleted control statement above the current statement
                        CustomSerializer.this.changes.put(start, content);
                        //Here we assume that this can only happen with one statement, so there is nothing at the new position for endIf
                        CustomSerializer.this.changes.put(endIf - 1, endControl);
                        CustomSerializer.this.changes.remove(start - 1);
                        //the new position for the control statement
                        insertedControl.put(start, endIf - 1);
                        start--;
                        //It should be decreased when we get the inserted control that follows
                        INSERTOLD--;
                    } else if (prev[1].contains("ReturnStatement")) {
                        if (type.equals("ReturnStatement")) {
                            //we replace both with an update
                            start--;
                            action = "U";
                            INSERTNEW--;
                            INSERTOLD--;
                            //want to delete the possible u at the line after
                            String[] next = changes.get(start + 1);
                            if(next!= null && next[0] == "u"){
                                changes.remove(start +1 );
                            }
                        } else {
                            //we switch the position of both
                            changes.put(start, prev);
                            start--;
                        }
                    }
                }
                //We deleted a declaration
                info = new String[]{action, type};
                CustomSerializer.this.changes.put(start, info);
            } else if (type.equals("ReturnStatement")) {
                //we can check if the return is inside a block (a if, without the INSERTOLD), if the block is not deleted there is no need to keep it
                //info = new String[]{"u"};

            } else if (type.equals("ExpressionStatement")) {
                INSERTNEW++;
                String[] prev = CustomSerializer.this.changes.get(start - 1);
                if (prev != null && prev[0] == "I") {
                if (prev[1].contains("false")) {
                    //If  something is inserted inside a deleted if condition, then something is wrong
                    int endIf = insertedControl.get(start - 1);
                    insertedControl.remove(start - 1);
                    String[] content = changes.get(start - 1);
                    String[] endControl = changes.get(endIf);
                    CustomSerializer.this.changes.remove(endIf);
                    //We put the deleted control statement above the current statement
                    CustomSerializer.this.changes.put(start, content);
                    //Here we assume that this can only happen with one statement, so there is nothing at the new position for endIf
                    CustomSerializer.this.changes.put(endIf - 1, endControl);
                    CustomSerializer.this.changes.remove(start - 1);
                    //the new position for the control statement
                    insertedControl.put(start, endIf - 1);
                    start--;
                    //It should be decreased when we get the inserted control that follows
                    INSERTOLD--;
                } else if (prev[1].contains("ReturnStatement")) {
                    //we switch the position of both
                    changes.put(start, prev);
                    start--;
                }
            }
                //We deleted an assignment to a variable
                info = new String[]{action, "Assignment", node.getChild(0).getChild(0).getLabel()};
                CustomSerializer.this.changes.put(start, info);
            } else if (type.equals("IfStatement") || type.equals("WhileStatement")) {
                //HERE DEAL WITH DELETE+INSERT: remove change, up
                boolean counterAlreadyUpdated = false;
                int shift = 1;
                String[] prev = CustomSerializer.this.changes.get(start - 1);
                if (info != null && info[0] == "I" && info[1].contains("false")) {
                    counterAlreadyUpdated = true;
                    shift = 0;
                }
                //Here it should even be about intersecting deleted and inserted if, and everything must be shifted up I guess
                if (counterAlreadyUpdated || (prev != null && prev[0] == "I" && (prev[1].contains("false")))) {
                    int endIf = insertedControl.get(start - shift);
                    insertedControl.remove(start - shift);
                    CustomSerializer.this.changes.remove(endIf);
                    CustomSerializer.this.changes.remove(start - shift);
                    INSERTOLD = INSERTOLD - shift;
                } else {
                    INSERTNEW++;
                    //In case of a loop, complete with more loop types
                    String replacement = (type.equals("IfStatement") ? "if" : "while") + "(false)";
                    if (end - start > 1) {
                        replacement += "{";
                        CustomSerializer.this.changes.put(end, new String[]{"E" + action});
                    } else
                        end++;
                    CustomSerializer.this.deletedControl.put(start, end);
                    info = new String[]{action, replacement};
                    CustomSerializer.this.changes.put(start, info);
                }
            }
            else if (type.equals("Block")) {
                //A block is not necessarily an else
                INSERTNEW++;
                String replacement = "else";
                if (end - start > 1) {
                    replacement += "{";
                    CustomSerializer.this.changes.put(end, new String[]{"E" + action});
                } else
                    end++;
                info = new String[]{action, replacement};
                CustomSerializer.this.changes.put(start, info);
            }
            else if (info == null) {
                if (!type.equals("Block")) {
                    //If we never put anything, it's a partial update
                    info = new String[]{"u"};
                    CustomSerializer.this.changes.put(start, info);
                } else {
                    //HERE USE Db and Eb, very similar to the if case
                }
            }
        }
    }


    public void insertRoot(ITree iTree) throws Exception {
        this.write("Line %d to %d : Insert %s", iTree.getPos(), this.toS(iTree, context2));
    }

    public void insertAction(ITree node, ITree parent) throws Exception {
        insertActionAux(node, parent, context2);
        this.write("[Insert,%d,%d,%s]", node.getPos(), node.getEndPos(), this.toS(node, context2));
    }

    /**
     * @param node
     * @param parent
     * @param context Current assumption: if a deleted and inserted if intersect, then it's probably just one if that had an updated condition
     */
    public void insertActionAux(ITree node, ITree parent, TreeContext context) {
        //MISSING DEALING WITH RETURN STATEMENTS: MAYBE CHECK IF LINE NUMBERS ARE THE SAME ?
        //TODO, BE CAREFUL RETURN STATEMENTS CAN ONLY BE INSERTED UNDER CONDITIONALS
        String action = "I";
        String type = context.getTypeLabel(node);
        int start = node.getPos() + INSERTNEW, end = node.getEndPos() + INSERTNEW;
        String[] info = CustomSerializer.this.changes.get(start);
        //Either we never add an action on this line or only a partial update
        if (type.equals("VariableDeclarationStatement") || type.equals("ReturnStatement")) {
            //we can only insert return statement inside if statements
            INSERTOLD++;
            //I switch the statements in case the insertion came after the deletion but should have been before
            String[] prev = CustomSerializer.this.changes.get(start - 1);
            if (prev != null && prev[0] == "D") {
                if (prev[1].contains("false")) {
                    int endIf = deletedControl.get(start - 1);
                    deletedControl.remove(start - 1);
                    String[] content = changes.get(start - 1);
                    String[] endControl = changes.get(endIf);
                    CustomSerializer.this.changes.remove(endIf);
                    //We put the deleted control statement above the current statement
                    CustomSerializer.this.changes.put(start, content);
                    //Here we assume that this can only happen with one statement, so there is nothing at the new position for endIf
                    CustomSerializer.this.changes.put(endIf - 1, endControl);
                    CustomSerializer.this.changes.remove(start - 1);
                    //the new position for the control statement
                    deletedControl.put(start, endIf - 1);
                    start--;
                    //It should be decreased when we get the inserted control that follows
                    INSERTNEW--;
                } else if (prev[1].contains("ReturnStatement")) {
                    if (type.equals("ReturnStatement")) {
                        //we replace both with an update
                        start--;
                        action = "U";
                        INSERTNEW--;
                        INSERTOLD--;
                    } else {
                        //we switch the position of both
                        changes.put(start, prev);
                        start--;
                    }
                }
            }
            //We deleted a declaration
            info = new String[]{action, type};
            CustomSerializer.this.changes.put(start, info);
        } else if (type.equals("ExpressionStatement")) {
            //probably eventually put the same thing as in variable declaration here at some point
            INSERTOLD++;
            String[] prev = CustomSerializer.this.changes.get(start - 1);
            if (prev != null && prev[0] == "D") {
                if (prev[1].contains("false")) {
                    int endIf = deletedControl.get(start - 1);
                    deletedControl.remove(start - 1);
                    String[] content = changes.get(start - 1);
                    String[] endControl = changes.get(endIf);
                    CustomSerializer.this.changes.remove(endIf);
                    //We put the deleted control statement above the current statement
                    CustomSerializer.this.changes.put(start, content);
                    //Here we assume that this can only happen with one statement, so there is nothing at the new position for endIf
                    CustomSerializer.this.changes.put(endIf - 1, endControl);
                    CustomSerializer.this.changes.remove(start - 1);
                    //the new position for the control statement
                    deletedControl.put(start, endIf - 1);
                    start--;
                    //It should be decreased when we get the inserted control that follows
                    INSERTNEW--;
                } else if (prev[1].contains("ReturnStatement")) {
                    //we switch the position of both
                    changes.put(start, prev);
                    start--;
                }
            }
            //We deleted an assignment to a variable
            info = new String[]{action, "Assignment", node.getChild(0).getChild(0).getLabel()};
            CustomSerializer.this.changes.put(start, info);
        } else if (type.equals("IfStatement") || type.equals("WhileStatement")) {
            //In case of a loop, complete with more loop types
            boolean counterAlreadyUpdated = false;
            int shift = 1;
            String[] prev = CustomSerializer.this.changes.get(start - 1);
            if (info != null && info[0] == "D" && info[1].contains("false")) {
                counterAlreadyUpdated = true;
                shift = 0;
            }
            //Here it should even be about intersecting deleted and inserted if, and everything must be shifted up I guess
            if (counterAlreadyUpdated || (prev != null && prev[0] == "D" && (prev[1].contains("false")))) {
                int endIf = deletedControl.get(start - shift);
                deletedControl.remove(start - shift);
                CustomSerializer.this.changes.remove(endIf);
                CustomSerializer.this.changes.remove(start - shift);
                INSERTNEW = INSERTNEW - shift;
            } else {
                INSERTOLD++;
                String replacement = (type.equals("IfStatement") ? "if" : "while") + "(false)";
                if (end - start > 1) {
                    replacement += "{";
                    CustomSerializer.this.changes.put(end, new String[]{"E" + action});
                } else
                    end++;
                CustomSerializer.this.insertedControl.putIfAbsent(start, end);
                info = new String[]{action, replacement};
                CustomSerializer.this.changes.put(start, info);
            }
        } else if (type.contains("Block")) {
            INSERTOLD++;
            //In case of a loop, complete with more loop types
            String replacement = "else";
            if (end - start > 1) {
                replacement += "{";
                CustomSerializer.this.changes.put(end, new String[]{"E" + action});
            } else
                end++;
            info = new String[]{action, replacement};
            CustomSerializer.this.changes.put(start, info);
        } else if (info == null) {
            if (!type.equals("Block")) {
                //If we never put anything, it's a partial update
                info = new String[]{"u"};
                CustomSerializer.this.changes.put(start, info);
            }
        }
    }
    //If there was an assignement, a control statement or a declaration, I would have already added it, so if it is null and it's the first thing I see, then
    public void lineAction(ITree node,ITree parent,TreeContext context,String action) {
        String type = context.getTypeLabel(node);
        String[] info = CustomSerializer.this.changes.get(node.getPos());
        if (DEBUG) System.out.println(CustomSerializer.this.changes);
        if (DEBUG) System.out.println(Arrays.toString(info));
        if (info == null || info[0].equals("UN") || info[0].equals("M")) {
            //If we never added anything or we add to replace an insertion/deletion with a special update
            if (type.equals("VariableDeclarationStatement")) {
                info = new String[]{action, type};
                CustomSerializer.this.changes.put(node.getPos(), info);
            } else if (type.equals("IfStatement") || type.equals("WhileStatement")) {
                type = (type.equals("IfStatement") ? "if" : "while") + "(true)";
                if (node.getEndPos() - node.getPos() > 1) {
                    type += "{";
                    int beginningElse = 0;
                    //TO FINISH
                   /* if(node instanceof IfStmt){
                        IfStmt ist = node.asIfStmt();
                       if (ist.hasElseBranch()){
                            beginningElse = ist.getElseStmt().getPos;
                        }
                    }*/
                    CustomSerializer.this.changes.put(node.getEndPos(), new String[]{"E" + action});
                }
                info = new String[]{action, type};
                CustomSerializer.this.changes.put(node.getPos(), info);
                //we add a statement for the end of the control statement
                //maybe more control types at some point
            }
            else if (type.equals("ExpressionStatement")) {
                //TOBECHECKED
                if (DEBUG) System.out.println(node.getChild(0).getChild(0).getLabel());
                info = new String[]{action, "Assignment", node.getChild(0).getChild(0).getLabel()};
                CustomSerializer.this.changes.put(node.getPos(), info);
            }
            if (info == null) {
                //To transform the insertion of nodes in a line into an update
                //This is the only case that is not handled earlier that need to be kept as an insertion
                if (!type.equals("Assignment") && !type.equals("Block") && !type.contains("Statement")) {
                    info = new String[]{"UN"};
                    CustomSerializer.this.changes.put(node.getPos(), info);
                }
            }

        }

    }

    public void endActions() throws Exception {

    }
}


}