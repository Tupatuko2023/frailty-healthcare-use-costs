# AIM1:n siirretyn koodin ajo-ohje

## Ajon ja testinäytön rajaus

Historiallinen pisteytysajo `20261005T105241Z` käytti PRS:n versiota
`c15ed24d1b901f83a70a1546858786160b49905c`, SourceBindings v3:a ja
K51/AUTH_SOURCE-snapshotia. E1:n `aim1_e1_nb_assumption_v1`-ajon
raportti ja E2/E3:n 2.11.2026 v2-ajon konfiguraatioketju sitovat
DEAC20:n saman K51-ajon CSV:hen. Kustannusten 6.11.2026 v2-ajo
käyttää E2/E3:n konfiguraatioketjua. Historiallisten ajurien
tiedostotiivisteet ovat [provenienssissa](PROVENANCE.md).

Kohderepon synteettinen näyttö koskee ajureita ja niiden rajapintoja.
Suojattu toistoajo kohdereposta on tekemättä. Alla olevat suojatun
ajon komentomuodot kuvaavat rajapintaa. Suojattuun toistoon tarvitaan
erillinen ajovaltuutus, versionmukaiset yksityiset syötteet ja ympäristö.

## K51-pisteytys

Ajuri käyttää Pythonin vakiokirjastoa ja viittä paikallista
`deac_*.py`-moduulia. Käytä Python 3.10:tä tai uudempaa
(`zip(strict=True)`) ja Git-työpuuta. CSV-kirjoitus tarvitsee
Linux/Termux-ympäristön, jonka libc ja tiedostojärjestelmä tukevat
`renameat2`-kutsua ja `RENAME_NOREPLACE`-toimintoa.

```sh
python DEAC-Frailty-Index/src/deac_run.py \
  --env "$PRIVATE_ENV" --bindings "$PRIVATE_BINDINGS" \
  --selector "$PRIVATE_SELECTOR" --correction "$PRIVATE_MOI_CORRECTION" \
  --output-parent "$PRIVATE_OUTPUT_PARENT"
```

Syötä suojattu env-tiedosto, K51/AUTH_SOURCE-XLSX:n SourceBindings v3,
kohorttivalitsin ja MOI-korjausloki. Env-tiedosto osoittaa työkirjaan
ja sisältää valitsimen edellyttämän tunnisteasetuksen. Ajuri tarkistaa
env-version sekä yhden hyväksyttyä SHA-256:ta vastaavan työkirjan.
Valitse olemassa oleva suojattu tulosylähakemisto repo-ulkopuolelta.

Ajuri luo aikaleimatun hakemiston ja kirjoittaa sinne
`deac_v2_participant_results_<run_id>.csv`-tiedoston sekä
`deac_v2_run_manifest_<run_id>.json`-manifestin. CSV sisältää
osallistuja-avaimen, 20 komponenttia, `deac_index`-arvon, havaitun ja
soveltuvan komponenttimäärän, kattavuuden ja kelpoisuuden. Historiallinen
manifesti yksilöi snapshotin, sidonnat, valitsimen, env-version,
korjauslokin, koodin ja CSV:n tiivisteillä. CSV ja manifesti kuuluvat
suojattuun säilytykseen. Mallien adapterit yhdistävät pisteet
tutkimuksen muihin suojattuihin lähteisiin ennen R-ajoa.

## Malliajurit

NB-ajurit tarvitsevat Rscriptin, MASSin ja jsonliten. Kustannusajuri
tarvitsee Rscriptin ja jsonliten. Paikallisissa synteettisissä
tarkistuksissa käytettiin R 4.5.3:a, MASS 7.3-65:tä ja jsonlite 2.0.0:aa.
Kukin CSV sisältää täsmälleen 527 riviä, `row_id`-arvot
`row1`–`row527` järjestyksessä ja kyseisen ajurin sarakkeet alla
olevassa järjestyksessä. Mallit käyttävät `ELIGIBLE`-rivejä.
Sukupuolikentän arvot ovat `F` ja `M`. Käytä suojattuja, uusia
tulospolkuja repo-ulkopuolella.

### E1

```sh
Rscript --vanilla R/e1/aim1_e1_nb_assumption_runner.R "$E1_CSV" "$E1_JSON"
```

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,R_P,D_P,R_A,D_A
```

JSON-skeema `aim1-e1-nb-model-results-v1` sisältää neljän
NB-mallin tilat, tuloskoosteet ja diagnostiikan. Historiallisesta
nimestä huolimatta sukupuolikenttä sisältää luokan.

### E2/E3 v2

```sh
Rscript --vanilla R/e2e3/aim1_e2e3_nb_assumption_runner.R "$E2E3_CSV" "$E2E3_JSON"
```

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,E2_S0,E2_S1,E3_S0,E3_S1
```

