
BEGIN TRANSACTION
EXEC sp_MedewerkerToevoegen 'van Megchelen', 'Supreme leader', 'Sv'
EXEC sp_InsertMedewerkerRolType 'lid'
EXEC sp_InsertMedewerkerRol 'Sv', 'lid'
EXEC sp_InsertProjectRolType 'projectleider'
EXEC sp_insertProjectCategorie 'subsidie', NULL
EXEC sp_InsertProject 'AK', 'subsidie', '01-01-1900', '01-01-2300', 'ALLES KAPOT'
EXEC sp_InsertMedewerkerOpProject 'AK', 'Sv', 'projectleider'
EXEC sp_invullenBeschikbareDagen @medewerker_code = 'Sv', @maand = '2020-01-01', @beschikbare_dagen = 10
EXEC sp_aanpassenBeschikbareDagen @medewerker_code = 'Sv', @maand ='2020-01-02', @beschikbare_dagen = 12
ROLLBACK TRANSACTION
