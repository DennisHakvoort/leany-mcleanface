USE LeanDb
--PROCEDURE OM CONSTRAINTS TE DROPPEN ALS DEZE BESTAAN
CREATE PROCEDURE SP_DROP_CONSTRAINT
	@Constraint_name VARCHAR(255) = NULL,
	@tablename VARCHAR(255) = NULL
	AS
	BEGIN TRY
		declare @sql NVARCHAR(255)
    SELECT @sql = 'ALTER TABLE ' + @tablename + ' DROP CONSTRAINT ' + @Constraint_name;
		EXEC sys.sp_executesql @stmt = @sql
	END TRY
	BEGIN CATCH
		PRINT 'Het volgende constraint is niet gedropt, waarschijnlijk omdat deze niet bestond: ' + @Constraint_name
	END CATCH
	GO

--DROP ALL BUSINESS RULES
EXEC SP_DROP_CONSTRAINT @Constraint_name = 'CK_UREN_MIN_MAX', @tablename = 'medewerker_beschikbaarheid'
EXEC SP_DROP_CONSTRAINT @Constraintname = 'CK_EINDDATUM_NA_BEGINDATUM', @tablename = 'project'


--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

-- BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
-- BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184
CREATE PROCEDURE spProjecturenInplannen
@medewerker_code INT,
@project_code CHAR(20),
@medewerker_uren INT,
@maand_datum datetime
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
	DECLARE @id int; -- id representeert de combinatie van een medewerker en project. Wordt uit de tabel medewerker_op_project
		SET @id = SELECT id
					FROM	medewerker_op_project
					where	medewerker_code = @medewerker_code
						AND	project_code = @project_code

		IF EXISTS (	SELECT	1
					FROM	medewerker_ingepland_project
					WHERE	id = @id

					HAVING	SUM(medewerker_uren) + @medewerker_uren <= 184) -- 184 is het maximum aantal uren per maand voor een medewerker

			INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
				VALUES	(@id, @medewerker_uren, @maand_datum);
		ELSE
			RAISERROR('Ingevulde uren is minder dan 0 of het totale aantal uren van de medewerker is meer dan 184 uur', 16, 1)

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

--BR7 project(eind_datum) moet na project(begin_datum) vallen
ALTER TABLE project WITH CHECK
	ADD CONSTRAINT CK_EINDDATUM_NA_BEGINDATUM CHECK (eind_datum > begin_datum)