/*
Gebruiker toevoegen als superuser:
Run de volgende commmando's en verander de 'USERNAME' in de user naam en de 'LOGINNAME' in de login naam.
ALTER ROLE [SUPERUSER] ADD MEMBER [LOGINNAME]
ALTER ROLE [db_securityadmin] ADD MEMBER [LOGINNAME]
ALTER SERVER ROLE [securityadmin] ADD MEMBER [USERNAME]
GRANT ALTER ANY USER TO [LOGINNAME]
*/

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
--Stored procedures waarin een check voor projectrechten wordt gedaan kunnen ook worden uitgevoerd door de medewerker. als hij niet de projecteigenaar is wordt een error geworpen.
GRANT EXECUTE on sp_checkProjectRechten TO MEDEWERKER
GRANT EXECUTE on sp_InsertProjecturenMedewerker TO MEDEWERKER
GRANT EXECUTE on sp_InsertMedewerkerOpProject TO MEDEWERKER
GRANT EXECUTE on sp_WijzigMedewerkerOpProject TO MEDEWERKER
GRANT EXECUTE on sp_VerwijderenProjectlidOpSubproject TO MEDEWERKER
GRANT EXECUTE on sp_WijzigProject TO MEDEWERKER
GRANT EXECUTE on sp_VerwijderSubproject TO MEDEWERKER
GRANT EXECUTE on sp_WijzigProjectlidOpSubproject TO MEDEWERKER
GRANT EXECUTE on sp_WijzigMedewerkerIngeplandProject TO MEDEWERKER
GRANT EXECUTE on sp_InsertProjLidOpSubProj TO MEDEWERKER
GRANT EXECUTE on sp_InsertSubproject TO MEDEWERKER
GRANT EXECUTE on sp_VerwijderenMedewerkerIngeplandProject TO MEDEWERKER
GRANT EXECUTE on sp_WijzigSubproject TO MEDEWERKER


--SUPERUSER rollen, hij kan alle views en stored procedures uitvoeren. Ook kan hij alle tables bekijken.
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
GRANT SELECT ON projectlid_op_subproject TO SUPERUSER
GRANT SELECT ON subproject TO SUPERUSER
GRANT SELECT ON subproject_categorie TO SUPERUSER
GRANT SELECT ON tag_van_categorie TO SUPERUSER
--EXECUTE PROCEDURES
GRANT EXECUTE ON sp_InsertProject TO SUPERUSER
GRANT EXECUTE ON sp_InsertProjectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerkerOpProject TO SUPERUSER
GRANT EXECUTE ON sp_InsertSubproject TO SUPERUSER
GRANT EXECUTE ON sp_InsertSubprojectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_InsertProjLidOpSubProj TO SUPERUSER
GRANT EXECUTE ON sp_InsertCategorieTag TO SUPERUSER
GRANT EXECUTE ON sp_InsertTagVanCategorie TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenMedewerkerRol TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenProjectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_verwijderenProjectrol TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenMedewerkerIngeplandProject TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenMedewerkerRolType TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenProjectlidOpSubproject TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderenSubprojectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderSubproject TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderCategorieTag TO SUPERUSER
GRANT EXECUTE ON sp_VerwijderTagVanCategorie TO SUPERUSER
GRANT EXECUTE ON sp_DropConstraint TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerker TO SUPERUSER
GRANT EXECUTE ON sp_InsertProjecturenMedewerker TO SUPERUSER
GRANT EXECUTE ON sp_InsertBeschikbareDagen TO SUPERUSER
GRANT EXECUTE ON sp_checkProjectRechten TO SUPERUSER
GRANT EXECUTE ON sp_WijzigProjectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_WijzigProjectRol TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerkerRolType TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerkerBeschikbareDagen TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerkerRol TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerkerOpProject TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerkerIngeplandProject TO SUPERUSER
GRANT EXECUTE ON sp_WijzigMedewerker TO SUPERUSER
GRANT EXECUTE ON sp_WijzigProject TO SUPERUSER
GRANT EXECUTE ON sp_WijzigProjectlidOpSubproject TO SUPERUSER
GRANT EXECUTE ON sp_WijzigSubprojectCategorie TO SUPERUSER
GRANT EXECUTE ON sp_WijzigSubproject TO SUPERUSER
GRANT EXECUTE ON sp_WijzigCategorieTag TO SUPERUSER
GRANT EXECUTE ON sp_WijzigTagVanCategorie TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerkerRol TO SUPERUSER
GRANT EXECUTE ON sp_InsertMedewerkerRolType TO SUPERUSER
GRANT EXECUTE ON sp_InsertProjectRolType TO SUPERUSER


