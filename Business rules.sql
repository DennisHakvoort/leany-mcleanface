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


--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

-- BR9 BR9 De waarden van project, medewerker op project en medewerker_ingepland_project
-- kunnen niet meer worden aangepast als project(eind_datum) is verstreken,

ALTER TRIGGER TG_PROJECT_VERSTREKEN_PROJECT
	ON project
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		IF EXISTS(SELECT '!'
							FROM (project P INNER JOIN inserted I ON P.project_code = I.project_code) LEFT OUTER JOIN deleted D on P.project_code = D.project_code
							WHERE (I.eind_datum < CURRENT_TIMESTAMP OR D.eind_datum < CURRENT_TIMESTAMP))

			THROW 50001, 'Een project kan niet meer aangepast worden nadat deze is afgelopen.', 16
	END

BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2018', '22 feb 2018', 'testerdetest')
ROLLBACK TRANSACTION

