import pyspark
import os
import json
import argparse

from dotenv import load_dotenv
from pathlib import Path
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import *
from pyspark.sql import SparkSession

spark_session = SparkSession.builder\
  .appName('dibimbing_finpro')\
  .master('local')\
  .config("spark.jars", "/resources/connector/sqljdbc_12.8/jars/mssql-jdbc-12.8.1.jre8.jar") \
  .getOrCreate()

dotenv_path = Path('/resources/.env')
load_dotenv(dotenv_path=dotenv_path)

sqlserver_host = os.getenv('SQL_SERVER_CONTAINER_NAME')
sqlserver_dw_db = os.getenv('SQL_SERVER_DB')
sqlserver_user = os.getenv('SQL_SERVER_USER')
sqlserver_password = os.getenv('SQL_SERVER_PASSWORD')

driver = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
jdbc_url = "jdbc:sqlserver://{};databaseName={};user={};password={};encrypt=true;trustServerCertificate=true;".format(sqlserver_host, sqlserver_dw_db, sqlserver_user, sqlserver_password)

schema_date = StructType([
    StructField('TransactionID', StringType()),
    StructField('CustomerID', StringType()),
    StructField('CustomerDOB', StringType()),
    StructField('CustGender', StringType()),
    StructField('CustLocation', StringType()),
    StructField('CustAccountBalance', FloatType()),
    StructField('TransactionDate', StringType()),
    StructField('TransactionTime', StringType()),
    StructField('TransactionAmoun', FloatType())
])

df_data = spark_session.read.csv('/resources/data/bank_transactions.csv', header=True, schema=schema_date)


# Data Transformation

# 1. Change '/' to '-' in column CustomerDOB and TransactionDate

df_data = df_data.withColumn("CustomerDOB", F.expr("replace(CustomerDOB, '/', '-')"))
df_data = df_data.withColumn("TransactionDate", F.expr("replace(TransactionDate, '/', '-')"))

#2 Change format date from "dd-MM-yy" to "dd-MM-yyyy"

# - get the Year from the date

df_data = df_data.withColumn("y_DOB", F.expr("substring(CustomerDOB, length(CustomerDOB)-1, 2)").cast('int'))
df_data = df_data.withColumn("y_transac", F.expr("substring(TransactionDate, length(TransactionDate)-1, 2)").cast('int'))

# use logic to change from "yy" to "yyyy"

df_data = df_data.withColumn("f_CustomerDOB", 
                             F.when(F.col("y_DOB") <=  30, F.col('y_DOB') + 2000)
                             .otherwise(F.col('y_DOB') + 1900))

df_data = df_data.withColumn("f_TransactionDate", 
                             F.when(F.col("y_transac") <=  30, F.col('y_transac') + 2000)
                             .otherwise(F.col('y_transac') + 1900))

# - concat month and day to new format year

df_data = df_data.withColumn("f_CustomerDOB", F.concat(F.expr("substring(CustomerDOB, 1, length(CustomerDOB)-2)"), df_data.f_CustomerDOB))

df_data = df_data.withColumn("f_TransactionDate", F.concat(F.expr("substring(TransactionDate, 1, length(TransactionDate)-2)"), df_data.f_TransactionDate))

# 3 change format time

df_data = df_data.withColumn("TransactionTime", 
                             F.expr("concat(substring(TransactionTime, 1, 2), ':', substring(TransactionTime, 3, 2), ':', substring(TransactionTime, 5, 2))"))

# 4. Drop unused columns

df_data = df_data.drop("CustomerDOB","TransactionDate", "y_DOB","y_transac")

df_data.show(5)

# Write
# df_data.write \
#         .format("jdbc") \
#         .option("driver", driver) \
#         .option("url", jdbc_url) \
#         .option("dbtable", "Final_Data") \
#         .mode("overwrite") \
#         .save()

# Stop the Spark session
spark_session.stop()





