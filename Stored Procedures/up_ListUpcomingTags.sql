USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListUpcomingTags
GO

CREATE PROCEDURE up_ListUpcomingTags
AS
/******************************************************************************
*  DBA Script: up_ListUpcomingTags
*  Created By: Jason Codianne 
*  Created:    04/02/2019 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListUpcomingTags
  
-- ============================================================================

SELECT
	T.ActivityTagName AS TagName,
	COUNT(T.ActivityTagID) AS TagCount,
	'/activities/taglist/' + T.ActivityTagName AS NavigateUrl
FROM ActivityTag T
	INNER JOIN Activity A ON T.ActivityID = A.ActivityID
WHERE A.ActivityDate >= GETDATE() 
GROUP BY T.ActivityTagName