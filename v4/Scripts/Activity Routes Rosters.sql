SELECT
	A.ActivityID,
	A.ActivityDate,
	A.ActivityName,
	A.RosterGroupTypeID,
	RGT.RosterGroupTypeName,
	ARG.GroupName,
	ARG.GroupDescription,
	ARG.ActivityRouteID,
	R.RouteName,
	AR.CreatedBy,
	RT.ResponseTypeName,
	RT.ResponseColor
FROM Activity A
	LEFT OUTER JOIN ActivityRosterGroup ARG ON A.ActivityID = ARG.ActivityID
	LEFT OUTER JOIN RosterGroupType RGT ON A.RosterGroupTypeID = RGT.RosterGroupTypeID
	LEFT OUTER JOIN ActivityRoster AR ON ARG.ActivityRosterGroupID = AR.ActivityRosterGroupID
	LEFT OUTER JOIN ResponseType RT ON AR.ResponseTypeID = RT.ResponseTypeID
	LEFT OUTER JOIN ActivityRoute R ON ARG.ActivityRouteID = R.ActivityRouteID

