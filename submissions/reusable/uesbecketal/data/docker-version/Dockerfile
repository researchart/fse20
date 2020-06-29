FROM rocker/tidyverse:4.0.0
COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts
RUN R -f dependencies.R

CMD ["Rscript", "analysis-Docker.R"]
