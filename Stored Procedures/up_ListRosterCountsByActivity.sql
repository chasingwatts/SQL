USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListRosterCountsByActivity
GO

CREATE PROCEDURE dbo.up_ListRosterCountsByActivity
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListRosterCountsByActivity
*  Created By: Jason Codianne 
*  Created:    05/25/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListRosterCountsByActivity 2334
  
-- ============================================================================
SET NOCOUNT ON

SELECT *
FROM (
SELECT
	R.ActivityID,
	R.UserID,
	T.ResponseTypeName
FROM ActivityRoster R
	INNER JOIN ResponseType T ON R.ResponseTypeID = T.ResponseTypeID 
WHERE R.ActivityID = @ActivityID
) AS Roster
PIVOT (
	COUNT(UserID) FOR ResponseTypeName IN ([Yes], [No], [Interested], [Invited])
) AS P