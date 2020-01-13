FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
        curl \
        openjdk-11-jdk-headless \
        python3 \
        unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /register
COPY setup.sh to_csv.py transform.xql run_conversion.sh ./
VOLUME ["/register/data"]
CMD ./setup.sh && ./run_conversion.sh && mv output-*.csv data/.
