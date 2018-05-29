

DROP PROCEDURE IF EXISTS sp_WijzigCategorieen
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerRol
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerOpProject

--SP wijzigen categorieën

GO
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
			THROW 50009, 'Deze categorie bestaat niet', 16
		UPDATE project_categorie
		SET naam = @naamNieuw, parent =@parentNieuw
		WHERE naam = @naamOud
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
		THROW 50008, 'medewerker rol bestaat niet.', 16
	UPDATE medewerker_rol_type
	SET medewerker_rol = @medewerker_Rol_Nieuw
	WHERE medewerker_rol = @medewerker_Rol_Oud
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
		THROW 50015, 'Medewerker in combinatie met deze rol bestaat niet.', 16
	UPDATE medewerker_rol
	SET medewerker_rol = @nieuwe_rol
	WHERE medewerker_code = @medewerker_code AND medewerker_rol = @oude_rol
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
		THROW 50019, ' De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.', 16
	UPDATE MEDEWERKER_OP_PROJECT
			SET project_rol = @nieuwe_ProjectRol
		WHERE project_code = @project_code AND medewerker_code = @medewerker_code
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

