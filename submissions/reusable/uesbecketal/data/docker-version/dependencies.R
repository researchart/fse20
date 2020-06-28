library(devtools)

# Specific versions of packages for compatability, please primarily rely on standard install, but use if run fails
#  This might require installing fortran binaries to compile the libraries
install_version("tidyverse", version = "1.3.0", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("car", version = "3.0-8", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("compute.es", version = "0.2-5", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("multcomp", version = "1.4-13", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("pastecs", version = "1.3.21", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("WRS2", version = "1.0-0", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("psych", version = "1.9.12.31", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("gmodels", version = "2.18.1", repos = "http://cran.us.r-project.org", upgrade = TRUE)
install_version("ez", version = "4.4-0", repos = "http://cran.us.r-project.org", upgrade = TRUE)
