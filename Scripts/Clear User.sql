USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_DeleteUser
GO

CREATE PROCEDURE up_DeleteUser
	@UserID int
AS


/******************************************************************************
*  Script Name:  	
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-03-11
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example

-- DECLARE @UserID int
-- SET @UserID = 24685
  
-- ============================================================================

DELETE ActivityRoster WHERE UserID = @UserID 
DELETE ActivityDisuccsionThreads WHERE UserID = @UserID
DELETE UserConnection WHERE UserID = @UserID
DELETE UserConnection WHERE ConnectionUserID = @UserID
DELETE UserNotification WHERE UserID = @UserID
DELETE UserPoint WHERE UserID = @UserID
DELETE UserProfile WHERE UserID = @UserID
DELETE AspNetUsers WHERE Id = @UserID


SELECT * FROM aspnetusers where email like '%fsmbeeeman@gmail.com%'
SELECT * FROM UserProfile WHERE UserID =  @UserID
--DELETE UserProfile WHERE UserID = 70
  