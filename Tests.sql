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

-- BR5 Faal Test - negatieve waarden
BEGIN TRANSACTION
	BEGIN TRY
		declare @date DATETIME = GETDATE();

		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas');

		insert into project_categorie (naam, parent)
			values	('onderwijs', null);

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');
	
		insert into project_rol_type (project_rol)
			values	('lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector');

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, @date));

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, @date));
		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = -10, @maand_datum = @date
		PRINT 'test mislukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Faal Test - over de limit
BEGIN TRANSACTION
	BEGIN TRY
		declare @date DATETIME = GETDATE();

		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas');

		insert into project_categorie (naam, parent)
			values	('onderwijs', null);

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');
	
		insert into project_rol_type (project_rol)
			values	('lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector');

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, @date));

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, @date));
		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 1000, @maand_datum = @date
		PRINT 'test mislukt'
	END TRY
	BEGIN CATCH
		SELECT 'test succesvol gefaald' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Succes Test
BEGIN TRANSACTION
	BEGIN TRY
		declare @date DATETIME = GETDATE();

		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas');

		insert into project_categorie (naam, parent)
			values	('onderwijs', null);

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'generieke proj naam');

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, @date - 60), CONVERT(date, @date + 300), 'niet zo generieke proj naam');
	
		insert into project_rol_type (project_rol)
			values	('lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector');

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector');

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, @date));

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, @date));
	
		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 10, @maand_datum = @date
		PRINT 'test succesvol verlopen' 
	END TRY
	BEGIN CATCH
		SELECT 'test mislukt' as 'resultaat', ERROR_MESSAGE() as 'error message'
	END CATCH
ROLLBACK TRANSACTION

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

--BR3
--Misschien evt. een while loop met honderd jan pieters?
BEGIN TRANSACTION --werken allemaal
EXEC sp_MedewerkerToevoegen 'Zwart', 'Jan Pieter' --code: JZ
EXEC sp_MedewerkerToevoegen 'Zweers', 'Johan' --code: JZ1
EXEC sp_MedewerkerToevoegen 'Zweers', 'Jan' --code: JZ2
SELECT * FROM medewerker
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