#!/bin/bash

export SPARK_HOME="/opt/spark-2.3.0-bin-hadoop2.7"
export JAVA_HOME="/opt/jdk1.8.0_181/"                                                                                                                               
export PATH="$PATH:/opt/jdk1.8.0_181/bin:/opt/jdk1.8.0_181/jre/bin"
export PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"
export HADOOP_CONF_DIR="$SPARK_HOME/conf"
export JAVA_CLASSPATH="$JAVA_HOME/jre/lib/"
export JAVA_OPTS="-Dsun.security.krb5.debug=true -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M"
export CLASSPATH=$SPARK_HOME/jars/:/opt/gcs-connector-latest-hadoop2.jar
export SPARK_OPTS="--driver-java-options=-$JAVA_DRIVER_OPTS --driver-java-options=-XX:MetaspaceSize=128M --driver-java-options=-XX:MaxMetaspaceSize=256M --driver-java-options=-Dlog4j.logLevel=info --master $SPARK_MASTER_URL --files $SPARK_HOME/conf/hive-site.xml"


echo Using SPARK_HOME=$SPARK_HOME

. "${SPARK_HOME}/sbin/spark-config.sh"
. "${SPARK_HOME}/bin/load-spark-env.sh"

#if [ "$ENV" == "s3" ]; then
#	mv $SPARK_HOME/conf/core-site.xml.s3 $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$ENV" == "gcs" ]; then
#	mv $SPARK_HOME/conf/core-site.xml.gcs $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$ENV" == "bigstep" ]; then
#	mv $SPARK_HOME/conf/core-site.xml.datalake $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$ENV" == "integration" ]; then
#	mv $SPARK_HOME/conf/core-site.xml.datalake.integration $SPARK_HOME/conf/core-site.xml
#fi

#Configure Google Cloud Platform connection details 

#if [ "$JSON_KEY_FILE" != "" ]; then
##	sed "s/JSON_KEY_FILE/$JSON_KEY_FILE/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \#
#	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$GCP_PROJECT_ID" != "" ]; then#
#	sed "s/GCP_PROJECT_ID/$GCP_PROJECT_ID/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \#
#	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
#fi

#Configure AWS connection details
#if [ "$ACCESSKEY" != "" ]; then
#	sed "s/ACCESSKEY/$ACCESSKEY/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
#	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$SECRETKEY" != "" ]; then
#	sed "s/SECRETKEY/$SECRETKEY/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
#	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
#fi
#if [ "$S3_ENDPOINT" != "" ]; then
#	sed "s/S3_ENDPOINT/$S3_ENDPOINT/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
#	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
#fi

if [ "$SPARK_MASTER_PORT" == "" ]; then
  SPARK_MASTER_PORT=7077
fi
if [ "$SPARK_MASTER_IP" == "" ]; then
  SPARK_MASTER_IP="0.0.0.0"
fi
if [ "$SPARK_MASTER_WEBUI_PORT" == "" ]; then
  SPARK_MASTER_WEBUI_PORT=8080
fi
if [ "$SPARK_WORKER_WEBUI_PORT" == "" ]; then
  SPARK_WORKER_WEBUI_PORT=8081
fi
if [ "$SPARK_UI_PORT" == "" ]; then
  SPARK_UI_PORT=4040
fi
if [ "$SPARK_WORKER_PORT" == "" ]; then
  SPARK_WORKER_PORT=8581
fi
if [ "$CORES" == "" ]; then
  CORES=1
fi
if [ "$MEM" == "" ]; then
  MEM=1g
fi
if [ "$SPARK_MASTER_HOSTNAME" == "" ]; then
  SPARK_MASTER_HOSTNAME=`hostname -f`
fi
if [ "$SPARK_HOSTNAME" == "" ]; then
  SPARK_HOSTNAME=`hostname -f`
fi

# Setting defaults for spark and Hive parameters -> RPC error
if [ "$SPARK_NETWORK_TIMEOUT" == "" ]; then
  SPARK_NETWORK_TIMEOUT=120
fi
if [ "$SPARK_HEARTBEAT" == "" ]; then
  SPARK_HEARTBEAT=20
fi
if [ "$SPARK_RPC_TIMEOUT" == "" ]; then
  SPARK_RPC_TIMEOUT=240
fi
if [ "$SPARK_RPC_NUM_RETRIES" == "" ]; then
  SPARK_RPC_NUM_RETRIES=5
fi
if [ "$DYNAMIC_PARTITION_VALUE" == "" ]; then
  DYNAMIC_PARTITION_VALUE=`true`
fi
if [ "$DYNAMIC_PARTITION_MODE" == "" ]; then
  DYNAMIC_PARTITION_MODE=`nonstrict`
fi
if [ "$NR_MAX_DYNAMIC_PARTITIONS" == "" ]; then
  NR_MAX_DYNAMIC_PARTITIONS=1000
fi
if [ "$MAX_DYNAMIC_PARTITIONS_PER_NODE" == "" ]; then
  MAX_DYNAMIC_PARTITIONS_PER_NODE=100
fi
if [ "$NEW_SIZE_JVM" == "" ]; then
	NEW_SIZE_JVM=1024
