# Dependencies

Ensure you have [Node.js](https://nodejs.org/en/download/) installed in your machine v12.4.0 or later.

# How to use the artifact

## Verification

The sub-directory `verification/` contains a script that will recreate the open-source evaluation portion of the experiment.

## Reproducing the paper results

The sub-directory `measured-complexity/` contains all the data (complexity measures for the opensource libraries and our own solution), and a tool to regenerate the plots.

The sub-directory `query-response/` contains an anonymized version of the corpus used for these experiments.

## Run your own experiments

To generate your own corpus of random queries for the Yelp and Github APIs:

1. Retrieve the schemas of the two APIs (see `graphql-schemas/`)
2. Generate a corpus of random queries (see `query-gen/`)
3. Compute the complexity of the queries with three open-source libraries (see `analysis-config/`)
