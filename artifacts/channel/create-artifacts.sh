
# Delete existing artifacts
rm genesis.block mychannel.tx
rm -rf ../../channel-artifacts/*

#Generate Crypto artifactes for organizations
# cryptogen generate --config=./crypto-config.yaml --output=./crypto-config/



# System channel
SYS_CHANNEL="sys-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

echo $CHANNEL_NAME

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./genesis.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

echo "#######    Generating anchor peer update for PengusahaMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./PengusahaMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PengusahaMSP

echo "#######    Generating anchor peer update for BpjhMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./BpjhMSPanchors.tx -channelID $CHANNEL_NAME -asOrg BpjhMSP

echo "#######    Generating anchor peer update for LphMSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./LphMSPanchors.tx -channelID $CHANNEL_NAME -asOrg LphMSP
