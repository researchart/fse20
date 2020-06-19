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
source code and binaries. The baseline decision tree is in `Tools/ICE-DT(Baseline)/C50`.

`Tools/Ours/Boundary`, `Tools/Ours/Dig` and `Tools/Ours/VarElim` are 3 
strategies mentioned in section 5.1 of paper. `Tools/Ours/Exp2` is for 
the comparison experiment in section 5.2. 
These 4 strategies we implemented are based on previous work ICE-DT (POPL-16) which is also the baseline in our paper
(`Tools/ICE-DT(Baseline)/Boogie`). All of these implementation including are followed the Microsoft Public License (MS-PL). 
For each project directories, source code and binaries are both provided.


Scripts
--
This directory provides some python scripts with which you can easily conduct the experiments in paper.

