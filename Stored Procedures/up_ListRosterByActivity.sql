DROP PROCEDURE IF EXISTS up_ListRosterByActivity
GO

CREATE PROCEDURE up_ListRosterByActivity
	@ActivityID int
AS

/******************************************************************************
*  Script Name:  	up_ListRosterByActivity
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2022-10-28
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListRosterByActivity 16782
  
-- ============================================================================
SELECT
	R.ActivityRosterID,
	A.ActivityID,
	R.UserID,
	R.ResponseTypeID,
	R.ResponseComments,
	GroupLevel = CASE WHEN AR.RouteName IS NULL THEN R.GroupLevel ELSE AR.RouteName END,
	RT.ResponseTypeName AS ResponseType,
	AR.RouteName,
	P.FirstName,
	P.LastName,
	A.ActivityName
FROM ActivityRoster R
LEFT OUTER JOIN UserProfile P ON R.UserID = P.UserID
LEFT OUTER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
LEFT OUTER JOIN Activity A ON A.ActivityID = R.ActivityID
LEFT OUTER JOIN ActivityRoute AR ON CONVERT(varchar, R.GroupLevel) = CONVERT(varchar, AR.ActivityRouteID)
WHERE R.ActivityID = @ActivityID
ORDER BY R.ResponseTypeID, P.LastName