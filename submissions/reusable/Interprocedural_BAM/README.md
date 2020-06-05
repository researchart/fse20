# Domain-Independent Interprocedural Program Analysis using Block-Abstraction Memoization

Authors: Dirk Beyer and Karlheinz Friedberger


# Summary of this Artifact Package

This artifact package provides the necessary data and tools to evaluate our approach for
Interprocedural BAM to analyze recursive procedures that is described in the paper
"Domain-Independent Interprocedural Program Analysis using Block-Abstraction Memoization"
accepted at FSE 2020.
The artifact can be downloaded from Xenodo: https://doi.org/10.5281/zenodo.3698235
It contains a detailed description how to proceed with the evaluation,
including the benchmarking process and step to generate the tables in the paper.


# Abstract of the Paper

Whenever a new software-verification technique is developed, additional effort
is necessary to extend the new program analysis to an interprocedural one,
such that it supports recursive procedures.
We would like to reduce that additional effort.
Our contribution is an approach to extend an existing analysis in a modular and
domain-independent way to an interprocedural analysis without large changes:
We present interprocedural block-abstraction memoization (BAM), which is
a technique for procedure summarization to analyze (recursive) procedures.
For recursive programs, a fix-point algorithm terminates the recursion if every
procedure is sufficiently unrolled and summarized to cover the abstract state space.
BAM Interprocedural works for data-flow analysis and for model checking,
and is independent from the underlying abstract domain.
To witness that our interprocedural analysis is generic and configurable,
we defined and evaluated the approach for three completely different abstract
domains: predicate abstraction, explicit values, and intervals.
The interprocedural BAM-based analysis is implemented in the open-source
verification framework CPAchecker. The evaluation shows that the overhead for
modularity and domainindependence is not prohibitively large and the analysis
is still competitive with other state-of-the-art software verification tools.


