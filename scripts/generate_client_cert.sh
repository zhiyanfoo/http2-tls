#!/bin/bash

# Create the cert directory if it doesn't exist
mkdir -p cert

# req: OpenSSL command to create a new certificate or a certificate signing request
# -new: This option generates a new certificate request. It also creates a new private key.
# -newkey rsa:4096: This option creates a new certificate request and a new private key. The argument takes one of several forms. rsa:nbits, where nbits is the number of bits, generates an RSA key nbits in size.
# -keyout: This gives the filename to write the newly created private key to.
# -out: This specifies the output filename to write to or standard output by default.
# -nodes: if this option is specified then if a private key is created it will not be encrypted.
# -config scripts/openssl.cnf: this allows an alternative configuration file to be specified, this file will be used in preference to the default one.
# -batch: this option will prevent openssl from prompting for the values of the distinguished name fields and use the default values specified in the openssl.cnf file instead.
openssl req \
  -new \
  -newkey rsa:4096 \
  -keyout cert/client.key \
  -out cert/client.csr \
  -nodes \
  -config scripts/openssl.cnf \
  -batch

# x509: OpenSSL command to display certificate information, convert certificates to different formats, sign certificate request, etc.
# -req: by default, a certificate is expected on input. With this option, a certificate request is expected instead.
# -in: this specifies the input filename to read a request from or standard input if this option is not specified.
# -CA: specifies the CA certificate to be used for signing. When used with the -signkey option the argument is a file containing the CA certificate and private key.
# -CAkey: specifies the CA private key to be used for signing. If this option is not specified then the CA certificate file should also contain the private key.
# -CAcreateserial: with this option the CA serial number file is created if it does not exist: it will contain the serial number "02" and the certificate being signed will have the 1 as its serial number.
# -out: this specifies the output filename to write to or standard output by default.
# -days 365: when the -x509 option is being used this specifies the number of days to certify the certificate for. The default is 30 days.
openssl x509 \
  -req \
  -in cert/client.csr \
  -CA cert/server.crt \
  -CAkey cert/server.key \
  -CAcreateserial \
  -out cert/client.crt \
  -days 365
