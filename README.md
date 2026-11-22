# Frailty, healthcare use and costs (AIM1)

AIM1-analyysirepo sisältää käsikirjoitukseen jäljitetyn
K51/AUTH_SOURCE-pisteytyskoodin ja kolme malliajuria. WP1:n DEAC20-kokoaja
on osa K51-ketjua. Malliajurit käyttävät ulkoisten adapterien tuottamia
valmiita mallisyötteitä.

| Vaihe | Ajuri | Ajonaikaiset riippuvuudet |
| --- | --- | --- |
| K51/AUTH_SOURCE | [deac_run.py](DEAC-Frailty-Index/src/deac_run.py) | Pythonin vakiokirjasto, viisi paikallista moduulia, Git ja Linux/Termuxin `renameat2` |
| E1, neljä NB-mallia | [E1-ajuri](R/e1/aim1_e1_nb_assumption_runner.R) | Rscript, MASS ja jsonlite |
| E2/E3 v2, neljä NB-mallia | [E2/E3-ajuri](R/e2e3/aim1_e2e3_nb_assumption_runner.R) | Rscript, MASS ja jsonlite |
| Kaksiosainen kustannusmalli v2 | [Kustannusajuri](R/cost/aim1_cost_two_part_runner.R) | Rscript ja jsonlite |

[Ajo-ohje](docs/RUNNING.md) kuvaa syötteet ja tulosteet, ulkoisen
valmisteluketjun versiot sekä synteettiset testit. Historialliset
tutkimusajot tehtiin suojatussa lähdeympäristössä. Kohderepossa on
synteettinen testinäyttö. Suojattu toistoajo kohdereposta on tekemättä.
Osa historiallisen täsmätoiston apumoduuliversioista on varmentamatta.

[Koodin provenienssi](docs/PROVENANCE.md) ·
[WP1:n testiohje](docs/TESTING.md) · [WP1-katselmointi](docs/WP1_REVIEW.md)

Kokonaisuuden lisenssi on [MIT](LICENSE).
