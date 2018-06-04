USE LeanDb
GO
--verwijder procedures tests.

--sp_VerwijderenProjectCategorie tests
--Een categorie verwijderen
--succesvol
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO project_categorie (naam, parent)
		VALUES ('subsidie', null)
	EXEC sp_VerwijderenProjectCategorie 'subsidie'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

--Een categorie die een subcategorie heeft proberen te verwijderen.
--Msg 50021, Level 16, State 16, Procedure sp_VerwijderenProjectCategorie, Line 20 [Batch Start Line 12]
--Een categorie met subcategoriën kan niet verwijderd worden.
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO project_categorie (naam, parent)
	VALUES ('subsidie', null),
		('bedrijf', 'subsidie')
	EXEC sp_VerwijderenProjectCategorie 'subsidie'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

--Probeer een categorie te verwijderen die nog toegekend is aan een project.
--Msg 50022, Level 16, State 16, Procedure sp_VerwijderenProjectCategorie, Line 26 [Batch Start Line 22]
--Een categorie die gebruikt wordt door een project kan niet verwijderd worden.
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO project_categorie (naam, parent)
		VALUES ('subsidie', null)
	INSERT INTO project (project_code, categorie_naam, begin_datum, eind_datum, project_naam)
		VALUES ('BB', 'subsidie', '01-01-2001', '01-01-2020', 'bubble')
	EXEC sp_VerwijderenProjectCategorie 'subsidie'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION

-- test sp_verwijderenProjectrol
-- succes test
BEGIN TRANSACTION
	BEGIN TRY
INSERT INTO project_rol_type (project_rol)
		VALUES ('projectleider')

	EXEC sp_verwijderenProjectrol @projectrol = 'projectleider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

-- test sp_verwijderenProjectrol
-- faal test
-- Msg 50026, Level 16, State 16, Procedure sp_verwijderenProjectrol
-- Projectrol kan niet worden verwijdert, omdat het nog in gebruik is.
BEGIN TRANSACTION
BEGIN TRY
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
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_VerwijderenMedewerkerIngeplandProject
--Verwijder een medewerker_ingepland_project record
--Succes test
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @maand_beschikbaar DATETIME = (getdate() + 40);
	
	INSERT INTO medewerker VALUES ('cod95', 'Gebruiker7', 'Achternaam7');
	INSERT INTO medewerker_beschikbaarheid VALUES ('cod95', 'jan 2019', 12);
	INSERT INTO medewerker_rol_type VALUES ('DeaTeacher');
	INSERT INTO medewerker_rol VALUES ('cod95', 'DeaTeacher');
	INSERT INTO project_categorie VALUES ('HAN Arnhem', null);
	INSERT INTO project_categorie VALUES ('DEA_project', 'HAN Arnhem');
	INSERT INTO categorie_tag VALUES ('school');
	INSERT INTO tag_van_categorie VALUES ('DEA_project', 'school');
	INSERT INTO project VALUES ('DEA12', 'DEA_project', GETDATE() + 30 , GETDATE() + 200, 'DEA_project_2018', 320);
	INSERT INTO project_rol_type VALUES ('CEO');
	INSERT INTO medewerker_op_project VALUES ('DEA12', 'cod95', 'CEO');
	INSERT INTO medewerker_ingepland_project VALUES (IDENT_CURRENT('medewerker_op_project'), 300, @maand_beschikbaar);

	DECLARE @id int = IDENT_CURRENT('medewerker_op_project') + 1;
	EXEC sp_VerwijderenMedewerkerIngeplandProject @id, @maand_beschikbaar;
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Een medewerker_ingepland_project verwijderen die niet bestaat
--Faal test
--Msg 50031, Level 16, State 16, Procedure sp_VerwijderenMedewerkerIngeplandProject, Line 21 [Batch Start Line 137]
--Er bestaat geen medewerker_ingepland_project record met de opgegeven id
BEGIN TRANSACTION
BEGIN TRY
	DECLARE @id int = IDENT_CURRENT('medewerker_op_project') + 1;
	EXEC sp_VerwijderenMedewerkerIngeplandProject @id, 'feb 2018';
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_VerwijderenMedewerkerRolType
--Verwijder een medewerker_rol_type die niet in gebruik is
--Succes test
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker_rol_type VALUES ('CEO');
	EXEC sp_VerwijderenMedewerkerRolType 'CEO'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Een medewerker_rol_type die al aan een medewerker gekoppeld is kan niet verwijderd worden
--Msg 50029, Level 16, State 16, Procedure sp_VerwijderenMedewerkerRolType, Line 20 [Batch Start Line 118]
--een medewerker_rol_type in gebruik kan niet verwijderd worden.
BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO medewerker VALUES ('aa123', 'Samir', 'Amed');
		INSERT INTO medewerker_rol_type VALUES ('Tester');
		INSERT INTO medewerker_rol VALUES ('aa123', 'Tester');
		EXEC sp_VerwijderenMedewerkerRolType 'Tester'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Test sp_VerwijderenMedewerkerRol
--Verwijder een medewerker_rol die gekoppeld is aan een medewerker
--Succes test
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker VALUES ('cod98', 'Gebruiker1', 'Achternaam1');
	INSERT INTO medewerker_rol_type VALUES ('Android');
	INSERT INTO medewerker_rol_type VALUES ('Tester');
	INSERT INTO medewerker_rol VALUES ('cod98', 'Android');
	INSERT INTO medewerker_rol VALUES ('cod98', 'Tester');
	EXEC sp_VerwijderenMedewerkerRol 'cod98', 'Android'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO

--Een medewerker_rol die niet gekoppeld is aan de opgegeven medewerker_code kan niet verwijderd worden
--Faal test
--Msg 50096, Level 16, State 16, Procedure sp_VerwijderenMedewerkerRol, Line 20 [Batch Start Line 147]
--deze medewerker heeft niet de ingevoerde medewerker_rol.
BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO medewerker VALUES ('cod17', 'Gebruiker2', 'Achternaam2');
	INSERT INTO medewerker_rol_type VALUES ('Administrator');
	INSERT INTO medewerker_rol VALUES ('cod17', 'Administrator');
	EXEC sp_VerwijderenMedewerkerRol 'cod17', 'Leider'
END TRY
BEGIN CATCH
	PRINT 'CATCH RESULTATEN:'
	PRINT CONCAT('ERROR NUMMER:		', ERROR_NUMBER())
	PRINT CONCAT('ERROR SEVERITY:	', ERROR_SEVERITY())
	PRINT 'ERROR MESSAGE:	' + ERROR_MESSAGE()
END CATCH
ROLLBACK TRANSACTION
GO