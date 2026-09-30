"""Run the Docudis OCR corpus through a local PP-OCRv6 pipeline.

The script only performs inference. The companion Dart scorer consumes the
prediction JSON so all OCR engines use the same normalization and metrics.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import sys
import time
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
os.environ.setdefault(
    "PADDLE_PDX_CACHE_HOME",
    str(REPOSITORY_ROOT / ".dart_tool" / "paddlex-cache"),
)
os.environ.setdefault("PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK", "True")

import cv2  # noqa: E402
import paddle  # noqa: E402
import paddleocr  # noqa: E402
from paddleocr import PaddleOCR  # noqa: E402


# PP-OCRv6 recognizers cover Chinese, Japanese and Latin scripts only; cases
# declaring another script use the matching PP-OCRv5 script recognizer, the
# same per-case script selection the on-device ML Kit runner does.
SCRIPT_RECOGNITION_MODELS = {
    "devanagiri": "devanagari_PP-OCRv5_mobile_rec",  # ML Kit spelling
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest",
        type=Path,
        default=REPOSITORY_ROOT / "benchmark" / "ocr_cases.json",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=(
            REPOSITORY_ROOT
            / "docs"
            / "benchmark"
            / "ocr-ppocrv6-small-predictions.json"
        ),
    )
    parser.add_argument("--limit", type=int)
    parser.add_argument(
        "--size",
        choices=("tiny", "small", "medium"),
        default="small",
    )
    parser.add_argument(
        "--pad",
        type=int,
        default=0,
        help="white border in pixels added before detection, so text "
        "touching the image edge is not clipped",
    )
    parser.add_argument(
        "--script-models",
        action="store_true",
        help="use a script-specific recognizer for non-CJK/Latin cases",
    )
    return parser.parse_args()


def extract_text(predictions: list[object]) -> str:
    lines: list[str] = []
    for prediction in predictions:
        payload = prediction.json["res"]
        lines.extend(str(value) for value in payload.get("rec_texts", []))
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    manifest_path = args.manifest.resolve()
    document = json.loads(manifest_path.read_text(encoding="utf-8"))
    cases = document["cases"]
    if args.limit is not None:
        cases = cases[: args.limit]
    if not cases:
        raise ValueError("OCR manifest contains no cases")

    detection_model = f"PP-OCRv6_{args.size}_det"
    recognition_model = f"PP-OCRv6_{args.size}_rec"

    def create_recognizer(recognition_model_name: str) -> PaddleOCR:
        return PaddleOCR(
            text_detection_model_name=detection_model,
            text_recognition_model_name=recognition_model_name,
            use_doc_orientation_classify=False,
            use_doc_unwarping=False,
            use_textline_orientation=False,
            # PaddlePaddle 3.3.x has an open oneDNN/PIR CPU inference bug for
            # these models. Disabling MKL-DNN selects the stable CPU path.
            enable_mkldnn=False,
        )

    recognizers = {None: create_recognizer(recognition_model)}
    if args.script_models:
        for case in cases:
            model = SCRIPT_RECOGNITION_MODELS.get(case.get("script"))
            if model is not None and model not in recognizers:
                recognizers[model] = create_recognizer(model)

    def load_image(image_path: Path):
        image = cv2.imread(str(image_path), cv2.IMREAD_COLOR)
        if image is None:
            raise ValueError(f"cannot read {image_path}")
        if args.pad > 0:
            image = cv2.copyMakeBorder(
                image, args.pad, args.pad, args.pad, args.pad,
                cv2.BORDER_CONSTANT, value=(255, 255, 255),
            )
        return image

    first_image = load_image(REPOSITORY_ROOT / cases[0]["imagePath"])
    for recognizer in recognizers.values():
        list(recognizer.predict(first_image))

    results: list[dict[str, object]] = []
    for index, case in enumerate(cases, start=1):
        image_path = REPOSITORY_ROOT / case["imagePath"]
        started = time.perf_counter_ns()
        error: str | None = None
        recognized_text = ""
        try:
            recognizer = recognizers[
                SCRIPT_RECOGNITION_MODELS.get(case.get("script"))
                if args.script_models
                else None
            ]
            recognized_text = extract_text(
                list(recognizer.predict(load_image(image_path)))
            )
        except Exception as exception:  # benchmark must record every failure
            error = f"{type(exception).__name__}: {exception}"
        elapsed_micros = (time.perf_counter_ns() - started) // 1_000
        result: dict[str, object] = {
            "id": case["id"],
            "recognizedText": recognized_text,
            "elapsedMicros": elapsed_micros,
        }
        if error is not None:
            result["error"] = error
        results.append(result)
        status = "ERROR" if error else f"{len(recognized_text)} chars"
        print(
            f"[{index:02d}/{len(cases):02d}] {case['id']:<36} "
            f"{elapsed_micros / 1000:8.0f} ms  {status}",
            flush=True,
        )

    output = {
        "title": "OCR benchmark (local server)",
        "platform": f"{platform.platform()} CPU",
        "recognizerName": (
            f"PP-OCRv6-{args.size} ({detection_model} + {recognition_model}"
            + (
                "; script recognizers: "
                + ", ".join(sorted(k for k in recognizers if k))
                if len(recognizers) > 1
                else ""
            )
            + (f"; {args.pad}px white padding" if args.pad else "")
            + "; oneDNN disabled)"
        ),
        "versions": {
            "python": sys.version.split()[0],
            "paddlepaddle": paddle.__version__,
            "paddleocr": paddleocr.__version__,
        },
        "results": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(output, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Predictions: {args.output.resolve()}")
    return 1 if any("error" in result for result in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
