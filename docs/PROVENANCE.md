# WP1:n koodiprovenienssi

Tarkistettu 19.11.2026. Lähderepo: `Tupatuko2023/Python-R-Scripts`. Tarkistushetken lähdecheckoutin HEAD: `919b5cc94f80452806f0b30a351577bb9ba0bdde`. Molemmat tiedostot olivat Gitissä seurattuja ja työpuussa muuttumattomia. Kummankin tiedoston viimeinen polkukohtainen commit oli `5ae1c8ec830715d0b5976314273fa2b91fea9b7a`. HEAD on tarkistusympäristön konteksti; tiedostojen sisällön yksilöivät alla olevat SHA-256-arvot.

| Lähteen suhteellinen polku | Lähteen Git-tila | Lähteen SHA-256 | Kohteen suhteellinen polku | Kohteen SHA-256 | Tavuvastaavuus |
| --- | --- | --- | --- | --- | --- |
| `DEAC-Frailty-Index/src/deac_index.py` | seurattu, puhdas | `c3fe94b631d488a5c5923ce4f31edca866b435464b8e6ce986b5e07c568593d7` | `DEAC-Frailty-Index/src/deac_index.py` | `c3fe94b631d488a5c5923ce4f31edca866b435464b8e6ce986b5e07c568593d7` | PASS |
| `tests/test_deac_index.py` | seurattu, puhdas | `396b798f73aced664deb0479a495bc2d9e8febb825bfc9dc5177b71e9ead1713` | `tests/test_deac_index.py` | `396b798f73aced664deb0479a495bc2d9e8febb825bfc9dc5177b71e9ead1713` | PASS |

Nämä hashit vastaavat AIM1-lisäosan lähdemanifestissa ilmoitettuja vertailuversioita. Siirrossa ei muutettu laskentalogiikkaa, testiä, importia eikä paketointia.

Lähderepon juuren `LICENSE` on MIT-lisenssi, tekijämerkintä `Copyright (c) 2025 Tomi Korpi`; myös juuren `README.md` viittaa projektin MIT-lisenssiin. `.github/CONTRIBUTING.md` §11 sanoo, että tähän repoon kontribuoitu koodi lisensoidaan projektin MIT-lisenssillä. `LICENSE` kopioitiin kohteeseen tavutarkasti (SHA-256 `9376874055d4aee919c382209a5906af10b52cc0e17590bf28af5ee70752c169`). Ainoa Gitin seuraama lisenssitiedosto lähderepossa on juuren `LICENSE`; DEAC-hakemistossa ei ole omaa lisenssitiedostoa, eikä kummassakaan siirretyssä Python-tiedostossa ole erillistä lisenssi- tai tekijäotsaketta.

Lähderepon `package.json` ilmoittaa ISC:n nimelle `python-r-scripts`
ja sen npm-paketille. Julkaisu sisältää alla yksilöidyt Python- ja
R-tiedostot, niiden testit ja dokumentaation. Omistaja valtuutti tämän
koodikokonaisuuden julkisen toimituksen. MIT-lisenssi ja Tomi Korven
alkuperäinen tekijänoikeusmerkintä sisältyvät tiedostoon `LICENSE`.

## K51/AUTH_SOURCE-ajon historiallinen pisteytyskoodi

Lähderepo `Tupatuko2023/Python-R-Scripts`, commit
`c15ed24d1b901f83a70a1546858786160b49905c`. Yksityisen ajon
`20261005T105241Z` manifestin kooditiivisteet tarkistettiin sekä
lähdecommitin blobeista että kohteen tiedostoista.

