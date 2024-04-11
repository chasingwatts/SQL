USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListUserResponseCountsCircles
GO

CREATE PROCEDURE dbo.up_ListUserResponseCountsCircles
	@UserID int
AS
/******************************************************************************
*  DBA Script: dbo.up_ListUserResponseCountsCircles
*  Created By: Jason Codianne 
*  Created:    05/15/2019 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListUserResponseCountsCircles 1401
  
-- ============================================================================

DECLARE @Total float
SELECT @Total = COUNT(ActivityID) FROM ActivityRoster WHERE UserID = @UserID

SELECT
	ISNULL(AR.UserID, @UserID) AS UserID,
	COUNT(AR.ActivityID) AS ActivityCount,
	@Total AS TotalCount,
	CONVERT(float, CASE WHEN @Total > 0 THEN ROUND(COUNT(AR.ActivityID)/@Total * 100, 0) ELSE 0 END) AS AcitivityPercent,
	RT.ResponseTypeName,
	CASE 
		WHEN RT.ResponseTypeID = 1 THEN '#47A44B' -- yes
		WHEN RT.ResponseTypeID = 3 THEN '#F08F00' -- int
		WHEN RT.ResponseTypeID = 4 THEN '#F33527' -- no
		WHEN RT.ResponseTypeID = 5 THEN 'gray' -- inv
	END AS ResponseColor
FROM ResponseType RT
	LEFT OUTER JOIN ActivityRoster AR ON RT.ResponseTypeID = AR.ResponseTypeID
		AND AR.UserID = @UserID
GROUP BY 
	AR.UserID,
	RT.ResponseTypeName,
	RT.ResponseTypeID


 