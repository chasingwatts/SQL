USE [trovafit_aspnet]
GO

DECLARE @TeamID int
DECLARE @TeamName varchar(100)
DECLARE @OwnerID int
DECLARE @IsPrivate bit = 0
DECLARE @Location varchar(500)
DECLARE @Website varchar(500)
DECLARE @TeamTypeID int
DECLARE @Desc varchar(max)

SET @TeamName = 'AL3BRIJES TRIATHLON TEAM'
SET @OwnerID = 8192
SET @IsPrivate = 0
SET @Location = 'Houston, TX'
SET @Website = null
SET @TeamTypeID = 2
SET @Desc = 'AL3BRIJES TRIATHLON TEAM'


INSERT INTO [dbo].[Team]
           ([TeamName]
           ,[OwnerUserID]
           ,[IsPrivate]
           ,[Location]
           ,[Website]
           ,[TeamTypeID]
           ,[TeamDesc])
     VALUES
           (
			@TeamName,
			@OwnerID,
			@IsPrivate,
			@Location,
			@Website,
			@TeamTypeID,
			@Desc
		   )

SET @TeamID = SCOPE_IDENTITY()


INSERT INTO [dbo].[TeamMember]
           ([TeamID]
           ,[UserID]
           ,[IsAdmin])
     VALUES
           (
			@TeamID,
			@OwnerID,
			1
		   )

SELECT * FROM Team WHERE TeamID = @TeamID
SELECT * FROM TeamMember WHERE TeamID = @TeamID 
SELECT * FROM AspNetUsers WHERE Id = @OwnerID 