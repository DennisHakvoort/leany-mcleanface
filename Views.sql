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

--TEST DATA EINDIGT HIER
*/

SELECT * FROM Project
SELECT * FROM medewerker_op_project
SELECT * FROM medewerker_ingepland_project
SELECT * FROM medewerker_beschikbaarheid

--View om projectbezetting in te zien
GO
CREATE VIEW vw_Totaal_Gepland_Beschikbaar_Jaar
AS
SELECT		mb.medewerker_code, YEAR(mb.maand) AS jaar, SUM(mb.beschikbaar_uren) AS totaal_beschikbaar_jaar, SUM(mip.medewerker_uren) AS totaal_ingepland_jaar, (CAST(SUM(mip.medewerker_uren) AS FLOAT) / NULLIF(SUM(mb.beschikbaar_uren), 0) * 100) AS percentage_ingepland_beschikbaar
FROM		medewerker_beschikbaarheid mb
			RIGHT JOIN medewerker_op_project mop ON mop.medewerker_code = mb.medewerker_code
			RIGHT JOIN medewerker_ingepland_project mip ON mip.id = mop.id AND YEAR(mip.maand_datum) = YEAR(mb.maand)
GROUP BY	mb.medewerker_code, YEAR(mb.maand)
GO

SELECT		YEAR(mip.maand_datum) AS jaar, p.project_naam, p.project_code, mop.medewerker_code, SUM(mip.medewerker_uren) AS totaal_ingepland_project, vtgbj.totaal_ingepland_jaar, vtgbj.totaal_beschikbaar_jaar, vtgbj.percentage_ingepland_beschikbaar
FROM		project p
			RIGHT JOIN medewerker_op_project mop ON mop.project_code = p.project_code
			RIGHT JOIN medewerker_ingepland_project mip ON mip.id = mop.id
			RIGHT JOIN vw_Totaal_Gepland_Beschikbaar_Jaar vtgbj ON vtgbj.jaar = YEAR(mip.maand_datum) AND vtgbj.medewerker_code = mop.medewerker_code
GROUP BY	mop.medewerker_code, YEAR(mip.maand_datum), p.project_code, p.project_naam, vtgbj.totaal_ingepland_jaar, vtgbj.totaal_beschikbaar_jaar, vtgbj.percentage_ingepland_beschikbaar
ORDER BY	YEAR(mip.maand_datum) DESC, medewerker_code ASC

select * from medewerker_beschikbaarheid where medewerker_code='UC' --1338 ------1512