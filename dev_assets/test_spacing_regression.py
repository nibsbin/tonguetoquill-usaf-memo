from pathlib import Path
import sys
import tempfile

try:
    import fitz
    import typst
except ImportError as exc:
    raise SystemExit(
        "This regression check requires the Python packages 'typst' and 'pymupdf'."
    ) from exc


REPO_ROOT = Path(__file__).resolve().parent.parent
FIXTURE = REPO_ROOT / "dev_assets" / "test_spacing_regression.typ"
FONT_PATHS = [str(REPO_ROOT), str(REPO_ROOT / "fonts")]
EXPECTED_PREFIXES = (
    "TEST/CD",
    "FROM:  TEST/DO",
    "Washington DC 12345",
    "SUBJECT:  Spacing Regression",
    "1.  Alpha top paragraph.",
    "a.  Bravo child paragraph.",
    "2.  Charlie closing paragraph.",
)


def extract_line_positions(pdf_path: Path) -> dict[str, float]:
    doc = fitz.open(pdf_path)
    page = doc[0]
    positions: dict[str, float] = {}

    for block in page.get_text("dict")["blocks"]:
        if block.get("type") != 0:
            continue
        for line in block["lines"]:
            text = "".join(span["text"] for span in line["spans"]).strip()
            if not text:
                continue
            for prefix in EXPECTED_PREFIXES:
                if text.startswith(prefix):
                    positions[prefix] = line["bbox"][1]

    return positions


def main() -> int:
    with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as compiled:
        output_path = Path(compiled.name)

    try:
        typst.compile(
            str(FIXTURE),
            output=str(output_path),
            root=str(REPO_ROOT),
            font_paths=FONT_PATHS,
        )

        positions = extract_line_positions(output_path)
        missing = [prefix for prefix in EXPECTED_PREFIXES if prefix not in positions]
        if missing:
            raise AssertionError(f"Missing expected lines in compiled PDF: {missing}")

        heading_gap = positions["FROM:  TEST/DO"] - positions["TEST/CD"]
        from_gap = positions["SUBJECT:  Spacing Regression"] - positions["Washington DC 12345"]
        subject_gap = positions["1.  Alpha top paragraph."] - positions["SUBJECT:  Spacing Regression"]
        body_gap_1 = positions["a.  Bravo child paragraph."] - positions["1.  Alpha top paragraph."]
        body_gap_2 = positions["2.  Charlie closing paragraph."] - positions["a.  Bravo child paragraph."]

        gaps = {
            "for_to_from": heading_gap,
            "from_to_subject": from_gap,
            "subject_to_body": subject_gap,
            "body_to_subparagraph": body_gap_1,
            "subparagraph_to_body": body_gap_2,
        }

        min_gap = min(gaps.values())
        max_gap = max(gaps.values())
        if max_gap - min_gap > 1.0:
            raise AssertionError(f"Inconsistent spacing detected: {gaps}")

        print("Spacing regression check passed:", {k: round(v, 2) for k, v in gaps.items()})
        return 0
    finally:
        output_path.unlink(missing_ok=True)


if __name__ == "__main__":
    sys.exit(main())
