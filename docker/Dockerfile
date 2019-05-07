FROM alpine:3.9.3

RUN addgroup relay42 && \
    adduser -D -G relay42 relay42

RUN apk add git && \
    apk add openjdk8

USER relay42
WORKDIR /home/relay42

RUN git clone https://github.com/lc-nyovchev/opstest.git . && \
    chmod +x mvnw && \
    ./mvnw install

ADD entrypoint.sh ./

EXPOSE 8080
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
