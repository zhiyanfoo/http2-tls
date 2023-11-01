.SUFFIXES:

.PHONY: docker-up
docker-up: bin/server-linux bin/client-linux cert/server.crt cert/server.crt cert/server.key
	docker-compose up --remove-orphans --build

.PHONY: docker-down
docker-down:
	docker-compose down --remove-orphans

.PHONY: docker-server
docker-server: bin/server-linux cert/server.crt cert/server.key
	docker build -t server:1.0 -f docker/server/Dockerfile .

.PHONY: docker-client
docker-client: bin/client-linux cert/server.crt
	docker build -t client:1.0 -f docker/client/Dockerfile .

docker: docker-server docker-client

.PHONY: client
client: bin/client
	./bin/client

.PHONY: server
server: bin/server
	./bin/server

bin/server: cmd/server/main.go pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	go build -o bin/server cmd/server/main.go

bin/server-linux: cmd/server/main.go pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	GOOS=linux GOARCH=arm64 go build -o bin/server-linux cmd/server/main.go

bin/client: cmd/client/main.go pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	go build -o bin/client cmd/client/main.go

bin/client-linux: cmd/client/main.go pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	GOOS=linux GOARCH=arm64 go build -o bin/client-linux cmd/client/main.go

pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go: proto/echo.proto
	protoc --go_out=. --go_opt=module=github.com/zhiyanfoo/http2-tls \
		--go_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		--go-grpc_out=. --go-grpc_opt=module=github.com/zhiyanfoo/http2-tls \
		--go-grpc_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		proto/echo.proto

cert/server.crt cert/server.key:
	./scripts/generate_server_cert.sh

.PHONY: cert-check
cert-check:
	openssl s_client -connect localhost:50051 2>/dev/null | openssl x509 -text

fmt:
	gofmt -s -w .
