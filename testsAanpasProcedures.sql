USE LeanDB

GO
--Tests sp_WijzigCategorieen
--Insert toegestane data
--succesvol
BEGIN TRANSACTION
INSERT INTO project_categorie (naam, parent)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigCategorieen 'Onderwijs', 'Cursus', NULL
ROLLBACK TRANSACTION

GO
--Insert niet toegestane data
--Msg 50010, Level 16, State 16, Procedure sp_WijzigCategorieen, Line 20 [Batch Start Line 14]
--Deze categorie bestaat niet
BEGIN TRANSACTION
set xact_abort on
INSERT INTO project_categorie (naam, parent)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigCategorieen 'bestaat niet', 'Cursus', NULL
ROLLBACK TRANSACTION

--Tests sp_wijzigProjectRol
--wijzig een bestaande categorie
--Succesvol
BEGIN TRANSACTION
INSERT INTO project_rol_type
VALUES ('leider')
EXEC sp_WijzigProjectRol 'leider', 'supreme-leader'
ROLLBACK TRANSACTION

--Probeer een niet bestaande categorie te wijzigen
--Msg 50013, Level 16, State 16, Procedure sp_WijzigProjectRol, Line 19 [Batch Start Line 33]
--Projectrol bestaat niet.
BEGIN TRANSACTION
INSERT INTO project_rol_type
VALUES ('leider')
EXEC sp_WijzigProjectRol 'Megchelaar', 'supreme-leader'
ROLLBACK TRANSACTION

GO
--Tests sp_WijzigenMedewerkerRol
--Pas een bestaande medewerkerrol aan.
--succesvol
BEGIN TRANSACTION
INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
VALUES ('HM', 'Henk', 'Meh')
INSERT INTO medewerker_rol_type
VALUES ('leider')
INSERT INTO medewerker_rol_type
VALUES ('Meister')
INSERT INTO medewerker_rol(medewerker_code, medewerker_rol)
VALUES ('HM', 'leider')
EXEC sp_WijzigenMedewerkerRol 'HM', 'leider', 'Meister'
ROLLBACK TRANSACTION

GO
--pas een niet bestaande medewerker rol/medewerkercode cobinatie aan.
--Msg 50015, Level 16, State 16, Procedure sp_WijzigenMedewerkerRol, Line 22 [Batch Start Line 37]
--Medewerker in combinatie met deze rol bestaat niet.
BEGIN TRANSACTION
INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
VALUES ('HM', 'Henk', 'Meh')
INSERT INTO medewerker_rol_type
VALUES ('leider')
INSERT INTO medewerker_rol_type
VALUES ('Meister')
INSERT INTO medewerker_rol(medewerker_code, medewerker_rol)
VALUES ('HM', 'leider')
EXEC sp_WijzigenMedewerkerRol 'HL', 'leider', 'Meister'
ROLLBACK TRANSACTION

GO
--Tests sp_WijzigMedewerkerRolType
--Probeer toegestane data te wijzigen
--succesvol
BEGIN TRANSACTION
	INSERT INTO medewerker_rol_type
		VALUES ('admin')
	EXEC sp_WijzigMedewerkerRolType 'admin', 'super-user'
ROLLBACK TRANSACTION

GO
--Probeer een niet bestaande rol te wijzigen.
--Msg 50008, Level 16, State 16, Procedure sp_WijzigMedewerkerRolType, Line 21 [Batch Start Line 34]
--medewerkerrol bestaat niet.
BEGIN TRANSACTION
	INSERT INTO medewerker_rol_type
	VALUES ('admin')
	EXEC sp_WijzigMedewerkerRolType 'geen admin', 'super-user'
ROLLBACK TRANSACTION

GO
-- Test sp_wijzigbeschikbareDagen
-- Succes test
BEGIN TRANSACTION
	DECLARE @date DATETIME = getdate()

	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aa', 'anton', 'ameland');
	INSERT INTO medewerker_beschikbaarheid (medewerker_code, maand, beschikbare_dagen)
		VALUES ('aa', @date, 10)
	EXEC sp_WijzigBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
ROLLBACK TRANSACTION

