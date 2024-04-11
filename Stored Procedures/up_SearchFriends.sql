USE [trovafit_aspnet]
GO

DROP PROCEDURE up_SearchFriends
GO

CREATE PROCEDURE up_SearchFriends
	@SearchKey varchar(100),
	@UserID int
AS
/******************************************************************************
*  DBA Script: up_SearchFriends
*  Created By: Jason Codianne 
*  Created:    01/07/2018 
*  Schema:     dbo
*  Purpose:    List friends based on name
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_SearchFriends 'minard', 1
  
-- ============================================================================

--DECLARE @SearchKey varchar(100)
--DECLARE @UserID int

--SET @SearchKey = 'stephens'
--SET @UserID = 1287

SELECT
	P.UserID,
	P.FirstName,
	P.LastName,
	P.HomeBaseZip,
	CASE WHEN P.Private = 1 THEN '  <i class="fal fa-user-secret" style="color: red; margin-left: 10px;" title="This friend is private!"></i>' ELSE '' END AS Private,
	Avatar = NULL,
	ISNULL(C.ConnectionUserID, 0) AS ConnectionUserID,
	C.ConnectionConfirmed,
	CASE WHEN ConnectionUserID IS NULL THEN 'Connect' ELSE 'Connected' END AS ConnectType
FROM AspNetUsers U
	INNER JOIN UserProfile P ON U.Id = P.UserID
	LEFT OUTER JOIN UserConnection C ON U.Id = C.ConnectionUserID
		AND C.UserID = @UserID
--WHERE (P.FirstName LIKE '%' + @SearchKey + '%' OR P.LastName LIKE '%' + @SearchKey + '%')
WHERE (P.FirstName + ' ' + P.LastName LIKE '%' + @SearchKey + '%')
--AND C.ConnectionUserID IS NULL
AND P.UserID <> @UserID
ORDER BY 3