--COMPLETELY WIPES OUT THE DATABASE, BE CAREFUL--

/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     5-6-2018 10:12:47                            */
/*==============================================================*/

USE Master
GO

DROP DATABASE IF EXISTS LeanDb;
GO

CREATE DATABASE LeanDb
GO

USE LeanDb
GO


if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_beschikbaarheid') and o.name = 'FK_MEDEWERK_BESCHIKBA_MEDEWERK')
alter table medewerker_beschikbaarheid
   drop constraint FK_MEDEWERK_BESCHIKBA_MEDEWERK
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_ingepland_project') and o.name = 'FK_MEDEWERK_UREN_INGE_MEDEWERK')
alter table medewerker_ingepland_project
   drop constraint FK_MEDEWERK_UREN_INGE_MEDEWERK
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERK_HEEFT_ALS_PROJECT_')
alter table medewerker_op_project
   drop constraint FK_MEDEWERK_HEEFT_ALS_PROJECT_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERK_HEEFT_DEE_PROJECT')
alter table medewerker_op_project
   drop constraint FK_MEDEWERK_HEEFT_DEE_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERK_NEEMT_DEE_MEDEWERK')
alter table medewerker_op_project
   drop constraint FK_MEDEWERK_NEEMT_DEE_MEDEWERK
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_rol') and o.name = 'FK_MEDEWERKER_ROL_FK_MEDEWERKER_ROL_TYPE')
alter table medewerker_rol
   drop constraint FK_MEDEWERKER_ROL_FK_MEDEWERKER_ROL_TYPE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_rol') and o.name = 'FK_MEDEWERK_FK_MEDEWE_MEDEWERK')
alter table medewerker_rol
   drop constraint FK_MEDEWERK_FK_MEDEWE_MEDEWERK
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('project') and o.name = 'FK_PROJECT_IS_VAN_TY_PROJECT_')
alter table project
   drop constraint FK_PROJECT_IS_VAN_TY_PROJECT_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('project_categorie') and o.name = 'FK_PROJECT__PARENT_VA_PROJECT_')
alter table project_categorie
   drop constraint FK_PROJECT__PARENT_VA_PROJECT_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('projectlid_op_subproject') and o.name = 'FK_PROJECTL_PROJECTLI_SUBPROJE')
alter table projectlid_op_subproject
   drop constraint FK_PROJECTL_PROJECTLI_SUBPROJE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('projectlid_op_subproject') and o.name = 'FK_PROJECTL_PROJECT_S_MEDEWERK')
alter table projectlid_op_subproject
   drop constraint FK_PROJECTL_PROJECT_S_MEDEWERK
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('subproject') and o.name = 'FK_SUBPROJE_CATEGORIE_SUBPROJE')
alter table subproject
   drop constraint FK_SUBPROJE_CATEGORIE_SUBPROJE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('subproject') and o.name = 'FK_SUBPROJE_SUBPROJEC_PROJECT')
alter table subproject
   drop constraint FK_SUBPROJE_SUBPROJEC_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('tag_van_categorie') and o.name = 'FK_TAG_VAN_CATEGORIE_FK_CATEGORIE_TAG')
alter table tag_van_categorie
   drop constraint FK_TAG_VAN_CATEGORIE_FK_CATEGORIE_TAG
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('tag_van_categorie') and o.name = 'FK_TAG_VAN__FK_TAG_VA_PROJECT_')
alter table tag_van_categorie
   drop constraint FK_TAG_VAN__FK_TAG_VA_PROJECT_
go

if exists (select 1
            from  sysobjects
           where  id = object_id('categorie_tag')
            and   type = 'U')
   drop table categorie_tag
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker')
            and   type = 'U')
   drop table medewerker
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_beschikbaarheid')
            and   name  = 'BESCHIKBAAR_VOOR_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_beschikbaarheid.BESCHIKBAAR_VOOR_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker_beschikbaarheid')
            and   type = 'U')
   drop table medewerker_beschikbaarheid
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_ingepland_project')
            and   name  = 'UREN_INGEPLAND_OP_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_ingepland_project.UREN_INGEPLAND_OP_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker_ingepland_project')
            and   type = 'U')
   drop table medewerker_ingepland_project
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_op_project')
            and   name  = 'HEEFT_ALS_ROL_BINNEN_HET_PROJECT_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_op_project.HEEFT_ALS_ROL_BINNEN_HET_PROJECT_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_op_project')
            and   name  = 'HEEFT_DEELNEMERS_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_op_project.HEEFT_DEELNEMERS_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_op_project')
            and   name  = 'NEEMT_DEEL_AAN_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_op_project.NEEMT_DEEL_AAN_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker_op_project')
            and   type = 'U')
   drop table medewerker_op_project
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_rol')
            and   name  = 'HEEFT_DE_ROL2_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_rol.HEEFT_DE_ROL2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_rol')
            and   name  = 'HEEFT_DE_ROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_rol.HEEFT_DE_ROL_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker_rol')
            and   type = 'U')
   drop table medewerker_rol