JSON-skeema `aim1-e2e3-nb-model-results-v1` sisältää neljän
NB-mallin tilat, tuloskoosteet ja diagnostiikan. Ajuri kirjoittaa
estimoitujen mallien diagnostiikan PDF-tiedostot samaan hakemistoon
JSON:n kanssa. Käytä erillistä suojattua tuloshakemistoa kullekin ajolle.

### Kustannusmalli v2

```sh
Rscript --vanilla R/cost/aim1_cost_two_part_runner.R "$COST_CSV" "$COST_SCENARIO" "$COST_JSON"
```

```text
row_id,status,deac20,age_index,sex,person_days,person_years,cost_eur_2023
```

Valitse syötettä vastaava skenaario `R_P` tai `E2_S0`. JSON-skeema
`aim1-cost-two-part-v1` sisältää logit- ja Gamma-osien kaavat ja
DEAC20-kertoimet, yhdistetyt EUR/henkilövuosi-ennusteet, luottamusvälit,
bootstrap-tiedot ja diagnostiikan. Molemmat malliosat estimoivat
log(henkilövuodet)-kovariaatin. Komentorivin oletus on 1 000
henkilöbootstrap-otosta, siemen `20261106`.

## Ulkoinen valmisteluketju

Kohderepon ajurit ovat käytettävissä kuvatuilla rajapinnoilla.
Tutkimussyötteiden muodostus tapahtuu PRS:n valmisteluketjussa.
Adapterit ovat olemassa, mutta niitä ei ole paketoitu tähän repoon.
Versiolukitut adapterit odottavat historiallista PRS-hakemistorakennetta,
mukaan lukien R-ajurin sijainti adapterin rinnalla. Siirretyt R-ajurit
voidaan kutsua suoraan, kun suojattu CSV on muodostettu. Kohderepon
itsenäistä raakalähteestä malliin ulottuvaa käynnistintä ei ole toimitettu.

| Vaihe | Suojatun valmistelun juuriviite | Syötteet ennen R-ajuria |
| --- | --- | --- |
| E1 | `aim1_e1_nb_assumption_v1/run_config.json` · SHA-256 `f44fe7dd60d5dc80a7c5864a40a30b9df899ef5ed17cb5477135286ceda42be6` | Aiemman neljän skenaarion raportti, E1-profiilikonfiguraatio ja palvelu-CSV sekä kuolleisuusketjun konfiguraatio, seuranta, henkilösilta ja K51-CSV |
| E2/E3 v2 | `aim1_e2e3_nb_assumption_v2/nb_config_v2.json` · SHA-256 `5b23a222fb7d340309a93293e140a815a742ce526ac112a85b9b3f3b90ded1c7` | Henkilötaulukon v2-konfiguraatio ja raportti, niihin sidottu S0/S1- ja koosteketju, SQLite-kandidaattikanta sekä kuolleisuusketjun kautta seuranta, henkilösilta ja K51-CSV |
| Kustannus v2 | `aim1_cost_two_part_config_v2.json` · SHA-256 `86923b9fcf3cbf42157c7a9f7b8c111045dcb66a9157b8faa2dd09f970dfa4cd` | Arvotusraportti v1, mallin ennakkotarkistusraportti v1 ja yllä yksilöity E2/E3 v2 -konfiguraatio. Arvotusketjun vuoden 2023 hinnasto pysyy suojattuna. |

Konfiguraatiot ja suojatut ajomanifestit yksilöivät ketjun yksityiset
artefaktit ja niiden tiivisteet. Taulukossa on valmistelun koodiversiot.
Python-tiedostot ovat PRS:n `Quantify-FOF-Utilization-Costs/scripts/`-
hakemistossa, paitsi DEAC-polulla merkitty tiedosto.

| Valmistelukoodi | Historialliseen konfiguraatioon ja ajon raporttiin täsmäävä SHA-256 |
| --- | --- |
| `aim1_e1_nb_assumption_adapter.py` | `7a794be62130c084443384819bda1cc80b95fd3259b211b1607ae68242a3a17d` |
| `aim1_e1_csv_xlsx_compare.py` | `3b924cc7c5047b7997a90f5ec9c062edc2a857e0db0bb97d679cdd13bebb582f` |
| `aim1_e1_four_scenario_check.py` | `3db32b50324235c676a1eae8a69f7b9a11b2af51ecd1340d5ce257b52f7304cc` |
| `aim1_e1_row_structure_profile.py` | `2f106394c5c42bc0ca716dccedbd96fcc53b88599e8e40d6cf903140de47ef07` |
| `aim1_mortality_assumption_adapter.py` | `ae3356276fa3dc2b7c036ec695ea21fb8cca4446c07a411378d4125d07454fd6` |
| `aim1_mortality_structure_qc.py` | `fe44a489722f3fcd191b148e9261e39d3e47057742b7ec8b5aa1dd5b516d245a` |
| `DEAC-Frailty-Index/src/aim1_person_followup.py` | `ef72bf38ad30fee4c2c9197fb59c505a6ba4cffd52eb37cd67d3b57f5770e571` |
| `aim1_e2e3_nb_assumption_adapter_v2.py` | `29b7ae417f9f047fb774a6032fb2701b6f217bd049147f7b52a89f01f2eb23b6` |
| `aim1_e2e3_assumption_check.py` | `4500521686e4e217bd71dd9d787d7e427eecbf1ef552b43f8d40d9d7178fcc44` |
| `aim1_e2e3_key_exception_trace.py` | `6a78d8c424c46b5c79fdcc25c258d935ea1a0690785033637057cb336939282b` |
| `aim1_e2e3_person_table_observed.py` | `7dc4975269132a071b88f81d31016bf37b2be0c18cf4641109d78c2f54585418` |
| `aim1_cost_two_part_adapter.py` | `737ccee2fa0cea139dc88aa89ee017c951054c884c7587d63cd426828802f703` |

