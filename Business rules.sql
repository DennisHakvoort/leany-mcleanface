--BUSINESS RULES--

USE LeanDb
GO

--PROCEDURE OM CONSTRAINTS TE DROPPEN ALS DEZE BESTAAN
GO
CREATE PROCEDURE sp_DropConstraint
	@Constraint_name VARCHAR(255) = NULL,
	@table_name VARCHAR(255) = NULL
	AS
	BEGIN TRY
		declare @sql NVARCHAR(255)
    SELECT @sql = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + @Constraint_name;
		EXEC sys.sp_executesql @stmt = @sql
	END TRY
	BEGIN CATCH
		PRINT 'Het volgende constraint is niet gedropt, waarschijnlijk omdat deze niet bestond: ' + @Constraint_name
	END CATCH
	GO

--DROP ALLE BUSINESS RULES
EXEC sp_DropConstraint @Constraint_name = 'CK_UREN_MIN_MAX', @table_name = 'medewerker_beschikbaarheid'
EXEC sp_DropConstraint @Constraint_name = 'CK_EINDDATUM_NA_BEGINDATUM', @table_name = 'project'
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenProject
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenMedewerker_Ingepland
DROP TRIGGER IF EXISTS trg_SubCategorieHeeftHoofdCategorie
DROP TRIGGER IF EXISTS trg_GeenHoofdCategorieMetSubsVerwijderen
DROP TRIGGER IF EXISTS trg_ProjectVerstrekenMedewerker_Op_Project
DROP PROCEDURE IF EXISTS sp_MedewerkerToevoegen
DROP PROCEDURE IF EXISTS sp_ProjecturenInplannen
DROP PROC  IF EXISTS  sp_MedewerkerNietInplannenAlsNietBeschikbaar


--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)



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

/*BR4 er kan geen record worden opgenomen in medewerker_ingepland_project voor een user die die
maand niet beschikbaar is voor werk (waar medewerker_beschikbaarheid niet bestaat voor die user)*/

GO
CREATE PROC sp_MedewerkerNietInplannenAlsNietBeschikbaar
@ID INT,
@medewerker_Uren INT,
@maand_datum DATETIME
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @entryTrancount INT
	SET @entryTrancount = @@TRANCOUNT
	IF @entryTrancount > 0
		SAVE TRANSACTION procTranTest
	ELSE
		BEGIN TRANSACTION
	BEGIN TRY
		BEGIN
		 IF EXISTS (SELECT *
FROM MEDEWERKER_OP_PROJECT m LEFT OUTER JOIN MEDEWERKER_INGEPLAND_PROJECT i ON m.ID = i.ID
							 LEFT OUTER JOIN MEDEWERKER_BESCHIKBAARHEID b ON m.MEDEWERKER_CODE = b.MEDEWERKER_CODE
WHERE @id = m.ID AND (b.BESCHIKBAAR_UREN = 0 OR b.BESCHIKBAAR_UREN IS NULL))
BEGIN
;THROW 50006, 'Medewerker heeft geen beschikbare uren en kan dus niet ingepland worden', 16
END
INSERT INTO MEDEWERKER_INGEPLAND_PROJECT (id, MEDEWERKER_UREN, MAAND_DATUM)
VALUES (@id, @medewerker_Uren, @maand_datum)
		END
		IF @entryTrancount = 0
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	THROW
	END CATCH
END



-- BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
-- BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184

DROP procedure sp_ProjecturenInplannen
CREATE PROCEDURE sp_ProjecturenInplannen
@medewerker_code CHAR(4),
@project_code CHAR(20),
@medewerker_uren INT,
@maand_datum datetime
AS BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT OFF

	DECLARE @TranCounter INT;
	SET @TranCounter = @@TRANCOUNT;

	IF @TranCounter > 0
		SAVE TRANSACTION ProcedureSave;
	ELSE
		BEGIN TRANSACTION;

	BEGIN TRY
		IF (@medewerker_uren < 0)
			BEGIN
				RAISERROR('Invalide invoerwaarde - negatieve uren', 16, 1)
			END
	DECLARE @id int; -- id representeert de combinatie van een medewerker en project. Wordt uit de tabel medewerker_op_project
		SET @id = (SELECT id
					FROM	medewerker_op_project
					where	medewerker_code = @medewerker_code
						AND	project_code = @project_code)

		IF EXISTS (	SELECT	1
					FROM	medewerker_ingepland_project mip
						INNER JOIN medewerker_op_project mop ON mip.id = mop.id
						INNER JOIN project p on mop.project_code = p.project_code
					WHERE	mop.medewerker_code = @medewerker_code
						AND	FORMAT(mip.maand_datum, 'yyyy-MM') = FORMAT(GETDATE(), 'yyyy-MM') --format naar yyyy-MM zodat het vergeleken kan worden
					GROUP BY medewerker_code
					HAVING	SUM(mip.medewerker_uren) + @medewerker_uren <= 184) -- 184 is het maximum aantal uren per maand voor een medewerker
			BEGIN
				INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
					VALUES	(@id, @medewerker_uren, @maand_datum);
			END
		ELSE
			RAISERROR('Totaal geplande uren van de medewerker is meer dan 184 uur', 16, 1)

		IF @TranCounter = 0 AND XACT_STATE() = 1
			COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
			IF @TranCounter = 0
			BEGIN
				IF XACT_STATE() = 1 ROLLBACK TRANSACTION;
			END;
		ELSE
			BEGIN
				IF XACT_STATE() <> -1 ROLLBACK TRANSACTION ProcedureSave;
			END;
		THROW
	END CATCH
END



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