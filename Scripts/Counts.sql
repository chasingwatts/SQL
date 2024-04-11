SELECT 
	COUNT(UserID) AS UserCount, 
	CONVERT(varchar, CreatedDate, 101) AS CreatedDate
FROM userprofile
GROUP BY CONVERT(varchar, CreatedDate, 101)


SELECT
	A.UserID,
	U.FirstName,
	U.LastName,
	COUNT(A.ActivityID) AS ActivityCount
FROM Activity A
	INNER JOIN UserProfile U ON A.UserID = U.UserID
GROUP BY A.UserID,
	U.FirstName,
	U.LastName
ORDER BY 4 DESC