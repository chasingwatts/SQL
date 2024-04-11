USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_DeleteActivity
GO

CREATE PROCEDURE dbo.up_DeleteActivity
	@ActivityID int,
	@All bit
AS
/******************************************************************************
*  DBA Script: up_DeleteActivity
*  Created By: Jason Codianne 
*  Created:    02/14/2018 
*  Schema:     dbo
*  Purpose:    Delete activity and foreign data
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_DeleteActivity 36919, 0
  
-- ============================================================================
SET NOCOUNT ON
--SET @ActivityID = 29

DECLARE @ParentID int

IF (@All = 1)
BEGIN
	SELECT DISTINCT @ParentID = ISNULL(RecurringParentActivityID, ActivityID) FROM Activity WHERE ActivityID = @ActivityID OR RecurringParentActivityID = @ActivityID

	DELETE ActivityDisuccsionThreads WHERE ActivityID IN (SELECT DISTINCT ActivityID FROM Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID)
	DELETE ActivityRoster WHERE ActivityID IN (SELECT DISTINCT ActivityID FROM Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID)
	DELETE ActivityRating WHERE ActivityID IN (SELECT DISTINCT ActivityID FROM Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID)
	DELETE ActivityRoute WHERE ActivityID IN (SELECT DISTINCT ActivityID FROM Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID)
	DELETE ActivityPicture WHERE ActivityID IN (SELECT DISTINCT ActivityID FROM Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID)
	DELETE Activity WHERE ActivityID = @ParentID OR RecurringParentActivityID = @ParentID
END
ELSE
BEGIN
	DELETE ActivityDisuccsionThreads WHERE ActivityID = @ActivityID
	DELETE ActivityRoster WHERE ActivityID = @ActivityID
	DELETE ActivityRating WHERE ActivityID = @ActivityID
	DELETE ActivityRoute WHERE ActivityID = @ActivityID
	DELETE ActivityPicture WHERE ActivityID = @ActivityID
	DELETE Activity WHERE ActivityID = @ActivityID
END
