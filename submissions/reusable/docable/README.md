# Replication Package for _Docable: Evaluating the Executability of Software Tutorials_

## Overview

Our artifacts include a copy of our [sample of tutorials in HTML format](https://github.com/docable/docable/tree/master/tutorials) (collection process explained in **section 2.2**), the [execution harness](https://github.com/docable/docable/tree/master/harness) that we developed to automatically create computing environment (virtual machines) needed for executing tutorials (explained in **section 2.3**), scripts used to run ["naive" approach](https://github.com/docable/docable/tree/master/harness/naive) (explained in **secrion 2.4**), as well as ["Docable" implementation](https://github.com/docable/docable/tree/master/docable) which contains implementation of automated annotations that was discussed in our [paper](./docable_FSE_20.pdf) (explained in **section 2.5**).

Artifacts mentioned above can be obtained in [docable/docable](https://github.com/docable/docable) repository. DOI: [![DOI](https://zenodo.org/badge/245012918.svg)](https://zenodo.org/badge/latestdoi/245012918)

## Directories

- The sample of tutorials are included in [`./tutorials`](https://github.com/docable/docable/tree/master/tutorials) directory.

- Execution harness is included in [`./harness`](https://github.com/docable/docable/tree/master/harness) directories, and it includes a separate `README.md` files which contain instructions for reproducing similar experiements.

    - Naive approach is included as part of harness in [`./harness/naive`](https://github.com/docable/docable/tree/master/harness/naive) directory.

    - Docable execution harness is included in [`./harness/docable`](https://github.com/docable/docable/tree/master/harness/docable) directory.

- Docable annotation are included in [`./docable`](https://github.com/docable/docable/tree/master/docable) directory and includes a `README.md` file for installation instructions and more examples.

## Reproduce Experiments

Each directory in the [artifacts repository](https://github.com/docable/docable) contains a `README.md` instructions for how they can be used.
