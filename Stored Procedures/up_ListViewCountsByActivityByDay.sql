USE [trovafit_aspnet]
GO

DROP PROCEDURE IF EXISTS dbo.up_ListViewCountsByActivityByDay
GO

CREATE PROCEDURE dbo.up_ListViewCountsByActivityByDay
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListViewCountsByActivityByDay
*  Created By: Jason Codianne 
*  Created:    05/25/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListViewCountsByActivityByDay 34902
  
-- ============================================================================
SET NOCOUNT ON

SELECT ROW_NUMBER() OVER(ORDER BY CONVERT(date, V.UpdateDate)) AS ViewID, V.ActivityID, CONVERT(date, V.UpdateDate) AS ViewDate, COUNT(V.ActivityID) AS ViewCount 
FROM ActivityView V
WHERE V.ActivityID = @ActivityID 
GROUP BY V.ActivityID, CONVERT(date, V.UpdateDate)
