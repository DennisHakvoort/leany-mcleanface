/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     06-06-2018 10:51:54                              */
/*==================================================================*/

/* Stored procedures tests voor insertProcedures.sql bestand        */


/*
Alle tests volgen dezelfde template:

--De error die hij geeft of dat hij goed gaat.
BEGIN TRANSACTION --Open transaction, zodat de test niet de echte database beïnvloedt
BEGIN TRY
-- Test gaat hier
END TRY
BEGIN CATCH -- Wanneer er een error is gegooid in de test, word deze hier geprint.
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION --De transaction terugrollen zodat de testdata niet in de echte database terecht komt

Alle tests worden uitgevoerd op een lege database.
 */

 USE LeanDb
 GO

--Runt alle insert procedures.

BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertMedewerkerRolType 'braadworst'
EXEC sp_InsertMedewerker'van Megchelen', 'Supreme leader', 'Sv', 'Wadsm12i30sa', 'braadworst'
EXEC sp_InsertMedewerkerRolType 'lid'
EXEC sp_InsertMedewerkerRol 'Sv', 'lid'
EXEC sp_InsertProjectRolType 'betatester'
EXEC sp_insertProjectCategorie 'subsidie', NULL
EXEC sp_InsertProject 'AK', 'subsidie', '01-01-1900', '01-01-2300', 'ALLES KAPOT', 1300
EXEC sp_InsertMedewerkerOpProject 'AK', 'Sv', 'projectleider'
EXEC sp_InsertSubprojectCategorie @categorie_naam = 'submurlock'
EXEC sp_InsertSubproject @parent_code = 'AK', @naam = 'subways', @verwachte_uren = 10, @categorie = 'submurlock'
EXEC sp_InsertProjLidOpSubProj @medewerker_code = 'Sv', @project_code = 'AK', @subproject_naam = 'subways', @subproject_uren = 2
EXEC sp_InsertCategorieTag @tag_naam = 'Test'
EXEC sp_InsertTagVanCategorie @naam = 'subsidie', @tag_naam = 'Test'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--sp_InsertSubprojectCategorie
--faaltest
--Subprojectcategorie bestaat al.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertSubprojectCategorie @categorie_naam = 'beep'
EXEC sp_InsertSubprojectCategorie @categorie_naam = 'beep'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--sp_InsertSubproject
--faaltest
--Opgegeven subproject categorie naam bestaand niet.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertSubproject @parent_code = 'AK', @naam = 'subways', @verwachte_uren = 10, @categorie = 'submurlock'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

--sp_InsertSubproject
--faaltest
--Opgegeven hoofdprojectcode bestaat niet.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertSubprojectCategorie @categorie_naam = 'falafeltent'
EXEC sp_InsertSubproject @parent_code = 'AK', @naam = 'subways', @verwachte_uren = 10, @categorie = 'falafeltent'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--sp_InsertSubproject
--faaltest
--Verwachte uren van subprojecten mogen niet negatief zijn.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_insertProjectCategorie 'subsidie', NULL
EXEC sp_InsertProject 'AK', 'subsidie', '01-01-1900', '01-01-2300', 'ALLES KAPOT', 1300
EXEC sp_InsertSubprojectCategorie @categorie_naam = 'wafelkraam'
EXEC sp_InsertSubproject @parent_code = 'AK', @naam = 'subways', @verwachte_uren = -10, @categorie = 'wafelkraam'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

--sp_InsertProjLidOpSubProj
--faaltest
--Medewerker is niet aan het hoofdproject gekoppeld.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertProjLidOpSubProj @medewerker_code = 'Sv', @project_code = 'AzK', @subproject_naam = 'subways', @subproject_uren = 2
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--sp_InsertProjLidOpSubProj
--faaltest
--Verwachte uren voor een subproject mag niet negatief zijn.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertProjLidOpSubProj @medewerker_code = 'Sv', @project_code = 'AK', @subproject_naam = 'subways', @subproject_uren = -2
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO


--sp_InsertTagVanCategorie
--faaltest
--een tag die niet bestaat kan niet aan een categorie gekoppeld worden.
/*
CATCH RESULTATEN:
ERROR NUMMER:		50048
ERROR SEVERITY:	16
ERROR MESSAGE:	De ingevoerde tagnaam bestaat niet.
*/
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO categorie_tag (tag_naam)
	VALUES('GemaakteTag')
	INSERT INTO project_categorie(naam, hoofdcategorie)
	VALUES('Subsidie', NULL)
EXEC sp_InsertTagVanCategorie @naam = 'Subsidie', @tag_naam = 'Tag123'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO
