FROM ubuntu:16.04

ADD entrypoint.sh /

ENV SPARK_VERSION 2.4.1
ENV BDLCL_VERSION 0.12.1

# Install Java 8
ENV JAVA_HOME /usr
ENV PATH $PATH:/usr/bin:/usr/lib:/etc/alternatives:/var/lib/dpkg/alternatives

RUN apt-get -qq update -y
RUN apt-get install -y unzip wget curl tar bzip2 software-properties-common git gcc make zlib1g-dev openjdk-8-jre libssl-dev vim

RUN echo 'export JAVA_HOME="/usr"' >> ~/.bashrc && \
    echo 'export PATH="$PATH:/usr/bin:/usr/lib"' >> ~/.bashrc && \
    bash ~/.bashrc 
    
#Add Java Security Policies
RUN curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
   unzip jce_policy-8.zip
RUN cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security && cp UnlimitedJCEPolicyJDK8/local_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security
RUN rm -rf UnlimitedJCEPolicyJDK8

# Install Spark 2.4.1
RUN cd /opt && wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz && \
   tar xzvf /opt/spark-$SPARK_VERSION-bin-hadoop2.7.tgz && \
   rm  /opt/spark-$SPARK_VERSION-bin-hadoop2.7.tgz
   
# Spark pointers for Jupyter Notebook
ENV SPARK_HOME /opt/spark-$SPARK_VERSION-bin-hadoop2.7
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip

ENV PATH $PATH:/$SPARK_HOME/bin/

# Fix guava dependencies for Google
#RUN wget http://central.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar -O $SPARK_HOME/jars/guava-23.0.jar && \
RUN rm $SPARK_HOME/jars/guava-14.0.1.jar

#Install Scala Spark kernel
#ENV SBT_VERSION 0.13.11
#ENV SBT_HOME /usr/local/sbt
#ENV PATH ${PATH}:${SBT_HOME}/bin
    
#RUN cd /tmp && \
#    wget "http://repo.bigstepcloud.com/bigstep/datalab/sbt-0.13.11.tgz" -O /tmp/sbt-0.13.11.tgz && \
#    tar -xvf /tmp/sbt-0.13.11.tgz -C /usr/local && \
#    echo -ne "- with sbt $SBT_VERSION\n" >> /root/.built

RUN cd /opt && \
    wget --no-check-certificate https://repo.lentiq.com/bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    tar -xzvf bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    rm -rf /opt/bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    cd /opt/bigstepdatalake-$BDLCL_VERSION/lib/ && \
    wget http://repo.uk.bigstepcloud.com/bigstep/bdl/BDL_libs/libhadoop.so && \
    cp /opt/bigstepdatalake-$BDLCL_VERSION/lib/* $SPARK_HOME/jars/ && \
    export PATH=/opt/bigstepdatalake-$BDLCL_VERSION/bin:$PATH && \
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/bigstepdatalake-$BDLCL_VERSION/lib/:$SPARK_HOME/jars/' >> ~/.bashrc && \
    bash  ~/.bashrc
    
#Add Thrift and Metadata support
#RUN cd $SPARK_HOME/jars/ && \
#   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-schema-1.2.0.postgres.sql && \
#   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-txn-schema-0.13.0.postgres.sql && \
#   wget http://repo.bigstepcloud.com/bigstep/datalab/hive-txn-schema-0.14.0.postgres.sql && \
RUN wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -P $SPARK_HOME/jars/ && \
   add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" && \
   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
   apt-get install -y postgresql-client 
   
#Install Python 3.6.7 and configure alias
RUN cd /opt && \
    wget https://www.python.org/ftp/python/3.6.7/Python-3.6.7.tgz && \
    tar xzf Python-3.6.7.tgz && \
    rm -rf Python-3.6.7.tgz && \
    cd ./Python-3.6.7/ && \
    ./configure --with-ssl && \
    make && \
#    make test && \
    make install && \
    alias python=python3.6 && \
    cd .. && \
    rm -rf Python-3.6.7 && \
    pip3 install numpy && \
    pip3 install pandas && \
    pip3 install py4j==0.10.7

#Add configuration files
ADD core-site.xml.apiKey $SPARK_HOME/conf/
ADD spark-defaults.conf $SPARK_HOME/conf/
ADD hive-site.xml $SPARK_HOME/conf/
ADD log4j2.xml.default $SPARK_HOME/conf/
#ADD log4j2.xml.audit $SPARK_HOME/conf/

RUN chmod 777 /entrypoint.sh

#        SparkMaster  SparkMasterWebUI  SparkWorkerWebUI REST     Jupyter Spark		Thrift
EXPOSE    7077        8080              8081              6066    8888      4040     88   10000

ENTRYPOINT ["/entrypoint.sh"]
