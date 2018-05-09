--BUSINESS RULES--

USE LeanDb
GO
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


/*BR8 project_categorie(parent) moet een waarde zijn
uit de project_categorie(naam) of NULL. Het kan niet naar zichzelf verwijzen.*/
USE LeanDb
DROP TRIGGER IF EXISTS TG_subCategorieHeeftHoofdCategorie
DROP TRIGGER IF EXISTS TG_geenHoofdCategorieMetSubsVerwijderen
GO

CREATE TRIGGER TG_subCategorieHeeftHoofdCategorie
  ON project_categorie
  AFTER INSERT, UPDATE
AS
BEGIN
BEGIN TRY
  IF NOT EXISTS ((SELECT parent
			  FROM inserted
			  WHERE EXISTS (SELECT naam
							   FROM PROJECT_CATEGORIE
							   WHERE naam = inserted.PARENT
							   )
							   OR parent IS NULL
							   ))
	THROW 500020, 'Deze subcategorie heeft geen geldige hoofdcategorie', 16
  END TRY
  BEGIN CATCH
    THROW
  END CATCH
END
GO

CREATE TRIGGER TG_geenHoofdCategorieMetSubsVerwijderen
  ON project_categorie
  AFTER DELETE
AS
BEGIN
BEGIN TRY
  IF EXISTS ((SELECT naam
			 FROM deleted
			 WHERE parent IS NULL AND naam = (SELECT parent
											  FROM project_categorie
											  )))
		THROW 5000021, 'Kan geen categorie met met subcategoriën verwijderen', 16
  END TRY
  BEGIN CATCH
    THROW
  END CATCH
END
GO


SELECT *
FROM PROJECT_CATEGORIE




--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
ALTER TABLE medewerker_beschikbaarheid
		ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (beschikbaar_uren < 184 AND beschikbaar_uren > 0)

