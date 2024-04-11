USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_GetChatListToUserByFromUser
GO

CREATE PROCEDURE up_GetChatListToUserByFromUser
	@FromUserID int
AS

-- EXEC up_GetChatListToUserByFromUser 1

SELECT DISTINCT 
	C.FromUserID, 
	F.FirstName,
	F.LastName,
	C.ToUserID,
	T.FirstName,
	T.LastName,
	MAX(C.ChatDateTimeStamp) AS LastMessageTimeStamp
FROM UserChat C
	INNER JOIN UserProfile F ON C.FromUserID = F.UserID
	INNER JOIN UserProfile T ON C.ToUserID = T.UserID
WHERE C.FromUserID = @FromUserID OR C.ToUserID = @FromUserID
GROUP BY 
	C.FromUserID, 
	F.FirstName,
	F.LastName,
	C.ToUserID,
	T.FirstName,
	T.LastName