USE LeanDb
GO

DROP PROCEDURE IF EXISTS SP_insertMedewerkerRol
DROP PROCEDURE IF EXISTS SP_insertMedewerkerRolType
DROP PROCEDURE IF EXISTS SP_insertProjectRoleType
DROP PROCEDURE IF EXISTS SP_insertProject
DROP PROCEDURE IF EXISTS SP_insertProjectCategorie
DROP PROCEDURE IF EXISTS SP_insertMedewerkerOpProject

--insert procedure medeweker_rol
GO
CREATE PROCEDURE SP_insertMedewerkerRol
@medewerker_code CHAR,
@medewerker_rol  CHAR
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
		 INSERT INTO medewerker_rol (medewerker_code, medewerker_rol)
		 VALUES (@medewerker_code, @medewerker_rol)
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
--Insert procedure medewerker rol type
CREATE PROCEDURE SP_insertMedewerkerRolType
@medewerker_rol  CHAR
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
		 INSERT INTO medewerker_rol_type (medewerker_rol)
		 VALUES (@medewerker_rol)
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
--procedure insert project rol type
CREATE PROCEDURE SP_insertProjectRoleType
@project_rol  CHAR
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
		 INSERT INTO project_rol_type (project_rol)
		 VALUES (@project_rol)
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
--procedure insert project
CREATE PROCEDURE SP_insertProject
@project_code   CHAR,
@categorie_naam CHAR,
@begin_datum	DATETIME,
@eind_datum		DATETIME,
@project_naam   CHAR
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
		 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		 VALUES (@project_code, @categorie_naam, @begin_datum, @eind_datum, @project_naam)
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
--insert project categorie
CREATE PROCEDURE SP_insertProjectCategorie
@naam   CHAR,
@parent CHAR
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
		 INSERT INTO project_categorie (naam, parent)
		 VALUES (@naam, @parent)
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
--insert medewerker op project
CREATE PROCEDURE SP_insertMedewerkerOpProject
@id				 INT,
@project_code    CHAR,
@medewerker_code CHAR,
@project_rol	 DATETIME
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
		 INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
		 VALUES (@id, @project_code, @medewerker_code, @project_rol)
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