go

if exists (select 1
            from  sysobjects
           where  id = object_id('medewerker_rol_type')
            and   type = 'U')
   drop table medewerker_rol_type
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('project')
            and   name  = 'IS_VAN_TYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index project.IS_VAN_TYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('project')
            and   type = 'U')
   drop table project
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('project_categorie')
            and   name  = 'PARENT_VAN_CATEGORIE_FK'
            and   indid > 0
            and   indid < 255)
   drop index project_categorie.PARENT_VAN_CATEGORIE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('project_categorie')
            and   type = 'U')
   drop table project_categorie
go

if exists (select 1
            from  sysobjects
           where  id = object_id('project_rol_type')
            and   type = 'U')
   drop table project_rol_type
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('projectlid_op_subproject')
            and   name  = 'PROJECT_SUBTAAK_MEDEWERKER_FK'
            and   indid > 0
            and   indid < 255)
   drop index projectlid_op_subproject.PROJECT_SUBTAAK_MEDEWERKER_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('projectlid_op_subproject')
            and   name  = 'PROJECTLID_INGEDEELD_OP_SUBPROJECT_FK'
            and   indid > 0
            and   indid < 255)
   drop index projectlid_op_subproject.PROJECTLID_INGEDEELD_OP_SUBPROJECT_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('projectlid_op_subproject')
            and   type = 'U')
   drop table projectlid_op_subproject
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('subproject')
            and   name  = 'CATEGORIE_VAN_SUBPROJECT_FK'
            and   indid > 0
            and   indid < 255)
   drop index subproject.CATEGORIE_VAN_SUBPROJECT_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('subproject')
            and   name  = 'SUBPROJECT_IN_PROJECT_FK'
            and   indid > 0
            and   indid < 255)
   drop index subproject.SUBPROJECT_IN_PROJECT_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('subproject')
            and   type = 'U')
   drop table subproject
go

if exists (select 1
            from  sysobjects
           where  id = object_id('subproject_categorie')
            and   type = 'U')
   drop table subproject_categorie
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('tag_van_categorie')
            and   name  = 'TAG_VAN_CATEGORIE2_FK'
            and   indid > 0
            and   indid < 255)
   drop index tag_van_categorie.TAG_VAN_CATEGORIE2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('tag_van_categorie')
            and   name  = 'TAG_VAN_CATEGORIE_FK'
            and   indid > 0
            and   indid < 255)
   drop index tag_van_categorie.TAG_VAN_CATEGORIE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('tag_van_categorie')
            and   type = 'U')
   drop table tag_van_categorie
go

if exists(select 1 from systypes where name='CATEGORIE_NAAM')
   drop type CATEGORIE_NAAM
go

if exists(select 1 from systypes where name='DAGEN')
   drop type DAGEN
go

if exists(select 1 from systypes where name='DATUM')
   drop type DATUM
go

if exists(select 1 from systypes where name='ID')
   drop type ID
go

if exists(select 1 from systypes where name='JAAR')
   drop type JAAR
go

if exists(select 1 from systypes where name='MAAND')
   drop type MAAND
go

if exists(select 1 from systypes where name='MEDEWERKER_CODE')
   drop type MEDEWERKER_CODE
go

if exists(select 1 from systypes where name='MEDEWERKER_ROL')
   drop type MEDEWERKER_ROL
go

if exists(select 1 from systypes where name='NAAM')
   drop type NAAM
go

if exists(select 1 from systypes where name='PROJECT_CODE')
   drop type PROJECT_CODE
go

if exists(select 1 from systypes where name='PROJECT_NAAM')
   drop type PROJECT_NAAM
go

if exists(select 1 from systypes where name='PROJECT_ROL')
   drop type PROJECT_ROL
go

if exists(select 1 from systypes where name='UREN')
   drop type UREN
go

/*==============================================================*/
/* Domain: CATEGORIE_NAAM                                       */
/*==============================================================*/
create type CATEGORIE_NAAM
   from varchar(40)
