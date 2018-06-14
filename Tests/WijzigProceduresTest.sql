/*==================================================================*/
/* DBMS name:      Microsoft SQL Server 2008                        */
/* Created on:     05-06-2018 10:51:54                              */
/*==================================================================*/

/* Test uitvoeringen voor de wijzig procedures voor database LeanDb */

/*
Alle tests volgen dezelfde template:
securityadmin kan gebuirkers aanmaken
--zet hier de verwachte foutmelding neer of zet hier neer dat het een succesvolle test is.
BEGIN TRANSACTION --Open transaction, zodat de duivelse gedaanten van de tests de database niet ontheiligen.
BEGIN TRY
-- Test gaat hier
END TRY
BEGIN CATCH -- Wanneer er een error is gegooid in de test, wordt deze hier geprint.
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION --De transaction terugrollen zodat de testdata niet in de echte database terecht komt

Alle tests worden uitgevoerd op een lege database.
*/

USE LeanDB
GO

--Tests sp_WijzigProjectCategorie
--Insert toegestane data
--Succestest
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_categorie (naam, hoofdcategorie)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigProjectCategorie 'Onderwijs', 'Cursus', NULL
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een niet bestaande categorie te wijzigen
--Msg 50009, Level 16, State 16, Procedure sp_WijzigProjectCategorie, Line 20 [Batch Start Line 14]
--Deze projectcategorie bestaat niet.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
set xact_abort on
INSERT INTO project_categorie (naam, hoofdcategorie)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigProjectCategorie 'bestaat niet', 'Cursus', NULL
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_wijzigProjectRol
--wijzig een bestaande rol
--Succestest
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_rol_type
VALUES ('leider')
EXEC sp_WijzigProjectRol 'leider', 'supreme-leader'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een niet bestaande rol te wijzigen
--Msg 50013, Level 16, State 16, Procedure sp_WijzigProjectRol, Line 19 [Batch Start Line 33]
--Deze projectrol bestaat niet.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO project_rol_type
VALUES ('leider')
EXEC sp_WijzigProjectRol 'Megchelaar', 'supreme-leader'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerkerRolType
--Probeer toegestane data te wijzigen
--Succestest
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker_rol_type
		VALUES ('admin')
	EXEC sp_WijzigMedewerkerRolType 'admin', 'super-user'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een niet-bestaand medewerkerroltype te wijzigen.
--Msg 50008, Level 16, State 16, Procedure sp_WijzigMedewerkerRolType, Line 21 [Batch Start Line 34]
--Deze medewerkerrol bestaat niet.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker_rol_type
	VALUES ('admin')
	EXEC sp_WijzigMedewerkerRolType 'geen admin', 'super-user'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerkerBeschikbareDagen
--Beschikbare dagen in een maand voor een medewerker wijzigen.
-- Succestest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = getdate() +30

	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aa', 'anton', 'ameland');
	INSERT INTO medewerker_beschikbaarheid (medewerker_code, maand, beschikbare_dagen)
		VALUES ('aa', @date, 10)
	EXEC sp_WijzigMedewerkerBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigMedewerkerBeschikbareDagen
-- Msg 500019, Level 16, State 16, Procedure sp_WijzignBeschikbareDagen, Line 22 [Batch Start Line 65]
-- Deze medewerker heeft geen beschikbare werkdagen voor de opgegeven maand.
-- Faaltest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = getdate()

	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aa', 'anton', 'ameland');
  EXEC sp_WijzigMedewerkerBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerkerRol
--Verander de rol van een medewerker.
--Succestest
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
VALUES ('HM', 'Henk', 'Meh')
INSERT INTO medewerker_rol_type
VALUES ('leider')
INSERT INTO medewerker_rol_type
VALUES ('Meister')
INSERT INTO medewerker_rol(medewerker_code, medewerker_rol)
VALUES ('HM', 'leider')
EXEC sp_WijzigMedewerkerRol 'HM', 'leider', 'Meister'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--pas een niet bestaande medewerker rol/medewerkercode cobinatie aan.
--Msg 50015, Level 16, State 16, Procedure sp_WijzigMedewerkerRol, Line 22 [Batch Start Line 37]
--Medewerker in combinatie met deze rol bestaat niet.
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
VALUES ('HM', 'Henk', 'Meh')
INSERT INTO medewerker_rol_type
VALUES ('leider')
INSERT INTO medewerker_rol_type
VALUES ('Meister')
INSERT INTO medewerker_rol(medewerker_code, medewerker_rol)
VALUES ('HM', 'leider')
EXEC sp_WijzigMedewerkerRol 'HL', 'leider', 'Meister'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerkerOpProject
--Probeer een bestaande medewerker met project te wijzigen.
--Succestest
BEGIN TRANSACTION
BEGIN TRY
 INSERT INTO project_categorie (naam, hoofdcategorie)
 VALUES ('subsidie', NULL)
 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
 VALUES('BB', 'subsidie', '01-01-2001', '01-01-2020', 'BB')
 INSERT INTO project_rol_type
 VALUES ('leider')
 INSERT INTO project_rol_type
 VALUES ('meister')
 INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
 VALUES ('HB', 'Henk', 'Bruin')
 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
 VALUES ('BB', 'HB', 'meister')
 EXEC sp_WijzigMedewerkerOpProject 'BB', 'HB', 'leider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een niet bestaande medewerker/ project combinatie aan te passen
