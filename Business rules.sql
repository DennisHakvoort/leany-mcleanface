--BUSINESS RULES--
USE LeanDb
GO

--BR3
--medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam, 
--de eerste letter van de achternaam en 
--een volgnummer dat met één verhoogd wanneer de medewerker code al bestaat.

select * from medewerker
CREATE PROCEDURE sp_MedewerkerToevoegen
					@achternaam CHAR(20), @voornaam CHAR(20)
AS
BEGIN
BEGIN TRY

END TRY
BEGIN CATCH
DECLARE @ERROR_MESSAGE NVARCHAR(4000), @ERROR_SEVERITY INT, @ERROR_STATE INT

SELECT @ERROR_MESSAGE = ERROR_MESSAGE(),
	   @ERROR_SEVERITY = ERROR_SEVERITY(),
	   @ERROR_STATE = ERROR_STATE()

RAISERROR (@ERROR_MESSAGE, @ERROR_SEVERITY, @ERROR_STATE )
END CATCH
END