go

/*==============================================================*/
/* Domain: DAGEN                                                */
/*==============================================================*/
create type DAGEN
   from int
go

/*==============================================================*/
/* Domain: DATUM                                                */
/*==============================================================*/
create type DATUM
   from datetime
go

/*==============================================================*/
/* Domain: ID                                                   */
/*==============================================================*/
create type ID
   from int
go

/*==============================================================*/
/* Domain: JAAR                                                 */
/*==============================================================*/
create type JAAR
   from datetime
go

/*==============================================================*/
/* Domain: MAAND                                                */
/*==============================================================*/
create type MAAND
   from datetime
go

/*==============================================================*/
/* Domain: MEDEWERKER_CODE                                      */
/*==============================================================*/
create type MEDEWERKER_CODE
   from varchar(5)
go

/*==============================================================*/
/* Domain: MEDEWERKER_ROL                                       */
/*==============================================================*/
create type MEDEWERKER_ROL
   from varchar(40)
go

/*==============================================================*/
/* Domain: NAAM                                                 */
/*==============================================================*/
create type NAAM
   from nvarchar(20)
go

/*==============================================================*/
/* Domain: PROJECT_CODE                                         */
/*==============================================================*/
create type PROJECT_CODE
   from varchar(20)
go

/*==============================================================*/
/* Domain: PROJECT_NAAM                                         */
/*==============================================================*/
create type PROJECT_NAAM
   from varchar(40)
go

/*==============================================================*/
/* Domain: PROJECT_ROL                                          */
/*==============================================================*/
create type PROJECT_ROL
   from varchar(40)
go

/*==============================================================*/
/* Domain: UREN                                                 */
/*==============================================================*/
create type UREN
   from int
go

/*==============================================================*/
/* Table: categorie_tag                                         */
/*==============================================================*/
create table categorie_tag (
   tag_naam             nvarchar(40)         not null,
   constraint PK_CATEGORIE_TAG primary key nonclustered (tag_naam)
)
go

/*==============================================================*/
/* Table: medewerker                                            */
/*==============================================================*/
create table medewerker (
   medewerker_code      MEDEWERKER_CODE      not null,
   voornaam             NAAM                 not null,
   achternaam           NAAM                 not null,
   constraint PK_MEDEWERKER primary key nonclustered (medewerker_code)
)
go

/*==============================================================*/
/* Table: medewerker_beschikbaarheid                            */
/*==============================================================*/
create table medewerker_beschikbaarheid (
   medewerker_code      MEDEWERKER_CODE      not null,
   maand                JAAR                 not null,
   beschikbare_dagen    DAGEN                not null,
   constraint PK_MEDEWERKER_BESCHIKBAARHEID primary key nonclustered (medewerker_code, maand)
)
go

/*==============================================================*/
/* Index: BESCHIKBAAR_VOOR_FK                                   */
/*==============================================================*/
create index BESCHIKBAAR_VOOR_FK on medewerker_beschikbaarheid (
medewerker_code ASC
)
go

/*==============================================================*/
/* Table: medewerker_ingepland_project                          */
/*==============================================================*/
create table medewerker_ingepland_project (
   id                   integer              not null,
   medewerker_uren      UREN                 not null,
   maand_datum          MAAND                not null,
   constraint PK_MEDEWERKER_INGEPLAND_PROJEC primary key nonclustered (maand_datum, id)
)
go

/*==============================================================*/
/* Index: UREN_INGEPLAND_OP_FK                                  */
/*==============================================================*/
create index UREN_INGEPLAND_OP_FK on medewerker_ingepland_project (
id ASC
)
go

/*==============================================================*/
/* Table: medewerker_op_project                                 */
/*==============================================================*/
create table medewerker_op_project (
   id                   integer              not null           IDENTITY,
   project_code         PROJECT_CODE         not null,
   medewerker_code      MEDEWERKER_CODE      not null,
   project_rol          PROJECT_ROL          not null,
   constraint PK_MEDEWERKER_OP_PROJECT primary key (id)
)
go

/*==============================================================*/
/* Index: NEEMT_DEEL_AAN_FK                                     */
/*==============================================================*/
create index NEEMT_DEEL_AAN_FK on medewerker_op_project (
medewerker_code ASC
)
go

/*==============================================================*/
/* Index: HEEFT_DEELNEMERS_FK                                   */
/*==============================================================*/
create index HEEFT_DEELNEMERS_FK on medewerker_op_project (
project_code ASC
)
go

