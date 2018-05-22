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

--BR3
--Misschien evt. een while loop met honderd jan pieters?
BEGIN TRANSACTION --werken allemaal
EXEC sp_MedewerkerToevoegen 'Zwart', 'Jan Pieter' --code: JZ
EXEC sp_MedewerkerToevoegen 'Zweers', 'Johan' --code: JZ1
EXEC sp_MedewerkerToevoegen 'Zweers', 'Jan' --code: JZ2
SELECT * FROM medewerker
ROLLBACK TRANSACTION


--Test BR4
--Insert een een tijd schatting van een persoon die uren beschikbaar heeft in de desbetreffende maand
--succesvol
BEGIN TRANSACTION
INSERT INTO MEDEWERKER (MEDEWERKER_CODE, VOORNAAM, ACHTERNAAM)
VALUES ('GB', 'Gertruude', 'van Barneveld')
INSERT INTO PROJECT_CATEGORIE (naam, parent)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT (PROJECT_CODE, categorie_naam, BEGIN_DATUM, EIND_DATUM, PROJECT_NAAM)
VALUES ('PR', 'subsidie', '01-01-1990', '01-01-2100', 'test project')
INSERT INTO PROJECT_ROL_TYPE (project_rol)
VALUES ('baas')
INSERT INTO MEDEWERKER_OP_PROJECT (ID, PROJECT_CODE, MEDEWERKER_CODE, PROJECT_ROL)
VALUES (1, 'PR', 'GB', 'baas')
INSERT INTO MEDEWERKER_BESCHIKBAARHEID (MEDEWERKER_CODE, maand, BESCHIKBAAR_UREN)
VALUES ('GB', '01-03-2002', 50)
EXEC sp_InsertMedewerkerIngepland 1, 50, '01-03-2001'
ROLLBACK TRANSACTION


--insert geplande uren voor iemand die geen uren beschikbaar heeft in een maand.
-- error: Msg 50006, Level 16, State 16, Procedure medewerkerNietInplannenAlsNietBeschikbaar, Line 21 [Batch Start Line 60]
--Medewerker heeft geen beschikbare uren en kan dus niet ingepland worden

BEGIN TRANSACTION
BEGIN TRY
INSERT INTO MEDEWERKER (MEDEWERKER_CODE, VOORNAAM, ACHTERNAAM)
VALUES ('GB', 'Gertruude', 'van Barneveld')
INSERT INTO PROJECT_CATEGORIE (naam, parent)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT (PROJECT_CODE, categorie_naam, BEGIN_DATUM, EIND_DATUM, PROJECT_NAAM)
VALUES ('PR', 'subsidie', '01-01-1990', '01-01-2100', 'test project')
INSERT INTO PROJECT_ROL_TYPE (project_rol)
VALUES ('baas')
INSERT INTO MEDEWERKER_OP_PROJECT (ID, PROJECT_CODE, MEDEWERKER_CODE, PROJECT_ROL)
VALUES (1, 'PR', 'GB', 'baas')
INSERT INTO MEDEWERKER_BESCHIKBAARHEID (MEDEWERKER_CODE, maand, BESCHIKBAAR_UREN)
VALUES ('GB', '01-03-2002', 0)
EXEC sp_InsertMedewerkerIngepland 1, 50, '01-03-2001'
END TRY
	BEGIN CATCH
				SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
ROLLBACK TRANSACTION


