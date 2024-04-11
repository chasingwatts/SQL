--SELECT * FROM AspNetUsers WHERE EmailConfirmed = 0 AND PasswordHash IS NOT NULL 

--BEGIN TRAN
--UPDATE AspNetUsers SET EmailConfirmed = 1 WHERE EmailConfirmed = 0 AND PasswordHash IS NOT NULL
--COMMIT

SELECT * FROM AspNetUsers ORDER BY 1 DESC 