/*==============================================================*/
/* Index: HEEFT_ALS_ROL_BINNEN_HET_PROJECT_FK                   */
/*==============================================================*/
create index HEEFT_ALS_ROL_BINNEN_HET_PROJECT_FK on medewerker_op_project (
project_rol ASC
)
go

/*==============================================================*/
/* Table: medewerker_rol                                        */
/*==============================================================*/
create table medewerker_rol (
   medewerker_code      MEDEWERKER_CODE      not null,
   medewerker_rol       MEDEWERKER_ROL       not null,
   constraint PK_MEDEWERKER_ROL primary key (medewerker_code, medewerker_rol)
)
go

/*==============================================================*/
/* Index: HEEFT_DE_ROL_FK                                       */
/*==============================================================*/
create index HEEFT_DE_ROL_FK on medewerker_rol (
medewerker_code ASC
)
go

/*==============================================================*/
/* Index: HEEFT_DE_ROL2_FK                                      */
/*==============================================================*/
create index HEEFT_DE_ROL2_FK on medewerker_rol (
medewerker_rol ASC
)
go

/*==============================================================*/
/* Table: medewerker_rol_type                                   */
/*==============================================================*/
create table medewerker_rol_type (
   medewerker_rol       MEDEWERKER_ROL       not null,
   constraint PK_MEDEWERKER_ROL_TYPE primary key nonclustered (medewerker_rol)
)
go

/*==============================================================*/
/* Table: project                                               */
/*==============================================================*/
create table project (
   project_code         PROJECT_CODE         not null,
   categorie_naam       CATEGORIE_NAAM       not null,
   begin_datum          DATUM                not null,
   eind_datum           DATUM                not null,
   project_naam         PROJECT_NAAM         not null,
   verwachte_uren       UREN                 null,
   constraint PK_PROJECT primary key nonclustered (project_code)
)
go

/*==============================================================*/
/* Index: IS_VAN_TYPE_FK                                        */
/*==============================================================*/
create index IS_VAN_TYPE_FK on project (
categorie_naam ASC
)
go

/*==============================================================*/
/* Table: project_categorie                                     */
/*==============================================================*/
create table project_categorie (
   naam                 CATEGORIE_NAAM       not null,
   hoofdcategorie       CATEGORIE_NAAM       null,
   constraint PK_PROJECT_CATEGORIE primary key nonclustered (naam)
)
go

/*==============================================================*/
/* Index: PARENT_VAN_CATEGORIE_FK                               */
/*==============================================================*/
create index PARENT_VAN_CATEGORIE_FK on project_categorie (
hoofdcategorie ASC
)
go

/*==============================================================*/
/* Table: project_rol_type                                      */
/*==============================================================*/
create table project_rol_type (
   project_rol          PROJECT_ROL          not null,
   constraint PK_PROJECT_ROL_TYPE primary key nonclustered (project_rol)
)
go

/*==============================================================*/
/* Table: projectlid_op_subproject                              */
/*==============================================================*/
create table projectlid_op_subproject (
   id                   integer              not null,
   project_code         PROJECT_CODE         not null,
   subproject_naam      PROJECT_NAAM         not null,
   subproject_uren      UREN                 null,
   constraint PK_PROJECTLID_OP_SUBPROJECT primary key (id, project_code, subproject_naam)
)
go

/*==============================================================*/
/* Index: PROJECTLID_INGEDEELD_OP_SUBPROJECT_FK                 */
/*==============================================================*/
create index PROJECTLID_INGEDEELD_OP_SUBPROJECT_FK on projectlid_op_subproject (
project_code ASC,
subproject_naam ASC
)
go

/*==============================================================*/
/* Index: PROJECT_SUBTAAK_MEDEWERKER_FK                         */
/*==============================================================*/
create index PROJECT_SUBTAAK_MEDEWERKER_FK on projectlid_op_subproject (
id ASC
)
go

/*==============================================================*/
/* Table: subproject                                            */
/*==============================================================*/
create table subproject (
   project_code         PROJECT_CODE         not null,
   subproject_naam      PROJECT_NAAM         not null,
   subproject_categorie_naam CATEGORIE_NAAM       not null,
   subproject_verwachte_uren UREN                 null,
   constraint PK_SUBPROJECT primary key nonclustered (project_code, subproject_naam)
)
go

/*==============================================================*/
/* Index: SUBPROJECT_IN_PROJECT_FK                              */
/*==============================================================*/
create index SUBPROJECT_IN_PROJECT_FK on subproject (
project_code ASC
)
go

