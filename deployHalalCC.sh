export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_PENGUSAHA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/ca.crt
export PEER0_BPJH_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/ca.crt
export PEER0_LPH_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Pengusaha() {
    export CORE_PEER_LOCALMSPID="PengusahaMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PENGUSAHA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/users/Admin@pengusaha.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPengusaha() {
    export CORE_PEER_LOCALMSPID="PengusahaMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PENGUSAHA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/users/User1@pengusaha.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Bpjh() {
    export CORE_PEER_LOCALMSPID="BpjhMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BPJH_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bpjh.example.com/users/Admin@bpjh.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer0Lph(){
    export CORE_PEER_LOCALMSPID="LphMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_LPH_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/lph.example.com/users/Admin@lph.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
    
}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/halal_cc/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
SEQUENCE=1
CC_SRC_PATH="./artifacts/src/github.com/halal_cc/go"
CC_NAME="halal_cc"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.pengusaha ===================== "

    setGlobalsForPeer0Bpjh
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.bpjh ===================== "

    setGlobalsForPeer0Lph
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.lph ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.pengusaha on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('PengusahaMSP.member','BpjhMSP.member')" \

approveForMyPengusaha() {
    setGlobalsForPeer0Pengusaha
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}
# queryInstalled
# approveForMyPengusaha

# --signature-policy "OR ('PengusahaMSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA
# --peerAddresses peer0.pengusaha.example.com:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA --peerAddresses peer0.bpjh.example.com:9051 --tlsRootCertFiles $PEER0_BPJH_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('PengusahaMSP.peer','BpjhMSP.peer')"

checkCommitReadyness() {
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyBpjh() {
    setGlobalsForPeer0Bpjh

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyBpjh

checkCommitReadyness() {

    setGlobalsForPeer0Bpjh
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyLph() {
    setGlobalsForPeer0Lph

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyLph

checkCommitReadyness() {

    setGlobalsForPeer0Lph
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_LPH_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA \
        --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_LPH_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Pengusaha
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Pengusaha
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA \
         --peerAddresses localhost:11051 --tlsRootCertFiles $PEER0_LPH_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Pengusaha

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA   \
        -c '{"function": "CreateSertifikatHalal","Args":["{\"id\":\"20\",\"perusahaan\":\"icetea\",\"addedAt\":1600138309939,\"nama\":\"Alice Corp\",\"nib\":\"097283834\",\"produk\":\"Es Teh\",\"alamat\":\"Samping Bara\",\"data\":{\"harga-pendaftaran\":\"10000\",\"pengecekan-oleh-majelis\":\"true\"},\"status\":\"Pengajuan Sertifikat\"}"]}'

}

# chaincodeInvoke

chaincodeInvokeDeleteAsset() {
    setGlobalsForPeer0Pengusaha

    # Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.example.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_PENGUSAHA_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_BPJH_CA   \
        -c '{"function": "DeleteCarById","Args":["2"]}'

}

# chaincodeInvokeDeleteAsset

chaincodeQuery() {
    setGlobalsForPeer0Pengusaha
    # setGlobalsForPengusaha
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetSertifikatHalalById","Args":["20"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode
queryInstalled
approveForMyPengusaha
checkCommitReadyness
approveForMyBpjh
checkCommitReadyness
approveForMyLph
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
