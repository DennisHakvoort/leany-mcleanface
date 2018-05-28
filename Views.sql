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

--Views om projectbezetting in te zien

--Onderstaande view geeft weer hoeveel uren een medewerker beschikbaar is en hoeveel uren een medewerker is ingepland per jaar. 
--Hiermee wordt ook een percentage berekent dat aangeeft hoeveel procent van de beschikbare tijd gebruikt wordt.
GO
CREATE VIEW vw_Totaal_Gepland_Beschikbaar_Jaar
AS
SELECT		mb.medewerker_code, mip.jaar AS jaar, SUM(mb.beschikbaar_uren) AS totaal_beschikbaar_jaar, medewerker_uren AS totaal_ingepland_jaar, (CAST(mip.medewerker_uren AS FLOAT) / NULLIF(SUM(mb.beschikbaar_uren), 0) * 100) AS percentage_ingepland_beschikbaar
FROM		medewerker_beschikbaarheid mb
			RIGHT JOIN (SELECT		mo.medewerker_code, YEAR(mi.maand_datum) as jaar, SUM(mi.medewerker_uren) as medewerker_uren
						FROM		medewerker_ingepland_project mi 
									INNER JOIN medewerker_op_project mo ON mi.id = mo.id
						GROUP BY	YEAR(mi.maand_datum), mo.medewerker_code) mip ON mb.medewerker_code = mip.medewerker_code 
										AND YEAR(mb.maand) = mip.jaar
GROUP BY	mip.jaar, mb.medewerker_code, mip.medewerker_uren

GO

--Onderstaande view geeft per medewerker aan hoeveel uren de medewerker in totaal aan welk project besteedt, en verwerkt hier ook de informatie van de 
--bovenstaande view in. Door ze zo te combineren hoeft er in een front-end van slechts één view geselecteerd te worden - om verwarring
--te voorkomen.
CREATE VIEW vw_Project_Overzicht_Bezetting
AS
SELECT		YEAR(mip.maand_datum) AS jaar, p.project_naam, p.project_code, mop.medewerker_code, SUM(mip.medewerker_uren) AS totaal_ingepland_project, vtgbj.totaal_ingepland_jaar, vtgbj.totaal_beschikbaar_jaar, vtgbj.percentage_ingepland_beschikbaar
FROM		project p
			RIGHT JOIN medewerker_op_project mop ON mop.project_code = p.project_code
			RIGHT JOIN medewerker_ingepland_project mip ON mip.id = mop.id
			RIGHT JOIN vw_Totaal_Gepland_Beschikbaar_Jaar vtgbj ON vtgbj.jaar = YEAR(mip.maand_datum) AND vtgbj.medewerker_code = mop.medewerker_code
GROUP BY	mop.medewerker_code, YEAR(mip.maand_datum), p.project_code, p.project_naam, vtgbj.totaal_ingepland_jaar, vtgbj.totaal_beschikbaar_jaar, vtgbj.percentage_ingepland_beschikbaar
GO