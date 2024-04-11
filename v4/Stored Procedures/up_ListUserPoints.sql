USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListUserPoints
GO

CREATE PROCEDURE up_ListUserPoints
	@UserID int,
	@Mode int
AS
/******************************************************************************
*  Script Name:  	up_ListUserPoints
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-02-02
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- 0 = all, 1 = MTD
-- EXEC up_ListUserPoints 1, 0
  
-- ============================================================================

--DECLARE @UserID int
--DECLARE @Mode int
--SET @UserID = 1
--SET @Mode = 0

IF @Mode = 1
	BEGIN
		SELECT
			UP.*
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.UserID = @UserID
			AND UP.CreatedDate >= DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
	END
ELSE
	BEGIN
		SELECT
			UP.*
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.UserID = @UserID
	END