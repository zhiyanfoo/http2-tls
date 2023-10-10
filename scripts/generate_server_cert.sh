#!/bin/bash

# Create the cert directory if it doesn't exist
mkdir -p cert

# req: OpenSSL command to create a new certificate or a certificate signing request
# -x509: This option outputs a self signed certificate instead of a certificate request.
# -newkey rsa:4096: This option creates a new certificate request and a new private key. The argument takes one of several forms. rsa:nbits, where nbits is the number of bits, generates an RSA key nbits in size.
# -keyout: This gives the filename to write the newly created private key to.
# -out: This specifies the output filename to write to or standard output by default.
# -days 365: when the -x509 option is being used this specifies the number of days to certify the certificate for. The default is 30 days.
# -nodes: if this option is specified then if a private key is created it will not be encrypted.
# -config openssl.cnf: this allows an alternative configuration file to be specified, this file will be used in preference to the default one.
# -extensions req_ext required to ensure openssl uses the altsan extension
# -batch: this option will prevent openssl from prompting for the values of the distinguished name fields and use the default values specified in the openssl.cnf file instead.
openssl req \
  -x509 \
  -newkey rsa:4096 \
  -keyout cert/server.key \
  -out cert/server.crt \
  -days 365 \
  -nodes \
  -config scripts/openssl.cnf \
  -extensions req_ext \
  -batch
