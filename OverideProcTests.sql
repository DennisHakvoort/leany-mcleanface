/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     06-06-2018 10:51:54                              */
/*==================================================================*/

/* Stored procedures tests voor insertProcedures.sql bestand        */


/*
Alle tests volgen hetzelfde template:

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
EXEC sp_InsertMedewerkerRolType 'Tester'
EXEC sp_MedewerkerToevoegen 'van Megchelen', 'Supreme leader', 'Sv', 'WachtwoordTest123', 'Tester'
EXEC sp_InsertProjectRolType 'projectleider'
EXEC sp_insertProjectCategorie 'subsidie', NULL
EXEC sp_InsertProject 'AK', 'subsidie', '01-01-1900', '01-01-2300', 'ALLES KAPOT', 1300
EXEC sp_InsertMedewerkerOpProject 'AK', 'Sv', 'projectleider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

