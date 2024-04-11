USE [trovafit_aspnet]
GO

DROP PROCEDURE up_ListDashboardRidesDays
GO

CREATE PROCEDURE up_ListDashboardRidesDays
	@UserID int,
	@Distance float
AS
--/******************************************************************************
--*  DBA Script: up_ListDashboardRidesDays
--*  Created By: Jason Codianne 
--*  Created:    01/17/2018 
--*  Schema:     dbo
--*  Purpose:    List activities within a specific radius of home.
--******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListDashboardRidesDays 1, 200

 --DECLARE @UserID int
 --DECLARE @Distance float
 --SET @UserID = 1
 --SET @Distance = 200  

---- ============================================================================

SET NOCOUNT ON

DECLARE @UOM int
DECLARE @UOMName varchar(10)
DECLARE @UOMFactor float
DECLARE @Radius float
DECLARE @MetersPerMile float = 1609.344
DECLARE @CurrentLocation geography; 

SELECT 
	@UOM = U.UnitOfMeasureID, 
	@UOMName = M.UnitOfMeasure,
	@UOMFactor = M.MeasureFactor,
	@CurrentLocation = geography::STPointFromText('POINT(' + CAST(U.HomeBaseLng AS VARCHAR(20)) + ' ' + CAST(U.HomeBaseLat AS VARCHAR(20)) + ')', 4326) 
FROM UserProfile U 
	INNER JOIN UnitOfMeasure M ON U.UnitOfMeasureID = M.UnitOfMeasureID
WHERE U.UserID = @UserID

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
	D.Date AS WeekDayDate,
	ISNULL(A.ActivityCount, 0) AS ActivityCount
FROM Dates D
	LEFT OUTER JOIN (
		SELECT
			COUNT(X.ActivityID) AS ActivityCount, 
			X.ActivityDate
		FROM (SELECT *, geography::Point(StartLat, StartLng, 4326) AS GeoPt FROM Activity) X
		INNER JOIN UserProfile U ON X.UserID = U.UserID
		WHERE ( 
			CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) >= GETDATE()
			AND CONVERT(datetime, ActivityDate) + CONVERT(datetime, ActivityStartTime) <= DATEADD(D, 6, GETDATE())
			AND GeoPt.STDistance(@CurrentLocation) < @Radius --(@Distance * @MetersPerMile)
			)
			AND (
				X.[Private] = 0
				OR X.TeamID IN (SELECT DISTINCT T.TeamID FROM Team T LEFT OUTER JOIN TeamMember TM ON T.TeamID = TM.TeamID WHERE (TM.UserID = @UserID OR T.OwnerUserID = @UserID))
				OR @UserID IN (SELECT DISTINCT UserID FROM ActivityRoster WHERE ActivityID = X.ActivityID)
				OR @UserID = X.UserID
				)
		GROUP BY X.ActivityDate
	) A ON D.Date = A.ActivityDate
WHERE D.Date >= CONVERT(varchar, GETDATE(), 101) AND D.Date < DATEADD(D, 6, GETDATE())


