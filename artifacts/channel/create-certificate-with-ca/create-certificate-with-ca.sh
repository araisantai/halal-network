createcertificatesForPengusaha() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.pengusaha.example.com --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-pengusaha-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-pengusaha-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-pengusaha-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-pengusaha-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.pengusaha.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.pengusaha.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.pengusaha.example.com --id.name pengusahaadmin --id.secret pengusahaadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.pengusaha.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/msp --csr.hosts peer0.pengusaha.example.com --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.pengusaha.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls --enrollment.profile tls --csr.hosts peer0.pengusaha.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/tlsca/tlsca.pengusaha.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/ca/ca.pengusaha.example.com-cert.pem

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/users/User1@pengusaha.example.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.pengusaha.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/users/User1@pengusaha.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/pengusaha.example.com/users/Admin@pengusaha.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://pengusahaadmin:pengusahaadminpw@localhost:7054 --caname ca.pengusaha.example.com -M ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/users/Admin@pengusaha.example.com/msp --tls.certfiles ${PWD}/fabric-ca/pengusaha/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/pengusaha.example.com/users/Admin@pengusaha.example.com/msp/config.yaml

}

# createcertificatesForpengusaha

createCertificatesForBpjh() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/bpjh.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.bpjh.example.com --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bpjh-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bpjh-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bpjh-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-bpjh-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.bpjh.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.bpjh.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.bpjh.example.com --id.name bpjhadmin --id.secret bpjhadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/bpjh.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.bpjh.example.com -M ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/msp --csr.hosts peer0.bpjh.example.com --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.bpjh.example.com -M ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls --enrollment.profile tls --csr.hosts peer0.bpjh.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/tlsca/tlsca.bpjh.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/ca/ca.bpjh.example.com-cert.pem

  # --------------------------------------------------------------------------------
 
  mkdir -p ../crypto-config/peerOrganizations/bpjh.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/bpjh.example.com/users/User1@bpjh.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.bpjh.example.com -M ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/users/User1@bpjh.example.com/msp --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/bpjh.example.com/users/Admin@bpjh.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://bpjhadmin:bpjhadminpw@localhost:8054 --caname ca.bpjh.example.com -M ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/users/Admin@bpjh.example.com/msp --tls.certfiles ${PWD}/fabric-ca/bpjh/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/bpjh.example.com/users/Admin@bpjh.example.com/msp/config.yaml

}

# createCertificateForbpjh

createCertificatesForLph() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/lph.example.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca.lph.example.com --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-lph-example-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-lph-example-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-lph-example-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-lph-example-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/lph.example.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.lph.example.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.lph.example.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.lph.example.com --id.name lphadmin --id.secret lphadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/peers
  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.lph.example.com -M ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/msp --csr.hosts peer0.lph.example.com --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca.lph.example.com -M ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls --enrollment.profile tls --csr.hosts peer0.lph.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/lph.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/lph.example.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/tlsca/tlsca.lph.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/lph.example.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/lph.example.com/ca/ca.lph.example.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/users
  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/users/User1@lph.example.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca.lph.example.com -M ${PWD}/../crypto-config/peerOrganizations/lph.example.com/users/User1@lph.example.com/msp --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/lph.example.com/users/Admin@lph.example.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://lphadmin:lphadminpw@localhost:10054 --caname ca.lph.example.com -M ${PWD}/../crypto-config/peerOrganizations/lph.example.com/users/Admin@lph.example.com/msp --tls.certfiles ${PWD}/fabric-ca/lph/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/lph.example.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/lph.example.com/users/Admin@lph.example.com/msp/config.yaml

}

createCretificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/example.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers
  # mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/example.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls --enrollment.profile tls --csr.hosts orderer2.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p ../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls --enrollment.profile tls --csr.hosts orderer3.example.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p ../crypto-config/ordererOrganizations/example.com/users
  mkdir -p ../crypto-config/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/example.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf ../crypto-config/*
# sudo rm -rf fabric-ca/*
createcertificatesForPengusaha
createCertificatesForBpjh
createCertificatesForLph

createCretificatesForOrderer

