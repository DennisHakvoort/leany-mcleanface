USE LeanDb
GO
--Procedures voor het verwijderen van data.
DROP PROCEDURE IF EXISTS sp_VerwijderenProjectCategorie
DROP PROCEDURE IF EXISTS sp_verwijderenProjectrol
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerIngeplandProject
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerRolType
DROP PROCEDURE IF EXISTS sp_VerwijderenMedewerkerRol
GO

--SP 16 Toevoegen SP verwijderen medewerker_rol
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

		THROW 50030, 'deze medewerker heeft niet de ingevoerde medewerker_rol.', 16

		DELETE FROM medewerker_rol
		WHERE medewerker_code = @medewerker_code

		IF @TranCounter = 0 AND XACT_STATE() = 1
			COMMIT TRANSACTION;
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


--Sp verwijderen project categorie.
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
	END
	BEGIN
		IF EXISTS (SELECT c.naam
				   FROM project_categorie c INNER JOIN project p ON c.naam = p.categorie_naam
				   WHERE c.naam = @categorieNaam  )
		THROW 50022, 'Een categorie die gebruikt wordt door een project kan niet verwijderd worden.', 16
    END
	DELETE FROM project_categorie
	WHERE naam = @categorieNaam
	IF @TranCounter = 0 AND XACT_STATE() = 1
	COMMIT TRANSACTION;
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

--Sp verwijderen projectrol
CREATE PROCEDURE sp_verwijderenProjectrol
@projectrol VARCHAR(40)
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
		IF EXISTS (SELECT '@'
					FROM medewerker_op_project
					WHERE project_rol = @projectrol)
			THROW 50026, 'Projectrol kan niet worden verwijderd, omdat het nog in gebruik is.', 16

			DELETE FROM project_rol_type
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
END
GO

--SP 15 Toevoegen SP verwijderen medewerker_ingepland_project
CREATE PROCEDURE sp_VerwijderenMedewerkerIngeplandProject
@id INT,
@maand_datum DATETIME			
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
END
GO 

--SP verwijderen subprojecten
/*
Dit is de procedure voor het verwijderen van subprojecten. Hieraan worden de
project_code en de subproject_naam meegegeven.
*/
CREATE PROCEDURE sp_VerwijderSubproject
@project_code VARCHAR(20),
@subproject_naam VARCHAR(20)
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
		IF NOT EXISTS  (SELECT	'@'
						FROM	subproject
						WHERE	project_code = @project_code AND
								subproject_naam = @subproject_naam)
			--Hier wordt nagekeken of er gegevens bekend zijn bij de opgegeven combinatie projectcode-subprojectnaam.
			THROW 50044, 'Dit subproject is niet gevonden.', 16;
        
		DELETE 
		FROM	subproject
		WHERE	project_code = @project_code AND--Hier wordt het subproject verwijderd.
				subproject_naam = @subproject_naam
		                                                                                                                                
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