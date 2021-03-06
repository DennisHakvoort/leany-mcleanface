/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     5-6-2018 10:12:47                            */
/*==============================================================*/

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


--Business rules tests

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--Success
BEGIN TRANSACTION
BEGIN TRY
DECLARE @date DATE = GETDATE()+30;
DECLARE @date2 DATE = GETDATE()+60;
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date, 10);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date2, 20);
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
--[23000][547] The INSERT statement conflicted with the CHECK constraint "CK_UREN_MIN_MAX". The conflict occurred in database "LeanDb", table "dbo.medewerker_beschikbaarheid", column 'beschikbaar_uren'.
BEGIN TRANSACTION
BEGIN TRY
DECLARE @date DATE = GETDATE()+30;
DECLARE @date2 DATE = GETDATE()+60;
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date, 1000);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date2, 820);
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
--Success
BEGIN TRANSACTION
BEGIN TRY
DECLARE @date DATE = GETDATE()+30;
DECLARE @date2 DATE = GETDATE()+60;
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date, 10);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date2, 15);
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
--[23000][547] The INSERT statement conflicted with the CHECK constraint "CK_UREN_MIN_MAX". The conflict occurred in database "LeanDb", table "dbo.medewerker_beschikbaarheid", column 'beschikbaar_uren'.
BEGIN TRANSACTION
BEGIN TRY
DECLARE @date DATE = GETDATE()+30;
DECLARE @date2 DATE = GETDATE()+60;
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date, -1);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', @date2, -80);
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR3
--Succes test
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker_rol_type VALUES ('test')
EXEC sp_InsertMedewerker @achternaam = 'jan', @voornaam = 'peter', @medewerker_code = 'aaaaa', @wachtwoord = 'Wachtwoord123', @rol = 'test'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR3
--[S00016][500014] Medewerker code is al in gebruik
--[50014] Medewerker code is al in gebruik
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker_rol_type VALUES ('test')
EXEC sp_InsertMedewerker @achternaam = 'jan', @voornaam = 'peter', @medewerker_code = 'aa', @wachtwoord = 'Wachtwoord123', @rol = 'test'
EXEC sp_InsertMedewerker @achternaam = 'jan', @voornaam = 'peter', @medewerker_code = 'aa', @wachtwoord = 'Wachtwoord123', @rol = 'test'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--[S00016][50020] Dit is geen bestaande rol
BEGIN TRANSACTION --werken allemaal
BEGIN TRY
EXEC sp_InsertMedewerker @achternaam = 'jan', @voornaam = 'peter', @medewerker_code = 'GVDS', @wachtwoord = 'Wachtwoord123', @rol = 'test'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR5 Faal Test - negatieve waarden
BEGIN TRANSACTION
	BEGIN TRY	
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');
	
		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C1', 'aa', 'lector');

		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C2', 'aa', 'lector');

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project')), 10, CONVERT(date, @date));

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project'))-1, 10, CONVERT(date, @date));
		EXEC sp_insertProjecturenMedewerker @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = -10, @maand_datum = @date
		PRINT 'test mislukt'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR5 Faal Test - over de limit
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');

		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C1', 'aa', 'lector');

		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C2', 'aa', 'lector');

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project')), 10, CONVERT(date, @date));

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project'))-1, 10, CONVERT(date, @date));
		
		EXEC sp_insertProjecturenMedewerker @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 1000, @maand_datum = @date
		PRINT 'test mislukt'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR5 Succes Test
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C11', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C21', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');
	
		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C11', 'aa', 'lector');

		INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
			VALUES	('PROJC0101C21', 'aa', 'lector');
			
		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project')) -1, 10, CONVERT(date, @date));
		
		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	((select IDENT_CURRENT('medewerker_op_project')), 10, CONVERT(date, @date));
		EXEC sp_insertProjecturenMedewerker @medewerker_code = 'aa', @project_code = 'PROJC0101C11', @medewerker_uren = 10, @maand_datum = @date
		PRINT 'test succesvol'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR5 FAAL TEST
