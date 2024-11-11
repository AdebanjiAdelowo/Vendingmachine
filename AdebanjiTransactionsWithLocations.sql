--Transactions with Locations for a specific time period (StartDate and EndDate)

/* 
-- Schema level Type / Persistent Type
Create a collection type that can hold the user IDs (a list of strings (VARCHAR2))
CREATE OR REPLACE TYPE user_id_table AS TABLE OF VARCHAR2(50);
*/

DECLARE
    TYPE USER_ID_TABLE IS
        TABLE OF VARCHAR2(50);
    USERS USER_ID_TABLE := :USER_IDS; -- user_ids coming from external source (in my case Abdul to pandas series)
BEGIN
    SELECT -- Use /*+ ORDERED */ to tell Oracle to follow the join order written in the query, which will process the INNER JOIN first.
        T.TRN_EXTERNAL_TRANSACTIONID AS "Transaction ID",
        T.TRN_TIPOOPERAZIONE AS "Type of Transaction",
        T.TRN_VALORE AS "Value of Transaction",
        T.TRN_DATAORA AS "Date and time of transaction",
        T.TRN_DBVEGA AS "DB Vega",
        T.TRN_CURRENCY AS "Currency",
        T.TRN_MODALITAPAGAMENTO AS "Mode of Payment",
        T.TRN_ORIGINE_TRANSAZIONE AS "Payment system",
        T.TRN_EXTERNAL_TRANSACTIONID AS "Transaction Id",
        T.TRN_CAPPUSERID AS "Coffeecapp User Id",
        T.TRN_STICKER AS "Sticker Id",
        T.TRN_ESITOTRANSAZIONE AS "Result of Transaction",
        T.TRN_DESCRIPTION AS "Possible Description",
        T.TRN_CAUSALE AS "Casual Code",
        T.TRN_PROD AS "TRN Product Code",
        T.TRN_WALLET_BALANCE_DECLARED AS "Wallet Balance after Trans",
        T.TRN_PRO_VENDPAY AS "VenPay Product Code",
        T.TRN_DATAADDEBITO AS "Actual debit date",
        P.PRO_DESCITA AS "Product Description",
        P.PRO_CAT AS "Product Category",
        P.PRO_UM AS "Measurement Unit",
        P.PRO_GRP AS "Product Type",
        P.PRO_MARCA AS "Product Brand",
        D.DBV_DESC AS "DB Vega Desc",
        S.*
 -- Location Data
    FROM
        (
            SELECT
                COLUMN_VALUE AS USER_ID
            FROM
                TABLE(USERS)
        ) U -- column_value is the pseudocolumn representing each of user_id
        INNER JOIN VEGACRMPROD.TRANSAZIONI T
        ON T.TRN_CAPPUSERID = U.USER_ID
        LEFT JOIN VEGACRMPROD.SEDIOPERATIVE S
        ON S.SEDE_ID = T.TRN_SEDEOPERATIVA
        LEFT JOIN VEGACRMPROD.PRODOTTI P
        ON T.TRN_PROD = P.PRO_COD
        AND T.TRN_DBVEGA = P.PRO_DBVEGA
        LEFT JOIN VEGACRMPROD.DBVEGA D
        ON T.TRN_DBVEGA = D.DBV_ID
    WHERE
        T.TRN_ESITOTRANSAZIONE = 4 -- Confirmed Transactions
        AND T.TRN_DATAORA BETWEEN STARTDATE AND ENDDATE END;
 /*

TABLE() is a function that allows you to treat a collection 
(like a nested table, varray, or PL/SQL associative array) as if it were a table. 
This is useful when you want to query or join a collection of values in the same way 
you would query a database table.

What TABLE() Does:
Purpose: The TABLE() function converts a collection (e.g., a PL/SQL array, nested table, or varray) 
into a virtual table that can be queried using SQL.
Use Case: It allows you to "unwrap" the elements of a collection and treat them as rows in a result set, 
which you can then use in JOIN or SELECT operations.

Other Considerations:
Bind Variables: Depending on your environment, you may want to use bind variables for 
users rather than hardcoding the tuple into the query to avoid exceeding query size limits.

Partitioning: If performance issues persist, consider breaking up users into smaller batches 
and running multiple queries, then aggregating the results.
*/