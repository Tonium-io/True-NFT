set -e

# tos=./tonos-cli
# if test -f "$tos"; then
#     echo "$tos exists."
# else
#     echo "$tos not found in current directory. Please, copy it here and rerun script."
#     exit
# fi

DEBOT_NAME=debot
giver=0:65823528df743defb0a19f231b428de8c59440f8523475869dfdc0e71351010f
function giver {
tonos-cli --url https://net.ton.dev call --abi ./local_giver.abi.json $giver grant "{\"addr\":\"$1\"}"
}
function get_address {
echo $(cat log.log | grep "Raw address:" | cut -d ' ' -f 3)
}
function genaddr {
tonos-cli genaddr $1.tvc $1.abi.json --genkey $1.keys.json > log.log
}

LOCALNET=http://gql.custler.net
DEVNET=https://net.ton.dev
MAINNET=https://main.ton.dev
NETWORK=$LOCALNET

echo GENADDR DEBOT
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address)

echo ASK GIVER
giver $DEBOT_ADDRESS
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)
#ICON_BYTES=$(base64 -w 0 hellodebot.png)
#ICON=$(echo -n "data:image/png;base64,$ICON_BYTES" | xxd -ps -c 20000)

echo DEPLOY DEBOT $DEBOT_ADDRESS
tonos-cli --url $NETWORK deploy $DEBOT_NAME.tvc "{}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
tonos-cli --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json
#tonos-cli --url $NETWORK call $DEBOT_ADDRESS setIcon "{\"icon\":\"$ICON\"}" --sign $DEBOT_NAME.keys.json --abi $DEBOT_NAME.abi.json

echo DONE
echo $DEBOT_ADDRESS > address.log
echo debot $DEBOT_ADDRESS