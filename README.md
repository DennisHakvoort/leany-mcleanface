# lean-mcleanyface
If I could be your lean saus.


BR1 Medewerker_beshikbaar(beschikbaar_uren) kan niet meer zijn dan 184
BR2 Medewerker_beshikbaar(beschikbaar_uren) kan niet minder zijn dan 0
BR3 medewerker(medewerker_code) bestaat uit de eerste letter van de voornaam, de eerste letter van de achternaam en een volgnummer die met één verhoogd wanneer de medewerker code al bestaat.
BR4 er kan geen record worden opgenomen in medewerker_ingepland_project voor een user die die maand niet beschikbaar is voor werk (waar medewerker_beschikbaarheid niet bestaat voor die user)
BR5 Medewerker_ingepland_project(medewerker_uren) kan niet minder zijn dan 0
BR6 Medewerker_ingepland_project(medewerker_uren) kan niet meer zijn dan 184
BR7 project(eind_datum) moet na project(begin_datum) vallen
BR8 project_categorie(parent) moet een waarde zijn uit de project_categorie(naam) of NULL. Het kan niet naar zichzelf verwijzen.
BR9 De waarden van project, medewerker op project en medewerker_ingepland_project kunnen niet meer worden aangepast als project(eind_datum) is verstreken,
BR10medewerker_beschikbaarheid kan niet worden aangepast als medewerker_beschikbaarheid(maand) is verstreken
BR11 medewerker_ingepland_project kan niet meer worden aangepast als medewerker_ingepland_project(maand_datum) is verstreken