--Msg 50035, Level 16, State 16, Procedure sp_WijzigMedewerkerOpProject, Line 21 [Batch Start Line 92]
--De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
 INSERT INTO project_categorie (naam, hoofdcategorie)
 VALUES ('subsidie', NULL)
 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
 VALUES('BB', 'subsidie', '01-01-2001', '01-01-2020', 'BB')
 INSERT INTO project_rol_type
 VALUES ('leider')
 INSERT INTO project_rol_type
 VALUES ('meister')
 INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
 VALUES ('HB', 'Henk', 'Bruin')
 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
 VALUES ('BB', 'HB', 'meister')
 EXEC sp_WijzigMedewerkerOpProject 'Bk', 'HB', 'leider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerkerIngeplandProject
--Wijzig een medewerker_ingepland_project maand of ingedeelde uren
--Succestest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @maand_beschikbaar DATETIME = (GETDATE() + 40);

	INSERT INTO medewerker VALUES ('cod95', 'Gebruiker7', 'Achternaam7');
	INSERT INTO medewerker_beschikbaarheid VALUES ('cod95', @maand_beschikbaar, 12);
	INSERT INTO medewerker_rol_type VALUES ('DeaTeacher');
	INSERT INTO medewerker_rol VALUES ('cod95', 'DeaTeacher');
	INSERT INTO project_categorie VALUES ('HAN Arnhem', null);
	INSERT INTO project_categorie VALUES ('DEA_project', 'HAN Arnhem');
	INSERT INTO categorie_tag VALUES ('school');
	INSERT INTO tag_van_categorie VALUES ('DEA_project', 'school');
	INSERT INTO project VALUES ('DEA12', 'DEA_project', GETDATE() + 30, GETDATE() + 200, 'DEA_project_2018', 320);
	INSERT INTO project_rol_type VALUES ('CEO');
	INSERT INTO medewerker_op_project VALUES ('DEA12', 'cod95', 'CEO');
	INSERT INTO medewerker_ingepland_project VALUES (IDENT_CURRENT('medewerker_op_project'), 300, @maand_beschikbaar);
	
	EXEC sp_WijzigMedewerkerIngeplandProject 'cod95', 'DEA12', 77, @maand_beschikbaar;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Een medewerker_ingepland_project wijzigen die niet bestaat
--Msg 50034, Level 16, State 16, Procedure sp_WijzigMedewerkerIngeplandProject, Line 23 [Batch Start Line 137]
--Er bestaat geen medewerker_ingepland_project record met de opgegeven id.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @maand_beschikbaar DATETIME = (GETDATE() + 10);
	EXEC sp_WijzigMedewerkerIngeplandProject 'cod95', 'DEA12', 200, @maand_beschikbaar;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigMedewerker
--Wijzig een bestaande medewerker gegevens
--Succestest
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO medewerker VALUES ('aa34F', 'Samir', 'WieDan')
EXEC sp_WijzigMedewerker  'aa34F', 'Fatima', 'Ahmeeeeeed';
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een medewerker te wijzigen waar geen record van bestaat
--Msg 50028, 'een medewerker met dit medewerker_code bestaat niet.', 16
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
EXEC sp_WijzigMedewerker 'a1122', 'Fatima', 'Ahmed';
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigProject
--Wijzig een bestaande project
--Succestest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('werkschool', NULL);
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('wiskunde', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project AH', 'werkschool', GETDATE() + 30, GETDATE() +200);

	EXEC sp_WijzigProject @project_code = 'PROJAH01', @categorie_naam = 'wiskunde', @begin_datum = @date
		,@eind_datum = @einddatum, @project_naam = 'project LIDL', @verwachte_uren = 90
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Wijzig een niet bestaande project
--Msg 50027, Level 16, State 16, Procedure sp_WijzigProject
--Opgegeven projectcode bestaat niet.
--Faaltest
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('Biochemie', NULL);
	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('Scheikunde', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project LODL', 'Biochemie', GETDATE() + 30, GETDATE() +200);

	EXEC sp_WijzigProject @project_code = 'PROJAH021', @categorie_naam = 'Scheikunde', @begin_datum = @date
		,@eind_datum = @einddatum, @project_naam = 'project LIDL', @verwachte_uren = 90
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Tests sp_WijzigenMedewerkerOpProject
--Probeer een bestaande medewerker met project te wijzigen
--succesvol
BEGIN TRANSACTION
BEGIN TRY
 INSERT INTO project_categorie (naam, hoofdcategorie)
 VALUES ('subsidie', NULL)
 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
 VALUES('BB', 'subsidie', '01-01-2001', '01-01-2020', 'BB')
 INSERT INTO project_rol_type
 VALUES ('leider')
 INSERT INTO project_rol_type
 VALUES ('meister')
 INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
 VALUES ('HB', 'Henk', 'Bruin')
 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
 VALUES ('BB', 'HB', 'meister')
 EXEC sp_WijzigenMedewerkerOpProject 'BB', 'HB', 'leider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Probeer een niet bestaande medewerker/ project combinatie aan te passen
--Msg 50019, Level 16, State 16, Procedure sp_WijzigenMedewerkerOpProject, Line 21 [Batch Start Line 92]
-- De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.
BEGIN TRANSACTION
BEGIN TRY
 INSERT INTO project_categorie (naam, hoofdcategorie)
 VALUES ('subsidie', NULL)
 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
 VALUES('BB', 'subsidie', '01-01-2001', '01-01-2020', 'BB')
 INSERT INTO project_rol_type
 VALUES ('leider')
 INSERT INTO project_rol_type
 VALUES ('meister')
 INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
 VALUES ('HB', 'Henk', 'Bruin')
 INSERT INTO medewerker_op_project (project_code, medewerker_code, project_rol)
 VALUES ('BB', 'HB', 'meister')
 EXEC sp_WijzigenMedewerkerOpProject 'Bk', 'HB', 'leider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--sp_WijzigProjectlidOpSubproject
--success
BEGIN TRANSACTION
BEGIN TRY
	IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
		DBCC CHECKIDENT ('medewerker_op_project', RESEED, 0);
	INSERT INTO medewerker VALUES ('JP', 'Julie', 'Provost')
	INSERT INTO project_categorie VALUES ('cat', NULL)
	INSERT INTO project VALUES ('proj', 'cat', 'jan 2018', 'jan 2020', 'Groene thee', '12002')
	INSERT INTO project_rol_type VALUES ('projectleider')
	INSERT INTO medewerker_op_project VALUES ('proj', 'JP', 'projectleider')
	INSERT INTO subproject_categorie VALUES ('cat')
	INSERT INTO subproject VALUES ('proj', 'sub', 'cat', 12)
	INSERT INTO projectlid_op_subproject VALUES (1, 'proj', 'sub', 10)

	EXECUTE sp_WijzigProjectlidOpSubproject @medewerker_code = 'JP', @project_code = 'proj', @subproject_naam = 'sub', @nieuwe_uren = 9
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Deze combinatie van gebruiker en subproject bestaat niet.
BEGIN TRANSACTION
BEGIN TRY
	EXECUTE sp_WijzigProjectlidOpSubproject @medewerker_code = 'JP', @project_code = 'proj', @subproject_naam = 'sub', @nieuwe_uren = 9
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--test sp_WijzigSubprojectCategorie
--success
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO subproject_categorie VALUES ('cat')

	EXECUTE sp_WijzigSubprojectCategorie @categorieNaam = 'cat', @nieuweCategorieNaam = 'bat'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Deze categorie bestaat niet.
BEGIN TRANSACTION
BEGIN TRY
	EXECUTE sp_WijzigSubprojectCategorie @categorieNaam = 'cat', @nieuweCategorieNaam = 'bat'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Deze categorie wordt nog gebruikt door een subproject.
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO project_categorie VALUES ('cat', NULL)
	INSERT INTO project VALUES ('proj', 'cat', 'jan 2018', 'jan 2020', 'Groene thee', '12002')
	INSERT INTO subproject_categorie VALUES ('cat')
	INSERT INTO subproject VALUES ('proj', 'sub', 'cat', 12)
	EXECUTE sp_WijzigSubprojectCategorie @categorieNaam = 'cat', @nieuweCategorieNaam = 'bat'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigSubproject
--Succestest
--De naam van een subproject wordt veranderd van Testsub naar Subtest.
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('Biochemie', NULL);

	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project LODL', 'Biochemie', GETDATE() + 30, GETDATE() +200);

	INSERT INTO subproject_categorie (subproject_categorie_naam)
		VALUES('Biologie');

	INSERT INTO subproject (project_code, subproject_naam, subproject_categorie_naam, subproject_verwachte_uren)
		VALUES('PROJAH01', 'Testsub', 'Biologie', 12);

	EXEC sp_WijzigSubproject 'PROJAH01', 'Testsub', 'Subtest', 'Biologie', 12;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigSubproject
--Faaltest
--De projectcode die wordt meegegeven aan de procedure
--komt niet overeen met de daadwerkelijke projectcode.
/*
ERROR NUMMER:	50044
ERROR SEVERITY:	16
ERROR MESSAGE:	Dit subproject is niet gevonden.
*/
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, hoofdcategorie)
		VALUES ('Biochemie', NULL);

	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project LODL', 'Biochemie', GETDATE() + 30, GETDATE() +200);

	INSERT INTO subproject_categorie (subproject_categorie_naam)
		VALUES('Biologie');

	--Incorrecte projectcode
	INSERT INTO subproject (project_code, subproject_naam, subproject_categorie_naam, subproject_verwachte_uren)
		VALUES('PROJAH01', 'Testsub', 'Biologie', 12);

	EXEC sp_WijzigSubproject 'PROJAH00', 'Testsub', 'Subtest', 'Biologie', 12;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigCategorieTag
--Succestest, een tag wordt toegevoegd zonder foutmelding
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO categorie_tag(tag_naam) --eerst wordt een tag toegevoegd
		VALUES('Test')

	EXECUTE sp_WijzigCategorieTag @tag_naam_oud = 'Test', @tag_naam_nieuw = 'Testosti' --hier wordt de tag gewijzigd
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Stored Procedure sp_WijzigCategorieTag
--Faaltest, oude tagnaam foutief
/*
CATCH RESULTATEN:
ERROR NUMMER:	50052
ERROR SEVERITY:	16
ERROR MESSAGE:	De te wijzigen tag is niet gevonden.
*/
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO categorie_tag(tag_naam) --eerst wordt een tag toegevoegd
		VALUES('Test')

	EXECUTE sp_WijzigCategorieTag @tag_naam_oud = 'Toest'/*in plaats van Test*/, @tag_naam_nieuw = 'Testosti' --nu wordt de tag niet gewijzigd
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigTagVanCategorie
--Succestest
--Een tag van een categorie wordt succesvol gewijzigd
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO categorie_tag(tag_naam) --eerst wordt een tag toegevoegd
	VALUES('TestTag');
	INSERT INTO categorie_tag(tag_naam)
	VALUES ('Test');
	INSERT INTO project_categorie(naam, hoofdcategorie)
	VALUES('Subsidie', NULL);
	INSERT INTO project_categorie(naam, hoofdcategorie)
	VALUES('Training', 'Subsidie');
	INSERT INTO tag_van_categorie(naam, tag_naam)
	VALUES('Training', 'TestTag');

	EXECUTE sp_WijzigTagVanCategorie @tag_naam_oud = 'TestTag', @tag_naam_nieuw = 'Test', @naam = 'Training';
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_WijzigTagVanCategorie
--Faaltest
--Een tag van een categorie proberen te wijzigen waar de opgegeven combinatie naam en tagnaam geen record van bestaan.
/*
CATCH RESULTATEN:
ERROR NUMMER:		50053
ERROR SEVERITY:	16
ERROR MESSAGE:	De te wijzigen tag van het opgegeven categorie bestaat niet.
*/
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO categorie_tag(tag_naam) --eerst wordt een tag toegevoegd
	VALUES('TestTag');
	INSERT INTO categorie_tag(tag_naam)
	VALUES ('Test');
	INSERT INTO project_categorie(naam, hoofdcategorie)
	VALUES('Subsidie', NULL);
	INSERT INTO project_categorie(naam, hoofdcategorie)
	VALUES('Training', 'Subsidie');
	INSERT INTO tag_van_categorie(naam, tag_naam)
	VALUES('Training', 'TestTag');

	EXECUTE sp_WijzigTagVanCategorie @tag_naam_oud = 'Tag17' /* niet bestaande tagnaam opgeven */ , @tag_naam_nieuw = 'Test', @naam = 'Training';
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO