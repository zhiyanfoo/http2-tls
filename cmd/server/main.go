package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"

	echopb "github.com/zhiyanfoo/http2-tls/pkg/pb/echo"
)

type server struct {
	echopb.UnimplementedEchoServiceServer
}

func (s *server) Echo(ctx context.Context, in *echopb.EchoRequest) (*echopb.EchoResponse, error) {
	return &echopb.EchoResponse{Message: in.Message}, nil
}

func main() {
	creds, err := credentials.NewServerTLSFromFile("cert/server.crt", "cert/server.key")
	if err != nil {
		log.Fatalf("Failed to generate credentials %v", err)
	}

	addr := "0.0.0.0:50051"
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer(grpc.Creds(creds))
	echopb.RegisterEchoServiceServer(s, &server{})

	log.Printf("Server is running at %s\n", addr)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
