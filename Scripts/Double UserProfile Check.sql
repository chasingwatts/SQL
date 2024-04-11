USE [trovafit_aspnet]
GO
/******************************************************************************
*  Script Name:  	Double UserProfile Check
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2021-02-02
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example

  
-- ============================================================================

SELECT UserID, COUNT(UserProfileID) AS UserCount FROM UserProfile GROUP BY UserID HAVING COUNT(UserProfileID) > 1

