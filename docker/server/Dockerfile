FROM ubuntu:jammy

WORKDIR /app

# Copy pre-built binary from file system
COPY bin/server-linux /app/bin/server
COPY cert /app/cert

CMD ["/app/bin/server"]
