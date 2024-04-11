USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_UpdateActivityRecurrence
GO

CREATE PROCEDURE dbo.up_UpdateActivityRecurrence
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_UpdateActivityRecurrence
*  Created By: Jason Codianne 
*  Created:    03/22/2018 
*  Schema:     dbo
*  Purpose:    Get A ID's for those in a recurring series (upcoming only)
******************************************************************************/	
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_UpdateActivityRecurrence 1737
  
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
	SELECT ActivityID FROM Activity WHERE ActivityID = @ActivityID OR RecurringParentActivityID = @ActivityID
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
END
ELSE
BEGIN
	SELECT ActivityID FROM Activity 
	WHERE (RecurringParentActivityID = @ParentActivityID OR RecurringParentActivityID = @ParentActivityID) OR ActivityID = @ParentActivityID
		AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
END