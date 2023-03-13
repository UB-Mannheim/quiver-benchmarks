FROM ocrd/all:maximum

WORKDIR /app

COPY requirements.txt requirements.txt

RUN apt install git
RUN apt-get update
RUN apt-get install -y --fix-missing openjdk-11-jre

COPY src src
COPY setup.py setup.py
COPY README.md README.md

RUN git init
RUN git submodule add https://github.com/MehmedGIT/OtoN_Converter submodules/oton
RUN git submodule add https://github.com/OCR-D/quiver-data submodules/quiver-data
RUN git submodule update --init

RUN cd submodules/oton && \
    sed -i 's \\\\$HOME/venv37-ocrd/bin/activate  g' oton/config.toml && \
    sed -i "s \$projectDir/ocrd-workspace/ $WORKSPACE_DIR/CURRENT/ g" oton/config.toml && \
    pip install .

RUN pip3 install -r requirements.txt
RUN pip3 install .
RUN nextflow

COPY workflows workflows

CMD [ "bash", "workflows/execute_workflows.sh" ]