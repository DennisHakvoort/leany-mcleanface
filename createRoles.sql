CREATE LOGIN TEST WITH PASSWORD = 'test', DEFAULT_DATABASE = leanDb
CREATE USER TESTU FROM LOGIN TEST
CREATE ROLE TESTROLE;
GO

DROP LOGIN TEST
DROP USER TESTU

GRANT SELECT ON DATABASE::leanDb TO TESTROLE
ALTER ROLE [SUPERUSER] ADD MEMBER [TESTU]
ROLLBACK TRANSACTION

EXECUTE AS LOGIN = 'TEST'
USE LeanDb

BEGIN TRANSACTION
EXECUTE sp_invullenBeschikbareDagen @medewerker_code = 'JS', @maand = 'feb 2028', @beschikbare_dagen = 8;
COMMIT TRANSACTION

BEGIN TRANSACTION
EXECUTE sp_MedewerkerToevoegen @achternaam = 'peterson', @voornaam = 'jackson', @medewerker_code = 'jape', @wachtwoord = 'wachtwoord';
COMMIT TRANSACTION
REVERT
 CREATE ROLE superuser

SELECT user as [database user], system_user as [current login], original_login() as [originele login]
GO
--Codegeneratie, handig voor het updaten van de statements.
-- SELECT 'GRANT SELECT ON ' + TABLE_NAME + ' TO SUPERUSER'
-- FROM --INFORMATION_SCHEMA.VIEWS
--      INFORMATION_SCHEMA.TABLES

SELECT 'GRANT EXECUTE ON ' + SPECIFIC_NAME + ' TO SUPERUSER'
FROM   INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE' AND (SPECIFIC_NAME != 'sp_DropConstraint'
                                      OR  SPECIFIC_NAME != 'sp_DatabaseUserToevoegen')

--Drop en creëer rollen.
DROP ROLE IF EXISTS MEDEWERKER
DROP ROLE IF EXISTS SUPERUSER
GO

CREATE ROLE MEDEWERKER
CREATE ROLE SUPERUSER
GO

--MEDEWERKER rollen, deze rol kan alleen de vies bekijken
GRANT SELECT ON vw_Bezetting TO MEDEWERKER

--SUERUSER rollen, hij kan alle views en stored procedures uitvoeren. Ook kan hij alle tables bekijken.
--SELECT VIEWS
GRANT SELECT ON vw_Bezetting TO SUPERUSER
--SELECT TABLES
GRANT SELECT ON categorie_tag TO SUPERUSER
GRANT SELECT ON medewerker TO SUPERUSER
GRANT SELECT ON medewerker_beschikbaarheid TO SUPERUSER
GRANT SELECT ON medewerker_ingepland_project TO SUPERUSER
GRANT SELECT ON medewerker_op_project TO SUPERUSER
GRANT SELECT ON medewerker_rol TO SUPERUSER
GRANT SELECT ON medewerker_rol_type TO SUPERUSER
GRANT SELECT ON project TO SUPERUSER
GRANT SELECT ON project_categorie TO SUPERUSER
GRANT SELECT ON project_rol_type TO SUPERUSER
GRANT SELECT ON tag_van_categorie TO SUPERUSER
GRANT SELECT ON vw_Bezetting TO SUPERUSER
--EXECUTE PROCEDURES
GRANT EXECUTE ON sp_MedewerkerToevoegen TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerkerIngepland TO SUPERUSER
GRANT EXECUTE ON sp_ProjecturenInplannen TO SUPERUSER
GRANT EXECUTE ON sp_invullenBeschikbareDagen TO SUPERUSER
--CREATE USERS




