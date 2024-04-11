USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListRosterCountsByShop
GO 

CREATE PROCEDURE up_ListRosterCountsByShop
	@OwnerID int,
	@StartDate date,
	@EndDate date
AS
/******************************************************************************
*  Script Name:  	up_ListRosterCountsByShop
*  Created By:  	VERDUN\jcodianne 
*  Created Date:  	2021-05-28
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListRosterCountsByShop 1, '05/28/2020', '05/28/2021'
  
-- ============================================================================

--ColorField = (grp.Key.ResponseTypeName == "Yes") ? "#47A44B" : (grp.Key.ResponseTypeName == "No") ? "#F33527" : (grp.Key.ResponseTypeName == "Invited") ? "gray" : "#F33527",

SELECT *
FROM (
	SELECT
		A.ActivityDate,
		R.UserID,
		T.ResponseTypeName
	FROM ActivityRoster R
		INNER JOIN Activity A ON R.ActivityID = A.ActivityID
		INNER JOIN ResponseType T ON R.ResponseTypeID = T.ResponseTypeID 
	WHERE A.UserID = @OwnerID
		AND A.ActivityDate BETWEEN @StartDate AND @EndDate
) AS Roster
PIVOT (
	COUNT(UserID) FOR ResponseTypeName IN ([Yes], [No], [Interested], [Invited])
) AS P
ORDER BY 1

SELECT
	A.ActivityDate,
	RT.ResponseTypeName,
	CASE
		WHEN RT.ResponseTypeName = 'Yes' THEN '#47A44B'
		WHEN RT.ResponseTypeName = 'No' THEN '#F33527'
		WHEN RT.ResponseTypeName = 'Invited' THEN 'gray'
		WHEN RT.ResponseTypeName = 'Interested' THEN '#F33527'
	END AS ColorField,
	COUNT(R.UserID) AS RosterCount
FROM ActivityRoster R
	INNER JOIN Activity A ON R.ActivityID = A.ActivityID
	INNER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
WHERE A.UserID = @OwnerID
	AND A.ActivityDate BETWEEN @StartDate AND @EndDate
GROUP BY A.ActivityDate, RT.ResponseTypeName
ORDER BY 1 DESC 