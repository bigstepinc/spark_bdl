#!/bin/bash
echo 'export SPARK_HOME="/opt/spark-2.4.2-bin-hadoop2.7"'>> ~/.bashrc
echo 'export BDL_HOME=/opt/bigstepdatalake-0.11.1' >> ~/.bashrc
#echo 'export JAVA_HOME="/opt/jdk1.8.0_202/"' >> ~/.bashrc                                                                                                                               
echo 'export JAVA_HOME="/usr"' >> ~/.bashrc                                                                                                                            
#echo 'export PATH="$PATH:/opt/jdk1.8.0_202/bin:/opt/jdk1.8.0_202/jre/bin"' >> ~/.bashrc
echo 'export JAVA_CLASSPATH="/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/"' >> ~/.bashrc
echo 'export PATH="$PATH:/usr/bin:/usr/lib/jvm/java-8-openjdk-amd64/jre/bin"' >> ~/.bashrc
echo 'export PATH=$BDL_HOME/bin:$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR="$SPARK_HOME/conf"' >> ~/.bashrc
#echo 'export JAVA_CLASSPATH="$JAVA_HOME/jre/lib/"' >> ~/.bashrc
echo 'export JAVA_OPTS="-Dsun.security.krb5.debug=true -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M"' >> ~/.bashrc
echo 'export CLASSPATH=$SPARK_HOME/jars/:/opt/gcs-connector-latest-hadoop2.jar' >> ~/.bashrc
echo 'export SPARK_OPTS="--driver-java-options=-$JAVA_DRIVER_OPTS --driver-java-options=-XX:MetaspaceSize=128M --driver-java-options=-XX:MaxMetaspaceSize=256M --driver-java-options=-Dlog4j.logLevel=info --master $SPARK_MASTER_URL --files $SPARK_HOME/conf/hive-site.xml"' >> ~/.bashrc
echo 'alias python=python3.6' >> ~/.bashrc
source ~/.bashrc

echo Using SPARK_HOME=$SPARK_HOME

. "${SPARK_HOME}/sbin/spark-config.sh"
. "${SPARK_HOME}/bin/load-spark-env.sh"

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
  DYNAMIC_PARTITION_VALUE='true'
fi
if [ "$DYNAMIC_PARTITION_MODE" == "" ]; then
  DYNAMIC_PARTITION_MODE='nonstrict'
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
if [ "$AUTH_METHOD" == "apikey" ]; then
	mv $SPARK_HOME/conf/core-site.xml.apiKey $SPARK_HOME/conf/core-site.xml
	if [ "$AUTH_APIKEY" != "" ]; then
		sed "s/AUTH_APIKEY/$AUTH_APIKEY/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
	if [ "$API_ENDPOINT" != "" ]; then
		sed "s/API_ENDPOINT/${API_ENDPOINT//\//\\/}/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
	if [ "$BDL_DEFAULT_PATH" != "" ]; then
		sed "s/BDL_DEFAULT_PATH/${BDL_DEFAULT_PATH//\//\\/}/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
	cp $SPARK_HOME/conf/core-site.xml $BDL_HOME/conf/
fi

#Configure log4j2.xml and core-site.xml based on the audit configuration

if [ "$AUDIT_ENABLED" == "true" ]; then
	mv $SPARK_HOME/conf/log4j2.xml.audit $SPARK_HOME/conf/log4j2.xml
	if [ "$AUDIT_ELASTICSEARCH_URL" != "" ]; then
		sed "s/AUDIT_ELASTICSEARCH_URL/${AUDIT_ELASTICSEARCH_URL//\//\\/}/" $SPARK_HOME/conf/log4j2.xml >> $SPARK_HOME/conf/log4j2.xml.tmp && \
		mv $SPARK_HOME/conf/log4j2.xml.tmp $SPARK_HOME/conf/log4j2.xml
	fi

	sed "s/AUDIT_ELASTICSEARCH_AUTH_TOKEN/${AUDIT_ELASTICSEARCH_AUTH_TOKEN//\//\\/}/" $SPARK_HOME/conf/log4j2.xml >> $SPARK_HOME/conf/log4j2.xml.tmp && \
	mv $SPARK_HOME/conf/log4j2.xml.tmp $SPARK_HOME/conf/log4j2.xml

	sed "s/AUDIT_ENABLE/true/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml

	sed "s/AUDIT_MOCK_USERID/$AUDIT_MOCK_USERID/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
else
	sed "s/AUDIT_ENABLE/false/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
	mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml

	mv $SPARK_HOME/conf/log4j2.xml.default $SPARK_HOME/conf/log4j2.xml
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

if [ "$SPARK_WAREHOUSE_DIR" != "" ]; then
	echo "spark.sql.warehouse.dir=${SPARK_WAREHOUSE_DIR}" >> $SPARK_HOME/conf/spark-defaults.conf
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

