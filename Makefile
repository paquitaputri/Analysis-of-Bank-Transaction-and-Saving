include .env

help:
	@echo "## docker-build			- Build Docker Images (amd64) including its inter-container network."
	@echo "## postgres			- Run a Postgres container  "
	@echo "## sqlserver			- Run a SQL Server container  "
	@echo "## spark			- Run a Spark cluster, rebuild the postgres container, then create the destination tables "
	@echo "## jupyter			- Spinup jupyter notebook for testing and validation purposes."
	@echo "## airflow			- Spinup airflow scheduler and webserver."
	@echo "## kafka			- Spinup kafka cluster (Kafka+Zookeeper)."
	@echo "## clean			- Cleanup all running containers related to the challenge."


docker-build:
	@echo '__________________________________________________________'
	@echo 'Building Docker Images ...'
	@echo '__________________________________________________________'
	@chmod 777 logs/
	@chmod 777 notebooks/
	@docker network inspect finpro-network >/dev/null 2>&1 || docker network create finpro-network
	@echo '__________________________________________________________'
	@docker build -t finpro-dibimbing/spark -f ./docker/Dockerfile.spark .
	@echo '__________________________________________________________'
	@docker build -t finpro-dibimbing/airflow -f ./docker/Dockerfile.airflow .
	@echo '__________________________________________________________'
	@docker build -t finpro-dibimbing/jupyter -f ./docker/Dockerfile.jupyter .
	@echo '==========================================================='


jupyter:
	@echo '__________________________________________________________'
	@echo 'Creating Jupyter Notebook Cluster at http://localhost:${JUPYTER_PORT} ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-jupyter.yml --env-file .env up -d
	@echo 'Created...'
	@echo 'Processing token...'
	@sleep 20
	@docker logs ${JUPYTER_CONTAINER_NAME} 2>&1 | grep '\?token\=' -m 1 | cut -d '=' -f2
	@echo '==========================================================='

spark:
	@echo '__________________________________________________________'
	@echo 'Creating Spark Cluster ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-spark.yml --env-file .env up -d
	@echo '==========================================================='

spark-submit-test:
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		spark-submit \
		--master spark://${SPARK_MASTER_HOST_NAME}:${SPARK_MASTER_PORT} \
		/spark-scripts/spark-example.py

spark-submit-airflow-test:
	@docker exec ${AIRFLOW_WEBSERVER_CONTAINER_NAME} \
		spark-submit \
		--master spark://${SPARK_MASTER_HOST_NAME}:${SPARK_MASTER_PORT} \
		--conf "spark.standalone.submit.waitAppCompletion=false" \
		--conf "spark.ui.enabled=false" \
		/spark-scripts/spark-example.py

airflow:
	@echo '__________________________________________________________'
	@echo 'Creating Airflow Instance ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-airflow.yml --env-file .env up
	@echo '==========================================================='

postgres: postgres-create

postgres-create:
	@docker compose -f ./docker/docker-compose-postgres.yml --env-file .env up -d
	@echo '__________________________________________________________'
	@echo 'Postgres container created at port ${POSTGRES_PORT}...'
	@echo '__________________________________________________________'
	@echo 'Postgres Docker Host	: ${POSTGRES_CONTAINER_NAME}' &&\
		echo 'Postgres Account	: ${POSTGRES_USER}' &&\
		echo 'Postgres password	: ${POSTGRES_PASSWORD}' &&\
		echo 'Postgres Db		: ${POSTGRES_DB}'
	@sleep 5
	@echo '==========================================================='

sqlserver: sqlserver-create 

sqlserver-create:
	@docker compose -f ./docker/docker-compose-sqlserver.yml --env-file .env up -d
	@echo '__________________________________________________________'
	@echo 'SQL Server container created at port ${SQL_SERVER_PORT}...'
	@echo '__________________________________________________________'
	@echo 'Creating database...'
	@echo '_________________________________________'
	@docker exec -it ${SQL_SERVER_CONTAINER_NAME} /opt/mssql-tools18/bin/sqlcmd -S ${SQL_SERVER_CONTAINER_NAME} -U ${SQL_SERVER_USER} -P ${SQL_SERVER_PASSWORD} -C -i sql/sqlserver-create.sql
	@echo 'Creating database ${SQL_SERVER_DB} is successed'
	@sleep 5
	@echo '==========================================================='

# sqlserver-create-database:
# 	@echo '__________________________________________________________'
# 	@echo 'Creating tables...'
# 	@echo '_________________________________________'
# 	@docker exec -it ${SQL_SERVER_CONTAINER_NAME} psql -U sa -C -f sql/ddl-retail.sql
# 	@echo '==========================================================='

kafka: kafka-create

kafka-create:
	@echo '__________________________________________________________'
	@echo 'Creating Kafka Cluster ...'
	@echo '__________________________________________________________'
	@docker compose -f ./docker/docker-compose-kafka.yml --env-file .env up -d
	@echo 'Waiting for uptime on http://localhost:8083 ...'
	@sleep 20
	@echo '==========================================================='

kafka-create-test-topic:
	@docker exec ${KAFKA_CONTAINER_NAME} \
		kafka-topics.sh --create \
		--partitions 3 \
		--replication-factor ${KAFKA_REPLICATION} \
		--bootstrap-server localhost:9092 \
		--topic ${KAFKA_TOPIC_NAME}

kafka-create-topic:
	@docker exec ${KAFKA_CONTAINER_NAME} \
		kafka-topics.sh --create \
		--partitions ${partition} \
		--replication-factor ${KAFKA_REPLICATION} \
		--bootstrap-server localhost:9092 \
		--topic ${topic}

spark-produce:
	@echo '__________________________________________________________'
	@echo 'Producing fake events ...'
	@echo '__________________________________________________________'
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		python \
		/scripts/event_producer.py

spark-consume:
	@echo '__________________________________________________________'
	@echo 'Consuming fake events ...'
	@echo '__________________________________________________________'
	@docker exec ${SPARK_WORKER_CONTAINER_NAME}-1 \
		spark-submit \
		/spark-scripts/spark-event-consumer.py


clean:
	@bash ./scripts/goodnight.sh


postgres-bash:
	@docker exec -it dataeng-postgres bash