--TODO: De rechten updaten met eventuele nieuwe tables en procedures.
--Codegeneratie, handig voor het updaten van de statements.
-- SELECT 'GRANT SELECT ON ' + TABLE_NAME + ' TO SUPERUSER'
-- FROM --INFORMATION_SCHEMA.VIEWS
--      INFORMATION_SCHEMA.TABLES

-- SELECT 'GRANT EXECUTE ON ' + SPECIFIC_NAME + ' TO SUPERUSER'
-- FROM   INFORMATION_SCHEMA.ROUTINES
-- WHERE ROUTINE_TYPE = 'PROCEDURE' AND (SPECIFIC_NAME != 'sp_DropConstraint'
--                                       OR  SPECIFIC_NAME != 'sp_DatabaseUserToevoegen')

--Drop en creëer rollen.
DROP ROLE IF EXISTS MEDEWERKER
DROP ROLE IF EXISTS SUPERUSER
-- GO

CREATE ROLE MEDEWERKER
CREATE ROLE SUPERUSER
GO

--MEDEWERKER rollen, deze rol kan alleen de vies bekijken
GRANT SELECT ON vw_Bezetting TO MEDEWERKER
GRANT SELECT ON vw_Totaal_Gepland_Beschikbaar_Jaar TO MEDEWERKER
GRANT SELECT ON vw_Project_Overzicht_Bezetting TO MEDEWERKER
GRANT SELECT ON vw_Actief_Project_Percentage_Gedekte_Uren TO MEDEWERKER
GRANT EXECUTE on sp_checkProjectRechten TO MEDEWERKER

--SUERUSER rollen, hij kan alle views en stored procedures uitvoeren. Ook kan hij alle tables bekijken.
--SELECT VIEWS
GRANT SELECT ON vw_Bezetting TO SUPERUSER
GRANT SELECT ON vw_Totaal_Gepland_Beschikbaar_Jaar TO SUPERUSER
GRANT SELECT ON vw_Project_Overzicht_Bezetting TO SUPERUSER
GRANT SELECT ON vw_Actief_Project_Percentage_Gedekte_Uren TO SUPERUSER
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
--EXECUTE PROCEDURES
GRANT EXECUTE ON sp_DropConstraint TO SUPERUSER
GRANT EXECUTE ON sp_MedewerkerToevoegen TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerkerIngepland TO SUPERUSER
GRANT EXECUTE ON sp_ProjecturenInplannen TO SUPERUSER
GRANT EXECUTE ON sp_invullenBeschikbareDagen TO SUPERUSER
GRANT EXECUTE ON sp_WijzigProjectRol TO SUPERUSER
