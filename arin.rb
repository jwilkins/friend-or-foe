require 'httparty'

class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'

  def self.block(ip)
    response = ARIN.get("/ip/#{ip}")
    #debugger
    blocks = response['net']['netBlocks']
    "#{blocks['netBlock']['startAddress']}/#{blocks['netBlock']['cidrLength']}"
  end

  def self.owner(ip)
    response = ARIN.get("/ip/#{ip}")
    orgref = response['net']['orgRef']
    "#{orgref['name']} (#{orgref['handle']})"
  end
end

if $0 == __FILE__
  target = ARGV[0] || '4.2.2.4'
  puts "#{target}:"
  puts "arin.block: #{ARIN.block(target)}"
  puts "arin.owner: #{ARIN.owner(target)}"
end
