USE LeanDb
GO

DROP PROCEDURE IF EXISTS sp_verwijderenProjectrol

GO
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
