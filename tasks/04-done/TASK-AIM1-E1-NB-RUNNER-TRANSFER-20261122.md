# AIM1:n E1-malliajurin paikallinen siirto

## Rajaus

Siirrä käsikirjoituksen neljän E1-mallin alkuperäinen R-ajuri
ajon kooditiivisteen mukaisena tavukopiona. Tarkista syötteen
sukupuolikenttä olemassa olevasta suojatun syötteen adapterikoodista.
Validoi ajuri pelkästään itse muodostetulla synteettisellä mallisyötteellä.

## Kirjoituspolut ja valmistumiskriteerit

- Lisää `R/e1/aim1_e1_nb_assumption_runner.R` ja
  `tests/test_aim1_e1_nb_runner.R`. Kirjaa provenienssi ja rajapinta
  `docs/PROVENANCE.md`:hen.
- Käytä kortin `01-ready` → `02-in-progress` → `03-review` -elinkaarta.
  Nimeä sama kortti PRS:n `PRJ-AIM1-REPO`-tietueessa. Toimitusraja on
  paikallinen commit.
- Varmenna ajurin lisenssi, tiiviste, riippuvuudet sekä synteettinen
  syöte- ja JSON-tulosrajapinta. Säilytä laskenta ja mallimääritykset.
- Oikea syöte, Python-adapteri ja todelliset mallituotokset pysyvät
  suojatussa lähdeketjussa. K51:n aiempi toimitus on tämän työn lähtöpohja.

## Loki

- 2026-11-22T11:47:27+02:00 Kortti luotu valtuutettuun paikalliseen siirtoon.
- 2026-11-22T11:47:27+02:00 Kortti siirretty `02-in-progress`-jonoon.
- 2026-11-22T11:48:08+02:00 Ajurin tiiviste, lisenssinäyttö, koodaus ja R-riippuvuudet
  varmennettu. Synteettisen komentorivitestin neljä tapausta läpäisivät,
  mukaan lukien neljä mallia ja kolme syötehylkäystä. Kortti siirrettiin
  `03-review`-jonoon paikallista katselmointia varten.

## Tila

Paikallinen siirto hyväksytty ja valmis (`04-done`). Suojattu toistoajo
käsitellään erikseen. Katso
[ajon rajaus ja testinäyttö](../../docs/RUNNING.md) ja
[koodin provenienssi](../../docs/PROVENANCE.md).
