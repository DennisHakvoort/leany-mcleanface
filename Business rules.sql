--BUSINESS RULES--

/*
CREATE PROCEDURE sp_VoorbeeldProcedure
@variabele1 CHAR(4),
@variabele2 CHAR(20)
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

GO

CREATE TRIGGER trg_VoorbeeldTrigger
ON voorbeeld_tabel
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
BEGIN TRY
	--iets
END TRY
BEGIN CATCH
	THROW
END CATCH
END
GO

*/




USE LeanDb
GO

--PROCEDURE OM CONSTRAINTS TE DROPPEN ALS DEZE BESTAAN
/*
Deze procedure verwijdert opgegeven constraints van tabellen.
*/
DROP PROCEDURE IF EXISTS sp_DropConstraint
GO
CREATE PROCEDURE sp_DropConstraint
	@Constraint_name VARCHAR(255) = NULL,
	@table_name VARCHAR(255) = NULL
	AS
	BEGIN TRY
		DECLARE @sql NVARCHAR(255)
    SELECT @sql = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + @Constraint_name; /*Zet een query in elkaar om de taak uit te voeren*/
		EXEC sys.sp_executesql @stmt = @sql --statement wordt geëxecute
	END TRY
	BEGIN CATCH
		--Print in plaats van raiserror, om ervoor te zorgen dat het script gewoon doorgaat.
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
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerIngepland
DROP PROCEDURE IF EXISTS sp_invullenBeschikbareDagen
DROP PROCEDURE IF EXISTS sp_checkProjectRechten

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
@wachtwoord VARCHAR(40),
@rol varchar(40)
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
				   WHERE medewerker_code = @medewerker_code)--Gaat na of medewerkercode voorkomt
			THROW 50014, 'Medewerkercode is al in gebruik', 16
		IF (EXISTS(SELECT '!'
                   FROM medewerker_rol_type
                   WHERE medewerker_rol = @rol))
        BEGIN
          INSERT INTO medewerker(medewerker_code, achternaam, voornaam)--Voegt de medewerker toe
            VALUES(@medewerker_code, @achternaam, @voornaam);
          INSERT INTO medewerker_rol
			VALUES (@medewerker_code, @rol)--Geeft meteen rol aan medewerker (mandatory child)

          DECLARE @sql NVARCHAR(255)
          IF EXISTS (SELECT '!'
					 FROM [sys].[server_principals]
					 WHERE [name] = @medewerker_code) --Gaat na of de naam uniek is
            THROW 50013, 'De naam moet uniek zijn.', 16
          ELSE
            BEGIN
			/*
			Hier wordt een login gemaakt voor de nieuwe medewerker. Deze krijgt automatisch de rol 'medewerker', wat voorkomt
			dat medewerkers gegevens kunnen aanpassen. Ze kunnen alleen views inzien.
			*/
            SELECT @sql = 'CREATE LOGIN ' + @medewerker_code + ' WITH PASSWORD ' + '= ''' + @wachtwoord + ''', DEFAULT_DATABASE = LeanDb; '
                          + 'CREATE USER ' + @medewerker_code + ' FROM LOGIN ' + @medewerker_code + '; '
                          + 'ALTER ROLE MEDEWERKER ADD MEMBER ' + @medewerker_code
            EXEC sys.sp_executesql @stmt = @sql
            IF @TranCounter = 0 AND XACT_STATE() = 1
              COMMIT TRANSACTION;
            END
			END
        ELSE
          THROW 50020, 'Dit is geen bestaande rol', 16
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

--BR4 Als een medewerker in een maand geen beschikbare uren ter beschikking heeft kan hij/zij niet diezelfde maand in een project ingedeeld worden
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
			--Onderstaande query gaat na of er sprake is van een gebrek aan beschikbaarheid in de betreffende maand.
		 IF EXISTS (SELECT	'!'
					FROM	medewerker_op_project m
							LEFT OUTER JOIN medewerker_ingepland_project i ON m.ID = i.ID
							LEFT OUTER JOIN medewerker_beschikbaarheid b ON m.medewerker_code = b.medewerker_code
					WHERE	@id = m.id AND (b.beschikbare_dagen = 0 OR b.beschikbare_dagen IS NULL) AND b.maand = @maand_datum)
			BEGIN
				;THROW 50006, 'Medewerker heeft geen beschikbare dagen in deze maand en kan dus niet ingepland worden', 16
			END
		ELSE
			BEGIN
				--Voegt de geplande uren toe
				INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
				VALUES (@id, @medewerker_uren, @maand_datum)
						IF @TranCounter = 0 AND XACT_STATE() = 10
							BEGIN
								COMMIT TRANSACTION;
							END
			END
	END TRY
	BEGIN CATCH
		IF @TranCounter = 0
			BEGIN
				IF XACT_STATE() = 1 ROLLBACK TRANSACTION;
			END;
		ELSE
			BEGIN
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
		EXECUTE sp_checkProjectRechten @projectcode = @project_code
		IF (@medewerker_uren < 0) --Medewerkeruren kunnen niet negatief zijn.
				THROW 500012, 'Invalide invoerwaarde - negatieve uren', 16
	DECLARE @id INT; -- id representeert de combinatie van een medewerker en project. Wordt uit de tabel medewerker_op_project opgehaald.
		SET @id = (SELECT	id
				   FROM		medewerker_op_project
				   WHERE	medewerker_code = @medewerker_code AND
							project_code = @project_code)

		IF EXISTS (	SELECT		1 --Onderstaande query telt het maandelijkse aantal uren op en vergelijkt het met maximum.
					FROM		medewerker_ingepland_project mip
								INNER JOIN medewerker_op_project mop ON mip.id = mop.id
								INNER JOIN project p on mop.project_code = p.project_code
					WHERE		mop.medewerker_code = @medewerker_code AND
								FORMAT(mip.maand_datum, 'yyyy-MM') = FORMAT(GETDATE(), 'yyyy-MM') --format naar yyyy-MM zodat het vergeleken kan worden
					GROUP BY	medewerker_code
					HAVING		SUM(mip.medewerker_uren) + @medewerker_uren <= 184) -- 184 is het maximum aantal uren per maand voor een medewerker
			BEGIN
				--Medewerkeruren worden toegevoegd.
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
GO
--BR7 project(eind_datum) moet na project(begin_datum) vallen.
ALTER TABLE project WITH CHECK
	ADD CONSTRAINT CK_EINDDATUM_NA_BEGINDATUM CHECK (eind_datum > begin_datum)
GO

--BR8 project_categorie(hoofdcategorie) moet een waarde zijn uit de project_categorie(naam) of NULL. Het kan niet naar zichzelf verwijzen.
CREATE TRIGGER trg_SubCategorieHeeftHoofdCategorie
 ON project_categorie
 AFTER INSERT, UPDATE
AS
BEGIN
BEGIN TRY -- dubbele negation
  IF NOT EXISTS ((SELECT	hoofdcategorie --  als een hoofdcategorie wordt geselecteerd is de ingevulde waarde geldig.
				  FROM		inserted -- als één van de twee voorwaardes true resulteert wordt de hoofdcategorie van inserted geselecteerd
				  WHERE		EXISTS (SELECT	naam -- eerste voorwaarde
									FROM	project_categorie
									WHERE	naam = inserted.hoofdcategorie) -- checkt of de opgegeven hoofdcategorie daadwerkelijk bestaat
							OR --tweede voorwaarde
							hoofdcategorie IS NULL)) --als de hoofdcategorie NULL is betekent het dat de categorie een hoofdcategorie is
	THROW 50003, 'Deze subcategorie heeft geen geldige hoofdcategorie', 16 -- wordt gegooid als geen hoofdcategorie wordt geselecteerd uit de eerste select
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
/*
Hieronder wordt bekeken of er categorieën zijn
die de gedeletete categorie(ën) als hoofdcategorie hebben.
Is dit het geval, wordt er een error geworpen.
*/
  IF EXISTS ((SELECT	naam
			  FROM		deleted
			  WHERE		naam IN (SELECT hoofdcategorie
								 FROM	project_categorie)))
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
				--Hier wordt nagegaan of er een project is toegevoegd/aangepast/verwijderd
				--nadat de eind_datum van het project is verstreken. Dit kan niet.
				IF (EXISTS( SELECT '!'
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
	AFTER UPDATE, DELETE
	AS
	BEGIN
		IF (@@ROWCOUNT > 0)
			BEGIN
				--Hier wordt nagekeken of er niks wordt aangepast aan geplande uren van projecten die al verstreken zijn.
				IF (EXISTS(	SELECT	'!'
							FROM	inserted I
									INNER JOIN medewerker_op_project mip ON i.id = mip.id
									INNER JOIN project p on mip.project_code = p.project_code
							WHERE	p.eind_datum < CURRENT_TIMESTAMP)--einde project voor huidige datum/tijd.
					OR
						EXISTS( SELECT	'!'
								FROM	deleted d
										INNER JOIN medewerker_op_project mip ON d.id = mip.id
										INNER JOIN project p on mip.project_code = p.project_code
								WHERE p.eind_datum < CURRENT_TIMESTAMP))
					BEGIN
						;THROW 50004, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					END
			END
	END
GO
--3
CREATE TRIGGER trg_ProjectVerstrekenMedewerker_Op_Project
	ON medewerker_op_project
	AFTER UPDATE, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				/*
				Zorgt ervoor dat er geen medewerkers meer worden toegevoegd aan/verwijderd van een project
				dat is verlopen.
				*/
				IF (EXISTS(	SELECT	'!'
							FROM	inserted i
									INNER JOIN project p ON i.project_code = p.project_code
							WHERE	p.eind_datum < CURRENT_TIMESTAMP) --project-einddatum voor huidige datum
					OR	EXISTS(	SELECT  '!'
								FROM	deleted d
										INNER JOIN project p ON d.project_code = p.project_code
								WHERE	p.eind_datum < CURRENT_TIMESTAMP))
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
			/*
			In onderstaande selectqueries wordt nagegaan of de maand in kwestie
			niet al verstreken is. Dan kan de beschikbaarheid namelijk niet meer worden aangepast,
			en wordt er een error geworpen.
			*/
				IF	(EXISTS(SELECT	'!'
							FROM	inserted i --Right join kan hier omdat pure inserts al in de procedure worden afgevangen.
									RIGHT JOIN deleted d ON i.medewerker_code = d.medewerker_code
							WHERE	i.maand < CURRENT_TIMESTAMP OR --Inserted maand voor huidige datum.
									d.maand < CURRENT_TIMESTAMP)) --Deleted maand voor huidige datum.
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
				/*
				Hier wordt bekeken of bij de gewijzigde waardes sprake is van een planningsmaand die al is verstreken.
				Is dit het geval, wordt error 50011 geworpen.
				*/
				IF	(EXISTS(SELECT	'!'
							FROM	inserted i
							WHERE	FORMAT(i.maand_datum, 'yyyy-MM') < FORMAT(GETDATE(), 'yyyy-MM'))
							--Datums worden omgezet naar hetzelfde formaat en vergeleken met elkaar.
					OR
						EXISTS( SELECT	'!'
								FROM	deleted d
								WHERE	FORMAT(d.maand_datum, 'yyyy-MM')  < FORMAT(GETDATE(), 'yyyy-MM')))
					THROW 50011, 'Medewerker-uren voor een verstreken maand kunnen niet meer aangepast worden.', 16

				/*
				Deze selectqueries achterhalen of het project waar de bettreffende medewerker voor ingepland is,
				niet al voorbij is. Dit wordt bepaald door de eind_datumwaarde te vergelijken met de huidige.
				Is dit het geval, wordt error 50001 geworpen.
				*/
				IF (EXISTS( SELECT	'!'
							FROM	inserted i
									INNER JOIN medewerker_op_project mop ON i.id = mop.id
									INNER JOIN project p ON mop.project_code = p.project_code
							WHERE	eind_datum < CURRENT_TIMESTAMP)
							--Door middel van de joins wordt het juiste project opgehaald, en diens einddatum vergeleken met
							--de huidige einddatum.
				OR (EXISTS(	SELECT '!'
							FROM	deleted d
									INNER JOIN medewerker_op_project mop ON d.id = mop.id
									INNER JOIN project p ON mop.project_code = p.project_code
							WHERE	eind_datum < CURRENT_TIMESTAMP)))
					THROW 50001, 'Een project kan niet meer worden aangepast nadat deze is afgelopen.', 16
			END
	END
GO

-- BR14 De beschikbaarheid van een medewerker kan maar 1x per maand worden opgegeven.
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
		/*
		Onderstaande query wordt gebruikt om te bepalen of er al beschikbaarheid bekend is voor de medewerker in de ingevoerde maand.
		Het is namelijk niet mogelijk om dit opnieuw in te vullen.
		Hier is een speciale aanpasprocedure voor.
		*/
		IF EXISTS  (SELECT	'@'
					FROM	medewerker_beschikbaarheid
					WHERE	medewerker_code = @medewerker_code AND
							FORMAT(maand, 'yyyy-MM') = FORMAT(@maand, 'yyyy-MM')) --Datumformaten gelijkgezet en datums vergeleken.
						THROW 50016, 'Medewerkerbeschikbaarheid is voor de ingevoerde maand al aangegeven', 16;
		/*
		Het is niet mogelijk om met terugwerkende kracht aan te geven hoeveel een medewerker beschikbaar was.
		Onderstaande query achterhaalt of dit het geval is.
		*/
		IF (FORMAT(@maand, 'yyyy-MM') < FORMAT(GETDATE(), 'yyyy-MM'))
						THROW 50017, 'Het is niet mogelijk om medewerkerbeschikbaarheid in te vullen voor een verstreken maand.', 16;

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
		/*
		Onderstaande query gaat na of het betreffende project al is begonnen.
		Als de oude begindatum vóór de huidige datum valt, en dezelfde begindatum niet voorkomt in de insertedtabel
		(en dus is gewijzigd), wordt error 50025 geworpen.
		*/
		IF EXISTS(SELECT	'@'
				  FROM		deleted d
				  WHERE		d.begin_datum < GETDATE() AND --begindatum voor huidige datum
							d.begin_datum NOT IN (SELECT	i.begin_datum --nagaan of begindatum überhaupt is aangepast
												  FROM		inserted i
												  WHERE		i.project_code = d.project_code))
		THROW 50025, 'Begindatum mag niet worden aangepast als het project is gestart.', 16
		/*
		Hier wordt nagegaan of er niet al medewerkers zijn ingepland in de oorspronkelijke beginmaand. Is dit het geval,
		wordt error 50023 geworpen.
		*/
		IF EXISTS(	SELECT	'@'
					FROM	inserted i
							INNER JOIN medewerker_op_project mop ON i.project_code = mop.project_code
							INNER JOIN medewerker_ingepland_project mip ON mop.id = mip.id
					WHERE	FORMAT(i.begin_datum, 'yyyy-MM') < FORMAT(mip.maand_datum, 'yyyy-MM'))

		THROW 50023, 'Begindatum kan niet worden aangepast. Een of meerdere medewerkers zijn al ingepland voor de huidige begindatum.', 16
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

-- BR16 Einddatum voor een project mag alleen verlengd worden.
CREATE TRIGGER trg_UpdateEinddatumAlleenVerlengen
  ON project
  AFTER UPDATE
AS
BEGIN
	BEGIN TRY
	/*
	Onderstaand if-statement bekijkt of het einde van een project wordt vervroegd in plaats van uitgesteld.
	*/
		IF EXISTS(	SELECT	'@'
					FROM	inserted i
							INNER JOIN deleted d ON i.project_code = d.project_code
					WHERE	i.eind_datum < d.eind_datum) --nieuwe datum (inserted) voor oude datum (deleted)

		THROW 50024, 'Nieuwe einddatum valt voor de oude einddatum.', 16

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--BR18 Een project kan alleen worden aangepast door zijn projectleider of de superuser.
CREATE PROCEDURE sp_checkProjectRechten
  @projectcode VARCHAR(40)
 AS
 BEGIN
 /*
 Onderstaande queries gaan na of de databasegebruiker die op dit moment is ingelogd
 het recht heeft om projecten aan te passen.
 */
  IF(EXISTS(SELECT	'!'
            FROM	medewerker_op_project
            WHERE	project_rol = 'Projectleider' AND --rol van de medewerker
					medewerker_code = CURRENT_USER AND --ingelogde user
					project_code = @projectcode) --relevante projectcode
    OR
     EXISTS(SELECT	'!'
            FROM	medewerker_rol
            WHERE	medewerker_rol = 'Superuser' AND
					medewerker_code = CURRENT_USER)
		OR CURRENT_USER = 'dbo'
  )
  RETURN
  ELSE
  THROW 50033, 'De huidige gebruiker heeft de rechten niet om dit project aan te passen', 16;
 END
GO

--BR17 Een medewerker heeft een mandatory child in medewerker_rol
CREATE TRIGGER trg_MandatoryChMedewerkerrol
ON medewerker_rol
AFTER DELETE
AS BEGIN
	IF(@@ROWCOUNT > 0)
		BEGIN
		/*
		Als een medewerkers rol wordt verwijderd terwijl het zijn laatste rol is,
		wordt dit teruggedraaid en error 50032 geworpen.
		*/
			IF EXISTS  (SELECT	'@'
						FROM	deleted d
								RIGHT JOIN medewerker_rol mr ON d.medewerker_code = mr.medewerker_code
						HAVING	COUNT(*) < 1)
				THROW 50032, 'Medewerkerrol kan niet worden verwijderd. Een medewerker moet een rol hebben.', 16
		END
END
GO
