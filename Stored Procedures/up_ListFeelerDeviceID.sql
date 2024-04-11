USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_ListFeelerDeviceID
GO

CREATE PROCEDURE dbo.up_ListFeelerDeviceID
	@FeelerID int,
	@UserID int
AS
/******************************************************************************
*  DBA Script: dbo.up_ListFeelerDeviceID
*  Created By: Jason Codianne 
*  Created:    9/28/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListFeelerDeviceID 17, 33
  
-- ============================================================================
SET NOCOUNT ON

SELECT DISTINCT
	F.ActivityFeelerID,
	F.UserID,
	D.DeviceID
FROM ActivityFeelerDiscussion F
	LEFT OUTER JOIN UserDevice D ON F.UserID = D.UserID
	INNER JOIN UserNotification N ON F.UserID = N.UserID
WHERE N.ActivityUpdateApp = 1
	AND D.DeviceID IS NOT NULL
	AND ActivityFeelerID = @FeelerID
	AND F.UserID <> @UserID
UNION ALL --include feeler owner
SELECT DISTINCT
	F.ActivityFeelerID,
	F.UserID,
	D.DeviceID
FROM ActivityFeeler F 
	INNER JOIN UserDevice D ON F.UserID = D.UserID
WHERE F.ActivityFeelerID = @FeelerID
