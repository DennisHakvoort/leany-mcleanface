

DROP VIEW IF EXISTS vw_Bezetting
DROP VIEW IF EXISTS vw_Totaal_Gepland_Beschikbaar_Jaar
DROP VIEW IF EXISTS vw_Project_Overzicht_Bezetting
DROP VIEW IF EXISTS vw_Actief_Project_Percentage_Gedekte_Uren

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

--Views om projectbezetting in te zien

--Onderstaande view geeft weer hoeveel dagen een medewerker beschikbaar is en hoeveel uren een medewerker is ingepland per jaar. 
--Hiermee wordt ook een percentage berekent dat aangeeft hoeveel procent van de beschikbare tijd gebruikt wordt.
GO

CREATE VIEW vw_Totaal_Gepland_Beschikbaar_Jaar
AS
SELECT		mb.medewerker_code, mip.jaar AS jaar, SUM(mb.beschikbare_dagen) * 8 /*werkuren in dag*/ AS totaal_beschikbaar_jaar, medewerker_uren AS totaal_ingepland_jaar, (CAST(mip.medewerker_uren AS FLOAT) / NULLIF(SUM(mb.beschikbare_dagen) * 8, 0) * 100) AS percentage_ingepland_beschikbaar
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

--View voor vergelijken van geplande uren en geschatte benodigde uren voor een project
CREATE VIEW vw_Actief_Project_Percentage_Gedekte_Uren
AS
SELECT		p.project_code, p.project_naam, p.begin_datum, p.eind_datum, p.verwachte_uren, SUM(mip.medewerker_uren) AS geplande_uren_project, (NULLIF(CAST(SUM(mip.medewerker_uren) AS FLOAT), 0) / NULLIF(p.verwachte_uren, 0) * 100) AS percentage_gepland
FROM		project p
			INNER JOIN medewerker_op_project mop ON mop.project_code = p.project_code
			INNER JOIN medewerker_ingepland_project mip ON mip.id = mop.id
WHERE		p.eind_datum >= GETDATE()
GROUP BY	p.project_code, p.project_naam, p.begin_datum, p.eind_datum, p.verwachte_uren

GO