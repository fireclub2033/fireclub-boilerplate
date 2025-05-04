ARG PYTHON_VERSION=3.9.12
FROM python:${PYTHON_VERSION}-slim

WORKDIR /app

COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8888

CMD [ "jupyter", "lab", "--allow-root", "--no-browser", "--ip=0.0.0.0" ]
