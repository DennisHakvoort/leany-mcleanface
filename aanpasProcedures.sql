/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     05-06-2018 10:51:54                               */
/*==================================================================*/

/* Stored procedures voor wijzigingen in tabellen voor database LeanDb */

USE LeanDb
GO

DROP PROCEDURE IF EXISTS sp_WijzigProjectCategorie
DROP PROCEDURE IF EXISTS sp_WijzigProjectRol
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerBeschikbareDagen
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerRol
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerOpProject
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerIngeplandProject
DROP PROCEDURE IF EXISTS sp_WijzigMedewerker
DROP PROCEDURE IF EXISTS sp_WijzigProject
DROP PROCEDURE IF EXISTS sp_AanpassenProjectlidOpSubproject
DROP PROCEDURE IF EXISTS sp_WijzigSubproject
DROP PROCEDURE IF EXISTS sp_WijzigCategorieTag
DROP PROCEDURE IF EXISTS sp_WijzigTagVanCategorie
GO

--SP 5 aanpassen projectcategorieën
/*
Aan deze SP wordt de huidige naam van de aan te passen categorie meegegeven,
de nieuwe naam ervan en eventueel de nieuwe hoofdcategorie.
*/
CREATE PROCEDURE sp_WijzigProjectCategorie
@naamOud   VARCHAR(40),
@naamNieuw VARCHAR(40),
@hoofdcategorieNieuw VARCHAR(40)
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
		IF NOT EXISTS (SELECT naam
				       FROM project_categorie
				       WHERE naam = @naamOud)
			--Als de opgegeven naam niet bestaat, wordt hier een error geworpen.
			THROW 50009, 'Deze projectcategorie bestaat niet.', 16;

		UPDATE project_categorie --Hier wordt de projectcategorie geüpdatet.
		SET naam = @naamNieuw, hoofdcategorie = @hoofdcategorieNieuw
		WHERE naam = @naamOud;

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
GO

--SP 4 aanpassen project_rol_type
/*
Deze SP is voor het aanpassen van mogelijke projectrollen. De oude naam wordt opgegeven,
en de naam waarmee die vervangen wordt.
*/
CREATE PROCEDURE sp_WijzigProjectRol
@project_rol_oud    VARCHAR(40),
@project_rol_nieuw  VARCHAR(40)
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

  	IF NOT EXISTS (SELECT project_rol
				   FROM project_rol_type
				   WHERE	 project_rol = @project_rol_oud)
		--Hierboven wordt de oude projectnaam opgevraagd.
		--Bestaat deze niet, wordt een error geworpen.
		THROW 50013, 'Deze projectrol bestaat niet.', 16;

	UPDATE project_rol_type --Hier wordt het projectroltype gewijzigd.
	SET project_rol = @project_rol_nieuw
	WHERE project_rol = @project_rol_oud;

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
  GO

--SP 12 aanpassen medewerker_rol_type
/*
In deze procedure kunnen mogelijke medewerkerrollen worden aangepast.
De oude en de nieuwe rolnaam worden allebei opgegeven.
*/
CREATE PROCEDURE sp_WijzigMedewerkerRolType
@medewerker_Rol_Oud   VARCHAR(40),
@medewerker_Rol_Nieuw VARCHAR(40)
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
		IF NOT EXISTS (SELECT medewerker_rol
				   FROM medewerker_rol_type
				   WHERE medewerker_rol = @medewerker_Rol_Oud)
		--Als het opgegeven type niet bestaat, wordt een error geworpen.
		THROW 50008, 'Deze medewerkerrol bestaat niet.', 16;

	UPDATE medewerker_rol_type --Hier wordt het roltype aangepast.
	SET medewerker_rol = @medewerker_Rol_Nieuw
	WHERE medewerker_rol = @medewerker_Rol_Oud;

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
GO

