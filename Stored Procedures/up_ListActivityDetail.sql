USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListActivityDetail
GO

CREATE PROCEDURE dbo.up_ListActivityDetail
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListActivityDetail
*  Created By: Jason Codianne 
*  Created:    08/13/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListActivityDetail 30869

-- DECLARE @ActivityID int
-- SET @ActivityID = 20801  
-- ============================================================================

SET NOCOUNT ON

SELECT
	A.ActivityID,
	A.RecurringParentActivityID,
	A.ActivityName,
	A.ActivityDate,
	A.ActivityStartTime,	
	A.ActivityEndTime,
	A.StartLocation,
	A.StartName,
	A.StartAddress,
	A.StartCity,
	A.StartState,
	A.StartCountry,
	A.StartLat,
	A.StartLng,
	A.StartW3W,
	A.EndLocation,
	A.EndName,
	A.EndAddress,
	A.EndCity,
	A.EndState,
	A.EndCountry,
	A.EndLat,
	A.EndLng,
	RT.Speed,
	RT.Distance,
	A.ActivityNotes,
	A.BikeRegName,
	A.BikeRegID,
	A.[Private],
	RT.MapSourceID,
	RT.MapURL,
	RT.MapRouteNumber,
	A.MapNotes,
	A.ActivityTypeID,
	T.ActivityTypeName,
	A.RouteTypeID,
	R.RouteTypeName,
	U.FirstName,
	U.LastName,
	U.RWGPSAuthKey,
	U.RWGPSUserID,
	U.StravaAuthKey,
	U.StravaUserID,
	A.UserID,
	ISNULL(RS.RosterCount, 0) AS RosterCount,
	ISNULL(AV.ActivityView, 0) AS ActivityView,
	ISNULL(A.Cancelled, 0) AS Cancelled,
	ISNULL(AR.AverageRating, 0) AS AverageRating,
	ISNULL(AR.RatingCount, 0) AS RatingCount,
	TM.TeamID,
	TM.TeamName,
	ViewStatus = 
		CASE
			WHEN A.[Private] = 1 AND A.TeamID IS NOT NULL THEN 'Private Team Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NOT NULL THEN 'Public Team Ride'
			WHEN A.[Private] = 1 AND A.TeamID IS NULL THEN 'Private Ride'
			WHEN A.[Private] = 0 AND A.TeamID IS NULL THEN 'Public Ride'
		END,
	A.IsPromoted,
	A.HasWaiver,
	A.HasGroups,
	A.IsMultiRoute,
	A.RelatedActivityID,
	A.IsCommunity,
	A.CreatedBy,
	A.CreatedDate,
	A.ModifiedBy,
	A.ModifiedDate
FROM Activity A 
	INNER JOIN ActivityRoute RT ON A.ActivityID = RT.ActivityID
		AND RT.IsPrimary = 1
	INNER JOIN ActivityType T ON A.ActivityTypeID = T.ActivityTypeID
	INNER JOIN RouteType R ON A.RouteTypeID = R.RouteTypeID
	INNER JOIN UserProfile U ON A.UserID = U.UserID
	LEFT OUTER JOIN Team TM ON A.TeamID = TM.TeamID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID) RS ON A.ActivityID = RS.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID) AV ON A.ActivityID = AV.ActivityID
	LEFT OUTER JOIN (SELECT ActivityID, AVG(UserRating) AS AverageRating, COUNT(ActivityID) AS RatingCount FROM ActivityRating GROUP BY ActivityID) AR ON A.ActivityID = AR.ActivityID
WHERE A.ActivityID = @ActivityID
