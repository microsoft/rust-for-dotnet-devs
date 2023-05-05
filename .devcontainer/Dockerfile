FROM alpine:latest AS stage

RUN wget https://github.com/rust-lang/mdBook/releases/download/v0.4.25/mdbook-v0.4.25-aarch64-unknown-linux-musl.tar.gz
RUN tar -xvf mdbook-v0.4.25-aarch64-unknown-linux-musl.tar.gz

FROM alpine:latest
COPY --from=stage mdbook /usr/local/bin/mdbook
WORKDIR /project
ENTRYPOINT ["mdbook"]
