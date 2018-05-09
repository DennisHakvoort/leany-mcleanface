--BUSINESS RULES--
USE LeanDb
GO

--BR3
--medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam, 
--de eerste letter van de achternaam en 
--een volgnummer dat met één verhoogd wanneer de medewerker code al bestaat.

DROP PROCEDURE sp_MedewerkerToevoegen
GO
CREATE PROCEDURE sp_MedewerkerToevoegen
					@achternaam CHAR(20), @voornaam CHAR(20)
AS
BEGIN
BEGIN TRY
DECLARE @v CHAR(1), @a CHAR(1), @volgnummer INT, @code CHAR(4)

--@v is de eerste letter van de voornaam, @a is de eerste letter van de achternaam
SET @v = (SELECT SUBSTRING(@voornaam, 1, 1))
SET @a = (SELECT SUBSTRING(@achternaam, 1, 1))
SET @volgnummer = (SELECT		COUNT(medewerker_code)
				   FROM			medewerker m
				   WHERE		SUBSTRING(m.medewerker_code, 1, 2) = @v + @a
				   GROUP BY		SUBSTRING(m.medewerker_code, 1, 2))

IF(@volgnummer > 0)
BEGIN
	SET @code = @v + @a + (CAST (@volgnummer AS CHAR))
END
ELSE
BEGIN
	SET @code = @v + @a
END

INSERT INTO medewerker(medewerker_code, achternaam, voornaam)
VALUES(@code, @achternaam, @voornaam)

END TRY
BEGIN CATCH
DECLARE @ERROR_MESSAGE NVARCHAR(4000), @ERROR_SEVERITY INT, @ERROR_STATE INT

SELECT @ERROR_MESSAGE = ERROR_MESSAGE(),
	   @ERROR_SEVERITY = ERROR_SEVERITY(),
	   @ERROR_STATE = ERROR_STATE()

RAISERROR (@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATE )
END CATCH
END
GO

EXEC sp_MedewerkerToevoegen 'Zwart', 'Jan Pieter'
EXEC sp_MedewerkerToevoegen 'Zweers', 'Johan'
EXEC sp_MedewerkerToevoegen 'Zweers', 'Jan'