/*==============================================================*/
/* Index: CATEGORIE_VAN_SUBPROJECT_FK                           */
/*==============================================================*/
create index CATEGORIE_VAN_SUBPROJECT_FK on subproject (
subproject_categorie_naam ASC
)
go

/*==============================================================*/
/* Table: subproject_categorie                                  */
/*==============================================================*/
create table subproject_categorie (
   subproject_categorie_naam CATEGORIE_NAAM       not null,
   constraint PK_SUBPROJECT_CATEGORIE primary key nonclustered (subproject_categorie_naam)
)
go

/*==============================================================*/
/* Table: tag_van_categorie                                     */
/*==============================================================*/
create table tag_van_categorie (
   naam                 CATEGORIE_NAAM       not null,
   tag_naam             nvarchar(40)         not null,
   constraint PK_TAG_VAN_CATEGORIE primary key (naam, tag_naam)
)
go

/*==============================================================*/
/* Index: TAG_VAN_CATEGORIE_FK                                  */
/*==============================================================*/
create index TAG_VAN_CATEGORIE_FK on tag_van_categorie (
naam ASC
)
go

/*==============================================================*/
/* Index: TAG_VAN_CATEGORIE2_FK                                 */
/*==============================================================*/
create index TAG_VAN_CATEGORIE2_FK on tag_van_categorie (
tag_naam ASC
)
go

alter table medewerker_beschikbaarheid
   add constraint FK_MEDEWERK_BESCHIKBA_MEDEWERK foreign key (medewerker_code)
      references medewerker (medewerker_code)
         on update cascade on delete cascade
go

alter table medewerker_ingepland_project
   add constraint FK_MEDEWERK_UREN_INGE_MEDEWERK foreign key (id)
      references medewerker_op_project (id)
         on update cascade on delete cascade
go

alter table medewerker_op_project
   add constraint FK_MEDEWERK_HEEFT_ALS_PROJECT_ foreign key (project_rol)
      references project_rol_type (project_rol)
         on update cascade
go

alter table medewerker_op_project
   add constraint FK_MEDEWERK_HEEFT_DEE_PROJECT foreign key (project_code)
      references project (project_code)
         on update cascade on delete cascade
go

alter table medewerker_op_project
   add constraint FK_MEDEWERK_NEEMT_DEE_MEDEWERK foreign key (medewerker_code)
      references medewerker (medewerker_code)
         on update cascade on delete cascade
go

alter table medewerker_rol
   add constraint FK_MEDEWERKER_ROL_FK_MEDEWERKER_ROL_TYPE foreign key (medewerker_rol)
      references medewerker_rol_type (medewerker_rol)
         on update cascade
go

alter table medewerker_rol
   add constraint FK_MEDEWERK_FK_MEDEWE_MEDEWERK foreign key (medewerker_code)
      references medewerker (medewerker_code)
         on update cascade on delete cascade
go

alter table project
   add constraint FK_PROJECT_IS_VAN_TY_PROJECT_ foreign key (categorie_naam)
      references project_categorie (naam)
         on update cascade
go

alter table project_categorie
   add constraint FK_PROJECT__PARENT_VA_PROJECT_ foreign key (hoofdcategorie)
      references project_categorie (naam)
go

alter table projectlid_op_subproject
   add constraint FK_PROJECTL_PROJECTLI_SUBPROJE foreign key (project_code, subproject_naam)
      references subproject (project_code, subproject_naam)
         on update cascade on delete cascade
go

alter table projectlid_op_subproject
   add constraint FK_PROJECTL_PROJECT_S_MEDEWERK foreign key (id)
      references medewerker_op_project (id)
         on update cascade on delete cascade
go

alter table subproject
   add constraint FK_SUBPROJE_CATEGORIE_SUBPROJE foreign key (subproject_categorie_naam)
      references subproject_categorie (subproject_categorie_naam)
         on update cascade
go

alter table subproject
   add constraint FK_SUBPROJE_SUBPROJEC_PROJECT foreign key (project_code)
      references project (project_code)
go

alter table tag_van_categorie
   add constraint FK_TAG_VAN_CATEGORIE_FK_CATEGORIE_TAG foreign key (tag_naam)
      references categorie_tag (tag_naam)
         on update cascade
go

alter table tag_van_categorie
   add constraint FK_TAG_VAN__FK_TAG_VA_PROJECT_ foreign key (naam)
      references project_categorie (naam)
         on update cascade on delete cascade
go

