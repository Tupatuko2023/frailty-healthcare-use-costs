# AIM1:n kaksiosaisen kustannusajurin paikallinen siirto

## Rajaus

Siirrä 6.11.2026 v2-ajossa käytetty R-ajuri tavukopiona K51-, E1-
ja E2/E3-toimitusten päälle. Säilytä mallit, ennusteet ja bootstrap.

## Kirjoituspolut ja valmistumiskriteerit

- Lisää `R/cost/aim1_cost_two_part_runner.R` ja
  `tests/test_aim1_cost_two_part_runner.R`. Kirjaa provenienssi
  `docs/PROVENANCE.md`:hen ja päivitä PRS:n `PRJ-AIM1-REPO`-tietue.
- Varmenna versio, lisenssi ja riippuvuudet. Testaa molemmat malliosat,
  yhdistetty ennuste, tulosrakenne ja syötevirheet synteettisesti.
- Katselmoi diffi ja palautustestaa toimituscommitit. Hinnasto, adapteri,
  konfiguraatiot, oikeat syötteet ja tulokset jäävät suojattuun
  lähdeketjuun.

## Loki

- 2026-11-22T14:52:32+02:00 Kortti luotu valtuutettuun paikalliseen siirtoon.
- 2026-11-22T14:52:32+02:00 Kortti siirretty `02-in-progress`-jonoon.
- 2026-11-22T14:54:02+02:00 Ajoversio, MIT-lisenssi ja riippuvuudet varmennettu.
  Synteettinen rajapintatesti läpäisi kahdeksan tapausta. Kortti
  siirrettiin `03-review`-jonoon paikallista katselmointia varten.

## Tila

Paikallinen siirto hyväksytty ja valmis (`04-done`). Suojattu toistoajo
käsitellään erikseen. Katso
[ajon rajaus ja testinäyttö](../../docs/RUNNING.md) ja
[koodin provenienssi](../../docs/PROVENANCE.md).
