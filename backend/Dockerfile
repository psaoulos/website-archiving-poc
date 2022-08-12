FROM alpine:3.14

WORKDIR /usr/src/app

COPY . .

RUN apk add --no-cache bash\
    build-base \
    mariadb-client \
    mariadb-connector-c-dev \
    python3-dev \
    musl-dev \
    linux-headers \
    wkhtmltopdf \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation 
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install --no-cache-dir -r requirements.txt

CMD [ "python3", "./backend.py" ]