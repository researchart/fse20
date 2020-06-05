Paper #633 Interval Counterexamples for Loop Invariant Learning
===
The artifacts include 3 parts: Benchmark, tools and scripts.

Benchmark
--
This directory includes all the benchmarks which used in our section "EXPERIMENTS AND EVALUATION".

Tools
--
This directory includes the prototype of our approaches and the baseline.
The invariant learning uses two modules. One is the teacher and the other is 
the decision tree learner.

Our implemented decision tree is in `Tools/Ours/IDT4Inv` which includes both
source code and binaries.

`Tools/Ours/Boundary`, `Tools/Ours/Dig` and `Tools/Ours/VarElim` are 3 
strategies mentioned in section 5.1 of paper. `Tools/Ours/Exp2` is for 
the comparison experiment in section 5.2. Notices that because we implemented our strategies based on previous work ICE-DT (POPL-16).  So, 
we need to ask the authors for opinions of open source and also what open source license we should follow. However, until now, we haven't received 
their replies. Because of this, we temporarily only put the binaries in these
directories. And if we get their approvement, we will further add the source code. 

Scripts
--
This directory provides some python scripts with which you can easily conduct the experiments in paper.

