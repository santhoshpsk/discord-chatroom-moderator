FROM alpine:latest

WORKDIR /opt/src

ENV PY_VENV_DIR /opt/venv

RUN apk update

RUN apk add python3 py3-pip

RUN python -m venv $PY_VENV_DIR

COPY . $WORKDIR

RUN . $PY_VENV_DIR/bin/activate && pip install --no-cache-dir -r requirement.pip && deactivate

CMD [".", "${PY_VENV_DIR}/bin/activate", "&&", "python", "main.py"]