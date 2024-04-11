USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListUserConnectionRequests
GO

CREATE PROCEDURE up_ListUserConnectionRequests
	@FollowingUserID int
AS

--EXEC up_ListUserConnectionRequests 1
--DECLARE @FollowingUserID int
--SET @FollowingUserID = 1

SELECT
	F.UserFollowingID,
	F.UserID AS CurrentUserID,
	UC.FirstName AS CurrentUserFirstName,
	UC.LastName AS CurrentUserLastName,
	F.FollowingID AS FollowingUserID,
	UF.FirstName AS FollowingUserFirstName,
	UF.LastName AS FollowingUserLastName,
	UF.[Private] AS FollowingUserIsPrivate
FROM UserFollowing F
INNER JOIN UserProfile UC ON F.UserID = UC.UserID
INNER JOIN UserProfile UF ON F.FollowingID = UF.UserID
WHERE F.IsConfirmed = 0
	AND F.FollowingID = @FollowingUserID
	AND UF.[Private] = 1