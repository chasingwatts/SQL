SELECT 
	A.ActivityID,
	A.ActivityName,
	A.ActivityDate,
	YEAR(A.ActivityDate) AS ActivityYear,
	MONTH(A.ActivityDate) AS ActivityMonth,
	A.StartLocation,
	A.Distance,
	SR.SpeedRangeLow,
	SR.SpeedRangeHigh,
	T.ActivityTypeName,
	ISNULL(R.RosterCount, 0) AS RosterCount,
	ISNULL(V.ViewCount, 0) AS ViewCount
FROM Activity A
	INNER JOIN ActivityType T ON A.ActivityTypeID = T.ActivityTypeID
	INNER JOIN SpeedRange SR ON A.SpeedRangeID = SR.SpeedRangeID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityRosterID) AS RosterCount
		FROM ActivityRoster
		GROUP BY ActivityID
	) R ON A.ActivityID = R.ActivityID
	LEFT OUTER JOIN (
		SELECT ActivityID, COUNT(ActivityViewID) AS ViewCount
		FROM ActivityView
		GROUP BY ActivityID
	) V ON A.ActivityID = V.ActivityID
ORDER BY 3 DESC