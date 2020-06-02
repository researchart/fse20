# Status

We apply for all three badges (availabe, functional and reusable). 


## Available

The artifact is available at [Zenodo](https://doi.org/10.5281/zenodo.3872805).


## Functional

The artifact is:

* documented: Documentation is found in in the INSTALL.md and README.md files.

* consistent: The scripts included in the Docker container are the ones we used to produce the results presented in the paper.

* complete: The Docker container contains all scripts used to generate the results presented in the paper. The Docker container contains all tools used to generate these results, including the source code of our own tool.

* exercisable: Scripts included in the Docker container can be exercised as described in the README.md. Results are produced as .csv files and can be manipulated by further scripts included in the Docker container or they can be manipulated directly outside of the Docker container.

* valdiation/verification: The artifact can be used to reproduce the results of the paper directly, as the scripts contained in the Docker container are the original scripts that were used to generate these results.


## Reusable

As described in the last two section, the artifact is both __Available__ and __Functional__. We additionally provide our tool, BlaSt, on GitHub, where it is carefully documented and open-sourced as part of the OPAL static analysis framework: [OPAL GitHub link](https://github.com/stg-tud/opal) OPAL, including BlaSt, is also included in full in the Docker container provided.

The artifact is reusable in the sense that:

* other static analysis frameworks can either use BlaSt to implement equivalent analyses and compare them to their implementations or compare against our already existing case study implementations.

* hints on how to use the artifact to execute further analyses in BlaSt or Doop are given in the README.md files.

The artifact can also be repurposed to facilitate research: 

* in various static analysis/programming language domains, e.g., Immutability, by using BlaSt to write the analyses

* on the modularity of static analyses by comparing the complexity of our case study implemenations (Escape Analysis, Purity Analysis, Call Graphs, etc.) to other frameworks and their implementations.