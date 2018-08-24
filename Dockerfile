FROM ubuntu:16.04

ADD entrypoint.sh /

ADD core-site.xml.datalake /opt/spark-2.3.0-bin-hadoop2.7/conf/
ADD core-site.xml.s3 /opt/spark-2.3.0-bin-hadoop2.7/conf/
ADD core-site.xml.gcs /opt/spark-2.3.0-bin-hadoop2.7/conf/
ADD core-site.xml.datalake.integration /opt/spark-2.3.0-bin-hadoop2.7/conf/
ADD spark-defaults.conf /opt/spark-2.3.0-bin-hadoop2.7/conf/spark-defaults.conf

ADD krb5.conf.integration /etc/
ADD krb5.conf /etc/

# Install Java 8
ENV JAVA_HOME /opt/jdk1.8.0_181
ENV PATH $PATH:/opt/jdk1.8.0_181/bin:/opt/jdk1.8.0_181/jre/bin:/etc/alternatives:/var/lib/dpkg/alternatives

RUN apt-get -qq update -y
RUN apt-get install -y unzip wget curl tar bzip2 software-properties-common git

RUN cd /opt && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz" &&\
   tar xzf jdk-8u181-linux-x64.tar.gz && rm -rf jdk-8u181-linux-x64.tar.gz

RUN echo 'export JAVA_HOME="/opt/jdk1.8.0_181"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/jdk1.8.0_181/bin:/opt/jdk1.8.0_181/jre/bin"' >> ~/.bashrc && \
    bash ~/.bashrc && cd /opt/jdk1.8.0_181/ && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_181/bin/java 1
    
#Add Java Security Policies
RUN curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
   unzip jce_policy-8.zip
RUN cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /opt/jdk1.8.0_181/jre/lib/security/ && cp UnlimitedJCEPolicyJDK8/local_policy.jar /opt/jdk1.8.0_181/jre/lib/security/
RUN rm -rf UnlimitedJCEPolicyJDK8

# Install Spark 2.3.0
RUN cd /opt && wget https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz && \
   tar xzvf /opt/spark-2.3.0-bin-hadoop2.7.tgz && \
   rm  /opt/spark-2.3.0-bin-hadoop2.7.tgz 
   
# Fix guava dependencies for Google
RUN wget http://central.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar -O $SPARK_HOME/jars/ && \
      rm $SPARK_HOME/jars/guava-14.0.1.jar

# Spark pointers for Jupyter Notebook
ENV SPARK_HOME /opt/spark-2.3.0-bin-hadoop2.7
ENV R_LIBS_USER $SPARK_HOME/R/lib:/opt/conda/envs/ir/lib/R/library:/opt/conda/lib/R/library
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip

ENV PATH $PATH:/$SPARK_HOME/bin/

#Install Scala Spark kernel
ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin
    
RUN cd /tmp && \
    wget "http://repo.bigstepcloud.com/bigstep/datalab/sbt-0.13.11.tgz" -O /tmp/sbt-0.13.11.tgz && \
    tar -xvf /tmp/sbt-0.13.11.tgz -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built
   
RUN chmod 777 /entrypoint.sh
RUN wget https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-latest-hadoop2.jar -O /opt/gcs-connector-latest-hadoop2.jar

#        SparkMaster  SparkMasterWebUI  SparkWorkerWebUI REST     Jupyter Spark		Thrift
EXPOSE    7077        8080              8081              6066    8888      4040     88   10000

ENTRYPOINT ["/entrypoint.sh"]
