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