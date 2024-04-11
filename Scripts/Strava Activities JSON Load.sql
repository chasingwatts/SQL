--SELECT * FROM  StravaActivities

--TRUNCATE TABLE StravaActivities

DECLARE @StravaActivities VARCHAR(MAX)
 
SELECT @StravaActivities = BulkColumn FROM OPENROWSET(BULK'C:\t\stravaacts.json', SINGLE_BLOB) JSON;
 
--SELECT @StravaActivities as SingleRow_Column

INSERT INTO StravaActivities
SELECT [resource_state]
      ,[athleteid]
      ,[athleteresource_state]
      ,[name]
      ,[distance] / 1610.3 AS distance
      ,[moving_time]
      ,[elapsed_time]
      ,[total_elevation_gain]
      ,[type]
      ,[workout_type]
      ,[id]
      ,[external_id]
      ,[upload_id]
      ,CONVERT(datetime, REPLACE(REPLACE([start_date], 'T', ' '), 'Z', ' ')) AS [start_date]
      ,CONVERT(datetime, REPLACE(REPLACE([start_date_local], 'T', ' '), 'Z', ' ')) AS [start_date_local]
      ,[timezone]
      ,[utc_offset]
      ,[start_latlng]
      ,[end_latlng]
      ,[location_city]
      ,[location_state]
      ,[location_country]
      ,ISNULL([start_latitude], 29.50) AS start_latitude
      ,ISNULL([start_longitude], -95.54) AS start_longitude
      ,[achievement_count]
      ,[kudos_count]
      ,[comment_count]
      ,[athlete_count]
      ,[photo_count]
      ,[mapid]
      ,[mapsummary_polyline]
      ,[mapresource_state]
      ,[trainer]
      ,[commute]
      ,[manual]
      ,[private]
      ,[flagged]
      ,[gear_id]
      ,[from_accepted_tag]
      ,[average_speed]
      ,[max_speed]
      ,[average_cadence]
      ,[average_temp]
      ,[average_watts]
      ,[weighted_average_watts]
      ,[kilojoules]
      ,[device_watts]
      ,[has_heartrate]
      ,[average_heartrate]
      ,[max_heartrate]
      ,[max_watts]
      ,[elev_high]
      ,[elev_low]
      ,[pr_count]
      ,[total_photo_count]
      ,[has_kudoed]
      ,[suffer_score]
      ,[start_latlng0]
      ,[start_latlng1]
      ,[end_latlng0]
      ,[end_latlng1]
FROM (
SELECT * FROM OPENJSON(@StravaActivities)
WITH (
	[resource_state] int,
	[athleteid] int,
	[athleteresource_state] bit,
	[name] varchar(35),
	[distance] numeric(7, 1),
	[moving_time] int,
	[elapsed_time] int,
	[total_elevation_gain] int,
	[type] varchar(4),
	[workout_type] int,
	[id] int,
	[external_id] varchar(48),
	[upload_id] int,
	[start_date] varchar(20),
	[start_date_local] varchar(20),
	[timezone] varchar(27),
	[utc_offset] int,
	[start_latlng] varchar(30),
	[end_latlng] varchar(30),
	[location_city] varchar(13),
	[location_state] varchar(2),
	[location_country] varchar(13),
	[start_latitude] numeric(5, 2),
	[start_longitude] numeric(6, 2),
	[achievement_count] int,
	[kudos_count] int,
	[comment_count] int,
	[athlete_count] int,
	[photo_count] bit,
	[mapid] varchar(11),
	[mapsummary_polyline] varchar(711),
	[mapresource_state] int,
	[trainer] varchar(5),
	[commute] varchar(5),
	[manual] varchar(5),
	[private] varchar(5),
	[flagged] varchar(5),
	[gear_id] varchar(8),
	[from_accepted_tag] varchar(5),
	[average_speed] numeric(5, 3),
	[max_speed] numeric(4, 1),
	[average_cadence] numeric(4, 1),
	[average_temp] int,
	[average_watts] numeric(5, 1),
	[weighted_average_watts] int,
	[kilojoules] numeric(6, 1),
	[device_watts] varchar(4),
	[has_heartrate] varchar(4),
	[average_heartrate] numeric(5, 1),
	[max_heartrate] int,
	[max_watts] int,
	[elev_high] numeric(5, 1),
	[elev_low] numeric(5, 1),
	[pr_count] int,
	[total_photo_count] bit,
	[has_kudoed] varchar(5),
	[suffer_score] int,
	[start_latlng0] numeric(5, 2),
	[start_latlng1] numeric(6, 2),
	[end_latlng0] numeric(5, 2),
	[end_latlng1] numeric(6, 2)
) AS Activities) X