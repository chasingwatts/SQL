DROP TABLE [trovafit_aspnet].dbo.MapConversion
GO

SELECT       
	A.ActivityID, 
	A.UserID, 
	A.ActivityName, 
	A.ActivityDate,
	A.MapSourceID,
	M.MapSourceName,
	A.MapURL,
	A.MapRouteNumber,
	A.Distance,
	S.SpeedRangeLow
--INTO [trovafit_aspnet].dbo.MapConversion
FROM Activity A
	INNER JOIN MapSource M ON A.MapSourceID = M.MapSourceID
	INNER JOIN SpeedRange S ON A.SpeedRangeID = S.SpeedRangeID
WHERE A.ActivityDate >= '10/15/2022'
	AND YEAR(A.ActivityDate) <= 2023
	AND A.MapSourceID <> 4 --no map
ORDER BY A.ActivityDate

SELECT TOP 10 * FROM ActivityRoute
ORDER BY 1 DESC
