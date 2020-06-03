# Artifacts for MAESTRO

This README file describes the artifacts for the paper "Recommending Stack Overflow Posts for Fixing Runtime Exceptions using Failure Scenario Matching" accepted in the technical track of ESEC/FSE 2020. A prototype implementation of our tool is called MAESTRO (**M**ine and **A**nalyz**E** **ST**ackoverflow to fix **R**untime excepti**O**ns).

In this artifact package, we present our data repository including the input and output artifacts of our MAESTRO tool. We describe the specific artifacts in detail below.


## Download instructions

Our artifact package can be downloaded at [https://doi.org/10.6084/m9.figshare.11948619](https://doi.org/10.6084/m9.figshare.11948619). It is available in the form of a zip file. The decompressed (unzipped) file contains the directory structure a shown below. The size of the zipped file is approximately 105 MB, while the unzipped package is approximately 460 MB.

## Artifacts package structure

```
artifacts
  └── buggy-instances
  └── experiment-results
  └── indexed-stackoverflow-posts
  └── scripts
  └── settings
```

### "buggy-instances" contents

This directory contains the input benchmark of 78 buggy instances used for evaluating MAESTRO. The instances are presented as Java files downloaded from GitHub. The instance names are written with the following convention: `<exception type>_<repo name>-<commit id>_<failing line number>`. For example, the instance "ArithmeticException_apache-cassandra-ce44599_189.java" indicates that it belongs to the *apache-cassandra* repository at commit *ce44599*, which throws the *ArithmeticException* at line *189*.

### "experiment-results" contents

This directory contains output results of MAESTRO, its three variants, and its four competitors on the above benchmarks, along with raw quality ratings of those results provided by our participants. The raw user experience case study results are also included.

**Results of RQ1-3:** In the "eval-rating-reordered-*.csv" files, we present the results for the 78 instances for all 8 tools considered in our evaluation (MAESTRO, No localization variant, Simple matching variant, AST variant, Prompter-RE, FaCoY-RE, Deckard, and Top rated).

The format of the three files is as follows:
- Column A shows the runtime exception (RE) category, column B shows exception name, column C shows the buggy instance names, and column D shows the corresponding Github links for the instances. The failing line number is also appended to the Github link. Note that the instance name in column C matches with the Java files in the "buggy-instances" directory.
- The Stack Overflow posts reported by the different tools are presented by their IDs in the columns E, G, I, K, M, O, Q, and S. The corresponding post can be accessed on Stack Overflow by prepending the ID with "http://stackoverflow.com/q/". For example, 5690351 in cell E3 becomes "http://stackoverflow.com/q/5690351". The entry with "-" indicates that the tool did not produce any Stack Overflow post.
- Columns F, H, J, L, N, P, R, and T show the relevancy ratings given by participants for the different Stack Overflow posts.

`eval-rating-reordered-participant1.csv`: raw survey ratings of the first participant *before consensus* <br />
`eval-rating-reordered-participant2.csv`: raw survey ratings of the second participant *before consensus* <br />
`eval-rating-reordered-consensus.csv`: final results *after consensus* between the two participants

NOTE: the data was presented to the participants in randomized order with the tool names anonymized. For presenting as artifacts, we reordered the data and put back the tool names.


**User Experience Case Study Results:** `user-experience-case-study-results.csv` presents the raw survey results from our user experience case study discussed in Section 4.7 of the paper. We performed this study on 10 instances with 10 participants, each participant evaluating 5 instances.
- Column A shows the instance name and column B shows its corresponding GitHub link
- Column C presents the Stack Overflow post ID reported by MAESTRO
- Column D shows the Stack Overflow posts reported by the participants from their *manual search*.
- Column E shows the ratings given by the participants for the post reported by MAESTRO
- Column F shows the experience feedback provided by the participants

### "indexed-stackoverflow-posts" contents

This directory contains the Stack Overflow posts indexed by MAESTRO for its analysis. The posts satisfy the filtering criteria discussed in Section 3.1 of the paper. Each Stack Overflow post is stored in JSON format and its parsable code snippets are stored as `.txt` files. Specifically, the contents in the "indexed-stackoverflow-posts" directory are organized as follows. Note that, by design of Stack Overflow, the question in a post inherits the ID of the post, while the answers in that post have their own independent IDs.

```
indexed-stackoverflow-posts
  └── exception type (e.g., arithmeticexception)
      └── post ID (e.g., 2281275)
          └── <post ID>-ques.json (e.g. 2281275-ques.json)
          └── <post ID>-ques-code-snippets (e.g., 2281275-ques-code-snippets)
              └── cs<ID>.txt (e.g., cs1.txt)    # parsable code snippet
          └── <post ans ID>-ans.json (e.g. 2281303-ans.json)
          └── <post ans ID>-ans-code-snippets (e.g., 2281303-ans-code-snippets)
              └── cs<ID>.txt (e.g., cs1.txt)    # parsable code snippet
```

NOTE: Parsability is determined by minimally completing the code snippet by adding enclosing method and/or class, and successful AST construction by JavaParser.


### "scripts" contents

This directory contains two scripts used for reproducing the results presented in the evaluation of the paper.

The `cohens-kappa.R` script calculates the value of Cohen's Kappa presented in Section 4.3. <br />
The `results.R` script calculates the I-score, IH-score, and M-score values presented in RQ1-3 (Sections 4.4-4.6).


### "settings" contents

`Deckard-configurations.txt` contained in this directory presents the exact configurations that we used for running Deckard, a competitor tool used in RQ3. The file also states the protocol that we used to find the most relevant post reported by Deckard


# Reproducing results in the paper:

We now describe the steps to be followed to reproduce the results in our paper. Details about setting up the environment for running the scripts can be found in [INSTALL.md](https://github.com/maestro-fla/fse20/blob/master/submissions/functional/fse-894/INSTALL.md).

From the unzipped artifacts package, navigate to the scripts directory.

```
cd artifacts/scripts
```


### Compute Cohen's Kappa

Cohen's Kappa is used to denote inter-rater agreement between different participants (refer to Section 4.3 of the paper). From the `scripts` directory, execute the `cohens-kappa.R` script to compute Cohen's Kappa.

```
Rscript cohens-kappa.R
```

This should produce the below Kappa value that is reported in the paper.

```
Kappa = 0.631
```


### Calculate RQ1-RQ3 results

The overall effectiveness of MAESTRO (RQ1), its three variants (RQ2), and its four competitors (RQ3) is categorized using the metrics: I-score, IH-score, and M-score as discussed in Section 4.3 of the paper. The results for the tools can be calculated by running the `results.R` script from the `scripts` directory.

```
Rscript results.R
```

An excerpt of the output produced by the script is shown below

```
[1] "MAESTRO results:"
[1] "I-score = 0.4"
[1] "IH-score = 0.71"
[1] "M-score = 0.26"
```

The different score values are rounded to two decimal points for each of the eight types of tools. The results can be cross-checked with the paper as follows. "MAESTRO results" correspond to the overall values reported in Table 1. Similarly, MAESTRO's variants IH-score corresponds to Figure 6, while MAESTRO's competitors IH-scores can be found in Figure 7.

# Verification

In addition to reproducing the results in the paper as described above, the relevancy ratings ascribed by the participants can also be verified. As discussed in Section 4.3, deciding the relevancy of the Stack Overflow posts recommended by MAESTRO and other techniques is a subjective, manual process.

The reviewers can verify the ratings available under the "experiment-results" folder in the following way.
- Open a results file (e.g., eval-rating-reordered-consensus.csv)
- Select a buggy instance to be inspected (e.g., ClassCastException_apache-dubbo-58b51cd_104). Open the instance from "buggy-instances" directory or the corresponding GitHub link.
- Inspect and understand the context of the runtime exception being thrown.
- Open the recommended Stack Overflow post for the instance (e.g., http://stackoverflow.com/q/5690351).
- Rate the post as *Instrumental*, *Helpful*, *Unavailable*, or *Misleading* (refer Section 4.3 for definitions).
- Verify the rating with the one ascribed in the results file.
