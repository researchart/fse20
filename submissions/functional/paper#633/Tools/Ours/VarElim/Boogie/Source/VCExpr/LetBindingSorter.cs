//-----------------------------------------------------------------------------
//
// Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//-----------------------------------------------------------------------------
using System;
using System.Text;
using System.IO;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using Microsoft.Basetypes;
using System.Runtime.InteropServices;

// Sort the bindings in a let-expression so that terms bound earlier do
// not contain variables bound later

namespace Microsoft.Boogie.VCExprAST {

  // (argument is not used)
  public class LetBindingSorter : MutatingVCExprVisitor<bool> {

    [ContractInvariantMethod]
    void ObjectInvariant() {
      Contract.Invariant(FreeVarCollector != null);
    }

    private readonly FreeVariableCollector/*!*/ FreeVarCollector =
      new FreeVariableCollector();

    private List<VCExprVar/*!*/>/*!*/ FreeVarsIn(VCExpr expr) {
      Contract.Requires(expr != null);
      Contract.Ensures(cce.NonNullElements(Contract.Result<List<VCExprVar>>()));
      FreeVarCollector.Collect(expr);
      List<VCExprVar/*!*/>/*!*/ freeVars = new List<VCExprVar/*!*/>(FreeVarCollector.FreeTermVars.Keys);
      FreeVarCollector.Reset();
      return freeVars;
    }

    public LetBindingSorter(VCExpressionGenerator gen):base(gen) {
      Contract.Requires(gen != null);

    }

