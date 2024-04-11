USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_SearchActivities
GO

CREATE PROCEDURE dbo.up_SearchActivities
	@Lat float = NULL,
	@Lng float = NULL,
	@Miles float,
	@Keyword varchar(500) = NULL,
	@StartDate date = NULL,
	@EndDate date = NULL,
	@ActivityType int = NULL,
	@Distance float = NULL
AS
/******************************************************************************
*  DBA Script: up_SearchActivities
*  Created By: Jason Codianne 
*  Created:    02/08/2018 
*  Schema:     dbo
*  Purpose:    List activities within a specific radius of home.
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_SearchActivities '37.5247764' ,'-77.5633009', 50, null, '07/31/2021', null, null, null
-- EXEC up_SearchActivities null, null, 50, '', '06/16/2018', '09/28/2018', null, null
-- ============================================================================

 
SET NOCOUNT ON

--DECLARE @Lat float
--DECLARE @Lng float
--DECLARE @Miles float
--DECLARE @Keyword varchar(500)
--DECLARE @StartDate date
--DECLARE @EndDate date
--DECLARE @ActivityType int
--DECLARE @Distance float

--SET @Lat = '29.5526471'
--SET @Lng = '-95.55422299999998'
--SET @Miles = 50
--SET @Keyword = null --'%church%'
--SET @ActivityType = 1
--SET @StartDate = '08/01/2018'
--SET @EndDate = '12/01/2018'
--SET @Distance = null

IF @Keyword IS NOT NULL	
	SET @Keyword = '%' + @Keyword + '%'

IF @StartDate IS NULL
	SET @StartDate = '01/01/1900'

IF @EndDate IS NULL
	SET @EndDate = '12/31/2078'

IF @Distance IS NULL
	SET @Distance = 0

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @Radius float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT @CurrentLocation = geography::STPointFromText('POINT(' + CAST(@Lng AS VARCHAR(20)) + ' ' + CAST(@Lat AS VARCHAR(20)) + ')', 4326)


--set conversion to meters
IF @UOM = 3 --km
BEGIN
	SET @Radius = @Distance * 1000
END
ELSE --mi
BEGIN
	SET @Radius = @Distance * @MetersPerMile
END

SELECT
	X.UserID AS ActivityUserID,
	U.FirstName AS UserFirstName,
	U.LastName AS UserLastName,
	X.ActivityID, 
	X.ActivityName AS ActivityName,
	ROUND(GeoPt.STDistance(@CurrentLocation)/@MetersPerMile, 0) AS DistanceFromHomeBase,
	X.StartLat,
	X.StartLng,
	X.StartLocation,
	X.ActivityDate,
	Distance = ROUND(R.Distance, 2),
	M.UnitOfMeasure,
	FORMAT(CONVERT(datetime, X.ActivityStartTime), 'hh:mm tt') AS ActivityStartTime,
	FORMAT(CONVERT(datetime, X.ActivityEndTime), 'hh:mm tt') AS ActivityEndTime,
	X.ActivityNotes AS ActivityNotes,
	ISNULL(X.IsCommunity, 0) AS IsCommunity,
	X.CreatedDate,
	'myMarker' AS Shape,
	RT.RouteTypeName,
	X.ActivityTypeID,
	AT.ActivityTypeName,
	ISNULL(RS.RosterCount, 0) AS RosterCount
FROM (
	SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity
) X
INNER JOIN ActivityRoute R ON X.ActivityID = R.ActivityID
	AND R.IsPrimary = 1
INNER JOIN UserProfile U ON X.UserID = U.UserID
INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
INNER JOIN RouteType RT ON X.RouteTypeID = RT.RouteTypeID
INNER JOIN ActivityType AT ON X.ActivityTypeID = AT.ActivityTypeID
LEFT OUTER JOIN (
	SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster GROUP BY ActivityID
) RS ON X.ActivityID = RS.ActivityID
WHERE 1=1
	--AND ActivityDate >= GETDATE()
	AND GeoPt.STDistance(@CurrentLocation) < (@Miles * @MetersPerMile)
	AND X.ActivityName LIKE COALESCE(@Keyword, X.ActivityName)
	AND X.ActivityTypeID = COALESCE(@ActivityType, X.ActivityTypeID)
	AND X.ActivityDate BETWEEN @StartDate AND @EndDate
	AND R.Distance >= @Distance
ORDER BY ActivityDate

