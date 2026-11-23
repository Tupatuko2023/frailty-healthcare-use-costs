# Running the AIM1 code

## Scope and run history

The historical scoring run `20261005T105241Z` used Python-R-Scripts (PRS)
revision `c15ed24d1b901f83a70a1546858786160b49905c`, SourceBindings v3 and
the K51/AUTH_SOURCE snapshot. The E1 run report
(`aim1_e1_nb_assumption_v1`) and the configuration chain for the
2 November 2026 E2/E3 v2 run link DEAC20 to the same K51 output CSV.
The 6 November 2026 v2 cost run used the E2/E3 configuration chain.
The [provenance record](PROVENANCE.md) identifies the historical runner
versions by checksum.

The repository includes synthetic tests of the runners and their interfaces.
No protected reproduction run has been performed from this repository.
The command forms below document the protected interfaces. To exercise the
code without research inputs, use the [synthetic tests](TESTING.md).
A protected run requires authorisation, version-matched protected inputs
and a compatible environment.

## K51 scoring

The runner uses the Python standard library and five local `deac_*.py`
modules. Use Python 3.10 or later (`zip(strict=True)`) in a Git checkout.
Writing the CSV requires a Linux or Termux environment with libc and
filesystem support for `renameat2` with `RENAME_NOREPLACE`.

```sh
python DEAC-Frailty-Index/src/deac_run.py \
  --env "$PRIVATE_ENV" --bindings "$PRIVATE_BINDINGS" \
  --selector "$PRIVATE_SELECTOR" --correction "$PRIVATE_MOI_CORRECTION" \
  --output-parent "$PRIVATE_OUTPUT_PARENT"
```

The command takes a protected environment file, SourceBindings v3 for
the K51/AUTH_SOURCE XLSX workbook, the cohort selector and the MOI correction
record. The environment file identifies the workbook and provides the identifier
setting required by the selector. The runner verifies the environment file
version and checks that exactly one workbook matches the approved SHA-256.
The output parent must be an existing protected directory outside the repository.

The runner creates a timestamped directory with
`deac_v2_participant_results_<run_id>.csv` and
`deac_v2_run_manifest_<run_id>.json`. The CSV contains a participant key,
20 component values, `deac_index`, counts of observed and relevant
components, coverage and eligibility. The historical manifest records
checksums for the snapshot, bindings, selector, environment file, correction
record, code and CSV. Both outputs require protected storage. External
adapters link the scores with other protected study inputs before model fitting.

## Model runners

The negative binomial runners require Rscript, MASS and jsonlite. The cost
runner requires Rscript and jsonlite. Recorded local synthetic checks used
R 4.5.3, MASS 7.3-65 and jsonlite 2.0.0. Each model input CSV has exactly
527 rows, ordered `row_id` values from `row1` to `row527` and the column
order shown below. The runners fit models on `ELIGIBLE` rows. The sex field
contains `F` or `M` on those rows. Use new, protected output paths outside
the repository.

### E1