    //unsafe private static string getMemory(object o)
    //{
    //    //GCHandle h = GCHandle.Alloc(o, GCHandleType.Pinned);
    //    TypedReference tr = __makeref(o);
    //    IntPtr addr = **(IntPtr**)(&tr);
    //    return "0x" + addr.ToString("X");
    //}
    public override VCExpr Visit(VCExprLet node, bool arg){
      
      Contract.Requires(node != null);
      Contract.Ensures(Contract.Result<VCExpr>() != null);
      IDictionary<VCExprVar/*!*/, Binding/*!*/> boundVars =
        new Dictionary<VCExprVar/*!*/, Binding/*!*/> ();


      //List<VCExpr> test = new List<VCExpr>();
      // recurse and collect the free variables in bound terms and formulae
      foreach (VCExprLetBinding/*!*/ binding in node) {Contract.Assert(binding != null);

       
        //Console.WriteLine("Before mutate, the original expr variables is : {0},  address is {1}", binding.V.Name, getMemory(binding.V));
        //Console.WriteLine("Before mutate, the original expr  is : {0}", binding.E.ToString());
        //Console.WriteLine("Before mutate, the original expr 's free variables are :");
        //List<VCExprVar> oExprs = FreeVarsIn(binding.E);
        //for (int i = 0; i < oExprs.Count; i++)
        //{
        //    //Console.WriteLine(getMemory(oExprs[i]));
        //    Console.WriteLine("Name : {0}, address {1}", oExprs[i].Name, getMemory(oExprs[i]));
        //}
        VCExpr/*!*/ newE = Mutate(binding.E, arg);
        List<VCExprVar> exprs = FreeVarsIn(newE);
        Binding/*!*/ b = new Binding (binding.V, newE, exprs);
        //Console.WriteLine("After mutate, the new expr is : {0}", newE.ToString());
        //Console.WriteLine("After mutate, the new exprssion's free variables are :");
        //for (int i = 0; i < exprs.Count; i++) {
        //    Console.WriteLine("Name : {0}, address {1}", exprs[i].Name, getMemory(exprs[i]));
        //}
        //Console.WriteLine("After init new object, the  new expr var is {0}, address is {1}:", b.V.Name, getMemory(b.V));
        //Console.WriteLine("After init new object, the  free variables are :");
        //for (int i = 0; i < b.FreeVars.Count; i++)
        //{
        //    Console.WriteLine("Name : {0}, address {1}", b.FreeVars[i].Name, getMemory(b.FreeVars[i]));
        //}
            //foreach (VCExprVar/*!*/ p in exprs)
            // Contract.Assert(p != null);
            // Console.WriteLine(getMemory(p));
            //}
            //foreach (VCExprVar/*!*/ v in b.FreeVars)
            //{
            //    Contract.Assert(v != null);
            //    Console.WriteLine(getMemory(v));
            //}
        boundVars.Add(b.V, b);
        //test.Add(b.V);
       
      }

      // generate the occurrence edges
      foreach (KeyValuePair<VCExprVar/*!*/, Binding/*!*/> pair in boundVars) {Contract.Assert(cce.NonNullElements(pair));
        Binding/*!*/ b = pair.Value;
        Contract.Assert(b != null);
        foreach (VCExprVar/*!*/ v in b.FreeVars) {Contract.Assert(v != null);
          Binding b2;
         // Console.WriteLine("current is :\n {0}", v.ToString());
          //Console.WriteLine(getMemory(v));
            //foreach(VCExpr e in test){
            //    Console.WriteLine(e.ToString());
            //    Console.WriteLine(getMemory(e));
            //    bool equal = v == e;
            //    if (equal) {
            //        Console.WriteLine("Correct");
            //    }
            //}
          //bool equal = v == 
          if (boundVars.TryGetValue(v, out b2)) {
            cce.NonNull(b2).Occurrences.Add(b);
            b.InvOccurrencesNum = b.InvOccurrencesNum + 1;
          }
        }
      }

      // topological sort
      Stack<Binding/*!*/> rootBindings = new Stack<Binding/*!*/> ();
      foreach (KeyValuePair<VCExprVar/*!*/, Binding/*!*/> pair in boundVars)
      {Contract.Assert(cce.NonNullElements(pair));
        if (pair.Value.InvOccurrencesNum == 0)
          rootBindings.Push(pair.Value);}

      List<Binding/*!*/>/*!*/ sortedBindings = new List<Binding/*!*/> ();
      while (rootBindings.Count > 0) {
        Binding/*!*/ b = rootBindings.Pop();
        Contract.Assert(b != null);
        sortedBindings.Add(b);
        foreach (Binding/*!*/ b2 in b.Occurrences) {
          Contract.Assert(b2 != null);
          b2.InvOccurrencesNum = b2.InvOccurrencesNum - 1;
          if (b2.InvOccurrencesNum == 0)
            rootBindings.Push(b2);
        }
      }

      if (boundVars.Any(pair=> pair.Value.InvOccurrencesNum > 0))
        System.Diagnostics.Debug.Fail("Cyclic let-bindings");

      Contract.Assert(node.Length == sortedBindings.Count);

      // check which of the bindings can be dropped
      VCExpr newBody = Mutate(node.Body, arg);
      Contract.Assert(newBody != null);

      IDictionary<VCExprVar/*!*/, VCExprVar/*!*/>/*!*/ usedVars =
        new Dictionary<VCExprVar/*!*/, VCExprVar/*!*/> ();
      foreach (VCExprVar/*!*/ v in FreeVarsIn(newBody)){Contract.Assert(v != null);
        if (!usedVars.ContainsKey(v))
          usedVars.Add(v, v);}

      for (int i = sortedBindings.Count - 1; i >= 0; --i) {
        if (usedVars.ContainsKey(sortedBindings[i].V)) {
          foreach (VCExprVar/*!*/ v in sortedBindings[i].FreeVars){
            Contract.Assert(v != null);
            if (!usedVars.ContainsKey(v))
              usedVars.Add(v, v);}
        } else {
          sortedBindings.RemoveAt(i);
        }
      }

      // assemble the resulting let-expression
      List<VCExprLetBinding/*!*/>/*!*/ newBindings = new List<VCExprLetBinding/*!*/>();
      foreach (Binding b in sortedBindings)
        newBindings.Add(Gen.LetBinding(b.V, b.E));

      return Gen.Let(newBindings, newBody);
    }

    private class Binding {
      public readonly VCExprVar/*!*/ V;
      public readonly VCExpr/*!*/ E;
      public readonly List<VCExprVar/*!*/>/*!*/ FreeVars;
      [ContractInvariantMethod]
      void ObjectInvariant() {
        Contract.Invariant(V != null);
        Contract.Invariant(E != null);
        Contract.Invariant(cce.NonNullElements(FreeVars));
        Contract.Invariant(Occurrences != null);
      }


      // list of all bound expression in which the variable V occurs
      // (outgoing edges)
      public readonly List<Binding>/*!*/ Occurrences;

      // number of variables that are bound in this let-expression
      // and that occur in FreeVars
      // (incoming edges)
      public int InvOccurrencesNum;

      public Binding(VCExprVar v, VCExpr e, List<VCExprVar/*!*/>/*!*/ freeVars) {
        Contract.Requires(e != null);
        Contract.Requires(v != null);
        Contract.Requires(cce.NonNullElements(freeVars));
        this.V = v;
        this.E = e;
        this.FreeVars = freeVars;
        this.Occurrences = new List<Binding>();
        this.InvOccurrencesNum = 0;
      }
    }

  }

}
