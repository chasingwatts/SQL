USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListPrivateRides
GO

CREATE PROCEDURE dbo.up_ListPrivateRides
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_ListPrivateRides
*  Created By: Jason Codianne 
*  Created:    01/17/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListPrivateRides 1
  
-- ============================================================================

SELECT 
	DISTINCT TOP 3 
	A.ActivityID,
	A.ActivityName,
	A.StartLocation,
	A.Distance,
	A.ActivityDate,
	FORMAT(CONVERT(datetime, A.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	AT.ActivityTypeName,
	A.UserID AS ActivityUserID,
	U.FirstName,
	U.LastName,
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
	INNER JOIN ActivityRoster AR ON A.ActivityID = AR.ActivityID
	INNER JOIN ActivityType AT ON A.ActivityTypeID = AT.ActivityTypeID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID
		) RS ON A.ActivityID = RS.ActivityID
		LEFT OUTER JOIN (
			SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
		) AV ON A.ActivityID = AV.ActivityID
WHERE (A.[Private] = 1 
		OR A.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID)))
	AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
	AND (AR.UserID = @UserID OR A.UserID = @UserID)