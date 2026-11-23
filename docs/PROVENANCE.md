# Code provenance

The Finnish release documentation and original closed task records are
retained at publication revision `1a4432e989a6835b35e4d0173fa61649dcfe4ee3`.
The sections below describe the checked code transfers and the evidence for
their source versions. See the [testing guide](TESTING.md) for the recorded
synthetic results and the [running guide](RUNNING.md) for protected inputs,
external adapters and known reproduction limits.

## WP1 index assembler and original test

The source repository was `Tupatuko2023/Python-R-Scripts`. The check on
19 November 2026 used source checkout HEAD
`919b5cc94f80452806f0b30a351577bb9ba0bdde`. Both source files were tracked
and unchanged in the working tree. Their last path-specific commit was
`5ae1c8ec830715d0b5976314273fa2b91fea9b7a`. The checkout HEAD identifies
the inspection context. The SHA-256 values identify the file contents.

| Source and target path | Verified SHA-256 | Comparison |
| --- | --- | --- |
| `DEAC-Frailty-Index/src/deac_index.py` | `c3fe94b631d488a5c5923ce4f31edca866b435464b8e6ce986b5e07c568593d7` | Byte-for-byte match |
| `tests/test_deac_index.py` | `396b798f73aced664deb0479a495bc2d9e8febb825bfc9dc5177b71e9ead1713` | Byte-for-byte match |

These values match the AIM1 source manifest. The transfer preserved the
implementation, test, imports and packaging.

## Licence and attribution

The source repository's root `LICENSE` is MIT and carries the notice
`Copyright (c) 2025 Tomi Korpi`. Its README and section 11 of
`.github/CONTRIBUTING.md` identify MIT as the project licence. The
[licence text in this repository](../LICENSE) is a byte-for-byte copy
(SHA-256 `9376874055d4aee919c382209a5906af10b52cc0e17590bf28af5ee70752c169`).
The file-level review identified no separate licence or attribution headers
in the transferred Python and R files. The ISC declaration in the source
repository's `package.json` applies to its `python-r-scripts` npm package.
The owner authorised publication of the code documented here.

## Historical K51/AUTH_SOURCE scoring code

The protected run `20261005T105241Z` used
`Tupatuko2023/Python-R-Scripts` revision
`c15ed24d1b901f83a70a1546858786160b49905c`. The file checksums in the
run manifest matched the historical source blobs and the files here.

| File under `DEAC-Frailty-Index/src/` | SHA-256 matching the run manifest |
| --- | --- |
| `deac_run.py` | `b05a9140532bc4ae734c88dda0447bc205af644014ec4dd2948a19e86fb95328` |
| `deac_cohort_runner.py` | `dac703be13d35726b34f4083646165db041af2080a7ad2ffab46d39279891554` |
| `deac_source_adapter.py` | `cd072b427ca4b93000c19d77419e8a250af82c2130a884d093d70a88051a627f` |
| `deac_components.py` | `c66b711788f29c73b73317b0d6d55cdd949e6a8db7bbb5a2945575bab67410e5` |
| `deac_moi.py` | `f404f054f299a05c30219e82cd0787a6eaaafadf0a0517b9b75750362faed3b6` |
| `deac_index.py` | `c3fe94b631d488a5c5923ce4f31edca866b435464b8e6ce986b5e07c568593d7` |

The transfer copied five modules byte for byte and reused WP1's
`deac_index.py` and `tests/test_deac_index.py`. The directory structure
preserves the original imports and the runner's repository-root detection.
The historical workbook, SourceBindings v3, cohort selector, correction log
and participant-level results remain protected outside this repository.

The synthetic command-line workflow checked earlier visit selection, the MOI
correction and quintiles, index output, CSV checksum and rejection of a
mismatched source snapshot. The repository tests returned 19/19 and the
separate historical synthetic suite returned 334/334. The protected research
inputs were outside the scope of those checks.

## Historical E1 negative binomial runner

