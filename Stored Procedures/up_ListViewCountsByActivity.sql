USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_ListViewCountsByActivity
GO

CREATE PROCEDURE dbo.up_ListViewCountsByActivity
	@ActivityID int
AS
/******************************************************************************
*  DBA Script: up_ListViewCountsByActivity
*  Created By: Jason Codianne 
*  Created:    05/25/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_ListViewCountsByActivity 1143
  
-- ============================================================================
SET NOCOUNT ON

SELECT ActivityID, COUNT(ActivityID) AS ViewCount FROM ActivityView WHERE ActivityID = @ActivityID GROUP BY ActivityID
