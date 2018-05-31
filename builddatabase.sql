--Query -> SQLCMD mode
--path verplaatsen met jouw pad naar de folder waar alle bestanden staan.
:setvar path "C:\Users\duppi\OneDrive\Datagrip\leany-mcleanface"
:setvar create "\Create database.sql"
:setvar businessrules "\Business rules.sql"
:r $(path)$(create)
:r $(path)\generated.sql
:r $(path)$(businessrules)
:r $(path)\aanpasProcedures.sql
:r $(path)\overigeInsertProc.sql
:r $(path)\ProceduresVoorDeletes.sql
:r $(path)\Views.sql
:r $(path)\createRoles.sql

--kopieerplakplek voor pad, scheelt gezoek
--Dennis: C:\Users\duppi\OneDrive\Datagrip\leany-mcleanface