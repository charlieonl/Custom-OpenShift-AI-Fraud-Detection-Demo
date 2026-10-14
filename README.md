# Meridian Financial — Minimal Red Hat OpenShift AI Fraud Demo

This folder contains only the files needed for the reusable Meridian Financial demo.

## Folder structure

```text
meridian_rhoai_fraud_demo/
├── 01_train_v1.ipynb
├── 02_create_v2.ipynb
├── fetch_data.py
├── data/
├── meridian_app/
│   ├── app.py
│   ├── Dockerfile
│   ├── openshift.yaml
│   └── deploy.sh
└── SOURCE.md
```

Generated during use:

```text
models/fraud/1/model.onnx
models/fraud/2/model.onnx
artifact/
```

## Fresh workbench use

Put this entire folder on the **workbench PVC** and open a terminal in the folder.

Fetch the exact three upstream CSV files required by the notebooks:

```bash
python3 fetch_data.py
```

Then run, in order:

```text
01_train_v1.ipynb
02_create_v2.ipynb
```

`01_train_v1.ipynb` creates:

```text
models/fraud/1/model.onnx
```

`02_create_v2.ipynb` creates:

```text
models/fraud/2/model.onnx
```

The v2 model is 85% less sensitive to `distance_from_last_transaction`
by reducing that fitted logistic-regression coefficient to 15% of its v1 value.

## OpenShift AI model deployment

Use the workbench PVC as cluster storage.

For v1:

```text
InferenceService name: fraud-detection-deploy
Model path: <folder-name>/models/fraud/1
Framework: ONNX
Runtime: MLServer
MLSERVER_MODEL_URI=/mnt/models/model.onnx
```

If this folder is placed directly at the PVC root and renamed, use that exact folder
name in the model path. For example, with the default package name:

```text
meridian_rhoai_fraud_demo/models/fraud/1
```

For v2, change only the model path to:

```text
meridian_rhoai_fraud_demo/models/fraud/2
```

Keep the InferenceService name unchanged.

## Deploy the Meridian Financial application

After `fraud-detection-deploy` is `READY=True`, from your Mac or another machine
with `oc` logged into the cluster:

```bash
cd meridian_app
chmod +x deploy.sh
./deploy.sh
```

The application is deployed into the `fraud-detection` project and talks to:

```text
fraud-detection-deploy-predictor.fraud-detection.svc.cluster.local
```

through the cluster-internal service.

Get the application URL with:

```bash
echo "https://$(oc get route meridian-fraud-demo \
  -n fraud-detection \
  -o jsonpath='{.spec.host}')"
```

Switching v1 → v2 does **not** require rebuilding or redeploying the Meridian app.

## What was intentionally removed

The original upstream repository contains workshop material for pipelines,
distributed training, Ray, KFTO, Feast, S4/setup helpers, additional notebooks,
assets, and other examples. None of those are required for this demo, so they are
not included here.
