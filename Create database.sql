--COMPLETELY WIPES OUT THE DATABASE, BE CAREFUL--
USE Master

DROP DATABASE IF EXISTS LeanDb;

CREATE DATABASE LeanDb
GO

USE LeanDb
GO

/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     8-5-2018 15:47:16                            */
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
   where r.fkeyid = object_id('medewerker_op_project') and o.name = 'FK_MEDEWERKER_ROL_PROJECT')
alter table medewerker_op_project
   drop constraint FK_MEDEWERKER_ROL_PROJECT
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
            from  sysobjects
           where  id = object_id('medewerker')
            and   type = 'U')
   drop table medewerker
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('medewerker_beschikbaarheid')
            and   name  = 'beschikbaar_voor_fk'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_beschikbaarheid.beschikbaar_voor_fk
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
            and   name  = 'neemt_deel_aan_fk'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_op_project.neemt_deel_aan_fk
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
            and   name  = 'heeft_als_rol_fk'
            and   indid > 0
            and   indid < 255)
   drop index medewerker_rol.heeft_als_rol_fk
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
            and   name  = 'is_van_type_fk'
            and   indid > 0
            and   indid < 255)
   drop index project.is_van_type_fk
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

if exists(select 1 from systypes where name='achternaam')
   drop type achternaam
go

if exists(select 1 from systypes where name='categorie_naam')
   drop type categorie_naam
go

if exists(select 1 from systypes where name='datum')
   drop type datum
go

if exists(select 1 from systypes where name='id')
   drop type id
go

if exists(select 1 from systypes where name='jaar')
   drop type jaar
go

if exists(select 1 from systypes where name='maand')
   drop type maand
go

if exists(select 1 from systypes where name='medewerker_code')
   drop type medewerker_code
go

if exists(select 1 from systypes where name='medewerker_rol')
   drop type medewerker_rol
go

if exists(select 1 from systypes where name='project_code')
   drop type project_code
go

if exists(select 1 from systypes where name='project_naam')
   drop type project_naam
go

if exists(select 1 from systypes where name='project_rol')
   drop type project_rol
go

if exists(select 1 from systypes where name='uren')
   drop type uren
go

if exists(select 1 from systypes where name='dagen')
   drop type dagen
go

if exists(select 1 from systypes where name='voornaam')
   drop type voornaam
go

/*==============================================================*/
/* Domain: achternaam                                           */
/*==============================================================*/
create type achternaam
   from nvarchar(20)
go

/*==============================================================*/
/* Domain: categorie_naam                                       */
/*==============================================================*/
create type categorie_naam
   from varchar(40)
go

/*==============================================================*/
/* Domain: datum                                                */
/*==============================================================*/
create type datum
   from datetime
go

/*==============================================================*/
/* Domain: id                                                   */
/*==============================================================*/
create type id
   from int
go

/*==============================================================*/
/* Domain: jaar                                                 */
/*==============================================================*/
create type jaar
   from datetime
go

/*==============================================================*/
/* Domain: maand                                                */
/*==============================================================*/
create type maand
   from datetime
go

/*==============================================================*/
/* Domain: medewerker_code                                      */
/*==============================================================*/
create type medewerker_code
   from varchar(4)
go

/*==============================================================*/
/* Domain: medewerker_rol                                       */
/*==============================================================*/
create type medewerker_rol
   from varchar(40)
go

/*==============================================================*/
/* Domain: project_code                                         */
/*==============================================================*/
create type project_code
   from varchar(20)
go

/*==============================================================*/
/* Domain: project_naam                                         */
/*==============================================================*/
create type project_naam
   from varchar(40)
go

/*==============================================================*/
/* Domain: project_rol                                          */
/*==============================================================*/
create type project_rol
   from varchar(40)
go

/*==============================================================*/
/* Domain: uren                                                 */
/*==============================================================*/
create type uren
   from int
go

/*==============================================================*/
/* Domain: dagen                                                */
/*==============================================================*/
create type dagen
   from int
go

/*==============================================================*/
/* Domain: voornaam                                             */
/*==============================================================*/
create type voornaam
   from nvarchar(20)
go

