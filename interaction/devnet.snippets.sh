PROXY=https://devnet-gateway.elrond.com
CHAIN_ID="D"

# WALLET="./wallets/test-wallet2.pem"
WALLET="~/hackathon.pem"

MY_ADDRESS=erd1man0h5zzj2ta8xju3vt4keqe5qdel95qe4k93dv4arzyfrkjj8dqj6yynt
MY_ADDRESS_HEX="$(erdpy wallet bech32 --decode ${MY_ADDRESS})"

#######################################################
ADDRESS=$(erdpy data load --key=address-devnet)
# ADDRESS=$(erdpy data load --key=address-devnet-2)
#######################################################

COLLECTION_NAME="WQITEMS"
COLLECTION_NAME_HEX="0x$(echo -n ${COLLECTION_NAME} | xxd -p -u | tr -d '\n')"
COLLECTION_TIKER="WQITEMS"
COLLECTION_TIKER_HEX="0x$(echo -n ${COLLECTION_TIKER} | xxd -p -u | tr -d '\n')"

TOTAL_NUMBER_OF_NFTS=500

CID="QmU28G8PJ31wEf9AtFCKjSKtVF3ptqREn6Jf6UeEJGH73X"
CID_HEX="0x$(echo -n ${CID} | xxd -p -u | tr -d '\n')"

MINT_EGLD_VALUE=1000000000000000000 # 1 EGLD

NUMBER_OF_NFTS_TO_MINT=05
REF_PERCENT=02
DISCOUNT_PERCENT=05

image_base_cid: ManagedBuffer,
metadata_base_cid: ManagedBuffer,
amount_of_tokens: u32,
tokens_limit_per_address: u32,
royalties: BigUint,
selling_price: BigUint,
file_extension: OptionalValue <ManagedBuffer >,
tags: OptionalValue <ManagedBuffer >,
provenance_hash: OptionalValue <ManagedBuffer >,
is_metadata_in_uris: OptionalValue <bool >,

IMAGE_CID=""
METADATA_CID=""
AMOUNT_OF_TOKENS=10000
TOKENS_LIMIT_PER_ADDRESS=10000
ROYALTIES=0
SELLING_PRICE=0
FILE_EXTENSION=".png"
FILE_EXTENSION_HEX="0x$(echo -n ${FILE_EXTENSION} | xxd -p -u | tr -d '\n')"

PAYMENT_TOKEN_ID="LKLAND-516da7"
PAYMENT_TOKEN_ID_HEX="$(echo -n ${PAYMENT_TOKEN_ID} | xxd -p -u | tr -d '\n')"
PAYMENT_TOKEN_AMOUNT=710000000000000000000 # 533 LAND

MINT_RANDOM="$(echo -n mintRandom | xxd -p -u | tr -d '\n')"
MINT_SPECIFIC="$(echo -n mintSpecificNft | xxd -p -u | tr -d '\n')"
MAX_PER_TX=32

deploy() {
    erdpy --verbose contract deploy \
        --project=${PROJECT} --pem=${WALLET} --recall-nonce --send --proxy=${PROXY} --chain=${CHAIN_ID} \
        --outfile="deploy-devnet.interaction.json" \
        --arguments ${CID_HEX} ${CID_HEX} ${AMOUNT_OF_TOKENS} ${TOKENS_LIMIT_PER_ADDRESS} ${ROYALTIES} ${SELLING_PRICE} ${FILE_EXTENSION_HEX} \
        --metadata-payable --gas-limit=100000000

    ADDRESS=$(erdpy data parse --file="deploy-devnet.interaction.json" --expression="data['contractAddress']")
    erdpy data store --key=address-devnet --value=${ADDRESS}

    echo ""
    echo "Smart contract address: ${ADDRESS}"
}
upgrade() {
    erdpy --verbose contract upgrade ${ADDRESS} --project=${PROJECT} \
        --recall-nonce --pem=${WALLET} --gas-limit=100000000 --send \
        --outfile="upgrade.json" --proxy=${PROXY} --chain=${CHAIN_ID} \
        --metadata-payable \
        --arguments ${CID_HEX} ${CID_HEX} ${AMOUNT_OF_TOKENS} ${TOKENS_LIMIT_PER_ADDRESS} ${ROYALTIES} ${SELLING_PRICE} ${FILE_EXTENSION_HEX}

}

issueToken() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="issueToken" \
        --value 50000000000000000 \
        --arguments ${COLLECTION_NAME_HEX} ${COLLECTION_TIKER_HEX}
}

setLocalRoles() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setLocalRoles"
}

whitelist() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="whitelist" \
        --arguments=0x${MY_ADDRESS_HEX}
}

changeBaseCids() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="changeBaseCids" \
        --arguments ${CID_HEX} ${CID_HEX}
}

setRefPercent() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setRefPercent" \
        --arguments ${REF_PERCENT}
}

setTotalAssetsAmount() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setTotalAssetsAmount" \
        --arguments 0x01
}

setDiscountPercent() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setDiscountPercent" \
        --arguments ${DISCOUNT_PERCENT}
}

populateIndexes() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=600000000 \
        --function="populateIndexes" \
        --arguments ${TOTAL_NUMBER_OF_NFTS}
    sleep 1

}

setCid() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setCid" \
        --arguments ${CID_HEX}
}

depopulateIndexes() {

    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=600000000 \
        --function="depopulateIndexes"

}

setPrice() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setPrice" \
        --arguments 0x${PAYMENT_TOKEN_ID_HEX} ${PAYMENT_TOKEN_AMOUNT}
}

setSpecificPrice() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=50000000 \
        --function="setSpecificPrice" \
        --arguments 0x${PAYMENT_TOKEN_ID_HEX} ${PAYMENT_TOKEN_AMOUNT}
}

setMaxPerTx() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="setMaxPerTx" \
        --arguments ${MAX_PER_TX}
}

pause() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --function="pause"
}

mintRandomNft() {
    erdpy --verbose contract call ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --function="mintRandom" \
        --gas-limit=100000000
}

mintSpecificNft() {
    erdpy --verbose tx new --receiver ${ADDRESS} --send --proxy=${PROXY} --chain=${CHAIN_ID} --recall-nonce --pem=${WALLET} \
        --gas-limit=100000000 \
        --data="ESDTTransfer@${PAYMENT_TOKEN_ID_HEX}@016345785d8a0000@${MINT_SPECIFIC}@01103E"
}

getSftPrice() {
    erdpy --verbose contract query ${ADDRESS} --proxy=${PROXY} --function="getSftPrice" --arguments ${CALLER_ADDRESS_HEX} 1
}

getWhitelist() {
    erdpy --verbose contract query ${ADDRESS} --proxy=${PROXY} --function="getWhitelist" --arguments 0x${MY_ADDRESS_HEX}
}

getSpecificSftPrice() {
    erdpy --verbose contract query ${ADDRESS} --proxy=${PROXY} --function="getSpecificSftPrice" --arguments ${CALLER_ADDRESS_HEX} 1
}
