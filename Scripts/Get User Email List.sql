USE [trovafit_aspnet]
GO

SELECT
	U.Email,
	ISNULL(P.FirstName, '') AS FirstName,
	ISNULL(P.LastName, '') AS LastName,
	CONVERT(varchar, ISNULL(P.CreatedDate, GETDATE()), 101) AS JoinDate,
	ISNULL(P.UserID, 0) AS UserID
FROM AspNetUsers U 
	LEFT OUTER JOIN UserProfile P ON U.Id = P.UserID 
	LEFT OUTER JOIN UserNotification N ON P.UserID = N.UserID 
WHERE ISNULL(N.AdminNoteEmail, 1) <> 0
UNION
SELECT 'alison@luccacyclingclub.com', 'Alison', 'T', GETDATE(), 0
ORDER BY JoinDate