USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_JobPreRideReminder
GO

CREATE PROCEDURE dbo.up_JobPreRideReminder
AS
/******************************************************************************
*  Script Name:		up_JobPreRideReminder
*  Created By:  	Jason Codianne 
*  Created Date:  	2019-07-19
*  Schema: 			dbo
*  Purpose:			list rides for pre-ride reminder (mobile push)
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_JobPreRideReminder
  
-- ============================================================================


SELECT
	ActivityID,
	ActivityName,
	ActivityDate,
	ActivityStartTime,
	CAST(ActivityDate AS DateTime) + CAST(ActivityStartTime AS DateTime) AS ActivityDateStart,
	StartLocation,
	Distance
FROM Activity 
WHERE (CAST(ActivityDate AS DateTime) + CAST(DATEADD(MINUTE, -60, ActivityStartTime) AS DateTime) <= DATEADD(MINUTE, 60, GETDATE())
    AND CAST(ActivityDate AS DateTime) + CAST(DATEADD(MINUTE, -60, ActivityStartTime) AS DateTime) > GETDATE())
	AND StartState = 'TX'