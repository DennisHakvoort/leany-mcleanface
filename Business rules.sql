USE LeanDb
IF EXISTS (SELECT 1 from sys.objects where name = 'CK_UREN_MIN_MAX')
  ALTER TABLE medewerker_beschikbaarheid DROP CONSTRAINT CK_UREN_MIN_MAX
GO

CREATE PROCEDURE SP_DROP_CONSTRAINT
	@Constraint_name VARCHAR(255) = NULL,
	@tablename VARCHAR(255) = NULL
	AS
		IF EXISTS (SELECT 1 from sys.objects where name = @Constraint_name)
    ALTER TABLE @tablename DROP CONSTRAINT @Constraint_name
	GO
--BUSINESS RULES--

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

