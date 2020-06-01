# STATUS

## Badge

ACM Reusable Badge

## Reasons

**Availability.** We have shared our tool implementation, experimental scripts, and all the models and datasets used by LEMON, in order to reproduce our experiments and reuse our tool in practice.

**Carefully Documented.** We have provided a very detailed README document to describe in detail what LEMON is, how to create a LEMON environment, how to configure the parameters in LEMON, how to run the tool, and how to reproduce our experiments.

**Demo Run.** We have provided a docker image of one experiment as an example and showed the corresponding instructions. Researchers can directly reproduce the results of LEMON published in the paper by using experiment configuration file (specific file name `experiments.conf`), but it can't be completed within 48 hours. Furthermore, to allow review of Reusable Badge to see the effectiveness of LEMON in a short time, we provide a `demo run`, which can find about 7 suspected bugs within 1 hour (Due to the randomness in the process of generating mutants, the number of bugs may change). 

**Scalability.** The scalability of LEMON has been carefully considered by us. Researchers can easily extend LEMON to other models and datasets through our extension instructions.