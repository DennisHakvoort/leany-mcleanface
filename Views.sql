USE LeanDb
GO

--VIEW1 Bezettingspercentages per maand per medewerker
CREATE VIEW vw_Bezetting AS
SELECT p.medewerker_code, year(i.maand_datum) AS jaar,
isnull(case when month(i.maand_datum) = 1 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Jan,
isnull(case when month(i.maand_datum) = 2 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Feb,
isnull(case when month(i.maand_datum) = 3 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Mar,
isnull(case when month(i.maand_datum) = 4 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Apr,
isnull(case when month(i.maand_datum) = 5 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Mei,
isnull(case when month(i.maand_datum) = 6 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Jun,
isnull(case when month(i.maand_datum) = 7 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Jul,
isnull(case when month(i.maand_datum) = 8 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Aug,
isnull(case when month(i.maand_datum) = 9 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Sep,
isnull(case when month(i.maand_datum) = 10 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Okt,
isnull(case when month(i.maand_datum) = 12 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Nov,
isnull(case when month(i.maand_datum) = 13 then (i.medewerker_uren / b.beschikbaar_uren) * 100 end, 0) Dec
FROM medewerker_op_project p LEFT OUTER JOIN medewerker_beschikbaarheid b ON p.medewerker_code = b.medewerker_code
							 LEFT OUTER JOIN medewerker_ingepland_project i ON p.id = i.id
GROUP BY p.medewerker_code, i.medewerker_uren, b.beschikbaar_uren, i.maand_datum


/*
--TODO: REMOVE TEST DATA IF OTHER DATA HAS BEEN GENERATED.
--TEST DATA BEGINT HIER
INSERT INTO project_categorie VALUES
	('Onderwijs', NULL),
	('Middelbaar onderwijs', 'Onderwijs'),
	('Facturering', NULL)

INSERT INTO project VALUES
	(1, 'Onderwijs', '12 jan 2017', '29 dec 2018', 'Onderwijs project'),
	(2, 'Facturering', '3 apr 3018', '22 aug 2019', 'Succesvol factureren')

INSERT INTO project_rol_type VALUES
	('Projectleider'),
	('Medewerker')

INSERT INTO medewerker VALUES
	('JP', 'Jan', 'Pieter'),
	('CS', 'Chris', 'Scholten'),
	('SC', 'Santa', 'Claus')

INSERT INTO medewerker_beschikbaarheid VALUES
	()

--TEST DATA EINDIGD HIER
*/