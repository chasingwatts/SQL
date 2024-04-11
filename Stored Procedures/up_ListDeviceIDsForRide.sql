USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListDeviceIDsForRide
GO

CREATE PROCEDURE up_ListDeviceIDsForRide
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListDeviceIDsForRide
*  Created By: Jason Codianne 
*  Created:    9/28/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListDeviceIDsForRide 16688
  
-- ============================================================================
SET NOCOUNT ON

SELECT DISTINCT 
	--R.ActivityRosterID,
	--D.UserDeviceID AS ActivityRosterID,
	R.ActivityID,
	R.UserID,
	R.ResponseTypeID,
	RT.ResponseTypeName,
	R.ResponseComments,
	P.FirstName,
	P.LastName,
	P.FirstName + ' ' + P.LastName AS FullName,
	A.ActivityName,
	D.DeviceID
FROM ActivityRoster R
	INNER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	INNER JOIN Activity A ON R.ActivityID = A.ActivityID
	INNER JOIN UserNotification N ON R.UserID = N.UserID
	LEFT OUTER JOIN UserDevice D ON R.UserID = D.UserID
	INNER JOIN UserProfile P ON R.UserID = P.UserID
WHERE R.ActivityID = @ActivityID
	AND N.ActivityRosterApp = 1 
	AND D.UserDeviceID IS NOT NULL
	AND R.ResponseTypeID NOT IN (4, 5) --no's & invited