--SP 10 aanpassen medewerker_Beschikbaarheid
/*
In deze SP kan de opgegeven beschikbaarheid van een medewerker worden aangepast.
Hiervoor zijn de medewerkercode, de maand in kwestie en het nieuwe aantal beschikbare dagen nodig.
*/
CREATE PROCEDURE sp_WijzigMedewerkerBeschikbareDagen
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

		IF NOT EXISTS (SELECT '@'
						FROM medewerker_beschikbaarheid
						WHERE medewerker_code = @medewerker_code and (FORMAT(maand, 'yyyy-MM')) = (FORMAT(@maand, 'yyyy-MM')))
			--Hier wordt gecontroleerd of er voor de betreffende medewerker-maand-combinatie wat is ingevuld.
			THROW 50019, 'Deze medewerker heeft geen beschikbare werkdagen voor de opgegeven maand.', 16;

		UPDATE medewerker_beschikbaarheid --Hier worden de wijzigingen doorgevoerd.
		SET beschikbare_dagen = @beschikbare_dagen
		WHERE medewerker_code = @medewerker_code and (FORMAT(maand, 'yyyy-MM')) = (FORMAT(@maand, 'yyyy-MM'));

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

--SP 11 aanpassen medewerker_rol
/*
Met deze SP kan de rol van een medewerker aangepast worden. Hiervoor zijn
de medewerkercode, de oude rol en de nieuwe rol nodig.
*/
CREATE PROCEDURE sp_WijzigMedewerkerRol
@medewerker_code VARCHAR(5),
@oude_rol        VARCHAR(40),
@nieuwe_rol      VARCHAR(40)
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
		IF NOT EXISTS (SELECT medewerker_code
					   FROM medewerker_rol
					   WHERE medewerker_code = @medewerker_code AND medewerker_rol = @oude_rol)
			--Hier wordt nagegaan of de combinatie medewerkercode-rol voorkomt in de database.
			--Zo niet, wordt een error geworpen.
			THROW 50015, 'Medewerker in combinatie met deze rol bestaat niet.', 16;

		UPDATE medewerker_rol --De wijziging wordt doorgevoerd.
		SET medewerker_rol = @nieuwe_rol
		WHERE medewerker_code = @medewerker_code AND medewerker_rol = @oude_rol;

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
GO

--SP 7 aanpassen medewerker_op_project
/*
Met deze SP kan data met betrekking tot de toewijzing van medewerkers
aan projecten worden aangepast. Hiervoor zijn de projectcode,
de medewerkercode en eventueel een nieuwe projectrol nodig.
*/
CREATE PROCEDURE sp_WijzigMedewerkerOpProject
@project_code VARCHAR(20),
@medewerker_code VARCHAR(5),
@nieuwe_ProjectRol VARCHAR(40)
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
			EXECUTE sp_checkProjectRechten @projectcode = @project_code
			--Hierboven wordt gecheckt of de huidige gebruiker de benodigde rechten heeft om
			--het betreffende project aan te passen.
		IF NOT EXISTS (SELECT '!'
					   FROM medewerker_op_project
				       WHERE project_code = @project_code AND medewerker_code = @medewerker_code)
			--Als de opgegeven medewerker niet aan het opgegeven project is verbonden, wordt een error geworpen.
			THROW 50035, 'De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.', 16;

		UPDATE medewerker_op_project --Hier wordt de data gewijzigd.
		SET project_rol = @nieuwe_ProjectRol
		WHERE project_code = @project_code AND medewerker_code = @medewerker_code;

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
GO

