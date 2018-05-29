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
--Insert niet toegestaane data
--Msg 50010, Level 16, State 16, Procedure sp_WijzigCategorieen, Line 20 [Batch Start Line 14]
--Deze categorie bestaat niet
BEGIN TRANSACTION
set xact_abort on
INSERT INTO project_categorie (naam, parent)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigCategorieen 'bestaat niet', 'Cursus', NULL
ROLLBACK TRANSACTION

GO
--Tests sp_WijzigenMedewerkerRol
--Pas een bestaande medewerker rol aan.
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
--pas een niet bestaande medewerker rol/medewerker code cobinatie aan.
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
--medewerker rol bestaat niet.
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
	EXEC sp_WijzignBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
ROLLBACK TRANSACTION

GO
-- Test sp_wijzigbeschikbareDagen
-- faal test
-- Msg 500019, Level 16, State 16, Procedure sp_WijzignBeschikbareDagen, Line 22 [Batch Start Line 65]
-- Mederwerker is in de opgegeven maand nog niet ingepland
BEGIN TRANSACTION
	DECLARE @date DATETIME = getdate()

	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('aa', 'anton', 'ameland');	
	EXEC sp_WijzignBeschikbareDagen @medewerker_code = 'aa', @maand = @date, @beschikbare_dagen = 20;
	select * from medewerker_beschikbaarheid
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
	INSERT INTO medewerker VALUES ('aa123', 'Samir', 'Amed');
	INSERT INTO medewerker_rol_type VALUES ('Tester');
	INSERT INTO medewerker_rol VALUES ('aa123', 'Tester');
	EXEC sp_VerwijderenMedewerkerRolType 'Tester'
ROLLBACK TRANSACTION
GO
