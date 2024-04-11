USE trovafit_aspnet
GO

/*
SELECT *
INTO #B
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0 Xml;HDR=YES;Database=c:\t\beta.xlsx',
    'SELECT * FROM [Sheet1$]')

INSERT INTO BetaInvite
SELECT
	InviteName,
	InviteEmail,
	SUBSTRING(CONVERT(varchar(255), REPLACE(NEWID(), '-', '')), 0, 20),
	GETDATE(),
	1
FROM #B


SELECT * FROM BetaInvite


DROP TABLE #B

*/


DECLARE @BetaName varchar(100),
	@InviteEmail varchar(100),
	@InviteCode varchar(20),
	@InviteDate datetime = GETDATE(),
	@CodeValue bit = 1

SET @BetaName = 'Kiet Tran'
SET @InviteEmail = 'aktran@yahoo.com'
SET @InviteCode = SUBSTRING(CONVERT(varchar(255), REPLACE(NEWID(), '-', '')), 0, 20)
DELETE BetaInvite WHERE InviteEmail = @InviteEmail
INSERT INTO BetaInvite (BetaName,InviteEmail, InviteCode, InviteDate, CodeValid) VALUES (@BetaName, @InviteEmail, @InviteCode, @InviteDate, @CodeValue)