--COMPLETELY WIPES OUT THE DATABASE, BE CAREFUL--

DROP DATABASE IF EXISTS LeanDb

CREATE DATABASE LeanDb
	
	/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2008                    */
/* Created on:     8-5-2018 11:59:13                            */
/*==============================================================*/


if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_BESCHIKBAARHEID') and o.name = 'FK_BESCHIKBAARHEID_MEDEWERKER')
alter table MEDEWERKER_BESCHIKBAARHEID
   drop constraint FK_BESCHIKBAARHEID_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_INGEPLAND_PROJECT') and o.name = 'FK_MEDEWERKER_INGEPLAND_PROJECT')
alter table MEDEWERKER_INGEPLAND_PROJECT
   drop constraint FK_MEDEWERKER_INGEPLAND_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_OP_PROJECT') and o.name = 'FK_PROJECT_MEDEWERKER')
alter table MEDEWERKER_OP_PROJECT
   drop constraint FK_PROJECT_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_OP_PROJECT') and o.name = 'FK_MEDEWERKER_PROJECT')
alter table MEDEWERKER_OP_PROJECT
   drop constraint FK_MEDEWERKER_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_OP_PROJECT') and o.name = 'FK_MEDEWERKER_ROL_PROJECT')
alter table MEDEWERKER_OP_PROJECT
   drop constraint FK_MEDEWERKER_ROL_PROJECT
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_ROL') and o.name = 'FK_MEDEWERKER_ROL')
alter table MEDEWERKER_ROL
   drop constraint FK_MEDEWERKER_ROL
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MEDEWERKER_ROL') and o.name = 'FK_ROL_MEDEWERKER')
alter table MEDEWERKER_ROL
   drop constraint FK_ROL_MEDEWERKER
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('PROJECT') and o.name = 'FK_PROJECT_CATEGORIE')
alter table PROJECT
   drop constraint FK_PROJECT_CATEGORIE
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER')
            and   type = 'U')
   drop table MEDEWERKER
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('MEDEWERKER_BESCHIKBAARHEID')
            and   name  = 'BESCHIKBAAR_VOOR_FK'
            and   indid > 0
            and   indid < 255)
   drop index MEDEWERKER_BESCHIKBAARHEID.BESCHIKBAAR_VOOR_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER_BESCHIKBAARHEID')
            and   type = 'U')
   drop table MEDEWERKER_BESCHIKBAARHEID
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER_INGEPLAND_PROJECT')
            and   type = 'U')
   drop table MEDEWERKER_INGEPLAND_PROJECT
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('MEDEWERKER_OP_PROJECT')
            and   name  = 'NEEMT_DEEL_AAN_FK'
            and   indid > 0
            and   indid < 255)
   drop index MEDEWERKER_OP_PROJECT.NEEMT_DEEL_AAN_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER_OP_PROJECT')
            and   type = 'U')
   drop table MEDEWERKER_OP_PROJECT
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('MEDEWERKER_ROL')
            and   name  = 'HEEFT_ALS_ROL_FK'
            and   indid > 0
            and   indid < 255)
   drop index MEDEWERKER_ROL.HEEFT_ALS_ROL_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER_ROL')
            and   type = 'U')
   drop table MEDEWERKER_ROL
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MEDEWERKER_ROL_TYPE')
            and   type = 'U')
   drop table MEDEWERKER_ROL_TYPE
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('PROJECT')
            and   name  = 'IS_VAN_TYPE_FK'
            and   indid > 0
            and   indid < 255)
   drop index PROJECT.IS_VAN_TYPE_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROJECT')
            and   type = 'U')
   drop table PROJECT
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROJECT_CATEGORIE')
            and   type = 'U')
   drop table PROJECT_CATEGORIE
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PROJECT_ROL_TYPE')
            and   type = 'U')
   drop table PROJECT_ROL_TYPE
go

if exists(select 1 from systypes where name='ACHTERNAAM')
   drop type ACHTERNAAM
go

if exists(select 1 from systypes where name='CATEGORIE_NAAM')
   drop type CATEGORIE_NAAM
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

