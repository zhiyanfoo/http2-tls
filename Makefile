.PHONY: server
server: protos server-certs
	go run cmd/server/main.go

.PHONY: client
client: protos client-certs
	go run cmd/client/main.go

pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go: proto/echo.proto
	protoc --go_out=. --go_opt=module=github.com/zhiyanfoo/http2-tls \
		--go_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		--go-grpc_out=. --go-grpc_opt=module=github.com/zhiyanfoo/http2-tls \
		--go-grpc_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		proto/echo.proto

server.crt server.key:
	./scripts/generate_server_cert.sh

client.crt client.key:
	./scripts/generate_client_cert.sh

.PHONY: protos
protos: pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go

.PHONY: server-cert
server-certs: server.crt server.key

.PHONY: client-cert
client-certs: client.crt client.key

.PHONY: cert-check
cert-check:
	openssl s_client -connect localhost:50051 2>/dev/null | openssl x509 -text

fmt:
	gofmt -s -w .
