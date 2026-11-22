"""Exercise the frozen DEAC command line with a wholly synthetic workbook."""

import csv
import hashlib
import json
from pathlib import Path
import stat
import subprocess
import sys
from xml.etree import ElementTree as ET
from zipfile import ZipFile

import pytest


REPO = Path(__file__).resolve().parents[1]
RUNNER = REPO / "DEAC-Frailty-Index" / "src" / "deac_run.py"
NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"


def write_synthetic_workbook(path, headers, labels, data):
    worksheet = ET.Element(f"{{{NS}}}worksheet")
    sheet_data = ET.SubElement(worksheet, f"{{{NS}}}sheetData")
    for row_number, values in enumerate((headers, labels, *data), 1):
        row = ET.SubElement(sheet_data, f"{{{NS}}}row", r=str(row_number))
        for column, value in enumerate(values):
            letter = chr(ord("A") + column)
            cell = ET.SubElement(row, f"{{{NS}}}c", r=f"{letter}{row_number}")
            if isinstance(value, str):
                cell.set("t", "inlineStr")
                inline = ET.SubElement(cell, f"{{{NS}}}is")
                ET.SubElement(inline, f"{{{NS}}}t").text = value
            else:
                ET.SubElement(cell, f"{{{NS}}}v").text = str(value)

    with ZipFile(path, "w") as workbook:
        workbook.writestr(
            "xl/workbook.xml",
            f'<workbook xmlns="{NS}" '
            'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            '<sheets><sheet name="Synthetic" sheetId="1" r:id="rId1"/></sheets></workbook>',
        )
        workbook.writestr(
            "xl/_rels/workbook.xml.rels",
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Id="rId1" Target="worksheets/sheet1.xml"/></Relationships>',
        )
        workbook.writestr("xl/worksheets/sheet1.xml", ET.tostring(worksheet))


def private_file(path, content):
    path.write_text(content, encoding="utf-8")
    path.chmod(0o600)
    return path


@pytest.mark.parametrize("wrong_snapshot", [False, True])
def test_frozen_deac_cli_with_synthetic_input(tmp_path, wrong_snapshot):
    baseline = {
        "diabetes": 0,
        "alzheimer": 0,
        "parkinson": 0,
        "stroke_avh": 0,
        "self_rated_health": 0,
        "moi_total": 1,
        "baseline_age_years": 60,
        "alcohol": 0,
        "hearing": 0,
        "vision": 0,
        "memory": 0,
        "mood": 0,
        "sleep": 0,
        "self_rated_mobility": 0,
        "walking_500m": 0,
        "balance_difficulty": 0,
        "previous_fall": 0,
        "fear_of_falling": 0,
        "pain_vas_cm": 0,
        "better_leg_stance_seconds": 12,
        "five_chair_rises_seconds": 10,
        "better_hand_grip_class": 5,
        "selected_max_10m_seconds": 8,
    }
    fields = list(baseline)
    headers = [f"synthetic_{name}" for name in fields] + ["fictional_id", "fictional_date"]
    labels = [f"label_{name}" for name in headers]
    rows = [
        [*dict(baseline, diabetes=1, moi_total=9).values(), "fake-a", "2020-01-02"],
        [*baseline.values(), "fake-a", "2020-01-01"],
        [*dict(baseline, diabetes=1, moi_total=6).values(), "fake-b", "2020-01-01"],
    ]
    workbook = tmp_path / "synthetic.xlsx"
    write_synthetic_workbook(workbook, headers, labels, rows)
    source_hash = hashlib.sha256(workbook.read_bytes()).hexdigest()
    env = private_file(
        tmp_path / "synthetic.env",
        f"SYNTHETIC_WORKBOOK={workbook}\nSYNTHETIC_ID=fictional_id\n",
    )
    bindings = {
        "schema_version": 1,
        "source_sha256": source_hash,
        "sheet": "Synthetic",
        "header_row": 1,
        "label_row": 2,
        "data_start_row": 3,
        "columns": dict(zip(fields, headers[:-2], strict=True)),
        "positions_1based": dict(zip(fields, range(1, len(fields) + 1), strict=True)),
        "expected_labels": dict(zip(fields, labels[:-2], strict=True)),
    }
    selector = {
        "schema_version": 1,
        "source_sha256": "0" * 64 if wrong_snapshot else source_hash,
        "env_sha256": hashlib.sha256(env.read_bytes()).hexdigest(),
        "identifier_setting": "SYNTHETIC_ID",
        "selector_rule": "Earliest fictional visit",
        "identifier_position_1based": len(fields) + 1,
        "visit_date_position_1based": len(fields) + 2,
    }
    correction = {
        "person_key": "fake-a",
        "baseline_visit": "2020-01-01",
        "source_sha256": source_hash,
        "source_moi_total": 1,
        "baseline_age_years": 60,
        "corrected_moi_without_age": 0,
        "approval_provenance": "Synthetic fixture",
    }
    output_parent = tmp_path / "synthetic-output"
    output_parent.mkdir(mode=0o700)
    args = [sys.executable, "-B", str(RUNNER), "--env", str(env)]
    for option, data in (("bindings", bindings), ("selector", selector), ("correction", correction)):
        path = private_file(tmp_path / f"{option}.json", json.dumps(data))
        args.extend([f"--{option}", str(path)])
    args.extend(["--output-parent", str(output_parent)])

    result = subprocess.run(args, cwd=REPO, capture_output=True, text=True, check=False)
    if wrong_snapshot:
        assert result.returncode != 0
        assert "refer to different snapshots" in result.stderr
        assert not list(output_parent.iterdir())
        return

    assert result.returncode == 0, result.stderr
    manifest_path, = output_parent.glob("*/deac_v2_run_manifest_*.json")
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    recorded_code = manifest["code_version"]["source_files"]
    assert len(recorded_code) == 6
    assert all(
        hashlib.sha256((RUNNER.parent / name).read_bytes()).hexdigest() == digest
        for name, digest in recorded_code.items()
    )
    assert manifest["aggregate_qc"]["later_visit_rows"] == 1
    assert manifest["moi"]["recomputed_cutpoints"] == pytest.approx([0.8, 1.6, 2.4, 3.2])
    output_path = manifest_path.parent / manifest["output"]["relative_path"]
    assert stat.S_IMODE(output_path.stat().st_mode) == 0o600
    assert hashlib.sha256(output_path.read_bytes()).hexdigest() == manifest["output"]["sha256"]
    with output_path.open(newline="", encoding="utf-8") as stream:
        rows = {row["participant_key"]: row for row in csv.DictReader(stream)}
    assert set(rows) == {"fake-a", "fake-b"}
    assert float(rows["fake-a"]["diabetes"]) == 0.0
    assert all(int(row["observed_components"]) == 20 for row in rows.values())
    assert [float(rows[key]["deac_index"]) for key in ("fake-a", "fake-b")] == pytest.approx(
        [0.0, 0.1]
    )
