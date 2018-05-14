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
	PRINT 'Moet falen:'
	BEGIN TRY
		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas')

		insert into project_categorie (naam, parent)
			values	('onderwijs', null)

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'generieke proj naam')

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'niet zo generieke proj naam')
	
		insert into project_rol_type (project_rol)
			values	('lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector')

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, GETDATE()))

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, GETDATE()))

		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = -10, @maand_datum = '2018-6-14'
		PRINT 'test gefaald'
	END TRY
	BEGIN CATCH
		PRINT 'test succesvol gefaald'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Faal Test - over de limit
BEGIN TRANSACTION
	PRINT 'Moet falen:'
	BEGIN TRY
		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas')

		insert into project_categorie (naam, parent)
			values	('onderwijs', null)

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'generieke proj naam')

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'niet zo generieke proj naam')
	
		insert into project_rol_type (project_rol)
			values	('lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector')

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, GETDATE()))

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, GETDATE()))
		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 1000, @maand_datum = '2018-6-14'
		PRINT 'test gefaald'
	END TRY
	BEGIN CATCH
		PRINT 'test succesvol gefaald'
	END CATCH
ROLLBACK TRANSACTION

-- BR5 Succes Test
BEGIN TRANSACTION
	PRINT 'Moet succesvol zijn: '
	BEGIN TRY
		insert into medewerker (medewerker_code, voornaam, achternaam)
			values ('aa', 'arend', 'aas')

		insert into project_categorie (naam, parent)
			values	('onderwijs', null)

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C1', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'generieke proj naam')

		insert into project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			values	('PROJC0101C2', 'onderwijs', CONVERT(date, GETDATE() - 60), CONVERT(date, GETDATE() + 300), 'niet zo generieke proj naam')
	
		insert into project_rol_type (project_rol)
			values	('lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912012, 'PROJC0101C1', 'aa', 'lector')

		insert into medewerker_op_project (id, project_code, medewerker_code, project_rol)
			values	(912013, 'PROJC0101C2', 'aa', 'lector')

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912013, 10, CONVERT(date, GETDATE()))

		insert into medewerker_ingepland_project (id, medewerker_uren, maand_datum)
			values	(912012, 10, CONVERT(date, GETDATE()))
	
		exec spProjecturenInplannen @medewerker_code = 'aa', @project_code = 'PROJC0101C1', @medewerker_uren = 10, @maand_datum = '2018-6-14'
		PRINT 'test succesvol' 
	END TRY
	BEGIN CATCH
		PRINT 'test gefaald'
	END CATCH
ROLLBACK TRANSACTION


select * from medewerker
-- BR7 Faal Test
BEGIN TRANSACTION
	PRINT 'Moet falen: '
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()-1)), 'generieke projectnaam');
		PRINT 'test gefaald' 
	END TRY
	BEGIN CATCH
		PRINT 'test succesvol gefaald'
	END CATCH
ROLLBACK TRANSACTION
GO

-- BR7 Succes Test
BEGIN TRANSACTION
	PRINT 'Moet succesvol zijn: '
	BEGIN TRY
		INSERT INTO project_categorie (naam, parent)
			VALUES ('testCat', null);
		INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
			VALUES ('PROJC99999P', 'testCat', CONVERT(date, GETDATE()), CONVERT(date, (GETDATE()+1)), 'generieke projectnaam');
		PRINT 'test succesvol' 
	END TRY
	BEGIN CATCH
		PRINT 'test gefaald'
	END CATCH
ROLLBACK