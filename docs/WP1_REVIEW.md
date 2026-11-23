# Historical WP1 review, 19 November 2026

This English rendering records the status at the time of the WP1 review.
The original Finnish text is retained in publication revision
[`1a4432e`](https://github.com/Tupatuko2023/frailty-healthcare-use-costs/blob/1a4432e989a6835b35e4d0173fa61649dcfe4ee3/docs/WP1_REVIEW.md).
See the [README](../README.md) for the current scope of the public repository.

## Scope and findings at the time of review

| Item | Recorded status | Evidence and limit |
| --- | --- | --- |
| Local repository scaffold | Ready for review | The repository had no remote. The local commit included the README, test and provenance documentation, and `.gitignore`. It had not been delivered to a remote `main`. |
| Code transfer | Pass | `DEAC-Frailty-Index/src/deac_index.py` and `tests/test_deac_index.py` matched their sources byte for byte. [Provenance](PROVENANCE.md) records the SHA-256 values and Git revisions. |
| Original synthetic test | Pass | 17 collected, 17 passed, 0 failed and 0 skipped. Exit status 0. |
| Scientific verification of scoring | Needs verification | The applicable controlling version of section 3.1 of `METHODS_AND_SCORING.md` and its approval references had not been compared with the implementation. |
| Permission to publish | Open at review | The source documentation supported MIT for Python code. The source npm package declared ISC without naming the transferred files. [Provenance](PROVENANCE.md#licence-and-attribution) records the release licence and attribution. |

## Recorded test run

The code and test were inspected before execution. They used synthetic inputs
without accessing protected inputs or network sources. The checkout had no
`conftest.py`. The ignored local `.venv` environment was prepared from the
existing uv cache in offline mode.

- Interpreter: `.venv/bin/python` (Python 3.14.6).
- Packages: pytest 9.1.1, iniconfig 2.3.0, packaging 26.3, pluggy 1.6.0 and
  pygments 2.21.0.
- Command from the checkout root:

  ```sh
  PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 .venv/bin/python -m pytest -q tests/test_deac_index.py
  ```

- Output: `17 passed in 0.02s`, exit status 0.

The result refers to the WP1 execution of the original synthetic test file.
Six earlier parity cases were separate evidence. The WP1 result establishes
the synthetic behaviour exercised by that test. Study source scoring,
research decisions and reproduction on protected inputs remained outside
its scope.

## Historical delivery boundary

The WP1 checkout was local. A remote, a `main` delivery, publication, merge
and worktree cleanup were outside that review. WP1 covered the index
assembler rather than the full AIM1 analysis workflow.
