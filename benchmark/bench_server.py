"""Desktop inference bridge for the NER benchmark.

Reads one JSON object per line from stdin: {"ids": [...], "mask": [...]}
and writes one JSON line with the logits (list of rows) to stdout.
Used by packages/docudis_engine/benchmark/run_benchmark.dart when no phone
is attached; the phone integration test uses ONNX Runtime directly.

Usage: python bench_server.py <model.onnx> <input_ids_name> <mask_name> <output_name>
"""
import json
import sys

import numpy as np
import onnxruntime as ort


def main() -> None:
    model_path, ids_name, mask_name, output_name = sys.argv[1:5]
    session = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
    sys.stdout.write("ready\n")
    sys.stdout.flush()
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        req = json.loads(line)
        ids = np.array([req["ids"]], dtype=np.int64)
        mask = np.array([req["mask"]], dtype=np.int64)
        (logits,) = session.run([output_name], {ids_name: ids, mask_name: mask})
        sys.stdout.write(json.dumps(logits[0].astype(float).tolist()) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
