USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListHubScatterMetrics
GO

CREATE PROCEDURE up_ListHubScatterMetrics
	@TeamID int,
	@StartDate date,
	@EndDate date
AS
/******************************************************************************
*  Script Name:  	up_ListHubScatterMetrics
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-07-21
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListHubScatterMetrics 1, '12/01/2022', '01/28/2023'
  
-- ============================================================================
SELECT
	A.ActivityID,
	A.ActivityDate,
	CONVERT(varchar(15),CAST(A.ActivityStartTime AS TIME),100) AS ActivityStartTime,
	A.ActivityName,
	ISNULL(V.ViewCount, 0) AS ViewCount,
	ISNULL(R.RosterCount, 0) AS RosterCount,
	AR.Speed,
	AR.Distance
FROM Activity A
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(CreatedBy) AS ViewCount FROM ActivityView GROUP BY ActivityID
	) V ON A.ActivityID = V.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(CreatedBy) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID <> 4 GROUP BY ActivityID
	) R ON A.ActivityID = R.ActivityID
	INNER JOIN ActivityRoute AR ON A.ActivityID = AR.ActivityID
		AND AR.IsPrimary = 1
WHERE A.TeamID = @TeamID
	AND A.ActivityDate BETWEEN @StartDate AND @EndDate




 