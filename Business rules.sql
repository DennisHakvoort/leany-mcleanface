--BUSINESS RULES--

USE LeanDb
GO

--PROCEDURE OM CONSTRAINTS TE DROPPEN ALS DEZE BESTAAN
DROP PROCEDURE IF EXISTS sp_DropConstraint
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
DROP TRIGGER IF EXISTS trg_MedewerkerBeschikbaarheidInplannenNaVerlopenMaand
DROP TRIGGER IF EXISTS trg_MedewerkerIngeplandProjectInplannenNaVerlopenMaand
DROP TRIGGER IF EXISTS trg_MandatoryChMedewerkerrol
DROP TRIGGER IF EXISTS trg_UpdateBegindatumValtNaIngeplandMedewerker
DROP TRIGGER IF EXISTS trg_UpdateEinddatumAlleenVerlengen
DROP PROCEDURE IF EXISTS sp_MedewerkerToevoegen
DROP PROCEDURE IF EXISTS sp_ProjecturenInplannen
DROP PROCEDURE IF EXISTS sp_DatabaseUserToevoegen
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerIngepland
DROP PROCEDURE IF EXISTS sp_invullenBeschikbareDagen

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 23 dagen. 23 dagen staan gelijk aan (23*8) 184 uren 
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbare_dagen <= 23 AND beschikbare_dagen >= 0)
GO

--BR3
--medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam,
--de eerste letter van de achternaam en
--een volgnummer dat met één verhoogd wanneer de medewerker code al bestaat.
CREATE PROCEDURE sp_MedewerkerToevoegen
@achternaam NVARCHAR(20),
@voornaam NVARCHAR(20),
@medewerker_code VARCHAR(5),
@wachtwoord VARCHAR(40)
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
		IF EXISTS (SELECT '@'
				FROM medewerker
				WHERE medewerker_code = @medewerker_code)
			THROW 500014, 'Medewerker code is al in gebruik', 16

		INSERT INTO medewerker(medewerker_code, achternaam, voornaam)
			VALUES(@medewerker_code, @achternaam, @voornaam);

		EXEC sp_DatabaseUserToevoegen @login_naam = @medewerker_code, @passwoord = @wachtwoord
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
GO

--BR4 Als een medewerker in een maand geen beschikbare uren ter beschikking heeft kan hij/zij niet hetzelfde maand in een project ingedeeld worden
CREATE PROCEDURE sp_InsertMedewerkerIngepland
@ID INT,
@medewerker_uren INT,
@maand_datum DATETIME
AS
	SET NOCOUNT ON 
	SET XACT_ABORT OFF
	DECLARE @TranCounter INT;
	SET @TranCounter = @@TRANCOUNT;
	IF @TranCounter > 0
		SAVE TRANSACTION ProcedureSave;
	ELSE
		BEGIN TRANSACTION;

	BEGIN TRY
		 IF EXISTS (SELECT *
				FROM MEDEWERKER_OP_PROJECT m LEFT OUTER JOIN MEDEWERKER_INGEPLAND_PROJECT i ON m.ID = i.ID
							     LEFT OUTER JOIN MEDEWERKER_BESCHIKBAARHEID b ON m.MEDEWERKER_CODE = b.MEDEWERKER_CODE
				WHERE @id = m.ID AND (b.beschikbare_dagen = 0 OR b.beschikbare_dagen IS NULL))
			BEGIN
				;THROW 50006, 'Medewerker heeft geen beschikbare uren en kan dus niet ingepland worden', 16
			END
		ELSE
			BEGIN
				INSERT INTO MEDEWERKER_INGEPLAND_PROJECT (id, MEDEWERKER_UREN, MAAND_DATUM)
				VALUES (@id, @medewerker_Uren, @maand_datum)
						IF @TranCounter = 0 AND XACT_STATE() = 10
							BEGIN
								PRINT'COMMITTING'
								COMMIT TRANSACTION;
							END
		END
	END TRY
	BEGIN CATCH
		IF @TranCounter = 0
			BEGIN
				PRINT'ROLLBACK TRANSACTION'
				IF XACT_STATE() = 1 ROLLBACK TRANSACTION;
			END;
		ELSE
			BEGIN
				PRINT'ROLLBACK TRANSACTION PROCEDURESAVE'
				PRINT XACT_STATE()
        IF XACT_STATE() <> -1 ROLLBACK TRANSACTION ProcedureSave;
			END;
		THROW
	END CATCH
