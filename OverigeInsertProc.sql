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
GO

--Insert procedure medewerkerrol
/*
Met deze stored procedure voeg je een medewerkerrol toe aan de medewerker_rol tabel. 
Hierbij worden de medewerker_code en medewerker_rol als parameters meegegeven.
*/
CREATE PROCEDURE sp_InsertMedewerkerRol
@medewerker_code CHAR(5),
@medewerker_rol  CHAR(40)
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
Met deze stored procedure voeg je een nieuwe medewerker_rol_type in de database
Bijvoorbeeld de rol superuser of medewerker kan je hiermee in de tabel medewerker_rol_type toevoegen.
*/
CREATE PROCEDURE sp_InsertMedewerkerRolType
@medewerker_rol  CHAR(40)
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
Met deze stored procedure voeg je een nieuwe projectroltype toe.
Bijvoorbeeld de projectrol tester of projectleider.
*/
CREATE PROCEDURE sp_InsertProjectRolType
@project_rol  CHAR(40)
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
Met deze stored procedure kan een project aangemaakt worden en in de database opgeslagen worden.
*/
CREATE PROCEDURE sp_InsertProject
@project_code   CHAR(20),
@categorie_naam CHAR(40),
@begin_datum	DATETIME,
@eind_datum		DATETIME,
@project_naam   CHAR(40),
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
Met deze stored procedure kan een projectcategorie toegevoegd worden.
*/
CREATE PROCEDURE sp_InsertProjectCategorie
@naam   CHAR(40),
@hoofdcategorie CHAR(40)
AS
	SET NOCOUNT ON
	SET XACT_ABORT OFF
	DECLARE @TranCounter INT;
	SET @TranCounter = @@TRANCOUNT;
	SELECT @TranCounter
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
@project_code    CHAR(20),
@medewerker_code CHAR(5),
@project_rol	 CHAR(40)
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
