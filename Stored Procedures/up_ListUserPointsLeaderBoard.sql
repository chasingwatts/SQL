USE [Mortis]
GO

--DROP PROCEDURE IF EXISTS dbo.up_ListUserPointsLeaderBoard
--GO

--CREATE PROCEDURE dbo.up_ListUserPointsLeaderBoard
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
-- 0 = all, 1 = MTD, 2 = QTR
-- EXEC up_ListUserPointsLeaderBoard 2
  
-- ============================================================================
SET FMTONLY OFF

DECLARE @Mode int
SET @Mode = 1

CREATE TABLE #T (
	UserID int,
	FirstName varchar(200),
	LastName varchar(200),
	PointAmount int,
	CreateDate datetime,
	ActivityName varchar(200)
)

IF @Mode = 1
	BEGIN
		INSERT INTO #T
		SELECT
			UP.UserID,
			U.FirstName,
			U.LastName,
			PT.PointAmount,
			UP.CreatedDate,
			A.ActivityName
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.CreatedDate >= DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
			AND UP.UserID <> 1 --exclude JC
	END
ELSE IF @Mode = 2
BEGIN
		INSERT INTO #T
		SELECT
			UP.UserID,
			U.FirstName,
			U.LastName,
			PT.PointAmount,
			UP.CreatedDate,
			A.ActivityName
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.CreatedDate BETWEEN DATEADD(q, DATEDIFF(q, 0, GETDATE()), 0) AND DATEADD(d, -1, DATEADD(q, DATEDIFF(q, 0, GETDATE()) + 1, 0))
			AND UP.UserID <> 1 --exclude JC
	END
ELSE
	BEGIN
		INSERT INTO #T
		SELECT
			UP.UserID,
			U.FirstName,
			U.LastName,
			PT.PointAmount,
			UP.CreatedDate,
			A.ActivityName
		FROM UserPoint UP 
			INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
			INNER JOIN UserProfile U ON UP.UserID = U.UserID
			LEFT OUTER JOIN Activity A ON UP.ActivityID = A.ActivityID
		WHERE UP.UserID <> 1 --exclude JC
	END

--remove any delete rides/feelers
DELETE #T WHERE ActivityName IS NULL 

--take top 20

SELECT TOP 20 
	UserID, 
	FirstName + ' ' + LastName AS FullName, 
	SUM(PointAmount) AS PointAmount 
FROM #T 
GROUP BY 
	UserID, 
	FirstName, 
	LastName
ORDER BY 3 DESC

DROP TABLE #T