USE [Mortis];
GO

DROP PROCEDURE IF EXISTS up_NotificationFriendEmailDevice;
GO

CREATE PROCEDURE up_NotificationFriendEmailDevice
	@UserID INT,
	@Type INT -- 1: device, 2: email
AS

/******************************************************************************
*  Script Name:  	up_NotificationFriendEmailDevice
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-04-12
*  Schema:  		dbo
*  Purpose:			Get user device or email for notifications
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_NotificationFriendEmailDevice 1, 1
  
-- ============================================================================

SELECT
	U.UserID,
	U.FirstName,
	U.LastName,
	CASE @Type WHEN 1 THEN D.DeviceID WHEN 2 THEN AA.Email END AS EmailDevice,
	CASE @Type WHEN 1 THEN 'Device' WHEN 2 THEN 'Email' END AS EmailDeviceType
FROM UserProfile U
	LEFT JOIN UserDevice D ON U.UserID = D.UserID AND @Type = 1
	LEFT JOIN Accounts AA ON U.UserID = AA.Id AND @Type = 2
	INNER JOIN UserNotification N ON U.UserID = N.UserID
WHERE U.UserID = @UserID
	AND U.IsDeleted = 0
	AND (@Type = 1 AND D.DeviceID IS NOT NULL OR @Type = 2 AND AA.Email IS NOT NULL)
	AND (N.NewRideApp = 1 
			AND N.NewRideEmail = 1 
			AND N.NewRideApp = 1
			AND N.ActivityUpdateApp = 1 
			AND N.ActivityUpdateEmail = 1
			AND N.ActivityRosterApp = 1
			AND N.ActivityRosterEmail = 1
			AND N.ActivityDiscussionApp = 1
			AND N.ActivityDiscussionEmail = 1);