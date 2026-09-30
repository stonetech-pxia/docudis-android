"""Run the Docudis OCR corpus through a small OCR vision-language model.

Whole-page recognition with a single prompt and no layout model, i.e. the
setup a phone would run. Writes the same prediction JSON as
run_ppocrv6_benchmark.py; score it with benchmark/score_ocr_predictions.dart.
"""

from __future__ import annotations

import argparse
import json
import platform
import sys
import time
from pathlib import Path

import torch
import transformers
from PIL import Image, ImageOps
from transformers import AutoModelForImageTextToText, AutoProcessor


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]

MODELS = {
    "paddleocr-vl": ("PaddlePaddle/PaddleOCR-VL-1.6", "OCR:"),
    "glm-ocr": ("zai-org/GLM-OCR", "Text Recognition:"),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", choices=sorted(MODELS), required=True)
    parser.add_argument(
        "--manifest",
        type=Path,
        default=REPOSITORY_ROOT / "benchmark" / "ocr_cases.json",
    )
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--limit", type=int)
    parser.add_argument(
        "--max-pixels",
        type=int,
        help="resize budget for the vision encoder (model default if unset)",
    )
    parser.add_argument("--max-new-tokens", type=int, default=4096)
    parser.add_argument(
        "--model-path",
        help="local snapshot directory instead of the Hugging Face id",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    model_id, prompt = MODELS[args.model]
    model_path = args.model_path or model_id
    document = json.loads(args.manifest.resolve().read_text(encoding="utf-8"))
    cases = document["cases"]
    if args.limit is not None:
        cases = cases[: args.limit]

    processor = AutoProcessor.from_pretrained(model_path)
    model = (
        AutoModelForImageTextToText.from_pretrained(
            model_path, dtype=torch.bfloat16
        )
        .to("cuda")
        .eval()
    )

    def recognize(image_path: Path) -> str:
        # Phone photos carry EXIF rotation; the OCR must see the upright page.
        image = ImageOps.exif_transpose(Image.open(image_path)).convert("RGB")
        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "image", "image": image},
                    {"type": "text", "text": prompt},
                ],
            }
        ]
        extra = {}
        if args.max_pixels:
            extra["images_kwargs"] = {
                "size": {
                    "shortest_edge": processor.image_processor.min_pixels,
                    "longest_edge": args.max_pixels,
                }
            }
        inputs = processor.apply_chat_template(
            messages,
            add_generation_prompt=True,
            tokenize=True,
            return_dict=True,
            return_tensors="pt",
            **extra,
        ).to(model.device)
        with torch.inference_mode():
            outputs = model.generate(
                **inputs, max_new_tokens=args.max_new_tokens, do_sample=False
            )
        return processor.decode(
            outputs[0][inputs["input_ids"].shape[-1] :],
            skip_special_tokens=True,
        ).strip()

    recognize(REPOSITORY_ROOT / cases[0]["imagePath"])  # warm-up

    results: list[dict[str, object]] = []
    for index, case in enumerate(cases, start=1):
        image_path = REPOSITORY_ROOT / case["imagePath"]
        torch.cuda.synchronize()
        started = time.perf_counter_ns()
        error: str | None = None
        recognized_text = ""
        try:
            recognized_text = recognize(image_path)
        except Exception as exception:  # benchmark must record every failure
            error = f"{type(exception).__name__}: {exception}"
        torch.cuda.synchronize()
        elapsed_micros = (time.perf_counter_ns() - started) // 1_000
        result: dict[str, object] = {
            "id": case["id"],
            "recognizedText": recognized_text,
            "recognizedTextFormat": "markdown",
            "elapsedMicros": elapsed_micros,
        }
        if error is not None:
            result["error"] = error
        results.append(result)
        status = "ERROR " + error if error else f"{len(recognized_text)} chars"
        print(
            f"[{index:02d}/{len(cases):02d}] {case['id']:<36} "
            f"{elapsed_micros / 1000:8.0f} ms  {status}",
            flush=True,
        )

    output = {
        "title": "OCR benchmark (local server)",
        "platform": (
            f"{platform.platform()} {torch.cuda.get_device_name()} (bfloat16)"
        ),
        "recognizerName": (
            f"{model_id} (whole page, prompt {prompt!r}, no layout model"
            + (f", max_pixels {args.max_pixels}" if args.max_pixels else "")
            + ")"
        ),
        "versions": {
            "python": sys.version.split()[0],
            "torch": torch.__version__,
            "transformers": transformers.__version__,
        },
        "results": results,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"Predictions: {args.output.resolve()}")
    return 1 if any("error" in result for result in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
