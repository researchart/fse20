# Install R

All calculations in the paper are calculated using `R version 3.6.2`.

If R is already installed, check your R version by running the following command on Linux/Mac

```
R --version
```

If R in not installed, please download and install it following the instructions at [The R Project for Statistical Computing](https://www.r-project.org/). After installation, again run the above command to check if the installation was successful.


## Install R packages
After successful installation of R, start the environment from command line using the command `R` on Linux/Mac. Through the R environment, install the `irr` package using the following command

```
install.packages("irr")
```

Check if the package is installed correctly by running the following. It should return `[1] TRUE`.

```
a <- installed.packages()
packages <- a[,1] 
is.element("irr", packages)
```

After successful installation of the irr package, exit from the R environment with the command `q()`.
