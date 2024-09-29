# Analysis of Bank Transaction and Saving

## Project Overview
This project focuses on Bank Transaction and Savings analysis, where this analysis is used to monitor transactions in the bank. The data set consists of a Transaction fact table, along with dimension tables including Location, Customer, Hour, and Calendar. The analysis involves data cleaning, transformation, and visualization.

## Goals of This Project
1. Average Transaction Amount by Location
2. Analyzing the age groups with the highest number of transactions, along with their location (Trend Analysis of Transaction Volume and Amount)
3. Perform Location-wise analysis to identify regional trends
4. Perform transaction-related analysis to identify interesting trends that can be used by a bank to improve / optimi their user experiences

## Datasets
1. [Kaggle](https://www.kaggle.com/datasets/shivamb/bank-customer-segmentation)
  - Size: 25 MB
  - Columns: TransactionID, CustomerID, CustomerDOB, CustGender, CustLocation, CustAccountBalance, TransactionDate, TransactionTime, TransactionAmount
2. Fake Stream for Today's Transaction Data
3. For Saving Data makes dummy but CustomerID based on the Kaggle data.

## Tools and Technologies
- Docker: For container management
- Python: Main programming language
- Apache Airflow: For managing the batch processing pipeline
- Kafka : For streaming data processing
- SQL Server : For Data Storage
- Power BI : For visualizing the analysis results
