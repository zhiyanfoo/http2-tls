package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"os"
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"

	echopb "github.com/zhiyanfoo/http2-tls/pkg/pb/echo"
)

const (
	name = "servername.com"
)
func main() {
	cert, err := tls.LoadX509KeyPair("cert/client.crt", "cert/client.key")
	if err != nil {
		log.Fatalf("Failed to load key pair: %v", err)
	}

	config := &tls.Config{
		ServerName: name,
		Certificates:       []tls.Certificate{cert},
	}

	creds := credentials.NewTLS(config)

	conn, err := grpc.Dial("localhost:50051",
		grpc.WithTransportCredentials(creds),
		grpc.WithAuthority(name),
	)
	if err != nil {
		log.Fatalf("did not connect: %v", err)
	}
	defer conn.Close()

	c := echopb.NewEchoServiceClient(conn)

	message := "Hello, World!"
	if len(os.Args) > 1 {
		message = os.Args[1]
	}

	r, err := c.Echo(context.Background(), &echopb.EchoRequest{Message: message})
	if err != nil {
		log.Fatalf("could not echo: %v", err)
	}

	log.Printf("Server says: %s", r.Message)
}

func customCheck(cert *x509.Certificate, host string) error {
    for _, sans := range cert.DNSNames {
        if sans == host {
            return nil
        }
    }

    return errors.New("no valid SANs found")
}
