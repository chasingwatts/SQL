
CREATE TABLE [dbo].[ActivityRoute](
	[ActivityRouteID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [int] NOT NULL,
	[IsPrimary] [bit] NOT NULL,
	[RouteName] [varchar](500) NOT NULL,
	[Distance] [float] NOT NULL,
	[Speed] [int] NOT NULL,
	[MapSourceID] [int] NOT NULL,
	[MapJSON] [nvarchar](max) NULL,
	[MapURL] [varchar](500) NULL,
	[MapRouteNumber] [varchar](50) NULL,
	[RouteLatLng] [nvarchar](max) NULL,
	[RouteDistanceElevation] [nvarchar](max) NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ActivityRoute] PRIMARY KEY CLUSTERED 
(
	[ActivityRouteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ActivityRoute] ADD  CONSTRAINT [DF_ActivityRoute_IsPrimary]  DEFAULT ((0)) FOR [IsPrimary]
GO

ALTER TABLE [dbo].[ActivityRoute] ADD  CONSTRAINT [DF_ActivityRoute_ModifiedDate]  DEFAULT (getdate()) FOR [ModifiedDate]
GO

ALTER TABLE [dbo].[ActivityRoute]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRoute_Activity] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[Activity] ([ActivityID])
GO

ALTER TABLE [dbo].[ActivityRoute] CHECK CONSTRAINT [FK_ActivityRoute_Activity]
GO

ALTER TABLE [dbo].[ActivityRoute]  WITH CHECK ADD  CONSTRAINT [FK_ActivityRoute_MapSource] FOREIGN KEY([MapSourceID])
REFERENCES [dbo].[MapSource] ([MapSourceID])
GO

ALTER TABLE [dbo].[ActivityRoute] CHECK CONSTRAINT [FK_ActivityRoute_MapSource]
GO

INSERT INTO ActivityRoute
SELECT 
	ActivityID,
	1,
	ActivityName,
	Distance,
	S.SpeedRangeLow,
	MapSourceID,
	NULL AS MapJSON,
	MapURL,
	MapRouteNumber,
	NULL AS RouteLatLng,
	NULL AS RouteDistanceElevation,
	ModifiedDate
FROM Activity A
INNER JOIN SpeedRange S ON A.SpeedRangeID = S.SpeedRangeID

SELECT * FROM ActivityRoute 

--drop map related cols in Activity
ALTER TABLE Activity DROP CONSTRAINT FK_Activity_MapSource
GO

ALTER TABLE Activity DROP CONSTRAINT FK_Activity_SpeedRange
GO

ALTER TABLE Activity
DROP COLUMN MapSourceID, MapURL, MapRouteNumber, Distance, SpeedRangeID
GO

--pictures
CREATE TABLE [dbo].[ActivityPicture](
	[ActivityPictureID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [int] NOT NULL,
	[PicturePath] [varchar](50) NOT NULL,
	[IsMap] [bit] NOT NULL,
 CONSTRAINT [PK_ActivityPicture] PRIMARY KEY CLUSTERED 
(
	[ActivityPictureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ActivityPicture] ADD  CONSTRAINT [DF_ActivityPicture_IsMap]  DEFAULT ((0)) FOR [IsMap]
GO

ALTER TABLE [dbo].[ActivityPicture]  WITH CHECK ADD  CONSTRAINT [FK_ActivityPicture_Activity] FOREIGN KEY([ActivityID])
REFERENCES [dbo].[Activity] ([ActivityID])
GO

ALTER TABLE [dbo].[ActivityPicture] CHECK CONSTRAINT [FK_ActivityPicture_Activity]
GO

INSERT INTO ActivityPicture
SELECT ActivityID, '/ogmaps/ogmap_' + CONVERT(varchar, ActivityID) + '.png', 1 FROM Activity 
