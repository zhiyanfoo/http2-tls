FROM ubuntu:jammy

WORKDIR /app

# Copy pre-built binary from file system
COPY bin/client-linux /app/bin/client
COPY cert/server.crt /app/cert/server.crt

CMD ["/app/bin/client"]