if exists(select 1 from systypes where name='VOORNAAM')
   drop type VOORNAAM
go

/*==============================================================*/
/* Domain: ACHTERNAAM                                           */
/*==============================================================*/
create type ACHTERNAAM
   from char(20)
go

/*==============================================================*/
/* Domain: CATEGORIE_NAAM                                       */
/*==============================================================*/
create type CATEGORIE_NAAM
   from char(40)
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
   from char(3)
go

/*==============================================================*/
/* Domain: MEDEWERKER_ROL                                       */
/*==============================================================*/
create type MEDEWERKER_ROL
   from char(40)
go

/*==============================================================*/
/* Domain: PROJECT_CODE                                         */
/*==============================================================*/
create type PROJECT_CODE
   from char(20)
go

/*==============================================================*/
/* Domain: PROJECT_NAAM                                         */
/*==============================================================*/
create type PROJECT_NAAM
   from char(40)
go

/*==============================================================*/
/* Domain: PROJECT_ROL                                          */
/*==============================================================*/
create type PROJECT_ROL
   from char(40)
go

/*==============================================================*/
/* Domain: UREN                                                 */
/*==============================================================*/
create type UREN
   from datetime
go

/*==============================================================*/
/* Domain: VOORNAAM                                             */
/*==============================================================*/
create type VOORNAAM
   from char(20)
go

/*==============================================================*/
/* Table: MEDEWERKER                                            */
/*==============================================================*/
create table MEDEWERKER (
   MEDEWERKER_CODE      MEDEWERKER_CODE      not null,
   CATEGORIE_NAAM       CATEGORIE_NAAM       not null,
   ACHTERNAAM           ACHTERNAAM           not null,
   VOORNAAM             VOORNAAM             not null,
   constraint PK_MEDEWERKER primary key nonclustered (MEDEWERKER_CODE)
)
go

/*==============================================================*/
/* Table: MEDEWERKER_BESCHIKBAARHEID                            */
/*==============================================================*/
create table MEDEWERKER_BESCHIKBAARHEID (
   MEDEWERKER_CODE      MEDEWERKER_CODE      not null,
   JAAR                 JAAR                 not null,
   BESCHIKBAAR_UREN     UREN                 not null,
   constraint PK_MEDEWERKER_BESCHIKBAARHEID primary key (MEDEWERKER_CODE, JAAR, BESCHIKBAAR_UREN)
)
go

/*==============================================================*/
/* Index: BESCHIKBAAR_VOOR_FK                                   */
/*==============================================================*/
create index BESCHIKBAAR_VOOR_FK on MEDEWERKER_BESCHIKBAARHEID (
MEDEWERKER_CODE ASC
)
go

/*==============================================================*/
/* Table: MEDEWERKER_INGEPLAND_PROJECT                          */
/*==============================================================*/
create table MEDEWERKER_INGEPLAND_PROJECT (
   ID                   ID                   not null,
   MEDEWERKER_UREN      UREN                 not null,
   MAAND_DATUM          MAAND                not null,
   constraint PK_MEDEWERKER_INGEPLAND_PROJEC primary key nonclustered (ID, MEDEWERKER_UREN, MAAND_DATUM)
)
go

/*==============================================================*/
/* Table: MEDEWERKER_OP_PROJECT                                 */
/*==============================================================*/
create table MEDEWERKER_OP_PROJECT (
   ID                   ID                   not null,
   PROJECT_CODE         PROJECT_CODE         not null,
   MEDEWERKER_CODE      MEDEWERKER_CODE      not null,
   PROJECT_ROL          PROJECT_ROL          null,
   constraint PK_MEDEWERKER_OP_PROJECT primary key nonclustered (ID)
)
go

/*==============================================================*/
/* Index: NEEMT_DEEL_AAN_FK                                     */
/*==============================================================*/
create index NEEMT_DEEL_AAN_FK on MEDEWERKER_OP_PROJECT (
MEDEWERKER_CODE ASC
)
go

