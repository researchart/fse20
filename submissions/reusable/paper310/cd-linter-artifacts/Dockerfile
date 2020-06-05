FROM ubuntu:18.04

# install Java 11
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q \
 && apt-get upgrade -q -y \
 && apt-get install -q -y \
        binutils=2.30-21ubuntu1~18.04.3 \
        openjdk-11-jdk-headless=11.0.7+10-2ubuntu2~18.04

# install Maven
RUN apt-get -y install maven=3.6.0-1~18.04.1

# install Python 3.7
RUN apt install software-properties-common -y \
&& add-apt-repository ppa:deadsnakes/ppa -y \
&& apt install python3.7=3.7.7-1+bionic1 -y

# install pip
RUN apt install python3-pip=9.0.1-2.3~ubuntu1.18.04.1 -y

# install R and required packages
RUN apt-get install r-base=3.4.4-1ubuntu1 -y \
&& R -e "install.packages('http://azzalini.stat.unipd.it/SW/Pkg-mnormt/mnormt_1.5-5.tar.gz', repos=NULL, type='source')" \
&& R -e "install.packages('likert')" \
&& R -e "install.packages('knitr')"

# install vim
RUN apt-get install vim=2:8.0.1453-1ubuntu1.3 -y

# copy all content inside
RUN mkdir /home/cd-linter-artifacts
COPY . /home/cd-linter-artifacts
WORKDIR /home/cd-linter-artifacts

# install the required dependencies
RUN pip3 install -r requirements.txt