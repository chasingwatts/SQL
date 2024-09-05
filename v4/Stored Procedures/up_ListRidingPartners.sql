USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListRidingPartners
GO

CREATE PROCEDURE up_ListRidingPartners
	@UserID int,
	@RideCount int = 10
AS

/******************************************************************************
*  Script Name:  	up_ListRidingPartners
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2024-07-27
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListRidingPartners 33, 5
  
-- ============================================================================

WITH UserPairs AS (
    SELECT
        ar1.ActivityID,
        ar1.CreatedBy AS User1,
        ar2.CreatedBy AS User2
    FROM ActivityRoster ar1
    INNER JOIN ActivityRoster ar2 ON ar1.ActivityID = ar2.ActivityID
    WHERE ar1.CreatedBy < ar2.CreatedBy
),
PairCounts AS (
    SELECT
        User1,
        User2,
        COUNT(*) AS RideCount
    FROM UserPairs
    WHERE User1 = @UserID OR User2 = @UserID
    GROUP BY
        User1,
        User2
)

SELECT TOP 5
	CASE
        WHEN User1 = @UserID THEN up2.UserID
        ELSE up1.UserID
    END AS RidingPartnerUserID,
    CASE
        WHEN User1 = @UserID THEN up2.FirstName
        ELSE up1.FirstName
    END AS RidingPartnerFirstName,
	CASE
        WHEN User1 = @UserID THEN up2.LastName
        ELSE up1.LastName
    END AS RidingPartnerLastName,
    RideCount
FROM PairCounts pc
	INNER JOIN UserProfile up1 ON pc.User1 = up1.UserID
	INNER JOIN UserProfile up2 ON pc.User2 = up2.UserID
WHERE RideCount > @RideCount
ORDER BY RideCount DESC;

