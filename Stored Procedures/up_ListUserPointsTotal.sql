USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListUserPointsTotal
GO

CREATE PROCEDURE up_ListUserPointsTotal
	@UserID int
AS
/******************************************************************************
*  Script Name:  	up_ListUserPointsTotal
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-02-02
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- 0 = all, 1 = MTD
-- EXEC up_ListUserPointsTotal 1
  
-- ============================================================================
SET FMTONLY OFF

--DECLARE @UserID int
--DECLARE @Mode int
--SET @UserID = 1
--SET @Mode = 0

CREATE TABLE #T (
	UserID int,
	UserPointID int,
	FirstName varchar(200),
	LastName varchar(200),
	PointTypeName varchar(100),
	PointAmount int,
	PointEntityID int,
	CreatedDate datetime,
	EntityName varchar(200),
	EntityUrl varchar(500)
)

INSERT INTO #T
SELECT
	UP.UserID,
	UP.UserPointID,
	U.FirstName,
	U.LastName,
	PT.PointTypeName,
	PT.PointAmount,
	UP.PointEntityID,
	UP.CreatedDate,
	EntityName = ISNULL(A.ActivityName, F.FeelerTitle),
	EntityUrl = 
		CASE
			WHEN PT.PointTypeName LIKE 'activity%' THEN '/activities/getactivity/' + CONVERT(varchar, PointEntityID) ELSE '/feelers/feelerdetails/' + CONVERT(varchar, PointEntityID)
		END
FROM UserPoint UP 
	INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
	INNER JOIN UserProfile U ON UP.UserID = U.UserID
	LEFT OUTER JOIN Activity A ON UP.PointEntityID = A.ActivityID
	LEFT OUTER JOIN ActivityFeeler F ON UP.PointEntityID = F.ActivityFeelerID
WHERE UP.UserID = @UserID

DELETE #T WHERE EntityName IS NULL

SELECT SUM(PointAmount) AS TotalPoints FROM #T

DROP TABLE #T