--Insert geplande uren voor iemand die beschikbaarheid nog niet doorgegeven heeft.
--error: Msg 50006, Level 16, State 16, Procedure medewerkerNietInplannenAlsNietBeschikbaar, Line 21 [Batch Start Line 60]
--Medewerker heeft geen beschikbare uren en kan dus niet ingepland worden
BEGIN TRANSACTION
BEGIN TRY
INSERT INTO MEDEWERKER (MEDEWERKER_CODE, VOORNAAM, ACHTERNAAM)
VALUES ('GB', 'Gertruude', 'van Barneveld')
INSERT INTO PROJECT_CATEGORIE (naam, parent)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT (PROJECT_CODE, categorie_naam, BEGIN_DATUM, EIND_DATUM, PROJECT_NAAM)
VALUES ('PR', 'subsidie', '01-01-1990', '01-01-2100', 'test project')
INSERT INTO PROJECT_ROL_TYPE (project_rol)
VALUES ('baas')
INSERT INTO MEDEWERKER_OP_PROJECT (ID, PROJECT_CODE, MEDEWERKER_CODE, PROJECT_ROL)
VALUES (1, 'PR', 'GB', 'baas')
EXEC sp_InsertMedewerkerIngepland 1, 50, '01-03-2001'
END TRY
	BEGIN CATCH
		SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message', ERROR_NUMBER() AS 'error number', ERROR_SEVERITY() as 'error severity'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Faal Test - negatieve waarden
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, parent)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912012, 'PROJC0101C1', 'aa', 'lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912013, 'PROJC0101C2', 'aa', 'lector');

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912013, 10, CONVERT(date, @date));

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912012, 10, CONVERT(date, @date));
		EXEC spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = -10, @maand_datum = @date
		PRINT 'test mislukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Faal Test - over de limit
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, parent)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912012, 'PROJC0101C1', 'aa', 'lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912013, 'PROJC0101C2', 'aa', 'lector');

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912013, 10, CONVERT(date, @date));

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912012, 10, CONVERT(date, @date));
		EXEC spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 1000, @maand_datum = @date
		PRINT 'test mislukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Succes Test
BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @date DATETIME = GETDATE();

		INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
			VALUES ('aa', 'arend', 'aas');

		INSERT INTO project_categorie (naam, parent)
			VALUES	('onderwijs', null);

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');

		INSERT INTO project_rol_type (project_rol)
			VALUES	('lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912012, 'PROJC0101C1', 'aa', 'lector');

		INSERT INTO medewerker_op_project (id, project_code, medewerker_code, project_rol)
			VALUES	(912013, 'PROJC0101C2', 'aa', 'lector');

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912013, 10, CONVERT(date, @date));

		INSERT INTO medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			VALUES	(912012, 10, CONVERT(date, @date));
		EXEC spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 10, @maand_datum = @date
		PRINT 'test succesvol verlopen'
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION


-- BR7 Faal Test - single insert
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam');
		PRINT 'Test mislsukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol verlopen' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION
GO
-- BR7 Faal test multi insert - 1 geldig 1 ongeldig
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam'); -- geldig data
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam'); -- ongeldig data
		PRINT 'Test mislsukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol verlopen' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION
GO

-- BR7 Succes Test single insert
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		PRINT 'test succesvol verlopen'
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK

-- BR7 Succes Test multi inserts
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99998P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam2');
		PRINT 'test succesvol verlopen'
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK

/* tests voor BR8*/
--Voeg een hoofdcategorie toe.
--gaat goed
BEGIN TRANSACTION
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
ROLLBACK TRANSACTION

--voeg een subcategorie met een niet bestaande hoofdcategorie toe
--Geeft error 50003 [2018-05-09 11:56:40] [S00016][50003] Deze subcategorie heeft geen geldige hoofdcategorie
BEGIN TRANSACTION
INSERT INTO PROJECT_CATEGORIE
VALUES ('school', 'onderwijs')
ROLLBACK TRANSACTION

--voeg een subcategorie toe met een bestaande hoofdcategorie
--gaat goed
BEGIN TRANSACTION
INSERT INTO PROJECT_CATEGORIE (naam, parent)
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE (naam, parent)
VALUES ('bedrijf1', 'subsidie')
ROLLBACK TRANSACTION

--verwijder een hoofdcategorie die een subcategorie bevat.
--Geeft error [50002] Kan geen categorie met met subcategoriën verwijderen
BEGIN TRANSACTION
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE
VALUES ('bedrijf1', 'subsidie')
DELETE FROM PROJECT_CATEGORIE
WHERE naam = 'subsidie'
ROLLBACK TRANSACTION

