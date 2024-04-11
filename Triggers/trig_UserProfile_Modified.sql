USE [trovafit_aspnet]
GO

DROP TRIGGER [dbo].[trig_UserProfile_Modified]
GO

CREATE TRIGGER [dbo].[trig_UserProfile_Modified]
   ON [dbo].[UserProfile]
   AFTER INSERT
AS 
/******************************************************************************
*  DBA Script: [trig_UserProfile_Modified]
*  Created By: Jason Codianne 
*  Created:    11/20/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms

  
-- ============================================================================

BEGIN
    DECLARE @UserID int
	SELECT @UserID = UserID FROM inserted

	UPDATE UserProfile SET ModifiedBy = @UserID, ModifiedDate = GETDATE() WHERE ModifiedBy IS NULL AND CreatedBy = @UserID
END

