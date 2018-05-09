<<<<<<< HEAD
--BUSINESS RULES--
USE LeanDb
GO

--BR3
--medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam, 
--de eerste letter van de achternaam en 
--een volgnummer dat met één verhoogd wanneer de medewerker code al bestaat.
GO
CREATE PROCEDURE sp_MedewerkerToevoegen
					@achternaam CHAR(20), @voornaam CHAR(20)
AS
BEGIN
BEGIN TRY
DECLARE @va CHAR(2), @volgnummer INT, @code CHAR(4)

--@va zijn de initialen (voor- en achternaam)
SET @va = (SELECT SUBSTRING(@voornaam, 1, 1)) + (SELECT SUBSTRING(@achternaam, 1, 1))
SET @volgnummer = (SELECT		COUNT(medewerker_code)
				   FROM			medewerker m
				   WHERE		SUBSTRING(m.medewerker_code, 1, 2) = @va
				   GROUP BY		SUBSTRING(m.medewerker_code, 1, 2))

IF(@volgnummer > 0)
BEGIN
	SET @code = @va + (CAST(@volgnummer AS CHAR))
END
ELSE
BEGIN
	SET @code = @va
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

--PROCEDURE OM CONSTRAINTS TE DROPPEN ALS DEZE BESTAAN
GO
CREATE PROCEDURE SP_DROP_CONSTRAINT
	@Constraint_name VARCHAR(255) = NULL,
	@tablename VARCHAR(255) = NULL
	AS
	BEGIN TRY
		declare @sql NVARCHAR(255)
    SELECT @sql = 'ALTER TABLE ' + @tablename + ' DROP CONSTRAINT ' + @Constraint_name;
		EXEC sys.sp_executesql @stmt = @sql
	END TRY
	BEGIN CATCH
		PRINT 'Het volgende constraint is niet gedropt, waarschijnlijk omdat deze niet bestond: ' + @Constraint_name
	END CATCH
	GO

--DROP ALL BUSINESS RULES
EXEC SP_DROP_CONSTRAINT @Constraint_name = 'CK_UREN_MIN_MAX', @tablename = 'medewerker_beschikbaarheid'


--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)
