USE [Mortis]
GO

/******************************************************************************
*  Script Name:  	Activity Add Script
*  Created By:  	Jason 
*  Created Date:  	1/31/2024
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
					
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- 
  
-- ============================================================================

DECLARE @ActivityID INT	
DECLARE @ActivityRouteID INT 

/* ========================================================================== */
-- ACTIVITY NEXT ID
/* ========================================================================== */
INSERT INTO ActivityNext 
SELECT 1, GETDATE()

SET @ActivityID = @@IDENTITY
PRINT ('Activity ID created: ' + CONVERT(VARCHAR, @ActivityID))

/* ========================================================================== */
-- ACTIVITY 
/* ========================================================================== */
INSERT INTO Activity
(
	ActivityID
	,ActivityTypeID
	,RosterGroupTypeID
	,UserID
	,ActivityName
	,ActivityDate
	,ActivityStartTime
	,ActivityEndTime
	,StartName
	,StartAddress
	,StartCity
	,StartState
	,StartCountry
	,StartLat
	,StartLng
	,StartW3W
	,ActivityNotes
	,IsPrivate
	,IsCancelled
	,IsPromoted
	,HasWaiver
	,IsCommunity
	,IsDrop
	,IsLightsRequired
	,ParentActivityID
	,TeamID
	,IsDeleted
	,CreatedBy
	,CreatedDate
	,ModifiedBy
	,ModifiedDate
)
VALUES
(
	@ActivityID,
	CAST(RAND(CHECKSUM(NEWID())) * 7 as INT) + 1 --Random <ActivityTypeID, int,>
	,1 --Default <RosterGroupTypeID, int,>
	,1 -- Jason C <UserID, int,>
	,'Test Ride: ' + CONVERT(VARCHAR, CAST(RAND(CHECKSUM(NEWID())) * 1000 as INT) + 1) --<ActivityName, nvarchar(200),>
	,CONVERT(VARCHAR, DATEADD(DAY, 2, GETDATE()), 101) -- +2 <ActivityDate, date,>
	,'07:00:00' -- <ActivityStartTime, time(7),>
	,'10:00:00' --<ActivityEndTime, time(7),>
	,'Test Start Location Name' --<StartName, varchar(200),>
	,'123 Here Street' --<StartAddress, varchar(200),>
	,'Houston' --<StartCity, varchar(200),>
	,'TX' --<StartState, varchar(200),>
	,'US' --<StartCountry, varchar(200),>
	,29.7354599 --<StartLat, float,>
	,-95.3764886 --<StartLng, float,>
	,'test.route.location' --<StartW3W, varchar(200),>
	,'Duis dignissim justo nec ultrices commodo. In sollicitudin interdum consequat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut fermentum lectus ut egestas aliquet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut sed magna vitae lorem consequat venenatis ut vel nunc. Aenean mollis tincidunt egestas. Quisque condimentum elit eu diam condimentum congue ac nec elit.' --<ActivityNotes, nvarchar(max),>
	,0 -- false <IsPrivate, bit,>
	,0 -- false <IsCancelled, bit,>
	,0 -- false <IsPromoted, bit,>
	,0 -- false <HasWaiver, bit,>
	,0 -- false <IsCommunity, bit,>
	,1 -- true <IsDrop, bit,>
	,0 -- false <IsLightsRequired, bit,>
	,NULL --<ParentActivityID, int,>
	,NULL --<TeamID, int,>
	,0 -- false <IsDeleted, bit,>
	,1 --<CreatedBy, varchar(100),>
	,GETDATE() --<CreatedDate, datetime,>
	,1 -- <ModifiedBy, varchar(100),>
	,GETDATE() --<ModifiedDate, datetime,>
)


