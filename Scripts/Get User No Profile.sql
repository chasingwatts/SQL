USE [trovafit_aspnet]
GO

SELECT
	Email,
	Id AS UserID
FROM AspNetUsers WHERE Id NOT IN (SELECT UserID FROM UserProfile)  


--SELECT * FROM UserProfile WHERE UserID = 1517 