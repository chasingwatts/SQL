USE [trovafit_aspnet]
GO

DECLARE @IsPromoted bit
DECLARE @ActivityID int

SET @IsPromoted = 1
SET @ActivityID = 1894

UPDATE Activity SET IsPromoted = @IsPromoted WHERE ActivityID = @ActivityID


--SELECT * FROM Activity ORDER BY 1 DESC 