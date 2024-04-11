USE [trovafit_aspnet]
GO

SELECT TOP 30
	UP.UserID,
	P.FirstName,
	P.LastName,
	U.Email,
	SUM(PT.PointAmount) AS UserPointTotal,
	MAX(UP.CreatedDate) AS LastUserPoint
FROM UserPoint UP
	INNER JOIN PointType PT ON UP.PointTypeID = PT.PointTypeID
	INNER JOIN UserProfile P ON UP.UserID = P.UserID
	INNER JOIN AspNetUsers U ON P.UserID = U.Id
WHERE UP.UserID NOT IN (1, 34) --JC/CW
GROUP BY UP.UserID, P.FirstName, P.LastName, U.Email
ORDER BY 5 DESC