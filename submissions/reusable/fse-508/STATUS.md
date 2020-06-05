# STATUS

## Badge

ACM Reusable

## Why

We present CoEvA2, a multi-objective search technique to generate adversarial examples against real-world machine learning systems. It exploits domain-specific constraints and objectives to cause misclassifications that are feasible in reality. 

In our paper, we report experimental results on a real-world industrial credit scoring system (developed an used by our partner). However, this work is subjected to a strigent non-disclosure agreement which forbids us to disclose the dataset used in our experiments (although the implementation of CoEvA2 can be made public).

In order for the research community to benefit from our tool and studies, we prepared scripts to execute CoEvA2 and reproduce our experiments on another (publicly available) dataset: the *Lending Club Loan data*. Even though this dataset is less challenging than our partner's case, it is sufficient to appreciate the benefits of CoEvA2 and confirm the conclusions of our study, mainly the following:

- State-of-the-art (random & Papernot's) attacks fail to generate adversarial examples satisfying the domain constraints
- Our multi-objective search method (CoEvA2) succeeds where the state of the art failed. Combining all four objectives yield the best results.
- We can improve the robustness of the system by retraining the system using the generated adversarial examples.

Furthermore, by providing this additional case study, we demonstrate that our tool can easily accomodate to other datasets and be reused by the community be with small effort. 

We have announced this to the artifact chair before submitting. In spite of the NDA, they encouraged us to proceed with the submission. We hope that the reviewers will also appreciate our efforts to make our research results available to all.