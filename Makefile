.PHONY: server client proto

server: pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	go run cmd/server/main.go

client: pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go
	go run cmd/client/main.go

pkg/pb/echo/echo.pb.go pkg/pb/echo/echo_grpc.pb.go:
	protoc --go_out=. --go_opt=module=github.com/zhiyanfoo/http2-tls \
		--go_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		--go-grpc_out=. --go-grpc_opt=module=github.com/zhiyanfoo/http2-tls \
		--go-grpc_opt=Mproto/echo.proto=github.com/zhiyanfoo/http2-tls/pkg/pb/echo \
		proto/echo.proto


.PHONY: cert-check
cert-check:
	openssl s_client -connect localhost:50051 2>/dev/null | openssl x509 -text
