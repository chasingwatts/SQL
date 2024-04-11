USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListUserChatMessage
GO

CREATE PROCEDURE up_ListUserChatMessage
	@FromUserID int,
	@ToUserID int
AS

-- EXEC up_ListUserChatMessage 1, 33


SELECT 
	C.UserChatID, 
	C.FromUserID, 
	F.FirstName AS FromFirstName,
	F.LastName AS FromLastName,
	CONVERT(bit, CASE
		WHEN C.FromUserID = @FromUserID THEN 1 ELSE 0
	END) AS IsMessageOwner,
	C.ToUserID,
	T.FirstName AS ToFirstName,
	T.LastName AS ToLastName,
	C.ChatDateTimeStamp, 
	C.ChatMessage 
FROM UserChat C
	INNER JOIN UserProfile F ON C.FromUserID = F.UserID
	INNER JOIN UserProfile T ON C.ToUserID = T.UserID
WHERE (C.FromUserID = @FromUserID AND C.ToUserID = @ToUserID) 
	OR (C.FromUserID = @ToUserID AND C.ToUserID = @FromUserID) --inverse
ORDER BY C.ChatDateTimeStamp