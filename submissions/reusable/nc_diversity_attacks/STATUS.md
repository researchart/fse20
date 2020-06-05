# STATUS

## Badge Requested: `Reusable`

The artifacts were made initially available via a DOI repository: https://doi.org/10.5281/zenodo.3695631. While this code was certainly functional, I put in the extra effort to:
 - generalize the code for non-Windows environments and non-GPU environments.
 - make it as easy as possible replicate and review by providing both a VM option and a self-setup option in the `INSTALL.md` file. 

Much of the code is commented as well, making it easier to use in other situations should people find our work useful to them. The metadata for all 6 sets of evaluation scripts is provided in the `assets` folder so that the raw figures can be reviewed. The `notebook` also contains the code used to generate the visualizations and a cross section of the correlations are still viewable. 

Lastly, my primary concern is that rerunning evaluation itself requires many hours of compute time on GPUs and I don't think you'll likely want to wait to confirm its completion. Either way, if the requested badge is rejected I hope that: 1) we will still qualify for `Functional` and that you will have some advice that I can use to attain `Reusable` next time :)