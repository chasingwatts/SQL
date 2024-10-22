USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListYesterdayRides
GO

CREATE PROCEDURE up_ListYesterdayRides
AS
/******************************************************************************
*  DBA Script: up_ListYesterdayRides
*  Created By: Jason Codianne 
*  Created:    10/29/2018
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListYesterdayRides
  
-- ============================================================================


SELECT
	ActivityID,
	ActivityName,
	ActivityDate,
	ActivityStartTime,
	StartAddress
FROM Activity 
WHERE ActivityDate = CONVERT(date, DATEADD(D, -1, GETDATE()))
	AND (IsCancelled IS NULL OR isCancelled = 0)
	AND IsDeleted = 0

 
GO


