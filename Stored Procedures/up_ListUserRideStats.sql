USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_ListUserRideStats
GO

CREATE PROCEDURE dbo.up_ListUserRideStats
	@UserID int
AS
/******************************************************************************
*  DBA Script: @up_ListUserRideStats
*  Created By: Jason Codianne 
*  Created:    09/02/2018
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUserRideStats 1
  
-- ============================================================================

DECLARE @Joules int

SELECT
	UP.UserID,
	PT.PointAmount,
	EntityName = ISNULL(A.ActivityName, F.FeelerTitle)
INTO #T
FROM UserPoint UP 
	INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
	INNER JOIN UserProfile U ON UP.UserID = U.UserID
	LEFT OUTER JOIN Activity A ON UP.PointEntityID = A.ActivityID
	LEFT OUTER JOIN ActivityFeeler F ON UP.PointEntityID = F.ActivityFeelerID
WHERE UP.UserID = @UserID

DELETE #T WHERE EntityName IS NULL
SELECT @Joules = SUM(PointAmount) FROM #T
DROP TABLE #T

SELECT 
	COUNT(AR.ActivityRosterID) AS RidesJoined,
	SUM(R.Distance) AS TotalDistance,
	RidesCreatedCount = (SELECT COUNT(ActivityID) AS RidesCreated FROM Activity WHERE UserID = @UserID),
	JoulePoints = @Joules -- (SELECT SUM(PointAmount) FROM UserPoint UP INNER JOIN Activity A ON UP.PointEntityID = A.ActivityID INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID WHERE UP.UserID = @UserID)
FROM ActivityRoster AR
	INNER JOIN Activity A ON AR.ActivityID = A.ActivityID
	INNER JOIN ActivityRoute R ON A.ActivityID = R.ActivityID
		AND R.IsPrimary = 1
WHERE AR.UserID = @UserID



