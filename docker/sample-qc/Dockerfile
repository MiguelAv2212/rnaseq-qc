FROM python:3.12-slim

LABEL description="multiqc and python reporting tools"

ARG MULTIQC_VERSION=1.21

RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    multiqc==${MULTIQC_VERSION}

COPY generate_report.py /usr/local/bin/generate_report.py
RUN chmod +x /usr/local/bin/generate_report.py

WORKDIR /data
