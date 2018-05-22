USE LeanDb
GO

--VIEW1 Bezettingspercentages per maand per medewerker
CREATE VIEW vw_Bezetting AS
SELECT j.medewerker_code, year(maand_datum) AS jaar,
isnull(sum(case when month(maand_datum) = 1 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Jan,
isnull(sum(case when month(maand_datum) = 2 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Feb,
isnull(sum(case when month(maand_datum) = 3 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Mar,
isnull(sum(case when month(maand_datum) = 4 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Apr,
isnull(sum(case when month(maand_datum) = 5 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Mei,
isnull(sum(case when month(maand_datum) = 6 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Jun,
isnull(sum(case when month(maand_datum) = 7 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Jul,
isnull(sum(case when month(maand_datum) = 8 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Aug,
isnull(sum(case when month(maand_datum) = 9 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Sep,
isnull(sum(case when month(maand_datum) = 10 then ROUND((CAST(totaal_uren AS FLOAT)/ (beschikbare_dagen * 8)) * 100, 2) end), 0) Okt,
isnull(sum(case when month(maand_datum) = 11 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Nov,
isnull(sum(case when month(maand_datum) = 12 then ROUND((CAST(totaal_uren AS FLOAT) / (beschikbare_dagen * 8)) * 100, 2) end), 0) Dec,
sum(totaal_uren) as totaal_uren
FROM (SELECT mop.medewerker_code, maand_datum, sum(mip.medewerker_uren) totaal_uren
			FROM medewerker_op_project mop INNER JOIN medewerker_ingepland_project mip ON mop.id = mip.id
			GROUP BY mop.medewerker_code, maand_datum) j INNER JOIN medewerker_beschikbaarheid m
					ON j.medewerker_code = m.medewerker_code
					AND year(maand_datum) = year(maand)
					AND month(maand_datum) = month(maand)
WHERE beschikbare_dagen > 0 AND totaal_uren > 0
GROUP BY j.medewerker_code, year(maand_datum)



-- SELECT p.medewerker_code, year(i.maand_datum) AS jaar,
-- isnull(case when month(i.maand_datum) = 1 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Jan,
-- isnull(case when month(i.maand_datum) = 2 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Feb,
-- isnull(case when month(i.maand_datum) = 3 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Mar,
-- isnull(case when month(i.maand_datum) = 4 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Apr,
-- isnull(case when month(i.maand_datum) = 5 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Mei,
-- isnull(case when month(i.maand_datum) = 6 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Jun,
-- isnull(case when month(i.maand_datum) = 7 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Jul,
-- isnull(case when month(i.maand_datum) = 8 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Aug,
-- isnull(case when month(i.maand_datum) = 9 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Sep,
-- isnull(case when month(i.maand_datum) = 10 then (CAST(i.medewerker_uren AS FLOAT)/ b.beschikbaar_uren) * 100 end, 0) Okt,
-- isnull(case when month(i.maand_datum) = 12 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Nov,
-- isnull(case when month(i.maand_datum) = 13 then (CAST(i.medewerker_uren AS FLOAT) / b.beschikbaar_uren) * 100 end, 0) Dec
-- FROM medewerker_op_project p LEFT OUTER JOIN medewerker_beschikbaarheid b ON p.medewerker_code = b.medewerker_code
-- 							 LEFT OUTER JOIN medewerker_ingepland_project i ON p.id = i.id
-- WHERE b.beschikbaar_uren IS NOT NULL AND b.beschikbaar_uren > 0
-- GROUP BY p.medewerker_code, i.medewerker_uren, b.beschikbaar_uren, i.maand_datum



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