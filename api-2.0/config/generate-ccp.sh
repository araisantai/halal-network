#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}

ORG=Pengusaha
P0PORT=7051
CAPORT=7054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/tlscacerts/tls-localhost-7054-ca-pengusaha-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM )" > connection-pengusaha.json

ORG=Bpjh
P0PORT=9051
CAPORT=8054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/tlscacerts/tls-localhost-8054-ca-bpjh-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/bpjh.example.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-bpjh.json

ORG=Lph
P0PORT=11051
CAPORT=10054
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/tlscacerts/tls-localhost-10054-ca-lph-example-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/lph.example.com/msp/tlscacerts/ca.crt


echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-lph.json