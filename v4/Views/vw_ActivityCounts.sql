USE [Mortis]
GO

DROP VIEW IF EXISTS vw_ActivityCounts
GO

--SELECT * FROM vw_ActivityCounts

CREATE VIEW vw_ActivityCounts
AS

SELECT 
	A.ActivityID,
	ISNULL(V.ViewCount, 0) AS ViewCount,
	ISNULL(L.LikeCount, 0) AS LikeCount,
	ISNULL(C.ChatCount, 0) AS ChatCount,
	ISNULL(R.RosterCount, 0) AS RosterCount
FROM Activity A
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityViewID) AS ViewCount FROM ActivityView GROUP BY ActivityID) V ON A.ActivityID = V.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityLikeID) AS LikeCount FROM ActivityLike GROUP BY ActivityID) L ON A.ActivityID = L.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityChatID) AS ChatCount FROM ActivityChat GROUP BY ActivityID) C ON A.ActivityID = C.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityRosterID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID <> 3 GROUP BY ActivityID) R ON A.ActivityID = R.ActivityID