/* ========================================================================== */
-- ACTIVITY ROUTE
/* ========================================================================== */
INSERT INTO ActivityRoute
(
	[ActivityID]
	,[RouteName]
	,[MapSourceID]
	,[IsPrimary]
	,[DifficultyLevelID]
	,[Distance]
	,[Speed]
	,[RouteNumber]
	,[MapUrl]
	,[GPXRoutePath]
	,[GeoRoutePath]
	,[IsDeleted]
	,[CreatedBy]
	,[CreatedDate]
	,[ModifiedBy]
	,[ModifiedDate]
)
VALUES
(
	@ActivityID --<ActivityID, int,>
	,'Test Route: ' + CONVERT(VARCHAR, CAST(RAND(CHECKSUM(NEWID())) * 1000 as INT) + 1) --<RouteName, nvarchar(500),>
	,1 --<MapSourceID, int,>
	,1 --true <IsPrimary, bit,>
	,1 --<DifficultyLevelID, int,>
	,50 --<Distance, float,>
	,20 --<Speed, int,>
	,'45391659' --<RouteNumber, varchar(100),>
	,'https://ridewithgps.com/routes/45391659' -- RWGPS <MapUrl, varchar(500),>
	,'/routegpx/route_gpx_' + CONVERT(varchar, @ActivityID) + '.gpx' --<GPXRoutePath, varchar(100),>
	,'/routegeo/route_geo_' + CONVERT(varchar, @ActivityID) + '.geojson' --<GeoRoutePath, varchar(100),>
	,0 --false <IsDeleted, bit,>
	,1 --<CreatedBy, varchar(100),>
	,GETDATE() --<CreatedDate, datetime,>
	,1 -- <ModifiedBy, varchar(100),>
	,GETDATE() --<ModifiedDate, datetime,>
)

SET @ActivityRouteID = @@IDENTITY
PRINT ('Activity route created: ' + CONVERT(VARCHAR, @ActivityRouteID))


/* ========================================================================== */
-- ACTIVITY ROSTER GROUP
/* ========================================================================== */
INSERT INTO ActivityRosterGroup
(
	[ActivityID]
	,[GroupName]
	,[GroupDescription]
	,[ActivityRouteID]
	,[IsDeleted]
	,[CreatedBy]
	,[CreatedDate]
	,[ModifiedBy]
	,[ModifiedDate]
)
VALUES
(
	@ActivityID --<ActivityID, int,>
	,'Default' --<GroupName, varchar(50),>
	,'Default Roster' --<GroupDescription, varchar(50),>
	,@ActivityRouteID --<ActivityRouteID, int,>
	,0 -- false <IsDeleted, bit,>
	,1 --<CreatedBy, varchar(100),>
	,GETDATE() --<CreatedDate, datetime,>
	,1 -- <ModifiedBy, varchar(100),>
	,GETDATE() --<ModifiedDate, datetime,>
)

PRINT ('Activity roster group created.')

/* ========================================================================== */
-- ACTIVITY PiCTURE
/* ========================================================================== */
INSERT INTO ActivityPicture
(
	[ActivityID]
	,[PicturePath]
	,[IsMap]
	,[IsDeleted]
)
VALUES
(
	@ActivityID --<ActivityID, int,>
	,'/ogmaps/ogmap_' + CONVERT(VARCHAR, @ActivityID) + '.png' --<PicturePath, varchar(100),>
	,1 -- true <IsMap, bit,>
	,0 -- false<IsDeleted, bit,>
)

PRINT ('Activity picture (ogMap) created.')

/* ========================================================================== */
-- ACTIVITY TAG
/* ========================================================================== */
INSERT INTO ActivityTag
(
	[ActivityID]
	,[ActivityTagName]
)
VALUES
(
	@ActivityID -- <ActivityID, int,>
	,'test tag ' + CONVERT(VARCHAR, CAST(RAND(CHECKSUM(NEWID())) * 10 as INT) + 1) -- ,<ActivityTagName, varchar(100),>
)
INSERT INTO ActivityTag
(
	[ActivityID]
	,[ActivityTagName]
)
VALUES
(
	@ActivityID -- <ActivityID, int,>
	,'test tag ' + CONVERT(VARCHAR, CAST(RAND(CHECKSUM(NEWID())) * 10 as INT) + 1) -- ,<ActivityTagName, varchar(100),>
)

PRINT ('Activity tags created.')

/* ========================================================================== */
-- ACTIVITY LOG
/* ========================================================================== */
INSERT INTO ActivityLog
(
	[ActivityID]
	,[LogText]
	,[CreatedBy]
	,[CreatedDate]
)
VALUES
(
	@ActivityID --<ActivityID, int,>
	,'Ride created.' --init <LogText, varchar(500),>
	,1 -- <CreatedBy, int,>
	,GETDATE() --<CreatedDate, datetime,>
)

PRINT ('Activity log created.')

