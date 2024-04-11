USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListActivityRecurrence
GO

CREATE PROCEDURE dbo.up_ListActivityRecurrence
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListActivityRecurrence
*  Created By: Jason Codianne 
*  Created:    03/22/2018 
*  Schema:     dbo
*  Purpose:    Get A ID's for those in a recurring series (upcoming only)
******************************************************************************/	
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListActivityRecurrence 2420
  
-- ============================================================================
SET NOCOUNT ON

DECLARE @ParentActivityID int

--DECLARE @ActivityID int
--SET @ActivityID = 1134

SELECT @ParentActivityID = RecurringParentActivityID FROM Activity WHERE ActivityID = @ActivityID

--SELECT * FROM Activity WHERE ActivityID = @ActivityID
--SELECT @ParentActivityID

IF @ParentActivityID IS NULL
BEGIN
	SELECT TOP 4
		ActivityID, 
		ActivityDate, 
		CONVERT(varchar(15),CAST(ActivityStartTime AS TIME),100) AS ActivityStartTime
	FROM Activity 
	WHERE (RecurringParentActivityID = @ActivityID OR ActivityID = @ActivityID) AND ActivityID <> @ActivityID
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
END
ELSE
BEGIN
	SELECT TOP 4
		ActivityID, 
		ActivityDate, 
		CONVERT(varchar(15),CAST(ActivityStartTime AS TIME),100) AS ActivityStartTime
	FROM Activity 
	WHERE (RecurringParentActivityID = @ParentActivityID OR ActivityID = @ParentActivityID) AND ActivityID <> @ActivityID
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
END