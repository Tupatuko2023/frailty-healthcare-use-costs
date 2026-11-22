# AIM1:n jäädytetyn K51-pisteytyskoodin paikallinen siirto

## Tavoite ja rajaus

Säilytä ajon `20261005T105241Z` kuuden Python-tiedoston koodikokonaisuus
AIM1-kohderepossa. Lähde on manifestin sitoma PRS-commit
`c15ed24d1b901f83a70a1546858786160b49905c`. Käytä WP1:n indeksikokoajaa
ja alkuperäistä testiä. Tarkista tiedostokohtaiset oikeusmerkinnät.

## Kirjoituspolut ja valmistumiskriteerit

- Lisää `DEAC-Frailty-Index/src/`-hakemistoon vain `deac_run.py`,
  `deac_cohort_runner.py`, `deac_source_adapter.py`, `deac_components.py`
  ja `deac_moi.py` manifestissa varmennetuista versioista.
- Lisää `tests/test_deac_k51_chain_synthetic.py` ja kirjaa koodiversiot,
  lisenssinäyttö, polut, importit ja validointi `docs/PROVENANCE.md`:hen.
- Käytä tämän kortin normaalia `01-ready` → `02-in-progress` → `03-review`
  -elinkaarta. Kohdista PRS:n `PRJ-AIM1-REPO` tähän kohderepon korttiin.
- Varmenna kuuden kooditiedoston tiivisteet ja aja alkuperäinen testi sekä
  synteettinen komentoriviketju. Toimitusraja on paikallinen commit.
- Työkirja, SourceBindings v3, kohorttivalitsin, MOI-korjausloki ja
  henkilötason tulokset säilyvät alkuperäisissä yksityisissä sijainneissaan.
  K40:n sidonnat, malliajurit, pisteytyssäännöt ja WP1:n sulku ovat rajauksen ulkopuolella.

## Loki

- 2026-11-22T07:02:10+02:00 Kortti luotu valtuutettuun paikalliseen siirtoon.
- 2026-11-22T07:02:10+02:00 Kortti siirretty `02-in-progress`-jonoon.
- 2026-11-22T07:03:51+02:00 Manifestin kuusi kooditiivistettä sekä tiedostokohtainen
  MIT-lisenssinäyttö varmennettu. Viisi tavukopiota, alkuperäinen kokoaja ja
  oikeusmerkintä tarkistettu. Synteettinen komentoriviketju ja WP1-testi
  19/19 PASS. Historiallinen synteettinen regressiosarja 334/334 PASS.
  Kortti siirretty `03-review`-jonoon paikallista katselmointia varten.

## Tila

Paikallinen siirto hyväksytty ja valmis (`04-done`). Suojattu toistoajo
käsitellään erikseen. Katso
[ajon rajaus ja testinäyttö](../../docs/RUNNING.md) ja
[koodin provenienssi](../../docs/PROVENANCE.md).
