/*
Alle tests volgen hetzelfde template:

--De error die hij geeft of dat hij goed gaat.
BEGIN TRANSACTION --Open transaction, zodat de test niet de echte database beïnvloed
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

--Runt alle insert procedures.
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_MedewerkerToevoegen 'van Megchelen', 'Supreme leader', 'Sv'
EXEC sp_InsertMedewerkerRolType 'lid'
EXEC sp_InsertMedewerkerRol 'Sv', 'lid'
EXEC sp_InsertProjectRolType 'projectleider'
EXEC sp_insertProjectCategorie 'subsidie', NULL
EXEC sp_InsertProject 'AK', 'subsidie', '01-01-1900', '01-01-2300', 'ALLES KAPOT'
EXEC sp_InsertMedewerkerOpProject 'AK', 'Sv', 'projectleider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION