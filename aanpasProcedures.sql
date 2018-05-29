

DROP PROCEDURE IF EXISTS sp_WijzigCategorieen
DROP PROCEDURE IF EXISTS sp_WijzigProjectRol


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

--SP voor wijzigen project rollen
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
	THROW 50013, 'Project rol bestaat niet.', 16
	UPDATE project_rol_type
	SET project_rol = @project_rol_nieuw
	WHERE project_rol = @project_rol_oud
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
