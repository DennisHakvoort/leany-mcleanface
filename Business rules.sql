--BUSINESS RULES--
--BR7 project(eind_datum) moet na project(begin_datum) vallen

EXEC SP_DROP_CONSTRAINT @Constraintname = 'CK_EINDDATUM_NA_BEGINDATUM', @tablename = 'project'

ALTER TABLE project WITH CHECK
	ADD CONSTRAINT CK_EINDDATUM_NA_BEGINDATUM CHECK (eind_datum > begin_datum)

-- Faal Test
BEGIN TRANSACTION
	PRINT 'Moeten falen: '
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam');
		PRINT 'test gefaald' 
	END TRY
	BEGIN CATCH
		PRINT 'test succesvol'
	END CATCH
ROLLBACK TRANSACTION
GO

-- Succes Test
BEGIN TRANSACTION
	PRINT 'Moet succesvol zijn: '
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		PRINT 'test succesvol' 
	END TRY
	BEGIN CATCH
		PRINT 'test gefaald'
	END CATCH
ROLLBACK