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
		IF (@medewerker_uren < 0)
			BEGIN
				RAISERROR('Invalide invoerwaarde - negatieve uren', 16, 1)
			END
	DECLARE @id int; -- id representeert de combinatie van een medewerker en project. Wordt uit de tabel medewerker_op_project
		SET @id = (SELECT id
					FROM	medewerker_op_project
					where	medewerker_code = @medewerker_code
						AND	project_code = @project_code)

		IF EXISTS (	SELECT	1
					FROM	medewerker_ingepland_project mip
						INNER JOIN medewerker_op_project mop ON mip.id = mop.id 
						INNER JOIN project p on mop.project_code = p.project_code 
					WHERE	mop.medewerker_code = 'a' --@medewerker_code
						AND	FORMAT(mip.maand_datum, 'yyyy-MM') = FORMAT(GETDATE(), 'yyyy-MM') --format zodat het vergeleken kan worden
					GROUP BY medewerker_code
					HAVING	SUM(mip.medewerker_uren) /*+ @medewerker_uren*/ <= 184) -- 184 is het maximum aantal uren per maand voor een medewerker

			INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
				VALUES	(@id, @medewerker_uren, @maand_datum);
		ELSE
			RAISERROR('Het totale geplande uren van de medewerker is meer dan 184 uur', 16, 1)

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

BEGIN TRANSACTION
	insert into medewerker (medewerker_code, voornaam, achternaam)
		values ('aa', 'arend', 'aas')

	insert into project_categorie (naam, parent)
		values	('onderwijs', null)

	insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		values	('PROJC0101C1', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'generieke proj naam')

	insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		values	('PROJC0101C2', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'niet zo generieke proj naam')
	
	insert into project_rol_type (project_rol)
		values	('lector')

	insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
		values	(912012, 'PROJC0101C1', 'aa', 'lector')

	insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
		values	(912013, 'PROJC0101C2', 'aa', 'lector')

	insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
		values	(912013, 10, CONVERT(date, GETDATE()))

	insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
		values	(912012, 10, CONVERT(date, GETDATE()))


	(	SELECT	sum(1)
					FROM	medewerker_ingepland_project mip
						INNER JOIN medewerker_op_project mop ON mip.id = mop.id 
						INNER JOIN project p on mop.project_code = p.project_code 
					WHERE	mop.medewerker_code = 'aa' --@medewerker_code
						AND FORMAT(mip.maand_datum, 'yyyy-MM') = FORMAT(GETDATE(), 'yyyy-MM') --@maand_datum
					GROUP BY medewerker_code
					HAVING	SUM(mip.medewerker_uren) /*+ @medewerker_uren*/ <= 184) -- 184 is het maximum aantal uren per maand voor een medewerker
ROLLBACK TRANSACTION