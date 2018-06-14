/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     05-06-2018 10:51:54                              */
/*==================================================================*/

/* Stored procedures voor insert in tabellen voor database LeanDb   */

USE LeanDb
GO

DROP PROCEDURE IF EXISTS SP_insertMedewerkerRol
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_InsertProjectRolType
DROP PROCEDURE IF EXISTS sp_InsertProject
DROP PROCEDURE IF EXISTS sp_InsertProjectCategorie
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerOpProject
DROP PROCEDURE IF EXISTS sp_InsertSubproject
DROP PROCEDURE IF EXISTS sp_InsertSubprojectCategorie
DROP PROCEDURE IF EXISTS sp_InsertProjLidOpSubProj
DROP PROCEDURE IF EXISTS sp_InsertCategorieTag
DROP PROCEDURE IF EXISTS sp_InsertTagVanCategorie
GO

--Insert procedure medewerkerrol
/*
Met deze stored procedure voeg je een medewerkerrol toe aan de medewerker_rol tabel. 
Hierbij worden de medewerker_code en medewerker_rol als parameters meegegeven.
*/
CREATE PROCEDURE sp_InsertMedewerkerRol
@medewerker_code VARCHAR(5),
@medewerker_rol  VARCHAR(40)
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
		 INSERT INTO medewerker_rol (medewerker_code, medewerker_rol)
		 VALUES (@medewerker_code, @medewerker_rol)

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

--Insert procedure medewerkerroltype
/*
Met deze stored procedure voeg je een medewerker_rol toe in medewerker_rol_type. 
Bijvoorbeeld de rol superuser of medewerker kan je hiermee in de tabel medewerker_rol_type toevoegen.
*/
CREATE PROCEDURE sp_InsertMedewerkerRolType
@medewerker_rol  VARCHAR(40)
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
		 INSERT INTO medewerker_rol_type (medewerker_rol)
		 VALUES (@medewerker_rol)

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

--Insert procedure projectroltype
/*
Met deze stored procedure voeg je een projectroltype toe.
Bijvoorbeeld de projectrol tester of projectleider.
*/
CREATE PROCEDURE sp_InsertProjectRolType
@project_rol  VARCHAR(40)
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
		 INSERT INTO project_rol_type (project_rol)
		 VALUES (@project_rol)

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

--Insert procedure project
/*
Met deze stored procedure voeg je een project toe.
*/
CREATE PROCEDURE sp_InsertProject
@project_code   VARCHAR(20),
@categorie_naam VARCHAR(40),
@begin_datum	DATETIME,
@eind_datum	DATETIME,
@project_naam   VARCHAR(40),
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
		 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam, verwachte_uren)
		 VALUES (@project_code, @categorie_naam, @begin_datum, @eind_datum, @project_naam, @verwachte_uren)
		
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

--Insert procedure projectcategorie
/*
Met deze stored procedure voeg je een projectcategorie toe.
*/
CREATE PROCEDURE sp_InsertProjectCategorie
@naam   VARCHAR(40),
@hoofdcategorie VARCHAR(40)
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
		 INSERT INTO project_categorie (naam, hoofdcategorie)
		 VALUES (@naam, @hoofdcategorie)

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

--Insert procedure medewerker op project
/*
Met deze stored procedure kan je een medewerker indelen op een bestaande project
*/
CREATE PROCEDURE sp_InsertMedewerkerOpProject
@project_code    VARCHAR(20),
@medewerker_code VARCHAR(5),
@project_rol	 VARCHAR(40)
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

		 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
		 VALUES (@project_code, @medewerker_code, @project_rol)

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

