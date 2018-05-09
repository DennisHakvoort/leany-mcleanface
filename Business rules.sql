--BUSINESS RULES--

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