--Totaal geplande uren van de medewerker is meer dan 184 uur
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO MEDEWERKER (MEDEWERKER_CODE, VOORNAAM, ACHTERNAAM)
VALUES ('GB', 'Gertruude', 'van Barneveld')
INSERT INTO PROJECT_CATEGORIE (naam, hoofdcategorie)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT (PROJECT_CODE, categorie_naam, BEGIN_DATUM, EIND_DATUM, PROJECT_NAAM)
VALUES ('PR', 'subsidie', '01-01-1990', '01-01-2100', 'test project')
INSERT INTO PROJECT_ROL_TYPE (project_rol)
VALUES ('baas')
INSERT INTO MEDEWERKER_OP_PROJECT (PROJECT_CODE, MEDEWERKER_CODE, PROJECT_ROL)
VALUES ('PR', 'GB', 'baas')
INSERT INTO MEDEWERKER_BESCHIKBAARHEID (MEDEWERKER_CODE, maand, beschikbare_dagen)
VALUES ('GB', '01-03-2022', 1)
EXEC sp_InsertProjecturenMedewerker 'GB', 'PR', 1, '01-03-2022'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--insert geplande uren voor iemand die geen uren beschikbaar heeft in een maand.
-- error: Msg 50006, Level 16, State 16, Procedure medewerkerNietInplannenAlsNietBeschikbaar, Line 21 [Batch Start Line 60]
--Medewerker heeft geen beschikbare uren en kan dus niet ingepland worden
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO MEDEWERKER (MEDEWERKER_CODE, VOORNAAM, ACHTERNAAM)
VALUES ('GB', 'Gertruude', 'van Barneveld')
INSERT INTO PROJECT_CATEGORIE (naam, hoofdcategorie)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT (PROJECT_CODE, categorie_naam, BEGIN_DATUM, EIND_DATUM, PROJECT_NAAM)
VALUES ('PR', 'subsidie', '01-01-1990', '01-01-2100', 'test project')
INSERT INTO PROJECT_ROL_TYPE (project_rol)
VALUES ('baas')
INSERT INTO MEDEWERKER_OP_PROJECT (PROJECT_CODE, MEDEWERKER_CODE, PROJECT_ROL)
VALUES ('PR', 'GB', 'baas')
INSERT INTO MEDEWERKER_BESCHIKBAARHEID (MEDEWERKER_CODE, maand, beschikbare_dagen)
VALUES ('GB', '01-03-2022', 0)
EXEC sp_InsertProjecturenMedewerker 'G', 'PR', 1, '01-03-2021'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Faal test
--Invalide invoerwaarde - negatieve uren
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_InsertProjecturenMedewerker 'G', 'PR', -1, '01-03-2021'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO


-- BR7 Faal Test - single insert
-- The INSERT statement conflicted with the CHECK constraint "CK_EINDDATUM_NA_BEGINDATUM". The conflict occurred in database "LeanDb", table "dbo.project".
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam');
		PRINT 'Test mislukt'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR7 Faal test multi insert - 1 geldig 1 ongeldig
-- The INSERT statement conflicted with the CHECK constraint "CK_EINDDATUM_NA_BEGINDATUM". The conflict occurred in database "LeanDb", table "dbo.project".
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam'); -- geldig data
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99998P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam'); -- ongeldig data
		PRINT 'Test mislukt'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR7 Succes Test single insert
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		PRINT 'test succesvol'
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
ROLLBACK
GO

-- BR7 Succes Test multi inserts
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, hoofdcategorie)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99998P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam2');
		PRINT 'test succesvol'
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
	
ROLLBACK
GO

