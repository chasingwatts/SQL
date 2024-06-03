USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_GetUserPointDetails
GO

CREATE PROCEDURE up_GetUserPointDetails
	@UserID int
AS

/******************************************************************************
*  Script Name:  	up_GetUserPointDetails
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-06-02
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_GetUserPointDetails 1
  
-- ============================================================================
WITH UserJoulePoints AS (
    SELECT
        P.UserID,
        SUM(T.PointAmount) AS JoulePointTotal
    FROM UserPoint P
    INNER JOIN PointType T ON P.PointTypeID = T.PointTypeID
    WHERE P.UserID = @UserID
    GROUP BY P.UserID
)

SELECT
    UJP.UserID,
    UJP.JoulePointTotal,
    UPL.*
FROM UserJoulePoints UJP
INNER JOIN UserPointLevel UPL
ON UJP.JoulePointTotal BETWEEN UPL.LevelMin AND UPL.LevelMax
