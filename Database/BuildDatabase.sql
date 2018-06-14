--Query -> SQLCMD mode
--path verplaatsen met jouw pad naar de folder waar alle bestanden staan.
:setvar path "C:\Users\HH Nguyen\Documents\GitHub\leany-mcleanface"
:r $(path)\CreateDatabase.sql
:r $(path)\BusinessRules.sql
:r $(path)\WijzigProcedures.sql
:r $(path)\InsertProcedures.sql
:r $(path)\DeleteProcedures.sql
:r $(path)\Views.sql
:r $(path)\createRoles.sql