Kustannusadapteri tuo E1- ja E2/E3-adapterit sekä
`aim1_cost_model_response_core.py`:n, jonka nykyinen SHA-256
`9fd8f2289bfa7267b63eecb312e279319fa24731a3bd1ae02af7e7aac5edc002`
vastaa AIM1-lähdemanifestia. Kustannusajon v2-raportti yksilöi
adapterin ja R-ajurin. Se ei yksilöi kustannusydintä erikseen.

Seuraavat seuranta- ja QC-tuonnit löytyivät nykyisestä PRS-lähdetyöpuusta.
Tiivisteet yksilöivät tarkistetut paikalliset tiedostot. Niiden
historiallista tavuvastaavuutta ei ole varmennettu näistä ajomanifesteista.

| Tuonti PRS-lähdepuussa | Nykyinen SHA-256 |
| --- | --- |
| `DEAC-Frailty-Index/src/aim1_index_cohort_qc.py` | `0bb409f6d38778b1acdf771c9f195be97bb247a1df321341722d279019990c95` |
| `DEAC-Frailty-Index/src/aim1_person_link_qc.py` | `8e24ba20287ee39dc3a2cddd06b7ca6356a67e3263c8472379b52dfdac89691c` |
| `DEAC-Frailty-Index/src/aim1_identity_service_followup_qc.py` | `8a233bca131312fc38abeb322c3942913f435593cdc1e17fbe02f111a9fbacd8` |
| `aim1_linkage_probe.py` | `4720b863b3e63cfcdaf59a91f216814b0165ab543623e45d704c8fa3f1b5e62f` |
| `aim1_mortality_identity_synthetic.py` | `f69bb9e253c7d1738943261a889cda0e86618414ce00c4a6c09977a4ccbd8932` |
| `aim1_person_bridge_probe.py` | `88fd55e2cff07ae749ba016971c368034829809d04a1145fcc740c069914fa9c` |

PRS:n valmisteluketjussa E2/E3 käyttää Pythonin `sqlite3`-moduulia.
Henkilötaulukon ja arvotusraportin muodostaminen raakalähteistä on
ennen yllä kuvattuja mallisyötteen valmisteluvaiheita. Käytä
historiallista konfiguraatiota kunkin suojatun lähtöartefaktin
tunnistamiseen. Hinnaston ja muiden lähdetietojen tieteellinen
soveltuvuus arvioidaan tutkimusdokumentaatiossa.

## Synteettinen käyttö

Aja komennot kohderepon juuresta. Pythonille käytä eristettyä ympäristöä,
jossa on `pytest`. Testit luovat omat keinotekoiset syötteensä.

```sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q \
  tests/test_deac_index.py tests/test_deac_k51_chain_synthetic.py
Rscript --vanilla tests/test_aim1_e1_nb_runner.R
Rscript --vanilla tests/test_aim1_e2e3_nb_runner.R
Rscript --vanilla tests/test_aim1_cost_two_part_runner.R
```

| Aiempi testinäyttö | Testattu AIM1-revisio | Tulos |
| --- | --- | --- |
| WP1-kokoaja ja synteettinen K51-komentoriviketju | `a3d1705fae3efe9c00fe75525a2206b5f0ec306e` | 19/19 |
| E1-rajapinta | `f90293bf56a05df125d1d5a7b71ffcd8d2913eca` | 4/4 |
| E2/E3 v2 -rajapinta | `c5c2779bb1c450f5f5a94b5bf4349c5c49da2332` | 6/6 |
| Kustannusmallin v2-rajapinta | `7cdfa349f2d07391b8861273c68742c1aaafce31` | 8/8 |

K51:n kuuden moduulin historiallisessa lähdeversiossa ajetun
erillisen synteettisen regressiosarjan tulos oli 334/334.
