SELECT 
	A.ActivityName,
	A.ActivityDate,
    V.ActivityID,
    V.UserID,
	U.FirstName + ' ' + U.LastName AS UserName,
	COUNT(V.UserID) AS UserCount
  FROM trovafit_aspnet.dbo.ActivityView V
	LEFT OUTER JOIN UserProfile U ON V.UserID = U.UserID
	INNER JOIN Activity A ON V.ActivityID = A.ActivityID
GROUP BY 
    A.ActivityName,
	A.ActivityDate,
	V.ActivityID,
    V.UserID,
	U.FirstName + ' ' + U.LastName
ORDER BY 2 DESC