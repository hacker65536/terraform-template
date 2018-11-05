FROM python:2.7-alpine
RUN apk add --no-cache --virtual .builddeps alpine-sdk && \
    apk add libxml2-dev libxslt-dev && \
    pip install locustio pyzmq lxml && \
    apk del .builddeps && \
    apk add libstdc++ && \
    mkdir /locust
Add locustfile.py /locust/locustfile.py
EXPOSE 5557 5558 8089
ENTRYPOINT ["locust", "-f", "/locust/locustfile.py"]
