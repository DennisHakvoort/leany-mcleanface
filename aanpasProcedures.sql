USE LeanDb
GO

DROP PROCEDURE IF EXISTS sp_WijzigCategorieen
DROP PROCEDURE IF EXISTS sp_WijzigProjectRol
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_WijzigBeschikbareDagen
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerRol
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerIngeplandProject
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_WijzigProject
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerOpProject
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerker
GO

--SP wijzigen categorieën
CREATE PROCEDURE sp_WijzigCategorieen
@naamOud   VARCHAR(40),
@naamNieuw VARCHAR(40),
@parentNieuw VARCHAR(40)
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
			THROW 50009, 'Deze categorie bestaat niet', 16;

		UPDATE project_categorie
		SET naam = @naamNieuw, parent =@parentNieuw
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

--SP voor wijzigen projectrollen
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
				   WHERE project_rol = @project_rol_oud)
		THROW 50013, 'Project rol bestaat niet.', 16;
	
	UPDATE project_rol_type
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
	
 --SP aanpassen medewerker rol types
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
		THROW 50008, 'medewerker rol bestaat niet.', 16;

	UPDATE medewerker_rol_type
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

--update beschikbare dagen van een medewerker
CREATE PROCEDURE sp_WijzigBeschikbareDagen
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
			THROW 50019, 'Mederwerker is in de opgegeven maand nog niet ingepland', 16;

		UPDATE medewerker_beschikbaarheid
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
                                                                                      
--SP het veranderen van een rol die een medewerker is toegekend.
CREATE PROCEDURE sp_WijzigenMedewerkerRol
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
			THROW 50015, 'Medewerker in combinatie met deze rol bestaat niet.', 16;

		UPDATE medewerker_rol
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
                                                                       
--Sp aanpassen medewerker op project
CREATE PROCEDURE sp_WijzigenMedewerkerOpProject
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
		IF NOT EXISTS (SELECT *
					   FROM medewerker_op_project
				       WHERE project_code = @project_code AND medewerker_code = @medewerker_code)
			THROW 50019, ' De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.', 16;

		UPDATE MEDEWERKER_OP_PROJECT
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

--SP 9 Toevoegen SP aanpassen medewerker.
CREATE PROCEDURE sp_WijzigenMedewerker
@medewerker_code VARCHAR(5),
@achternaam NVARCHAR(20),
@voornaam NVARCHAR(20)
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
         	IF NOT EXISTS (SELECT '!'                                                                
							FROM medewerker
							WHERE medewerker_code = @medewerker_code)
		
		THROW 50028, 'Een medewerker met dit medewerker_code bestaat niet.', 16;

		UPDATE medewerker
		SET achternaam = @achternaam, voornaam = @voornaam
		WHERE medewerker_code = @medewerker_code;

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
                                                                                                                                                                                                                                 
--SP wijzigen projecten
CREATE PROCEDURE sp_WijzigProject
@project_code VARCHAR(20),
@categorie_naam VARCHAR(40),
@begin_datum DATETIME,
@eind_datum DATETIME,
@project_naam VARCHAR(40),
@verwachte_uren INT
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
					FROM project
					WHERE project_code = @project_code)

				THROW 50027, 'Opgegeven project code bestaat niet', 16

		UPDATE project
		SET categorie_naam = @categorie_naam,
			begin_datum = @begin_datum,
			eind_datum = @eind_datum,
			project_naam = @project_naam,
			verwachte_uren = @verwachte_uren
		WHERE project_code = @project_code;

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
                                                                               
--SP 15 Toevoegen SP verwijderen medewerker_ingepland_project
CREATE PROCEDURE sp_VerwijderenMedewerkerIngeplandProject
@id INT,
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
		IF NOT EXISTS (SELECT '!'
				FROM medewerker_ingepland_project mip INNER JOIN medewerker_op_project mop
				ON mip.id = mop.id
				WHERE mip.id = @id AND mip.maand_datum = @maand_datum)
												  
		THROW 50031, 'Er bestaat geen medewerker_ingepland_project record met de opgegeven id', 16

		DELETE FROM medewerker_ingepland_project
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
END
GO
                                                                               
--SP 17 Toevoegen SP verwijderen medewerker_rol_type
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

		DELETE FROM medewerker_rol_type
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