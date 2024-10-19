
USE master;
GO

IF DB_ID (N'dwh_finpro') IS NOT NULL
DROP DATABASE dwh_finpro;
GO

CREATE DATABASE dwh_finpro;
GO

-- USE [dwh_finpro];
-- G0

-- check to see if table exists in sys.tables - ignore DROP TABLE if it does not
-- IF EXISTS(SELECT * FROM sys.tables WHERE SCHEMA_NAME(schema_id) LIKE 'dbo' AND name like '%dwh_finpro%')  
--    DROP TABLE [dbo].[dwh_finpro];  
-- GO

-- CREATE TABLE dwh_finpro (
--     TransactionID varchar(50) NOT NULL,
--     CustomerID varchar(50) NOT NULL,
--     CustomerDOB varchar(20) NULL,
--     CustGender varchar(10) NULL,
--     CustLocation varchar(250) NULL,
--     CustAccountBalance float, -- times 185,04
--     TransactionDate varchar(20) NULL,
--     TransactionTime varchar(25) NULL,
--     TransactionAmoun float -- times 185,04 to idr
-- );
-- GO