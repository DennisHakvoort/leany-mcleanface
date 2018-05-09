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
DROP TRIGGER IF EXISTS TG_PROJECT_VERSTREKEN_PROJECT
DROP TRIGGER IF EXISTS TG_PROJECT_VERSTREKEN_MEDEWERKER_INGEPLAND


--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

-- BR9 BR9 De waarden van project, medewerker op project en medewerker_ingepland_project
-- kunnen niet meer worden aangepast als project(eind_datum) is verstreken,

CREATE TRIGGER TG_PROJECT_VERSTREKEN_PROJECT
	ON project
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(SELECT '!'
									FROM inserted
									WHERE eind_datum < CURRENT_TIMESTAMP)
				OR (EXISTS(	SELECT '!'
										FROM deleted
										WHERE eind_datum < CURRENT_TIMESTAMP)))
				THROW 50001, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
			END
	END

CREATE TRIGGER TG_PROJECT_VERSTREKEN_MEDEWERKER_INGEPLAND
	ON medewerker_ingepland_project
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		IF (@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(	SELECT '!'
										FROM (inserted I INNER JOIN medewerker_op_project MIP ON I.id = MIP.id) INNER JOIN project P on MIP.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP)
					OR
						EXISTS( SELECT '!'
										FROM (deleted D INNER JOIN medewerker_op_project MIP ON D.id = MIP.id) INNER JOIN project P on MIP.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP))
					BEGIN
						THROW 50004, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					END
			END
	END

CREATE TRIGGER TG_PROJECT_VERSTREKEN_MEDEWERKER_OP_PROJECT
	ON medewerker_op_project
	AFTER UPDATE, INSERT, DELETE
	AS
	BEGIN
		IF(@@ROWCOUNT > 0)
			BEGIN
				IF (EXISTS(	SELECT '!'
										FROM inserted I INNER JOIN PROJECT P ON I.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP)
					OR
						EXISTS(	SELECT  '!'
										FROM deleted D INNER JOIN PROJECT P ON D.project_code = P.project_code
										WHERE P.eind_datum < CURRENT_TIMESTAMP))
					BEGIN
						THROW 50005, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
					END
			END
	END
