USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_NotificationRosterEmailDevice
GO

CREATE PROCEDURE up_NotificationRosterEmailDevice
	@ActivityID int,
	@Type int, -- 1: device, 2: email
	@IncludeOwner int
AS

/******************************************************************************
*  Script Name:  	up_NotificationRosterEmailDevice
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-04-12
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_NotificationRosterEmailDevice 10, 1, 1
  
-- ============================================================================

SELECT
	CASE WHEN @IncludeOwner = 1 AND U.UserID = A.UserID THEN 'Owner' ELSE 'Roster' END AS UserType,
	@ActivityID AS ActivityID,
	U.UserID,
	U.FirstName,
	U.LastName,
	CASE @Type WHEN 1 THEN D.DeviceID WHEN 2 THEN AA.Email END AS EmailDevice,
	CASE @Type WHEN 1 THEN 'Device' WHEN 2 THEN 'Email' END AS EmailDeviceType
FROM ActivityRosterGroup ARG
	INNER JOIN ActivityRoster R ON ARG.ActivityRosterGroupID = R.ActivityRosterGroupID
	INNER JOIN UserProfile U ON R.CreatedBy = U.UserID
	LEFT JOIN UserDevice D ON U.UserID = D.UserID AND @Type = 1
	LEFT JOIN Accounts AA ON U.UserID = AA.Id AND @Type = 2
	LEFT JOIN Activity A ON A.ActivityID = @ActivityID AND @IncludeOwner = 1
	INNER JOIN UserNotification N ON U.UserID = N.UserID
WHERE ARG.ActivityID = @ActivityID
	AND ARG.IsDeleted = 0
	AND (@Type = 1 AND D.DeviceID IS NOT NULL OR @Type = 2 AND AA.Email IS NOT NULL)
	AND (N.NewRideApp = 1 
			AND N.NewRideEmail = 1 
			AND N.NewRideApp = 1
			AND N.ActivityUpdateApp = 1 
			AND N.ActivityUpdateEmail = 1
			AND N.ActivityRosterApp = 1
			AND N.ActivityRosterEmail = 1
			AND N.ActivityDiscussionApp = 1
			AND N.ActivityDiscussionEmail = 1)