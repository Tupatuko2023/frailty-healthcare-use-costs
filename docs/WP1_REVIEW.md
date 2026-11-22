# WP1-katselmointi 19.11.2026

## Rajaus ja tilat

| Osa | Tila | Näyttö ja raja |
| --- | --- | --- |
| Paikallinen reporunko | VALMIS KATSELMOINTIIN | Erillinen Git-repo on alustettu ilman remotea; README, testaus- ja provenienssiohjeet sekä `.gitignore` ovat mukana. Paikallinen commit on tehty; main-toimitusta ei ole. |
| Rajattu siirto | PASS | `DEAC-Frailty-Index/src/deac_index.py` ja `tests/test_deac_index.py` vastaavat lähteitään tavutasolla; SHA-256 ja Git-provenienssi ovat `PROVENANCE.md`:ssä. |
| Alkuperäinen synteettinen testi | PASS | 17 kerättyä, 17 läpäissyttä, 0 epäonnistunutta, 0 ohitettua; paluukoodi 0. |
| Pisteytyksen tieteellinen vahvistus | NEEDS_VERIFICATION | Omistavan `METHODS_AND_SCORING.md` §3.1:n soveltuvaa nykyversiota ja hyväksyntäviitteitä ei ole verrattu tähän toteutukseen. |
| Julkaisuoikeuden selvitys WP1:n katselmointihetkellä | AVOIN | Julkaisuhetken MIT-lisenssi ja tekijänoikeusmerkintä on kuvattu [provenienssissa](PROVENANCE.md). |

## Testiajo

Koodi ja testi luettiin ennen ajoa. Ne eivät lue osallistuja-aineistoa, tuotantopolkuja, yksityisiä asetuksia tai verkkolähteitä. Kohderepossa ei ollut `conftest.py`-tiedostoa. Käytettiin paikallista ignoroitua `.venv`-ympäristöä; pytest ja sen neljä riippuvuutta asennettiin olemassa olevasta paikallisesta välimuistista ilman verkkoa tai globaalin Pythonin muutoksia.

- Tulkki: `.venv/bin/python` (Python 3.14.6).
- Pakettilähde: paikallinen uv-välimuisti, offline-tila.
- Toteutuneet paketit: pytest 9.1.1, iniconfig 2.3.0, packaging 26.3, pluggy 1.6.0 ja pygments 2.21.0.
- Komento kohderepon juuresta: `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q tests/test_deac_index.py`.
- Tulos: `17 passed in 0.02s`; paluukoodi 0.

Tämä tulos on alkuperäisen testitiedoston uusi ajo tässä WP1:ssä. Aiemmin raportoidut kuusi pariteettitapausta eivät ole tämän ajon tulos. PASS osoittaa testitiedoston määrittämän synteettisen käyttäytymisen tässä toteutuksessa; se ei vahvista lähdemuuttujien pisteytystä, tutkimuspäätöksiä eikä suojatun ajon tulospariteettia.

## Toimitusraja

Kaikki toimitettavat tiedostot tarkastetaan ennen katselmointia. Tämä paikallinen repo ei sisällä osallistujadataa, todellisia aggregaatteja, suojattuja ajotuloksia, tunnuksia tai yksityisiä absoluuttisia polkuja. `.venv` on Gitissä ignoroitu paikallinen testiympäristö eikä kuulu toimitukseen.

WP1:n katselmointihetkellä paikallinen toteutus ja synteettinen testaus olivat katselmoitavissa. `origin/main`-toimitusta, kohderepon etärepoa, julkaisua, mergeä tai työpuun siivousta ei ole tehty. Koko AIM1-analyysiputki on tämän WP1:n ulkopuolella.
