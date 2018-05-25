--verwijder procedures tests.

--sp_VerwijderenProjectCategorie tests
--Een categorie verwijderen
--succesvol
BEGIN TRANSACTION
 INSERT INTO project_categorie (naam, parent)
 VALUES ('subsidie', null)
 EXEC sp_VerwijderenProjectCategorie 'subsidie'
ROLLBACK TRANSACTION

--Een categorie die een subcategorie heeft proberen te verwijderen.
--Msg 50021, Level 16, State 16, Procedure sp_VerwijderenProjectCategorie, Line 20 [Batch Start Line 12]
--Een categorie met subcategoriën kan niet verwijdert worden.
BEGIN TRANSACTION
 INSERT INTO project_categorie (naam, parent)
 VALUES ('subsidie', null),
		('bedrijf', 'subsidie')
 EXEC sp_VerwijderenProjectCategorie 'subsidie'
ROLLBACK TRANSACTION

--Probeer een categorie te verwijderen die nog toegekend is aan een project.
--Msg 50022, Level 16, State 16, Procedure sp_VerwijderenProjectCategorie, Line 26 [Batch Start Line 22]
--Een categorie die gebruikt wordt door een project kan niet verwijdert worden.
BEGIN TRANSACTION
 INSERT INTO project_categorie (naam, parent)
 VALUES ('subsidie', null)
 INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
 VALUES ('BB', 'subsidie', '01-01-2001', '01-01-2020', 'bubble')
 EXEC sp_VerwijderenProjectCategorie 'subsidie'
ROLLBACK TRANSACTION