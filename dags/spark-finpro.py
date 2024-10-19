from datetime import timedelta
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.utils.dates import days_ago

default_args = {
    "owner": "paquita",
    "retry_delay": timedelta(minutes=5),
}

spark_dag = DAG(
    dag_id="spark_etl_finpro",
    default_args=default_args,
    schedule_interval=None,
    dagrun_timeout=timedelta(minutes=60),
    description="Insert data from csv to SQL Server",
    start_date=days_ago(1),
)

ETL = SparkSubmitOperator(
    application="/spark-scripts/spark-etl.py",
    conn_id="sqlserver_finpro",
    task_id="spark_etl_task",
    dag=spark_dag,
)

ETL