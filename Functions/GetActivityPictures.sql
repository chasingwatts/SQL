USE [trovafit_aspnet]
GO

DROP FUNCTION IF EXISTS dbo.GetActivityPictures
GO 

CREATE FUNCTION dbo.GetActivityPictures
(
	@ActivityID int
)
RETURNS varchar(500)
AS
/******************************************************************************
*  Script Name:  	GetActivityPictures
*  Created By:  	PETERMAN\Jason 
*  Created Date:  	2022-02-09
*  Schema:  		dbo
*  Purpose:			
*  Updates:			
******************************************************************************/
-- ============================================================================
-- Testing Parms/Example
-- SELECT PicList = dbo.GetActivityPictures(34903) 
  
-- ============================================================================

BEGIN

DECLARE @Pics VARCHAR(MAX)  

--<div class="carousel-item active"><img src="..." class="d-block w-100" alt="..."></div>
SELECT @Pics = COALESCE(@Pics, '') + 
	CASE WHEN PATINDEX('%active%', @Pics) = 0 
		THEN '<div class="carousel-item active"><img src="' 
		ELSE '<div class="carousel-item"><img src="' 
	END + 
	PicturePath + '" class="d-block w-100" style="height: 350px; object-fit: cover;" alt="chasing watts map" /></div>' 
FROM ActivityPicture 
WHERE ActivityID = @ActivityID 
ORDER BY IsMap DESC

RETURN CASE WHEN CHARINDEX('active', @Pics) = 0 THEN REPLACE(@Pics, 'carousel-item', 'carousel-item active') ELSE @Pics END

--SELECT @Pics = COALESCE(@Pics, '') + '<img src="' + PicturePath + '" style="height: 350px; object-fit: cover;" />' FROM ActivityPicture WHERE ActivityID = @ActivityID ORDER BY IsMap
--RETURN @Pics

END
GO
