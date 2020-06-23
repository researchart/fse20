# Installation

Each directory of artifacts repository contains a `README.md` with detailed instructions for installing dependencies and using the artifacts. Here we also include a summary of those instructions:

## Prerequisite

- Our testing harness is written using [Node.js](https://nodejs.org/en/). Please refer to Node.js [official installation instructions for your operating system](https://nodejs.org/en/download/package-manager/). Requires Node version > `10.x.x`.

- Our testing harness uses [VirtualBox](https://www.virtualbox.org/) for creation of computing environments (virtual machines). Simply download the correct executable installer for your operating system [on this page](https://www.virtualbox.org/wiki/Downloads), and run it to install VirtualBox. Tested with VirtualBox version `6.1.8`.

    > _Note: you need to make sure hardware virtualization (Intel VT-x or AMD SVM) support is enabled on your system before using virtualbox._

- Our scripts also use several packages for the implementation, which need to be installed before they can run. This can simply be done by running `npm install` in `./harness` directory:

    ```bash
    git clone https://github.com/docable/docable.git
    cd docable/harness
    npm install
    ```

## Execution

More detailed instructions for execution are included in [the artifacts repo](https://github.com/docable/docable/tree/master/harness). Here is a summary of those instructions:

### Naive

After installing the prerequisites, you can execute the naive execution harness by running this command:

```
cd harness/naive
node node index.js test --optionyes     # <--- naive   execution
node node index.js test                 # <--- naive++ execution
```

You will see the execution harness pulls a base image for the corresponding VM image, provision a VM using that image, and start executing the code blocks of tutorials. Logs from execution from executions are stored in `./harness/naive/logs`. Make sure to move the logs to another directory before starting execution using a different approach, to avoid deleting old logs.

### Docable

After installing the prerequisites, you can execute the docable execution harness by running this command:

```
cd harness/docable
node index.js
```

You will see the execution harness pulls a base image for the corresponding VM image, provision a VM using that image, and start executing the annotations. Results of annotations are then stored in Docable feedback files (ex. Figure 4 in the paper) which are created in a new directory called `docable_results` in the same directory as annotations (`./annotations/docable_results`).

Additionally you should be able to see virtual machines in VirtualBox application, as they are provisioned and removed after execution is done.
