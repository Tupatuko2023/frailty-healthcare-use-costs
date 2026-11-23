# Frailty, healthcare use and costs (AIM1)

This repository is the public research-code companion for the AIM1 study of
DEAC20 frailty, healthcare use and costs. It supports a scientific manuscript
targeting *BMC Geriatrics*. The code and documentation are intended for
researchers, peer reviewers and readers who want to inspect, understand or
reuse the implementation.

## Included code

| Stage | Entry point | Runtime dependencies |
| --- | --- | --- |
| K51/AUTH_SOURCE DEAC20 scoring, including the index assembler | [`deac_run.py`](DEAC-Frailty-Index/src/deac_run.py) | Python standard library, five local modules, Git and Linux/Termux with `renameat2` support |
| E1 negative binomial models (four) | [E1 runner](R/e1/aim1_e1_nb_assumption_runner.R) | Rscript, MASS and jsonlite |
| E2/E3 v2 negative binomial models (four) | [E2/E3 runner](R/e2e3/aim1_e2e3_nb_assumption_runner.R) | Rscript, MASS and jsonlite |
| v2 two-part cost model | [Cost runner](R/cost/aim1_cost_two_part_runner.R) | Rscript and jsonlite |

The [running guide](docs/RUNNING.md) describes the input and output schemas,
commands and dependencies for each stage.

## Setup and synthetic example

Clone the repository and work from its root. Use Python 3.10 or later. The
scoring CLI requires a Git checkout and a filesystem that supports
`RENAME_NOREPLACE` through `renameat2`. Python's test dependency is `pytest`.

```sh
git clone https://github.com/Tupatuko2023/frailty-healthcare-use-costs.git
cd frailty-healthcare-use-costs
python3 -m venv .venv
.venv/bin/python -m pip install pytest
```

Install R and make MASS and jsonlite available to Rscript. For an R library
that does not contain them, use:

```sh
Rscript --vanilla -e 'install.packages(c("MASS", "jsonlite"), repos = "https://cloud.r-project.org")'
```

The recorded synthetic checks used R 4.5.3, MASS 7.3-65 and jsonlite 2.0.0.
The cost runner's built-in example generates synthetic data in memory and
exercises both model parts without research inputs:

```sh
Rscript --vanilla R/cost/aim1_cost_two_part_runner.R --self-test
```

## Run the synthetic tests

From the repository root, run:

```sh
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q \
  tests/test_deac_index.py tests/test_deac_k51_chain_synthetic.py
Rscript --vanilla tests/test_aim1_e1_nb_runner.R
Rscript --vanilla tests/test_aim1_e2e3_nb_runner.R
Rscript --vanilla tests/test_aim1_cost_two_part_runner.R
```

The tests generate their own inputs. The [testing guide](docs/TESTING.md)
describes the recorded results and their scope.

## Research data and reproducibility

The historical research runs took place in a protected source environment.
The research data, source bindings, run configurations, input-preparation
adapters and protected outputs remain outside this repository. The model
runners require prepared input tables. The running guide identifies the
external components and the versions for which evidence is available.

The published code and synthetic tests support inspection of the
implementation and its interfaces. No protected reproduction run has been
performed from this repository. Some historical helper-module versions remain
unverified. The available evidence does not establish scientific validation or
full end-to-end reproducibility. Manuscript acceptance and research-data
access are separate matters.

See [code provenance](docs/PROVENANCE.md) for source versions, checksums and
the historical record. The repository is released under the [MIT licence](LICENSE).