/*==============================================================*/
/* Table: medewerker                                            */
/*==============================================================*/
create table medewerker (
   medewerker_code      medewerker_code      not null,
   achternaam           achternaam           not null,
   voornaam             voornaam             not null,
   constraint PK_MEDEWERKER primary key nonclustered (medewerker_code)
)
go

/*==============================================================*/
/* Table: medewerker_beschikbaarheid                            */
/*==============================================================*/
create table medewerker_beschikbaarheid (
   medewerker_code      medewerker_code      not null,
   maand                jaar                 not null,
   beschikbare_dagen    dagen                not null,
   constraint PK_MEDEWERKER_BESCHIKBAARHEID primary key (medewerker_code, maand)
)
go

/*==============================================================*/
/* Index: beschikbaar_voor_fk                                   */
/*==============================================================*/
create index beschikbaar_voor_fk on medewerker_beschikbaarheid (
medewerker_code ASC
)
go

/*==============================================================*/
/* Table: medewerker_ingepland_project                          */
/*==============================================================*/
create table medewerker_ingepland_project (
   id                   id                   not null,
   medewerker_uren      uren                 not null,
   maand_datum          maand                not null,
   constraint PK_MEDEWERKER_INGEPLAND_PROJEC primary key nonclustered (id, medewerker_uren, maand_datum)
)
go

/*==============================================================*/
/* Table: medewerker_op_project                                 */
/*==============================================================*/
create table medewerker_op_project (
   id                   id                   IDENTITY(1,1) NOT NULL,
   project_code         project_code         not null,
   medewerker_code      medewerker_code      not null,
   project_rol          project_rol          null,
   constraint PK_MEDEWERKER_OP_PROJECT primary key nonclustered (id)
)
go

/*==============================================================*/
/* Index: neemt_deel_aan_fk                                     */
/*==============================================================*/
create index neemt_deel_aan_fk on medewerker_op_project (
medewerker_code ASC
)
go

/*==============================================================*/
/* Table: medewerker_rol                                        */
/*==============================================================*/
create table medewerker_rol (
   medewerker_code      medewerker_code      not null,
   medewerker_rol       medewerker_rol       not null,
   constraint PK_MEDEWERKER_ROL primary key nonclustered (medewerker_code, medewerker_rol)
)
go

/*==============================================================*/
/* Index: heeft_als_rol_fk                                      */
/*==============================================================*/
create index heeft_als_rol_fk on medewerker_rol (
medewerker_code ASC
)
go

/*==============================================================*/
/* Table: medewerker_rol_type                                   */
/*==============================================================*/
create table medewerker_rol_type (
   medewerker_rol       medewerker_rol       not null,
   constraint PK_MEDEWERKER_ROL_TYPE primary key nonclustered (medewerker_rol)
)
go

/*==============================================================*/
/* Table: project                                               */
/*==============================================================*/
create table project (
   project_code         project_code         not null,
   categorie_naam       categorie_naam       not null,
   begin_datum          datum                not null,
   eind_datum           datum                not null,
   project_naam         varchar(40)             not null,
   constraint PK_PROJECT primary key nonclustered (project_code)
)
go

/*==============================================================*/
/* Index: is_van_type_fk                                        */
/*==============================================================*/
create index is_van_type_fk on project (
categorie_naam ASC
)
go

/*==============================================================*/
/* Table: project_categorie                                     */
/*==============================================================*/
create table project_categorie (
   naam                 categorie_naam       not null,
   parent               categorie_naam       null,
   constraint PK_PROJECT_CATEGORIE primary key nonclustered (naam)
)
go

/*==============================================================*/
/* Table: project_rol_type                                      */
/*==============================================================*/
create table project_rol_type (
   project_rol          project_rol          not null,
   constraint PK_PROJECT_ROL_TYPE primary key nonclustered (project_rol)
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
   add constraint FK_PROJECT_MEDEWERKER foreign key (project_code)
      references project (project_code)
go

alter table medewerker_op_project
   add constraint FK_MEDEWERKER_PROJECT foreign key (medewerker_code)
      references medewerker (medewerker_code)
go

alter table medewerker_op_project
   add constraint FK_MEDEWERKER_ROL_PROJECT foreign key (project_rol)
      references project_rol_type (project_rol)
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