fi
if [ "$CLEANUP_ENABLED" == "" ]; then
        CLEANUP_ENABLED=true
fi
if [ "$CLEANUP_INTERVAL" == "" ]; then
        CLEANUP_INTERVAL=3600
fi
if [ "$CLEANUP_APPDATA" == "" ]; then
        CLEANUP_APPDATA=3600
fi
if [ "$SPARK_MASTER_URL" == "" ]; then 
	SPARK_MASTER_URL="spark://$SPARK_MASTER_HOSTNAME:$SPARK_MASTER_PORT"
	echo "Using SPARK_MASTER_URL=$SPARK_MASTER_URL"
fi
if [ "$EX_MEM" != "" ]; then
	EX_MEM=1g
fi
if [ "$EX_CORES" != "" ]; then
	EX_CORES=1
fi
if [ "$DRIVER_MEM" != "" ]; then
	DRIVER_MEM=1g
fi
if [ "$DRIVER_CORES" != "" ]; then
	DRIVER_CORES=1
fi

#Configure core-site.xml based on the configured authentication method

if [ "$AUTH_METHOD" == "basic" ]; then
	mv $SPARK_HOME/conf/core-site.xml.basic $SPARK_HOME/conf/core-site.xml
	if [ "$OBJ_STORAGE_USERNAME" != "" ]; then
		sed "s/OBJ_STORAGE_USERNAME/$OBJ_STORAGE_USERNAME" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
	if [ "$OBJ_STORAGE_PASSWORD" != "" ]; then
		sed "s/OBJ_STORAGE_PASSWORD/$OBJ_STORAGE_PASSWORD" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
fi 
if [ "$AUTH_METHOD" == "apikey" ]; then
	mv $SPARK_HOME/conf/core-site.xml.apiKey $SPARK_HOME/conf/core-site.xml
	if [ "$AUTH_APIKEY" != "" ]; then
		sed "s/AUTH_APIKEY/$AUTH_APIKEY" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
fi
if [ "$SET_PATH_TO_CONF_FOLDER" != "" ]; then
		sed "s/SET_PATH_TO_CONF_FOLDER/$SET_PATH_TO_CONF_FOLDER" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
fi

if [ "$LOCAL_DIR" != "" ]; then
	
	export NOTEBOOK_DIR=$LOCAL_DIR

	export ESCAPED_LOCAL_DIR="${LOCAL_DIR//\//\\/}"
	
	mkdir $LOCAL_DIR/$SPARK_HOSTNAME
	mkdir $LOCAL_DIR/$SPARK_HOSTNAME/logs
	mkdir $LOCAL_DIR/$SPARK_HOSTNAME/work
	mkdir $LOCAL_DIR/$SPARK_HOSTNAME/local
	
	cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
	echo "SPARK_WORKER_DIR=$LOCAL_DIR/$SPARK_HOSTNAME/work" >> $SPARK_HOME/conf/spark-env.sh
	
	sed "s/LOG_DIR/${ESCAPED_LOCAL_DIR}\/$SPARK_HOSTNAME\/logs/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
	mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

	sed "s/LOCAL_DIR/${ESCAPED_LOCAL_DIR}\/$SPARK_HOSTNAME\/local/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
	mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf
fi

sed "s/CLEANUP_ENABLED/$CLEANUP_ENABLED/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/CLEANUP_INTERVAL/$CLEANUP_INTERVAL/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/CLEANUP_APPDATA/$CLEANUP_APPDATA/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf


sed "s/HOSTNAME_MASTER/$SPARK_MASTER_HOSTNAME/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/NEW_SIZE_JVM/$NEW_SIZE_JVM/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/SPARK_UI_PORT/$SPARK_UI_PORT/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/EX_MEM/$EX_MEM/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/EX_CORES/$EX_CORES/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/DRIVER_MEM/$DRIVER_MEM/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/DRIVER_CORES/$DRIVER_CORES/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/SPARK_NETWORK_TIMEOUT/$SPARK_NETWORK_TIMEOUT/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp /$SPARK_HOME/conf/spark-defaults.conf

sed "s/SPARK_RPC_TIMEOUT/$SPARK_RPC_TIMEOUT/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/SPARK_RPC_NUM_RETRIES/$SPARK_RPC_NUM_RETRIES/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

sed "s/SPARK_HEARTBEAT/$SPARK_HEARTBEAT/" $SPARK_HOME/conf/spark-defaults.conf >> $SPARK_HOME/conf/spark-defaults.conf.tmp && \
mv $SPARK_HOME/conf/spark-defaults.conf.tmp $SPARK_HOME/conf/spark-defaults.conf

if [ "$MODE" == "" ]; then
MODE=$1
fi

if [ "$MODE" == "master" ]; then 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT 
	
elif [ "$MODE" == "worker" ]; then
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL -c $CORES -m $MEM -d $NOTEBOOK_DIR/work/

elif [ "$MODE" == "thrift" ]; then 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT 
	${SPARK_HOME}/bin/spark-submit --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 --name "Thrift JDBC/ODBC Server"  --master $SPARK_MASTER_URL
else
	nohup ${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	-c $CORES -m $MEM -d $NOTEBOOK_DIR/work/ 
fi
