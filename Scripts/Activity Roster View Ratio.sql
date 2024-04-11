SELECT
	A.ActivityID,
	A.ActivityName,
	A.ActivityDate,
	ISNULL(R.RosterCount, 0) AS YesCount,
	ISNULL(V.ActivityView, 0) AS ViewCount,
	CASE WHEN ISNULL(V.ActivityView, 0) > 0 THEN (CONVERT(float, ISNULL(R.RosterCount, 0))/CONVERT(float, ISNULL(V.ActivityView, 0)))*100 ELSE 0 END AS YesRatio
FROM Activity A 
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(UserID) AS RosterCount FROM ActivityRoster WHERE ResponseTypeID = 1 GROUP BY ActivityID -- yes only
	) R ON R.ActivityID = A.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityID) AS ActivityView FROM ActivityView GROUP BY ActivityID
	) V ON V.ActivityID = A.ActivityID
ORDER BY 6 DESC