--tests voor BR8 Voeg een hoofdcategorie toe.
--gaat goed
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--voeg een subcategorie met een niet bestaande hoofdcategorie toe
--Geeft error 50003 [2018-05-09 11:56:40] [S00016][50003] Deze subcategorie heeft geen geldige hoofdcategorie
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO PROJECT_CATEGORIE
VALUES ('school', 'onderwijs')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--voeg een subcategorie toe met een bestaande hoofdcategorie
--gaat goed
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO PROJECT_CATEGORIE (naam, hoofdcategorie)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE (naam, hoofdcategorie)
VALUES ('bedrijf1', 'subsidie')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--verwijder een hoofdcategorie die een subcategorie bevat.
--Geeft error [50002] Kan geen categorie met met subcategoriën verwijderen
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE
VALUES ('bedrijf1', 'subsidie')
DELETE FROM PROJECT_CATEGORIE
WHERE naam = 'subsidie'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Verwijdert een subcategorie met geldige hoofdcategorie.
--gaat goed
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE
VALUES ('bedrijf1', 'subsidie')
DELETE FROM PROJECT_CATEGORIE
WHERE naam = 'bedrijf1'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR9 BR9 De waarden van project, medewerker op project en medewerker_ingepland_project
-- kunnen niet meer worden aangepast als project(eind_datum) is verstreken,
-- Project
-- Success
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest', 0)
UPDATE project SET begin_datum = '23 sep 2018' WHERE project_code = 1
DELETE FROM project WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2018', '22 feb 2018', 'testerdetest', 0)
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2016', '22 feb 2019', 'testerdetest', 0)
UPDATE project SET eind_datum = '23 sep 2017' WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2017', CURRENT_TIMESTAMP, 'testerdetest', 0)
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
UPDATE project SET eind_datum = '27 feb 2020' WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2016', '22 feb 2019', 'testerdetest', 0)
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
DELETE FROM project WHERE project_code = 1
INSERT INTO project VALUES (1, 'd', '15 jan 2016', '22 feb 2019', 'testerdetest', 0)
UPDATE project SET eind_datum = '23 sep 2017' WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

