USE [Mortis];
GO

DROP PROCEDURE IF EXISTS up_NotificationRosterEmailDeviceRoster;
GO

CREATE PROCEDURE up_NotificationRosterEmailDeviceRoster
    @ActivityID INT,
    @Type INT, -- 1: device, 2: email
    @IncludeOwner INT -- 1: include
AS

/******************************************************************************
*  Script Name:  	up_NotificationRosterEmailDeviceRoster
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-04-12
*  Schema:  		dbo
*  Purpose:		Fetch user details for notification based on activity and type.
*  Updates:			
******************************************************************************/

-- ============================================================================
-- Testing Parameters Example
-- EXEC up_NotificationRosterEmailDeviceRoster 10, 2, 1
--DECLARE @ActivityID int
--DECLARE @Type int
--DECLARE @IncludeOwner int

--SET @ActivityID = 10
--SET @Type = 1
--SET @IncludeOwner = 1
-- ============================================================================

BEGIN
    -- Validate parameters
    IF @Type NOT IN (1, 2)
    BEGIN
        RAISERROR('Invalid @Type. Must be 1 (Device) or 2 (Email).', 16, 1);
        RETURN;
    END

    IF @IncludeOwner NOT IN (0, 1)
    BEGIN
        RAISERROR('Invalid @IncludeOwner. Must be 0 (Exclude) or 1 (Include).', 16, 1);
        RETURN;
    END

    SELECT DISTINCT
		'Roster' AS UserType,
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
	INTO #R
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
          (@Type = 1 AND N.ActivityRosterApp = 1)
          OR (@Type = 2 AND N.ActivityRosterEmail = 1) 
      )
      AND (
          -- Additional conditions for device or email based on @Type
          (@Type = 1 AND D.DeviceID IS NOT NULL)
          OR (@Type = 2 AND AA.Email IS NOT NULL)
      );

	IF (@IncludeOwner = 1)
	BEGIN
		SELECT DISTINCT
		'Owner' AS UserType,
        A.ActivityID,
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
	INTO #O
    FROM Activity A
		LEFT JOIN UserProfile U ON A.UserID = U.UserID
		LEFT JOIN UserDevice D ON U.UserID = D.UserID AND @Type = 1
		LEFT JOIN Accounts AA ON U.UserID = AA.Id AND @Type = 2
		LEFT JOIN UserNotification N ON U.UserID = N.UserID
    WHERE A.ActivityID = @ActivityID
      AND A.IsDeleted = 0
      AND U.IsDeleted = 0
      AND (
          (@Type = 1 AND N.ActivityRosterApp = 1)
          OR (@Type = 2 AND N.ActivityRosterEmail = 1) 
      )
      AND (
          -- Additional conditions for device or email based on @Type
          (@Type = 1 AND D.DeviceID IS NOT NULL)
          OR (@Type = 2 AND AA.Email IS NOT NULL)
      );
	END

	
	IF OBJECT_ID('tempdb..#O') IS NOT NULL
	BEGIN
		SELECT * FROM #R
		UNION ALL
		SELECT * FROM #O;
	END
	ELSE
	BEGIN
		SELECT * FROM #R
	END

	DROP TABLE IF EXISTS #R
	DROP TABLE IF EXISTS #O
END;
GO
