USE LeanDb
GO

-- test sp_verwijderenProjectrol
-- succes test
BEGIN TRANSACTION
	INSERT INTO project_rol_type (project_rol)
		VALUES ('projectleider')

	EXEC sp_verwijderenProjectrol @projectrol = 'projectleider'
ROLLBACK TRANSACTION
GO

-- test sp_verwijderenProjectrol
-- faal test
-- Msg 50026, Level 16, State 16, Procedure sp_verwijderenProjectrol
-- Projectrol kan niet worden verwijdert, omdat het nog in gebruik is.
BEGIN TRANSACTION
	INSERT INTO project_categorie (naam, parent)
		VALUES ('uitzendwerk', NULL);
	INSERT INTO project (project_code, project_naam, categorie_naam, begin_datum, eind_datum, verwachte_uren)
		VALUES ('PROJUICE', 'MarktMedia uitzendbureau', 'uitzendwerk', GETDATE(), GETDATE() +300, 900);
	INSERT INTO medewerker (medewerker_code, voornaam, achternaam)
		VALUES ('ASB99', 'Arnold', 'Sporrel');

	INSERT INTO project_rol_type (project_rol)
		VALUES ('projectleider');

	INSERT INTO medewerker_op_project (medewerker_code, project_code, project_rol)
		VALUES ('ASB99', 'PROJUICE', 'projectleider');

	EXEC sp_verwijderenProjectrol @projectrol = 'projectleider'
ROLLBACK TRANSACTION
