USE [Mortis]
GO

DROP PROCEDURE IF EXISTS up_ListInviteListByActivity
GO

CREATE PROCEDURE up_ListInviteListByActivity
	@ActivityID int,
	@UserID int
AS

--EXEC up_ListInviteListByActivity 10, 1

SELECT * FROM UserFollowing F
WHERE F.UserID = @UserID
	AND F.IsConfirmed = 1
	AND F.FollowingID NOT IN (SELECT UserID FROM ActivityInvite WHERE UserID = F.FollowingID AND ActivityID = @ActivityID)
	AND F.FollowingID NOT IN (
		SELECT ISNULL(R.CreatedBy, 0) FROM Activity A
			LEFT OUTER JOIN ActivityRosterGroup G ON A.ActivityID = G.ActivityID
			LEFT OUTER JOIN ActivityRoster R ON G.ActivityRosterGroupID = R.ActivityRosterGroupID
		WHERE A.ActivityID = @ActivityID
		)