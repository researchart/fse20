# ML-Fairness
This repository contains the source code and data used for the [paper](ml-fairness.pdf), to be appeared at ESEC/FSE 2020.

## Do the Machine Learning Models on a Crowd Sourced Platform Exhibit Bias? An Empirical Study on Model Fairness

#### Abstract
Machine learning models are increasingly being used in important decision-making software such as approving bank loans, recommending criminal sentencing, hiring employees, and so on. It is important to ensure the fairness of these models so that no discrimination is made between different groups in a protected attribute (e.g., race, sex, age) while decision making. Algorithms have been developed to measure unfairness and mitigate them to a certain extent. In this paper, we have focused on the empirical evaluation of fairness and mitigations on real-world machine learning models. We have created a benchmark of 40 top-rated models from Kaggle used for 5 different tasks, and then using a comprehensive set of fairness metrics evaluated their fairness. Then, we have applied 7 mitigation techniques on these models and analyzed the fairness, mitigation results, and impacts on performance. We have found that some model optimization techniques result in inducing unfairness in the models. On the other hand, although there are some fairness control mechanisms in machine learning libraries, they are not documented. The mitigation algorithm also exhibit common patterns such as mitigation in the post-processing is often costly (in terms of performance) and mitigation in the pre-processing stage is preferred in most cases. We have also presented different trade-off choices of fairness mitigation decisions. Our study suggests future research directions to reduce the gap between theoretical fairness aware algorithms and the software engineering methods to leverage them in practice.

## Installation and Usage
Follow the [instructions](INSTALL.md) to setup environment, run the source code, and validate results.

## Contact Lists
For any concerns contact the authors Sumon Biswas [sumon@iastate.edu] or Hridesh Rajan [hridesh@iastate.edu]. For more information [click here](CONTACT.md).

## License
The code is licensed under [MIT License](LICENSE.md): Copyright (c) 2020 FSE_ML_Fairness

## DOI
[![DOI](https://zenodo.org/badge/269506778.svg)](https://zenodo.org/badge/latestdoi/269506778)

## ACM Reference
Biswas, S. and Rajan, H. 2020. Do the Machine Learning Models on a Crowd Sourced Platform Exhibit Bias? An Empirical Study on Model Fairness. ESEC/FSE’2020: The 28th ACM Joint European Software Engineering Conference and Symposium on the Foundations of Software Engineering (Nov. 2020).
