# Entropic
<a href="https://mboehme.github.io/paper/FSE20.Entropy.pdf"><img src="Entropic.png" align="right" width="300"></a>

@TODO:
- copy this folder into the others


Entropic is an information-theoretic power schedule implemented into
LibFuzzer. It boosts performance by changing how weights are assigned to the
seeds in the corpus. Seeds revealing more ‘‘information’’ about globally rare
features are assigned a higher weight.

Entropic has been independently evaluated by a team at Google and invited for
integration into mainline [LibFuzzer @
LLVM](https://github.com/llvm/llvm-project/commit/e2e38fca64e49d684de0b100437fe2f227f8fcdd),
whereupon Entropic was subject to a substantial [code reviewing
process](https://reviews.llvm.org/D73776). When Google released the fuzzer
benchmarking platform [Fuzzbench](https://github.com/google/fuzzbench), to
facilitate replication, we also [integrated Entropic @
FuzzBench](https://github.com/google/fuzzbench/commits/master/fuzzers/entropic).
Recent results can be found here
https://www.fuzzbench.com/reports/2020-05-24/index.html.

We therefore kindly request the ESEC/FSE'20 artifact evaluation committee to consider our artifact as
* available, functional, and reusable.
* replicated, and reproduced.

Entropic is the result of the fruitful collaboration between
* [Marcel Böhme](https://mboehme.github.io) @ Monash, Australia,
* [Valentin Manès](https://www.jiliac.com/), CSRC, KAIST, Korea
* [Sang Kil Cha](https://softsec.kaist.ac.kr/~sangkilc/) @ KAIST, South Korea.

## Installation

We prepared a quick and slow way to compile Entropic.

### Dependencies

- Both methods of installation we explain below require to use `docker`.
Please see the installation process specific to your platform
[here](https://docs.docker.com/engine/install/).
- The "quick installation" we describe just below requires other
dependencies. See [FuzzBench
prerequisites](https://google.github.io/fuzzbench/getting-started/prerequisites/).

### Quick Installation
To build and run Entropic for the [re2-2014-09 benchmark @
FuzzBench](https://github.com/google/fuzzbench/tree/master/benchmarks/re2-2014-12-09),
run the following:
```
git clone https://github.com/google/fuzzbench/
cd fuzzbench
make run-entropic-re2-2014-12-09
```
To build all benchmarks from FuzzBench with entropic, run
```
make build-entropic-all
```

### Slow but Full Installation
This slower way is based on building the LLVM project from scratch and the
[Fuzzer Test Suite](https://github.com/google/fuzzer-test-suite). This is
the method we used to perform the experiments described in the paper.
Building clang and LLVM compiler-rt with Entropic can take several hours and
might require around 130GB of disk space. To build Entropic from the LLVM
repository and then use it to build the [re2-2014-09 benchmark @
FuzzerTestSuite](https://github.com/google/fuzzer-test-suite/tree/master/re2-2014-12-09),
run our Dockerfile:
```
docker build . -t entropic

# To run LibFuzzer
docker run entropic /fuzzers/re2-2014-12-09/re2-2014-12-09-fsanitize_fuzzer

# To run Entropic
docker run entropic /fuzzers/re2-2014-12-09/re2-2014-12-09-fsanitize_fuzzer -entropic=1
```
**OR** run the the following commands on your machine. In both cases, expect
*the build process to take a few hours and require around 130GB of disk
*storage:
```
sudo apt -y install git build-essential cmake python3 ninja-build

# Checkout LLVM revision where Entropic was integrated
git clone https://github.com/llvm/llvm-project
cd llvm-project
git checkout e2e38fca64e49d684de0b100437fe2f227f8fcdd
popd

# Build LLVM clang and compiler-rt
mkdir llvm-build
pushd llvm-build
cmake -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" -DLLVM_PARALLEL_LINK_JOBS=1 \
    -G "Ninja" ../llvm-project/llvm
cmake --build .
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -P cmake_install.cmake
popd

# Build re2-2014-09 benchmark @ FuzzerTestSuite
git clone https://github.com/google/fuzzer-test-suite fts
mkdir -p fuzzers/re2-2014-12-09
pushd fuzzers/re2-2014-12-09
../../fts/re2-2014-12-09/build.sh
popd

# To run LibFuzzer
fuzzers/re2-2014-12-09/re2-2014-12-09-fsanitize_fuzzer

# To run Entropic
fuzzers/re2-2014-12-09/re2-2014-12-09-fsanitize_fuzzer -entropic=1
```
For more on LibFuzzer usage, see its
[documentation](https://www.llvm.org/docs/LibFuzzer.html). For our
experiments, we run each subject in the Fuzzer Test Suite 40 times during one
hour. This requires about 40 CPU days.

Entropic usage can be customized with two options:
- The `-considered_rare` option sets a threshold: If the incidence frequency
of a feature is below this threshold, this feature is considered "rare". A
higher rarity threshold means more features and thus more information are
included in the entropy computation. It can potentially be helpful, but has
the higher this threshold is, the higher the risk that a very abundant
species will have a huge impact on the entropy estimate. This will diminish
the entropy difference between seeds, thus the impact of our boosting.
- When above the "rare" threshold, Entropic still keep track of a specific
number of features with the lowest frequency. The `-topX_rarest_features`
option sets this number. Similarly than for the option above, the higher
number of features is being considered, the more potential precision in the
entropy, at the risk of adding a high abundance feature.

Entropic code, the data from our experiments, and the R scripts we used to
produce the paper figures are available on
[Figshare](https://figshare.com/articles/FSE2020_-_Boosting_Fuzzer_Efficiency_An_Information-Theoretic_Perspective/12415622),
DOI: [10.6084/m9.figshare.12415622](https://doi.org/10.6084/m9.figshare.12415622).

## LibFuzzer modifications

Entropic implemented into LibFuzzer. The implementation can be broken in two
logical steps: First, collect data on every feature frequencies; then, use
this data to compute the entropy of each seed and modify the scheduling of
seeds accordingly:
1. The collection of information happens in each run of a test case, in the
`RunOne` function. For every subject execution, a call will be made to a
function updating the feature frequencies at the local (i.e. concerning this
specific seed), and at the global level, i.e. for all the corpus ([see in
code](https://github.com/llvm/llvm-project/blob/e2e38fca64e49d684de0b100437fe2f227f8fcdd/compiler-rt/lib/fuzzer/FuzzerLoop.cpp#L478-L479)).
2. To modify the LibFuzzer scheduling algorithm, we modified the
`UpdateCorpusDistribution` function: LibFuzzer set a weight for each seed,
and then chooses seeds with probabilities proportional to their weights. So
first we inserted a call that regularly computes the entropy of
each seed ([see in
code](https://github.com/llvm/llvm-project/blob/e2e38fca64e49d684de0b100437fe2f227f8fcdd/compiler-rt/lib/fuzzer/FuzzerCorpus.h#L468)).
Then, we set each seed weight equal to its entropy ([see in
code](https://github.com/llvm/llvm-project/blob/e2e38fca64e49d684de0b100437fe2f227f8fcdd/compiler-rt/lib/fuzzer/FuzzerCorpus.h#L483)).
