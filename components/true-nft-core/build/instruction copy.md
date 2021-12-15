# Generate addr and key
tonos-cli genaddr uploadDeGeneratice.tvc uploadDeGenerative.abi.json --genkey main.keys.json

# Send money to upload deGenerative 
sudo tonos-cli --url net.ton.dev call 0:653b9a6452c7a982c6dc92b2da9eba832ade1c467699ebb3b43dca6d77b780dd grant "{\"addr\":\"ADDRESS OF degenerative\"}" --abi grant.abi.json

# Deploy uploadDeGenerative
tonos-cli --url net.ton.dev deploy uploadDeGeneratice.tvc "{}" --sign main.keys.json --abi uploadDeGenerative.abi.json

# Get code index and code data 
tvm_linker decode --tvc NftRoot.tvc  > nftroot.txt
tvm_linker decode --tvc Index.tvc > index.txt


# Deploy true nft 
tonos-cli --url net.ton.dev deploy NftRoot.tvc --data "{_addrOwner:'address of uploadDeGenerative',_name:'YourNameInHex'}" "{codeIndex:'code nft root',codeData:'code index',pay:123,koef:123}" --sign main.keys.json --abi NftRoot.abi.json

# Send money to true nft  
sudo tonos-cli --url net.ton.dev call 0:653b9a6452c7a982c6dc92b2da9eba832ade1c467699ebb3b43dca6d77b780dd grant "{\"addr\":\"ADDRESS OF root nft\"}" --abi grant.abi.json

# Upload metadata 
tonos-cli --url net.ton.dev call ADDRESSOFDEGENERATIVE sendMetadata "{\"adr\":\"address of true nft\",\"metadata\":\"metadata bytes\"}" --sign main.keys.json --abi uploadDeGenerative.abi.json

# Finish 
tonos-cli --url net.ton.dev call ADDRESSOFDEGENERATIVE startSelling "{\"adr\":\"address of true nft\"}" --sign main.keys.json --abi uploadDeGenerative.abi.json

# And now any body can mint nft with special sum if they want