```sh
Rscript --vanilla R/e1/aim1_e1_nb_assumption_runner.R "$E1_CSV" "$E1_JSON"
```

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,R_P,D_P,R_A,D_A
```

The JSON schema `aim1-e1-nb-model-results-v1` records model status, estimates
and diagnostics for four negative binomial models. The field
`sex_encoded_in_bridge_hetu` contains the derived sex category.

### E2/E3 v2

```sh
Rscript --vanilla R/e2e3/aim1_e2e3_nb_assumption_runner.R "$E2E3_CSV" "$E2E3_JSON"
```

```text
row_id,status,deac20,age_index,sex_encoded_in_bridge_hetu,person_days,person_years,E2_S0,E2_S1,E3_S0,E3_S1
```

The JSON schema `aim1-e2e3-nb-model-results-v1` records model status,
estimates and diagnostics for four negative binomial models. The runner
writes diagnostic PDFs for fitted models alongside the JSON. Use a separate
protected output directory for each run.

### Cost model v2

```sh
Rscript --vanilla R/cost/aim1_cost_two_part_runner.R "$COST_CSV" "$COST_SCENARIO" "$COST_JSON"
```

```text
row_id,status,deac20,age_index,sex,person_days,person_years,cost_eur_2023
```

Select the scenario corresponding to the input: `R_P` or `E2_S0`. The JSON
schema `aim1-cost-two-part-v1` contains the logit and gamma model formulas
and DEAC20 coefficients, combined EUR-per-person-year predictions,
confidence intervals, bootstrap information and diagnostics. Both model
parts estimate a coefficient for the log of person-years. The command-line
defaults are 1,000 participant bootstrap samples and seed `20261106`.

## External input preparation

The historical PRS adapters prepare the research inputs. They remain external
to this repository and expect the historical PRS directory structure,
including the R runner alongside each adapter. The R runners here can be
called directly after the protected CSV has been prepared. The public
repository does not include an end-to-end entry point from raw data to models.

| Stage | Protected configuration reference | Inputs upstream of the R runner |
| --- | --- | --- |
| E1 | `aim1_e1_nb_assumption_v1/run_config.json`, SHA-256 `f44fe7dd60d5dc80a7c5864a40a30b9df899ef5ed17cb5477135286ceda42be6` | Earlier four-scenario report, E1 profile configuration and service CSV; mortality workflow configuration, follow-up, person linkage and K51 output CSV |
| E2/E3 v2 | `aim1_e2e3_nb_assumption_v2/nb_config_v2.json`, SHA-256 `5b23a222fb7d340309a93293e140a815a742ce526ac112a85b9b3f3b90ded1c7` | v2 participant table configuration and report, linked S0/S1 and assembly records, candidate SQLite database and, through the mortality workflow, follow-up, person linkage and K51 output CSV |
| Cost v2 | `aim1_cost_two_part_config_v2.json`, SHA-256 `86923b9fcf3cbf42157c7a9f7b8c111045dcb66a9157b8faa2dd09f970dfa4cd` | v1 valuation report, v1 model preflight report and the E2/E3 v2 configuration above. The 2023 price list used in the valuation workflow remains protected. |

Protected configurations and run manifests identify private artefacts by
checksum. The table below identifies the input preparation code versions.
Paths are relative to `Quantify-FOF-Utilization-Costs/scripts/` in PRS
unless they begin with `DEAC-Frailty-Index/`.

| Input preparation code | SHA-256 matching the historical configuration and run report |
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

The cost adapter imports the E1 and E2/E3 adapters and
`aim1_cost_model_response_core.py`. The inspected version of the latter
has SHA-256
`9fd8f2289bfa7267b63eecb312e279319fa24731a3bd1ae02af7e7aac5edc002`,
which matches the AIM1 source manifest. The v2 cost run report identifies
the adapter and R runner. The cost response module has no separate version
record in that report.

The follow-up and quality-control imports below were identified in the PRS
source tree. The checksums identify the local versions inspected. The
available run manifests do not establish byte-for-byte equivalence to the
versions used in the historical runs.

| Import in the PRS source tree | SHA-256 of the inspected file |
| --- | --- |
| `DEAC-Frailty-Index/src/aim1_index_cohort_qc.py` | `0bb409f6d38778b1acdf771c9f195be97bb247a1df321341722d279019990c95` |
| `DEAC-Frailty-Index/src/aim1_person_link_qc.py` | `8e24ba20287ee39dc3a2cddd06b7ca6356a67e3263c8472379b52dfdac89691c` |
| `DEAC-Frailty-Index/src/aim1_identity_service_followup_qc.py` | `8a233bca131312fc38abeb322c3942913f435593cdc1e17fbe02f111a9fbacd8` |
| `aim1_linkage_probe.py` | `4720b863b3e63cfcdaf59a91f216814b0165ab543623e45d704c8fa3f1b5e62f` |
| `aim1_mortality_identity_synthetic.py` | `f69bb9e253c7d1738943261a889cda0e86618414ce00c4a6c09977a4ccbd8932` |
| `aim1_person_bridge_probe.py` | `88fd55e2cff07ae749ba016971c368034829809d04a1145fcc740c069914fa9c` |

The external E2/E3 workflow uses Python's `sqlite3` module. Preparation
of the participant table and valuation report from raw sources precedes
the stages described here. Use the historical configuration to identify
each protected input artefact. Assessment of the scientific suitability of
the price list and other source materials belongs to the study documentation.
