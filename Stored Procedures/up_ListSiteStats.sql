USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListSiteStats
GO

CREATE PROC dbo.up_ListSiteStats
AS
/******************************************************************************
*  DBA Script: up_ListSiteStats
*  Created By: Jason Codianne 
*  Created:    08/06/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListSiteStats
  
-- ============================================================================


SELECT
	COUNT(A.ActivityID) AS ActivityCount,
	SUM(A.Distance) AS TotalDistance,
	UserCount = (SELECT COUNT(Id) FROM AspNetUsers),
	RosterCount = (SELECT COUNT(ActivityID) FROM ActivityRoster),
	ViewCount = (SELECT COUNT(ActivityID) FROM ActivityView) 
FROM Activity A
WHERE YEAR(A.ActivityDate) = 2018

