# Entropic

This is the artifact for the paper: "Boosting Fuzzer Efficiency: An Information Theoretic Perspective".

### Badges description

Entropic has been independently evaluated by a team at Google and invited for
integration into mainline [LibFuzzer @
LLVM](https://github.com/llvm/llvm-project/commit/e2e38fca64e49d684de0b100437fe2f227f8fcdd).
During our integration, Entropic was subject to a substantial [code reviewing
process](https://reviews.llvm.org/D73776) which included adding sufficient
documentation and unit tests. When Google released the fuzzer benchmarking
platform [Fuzzbench](https://github.com/google/fuzzbench), to facilitate
independent replication, we also [integrated Entropic @
FuzzBench](https://github.com/google/fuzzbench/commits/master/fuzzers/entropic).
Recent results can be found here
https://www.fuzzbench.com/reports/2020-05-24/index.html.

We therefore kindly request the ESEC/FSE'20 artifact evaluation committee to consider our artifact as
* available, functional, and reusable.
* replicated, and reproduced.
