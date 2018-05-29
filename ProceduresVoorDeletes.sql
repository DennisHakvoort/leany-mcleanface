--Procedures voor het verwijderen van data.
DROP PROCEDURE IF EXISTS sp_VerwijderenProjectCategorie
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
				   WHERE parent = @categorieNaam)
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