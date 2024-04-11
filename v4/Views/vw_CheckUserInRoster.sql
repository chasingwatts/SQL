USE [Mortis]
GO

DROP VIEW IF EXISTS vw_CheckUserInRoster
GO

CREATE VIEW vw_CheckUserInRoster
AS

SELECT
	G.ActivityID,
	G.GroupName,
	R.ResponseTypeID,
	T.ResponseTypeName,
	T.ResponseColor,
	R.CreatedBy AS UserID
FROM ActivityRosterGroup G
	LEFT OUTER JOIN ActivityRoster R ON G.ActivityRosterGroupID = R.ActivityRosterGroupID
	LEFT OUTER JOIN ResponseType T ON R.ResponseTypeID = T.ResponseTypeID
--select * from vw_CheckUserInRoster WHERE ActivityID = 10


