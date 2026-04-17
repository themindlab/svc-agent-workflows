FROM python:3.12.3-slim

RUN apt-get update && apt-get install -y curl

WORKDIR /app

ENV UV_PROJECT_ENVIRONMENT="/usr/local/"
ENV UV_COMPILE_BYTECODE=1

COPY services/svc-agent-workflows/requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Install submodule requirements 
COPY libraries/py /libraries/py
COPY services/svc-agent-workflows/local-requirements.txt /app/local-requirements.txt
RUN pip install -r local-requirements.txt

ADD services/svc-agent-workflows/src ./

CMD ["python", "run_service.py"]
