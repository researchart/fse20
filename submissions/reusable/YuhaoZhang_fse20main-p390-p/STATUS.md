# STATUS

## Badge

Reusable Badge

## Reasons

We maintain our tool DEBAR at https://github.com/ForeverZyh/DEBAR. The artifact as well as the online available tool is:

1. Carefully documented: We provide very detailed documentation of all source files, all classes, and most of the member functions. Please see https://github.com/ForeverZyh/DEBAR/tree/without-SMT/docs.

2. Consistent: We provide ways to generate consistent results in the paper.

3. Complete: We provide the docker way of running DEBAR in the artifact. The only additional package needed to be installed is docker, which we provide instructions for how to obtain.

4. Exercisable: We provide scripts that generate the results in the paper and share the link for downloading the collected datasets.

5. Reusing and Reproducing: We believe our tool is well-structured and we provide guidelines for contributing and redevelopment of our tool. Please see https://github.com/ForeverZyh/DEBAR/blob/without-SMT/CONTRIBUTING.md.

6. Evidence of verification and validation: for the numerical bugs we detected, we create some pull requests to try to fix the bugs. By the time of preparing this artifact, two of them are accepted and merged:
   https://github.com/tensorflow/models/pull/8223

   https://github.com/tensorflow/models/pull/8221
   Rejected pull requests are all due to that the architecture is deprecated or there is no developer maintaining the architecture.