GO
-- Test sp_wijzigbeschikbareDagen
-- faal test
-- Msg 500019, Level 16, State 16, Procedure sp_WijzignBeschikbareDagen, Line 22 [Batch Start Line 65]
-- Medewerker is in de opgegeven maand nog niet ingepland
BEGIN TRANSACTION
	DECLARE @date DATETIME = getdate()

	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aa', 'anton', 'ameland');	
  EXEC sp_WijzigBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
ROLLBACK TRANSACTION
GO

--Test sp_VerwijderenMedewerkerRolType
--Verwijder een medewerker_rol_type die niet in gebruik is
--Succes test
BEGIN TRANSACTION
	INSERT INTO medewerker_rol_type VALUES ('CEO');
	EXEC sp_VerwijderenMedewerkerRolType 'CEO'
ROLLBACK TRANSACTION
GO

--Een medewerker_rol_type die al aan een medewerker gekoppeld is kan niet verwijderd worden
--Msg 50029, Level 16, State 16, Procedure sp_VerwijderenMedewerkerRolType, Line 20 [Batch Start Line 118]
--een medewerker_rol_type in gebruik kan niet verwijderd worden.
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO medewerker VALUES ('aa123', 'Samir', 'Amed');
		INSERT INTO medewerker_rol_type VALUES ('Tester');
		INSERT INTO medewerker_rol VALUES ('aa123', 'Tester');
		EXEC sp_VerwijderenMedewerkerRolType 'Tester'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
ROLLBACK TRANSACTION
GO

--SP 9 Toevoegen SP aanpassen medewerker.
--Succes test
BEGIN TRANSACTION
INSERT INTO medewerker VALUES ('aa34F', 'Samir', 'WieDan')
EXEC sp_WijzigenMedewerker  'aa34F', 'Fatima', 'Ahmeeeeeed';
ROLLBACK TRANSACTION

--SP 9 Toevoegen SP aanpassen medewerker
--Faal test
--Msg 50028, 'een medewerker met dit medewerker_code bestaat niet.', 16
BEGIN TRANSACTION
EXEC sp_WijzigenMedewerker 'a1122', 'Fatima', 'Ahmed';
ROLLBACK TRANSACTION

GO
-- Test sp_aanpassenProject
-- succestest
BEGIN TRANSACTION
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, parent)
		VALUES ('werkschool', NULL);
	INSERT INTO project_categorie (naam, parent)
		VALUES ('wiskunde', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project AH', 'werkschool', GETDATE() + 30, GETDATE() +200);

	EXEC sp_WijzigProject @project_code = 'PROJAH01', @categorie_naam = 'wiskunde', @begin_datum = @date
		,@eind_datum = @einddatum, @project_naam = 'project LIDL', @verwachte_uren = 90
ROLLBACK TRANSACTION

GO
-- Test sp_aanpassenProject
-- faaltest
-- Msg 50066, Level 16, State 16, Procedure sp_WijzigProject
-- Opgegeven projectcode bestaat niet
BEGIN TRANSACTION
	DECLARE @date DATETIME = (getdate() + 10);
	DECLARE @einddatum DATETIME = (getdate() + 300);

	INSERT INTO project_categorie (naam, parent)
		VALUES ('Biochemie', NULL);
	INSERT INTO project_categorie (naam, parent)
		VALUES ('Scheikunde', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum)
		VALUES ('PROJAH01', 'project LODL', 'Biochemie', GETDATE() + 30, GETDATE() +200);

	EXEC sp_WijzigProject @project_code = 'PROJAH021', @categorie_naam = 'Scheikunde', @begin_datum = @date
		,@eind_datum = @einddatum, @project_naam = 'project LIDL', @verwachte_uren = 90
ROLLBACK TRANSACTION

--Tests sp_WijzigenMedewerkerOpProject
--Probeer een bestaande medewerker met project te wijzigen
--succesvol
BEGIN TRANSACTION
 INSERT INTO project_categorie (naam, parent)
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
ROLLBACK TRANSACTION

--Probeer een niet bestaande medewerker/ project combinatie aan te passen
--Msg 50019, Level 16, State 16, Procedure sp_WijzigenMedewerkerOpProject, Line 21 [Batch Start Line 92]
-- De medewerker met de opgegeven medewerker_code is niet aan dit project gekoppeld.
BEGIN TRANSACTION
 INSERT INTO project_categorie (naam, parent)
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
ROLLBACK TRANSACTION
