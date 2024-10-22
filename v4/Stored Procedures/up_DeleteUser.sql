USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_DeleteUser
GO

CREATE PROCEDURE up_DeleteUser
	@UserID int
AS
BEGIN
/******************************************************************************
*  Script Name:  	up_DeleteUser
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-09-30
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_DeleteUser 88
-- SELECT * FROM accounts WHERE email = 'jason@radicallogic.com'
-- DECLARE @UserID int
-- SET @UserID = 88
-- ============================================================================

BEGIN TRANSACTION

BEGIN TRY

	DELETE ActivityChat WHERE UserID = @UserID
	DELETE ActivityInvite WHERE UserID = @UserID
	DELETE ActivityLike WHERE CreatedBy = @UserID
	DELETE ActivityRating WHERE UserID = @UserID
	DELETE ActivityRoster WHERE CreatedBy = @UserID
	DELETE ActivityView WHERE CreatedBy = @UserID
	DELETE BadgeUser WHERE UserID = @UserID
	DELETE StravaUserToken WHERE UserID = @UserID
	DELETE RWGPSUserToken WHERE UserID = @UserID
	DELETE GarminUserToken WHERE UserID = @UserID
	DELETE HubMember WHERE UserID = @UserID
	DELETE Notifications WHERE UserID = @UserID OR CreatedBy = @UserID
	DELETE RefreshToken WHERE AccountId = @UserID
	DELETE UserDevice WHERE UserID = @UserID
	DELETE UserFollowing WHERE UserID = @UserID OR FollowingID = @UserID
	DELETE UserNotification WHERE UserID = @UserID
	DELETE UserPoint WHERE UserID = @UserID
	UPDATE Activity SET UserID = 34 WHERE UserID = @UserID --set to CW account
	DELETE UserProfile WHERE UserID = @UserID
	DELETE Accounts WHERE Id = @UserID

	COMMIT TRANSACTION;

    SELECT 'Success' AS Result;

END TRY
    BEGIN CATCH
        -- If there is an error, roll back the transaction
        ROLLBACK TRANSACTION;

        -- Return error message or status
        SELECT ERROR_MESSAGE() AS ErrorMessage;

        -- Optionally, you can rethrow the error to be handled by the calling application
        -- THROW;
    END CATCH

END;