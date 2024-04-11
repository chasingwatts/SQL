USE [Mortis]
GO

--DROP PROCEDURE IF EXISTS dbo.up_ListUserPoints
--GO

--CREATE PROCEDURE dbo.up_ListUserPoints
--	@UserID int,
--	@Mode int
--AS
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
SET FMTONLY OFF

DECLARE @UserID int
DECLARE @Mode int
SET @UserID = 1
SET @Mode = 0

CREATE TABLE #T (
	UserID int,
	UserPointID int,
	FirstName varchar(200),
	LastName varchar(200),
	PointTypeName varchar(100),
	PointAmount int,
	PointEntityID int,
	CreatedDate datetime,
	ActivityName varchar(200),
	ActivityUrl varchar(500)
)

IF @Mode = 1
	BEGIN
		INSERT INTO #T
		SELECT
			UP.UserID,
			UP.UserPointID,
			U.FirstName,
			U.LastName,
			PT.PointTypeName,
			PT.PointAmount,
			UP.ActivityID,
			UP.CreatedDate,
			A.ActivityName,
			ActivityUrl = '/activities/getactivity/' + CONVERT(varchar, UP.ActivityID)
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.UserID = @UserID
			AND UP.CreatedDate >= DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
	END
ELSE
	BEGIN
		INSERT INTO #T
		SELECT
			UP.UserID,
			UP.UserPointID,
			U.FirstName,
			U.LastName,
			PT.PointTypeName,
			PT.PointAmount,
			UP.ActivityID,
			UP.CreatedDate,
			A.ActivityName,
			ActivityUrl = '/activities/getactivity/' + CONVERT(varchar, UP.ActivityID)
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.UserID = @UserID
	END

DELETE #T WHERE ActivityName IS NULL

SELECT * FROM #T ORDER BY CreatedDate DESC

DROP TABLE #T