/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     06-06-2018 15:51:54                              */
/*==================================================================*/

/* Stored procedures voor delete in tabellen voor database LeanDb   */

USE LeanDb
GO

--Procedures voor het verwijderen van data.
DROP PROCEDURE IF EXISTS sp_VerwijderenProjectCategorie
DROP PROCEDURE IF EXISTS sp_verwijderenProjectrol
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerIngeplandProject
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerRol
GO

--SP verwijderen medewerker_rol
/*
Met deze delete stored procedure kan een rol toegewezen aan een medewerker verwijderd worden
*/
CREATE PROCEDURE sp_VerwijderenMedewerkerRol
@medewerker_code VARCHAR(5),
@medewerker_rol VARCHAR(40)
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
			FROM medewerker m INNER JOIN medewerker_rol mr
			ON m.medewerker_code = mr.medewerker_code
			WHERE mr.medewerker_rol = @medewerker_rol AND mr.medewerker_code = @medewerker_code)
		--Deze foutmelding wordt getoond indien een opgegeven medewerkerrol niet aan de opgegeven medewerkercode als data bestaat
		THROW 50030, 'deze medewerker heeft niet de ingevoerde medewerker_rol.', 16

		DELETE FROM medewerker_rol --als er geen errors ontstaan wordt de opgegeven medewerkerrol verwijderd uit tabel
		WHERE medewerker_code = @medewerker_code AND medewerker_rol = @medewerker_rol

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

--Sp verwijderen projectcategorie
/*
Met deze stored procedure kan een projectcategorie verwijderd worden
*/
CREATE PROCEDURE sp_VerwijderenProjectCategorie
@categorieNaam VARCHAR(40)
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
		BEGIN
			IF EXISTS (SELECT naam
					   FROM project_categorie
					   WHERE hoofdcategorie = @categorieNaam)
			THROW 50021, 'Een categorie met subcategorieën kan niet verwijderd worden.', 16
			--Deze foutmelding wordt getoond wanneer je een categorie met bestaande subcategorieën probeert te verwijderen.
		END
	BEGIN
		IF EXISTS (SELECT c.naam
				   FROM project_categorie c INNER JOIN project p ON c.naam = p.categorie_naam
				   WHERE c.naam = @categorieNaam)
		THROW 50022, 'Een categorie die gebruikt wordt door een project kan niet verwijderd worden.', 16
		--Deze foutmelding wordt getoond wanneer je een categorie die in gebruik is binnen een project probeert te verwijderen.
    END
	DELETE FROM project_categorie --Hier wordt de categorienaam verwijderd. 
	WHERE naam = @categorieNaam

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

--Sp verwijderen projectrol
/*
Met deze stored procedure kan een projectrol uit de database verwijderd worden.
*/
CREATE PROCEDURE sp_verwijderenProjectrol
@projectrol VARCHAR(40)
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
		IF EXISTS (SELECT '@'
					FROM medewerker_op_project
					WHERE project_rol = @projectrol)
			THROW 50026, 'Projectrol kan niet worden verwijderd, omdat het nog in gebruik is.', 16
			--Deze foutmelding wordt getoond wanneer je een projectrol in gebruik door een medewerker probeert te verwijderen.

			DELETE FROM project_rol_type --Hier wordt de projectrol verwijderd.
			WHERE project_rol = @projectrol

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

--SP verwijderen medewerker_ingepland_project
/*
Met deze stored procedure kan een medewerker_ingepland_project record verwijderd worden.
*/
CREATE PROCEDURE sp_VerwijderenMedewerkerIngeplandProject
@maand_datum DATETIME,
@medewerker_code VARCHAR(5),
@project_code VARCHAR(20)		
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
	DECLARE @id INT;
		IF NOT EXISTS (SELECT '!'
				FROM medewerker_op_project
				WHERE medewerker_code = @medewerker_code AND project_code = @project_code)
		THROW 50035, 'De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.', 16
		--Deze foutmelding wordt getoond wanneer de medewerker niet ingedeeld is in de opgegeven id.
		SET @id = (SELECT id
				FROM medewerker_op_project
				WHERE medewerker_code = @medewerker_code AND project_code = @project_code)

		IF NOT EXISTS (SELECT '!'
				FROM medewerker_ingepland_project mip INNER JOIN medewerker_op_project mop
				ON mip.id = mop.id
				WHERE mip.id = @id AND mip.maand_datum = @maand_datum)
												  
		THROW 50031, 'Er bestaat geen medewerker_ingepland_project record met de opgegeven id.', 16
		--Deze foutmelding wordt getoond wanneer de medewerker die aan een project gekoppeld is niet voor de opgegeven maand_datum ingepland staat.

		DELETE FROM medewerker_ingepland_project --Hier wordt de ingeplande maand_datum verwijderd.
		WHERE id = @id AND maand_datum = @maand_datum

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
                                                                               
--SP verwijderen medewerker_rol_type
/*
Met deze stored procedure kan een medewerkerroltype verwijderd worden.
*/
CREATE PROCEDURE sp_VerwijderenMedewerkerRolType
@medewerker_rol VARCHAR(40)
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
		IF EXISTS (SELECT '!'
					FROM medewerker_rol
					WHERE medewerker_rol = @medewerker_rol)
		THROW 50029, 'een medewerker_rol_type in gebruik kan niet verwijderd worden.', 16;
		--Deze foutmelding wordt getoond wanneer je een medewerkerroltype probeert te verwijderen terwijl het nog in gebruik is door een medewerker.

		DELETE FROM medewerker_rol_type --Hier wordt de opgegeven medewerkerrol verwijderd.
		WHERE medewerker_rol = @medewerker_rol;

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
