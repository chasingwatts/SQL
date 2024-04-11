USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListTeamUpcomingRides
GO

CREATE PROCEDURE dbo.up_ListTeamUpcomingRides
	@TeamID int
AS
/******************************************************************************
*  DBA Script: up_ListTeamUpcomingRides
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListTeamUpcomingRides 2
  
-- ============================================================================

SELECT 
	DISTINCT
	A.TeamID,
	T.TeamName,
	A.ActivityID,
	A.ActivityName,
	A.StartLocation,
	R.Distance,
	A.ActivityDate,
	FORMAT(CONVERT(datetime, A.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	AT.ActivityTypeName,
	A.UserID AS ActivityUserID,
	U.FirstName,
	U.LastName,
	--AR.ResponseTypeID,
	A.[Private],
	ISNULL(A.Cancelled, 0) AS Cancelled,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ViewStatus = 
		CASE
			WHEN A.[Private] = 1 AND A.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN A.[Private] = 1 AND A.TeamID IS NULL THEN 'Private Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		END
FROM Activity A
	--INNER JOIN ActivityRoster AR ON A.ActivityID = AR.ActivityID
	INNER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	INNER JOIN Team T ON A.TeamID = T.TeamID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID
	) RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) AV ON A.ActivityID = AV.ActivityID
WHERE CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND A.TeamID = @TeamID
ORDER BY 5