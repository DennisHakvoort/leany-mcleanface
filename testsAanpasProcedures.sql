--Tests sp_WijzigCategorieen

--Insert toegestane data
--succesvol
BEGIN TRANSACTION
INSERT INTO project_categorie (naam, parent)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigCategorieen 'Onderwijs', 'Cursus', NULL
ROLLBACK TRANSACTION


--Insert niet toegestaane data
--Msg 50010, Level 16, State 16, Procedure sp_WijzigCategorieen, Line 20 [Batch Start Line 14]
--Deze categorie bestaat niet
BEGIN TRANSACTION
INSERT INTO project_categorie (naam, parent)
VALUES ('subsidie', NULL),
	   ('Onderwijs', 'subsidie')
EXEC sp_WijzigCategorieen 'bestaat niet', 'Cursus', NULL
ROLLBACK TRANSACTION

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


--Tests sp_WijzigMedewerkerRolType

--Probeer toegestane data te wijzigen
--succesvol
BEGIN TRANSACTION
 INSERT INTO medewerker_rol_type
 VALUES ('admin')
 EXEC sp_WijzigMedewerkerRolType 'admin', 'super-user'
ROLLBACK TRANSACTION

--Probeer een niet bestaande rol te wijzigen.
--Msg 50008, Level 16, State 16, Procedure sp_WijzigMedewerkerRolType, Line 21 [Batch Start Line 34]
--medewerker rol bestaat niet.
BEGIN TRANSACTION
 INSERT INTO medewerker_rol_type
 VALUES ('admin')
 EXEC sp_WijzigMedewerkerRolType 'geen admin', 'super-user'
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