---------------------
-- Medewerker_ingepland_project
-- Success
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
	VALUES (1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((select IDENT_CURRENT('medewerker_op_project')), 10, 'feb 2019')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', CURRENT_TIMESTAMP, 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
INSERT INTO medewerker_ingepland_project VALUES ((select IDENT_CURRENT('medewerker_op_project')), 10, 'feb 2019')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
/*
CATCH RESULTATEN:
ERROR NUMMER:		50001
ERROR SEVERITY:	16
ERROR MESSAGE:	Een project kan niet meer aangepast worden nadat deze is afgelopen.
*/
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((select IDENT_CURRENT('medewerker_op_project')), 10, 'feb 2019')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
UPDATE medewerker_ingepland_project SET medewerker_uren = 10 WHERE id = (select IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
/*
CATCH RESULTATEN:
ERROR NUMMER:		50004
ERROR SEVERITY:	16
ERROR MESSAGE:	Een project kan niet meer aangepast worden nadat deze is afgelopen.
*/
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((select IDENT_CURRENT('medewerker_op_project')), 10, 'feb 2019')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
DELETE FROM medewerker_ingepland_project WHERE id = (select IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- medewerker_op_project
-- Success
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
/*
CATCH RESULTATEN:
ERROR NUMMER:		50005
ERROR SEVERITY:	16
ERROR MESSAGE:	Een medewerker op een project kan niet meer aangepast worden nadat deze is afgelopen.
*/
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', CURRENT_TIMESTAMP, 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2017', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker VALUES ('JD', 'Jan', 'Dieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
UPDATE medewerker_op_project SET medewerker_code = 'JD' WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2017', 'testerdetest', 0)
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 'JP', 'tester')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01' --hier wordt een delay geplaatst zodat er geen conflict kan ontstaan door de CURRENT_TIMESTAMP
DELETE FROM medewerker_op_project WHERE project_code = 1
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR10 medewerker_beschikbaarheid kan niet worden aangepast als medewerker_beschikbaarheid(maand) is verstreken.
-- Succesvol insert nieuwe medewerker_beschikbaarheid datum (moet nieuwer dan huidige datum zijn).
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '10 sep 2018', '10')
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Succesvol medewerker_beschikbaarheid maand updaten toegestaan als die groter is dan huidige datum.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '10 sep 2018', '10')
UPDATE medewerker_beschikbaarheid SET maand = '10 jan 2019' WHERE medewerker_code = 'HF'
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukte poging
--[500016][50001] maand data kan niet aangepast worden naar een verstreken maand.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '25 may 2018', '10')
UPDATE medewerker_beschikbaarheid SET maand = '10 jan 2018' WHERE medewerker_code = 'HF'
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukte poging
--[500016][50001] je mag niet een maand als beschikbaarheid instellen als de ingevulde maand verstreken is.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '25 may 2017', '10')
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR11 medewerker_ingepland_project kan niet meer worden aangepast als medewerker_ingepland_project(maand_datum) is verstreken
--BR 11 Success
--Medewerker uren kunnen aangepast worden voor huidige datum en toekomstige tijdstip.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'jul 2018' WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Success
--Medewerker kan ingedeeld worden in een project als de maand groter is dan huidige datum.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 succesvol uren van een maand aanpassen dat nog niet verstreken is
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET medewerker_uren = '20' WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Mislukte poging
--[500016][50001] medewerker verstreken maand(en) kunnen niet meer aangepast worden.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'feb 2018' WHERE id = (select IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Mislukte poging
--[500016][50001] medewerker kan niet een verstreken maand ingepland krijgen voor een project.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2017')
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR10 medewerker_beschikbaarheid kan niet worden aangepast als medewerker_beschikbaarheid(maand) is verstreken.
-- Succesvol insert nieuwe medewerker_beschikbaarheid datum (moet nieuwer dan huidige datum zijn).
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '10 sep 2018', '10')
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Succesvol medewerker_beschikbaarheid maand updaten toegestaan als die groter is dan huidige datum.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '10 sep 2018', '30')
UPDATE medewerker_beschikbaarheid SET maand = '10 jan 2019' WHERE medewerker_code = 'HF'
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukte poging
--[500016][50001] maand data kan niet aangepast worden naar een verstreken maand.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '25 may 2018', '10')
UPDATE medewerker_beschikbaarheid SET maand = '10 jan 2018' WHERE medewerker_code = 'HF'
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Mislukte poging
--[500016][50001] je mag niet een maand als beschikbaarheid instellen als de ingevulde maand verstreken is.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('HF', 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES ('HF', '25 may 2017', '10')
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 'HF'
DELETE FROM medewerker WHERE medewerker_code = 'HF'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR11 medewerker_ingepland_project kan niet meer worden aangepast als medewerker_ingepland_project(maand_datum) is verstreken
--BR 11 Success
--Medewerker uren kunnen aangepast worden voor huidige datum en toekomstige tijdstip.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'jul 2018' WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Success
--Medewerker kan ingedeeld worden in een project als de maand groter is dan huidige datum.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 succesvol uren van een maand aanpassen dat nog niet verstreken is
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET medewerker_uren = '20' WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Mislukte poging
--[500016][50001] medewerker verstreken maand(en) kunnen niet meer aangepast worden.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'feb 2018' WHERE id = (select IDENT_CURRENT('medewerker_op_project'))
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR 11 Mislukte poging
--[500016][50001] medewerker kan niet een verstreken maand ingepland krijgen voor een project.
BEGIN TRANSACTION
BEGIN TRY
IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES ('proj1049', 'training', '15 jan 2018', '12 dec 2018', 'testproject', 0)
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES ('HFQWE', 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES ('proj1049', 'HFQWE', 'tester')
INSERT INTO medewerker_ingepland_project VALUES ((SELECT IDENT_CURRENT('medewerker_op_project')), 30, 'jun 2017')
DELETE FROM medewerker_ingepland_project WHERE id = (SELECT IDENT_CURRENT('medewerker_op_project'))
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR14 De beschikbaarheid van een medewerker kan maar wordt per maand opgegeven.
-- faal test in het verleden invullen
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO medewerker VALUES ('JD', 'Jan', 'Dieter')
		EXEC sp_InsertBeschikbareDagen @medewerker_code = 'JD', @maand = '1900-01-01', @beschikbare_dagen = 20
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR14 De beschikbaarheid van een medewerker kan maar wordt per maand opgegeven.
-- succes test invullen beschikbaarheid van de medewerker
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = GETDATE();
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('BR', 'Boris', 'Brilmans')
	EXEC sp_InsertBeschikbareDagen @medewerker_code = 'BR', @maand = @date, @beschikbare_dagen = 20
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR14 De beschikbaarheid van een medewerker kan maar wordt per maand opgegeven.
-- faal test zelfde maand invullen
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();
		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('BRN', 'Borido', 'Borisen')
		EXEC sp_InsertBeschikbareDagen @medewerker_code = 'BR', @maand = @date, @beschikbare_dagen = 20
		EXEC sp_InsertBeschikbareDagen @medewerker_code = 'BR', @maand = @date, @beschikbare_dagen = 20
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR15 Begin_datum van een project mag niet worden aangepast als een medewerker is ingepland in dezelfde maand of een medewerker is ingepland voor de nieuwe begin_datum.
-- succes test
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATE = GETDATE()
	DECLARE @einddatum DATE = GETDATE() +300
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('KB01', 'Kean', 'Bergmans');
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('school', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('projo0321', 'beste project', 'school', @date, @einddatum, 10)
	INSERT INTO project_rol_type (project_rol)
		VALUES ('notulist');
	INSERT INTO medewerker_op_project (medewerker_code, project_code, project_rol)
		VALUES ('KB01', 'projo0321', 'notulist');
	INSERT INTO medewerker_ingepland_project (id, maand_datum, medewerker_uren)
		VALUES (IDENT_CURRENT('medewerker_op_project'), (@date), 10);
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR15 Begin_datum van een project mag niet worden aangepast als een medewerker is ingepland in dezelfde maand of een medewerker is ingepland voor de nieuwe begin_datum.
-- faal test
-- Msg 50025, Level 16, State 16, Procedure trg_UpdateBegindatumValtNaIngeplandMedewerker, Line 15 [Batch Start Line 873]
-- Begindatum mag niet worden aangepast als het project is gestart
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATE = GETDATE() -100
	DECLARE @einddatum DATE = GETDATE() +300
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('WB02', 'Wouter', 'Bosh');
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('school', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('projo0321', 'beste project', 'school', @date, @einddatum, 10);
	UPDATE PROJECT
	SET begin_datum = GETDATE() +20
	WHERE project_code = 'projo0321'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR15 Begin_datum van een project mag niet worden aangepast als een medewerker is ingepland in dezelfde maand of een medewerker is ingepland voor de nieuwe begin_datum.
-- faal test
-- Msg 50023, Level 16, State 16, Procedure trg_UpdateBegindatumValtNaIngeplandMedewerker, Line 23 [Batch Start Line 892]
-- Begindatum kan niet worden aangepast. Een medewerker is al ingepland voor de begindatum.
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATE = GETDATE() +100
	DECLARE @einddatum DATE = GETDATE() +300
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('RZK1', 'Rudolf', 'Bergmans');
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('school', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('projo0321', 'beste project', 'school', @date, @einddatum, 10)
	INSERT INTO project_rol_type (project_rol)
		VALUES ('notulist');
	INSERT INTO medewerker_op_project (medewerker_code, project_code, project_rol)
		VALUES ('RZK1', 'projo0321', 'notulist');
	INSERT INTO medewerker_ingepland_project (id, maand_datum, medewerker_uren)
		VALUES (IDENT_CURRENT('medewerker_op_project'), (@date), 10);

	UPDATE PROJECT
	SET begin_datum = GETDATE() +20
	WHERE project_code = 'projo0321'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR16 Einddatum voor een project mag alleen verlengt worden.
-- succes test
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATE = GETDATE() +100
	DECLARE @einddatum DATE = GETDATE() +300
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('BB10', 'Berend', 'Botje');
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('school', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('projo0321', 'beste project', 'school', @date, @einddatum, 10);

	UPDATE PROJECT
	SET eind_datum = GETDATE() +400
	WHERE project_code = 'projo0321'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR16 Einddatum voor een project mag alleen verlengt worden.
-- faal test
-- Msg 50024, Level 16, State 16, Procedure trg_UpdateEinddatumAlleenVerlengen, Line 14 [Batch Start Line 931]
-- Nieuwe eind datum valt voor de oude eind datum.
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATE = GETDATE() +100
	DECLARE @einddatum DATE = GETDATE() +300
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('MM99', 'Meep', 'Meepster');
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('school', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('projo0321', 'beste project', 'school', @date, @einddatum, 10);

	UPDATE PROJECT
	SET eind_datum = GETDATE() +200
	WHERE project_code = 'projo0321'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR17 Een medewerker heeft een mandatory child in medewerker_rol
-- succes test
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('EAM99', 'Elizabeth', 'Alexandra Mary');
	INSERT INTO medewerker_rol_type (medewerker_rol)
		VALUES ('Queen');
	INSERT INTO medewerker_rol_type (medewerker_rol)
		VALUES ('Empress');
	INSERT INTO medewerker_rol (medewerker_code, medewerker_rol)
		VALUES ('EAM99', 'Queen');
	INSERT INTO medewerker_rol (medewerker_code, medewerker_rol)
		VALUES ('EAM99', 'Empress');

	DELETE FROM medewerker_rol
	WHERE medewerker_code = 'EAM99' AND medewerker_rol = 'Empress'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- BR17 Een medewerker heeft een mandatory child in medewerker_rol
-- faal test
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('JL37', 'Johan', 'Lunde');
	INSERT INTO medewerker_rol_type (medewerker_rol)
		VALUES ('Bishop');
	INSERT INTO medewerker_rol (medewerker_code, medewerker_rol)
		VALUES ('JL37', 'Bishop');

	DELETE FROM medewerker_rol
	WHERE medewerker_code = 'JL37' AND medewerker_rol = 'Bishop'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--BR18
--Success omdat hij projectleider is
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker_rol_type VALUES ('Medewerker')
EXECUTE sp_InsertMedewerker @achternaam = 'Peterson', @voornaam = 'Johnson', @medewerker_code = 'jope', @wachtwoord = 'VeiligWachtw00rd', @rol = 'Medewerker';
INSERT INTO project_rol_type VALUES ('Projectleider')
INSERT INTO project_categorie VALUES ('cat', NULL)
INSERT INTO project VALUES ('test', 'cat', 'jan 2019', 'feb 2020', 'testproject', 12)
INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol) VALUES ('test', 'jope', 'Projectleider')
EXECUTE AS USER = 'jope'
EXECUTE sp_checkProjectRechten @projectcode = 'test'
REVERT
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
REVERT
ROLLBACK TRANSACTION
GO

--Succes omdat hij superuser is.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker_rol_type VALUES ('Superuser')
EXECUTE sp_InsertMedewerker @achternaam = 'Peterson', @voornaam = 'Johnson', @medewerker_code = 'jope', @wachtwoord = 'VeiligWachtw00rd', @rol = 'Superuser';
INSERT INTO project_rol_type VALUES ('Programmeuse')
INSERT INTO project_categorie VALUES ('cat', NULL)
INSERT INTO project VALUES ('test', 'cat', 'jan 2019', 'feb 2020', 'testproject', 12)
INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol) VALUES ('test', 'jope', 'Programmeuse')
EXECUTE AS USER = 'jope'
EXECUTE sp_checkProjectRechten @projectcode = 'test'
REVERT
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
REVERT
ROLLBACK TRANSACTION
GO

--Faal omdat hij geen projectleider of superuser is.
--[S00016][50033] De huidige gebruiker heeft de rechten niet om dit project aan te passen
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker_rol_type VALUES ('Medewerker')
EXECUTE sp_InsertMedewerker @achternaam = 'Peterson', @voornaam = 'Johnson', @medewerker_code = 'jope', @wachtwoord = 'VeiligWachtw00rd', @rol = 'Medewerker';
INSERT INTO project_rol_type VALUES ('Programmeuse')
INSERT INTO project_categorie VALUES ('cat', NULL)
INSERT INTO project VALUES ('test', 'cat', 'jan 2019', 'feb 2020', 'testproject', 12)
INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol) VALUES ('test', 'jope', 'Programmeuse')
EXECUTE AS USER = 'jope'
EXECUTE sp_checkProjectRechten @projectcode = 'test'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
REVERT
ROLLBACK TRANSACTION
GO

--BR18 unique-test
--succestest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = GETDATE()
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aber', 'Amon', 'Adelaar');

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES	('onderwijs', null);

	INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

	INSERT INTO project_rol_type (project_rol)
		VALUES	('lector');
	
	INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
		VALUES	('PROJC0101C1', 'aber', 'lector');
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

--BR18 unique-test
--faaltest
--Violation of UNIQUE KEY constraint 'UC_Medewerker_Project_Code'
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = GETDATE()
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aber', 'Amon', 'Adelaar');

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES	('onderwijs', null);

	INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

	INSERT INTO project_rol_type (project_rol)
		VALUES	('lector');
	
	INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
		VALUES	('PROJC0101C1', 'aber', 'lector');
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO