# AIM1:n E2/E3 v2 -malliajurin paikallinen siirto

## Rajaus

Siirrä jäljitetyn E2/E3 v2 -ajon alkuperäinen R-ajuri tavukopiona
K51- ja E1-toimitusten päälle. Säilytä mallimääritykset ja laskenta.

## Kirjoituspolut ja valmistumiskriteerit

- Lisää `R/e2e3/aim1_e2e3_nb_assumption_runner.R` ja
  `tests/test_aim1_e2e3_nb_runner.R`. Kirjaa provenienssi ja rajapinta
  `docs/PROVENANCE.md`:hen ja linkitä kortti PRS:n `PRJ-AIM1-REPO`-tietueesta.
- Varmenna versio, lisenssi ja riippuvuudet. Testaa neljä mallia,
  JSON- ja PDF-tulosteet sekä olennaiset virhetilanteet keksityillä riveillä.
- Katselmoi rajattu diffi ja palautustestaa paikalliset toimituscommitit.
  Oikeat konfiguraatiot, adapteri, henkilötason syötteet ja ajotulokset
  säilyvät suojattuina alkuperäisessä lähdeketjussa.

## Loki

- 2026-11-22T13:25:03+02:00 Kortti luotu valtuutettuun paikalliseen siirtoon.
- 2026-11-22T13:25:03+02:00 Kortti siirretty `02-in-progress`-jonoon.
- 2026-11-22T13:26:13+02:00 Historiallinen ajuriversio, lisenssi ja riippuvuudet varmennettu.
  Synteettinen rajapintatesti läpäisi kuusi tapausta. Kortti siirrettiin
  `03-review`-jonoon paikallista katselmointia varten.

## Tila

Paikallinen siirto hyväksytty ja valmis (`04-done`). Suojattu toistoajo
käsitellään erikseen. Katso
[ajon rajaus ja testinäyttö](../../docs/RUNNING.md) ja
[koodin provenienssi](../../docs/PROVENANCE.md).
