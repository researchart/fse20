
# Overview

When designing a software system, architects make a series of design
decisions that directly impact the system's quality. The number of available
design alternatives grows rapidly with system size, creating an enormous
space of intertwined design concerns that renders manual exploration
impractical.
Here we provide an implementation of  eQual as presented at FSE 2020. eQual a model-driven technique for simulation-based assessment
of architectural designs. While it is impossible to guarantee optimal
decisions so early in the design process, eQual improves decision quality.
eQual is effective in practice because it:

    1.limits the amount of information the architects have to provide and
    2.adapts optimization algorithms to effectively explore massive spaces of design alternatives.

A user study shows that, compared to the prior state of the art, engineers
using eQual produce statistically significantly higher-quality designs with
a large effect size, are statistically significantly more confident in their
designs, and find eQual easier to use.

# Artifacts

The source code and artifacts of the eQual can be found at https://github.com/arman2/equal_public. 

## User Study

We conducted a within-subject controlled experiment with 15 participants using eQual and GuideArch to measure:

whether users were more likely to produce higher-quality designs using GuideArch, eQual, or without any tool support; and
whether the users preferred using GuideArch, eQual, or neither tool.
Full details of this user study can be found in Section 4.3 and its pertinent data is located [here](https://github.com/arman2/equal_public/tree/master/User%20Study%20Data).

## Effectiveness Data

We evaluated eQual’s effectiveness against known fitness models of six real-world systems, summarized in Figure 5. The full details of this study can be found in Section 4.2 of the paper. The corresponding files are located [here](https://github.com/arman2/equal_public/tree/master/Effectiveness%20Data).

## Scalability Data

To evaluate eQual’s scalability, we used Google Compute Engine (GCE). We created 16 n1-standard-1 nodes (the most basic configuration available in GCE, with 1 vCPU and 3.75 GB RAM) as simulation nodes, and a single n1-standard-2 node (2 vCPU and 7.5 GB RAM) as the central controller node. All nodes were located in Google’s us-central1-f datacenter. We used the variation points and NFPs described in Section 3. The full details can be found in Section 4.4 of the paper. In short, we analyzed eQual’s scalability in terms of number of nodes, number of events, and number of variants. The data for these simulations is hosted [here](https://github.com/arman2/equal_public/tree/master/Simulation%20Data). 

## Source Code

We have implemented eQual on top of DomainPro, resulting in 4.7K C# and 1.0K JavaScript SLoC added to DomainPro. To aid in eQual’s evaluation, we also built a utility totaling an additional 1.0K C# and 0.2K MATLAB SLoC, as detailed in Section 4.2. All source code, including DomainPro, is hosted [here](https://github.com/arman2/equal_public/tree/master/Source%20Code).
