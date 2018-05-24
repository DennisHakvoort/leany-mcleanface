--COMPLETELY WIPES OUT THE DATABASE, BE CAREFUL--
USE Master

DROP DATABASE IF EXISTS LeanDb;

CREATE DATABASE LeanDb
GO

USE LeanDb
GO

/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     24-5-2018 10:51:54                           */
/*==============================================================*/


if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_beschikbaarheid') and o.name = 'FK_BESCHIKBAARHEID_MEDEWERKER')
alter table medewerker_beschikbaarheid
   drop constraint FK_BESCHIKBAARHEID_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_ingepland_project') and o.name = 'FK_MEDEWERKER_INGEPLAND_PROJECT')
alter table medewerker_ingepland_project
   drop constraint FK_MEDEWERKER_INGEPLAND_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERKER_ROL_PROJECT')
alter table medewerker_op_project
   drop constraint FK_MEDEWERKER_ROL_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_PROJECT_MEDEWERKER')
alter table medewerker_op_project
   drop constraint FK_PROJECT_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERKER_PROJECT')
alter table medewerker_op_project
   drop constraint FK_MEDEWERKER_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_rol') and o.name = 'FK_MEDEWERKER_ROL')
alter table medewerker_rol
   drop constraint FK_MEDEWERKER_ROL
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('medewerker_rol') and o.name = 'FK_ROL_MEDEWERKER')
alter table medewerker_rol
   drop constraint FK_ROL_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('project') and o.name = 'FK_PROJECT_CATEGORIE')
alter table project
   drop constraint FK_PROJECT_CATEGORIE
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('tag_van_categorie') and o.name = 'FK_TAG_VAN__TAG_VAN_C_PROJECT_')
alter table tag_van_categorie
   drop constraint FK_TAG_VAN__TAG_VAN_C_PROJECT_
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('tag_van_categorie') and o.name = 'FK_TAG_VAN__TAG_VAN_C_CATEGORI')
alter table tag_van_categorie
   drop constraint FK_TAG_VAN__TAG_VAN_C_CATEGORI
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
            from  sysobjects
           where  id = object_id('medewerker_ingepland_project')
            and   type = 'U')
   drop table medewerker_ingepland_project
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
            and   name  = 'HEEFT_ALS_ROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_rol.HEEFT_ALS_ROL_FK
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
   from varchar(3)
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
   tag_naam             CATEGORIE_NAAM       not null,
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
   constraint PK_MEDEWERKER_BESCHIKBAARHEID primary key (medewerker_code, maand)
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
   id                   ID                   not null,
   medewerker_uren      UREN                 not null,
   maand_datum          MAAND                not null,
   constraint PK_MEDEWERKER_INGEPLAND_PROJEC primary key nonclustered (id, medewerker_uren, maand_datum)
)
go

/*==============================================================*/
/* Table: medewerker_op_project                                 */
/*==============================================================*/
create table medewerker_op_project (
   id                   ID                   not null             IDENTITY,
   project_code         PROJECT_CODE         not null,
   medewerker_code      MEDEWERKER_CODE      not null,
   project_rol          PROJECT_ROL          not null,
   constraint PK_MEDEWERKER_OP_PROJECT primary key nonclustered (id)
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
/* Table: medewerker_rol                                        */
/*==============================================================*/
create table medewerker_rol (
   medewerker_code      MEDEWERKER_CODE      not null,
   medewerker_rol       MEDEWERKER_ROL       not null,
   constraint PK_MEDEWERKER_ROL primary key nonclustered (medewerker_code, medewerker_rol)
)
go

/*==============================================================*/
/* Index: HEEFT_ALS_ROL_FK                                      */
/*==============================================================*/
create index HEEFT_ALS_ROL_FK on medewerker_rol (
medewerker_code ASC
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
   parent               CATEGORIE_NAAM       null,
   constraint PK_PROJECT_CATEGORIE primary key nonclustered (naam)
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
/* Table: tag_van_categorie                                     */
/*==============================================================*/
create table tag_van_categorie (
   naam                 CATEGORIE_NAAM       not null,
   tag_naam             CATEGORIE_NAAM       not null,
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
   add constraint FK_BESCHIKBAARHEID_MEDEWERKER foreign key (medewerker_code)
      references medewerker (medewerker_code)
go

alter table medewerker_ingepland_project
   add constraint FK_MEDEWERKER_INGEPLAND_PROJECT foreign key (id)
      references medewerker_op_project (id)
go

alter table medewerker_op_project
   add constraint FK_MEDEWERKER_ROL_PROJECT foreign key (project_rol)
      references project_rol_type (project_rol)
go

alter table medewerker_op_project
   add constraint FK_PROJECT_MEDEWERKER foreign key (project_code)
      references project (project_code)
go

alter table medewerker_op_project
   add constraint FK_MEDEWERKER_PROJECT foreign key (medewerker_code)
      references medewerker (medewerker_code)
go

alter table medewerker_rol
   add constraint FK_MEDEWERKER_ROL foreign key (medewerker_code)
      references medewerker (medewerker_code)
go

alter table medewerker_rol
   add constraint FK_ROL_MEDEWERKER foreign key (medewerker_rol)
      references medewerker_rol_type (medewerker_rol)
go

alter table project
   add constraint FK_PROJECT_CATEGORIE foreign key (categorie_naam)
      references project_categorie (naam)
go

alter table tag_van_categorie
   add constraint FK_TAG_VAN__TAG_VAN_C_PROJECT_ foreign key (naam)
      references project_categorie (naam)
go

alter table tag_van_categorie
   add constraint FK_TAG_VAN__TAG_VAN_C_CATEGORI foreign key (tag_naam)
      references categorie_tag (tag_naam)
go

