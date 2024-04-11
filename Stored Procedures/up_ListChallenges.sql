USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListChallenges
GO

CREATE PROCEDURE up_ListChallenges
 @UserID int
 AS
 /******************************************************************************
 *  Script Name:	up_ListChallenges
 *  Created By:  	Jason Codianne 
 *  Created Date:  	2019-06-10
 *  Schema: 		dbo
 *  Purpose:	
 ******************************************************************************/
 -- ============================================================================
 -- Testing Parms
 -- EXEC dbo.up_ListChallenges 1
   
 -- ============================================================================
 

SELECT
	C.ChallengeID, 
	C.ChallengeName, 
	C.StartDate, 
	C.EndDate, 
	C.ChallengeDesc,
	C.ChallengeTag,
	COUNT(R.UserID) AS ChallengeCount,
	InRoster = CONVERT(bit, ISNULL((SELECT 0 FROM ChallengeRoster WHERE ChallengeID = C.ChallengeID AND UserID = @UserID), 1))
FROM Challenge C
LEFT OUTER JOIN ChallengeRoster R ON C.ChallengeID = R.ChallengeID  
WHERE C.EndDate >= GETDATE()
GROUP BY 
	C.ChallengeID, 
	C.ChallengeName, 
	C.StartDate, 
	C.EndDate, 
	C.ChallengeDesc,
	C.ChallengeTag
GO


