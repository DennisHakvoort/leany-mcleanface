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

--Test sp_VerwijderenMedewerkerRol
--Verwijder een medewerker_rol die gekoppelt is aan een medewerker
--Succes test
BEGIN TRANSACTION
	INSERT INTO medewerker VALUES ('cod98', 'Gebruiker1', 'Achternaam1');
	INSERT INTO medewerker_rol_type VALUES ('Android');
	INSERT INTO medewerker_rol VALUES ('cod98', 'Android');
	EXEC sp_VerwijderenMedewerkerRol 'cod98', 'Android'
	SELECT * FROM medewerker_rol_type
	SELECT * FROM medewerker_rol
ROLLBACK TRANSACTION
GO

--Een medewerker_rol die niet gekoppeld is aan de opgegeven medewerker_code kan niet verwijderd worden
--Faal test
--Msg 50096, Level 16, State 16, Procedure sp_VerwijderenMedewerkerRol, Line 20 [Batch Start Line 147]
--deze medewerker heeft niet de ingevoerde medewerker_rol.
BEGIN TRANSACTION
	INSERT INTO medewerker VALUES ('cod17', 'Gebruiker2', 'Achternaam2');
	INSERT INTO medewerker_rol_type VALUES ('Administrator');
	INSERT INTO medewerker_rol VALUES ('cod17', 'Administrator');

	EXEC sp_VerwijderenMedewerkerRol 'cod17', 'Leider'

	DELETE FROM medewerker_rol WHERE medewerker_code = 'cod17'
	DELETE FROM medewerker WHERE medewerker_code = 'cod17'
	DELETE FROM medewerker_rol_type WHERE medewerker_rol = 'Administrator'
ROLLBACK TRANSACTION
GO