GO

-- BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
-- BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184 (184 uur staat gelijk aan 23 dagen (23*8 = 184))
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
			
				THROW 500012, 'Invalide invoerwaarde - negatieve uren', 16
			
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
			THROW 500013, 'Totaal geplande uren van de medewerker is meer dan 184 uur', 16

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

--BR7 project(eind_datum) moet na project(begin_datum) vallen.
ALTER TABLE project WITH CHECK
	ADD CONSTRAINT CK_EINDDATUM_NA_BEGINDATUM CHECK (eind_datum > begin_datum)
GO

--BR8 project_categorie(parent) moet een waarde zijn uit de project_categorie(naam) of NULL. Het kan niet naar zichzelf verwijzen.
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
		THROW 50002, 'Kan geen categorie met met subcategories verwijderen', 16
  END TRY
  BEGIN CATCH
    THROW
  END CATCH
END
GO

-- BR9 De waarden van project(1), medewerker_op_project(2) en medewerker_ingepland_project(3) kunnen niet meer worden aangepast als project(eind_datum) is verstreken
--1
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
GO
--2
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
GO
--3
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
					
						THROW 50005, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					
			END
	END
GO

-- BR10 medewerker_beschikbaarheid kan niet worden aangepast als medewerker_beschikbaarheid(maand) is verstreken
CREATE TRIGGER trg_MedewerkerBeschikbaarheidInplannenNaVerlopenMaand
	ON medewerker_beschikbaarheid
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF	(EXISTS(SELECT '!'
										FROM (inserted I INNER JOIN medewerker_beschikbaarheid mb ON i.maand = mb.maand) INNER JOIN medewerker m ON mb.medewerker_code = m.medewerker_code
										WHERE i.maand < CURRENT_TIMESTAMP)
					OR
						EXISTS(SELECT	'!'
										FROM (deleted D INNER JOIN medewerker_beschikbaarheid mb ON d.maand = mb.maand) INNER JOIN medewerker m ON mb.medewerker_code = m.medewerker_code
										WHERE d.maand < CURRENT_TIMESTAMP))
					
						THROW 50010, 'Verstreken maand kan niet meer aangepast worden.', 16
					
			END
	END
GO

--BR11 medewerker_ingepland_project kan niet meer worden aangepast als medewerker_ingepland_project(maand_datum) is verstreken
CREATE TRIGGER trg_MedewerkerIngeplandProjectInplannenNaVerlopenMaand
ON medewerker_ingepland_project
AFTER UPDATE, INSERT, DELETE
AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF	(EXISTS(SELECT '!'
										FROM (inserted I INNER JOIN medewerker_ingepland_project mip ON i.id = mip.id)
										WHERE FORMAT(i.maand_datum, 'yyyy-MM') < FORMAT(GETDATE(), 'yyyy-MM'))
					OR
						EXISTS(SELECT	'!'
										FROM (deleted D INNER JOIN medewerker_ingepland_project mip ON d.id = mip.id)
										WHERE FORMAT(d.maand_datum, 'yyyy-MM')  < FORMAT(GETDATE(), 'yyyy-MM')))
					
					THROW 50011, 'Medewerker uren voor een verstreken maand kunnen niet meer aangepast worden.', 16
					

				IF (EXISTS(SELECT '!'
									FROM inserted i INNER JOIN medewerker_op_project mop ON i.id = mop.id
										INNER JOIN project p ON mop.project_code = p.project_code
									WHERE eind_datum < CURRENT_TIMESTAMP)
				OR (EXISTS(	SELECT '!'
										FROM deleted d INNER JOIN medewerker_op_project mop ON d.id = mop.id
										INNER JOIN project p ON mop.project_code = p.project_code
										WHERE eind_datum < CURRENT_TIMESTAMP)))
					THROW 50001, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
			END
	END
GO

