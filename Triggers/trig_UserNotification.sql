USE [trovafit_aspnet]
GO

CREATE TRIGGER dbo.trig_UserNotification
	ON UserProfile
	FOR INSERT
AS
/******************************************************************************
*  DBA Script: trig_UserNotification
*  Created By: Jason Codianne 
*  Created:    10/16/2018 
*  Schema:     dbo
*  Purpose:    add notifciation defaults for new user
******************************************************************************/
-- ============================================================================
-- Testing Parms

  
-- ============================================================================

BEGIN
	INSERT INTO UserNotification
	SELECT 
		I.UserID,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		GETDATE()
	FROM inserted I
END