`R/e1/aim1_e1_nb_assumption_runner.R` is a byte-for-byte copy of
`Quantify-FOF-Utilization-Costs/scripts/aim1_e1_nb_assumption_runner.R` in
PRS. Its SHA-256 is
`56f86bcec8d197951a5410c9fb5f09484bf66eb20b8630c9e960af9245a510c2`,
matching the configuration and report for `aim1_e1_nb_assumption_v1`.
The source was a working-tree file. The run checksum identifies the version,
and the transfer changed only its path.

In the historical input preparation workflow, `encoded_covariates` in
`aim1_mortality_assumption_adapter.py` checks the personal identity code in the
linkage data and returns status, age and the sex category `F` or `M`.
`aim1_e1_nb_assumption_adapter.py` copies the category into
`sex_encoded_in_bridge_hetu` for `ELIGIBLE` rows. Other rows have an empty
field. The field contains neither an identity code nor a fragment of it.
An invalid identity code or age yields `AGE_OR_HETU_UNRESOLVED`. For rows
that pass the preceding checks, a missing or invalid category yields
`SEX_UNRESOLVED`. The R runner uses `INPUT_VALUE` to reject a missing
or invalid category on an `ELIGIBLE` row. Its factor levels are `F`, `M`,
with `F` as the reference under the default contrasts in a vanilla R session.

The synthetic interface test fitted four models and checked the JSON
structure, two invalid or missing-category cases and one truncated input.
The historical input and JSON output remain protected.

## Historical E2/E3 v2 negative binomial runner

`R/e2e3/aim1_e2e3_nb_assumption_runner.R` is a byte-for-byte copy of
`Quantify-FOF-Utilization-Costs/scripts/aim1_e2e3_nb_assumption_runner.R`
in PRS. The configuration `nb_config_v2.json` and the
`provenance_sha256.code.runner` entry in `report.json` for the
2 November 2026 `aim1_e2e3_nb_assumption_v2` run identify the same SHA-256:

```text
1a90cb0065e70edb301a05eb0e1a09c96a1d4c4e6bd7ea6ed894f20c6a528f42
```

The source was a working-tree file. The transfer changed only its path.
The model formulas, DEAC20 scaling per 0.1 units, eligibility filter,
log person-years offset and result calculations are byte-for-byte unchanged.
The historical input adapter `aim1_e2e3_nb_assumption_adapter_v2.py`
has SHA-256
`29b7ae417f9f047fb774a6032fb2701b6f217bd049147f7b52a89f01f2eb23b6`.
The interface test covered four fitted models and their JSON and PDF
structures, four invalid inputs and a case with insufficient predictor
variation. The historical configuration, adapter, input and results remain
outside this repository.

## Historical v2 two-part cost runner

`R/cost/aim1_cost_two_part_runner.R` is a byte-for-byte copy of
`Quantify-FOF-Utilization-Costs/scripts/aim1_cost_two_part_runner.R` in PRS.
The `runner_sha256` entry in `aim1_cost_two_part_config_v2.json` and
`provenance_sha256.runner` in `review_private.json` identify the runner
used for the 6 November 2026 v2 run:

```text
bc19281cc85533fe2390aeb086d8767522c248d612c48f7eee6220a786729b4f
```

The source was a working-tree file. The transfer changed only its path.
`aim1_cost_two_part_adapter.py` supplied the external CSV. The logit part
estimates the probability of a positive cost. The gamma part uses a log
link to estimate positive cumulative cost in 2023 EUR. Both parts use
DEAC20 scaled per 0.1 units and estimate a coefficient for log person-years.
The marginal standardised estimate sums the products of the predicted
probability and conditional cost, then divides by the total person-years
in the target population. The runner compares DEAC20 values of 0.4 and
0.5. The command-line defaults use 1,000 participant bootstrap samples
and seed `20261106`, with the target population held fixed across samples.

The synthetic test used the historical bootstrap defaults on synthetic
inputs. It compared both fitted DEAC20 coefficients and combined
predictions with a separate calculation, checked the JSON structure and
bootstrap metadata and verified seven input rejections. The research inputs,
price list, adapter, configurations and results remain outside this
repository.
