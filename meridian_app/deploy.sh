#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="fraud-detection"
APP="meridian-fraud-demo"

for cmd in oc; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "ERROR: '$cmd' is required."; exit 1; }
done

oc whoami >/dev/null
oc project "$NAMESPACE" >/dev/null

READY="$(oc get inferenceservice fraud-detection-deploy -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
if [[ "$READY" != "True" ]]; then
  echo "ERROR: fraud-detection-deploy is not Ready. Deploy the model first."
  oc get inferenceservice fraud-detection-deploy -n "$NAMESPACE" || true
  exit 1
fi

echo "Creating OpenShift resources..."
oc apply -f openshift.yaml

echo "Building Meridian application image..."
oc start-build "$APP" --from-dir=. --follow -n "$NAMESPACE"

echo "Starting application deployment..."
oc rollout restart deployment/$APP -n "$NAMESPACE"
oc rollout status deployment/$APP -n "$NAMESPACE" --timeout=180s

echo
echo "Meridian Financial is available at:"
echo "https://$(oc get route $APP -n "$NAMESPACE" -o jsonpath='{.spec.host}')"
echo
echo "Model remains internal at:"
echo "http://fraud-detection-deploy-predictor.fraud-detection.svc.cluster.local:8080"