--BR13 een database login user aanmaken en een rol toewijzen
CREATE PROCEDURE sp_DatabaseUserToevoegen
@login_naam VARCHAR(255),
@wachtwoord VARCHAR(40)
AS
	SET NOCOUNT ON
	SET XACT_ABORT OFF
	DECLARE @TranCounter INT;
	SET @TranCounter = @@TRANCOUNT;
	IF @TranCounter > 0
		SAVE TRANSACTION ProcedureSave;
	ELSE
		BEGIN TRANSACTION;

	BEGIN TRY
		declare @sql NVARCHAR(255)
		IF EXISTS (select '!'
					 FROM [sys].[server_principals]
					 WHERE name = @login_naam)
		THROW 50013, 'De naam moet uniek zijn.', 16

    SELECT @sql = 'CREATE LOGIN ' + @login_naam + ' WITH PASSWORD ' + '= ''' + @wachtwoord + ''''
		PRINT @sql
		EXEC sys.sp_executesql @stmt = @sql
	END TRY
	BEGIN CATCH
		IF @TranCounter = 0
			BEGIN
				PRINT'ROLLBACK TRANSACTION'
				IF XACT_STATE() = 1 ROLLBACK TRANSACTION;
			END;
		ELSE
			BEGIN

				PRINT'ROLLBACK TRANSACTION PROCEDURESAVE'
				PRINT XACT_STATE()
        IF XACT_STATE() <> -1 ROLLBACK TRANSACTION ProcedureSave;
			END;
		THROW
	END CATCH
GO

-- BR14 De beschikbaarheid van een medewerker kan maar 1x per maand opgegeven.
CREATE PROCEDURE sp_invullenBeschikbareDagen
@medewerker_code VARCHAR(5),
@maand DATE,
@beschikbare_dagen INT
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

		IF EXISTS (SELECT '@'
					FROM medewerker_beschikbaarheid
					WHERE medewerker_code = @medewerker_code
					and FORMAT(maand, 'yyyy-MM') = FORMAT(@maand, 'yyyy-MM'))
						THROW 50016, 'Medewerkerbeschikbaarheid is voor de ingevulde maand al ingepland', 16;

		IF (FORMAT(@maand, 'yyyy-MM') < FORMAT(GETDATE(), 'yyyy-MM'))
						THROW 50017, 'U kan geen medewerkerbeschikbaarheid in het verleden opgegeven', 16;

		INSERT INTO medewerker_beschikbaarheid(medewerker_code, maand, beschikbare_dagen)
			VALUES	(@medewerker_code, @maand, @beschikbare_dagen);
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
GO

-- BR15 Begin_datum van een project mag niet worden aangepast als een medewerker is
-- ingepland in dezelfde maand of een medewerker is ingepland voor de nieuwe begin_datum.
CREATE TRIGGER trg_UpdateBegindatumValtNaIngeplandMedewerker
  ON project
  AFTER UPDATE
AS
BEGIN
	BEGIN TRY
	select * from deleted
		IF EXISTS(SELECT '@'
					FROM deleted d
					WHERE d.begin_datum < GETDATE())

		THROW 500025, 'Begindatum mag niet worden aangepast als het project is gestart', 16

		IF EXISTS(SELECT '@'
					FROM inserted i
					INNER JOIN medewerker_op_project mop ON i.project_code = mop.project_code
					INNER JOIN medewerker_ingepland_project mip ON mop.id = mip.id
					WHERE FORMAT(i.begin_datum, 'yyyy-MM') < FORMAT(mip.maand_datum, 'yyyy-MM'))

		THROW 50023, 'Begindatum kan niet worden aangepast. Een medewerker is al ingepland voor de begindatum.', 16
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

-- BR16 Einddatum voor een project mag alleen verlengt worden.
CREATE TRIGGER trg_UpdateEinddatumAlleenVerlengen
  ON project
  AFTER UPDATE
AS
BEGIN
	BEGIN TRY
		IF EXISTS(SELECT '@'
					FROM inserted i
					INNER JOIN deleted d ON i.project_code = d.project_code
					WHERE i.eind_datum < d.eind_datum)

		THROW 50024, 'Nieuwe einddatum valt voor de oude einddatum.', 16

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--BR17 Een medewerker heeft een mandatory child in medewerker_rol
CREATE TRIGGER trg_MandatoryChMedewerkerrol
ON medewerker_rol
AFTER DELETE
AS BEGIN	
	IF(@@ROWCOUNT > 0)
		BEGIN
			IF EXISTS (SELECT '@'
						FROM deleted d RIGHT JOIN medewerker_rol mr
							ON d.medewerker_code = mr.medewerker_code
						HAVING COUNT(*) < 1)
				THROW 50032, 'Medewerkerrol kan niet worden verwijderd. Een medewerker moet een rol hebben.', 16
		END
END
GO
