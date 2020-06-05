# Summary

Welcome to the artifact for ESEC/FSE'20 research paper, "A Principled Approach to GraphQL Query Cost Analysis".

[![DOI](https://zenodo.org/badge/268707378.svg)](https://zenodo.org/badge/latestdoi/268707378)

## Table of contents

This artifact contains the items discussed in paper.

The sub-directories contain their own README.md files to clarify their contents.

| Item | Description | Location |
|------|-------------|----------|
| GraphQL query-response corpus                 | The 10,000 unique queries we generated for GitHub (5,000) and Yelp (5,000), and the responses from those service providers (anonymized) | `query-response` |
| Configuration of static analyses              | Our configuration of the static analyses (our own and those we compared against) | `analysis-config/` |
| Complexity measures for queries and responses | Data used to generate Figures 5 and 6, plus charts generator | `measured-complexity/` |
| Novel GraphQL query generator                 | Configuration details and link to the open-source tool | `query-gen/` |
| GraphQL schemas                               | GraphQL schemas for GitHub and Yelp at the time of the study | `graphql-schemas` |
| Verification                                  | Rerun the open-source library evaluation portion of the experiment                                                                      | `verification/`             |

Institutional policy precludes sharing the prototype of our own static analysis.
We have described the algorithms in enough detail to permit an independent implementation.