--Verwijdert een subcategorie met geldige hoofdcategorie.
--gaat goed
BEGIN TRANSACTION
INSERT INTO PROJECT_CATEGORIE
VALUES ('subsidie', NULL)
INSERT INTO PROJECT_CATEGORIE
VALUES ('bedrijf1', 'subsidie')
DELETE FROM PROJECT_CATEGORIE
WHERE naam = 'bedrijf1'
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

-- medewerker_op_project
-- Success
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2019', '22 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', current_timestamp, 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
WAITFOR DELAY '00:00:01'
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO medewerker VALUES ('JD', 'Jan', 'Dieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01'
UPDATE medewerker_op_project SET medewerker_code = 'JD' WHERE project_code = 1
ROLLBACK TRANSACTION

--Mislukking
--[S00016][50001] Een project kan niet meer aangepast worden nadat deze is afgelopen.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('d', NULL)
INSERT INTO project VALUES (1, 'd', '15 jan 2015', '12 feb 2019', 'testerdetest')
INSERT INTO medewerker VALUES ('JP', 'Jan', 'Pieter')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker_op_project VALUES (1, 1, 'JP', 'tester')
UPDATE project SET eind_datum = CURRENT_TIMESTAMP WHERE project_code = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_op_project WHERE project_code = 1
ROLLBACK TRANSACTION


-- BR10 medewerker_beschikbaarheid kan niet worden aangepast als medewerker_beschikbaarheid(maand) is verstreken
-- Success
BEGIN TRANSACTION
INSERT INTO medewerker VALUES (1, 'SurnameTest', 'FirstnameTest')
INSERT INTO medewerker_beschikbaarheid VALUES (1, '01 jan 2015', '30')
UPDATE medewerker_beschikbaarheid SET maand = '23 sep 2014' WHERE medewerker_code = 1
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 1
ROLLBACK TRANSACTION

--Mislukte poging
--[500016][50001] Verstreken maand kan niet meer aangepast worden.
BEGIN TRANSACTION
INSERT INTO medewerker VALUES (1, 'Khabat', 'Samir')
INSERT INTO medewerker_beschikbaarheid VALUES (1, '01 jan 2015', '30')
UPDATE medewerker_beschikbaarheid SET maand = '23 sep 2014' WHERE medewerker_code = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_beschikbaarheid WHERE medewerker_code = 1
ROLLBACK TRANSACTION

--BR11 medewerker_ingepland_project kan niet meer worden aangepast als medewerker_ingepland_project(maand_datum) is verstreken
--BR 11 Success 
--Medewerker uren kunnen aangepast worden voor huidige datum en toekomstige tijdstip.
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES (1, 'training', '15 jan 2018', '12 dec 2018', 'testproject')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES (1, 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES (1, 1, 1, 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'jul 2018' WHERE id = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = 1
ROLLBACK TRANSACTION

--BR 11 Mislukte poging
--[500016][50001] medewerker verstreken maand(en) kunnen niet meer aangepast worden.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES (1, 'training', '15 jan 2018', '12 dec 2018', 'testproject')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES (1, 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES (1, 1, 1, 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'feb 2018' WHERE id = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = 1
ROLLBACK TRANSACTION

--BR 11 Mislukte poging
--[500016][50001] medewerker uren van een verstreken maand kunnen niet meer aangepast worden.
BEGIN TRANSACTION
INSERT INTO project_categorie VALUES ('training', NULL)
INSERT INTO project VALUES (1, 'training', '15 jan 2018', '12 dec 2018', 'testproject')
INSERT INTO project_rol_type VALUES ('tester')
INSERT INTO medewerker VALUES (1, 'Khabar', 'Samir')
INSERT INTO medewerker_op_project VALUES (1, 1, 1, 'tester')
INSERT INTO medewerker_ingepland_project VALUES (1, 30, 'jun 2018')
UPDATE medewerker_ingepland_project SET maand_datum = 'feb 2018' WHERE id = 1
WAITFOR DELAY '00:00:01'
UPDATE medewerker_ingepland_project SET medewerker_uren = '20' WHERE id = 1
WAITFOR DELAY '00:00:01'
DELETE FROM medewerker_ingepland_project WHERE id = 1
ROLLBACK TRANSACTION

