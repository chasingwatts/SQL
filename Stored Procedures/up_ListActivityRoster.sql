USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS up_ListActivityRoster
GO

CREATE PROCEDURE up_ListActivityRoster
	@ActivityID int
AS
/******************************************************************************
*  Script Name:  	up_ListActivityRoster
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2022-01-31
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- EXEC up_ListActivityRoster 34903
  
-- ============================================================================

DECLARE @IsMultiRoute bit
SELECT @IsMultiRoute = IsMultiRoute FROM Activity WHERE ActivityID = @ActivityID

IF @IsMultiRoute = 0 --groups or nothing
BEGIN
SELECT 
	X.ActivityID, 
	X.ActivityDate, 
	X.UserID, 
	X.[Private],
	X.ResponseTypeID, 
	X.GroupLevel, 
	X.FirstName, 
	X.LastName, 
	X.UnitOfMeasureID, 
	X.Distance, 
	X.ResponseTypeName, 
	X.RouteName,
	X.ICE,
	X.HasGroups,
	X.IsMultiRoute,
	CASE 
		WHEN X.HasGroups = 1 THEN X.ResponseTypeName + ' - ' + X.GroupLevel
		WHEN X.IsMultiRoute = 1 THEN X.ResponseTypeName + ' - ' + X.RouteName --CONVERT(varchar, X.Distance) + X.UoM
		ELSE X.ResponseTypeName
	END AS ResponseTypeNameFull
FROM ( 
	SELECT
		A.ActivityID,
		A.ActivityDate,
		A.HasGroups,
		A.IsMultiRoute,
		A.[Private],
		RR.UserID,
		RR.ResponseTypeID,
		RT.ResponseTypeName,
		RR.GroupLevel,
		NULL AS RouteName,
		U.FirstName,
		U.LastName,
		U.UnitOfMeasureID,
		CASE WHEN U.UnitOfMeasureID = 2 THEN ' mi' ELSE ' km' END AS UoM,
		Distance = CASE WHEN U.UnitOfMeasureID = 2 THEN AR.Distance ELSE ROUND(AR.Distance * 1.609344, 2) END,
		ICE = CASE WHEN (U.ICEContact != '' AND U.ICEPhone != '' AND U.ICEContact != null AND U.ICEPhone != null) THEN '<i class="fal fa-heartbeat text-danger me-2"></i>' + U.ICEContact + ' - <a href="tel:' + U.ICEPhone + '">' + U.ICEPhone + '</a>' ELSE NULL END
	FROM ActivityRoster RR 
		INNER JOIN UserProfile U ON RR.UserID = U.UserID
		INNER JOIN ResponseType RT ON RR.ResponseTypeID = RT.ResponseTypeID
		INNER JOIN Activity A ON RR.ActivityID = A.ActivityID
		INNER JOIN ActivityRoute AR ON A.ActivityID = AR.ActivityID
			AND AR.IsPrimary = 1
	WHERE RR.ActivityID = @ActivityID
) X
END
ELSE
BEGIN
	SELECT 
		X.ActivityID, 
		X.ActivityDate, 
		X.UserID, 
		X.[Private],
		X.ResponseTypeID, 
		X.GroupLevel, 
		X.FirstName, 
		X.LastName, 
		X.UnitOfMeasureID, 
		X.Distance, 
		X.ResponseTypeName, 
		X.RouteName,
		X.ICE,
		X.HasGroups,
		X.IsMultiRoute,
		CASE 
			WHEN X.HasGroups = 1 THEN X.ResponseTypeName + ' - ' + X.GroupLevel
			WHEN X.IsMultiRoute = 1 THEN X.ResponseTypeName + ' - ' + X.RouteName --CONVERT(varchar, X.Distance) + X.UoM
			ELSE X.ResponseTypeName
		END AS ResponseTypeNameFull
	FROM ( 
		SELECT
			A.ActivityID,
			A.ActivityDate,
			A.HasGroups,
			A.IsMultiRoute,
			A.[Private],
			RR.UserID,
			RR.ResponseTypeID,
			RT.ResponseTypeName,
			RR.GroupLevel,
			AR.RouteName,
			U.FirstName,
			U.LastName,
			U.UnitOfMeasureID,
			CASE WHEN U.UnitOfMeasureID = 2 THEN ' mi' ELSE ' km' END AS UoM,
			Distance = CASE WHEN U.UnitOfMeasureID = 2 THEN AR.Distance ELSE ROUND(AR.Distance * 1.609344, 2) END,
			ICE = CASE WHEN (U.ICEContact != '' AND U.ICEPhone != '' AND U.ICEContact != null AND U.ICEPhone != null) THEN '<i class="fal fa-heartbeat text-danger me-2"></i>' + U.ICEContact + ' - <a href="tel:' + U.ICEPhone + '">' + U.ICEPhone + '</a>' ELSE NULL END
		FROM ActivityRoster RR 
			INNER JOIN UserProfile U ON RR.UserID = U.UserID
			INNER JOIN ResponseType RT ON RR.ResponseTypeID = RT.ResponseTypeID
			INNER JOIN Activity A ON RR.ActivityID = A.ActivityID
			LEFT OUTER JOIN ActivityRoute AR ON RR.ActivityID = AR.ActivityID
				AND RR.GroupLevel = AR.ActivityRouteID
		WHERE RR.ActivityID = @ActivityID
	) X
END