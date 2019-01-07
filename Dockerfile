FROM ubuntu:16.04

ADD entrypoint.sh /

# Install Java 8
ENV JAVA_HOME /opt/jdk1.8.0_191
ENV PATH $PATH:/opt/jdk1.8.0_191/bin:/opt/jdk1.8.0_191/jre/bin:/etc/alternatives:/var/lib/dpkg/alternatives

RUN apt-get -qq update -y
RUN apt-get install -y unzip wget curl tar bzip2 software-properties-common git

RUN cd /opt && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz" &&\
   tar xzf jdk-8u191-linux-x64.tar.gz && rm -rf jdk-8u191-linux-x64.tar.gz

RUN echo 'export JAVA_HOME="/opt/jdk1.8.0_191"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/opt/jdk1.8.0_191/bin:/opt/jdk1.8.0_191/jre/bin"' >> ~/.bashrc && \
    bash ~/.bashrc && cd /opt/jdk1.8.0_191/ && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_191/bin/java 1
    
#Add Java Security Policies
RUN curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
   unzip jce_policy-8.zip
RUN cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /opt/jdk1.8.0_191/jre/lib/security/ && cp UnlimitedJCEPolicyJDK8/local_policy.jar /opt/jdk1.8.0_191/jre/lib/security/
RUN rm -rf UnlimitedJCEPolicyJDK8

# Install Spark 2.4.0
RUN cd /opt && wget https://www-eu.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz && \
   tar xzvf /opt/spark-2.4.0-bin-hadoop2.7.tgz && \
   rm  /opt/spark-2.4.0-bin-hadoop2.7.tgz
   
# Spark pointers for Jupyter Notebook
ENV SPARK_HOME /opt/spark-2.4.0-bin-hadoop2.7
ENV R_LIBS_USER $SPARK_HOME/R/lib:/opt/conda/envs/ir/lib/R/library:/opt/conda/lib/R/library
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip

ENV PATH $PATH:/$SPARK_HOME/bin/

# Fix guava dependencies for Google
RUN wget http://central.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar -O $SPARK_HOME/jars/guava-23.0.jar && \
      rm $SPARK_HOME/jars/guava-14.0.1.jar

#Install Scala Spark kernel
ENV SBT_VERSION 0.13.11
ENV SBT_HOME /usr/local/sbt
ENV PATH ${PATH}:${SBT_HOME}/bin
    
RUN cd /tmp && \
    wget "http://repo.bigstepcloud.com/bigstep/datalab/sbt-0.13.11.tgz" -O /tmp/sbt-0.13.11.tgz && \
    tar -xvf /tmp/sbt-0.13.11.tgz -C /usr/local && \
    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

RUN cd /opt && \
    wget http://repo.uk.bigstepcloud.com/bigstep/bdl/bigstepdatalake-0.9.1-bin.tar.gz && \
    tar -xzvf bigstepdatalake-0.9.1-bin.tar.gz && \
    rm -rf /opt/bigstepdatalake-0.9.1-bin.tar.gz && \
    cp /opt/bigstepdatalake-0.9.1/lib/* $SPARK_HOME/jars/ && \
    export PATH=$PATH:/opt/bigstepdatalake-0.9.1/bin
    
#Add Thrift and Metadata support
RUN cd $SPARK_HOME/jars/ && \
   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-schema-1.2.0.postgres.sql && \
   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-txn-schema-0.13.0.postgres.sql && \
   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-txn-schema-0.14.0.postgres.sql && \
   wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -P $SPARK_HOME/jars/ && \
   add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" && \
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
   apt-get install -y postgresql-client 

#Add configuration files
ADD core-site.xml.apiKey $SPARK_HOME/conf/
ADD spark-defaults.conf $SPARK_HOME/conf/
ADD hive-site.xml $SPARK_HOME/conf/
ADD log4j2.xml.default $SPARK_HOME/conf/
ADD log4j2.xml.audit $SPARK_HOME/conf/

RUN chmod 777 /entrypoint.sh

#        SparkMaster  SparkMasterWebUI  SparkWorkerWebUI REST     Jupyter Spark		Thrift
EXPOSE    7077        8080              8081              6066    8888      4040     88   10000

ENTRYPOINT ["/entrypoint.sh"]
