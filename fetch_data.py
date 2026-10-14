#!/usr/bin/env python3
from pathlib import Path
from urllib.request import Request, urlopen
import csv
import sys

BASE = "https://raw.githubusercontent.com/rh-aiservices-bu/fraud-detection/main/data"
FILES = ("train.csv", "validate.csv", "test.csv")
REQUIRED_COLUMNS = {
    "distance_from_last_transaction",
    "ratio_to_median_purchase_price",
    "used_chip",
    "used_pin_number",
    "online_order",
}

root = Path(__file__).resolve().parent
data_dir = root / "data"
data_dir.mkdir(exist_ok=True)

for name in FILES:
    url = f"{BASE}/{name}"
    dest = data_dir / name

    print(f"Downloading {name}...")
    req = Request(url, headers={"User-Agent": "meridian-rhoai-demo"})
    with urlopen(req, timeout=120) as response:
        dest.write_bytes(response.read())

    with dest.open(newline="") as f:
        header = next(csv.reader(f))

    missing = REQUIRED_COLUMNS.difference(header)
    if missing:
        dest.unlink(missing_ok=True)
        raise RuntimeError(
            f"{name} downloaded but is missing expected columns: {sorted(missing)}"
        )

    print(f"  saved {dest} ({dest.stat().st_size:,} bytes)")

print("\nData ready.")
print("Run 01_train_v1.ipynb first, then 02_create_v2.ipynb.")
