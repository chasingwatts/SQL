USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_SearchUserProfile
GO

CREATE PROCEDURE up_SearchUserProfile
	@SearchTerm varchar(200),
	@UserID int
AS

-- EXEC up_SearchUserProfile 'chasing', 1
--DECLARE @SearchTerm NVARCHAR(100) = 'test';
--DECLARE @UserID int = 5

SELECT DISTINCT
	U.*, 
	CASE 
		WHEN F.FollowingID = @UserID AND F.IsConfirmed = 1 THEN 'Confirmed Friend' 
		WHEN F.FollowingID = @UserID AND F.IsConfirmed = 0 THEN 'Requested Friend' 
		WHEN F.FollowingID IS NULL OR F.FollowingID <> @UserID THEN 'Not Connected' 
	END AS FriendStatus,
	AT.ActivityTypeName,
	AT.ActivityTypeColor,
	AT.ActivityTypeIcon,
	G.GenderName
FROM UserProfile U
	LEFT OUTER JOIN UserFollowing F ON U.UserID = F.FollowingID
	LEFT OUTER JOIN ActivityType AT ON U.ActivityTypeID = AT.ActivityTypeID
	LEFT OUTER JOIN UserGender G ON U.UserGenderID = G.UserGenderID
WHERE IsDeleted = 0
AND U.UserID <> @UserID
AND (FirstName + ' ' + LastName LIKE '%' + @SearchTerm + '%'
OR LastName + ', ' + FirstName LIKE '%' + @SearchTerm + '%');
