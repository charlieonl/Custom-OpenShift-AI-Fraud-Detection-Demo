FROM registry.access.redhat.com/ubi9/python-312:latest

WORKDIR /opt/app-root/src
COPY app.py ./app.py

ENV APP_HOST=0.0.0.0 \
    APP_PORT=8080 \
    MODEL_NAME=fraud-detection-deploy \
    MODEL_HOST=http://fraud-detection-deploy-predictor.fraud-detection.svc.cluster.local:8080

EXPOSE 8080
CMD ["python3", "app.py"]