--SP 8 aanpassen medewerker_ingepland_project
/*
Met deze stored procedure kan de data met betrekking tot de ingeplande uren van een
medewerker op een project worden aangepast. Hiervoor zijn de medewerkercode, de projectcode,
het nieuwe aantal uren en de maand nodig.
*/
CREATE PROCEDURE sp_WijzigMedewerkerIngeplandProject
@medewerker_code VARCHAR (5),
@project_code VARCHAR (20),
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

		EXECUTE sp_checkProjectRechten @projectcode = @project_code

		DECLARE @id INT = (SELECT id --KoppelID wordt opgevraagd voor data-opvraag medewerker_ingepland_project.
						FROM medewerker_op_project
						WHERE medewerker_code =  @medewerker_code AND project_code = @project_code)

		IF NOT EXISTS (SELECT '!'
				FROM medewerker_ingepland_project mip
				WHERE mip.id = @id AND (FORMAT(mip.maand_datum, 'yyyy-MM'))  = (FORMAT(@maand_datum, 'yyyy-MM'))) --format voor vergelijken datums
		--Als de medewerker niet is ingepland voor het project in de betreffende maand, wordt een error geworpen.
		THROW 50034, 'Er bestaat geen medewerker_ingepland_project record met de opgegeven gegevens.', 16

		UPDATE medewerker_ingepland_project --Hier wordt de data geüpdatet.
		SET medewerker_uren = @medewerker_uren
		WHERE id = @id AND (FORMAT(maand_datum, 'yyyy-MM')) = (FORMAT(@maand_datum, 'yyyy-MM'))

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
GO

--SP 9 aanpassen medewerker
/*
Met deze procedure kunnen medewerkergegevens worden aangepast, zoals
voor- en achternaam.
*/
CREATE PROCEDURE sp_WijzigMedewerker
@medewerker_code VARCHAR(5),
@achternaam NVARCHAR(20),
@voornaam NVARCHAR(20)
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
         	IF NOT EXISTS (SELECT '!'
							FROM medewerker
							WHERE medewerker_code = @medewerker_code)
		--Hier wordt nagekeken of er gegevens bekend zijn bij de opgegeven medewerkercode.		
		THROW 50028, 'Een medewerker met dit medewerker_code bestaat niet.', 16;

		UPDATE medewerker --Wijzigingen worden doorgevoerd.
		SET achternaam = @achternaam, voornaam = @voornaam
		WHERE medewerker_code = @medewerker_code

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
GO

--SP 6 SP aanpassen projecten
/*
Hier kunnen projectgegevens worden aangepast aan de hand van de projectcode
en de nieuwe informatie die daarbij hoort.
*/
CREATE PROCEDURE sp_WijzigProject
@project_code VARCHAR(20),
@categorie_naam VARCHAR(40),
@begin_datum DATETIME,
@eind_datum DATETIME,
@project_naam VARCHAR(40),
@verwachte_uren INT
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
		EXECUTE sp_checkProjectRechten @projectcode = @project_code --Hier wordt gecheckt of de databasegebruiker de benodigde rechten heeft.

		IF NOT EXISTS (SELECT '@'
					FROM project
					WHERE project_code = @project_code)
			--Hierboven wordt gecheckt of de opgegeven projectcode bestaat. Zo niet, wordt onderstaande error geworpen.
			THROW 50027, 'Opgegeven projectcode bestaat niet.', 16

		UPDATE project --Wijzigingen worden doorgevoerd.
		SET categorie_naam = @categorie_naam,
			begin_datum = @begin_datum,
			eind_datum = @eind_datum,
			project_naam = @project_naam,
			verwachte_uren = @verwachte_uren
		WHERE project_code = @project_code

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
GO

CREATE PROCEDURE sp_AanpassenProjectlidOpSubproject
	@medewerker_code VARCHAR(6),
	@project_code VARCHAR(40),
	@subproject_naam VARCHAR(40),
	@nieuwe_uren INT
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
		EXECUTE sp_checkProjectRechten @projectcode = @project_code

		DECLARE @id INT = (	SELECT id
												FROM medewerker_op_project
												WHERE medewerker_code = @medewerker_code AND project_code = @project_code)

		IF(NOT EXISTS(SELECT '!'
									FROM projectlid_op_subproject
									WHERE id = @id AND project_code = @project_code AND subproject_naam = @subproject_naam
		))
			THROW 50039, 'Deze combinatie van gebruiker en subproject bestaat niet.', 16

		UPDATE projectlid_op_subproject
		SET subproject_uren = @nieuwe_uren
		WHERE id = @id AND project_code = @project_code AND subproject_naam = @subproject_naam

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
GO

