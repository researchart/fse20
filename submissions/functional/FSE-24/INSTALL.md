# Dependencies

For running the code in the different subdirectories:

* [Node.js](https://nodejs.org/en/download/), `v12.4.0` or higher
* [npm](https://www.npmjs.com/get-npm) (bundled with Node.js), `v6.10.2` or higher

For plotting the data in `measured-complexity/`:

* [Python](https://www.python.org/downloads/), `v3.7.7` or higher

Additional Node.js and Python dependencies are defined in `package.json` and `requirement.txt` files in the different subdirectories. Please read the `README.md` in the subdirectories for additional installation and usage instructions. 

# How to use the artifact

## Verification

The sub-directory `verification/` contains a script that will recreate the open-source evaluation portion of the experiment.

## Reproducing the paper results

The sub-directory `measured-complexity/` contains all the data (complexity measures for the open-source libraries and our own solution), and a script to regenerate the plots.

The sub-directory `query-response/` contains an anonymized version of the corpus used for these experiments.

## Run your own experiments

To generate your own corpus of random queries for the Yelp and Github APIs:

1. Retrieve the schemas of the two APIs (see `graphql-schemas/`)
2. Generate a corpus of random queries (see `query-gen/`)
3. Compute the complexity of the queries with three open-source libraries (see `analysis-config/`)
