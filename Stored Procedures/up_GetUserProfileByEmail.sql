USE [trovafit_aspnet]
GO

DROP PROCEDURE dbo.up_GetUserProfileByEmail
GO

CREATE PROCEDURE dbo.up_GetUserProfileByEmail
	@Email varchar(256)
AS
/******************************************************************************
*  DBA Script: up_GetUserProfileByEmail
*  Created By: Jason Codianne 
*  Created:    09/16/2018 
*  Schema:     dbo
*  Purpose:    
******************************************************************************/
-- ============================================================================
-- Testing Parms
-- EXEC up_GetUserProfileByEmail 'jason@codianne.com'
  
-- ============================================================================
SET NOCOUNT ON

SELECT
	U.UserProfileID, 
	U.UserID, 
	U.FirstName, 
	U.LastName, 
	U.DisplayName, 
	U.BirthdayMonth, 
	U.BirthdayDay, 
	U.BirthdayYear, 
	U.Gender, 
	U.HomeBaseZip, 
	U.HomeBaseLat, 
	U.HomeBaseLng, 
	U.HomeBaseCity,
	U.HomeBaseState,
	U.HomeBaseCountry,
	U.UnitOfMeasureID, 
	ISNULL(U.DefaultRadius, 50) AS DefaultRadius,
	U.Instagram, 
	U.Twitter, 
	U.RWGPSAuthKey, 
	U.RWGPSUserID, 
	StravaAuthKey = S.AuthToken, 
	StravaUserID = S.StravaUserID, 
	GarminRequestToken = G.RequestToken,
	GarminTokenSecret = G.TokenSecret,
	U.Private, 
	U.ICEContact,
	U.ICEPhone,
	U.CreatedBy, 
	U.CreatedDate, 
	U.ModifiedBy, 
	U.ModifiedDate
FROM UserProfile U	
	INNER JOIN AspNetUsers A ON U.UserID = A.Id
	LEFT OUTER JOIN StravaUserToken S ON U.UserID = S.UserID
	LEFT OUTER JOIN GarminUserToken G ON U.UserID = G.UserID
WHERE A.Email = @Email