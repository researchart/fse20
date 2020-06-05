# Use the official image as a parent image.
FROM debian:stretch

# Setup the environment
ENV JAVA_HOME /usr/lib/jvm/java-1.11.0-openjdk-amd64
WORKDIR /home

# Install debian packages
RUN echo 'deb http://ftp.debian.org/debian stretch-backports main' | tee /etc/apt/sources.list.d/stretch-backports.list
RUN dpkg --configure -a
RUN apt-get -f install
RUN apt-get upgrade
RUN apt-get update
RUN apt-get install -y git openjdk-11-jdk openjdk-11-dbg libjna-jni maven ant make python3 python3-pip kmod msr-tools msrtool wget

# Setup python
RUN pip3 install numpy scipy pandas tqdm matplotlib seaborn

# Setup chappie
RUN git clone https://github.com/pl-chappie/chappie.git
RUN cd chappie/vendor/jlibc && mvn package
RUN cd chappie/vendor/async-profiler && make
RUN cd chappie/src/java/jrapl-port && make
RUN cd chappie && ant deps && ant jar

ENTRYPOINT modprobe msr && \
  cd chappie/wrapper && \
  mkdir jar && \
  wget https://dacapo-data.s3.amazonaws.com/dacapo-evaluation-git.jar -O jar/dacapo-evaluation-git.jar && \
  mkdir jar/evaluation-git+309e1fa && \
  ant jar && \
  cd .. && fse2020/run-experiments.sh \
