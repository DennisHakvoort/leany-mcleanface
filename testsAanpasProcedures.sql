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

--Test sp_WijzigenMedewerkerIngeplandProject
--Wijzig een medewerker_ingepland_project maand of ingedeelde uren
--Succes test
BEGIN TRANSACTION
BEGIN TRY
	IF (select IDENT_CURRENT('medewerker_op_project')) IS NOT NULL
	DBCC CHECKIDENT ('medewerker_op_project', RESEED,1);
	INSERT INTO medewerker VALUES ('cod95', 'Gebruiker7', 'Achternaam7');
	INSERT INTO medewerker_beschikbaarheid VALUES ('cod95', 'jan 2019', 12);
	INSERT INTO medewerker_rol_type VALUES ('DeaTeacher');
	INSERT INTO medewerker_rol VALUES ('cod95', 'DeaTeacher');
	INSERT INTO project_categorie VALUES ('HAN Arnhem', null);
	INSERT INTO project_categorie VALUES ('DEA_project', 'HAN Arnhem');
	INSERT INTO categorie_tag VALUES ('school');
	INSERT INTO tag_van_categorie VALUES ('DEA_project', 'school');
	INSERT INTO project VALUES ('DEA12', 'DEA_project', '11 jan 2019', '11 dec 2019', 'DEA_project_2018', 320);
	INSERT INTO project_rol_type VALUES ('CEO');
	INSERT INTO medewerker_op_project VALUES ('DEA12', 'cod95', 'CEO');
	INSERT INTO medewerker_ingepland_project VALUES (IDENT_CURRENT('medewerker_op_project'), 300, 'jan 2019');
	INSERT INTO medewerker_ingepland_project VALUES (IDENT_CURRENT('medewerker_op_project'), 100, 'feb 2019');
	
	DECLARE @id int = IDENT_CURRENT('medewerker_op_project');
	EXEC sp_WijzigenMedewerkerIngeplandProject @id, 211, 'jan 2019';
	SELECT * FROM medewerker_ingepland_project WHERE id = IDENT_CURRENT('medewerker_op_project')
END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
ROLLBACK TRANSACTION
GO

--Een medewerker_ingepland_project wijzigen die niet bestaat
--Faal test
--Msg 50080, Level 16, State 16, Procedure sp_WijzigenMedewerkerIngeplandProject, Line 20 [Batch Start Line 141]
--Er bestaat geen medewerker_ingepland_project record met de opgegeven id
BEGIN TRANSACTION
	SELECT * FROM medewerker_ingepland_project
	DECLARE @id int = IDENT_CURRENT('medewerker_op_project');
	EXEC sp_WijzigenMedewerkerIngeplandProject @id, 200, 'jan 2018';
ROLLBACK TRANSACTION
GO
