USE [Mortis]
GO

DROP VIEW IF EXISTS vw_CheckUserInRoster
GO

CREATE VIEW vw_CheckUserInRoster
AS

SELECT
	R.ActivityID,
	R.GroupLevel,
	R.ResponseTypeID,
	T.ResponseTypeName,
	T.ResponseColor,
	R.CreatedBy AS UserID
FROM ActivityRoster R 
	LEFT OUTER JOIN ResponseType T ON R.ResponseTypeID = T.ResponseTypeID
--select * from vw_CheckUserInRoster WHERE ActivityID = 10


