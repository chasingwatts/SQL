USE [Mortis]
GO

DROP VIEW IF EXISTS vw_CheckUserHasLiked
GO

CREATE VIEW vw_CheckUserHasLiked
AS

SELECT
	ActivityID,
	CreatedBy AS UserID
FROM ActivityLike L