USE LeanDb
GO

DROP PROCEDURE IF EXISTS sp_WijzigCategorieen
DROP PROCEDURE IF EXISTS sp_WijzigMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_WijzigBeschikbareDagen
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerRol
DROP PROCEDURE IF EXISTS sp_WijzigenMedewerkerIngeplandProject

--SP wijzigen categorieën
GO
CREATE PROCEDURE sp_WijzigCategorieen
@naamOud   CHAR(40),
@naamNieuw CHAR(40),
@parentNieuw CHAR(40)
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
	BEGIN
		IF NOT EXISTS (SELECT naam
				   FROM project_categorie
				   WHERE naam = @naamOud)
			THROW 50009, 'Deze categorie bestaat niet', 16
			END
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

--SP aanpassen medewerker rol types
GO
CREATE PROCEDURE sp_WijzigMedewerkerRolType
@medewerker_Rol_Oud   CHAR(40),
@medewerker_Rol_Nieuw CHAR(40)
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
	BEGIN
		IF NOT EXISTS (SELECT medewerker_rol
				   FROM medewerker_rol_type
				   WHERE medewerker_rol = @medewerker_Rol_Oud)
		THROW 50008, 'medewerker rol bestaat niet.', 16
		END
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

-- update beschikbare dagen van een medewerker
GO
CREATE PROCEDURE sp_WijzigBeschikbareDagen
@medewerker_code VARCHAR(5),
@maand DATE,
@beschikbare_dagen INT
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
		UPDATE medewerker_beschikbaarheid
		SET beschikbare_dagen = @beschikbare_dagen
		WHERE medewerker_code = @medewerker_code and (FORMAT(maand, 'yyyy-MM')) = (FORMAT(@maand, 'yyyy-MM'))

		IF @@ROWCOUNT = 0
		THROW 50019, 'Mederwerker is in de opgegeven maand nog niet ingepland', 16;

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

--SP het veranderen van een rol die een medewerker is toegekend.
GO
CREATE PROCEDURE sp_WijzigenMedewerkerRol
@medewerker_code CHAR(5),
@oude_rol        CHAR(40),
@nieuwe_rol      CHAR(40)
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
	BEGIN
		IF NOT EXISTS (SELECT medewerker_code
					   FROM medewerker_rol
					   WHERE medewerker_code = @medewerker_code AND medewerker_rol = @oude_rol)
		THROW 50015, 'Medewerker in combinatie met deze rol bestaat niet.', 16
		END
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

--SP 8 Toevoegen SP aanpassen medewerker_ingepland_project
CREATE PROCEDURE sp_WijzigenMedewerkerIngeplandProject
@id INT,
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
		IF NOT EXISTS (SELECT '!'
				FROM medewerker_ingepland_project mip INNER JOIN medewerker_op_project mop
				ON mip.id = mop.id
				WHERE mip.id = @id)
												  
		THROW 50034, 'Er bestaat geen medewerker_ingepland_project record met de opgegeven id.', 16
												  
		UPDATE medewerker_ingepland_project
		SET medewerker_uren = @medewerker_uren
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
