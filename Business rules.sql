--BUSINESS RULES--

USE LeanDb
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

--DROP ALLE BUSINESS RULES
EXEC SP_DROP_CONSTRAINT @Constraint_name = 'CK_UREN_MIN_MAX', @tablename = 'medewerker_beschikbaarheid'
EXEC SP_DROP_CONSTRAINT @Constraint_name = 'CK_EINDDATUM_NA_BEGINDATUM', @tablename = 'project'
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenProject
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenMedewerker_Ingepland
DROP TRIGGER IF EXISTS trg_SubCategorieHeeftHoofdCategorie
DROP TRIGGER IF EXISTS trg_GeenHoofdCategorieMetSubsVerwijderen
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenMedewerker_Op_Project
DROP PROCEDURE IF EXISTS sp_MedewerkerToevoegen


--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)



--BR3
--medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam,
--de eerste letter van de achternaam en
--een volgnummer dat met ��n verhoogd wanneer de medewerker code al bestaat.
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



--BR7 project(eind_datum) moet na project(begin_datum) vallen
ALTER TABLE project WITH CHECK
	ADD CONSTRAINT CK_EINDDATUM_NA_BEGINDATUM CHECK (eind_datum > begin_datum)



/*BR8 project_categorie(parent) moet een waarde zijn
uit de project_categorie(naam) of NULL. Het kan niet naar zichzelf verwijzen.*/
CREATE TRIGGER trg_SubCategorieHeeftHoofdCategorie
  ON project_categorie
  AFTER INSERT, UPDATE
AS
BEGIN
BEGIN TRY
  IF NOT EXISTS ((SELECT parent
			  FROM inserted
			  WHERE EXISTS (SELECT naam
							   FROM PROJECT_CATEGORIE
							   WHERE naam = inserted.PARENT
							   )
							   OR parent IS NULL
							   ))
	THROW 50003, 'Deze subcategorie heeft geen geldige hoofdcategorie', 16
  END TRY
  BEGIN CATCH
    THROW
  END CATCH
END
GO

CREATE TRIGGER trg_GeenHoofdCategorieMetSubsVerwijderen
  ON project_categorie
  AFTER DELETE
AS
BEGIN
BEGIN TRY
  IF EXISTS ((SELECT naam
			 FROM deleted
			 WHERE parent IS NULL AND naam IN (SELECT parent
											  FROM project_categorie
											  )))
		THROW 50002, 'Kan geen categorie met met subcategori�n verwijderen', 16
  END TRY
  BEGIN CATCH
    THROW
  END CATCH
END
GO



-- BR9 De waarden van project, medewerker op project en medewerker_ingepland_project
-- kunnen niet meer worden aangepast als project(eind_datum) is verstreken,

CREATE TRIGGER trg_ProjectVerstrekenProject
	ON project
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(SELECT '!'
									FROM inserted
									WHERE eind_datum < CURRENT_TIMESTAMP)
				OR (EXISTS(	SELECT '!'
										FROM deleted
										WHERE eind_datum < CURRENT_TIMESTAMP)))
				THROW 50001, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
			END
	END

CREATE TRIGGER trg_ProjectVerstrekenMedewerker_Ingepland
	ON medewerker_ingepland_project
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		IF (@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(	SELECT '!'
										FROM (inserted I INNER JOIN medewerker_op_project MIP ON I.id = MIP.id) INNER JOIN project P on MIP.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP)
					OR
						EXISTS( SELECT '!'
										FROM (deleted D INNER JOIN medewerker_op_project MIP ON D.id = MIP.id) INNER JOIN project P on MIP.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP))
					BEGIN
						THROW 50004, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					END
			END
	END

CREATE TRIGGER trg_ProjectVerstrekenMedewerker_Op_Project
	ON medewerker_op_project
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(	SELECT '!'
										FROM inserted I INNER JOIN PROJECT P ON I.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP)
					OR
						EXISTS(	SELECT  '!'
										FROM deleted D INNER JOIN PROJECT P ON D.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP))
					BEGIN
						THROW 50005, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					END
			END
	END