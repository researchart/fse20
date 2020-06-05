# Entropic
<a href="https://mboehme.github.io/paper/FSE20.Entropy.pdf"><img src="Entropic.png" align="right" width="300"></a>

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
For more on LibFuzzer usage, see its [documentation](https://www.llvm.org/docs/LibFuzzer.html).

Entropic usage can be customized with two options:
- The `-considered_rare` option sets a threshold: If the incidence frequency
of a feature is below this threshold, this feature is considered "rare".
- When above the "rare" threshold, Entropic still keep tracks of a specific
number of feature with the lowest frequency. The `-topX_rarest_features` sets
this number.

See the paper, and in partical section 4.2.2, for more details and what the
setting of these options implies.

The data from our experiment is available on
[Figshare](https://figshare.com/articles/FSE2020_-_Boosting_Fuzzer_Efficiency_An_Information-Theoretic_Perspective/12415622),
DOI: [10.6084/m9.figshare.12415622](https://doi.org/10.6084/m9.figshare.12415622).