| Tiedosto polussa `DEAC-Frailty-Index/src/` | Ajomanifestia vastaava SHA-256 |
| --- | --- |
| `deac_run.py` | `b05a9140532bc4ae734c88dda0447bc205af644014ec4dd2948a19e86fb95328` |
| `deac_cohort_runner.py` | `dac703be13d35726b34f4083646165db041af2080a7ad2ffab46d39279891554` |
| `deac_source_adapter.py` | `cd072b427ca4b93000c19d77419e8a250af82c2130a884d093d70a88051a627f` |
| `deac_components.py` | `c66b711788f29c73b73317b0d6d55cdd949e6a8db7bbb5a2945575bab67410e5` |
| `deac_moi.py` | `f404f054f299a05c30219e82cd0787a6eaaafadf0a0517b9b75750362faed3b6` |
| `deac_index.py` | `c3fe94b631d488a5c5923ce4f31edca866b435464b8e6ce986b5e07c568593d7` |

Viisi moduulia kopioitiin tavutarkasti. WP1:n `deac_index.py` ja
`tests/test_deac_index.py` käytettiin sellaisinaan. Alkuperäinen
`DEAC-Frailty-Index/src/`-rakenne säilyttää moduulien importit ja ajurin
repojuuren tunnistuksen. Siirrossa ei muutettu polkuja, importeja tai laskentaa.

Lisenssitarkistus kattoi kaikki viisi moduulia erikseen. Lähdecommitin
juuren MIT-lisenssi ja kontribuutio-ohje kattavat Python-koodin.
Tiedostoissa ei ollut poikkeavaa lisenssiä tai erillistä tekijämerkintää.
Saman commitin `package.json` koskee npm-pakettia. Kohderepon olemassa
oleva `LICENSE` vastaa lähdeversion MIT-tekstiä tavutasolla ja säilyttää
tekijänoikeusmerkinnän.

Synteettinen testi käynnisti `deac_run.py`:n itse luodulla työkirjalla ja
paikallisilla testiasetuksilla. Se varmisti aiemman käynnin valinnan,
MOI-korjauksen ja kvintiilit, indeksituloksen, CSV-tiivisteen sekä
väärän lähdesnapshotin hylkäyksen. Kohderepon testit 19/19 ja
lähdecommitin synteettinen regressiosarja eristetyssä kopiossa 334/334.
Tuotantoajuria ei käynnistetty oikeilla syötteillä. Työkirja, SourceBindings
v3, kohorttivalitsin, korjausloki ja henkilötason tulokset jäävät
alkuperäisiin yksityisiin sijainteihinsa.

## E1:n historiallinen NB-malliajuri

`R/e1/aim1_e1_nb_assumption_runner.R` on tavukopio PRS:n tiedostosta
`Quantify-FOF-Utilization-Costs/scripts/aim1_e1_nb_assumption_runner.R`.
Ajurin SHA-256 on `56f86bcec8d197951a5410c9fb5f09484bf66eb20b8630c9e960af9245a510c2`.
Se vastaa ajon `aim1_e1_nb_assumption_v1` konfiguraatiossa ja raportissa
pinnattua koodiversiota. Lähde oli työpuutiedosto, joten version yksilöi
ajon tiiviste. Kohteessa vaihtui ainoastaan tiedostopolku.

Ajurissa ei ole poikkeavaa lisenssiä tai erillistä tekijämerkintää.
Lähderepon MIT-lisenssin mukainen tekijänoikeus- ja lisenssiteksti säilyy
kohderepon `LICENSE`-tiedostossa.

Ajuri hyväksyy ulkoisen, suojatun CSV:n ja kirjoittaa JSON-mallikoosteen.
Historiallinen ajuri tarkistaa sarakkeiden järjestyksen sekä 527 riviä
juoksevilla `row_id`-arvoilla ja käyttää mallissa vain `ELIGIBLE`-rivejä.
Sarakkeet järjestyksessä:

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,R_P,D_P,R_A,D_A
```

`aim1_mortality_assumption_adapter.py`:n `encoded_covariates` tarkistaa
sillassa olevan henkilötunnuksen ja palauttaa statuskoodin, iän ja luokan
`F` tai `M`. E1:n `aim1_e1_nb_assumption_adapter.py` kopioi kenttään
vain tämän luokan `ELIGIBLE`-rivillä. Muissa tiloissa kenttä jää tyhjäksi.
Tunnusta, syntymäaikaa tai tunnuksen osaa ei kirjoiteta kenttään.
Virheellinen tunnus tai ikä estää kelpoisuuden tilalla
`AGE_OR_HETU_UNRESOLVED`. Jos aiemmat portit läpäisevällä rivillä luokka
puuttuu tai on muu kuin `F` tai `M`, adapterin tila on `SEX_UNRESOLVED`.
R hylkää kelvolliseksi merkityn rivin puuttuvan tai virheellisen arvon
`INPUT_VALUE`-tarkistuksessa. R:n faktorin tasot ovat `F`, `M` ja
`Rscript --vanilla`-ajon oletuskontrasteilla vertailutaso on `F`.

Tarkistettu ympäristö: Rscript 4.5.3, MASS 7.3.65 ja jsonlite 2.0.0.
Aja synteettinen testi komennolla `Rscript --vanilla tests/test_aim1_e1_nb_runner.R`.
Testi ei hyväksy syöteargumentteja ja antaa ajurille vain itse luomansa
väliaikaiset CSV- ja JSON-polut. Neljä tapausta läpäisi. Onnistuva ajo
estimoi neljä mallia ja tuotti odotetun JSON-rakenteen. Puuttuva ja
virheellinen kelvollisen rivin luokka sekä liian lyhyt CSV hylättiin.
Oikea mallisyöte ja sen JSON-tulos säilyvät suojattuna repo-ulkopuolella.

## E2/E3 v2:n historiallinen NB-malliajuri

`R/e2e3/aim1_e2e3_nb_assumption_runner.R` on tavukopio PRS:n tiedostosta
`Quantify-FOF-Utilization-Costs/scripts/aim1_e2e3_nb_assumption_runner.R`.
Päivän 2.11.2026 ajoketjun `aim1_e2e3_nb_assumption_v2` konfiguraation
`nb_config_v2.json` kooditiiviste ja ajoa kuvaavan `report.json`-raportin
`provenance_sha256.code.runner` yksilöivät saman version:

```text
1a90cb0065e70edb301a05eb0e1a09c96a1d4c4e6bd7ea6ed894f20c6a528f42
```

Alkuperäinen ajuri oli PRS:n työpuutiedosto. Version yksilöi ajon
tiiviste. Kohteessa vaihtui ainoastaan tiedostopolku. Mallikaavat,
DEAC20:n 0,1 yksikön skaalaus, kelpoisuussuodatus, henkilövuosien
log-offset ja tuloslaskenta säilyvät tavutasolla. Ajurissa ei ole
erillistä tekijämerkintää tai poikkeavaa lisenssiä. Kohderepon
`LICENSE` säilyttää lähderepon MIT-tekstin ja tekijänoikeusmerkinnän.

Historiallinen `aim1_e2e3_nb_assumption_adapter_v2.py` tuotti ajurin
CSV-syötteen. Ajon adapterin SHA-256 on
`29b7ae417f9f047fb774a6032fb2701b6f217bd049147f7b52a89f01f2eb23b6`.
R-ajurin komentorivi ottaa CSV- ja JSON-polun. Ajuri edellyttää
527 juoksevaa `row_id`-arvoa `row1`–`row527` ja alla olevaa
sarakejärjestystä. Mallit käyttävät vain `ELIGIBLE`-rivejä, joilla
sukupuolikentässä on luokka `F` tai `M`. JSON sisältää neljän mallin
tuloskoosteet ja onnistuneiden mallien PDF-diagnostiikka kirjoitetaan
JSON-tiedoston hakemistoon.

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,E2_S0,E2_S1,E3_S0,E3_S1
```