cp $SPARK_HOME/conf/core-site.xml $BDL_HOME/conf/
rm -rf $SPARK_HOME/conf/core-site.xml.*

if [ "$DB_TYPE" == "postgresql" ]; then
	# Add metadata support
	if [ "$POSTGRES_HOSTNAME" != "" ]; then
		sed "s/POSTGRES_HOSTNAME/$POSTGRES_HOSTNAME/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	if [ "$POSTGRES_PORT" != "" ]; then
		sed "s/POSTGRES_PORT/$POSTGRES_PORT/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	#if [ "$SPARK_POSTGRES_DB" != "" ]; then
	#	sed "s/SPARK_POSTGRES_DB/$SPARK_POSTGRES_DB/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
	#	mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	#fi

	#if [ "$SPARK_POSTGRES_USER" != "" ]; then
	#	sed "s/SPARK_POSTGRES_USER/$SPARK_POSTGRES_USER/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
	#	mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	#fi
	
	if [ "$DB_NAME" != "" ]; then
		sed "s/SPARK_POSTGRES_DB/$DB_NAME/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	if [ "$DB_USER" != "" ]; then
		sed "s/SPARK_POSTGRES_USER/$DB_USER/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi


	if [ "$DYNAMIC_PARTITION_VALUE" != "" ]; then
		sed "s/DYNAMIC_PARTITION_VALUE/$DYNAMIC_PARTITION_VALUE/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	if [ "$DYNAMIC_PARTITION_MODE" != "" ]; then
		sed "s/DYNAMIC_PARTITION_MODE/$DYNAMIC_PARTITION_MODE/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	if [ "$NR_MAX_DYNAMIC_PARTITIONS" != "" ]; then
		sed "s/NR_MAX_DYNAMIC_PARTITIONS/$NR_MAX_DYNAMIC_PARTITIONS/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	if [ "$MAX_DYNAMIC_PARTITIONS_PER_NODE" != "" ]; then
		sed "s/MAX_DYNAMIC_PARTITIONS_PER_NODE/$MAX_DYNAMIC_PARTITIONS_PER_NODE/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
		mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml
	fi

	sed "s/SPARK_POSTGRES_PASSWORD/$DB_PASSWORD/" $SPARK_HOME/conf/hive-site.xml >> $SPARK_HOME/conf/hive-site.xml.tmp && \
	mv $SPARK_HOME/conf/hive-site.xml.tmp $SPARK_HOME/conf/hive-site.xml

	#export PGPASSWORD=$POSTGRES_PASSWORD 

	#psql -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT  -U $POSTGRES_USER -d $POSTGRES_DB -c "CREATE USER $SPARK_POSTGRES_USER WITH PASSWORD '$SPARK_POSTGRES_PASSWORD';"

	#psql -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT  -U $POSTGRES_USER -d $POSTGRES_DB -c "CREATE DATABASE $SPARK_POSTGRES_DB;"

	#psql -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT  -U $POSTGRES_USER -d $POSTGRES_DB -c "grant all PRIVILEGES on database $SPARK_POSTGRES_DB to $SPARK_POSTGRES_USER;" 

	cd $SPARK_HOME/jars

	export PGPASSWORD=$DB_PASSWORD

	psql -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT  -U  $DB_USER -d $DB_NAME -f $SPARK_HOME/jars/hive-schema-1.2.0.postgres.sql

fi

#Fix python not found file/directory issues
rm -rf /usr/bin/python
ln -s /usr/local/bin/python3.6 /usr/bin/python

rm -rf /opt/bigstepdatalake-0.11.1/conf/core-site.xml
cp /opt/spark-2.4.2-bin-hadoop2.7/conf/core-site.xml /opt/bigstepdatalake-0.11.1/conf/

mkdir /tmp/hive 
chmod -R 777 /tmp/hive

if [ "$MODE" == "" ]; then
MODE=$1
fi

if [ "$MODE" == "master" ]; then 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT 
	
elif [ "$MODE" == "worker" ]; then
	#${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL -c $CORES -m $MEM -d $NOTEBOOK_DIR/work/
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL -c $EX_CORES -m $EX_MEM -d $NOTEBOOK_DIR/work/

elif [ "$MODE" == "thrift" ]; then 
	nohup ${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-submit --class org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 --name "Thrift JDBC/ODBC Server"  --master $SPARK_MASTER_URL
else
	nohup ${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" -h $SPARK_MASTER_HOSTNAME --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	#${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	-c $CORES -m $MEM -d $NOTEBOOK_DIR/work/ 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	-c $EX_CORES -m $EX_MEM -d $NOTEBOOK_DIR/work/ 

fi
