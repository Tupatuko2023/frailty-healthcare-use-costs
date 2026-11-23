# Synthetic testing

Run the tests from the repository root. The tests create their own synthetic
inputs. See the [README](../README.md#setup-and-synthetic-example) for setup
and the R dependencies. For Python, use the interpreter from an isolated
environment with `pytest`. Check that any local `conftest.py` you have added
will not alter test discovery or execution.

```sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q \
  tests/test_deac_index.py tests/test_deac_k51_chain_synthetic.py
Rscript --vanilla tests/test_aim1_e1_nb_runner.R
Rscript --vanilla tests/test_aim1_e2e3_nb_runner.R
Rscript --vanilla tests/test_aim1_cost_two_part_runner.R
```

## Recorded results

These results were recorded at the named local transfer revisions. Their
provenance is retained after publication of the code.

| Check | Tested AIM1 revision | Result |
| --- | --- | --- |
| WP1 assembler and synthetic K51 command-line workflow | `a3d1705fae3efe9c00fe75525a2206b5f0ec306e` | 19/19 |
| E1 interface | `f90293bf56a05df125d1d5a7b71ffcd8d2913eca` | 4/4 |
| E2/E3 v2 interface | `c5c2779bb1c450f5f5a94b5bf4349c5c49da2332` | 6/6 |
| v2 cost model interface | `7cdfa349f2d07391b8861273c68742c1aaafce31` | 8/8 |

A separate synthetic regression suite for the six K51 modules returned
334/334 in the [historical source revision](PROVENANCE.md#historical-k51auth_source-scoring-code).
The original WP1 test loads `DEAC-Frailty-Index/src/deac_index.py` and
covers both sides of the 80% eligibility threshold, ordinary missingness,
confirmed non-applicability, an empty set of relevant components and
invalid values or component names. The [historical WP1 review](WP1_REVIEW.md)
records the original 17/17 run and its environment.

The tests establish synthetic behaviour at the code and interface level.
They do not verify the mapping of study source variables, establish
scientific validity or reproduce research results from protected inputs.
