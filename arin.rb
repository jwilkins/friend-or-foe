require 'httparty'
require 'debugger'

class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
  Cache = {:ip => {},
           :net => {},
           :org_pocs => {},
           :noc => {},
           :pocs => {}}

  def self.block(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    blocks = Cache[:ip][ip]['net']['netBlocks']
    "#{blocks['netBlock']['startAddress']}/#{blocks['netBlock']['cidrLength']}"
  end

  def self.handle(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    Cache[:ip][ip]['net']['handle']
  end

  def self.owner(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    orgref = Cache[:ip][ip]['net']['orgRef']
    "#{orgref['name']} (#{orgref['handle']})"
  end

  def self.name(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    Cache[:ip][ip]['net']['name']
  end

  def self.registered(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    Cache[:ip][ip]['net']['registrationDate']
  end

  def self.noc(ip)
    Cache[:ip][ip] ||= ARIN.get("/ip/#{ip}")
    handle = Cache[:ip][ip]['net']['orgRef']['handle']
    return Cache[:noc][handle] if Cache[:noc][handle]
    Cache[:org_pocs][handle] ||= ARIN.get("/org/#{handle}/pocs")
    Cache[:org_pocs][handle]['pocs']['pocLinkRef'].each { |lr|
      if lr['function'] === 'N'
        poc_handle = lr['handle']
        noc = ARIN.get("/poc/#{poc_handle}")
        return Cache[:noc][handle] = "#{noc['poc']['phones']['phone']['number']} #{noc['poc']['emails']['email']}"
      end
    }
    "unavailable"
  end
end

if $0 == __FILE__
  target = ARGV[0] || '4.2.2.4'
  puts "#{target}:"
  puts "arin.block: #{ARIN.block(target)}"
  puts "arin.owner: #{ARIN.owner(target)}"
  puts "arin.name : #{ARIN.name(target)}"
  puts "arin.registered: #{ARIN.registered(target)}"
  puts "arin.noc: #{ARIN.noc(target)}"
end
