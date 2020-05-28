# Installation and Dependencies

This project is expected to be run from the **root** repository directory. It requires Python 3.6 or newer.
It depends on the following python packages:

```
jsonpickle==1.2    # For data loading and storage
scipy>=1.3.1       # Used for the Hungarian algorithm when evaluating 3+ untangles
tqdm>=4.38.0       # Used for progressbars
networkx>=2.4      # Used for shortest-paths and general graph utils
numpy>=1.17.3      # Used for matrix operations
fuzzywuzzy>=0.17.0 # Used for fuzzy string matching
pygraphviz>=1.6    # Used as the main way to interact with .dot files
pydot>=1.4.1       # Used as a fall-back method to read .dot files
grakel>=0.1a6      # Used for the WL-kernel implementation
nltk>=3.4.4        # Used for tokenisation
```

Additionally, corpus generation or generation of the 𝛿-PDG requires either the use of a MS Windows machine with .NET 4.5 or newer or WSL1. 
We have validated the system to work when the Windows specific code is called from WSL1. We have not validated using wine or mono under Linux.

A more detailed guide is available on the main repository for the project: [link](https://github.com/PPPI/Flexeme).