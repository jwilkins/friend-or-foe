require 'geocoder'
require 'whois'
require 'debugger'
require 'netaddr'
require 'net/dns'

class IPInfo
  def self.ip_to_geo(ip)
    geoinfo = Geocoder.search(ip)
    res = []
    geoinfo.each { |geo|
      res << "#{geo.data['latitude']}, #{geo.data['longitude']}"
      res << "#{geo.data['city']}, #{geo.data['region_name']}, "\
      "#{geo.data['country_name']}"
    }
    res.join("\n")
  end

  def self.whois(ip)
    who = Whois.query(ip)
    puts who
  end
end


if $0 == __FILE__
  target = ARGV[0] || '4.2.2.4'
  puts "#{target}:"
  puts "GeoIP: #{IPInfo.ip_to_geo(target)}"
  puts "Whois: #{IPInfo.whois(target)}"
end