Synteettinen rajapintatesti ajettiin komennolla
`Rscript --vanilla tests/test_aim1_e2e3_nb_runner.R`. Ympäristössä oli
R 4.5.3, MASS 7.3.65 ja jsonlite 2.0.0. Kuusi tapausta läpäisi:
neljän mallin estimointi ja JSON- sekä PDF-rakenne, neljä syötevirhettä
ja vakioselittäjän vuoksi estimoimaton tapaus. Testi muodostaa omat
rivinsä ja väliaikaiset polkunsa eikä hyväksy syöteargumentteja.
Historiallinen konfiguraatio, adapteri, mallisyöte ja tulokset
säilyvät alkuperäisissä suojatuissa sijainneissa.

## Kaksiosaisen kustannusmallin historiallinen v2-ajuri

`R/cost/aim1_cost_two_part_runner.R` on tavukopio PRS:n tiedostosta
`Quantify-FOF-Utilization-Costs/scripts/aim1_cost_two_part_runner.R`.
Käsikirjoituksen 6.11.2026 v2-ajon konfiguraation
`aim1_cost_two_part_config_v2.json` kenttä `runner_sha256` ja ajon
`review_private.json`-raportin kenttä `provenance_sha256.runner`
yksilöivät saman SHA-256-version:

```text
bc19281cc85533fe2390aeb086d8767522c248d612c48f7eee6220a786729b4f
```

Ajuri oli PRS:n työpuutiedosto. Version yksilöi ajon tiiviste.
Kohteessa muuttui tiedostopolku. Ajurissa ei ole erillistä
tekijämerkintää tai poikkeavaa lisenssiä. Kohderepon `LICENSE`
säilyttää lähderepon MIT-tekstin ja tekijänoikeusmerkinnän.

Historiallinen `aim1_cost_two_part_adapter.py` tuotti ulkoisen CSV:n.
Ajurin komentorivi ottaa CSV-polun, skenaarion (`R_P` tai `E2_S0`)
ja uuden JSON-polun. Ajuri tarkistaa 527 juoksevaa `row_id`-arvoa
`row1`–`row527` sekä seuraavan sarakejärjestyksen ja käyttää mallissa
vain `ELIGIBLE`-rivejä.

```text
row_id,status,deac20,age_index,sex,person_days,person_years,cost_eur_2023
```

Logit-osa estimoi positiivisen kustannuksen todennäköisyyden.
Gamma-osa log-linkillä estimoi positiivisen kumulatiivisen
2023 EUR -kustannuksen. Molemmat käyttävät DEAC20:n 0,1 yksikön
skaalausta ja estimoitua log(henkilövuodet)-kovariaattia.
Kummassakaan osassa ei käytetä offsetia. Ehdoton vakioitu ennuste
summaa todennäköisyyden ja ehdollisen kustannuksen tulot ja jakaa
summan kohdejoukon henkilövuosilla. Ajuri vertaa DEAC20-tasoja
0,4 ja 0,5. Komentorivi käyttää 1 000 henkilöbootstrap-otosta ja
siementä 20261106, ja vakioinnin kohdejoukko pysyy otoksissa kiinteänä.
Oikeat syötteet, hinnasto, adapteri, konfiguraatiot ja tulokset
säilyvät suojatussa lähdeketjussa.

Synteettisen rajapintatestin komento on
`Rscript --vanilla tests/test_aim1_cost_two_part_runner.R`.
Testi ei hyväksy syöteargumentteja. Se antaa ajurille vain itse luodun
CSV:n ja väliaikaisen JSON-polun. Testi käyttää komentorivin
historiallisia bootstrap-oletuksia keksityllä aineistolla.
Riippuvuudet tarkistettiin ympäristössä R 4.5.3 ja jsonlite 2.0.0.
Kahdeksan tapausta läpäisi. Testi vertasi kummankin malliosan
DEAC20-kertoimia ja yhdistettyjä ennusteita erilliseen laskentaan,
tarkisti JSON-rakenteen ja bootstrap-metatiedot sekä varmisti
seitsemän virheellisen tai sovitukseen riittämättömän syötteen hylkäyksen.
