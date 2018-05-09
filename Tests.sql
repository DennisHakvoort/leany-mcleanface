USE LeanDb
--Business rules

--BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
--Success
BEGIN TRANSACTION
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'jan 2018', 10);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'feb 2018', 120);
ROLLBACK TRANSACTION

--Mislukking
--[23000][547] The INSERT statement conflicted with the CHECK constraint "CK_UREN_MIN_MAX". The conflict occurred in database "LeanDb", table "dbo.medewerker_beschikbaarheid", column 'beschikbaar_uren'.
BEGIN TRANSACTION
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'jan 2018', 1000);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'feb 2018', 820);
ROLLBACK TRANSACTION


--BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
--Success
BEGIN TRANSACTION
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'jan 2018', 10);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'feb 2018', 120);
ROLLBACK TRANSACTION

--Mislukking
--[23000][547] The INSERT statement conflicted with the CHECK constraint "CK_UREN_MIN_MAX". The conflict occurred in database "LeanDb", table "dbo.medewerker_beschikbaarheid", column 'beschikbaar_uren'.
BEGIN TRANSACTION
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'jan 2018', -1);
INSERT INTO medewerker_beschikbaarheid VALUES ('JP', 'feb 2018', -80);
ROLLBACK TRANSACTION

-- BR9 BR9 De waarden van project, medewerker op project en medewerker_ingepland_project
-- kunnen niet meer worden aangepast als project(eind_datum) is verstreken,
-- Project
-- Success
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest')
UPDATE project SET begin_datum = '23 sep 2018' WHERE project_code = 1
DELETE FROM project WHERE project_code = 1
ROLLBACK TRANSACTION

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2018', '22 feb 2018', 'testerdetest')
ROLLBACK TRANSACTION

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2016', '22 feb 2019', 'testerdetest')
UPDATE project SET eind_datum = '23 sep 2017' WHERE project_code = 1
ROLLBACK TRANSACTION

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2017', CURRENT_TIMESTAMP, 'testerdetest')
WAITFOR DELAY '00:00:01'
UPDATE project SET eind_datum = '27 feb 2020' WHERE project_code = 1
ROLLBACK TRANSACTION

-- Mislukking
-- [S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2016', '22 feb 2019', 'testerdetest')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01'
DELETE FROM project WHERE project_code = 1
ROLLBACK TRANSACTION

-- Medewerker_ingepland_project
-- Success
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 10, 'feb 2019')
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', current_timestamp, 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
WAITFOR DELAY '00:00:01'
INSERT INTO medewerker_ingepland_project VALUES (1, 10, 'feb 2019')
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 10, 'feb 2019')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01'
UPDATE medewerker_ingepland_project SET medewerker_uren = 10 WHERE id = 1
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 10, 'feb 2019')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = 1
ROLLBACK TRANSACTION
