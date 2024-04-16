export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_PENGUSAHA_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/peers/peer0.pengusaha.example.com/tls/ca.crt
export PEER0_BPJH_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/bpjh.example.com/peers/peer0.bpjh.example.com/tls/ca.crt
export PEER0_LPH_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/lph.example.com/peers/peer0.lph.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForPeer0Pengusaha(){
    export CORE_PEER_LOCALMSPID="PengusahaMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PENGUSAHA_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/pengusaha.example.com/users/Admin@pengusaha.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer0Bpjh(){
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

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0Pengusaha
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.example.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-PENGUSAHA/*
    rm -rf ./api-2.0/pengusaha-wallet/*
    rm -rf ./api-2.0/bpjh-wallet/*
    rm -rf ./api-2.0/lph-wallet/*
}


joinChannel(){
    setGlobalsForPeer0Pengusaha
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    
    setGlobalsForPeer0Bpjh
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Lph
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Pengusaha
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Bpjh
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

    setGlobalsForPeer0Lph
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

removeOldCrypto

createChannel
joinChannel
updateAnchorPeers