/*==============================================================*/
/* Table: MEDEWERKER_ROL                                        */
/*==============================================================*/
create table MEDEWERKER_ROL (
   MEDEWERKER_CODE      MEDEWERKER_CODE      not null,
   MEDEWERKER_ROL       MEDEWERKER_ROL       not null,
   constraint PK_MEDEWERKER_ROL primary key nonclustered (MEDEWERKER_CODE, MEDEWERKER_ROL)
)
go

/*==============================================================*/
/* Index: HEEFT_ALS_ROL_FK                                      */
/*==============================================================*/
create index HEEFT_ALS_ROL_FK on MEDEWERKER_ROL (
MEDEWERKER_CODE ASC
)
go

/*==============================================================*/
/* Table: MEDEWERKER_ROL_TYPE                                   */
/*==============================================================*/
create table MEDEWERKER_ROL_TYPE (
   MEDEWERKER_ROL       MEDEWERKER_ROL       not null,
   constraint PK_MEDEWERKER_ROL_TYPE primary key nonclustered (MEDEWERKER_ROL)
)
go

/*==============================================================*/
/* Table: PROJECT                                               */
/*==============================================================*/
create table PROJECT (
   PROJECT_CODE         PROJECT_CODE         not null,
   NAAM                 CATEGORIE_NAAM       not null,
   BEGIN_DATUM          DATUM                not null,
   EIND_DATUM           DATUM                not null,
   PROJECT_NAAM         char(40)             not null,
   constraint PK_PROJECT primary key nonclustered (PROJECT_CODE)
)
go

/*==============================================================*/
/* Index: IS_VAN_TYPE_FK                                        */
/*==============================================================*/
create index IS_VAN_TYPE_FK on PROJECT (
NAAM ASC
)
go

/*==============================================================*/
/* Table: PROJECT_CATEGORIE                                     */
/*==============================================================*/
create table PROJECT_CATEGORIE (
   NAAM                 CATEGORIE_NAAM       not null,
   PARENT               CATEGORIE_NAAM       null,
   constraint PK_PROJECT_CATEGORIE primary key nonclustered (NAAM)
)
go

/*==============================================================*/
/* Table: PROJECT_ROL_TYPE                                      */
/*==============================================================*/
create table PROJECT_ROL_TYPE (
   PROJECT_ROL          PROJECT_ROL          not null,
   constraint PK_PROJECT_ROL_TYPE primary key nonclustered (PROJECT_ROL)
)
go

alter table MEDEWERKER_BESCHIKBAARHEID
   add constraint FK_BESCHIKBAARHEID_MEDEWERKER foreign key (MEDEWERKER_CODE)
      references MEDEWERKER (MEDEWERKER_CODE)
go

alter table MEDEWERKER_INGEPLAND_PROJECT
   add constraint FK_MEDEWERKER_INGEPLAND_PROJECT foreign key (ID)
      references MEDEWERKER_OP_PROJECT (ID)
go

alter table MEDEWERKER_OP_PROJECT
   add constraint FK_PROJECT_MEDEWERKER foreign key (PROJECT_CODE)
      references PROJECT (PROJECT_CODE)
go

alter table MEDEWERKER_OP_PROJECT
   add constraint FK_MEDEWERKER_PROJECT foreign key (MEDEWERKER_CODE)
      references MEDEWERKER (MEDEWERKER_CODE)
go

alter table MEDEWERKER_OP_PROJECT
   add constraint FK_MEDEWERKER_ROL_PROJECT foreign key (PROJECT_ROL)
      references PROJECT_ROL_TYPE (PROJECT_ROL)
go

alter table MEDEWERKER_ROL
   add constraint FK_MEDEWERKER_ROL foreign key (MEDEWERKER_CODE)
      references MEDEWERKER (MEDEWERKER_CODE)
go

alter table MEDEWERKER_ROL
   add constraint FK_ROL_MEDEWERKER foreign key (MEDEWERKER_ROL)
      references MEDEWERKER_ROL_TYPE (MEDEWERKER_ROL)
go

alter table PROJECT
   add constraint FK_PROJECT_CATEGORIE foreign key (NAAM)
      references PROJECT_CATEGORIE (NAAM)
go

