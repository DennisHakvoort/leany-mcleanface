--DROP ALL BUSINESS RULES
EXEC SP_DROP_CONSTRAINT @Constraint_name = 'CK_UREN_MIN_MAX', @tablename = 'medewerker_beschikbaarheid'


--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

/*
 *	business rule 5 en 6
 *	BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
 *	BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184
*/

ALTER TABLE MEDEWERKER_INGEPLAND_PROJECT WITH CHECK
	ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (medewerker_uren > 0 and medewerker_uren < 184)

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