--Insert subproject
/*
Met deze procedure kan je een subproject toevoegen binnen een project
*/
CREATE PROCEDURE sp_InsertSubproject
@parent_code	VARCHAR(20),
@naam			VARCHAR(40),
@verwachte_uren	INT,
@categorie		VARCHAR(40)
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
		EXECUTE sp_checkProjectRechten @projectcode = @parent_code;
		IF NOT EXISTS(SELECT '@' --Checkt of de subprojectcategorie wel bestaat.
					FROM subproject_categorie
					WHERE subproject_categorie_naam = @categorie)
			THROW 50045, 'Opgegeven subprojectcategorienaam bestaat niet.', 16

		IF NOT EXISTS(SELECT '@' --Checkt of de opgegeven hoofdproject wel bestaat.
						FROM project
						WHERE project_code = @parent_code)
			THROW 50046, 'Opgegeven hoofdprojectcode bestaat niet.', 16

		IF (@verwachte_uren < 0) --Checkt of er geen negatieve uren zijn opgegeven.
			THROW 50047, 'Verwachte uren van subprojecten mogen niet negatief zijn.', 16
		
		INSERT INTO subproject (project_code, subproject_naam, subproject_categorie_naam, subproject_verwachte_uren)
			VALUES (@parent_code, @naam, @categorie, @verwachte_uren);

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


--Insert sp_InsertSubprojectCategorie
/*
Met deze procedure kan je een categorie toevoegen aan een subproject
*/
CREATE PROCEDURE sp_InsertSubprojectCategorie
@categorie_naam			VARCHAR(40)
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
		INSERT INTO subproject_categorie(subproject_categorie_naam)
			VALUES (@categorie_naam);

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

--Insert sp_InsertProjLidOpSubProj
/*
Met deze procedure kan je een projectlid toevoegen aan een subproject.
*/
CREATE PROCEDURE sp_InsertProjLidOpSubProj
@medewerker_code	VARCHAR(5),
@project_code		VARCHAR(20),
@subproject_naam	VARCHAR(40),
@subproject_uren	INT
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
		DECLARE @id INT = -1

		IF (@subproject_uren < 0) --mag niet negatief zijn
			THROW 50050, 'Verwachte uren voor een subproject mag niet negatief zijn.', 16

		IF NOT EXISTS (SELECT '@'
					FROM medewerker_op_project
					WHERE medewerker_code = @medewerker_code
					AND	project_code =@project_code)
			THROW 50049, 'Medewerker is niet aan het hoofdproject gekoppeld.', 16 -- moet gekoppeld aan elkaar zijn

		SET @id = (SELECT id
					FROM medewerker_op_project
					WHERE medewerker_code = @medewerker_code
					AND	project_code =@project_code)

		INSERT INTO projectlid_op_subproject (id, project_code, subproject_naam, subproject_uren)
			VALUES (@id, @project_code, @subproject_naam, @subproject_uren)

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

--SP Toevoegen categorietags
/*
Met deze procedure kunnen tags worden toegevoegd aan de mogelijke lijst van tags voor categorieën.
Deze tags zijn bedoeld om gebruikt te worden voor een eventuele zoekfunctie.

De Stored Procedure verwacht alleen een tagnaam.
*/
CREATE PROCEDURE sp_InsertCategorieTag
@tag_naam NVARCHAR(40)
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
		INSERT INTO categorie_tag(tag_naam) --Is de naam nog niet in gebruik, wordt deze toegevoegd.
			VALUES(@tag_naam)

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

--SP Toevoegen tag van categorie
/*
Met deze procedure kunnen bestaande tags aan een projectcategorie toegevoegd worden.
*/
CREATE PROCEDURE sp_InsertTagVanCategorie
@naam VARCHAR (40),
@tag_naam NVARCHAR (40)
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
		IF NOT EXISTS (SELECT '@' --Check of de ingevoerde tag_naam wel bestaat.
					FROM categorie_tag
					WHERE tag_naam = @tag_naam)
			THROW 50048, 'De ingevoerde tagnaam bestaat niet.', 16
			--Deze foutmelding wordt getoond wanneer een niet bestaande tag_naam aan een tag_van_categorie gekoppeld wordt.

		INSERT INTO tag_van_categorie(naam, tag_naam)
			VALUES (@naam, @tag_naam)

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