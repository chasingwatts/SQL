USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListChatListToUserByFromUser
GO

CREATE PROCEDURE up_ListChatListToUserByFromUser
	@FromUserID int
AS

-- EXEC up_ListChatListToUserByFromUser 1
-- DECLARE @FromUserID int
-- SET @FromUserID = 1

SELECT
	Y.FromUserID, 
	Y.FromFirstName, 
	Y.FromLastName, 
	Y.ToUserID, 
	Y.ToFirstName, 
	Y.ToLastName, 
	MAX(Y.LastMessageTimeStamp) AS LastMessageTimeStamp
FROM (
	SELECT DISTINCT
		1 AS FromUserID, 
		'' AS FromFirstName, 
		'' AS FromLastName, 
		CASE WHEN X.ToUserID = @FromUserID THEN X.FromUserID ELSE X.ToUserID END AS ToUserID, 
		CASE WHEN X.ToUserID = @FromUserID THEN X.FromFirstName ELSE X.ToFirstName END AS ToFirstName, 
		CASE WHEN X.ToUserID = @FromUserID THEN X.FromLastName ELSE X.ToLastName END AS ToLastName, 
		X.LastMessageTimeStamp
	FROM (
		SELECT DISTINCT 
			C.FromUserID, 
			F.FirstName AS FromFirstName,
			F.LastName AS FromLastName,
			C.ToUserID,
			T.FirstName AS ToFirstName,
			T.LastName AS ToLastName,
			MAX(C.ChatDateTimeStamp) AS LastMessageTimeStamp
		FROM UserChat C
			INNER JOIN UserProfile F ON C.FromUserID = F.UserID
			INNER JOIN UserProfile T ON C.ToUserID = T.UserID
		WHERE C.FromUserID = @FromUserID
		GROUP BY 
			C.FromUserID, 
			F.FirstName,
			F.LastName,
			C.ToUserID,
			T.FirstName,
			T.LastName
		UNION ALL 
		SELECT DISTINCT 
			C.FromUserID, 
			F.FirstName AS FromFirstName,
			F.LastName AS FromLastName,
			C.ToUserID,
			T.FirstName AS ToFirstName,
			T.LastName AS ToLastName,
			MAX(C.ChatDateTimeStamp) AS LastMessageTimeStamp
		FROM UserChat C
			INNER JOIN UserProfile F ON C.FromUserID = F.UserID
			INNER JOIN UserProfile T ON C.ToUserID = T.UserID
		WHERE C.ToUserID = @FromUserID
		GROUP BY 
			C.FromUserID, 
			F.FirstName,
			F.LastName,
			C.ToUserID,
			T.FirstName,
			T.LastName
	) X
) Y
GROUP BY 
		Y.FromUserID, 
		Y.FromFirstName,
		Y.FromLastName,
		Y.ToUserID,
		Y.ToFirstName,
		Y.ToLastName