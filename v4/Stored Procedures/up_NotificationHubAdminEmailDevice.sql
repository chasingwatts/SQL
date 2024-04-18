USE [Mortis];
GO

DROP PROCEDURE IF EXISTS up_NotificationHubAdminEmailDevice;
GO

CREATE PROCEDURE up_NotificationHubAdminEmailDevice
	@HubID INT,
	@Type INT -- 1: device, 2: email
AS

/******************************************************************************
*  Script Name:  	up_NotificationHubAdminEmailDevice
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-04-17
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_NotificationHubAdminEmailDevice 1, 2

-- DECLARE @Type int
-- SET @Type = 1  
-- ============================================================================

SELECT 
	'Admin' AS UserType,
	H.HubID,
	HM.UserID,
	U.FirstName,
	U.LastName,
	CASE @Type WHEN 1 THEN D.DeviceID WHEN 2 THEN AA.Email END AS EmailDevice,
	CASE @Type WHEN 1 THEN 'Device' WHEN 2 THEN 'Email' END AS EmailDeviceType
FROM Hub H
	INNER JOIN HubMember HM ON H.HubID = HM.HubID
	INNER JOIN HubMemberRole HMR ON HM.HubMemberRoleID = HMR.HubMemberRoleID
	INNER JOIN UserProfile U ON HM.UserID = U.UserID
	LEFT JOIN UserDevice D ON HM.UserID = D.UserID AND @Type = 1
	LEFT JOIN Accounts AA ON HM.UserID = AA.Id AND @Type = 2
	INNER JOIN UserNotification N ON HM.UserID = N.UserID
WHERE HM.HubMemberRoleID = 1 --admin
	AND H.HubID = @HubID
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