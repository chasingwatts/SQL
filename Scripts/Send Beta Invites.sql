DECLARE
  @email VARCHAR(64),
  @name VARCHAR(64),
  @invitecode varchar(20),
  @emailSubject varchar(100),
  @emailBody varchar(max)

  DECLARE c1 CURSOR FOR 
    SELECT LOWER(InviteEmail), BetaName, InviteCode FROM BetaInvite WHERE CodeValid = 1 AND BetaInviteID = 27

  OPEN c1
  FETCH NEXT FROM c1 INTO @email, @name, @invitecode
  WHILE @@FETCH_STATUS <> -1
    BEGIN
    SELECT 
      @emailSubject = 'Chasing Watts - Welcome to the beta program',
      @emailBody = 'Hey ' + @name + '!' + CHAR(10) + CHAR(13) + 
		'Thanks for your interest in Chasing Watts!  We''re excited to have you in the beta program.' + CHAR(10) + CHAR(13) +
		'As a friendly reminder, this is pre-release software and a work in progress - there will be bugs! :)  That''s why you are here, we need help finding and squashing them!' + CHAR(10) + CHAR(13) +
		'A few notes on the current state of the site:'  + CHAR(10) +
		'-- Most pages/screens are responsive on a mobile device; however, if you''re using your phone and the page is wonking go ahead and let us know either way.'  + CHAR(10) +
		'-- Route integration is setup with Strava and Ride with GPS.  You will have to authenticate with those sites in order to pull your routes into Chasing Watts.'  + CHAR(10) +
		'-- All pages should load correclty on all browsers (IE, Chrome, Firefox, Safari), but again if you submit a bug, please let us know which browser you''re using!'  + CHAR(10) +
		'We''ll work to keep this group aware of the updates and changes regularly!' + CHAR(10) + CHAR(13) + 
		'Once registered and in the site, if (or when) you come across an error or you have a feature request, please send a detail email to help@chasingwatts.com.' + CHAR(10) +
		'It will then be logged where we can review, prioritize and address accordingly.' + CHAR(10) + CHAR(13) +
		'OK...to get registered on the site, head over to https://chasingwatts.com/account/register.' + CHAR(10) + 
		'Please use the following details to register.  (Note this is a one-time use code and tied to your email address.)' + CHAR(10) + CHAR(13) +
		'Email: ' + @email  + CHAR(10) +
		'Invite Code: ' + @invitecode  + CHAR(10) + CHAR(13) + 
		'Again, if you have any questions or issues, please email help@chasingwatts.com and we''ll get back to you as quickly as possible.' + CHAR(10) + CHAR(13) +
		'Thanks again your time and support!' + CHAR(10) + CHAR(13)

      EXEC msdb.dbo.sp_send_dbmail 
		@profile_Name ='ChasingWatts',
		@recipients= @email,
		@blind_copy_recipients = 'jason@codianne.com',
		@subject = @emailSubject,
		@body = @emailBody

    FETCH NEXT FROM c1 INTO @email, @name, @invitecode
    END
  CLOSE c1
  DEALLOCATE c1