CREATE PROCEDURE sp_AanpassenSubprojectCategorie
@categorieNaam VARCHAR(40),
@nieuweCategorieNaam VARCHAR(40)
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
		IF(NOT EXISTS(SELECT '!' --Check of de meegegeven categorie überhaupt bestaat
									FROM subproject_categorie
									WHERE subproject_categorie_naam = @categorieNaam))
			THROW 50042, 'Deze categorie bestaat niet.', 16

		IF(EXISTS(SELECT '!'
							FROM subproject --Check of de categorie wel verwijderd mag worden. Dit mag niet wanneer het nog gebonden is aan een subproject
							WHERE subproject_categorie_naam = @categorieNaam))
			THROW 50043, 'Deze categorie wordt nog gebruikt door een subproject.', 16

		UPDATE subproject_categorie
		SET subproject_categorie_naam = @nieuweCategorieNaam
		WHERE subproject_categorie_naam = @categorieNaam

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
GO

--SP aanpassen subproject
/*
Met deze procedure kunnen subprojectgegevens worden aangepast, zoals de naam, categorie
en de verwachte uren.
*/
CREATE PROCEDURE sp_WijzigSubproject
@project_code VARCHAR(20),
@subproject_naam_oud VARCHAR(40),
@subproject_naam_nieuw VARCHAR(40),
@subproject_categorie_naam VARCHAR(40),
@subproject_verwachte_uren INT
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
    IF NOT EXISTS  (SELECT	'!'
					FROM	subproject
					WHERE	project_code = @project_code AND
							subproject_naam = @subproject_naam_oud)
		--Hier wordt nagekeken of er gegevens bekend zijn bij de opgegeven combinatie projectcode-subprojectnaam.
		THROW 50044, 'Dit subproject is niet gevonden.', 16;

	UPDATE	subproject --Wijzigingen worden doorgevoerd.
	SET		project_code = @project_code,
			subproject_naam = @subproject_naam_nieuw,
			subproject_categorie_naam = @subproject_categorie_naam,
			subproject_verwachte_uren = @subproject_verwachte_uren
	WHERE	project_code = @project_code AND
			subproject_naam = @subproject_naam_oud

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
GO

--SP aanpassen categorietag
/*
Met deze procedure kunnen de namen van categorietags worden aangepast. 
De stored procedure verwacht de huidige naam en de naam waarin het veranderd moet worden.
*/
CREATE PROCEDURE sp_WijzigCategorieTag
@tag_naam_oud NVARCHAR(40),
@tag_naam_nieuw NVARCHAR(40)
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
    IF (NOT EXISTS (SELECT	'!'
					FROM	categorie_tag
					WHERE	tag_naam = @tag_naam_oud))
		--Hier wordt nagekeken of de te wijzigen tagnaam bestaat.
		THROW 50052, 'De te wijzigen tag is niet gevonden.', 16;

	UPDATE	categorie_tag --Wijzigingen worden doorgevoerd.
	SET		tag_naam = @tag_naam_nieuw
	WHERE	tag_naam = @tag_naam_oud

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
GO

--SP aanpassen tag van categorie
/*
Met deze procedure kan een bestaande tag van een categorie gewijzigd worden.
*/
CREATE PROCEDURE sp_WijzigTagVanCategorie
@tag_naam_oud NVARCHAR(40),
@tag_naam_nieuw NVARCHAR(40),
@naam VARCHAR(40)
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
	IF NOT EXISTS (SELECT '!'
					FROM tag_van_categorie
					WHERE tag_naam = @tag_naam_oud AND naam = @naam)
		--Hier wordt gecontroleerd of de combinatie van het opgegeven naam en tag_naam bestaat voordat die aangepast kan worden. Zoniet, dan wordt het onderstaande foutmelding getoond.
		THROW 50053, 'De te wijzigen tag van het opgegeven categorie bestaat niet.', 16;

	UPDATE	tag_van_categorie --Wijzigingen worden doorgevoerd.
	SET		tag_naam = @tag_naam_nieuw
	WHERE	tag_naam = @tag_naam_oud AND naam = @naam

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
GO				

