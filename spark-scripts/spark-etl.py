import pyspark
import os
import json
import argparse

from dotenv import load_dotenv
from pathlib import Path
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import StructType, IntegerType, FloatType


dotenv_path = Path('/resources/.env')
load_dotenv(dotenv_path=dotenv_path)


postgres_host = os.getenv('POSTGRES_CONTAINER_NAME')
postgres_dw_db = os.getenv('POSTGRES_DW_DB')
postgres_user = os.getenv('POSTGRES_USER')
postgres_password = os.getenv('POSTGRES_PASSWORD')
