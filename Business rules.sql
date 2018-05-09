--BUSINESS RULES--

/*
 *	business rule 5 en 6
 *	BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
 *	BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184
*/
ALTER TABLE MEDEWERKER_INGEPLAND_PROJECT WITH CHECK
	ADD CONSTRAINT CK_UREN_MIN_MAX CHECK (medewerker_uren > 0 and medewerker_uren < 184)