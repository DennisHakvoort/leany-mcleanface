DROP PROCEDURE IF EXISTS SP_insertMedewerkerRol
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_InsertProjectRolType
DROP PROCEDURE IF EXISTS sp_InsertProject
DROP PROCEDURE IF EXISTS sp_InsertProjectCategorie
DROP PROCEDURE IF EXISTS sp_InsertMedewerkerOpProject

--insert procedure medeweker_rol
GO
CREATE PROCEDURE sp_InsertMedewerkerRol
@medewerker_code CHAR(5),
@medewerker_rol  CHAR(40)
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
CREATE PROCEDURE sp_InsertMedewerkerRolType
@medewerker_rol  CHAR(40)
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
CREATE PROCEDURE sp_InsertProjectRolType
@project_rol  CHAR(40)
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
CREATE PROCEDURE sp_InsertProject
@project_code   CHAR(20),
@categorie_naam CHAR(40),
@begin_datum	DATETIME,
@eind_datum		DATETIME,
@project_naam   CHAR(40)
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
CREATE PROCEDURE sp_InsertMedewerkerOpProject
@project_code    CHAR(20),
@medewerker_code CHAR(5),
@project_rol	 CHAR(40)
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
			EXECUTE sp_checkProjectRechten @projectcode = @project_code

		 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
		 VALUES (@project_code, @medewerker_code, @project_rol)
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

CREATE PROCEDURE sp_InsertSubproject
@parent_code VARCHAR(20),
@naam VARCHAR(40),
@verwachte_uren	INT,
@categorie VARCHAR(40)
AS BEGIN
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
		IF NOT EXISTS(SELECT '@'
					FROM subproject_categorie
					WHERE subproject_categorie_naam = @categorie)
			THROW 50, 'Opgegeven subproject categorie naam bestaand niet.', 16
		IF NOT EXISTS(SELECT '@'
						FROM project
						WHERE project_code = @parent_code)
			THROW 50, 'Opgegeven hoofdprojectcode bestaat niet.', 16
		IF (@verwachte_uren < 0)
			THROW 50, 'Verwachte uren van subprojecten mogen niet negatief zijn.', 16
		
		INSERT INTO subproject (project_code, subproject_naam, subproject_categorie_naam, subproject_verwachte_uren)
			VALUES (@parent_code, @naam, @verwachte_uren, @categorie);
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