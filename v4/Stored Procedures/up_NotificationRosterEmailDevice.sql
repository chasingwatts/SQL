USE [Mortis];
GO

DROP PROCEDURE IF EXISTS up_NotificationRosterEmailDevice;
GO

CREATE PROCEDURE up_NotificationRosterEmailDevice
	@ActivityID INT,
	@Type INT, -- 1: device, 2: email
	@IncludeOwner INT -- 1: include
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
-- EXEC up_NotificationRosterEmailDevice 10, 2, 1
  
-- ============================================================================

SELECT DISTINCT
        CASE 
            WHEN @IncludeOwner = 1 AND U.UserID = A.UserID THEN 'Owner' 
            ELSE 'Roster' 
        END AS UserType,
        R.ActivityID,
        U.UserID,
        U.FirstName,
        U.LastName,
        CASE 
            WHEN @Type = 1 THEN D.DeviceID 
            WHEN @Type = 2 THEN AA.Email 
        END AS EmailDevice,
        CASE 
            WHEN @Type = 1 THEN 'Device' 
            WHEN @Type = 2 THEN 'Email' 
        END AS EmailDeviceType
    FROM ActivityRoster R
    LEFT JOIN UserProfile U ON R.CreatedBy = U.UserID
    LEFT JOIN UserDevice D ON U.UserID = D.UserID AND @Type = 1
    LEFT JOIN Accounts AA ON U.UserID = AA.Id AND @Type = 2
    LEFT JOIN Activity A ON A.ActivityID = @ActivityID
    LEFT JOIN UserNotification N ON U.UserID = N.UserID
    WHERE R.ActivityID = @ActivityID
      AND A.IsDeleted = 0
      AND U.IsDeleted = 0
      AND (
          (@Type = 1 AND D.DeviceID IS NOT NULL) 
          OR (@Type = 2 AND AA.Email IS NOT NULL)
      )
		--AND ((@Type = 2 AND N.NewRideEmail = 1) OR (@Type = 1 AND N.NewRideApp = 1))
      AND (
          (@Type = 1 AND N.NewRideApp = 1) 
          OR (@Type = 2 AND N.NewRideEmail = 1) 
          OR (@Type = 1 AND N.ActivityUpdateApp = 1)
          OR (@Type = 2 AND N.ActivityUpdateEmail = 1)
          OR (@Type = 1 AND N.ActivityRosterApp = 1)
          OR (@Type = 2 AND N.ActivityRosterEmail = 1)
          OR (@Type = 1 AND N.ActivityDiscussionApp = 1)
          OR (@Type = 2 AND N.ActivityDiscussionEmail = 1)
      )
      AND (
          @IncludeOwner = 1 
          OR (A.UserID IS NULL OR A.UserID <> U.UserID)
      );