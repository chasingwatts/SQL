USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListYesterdayRides
GO

CREATE PROCEDURE dbo.up_ListYesterdayRides
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
-- EXEC dbo.up_ListYesterdayRides
  
-- ============================================================================


SELECT
	ActivityID,
	ActivityName,
	ActivityDate,
	ActivityStartTime,
	StartLocation
FROM Activity 
WHERE ActivityDate = CONVERT(date, DATEADD(D, -1, GETDATE()))

 