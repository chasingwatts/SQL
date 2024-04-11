USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListRosterApp
GO

CREATE PROCEDURE dbo.up_ListRosterApp
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: dbo.up_ListRosterApp
*  Created By: Jason Codianne 
*  Created:    09/27/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC dbo.up_ListRosterApp 1817
  
-- ============================================================================
SET NOCOUNT ON

SELECT DISTINCT 
	R.ActivityID,
	R.UserID,
	R.ResponseTypeID,
	RT.ResponseTypeName,
	R.ResponseComments,
	R.GroupLevel,
	P.FirstName,
	P.LastName,
	P.FirstName + ' ' + P.LastName AS FullName,
	A.ActivityName,
	U.Email
FROM ActivityRoster R
	INNER JOIN ResponseType RT ON R.ResponseTypeID = RT.ResponseTypeID
	INNER JOIN Activity A ON R.ActivityID = A.ActivityID
	INNER JOIN UserNotification N ON R.UserID = N.UserID
	INNER JOIN AspNetUsers U ON N.UserID = U.Id
	INNER JOIN UserProfile P ON U.Id = P.UserID
WHERE R.ActivityID = @ActivityID 
	AND N.ActivityRosterApp = 1


--SELECT * FROM ActivityRoster WHERE ActivityID = 1143  