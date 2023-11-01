package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"log"
	"os"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"

	echopb "github.com/zhiyanfoo/http2-tls/pkg/pb/echo"
)

const (
	name = "servername.com"
)

func main() {
	caCert, err := os.ReadFile("cert/server.crt")
	if err != nil {
		log.Fatalf("could not load CA cert: %s", err)
	}

	cp := x509.NewCertPool()
	if !cp.AppendCertsFromPEM(caCert) {
		log.Fatalf("failed to append certificates")
	}

	config := &tls.Config{
		InsecureSkipVerify: true,
		// https://pkg.go.dev/crypto/tls#example-Config-VerifyConnection
		VerifyConnection: func(cs tls.ConnectionState) error {
			opts := x509.VerifyOptions{
				DNSName:       "servername.com",
				Intermediates: x509.NewCertPool(),
				Roots: cp,
			}
			for _, cert := range cs.PeerCertificates[1:] {
				opts.Intermediates.AddCert(cert)
			}
			_, err := cs.PeerCertificates[0].Verify(opts)
			return err
		},
	}

	creds := credentials.NewTLS(config)

	conn, err := grpc.Dial("server:50051",
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

	ticker := time.NewTicker(2 * time.Second)

	done := make(chan bool)

	go func() {
		for {
			select {
			case <-done:
				return
			case <-ticker.C:
				r, err := c.Echo(context.Background(), &echopb.EchoRequest{Message: message})
				if err != nil {
					log.Printf("could not echo: %v", err)
					continue
				}
				log.Printf("Server says: %s", r.Message)
			}
		}
	}()

	time.Sleep(10 * time.Second)
	ticker.Stop()
	done <- true

	fmt.Println("Finished")

}

func customCheck(cert *x509.Certificate, host string) error {
	for _, sans := range cert.DNSNames {
		if sans == host {
			return nil
		}
	}

	return errors.New("no valid SANs found")
}
