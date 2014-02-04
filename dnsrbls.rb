#!/usr/bin/env ruby
# DNS Realtime Black List
require 'resolv'
require 'parallel'

class DNSRBL
  begin
    Servers = File.open(File.join(File.dirname(__FILE__), 'dnsrbl-list.txt')).readlines
  rescue => e
    puts "Error: #{e}"
    exit(-1)
  end

  def self.check(ip, threads=20, debug=false)
    hits = []
    timeouts = []
    lookup = ip.split('.').reverse.join('.')
    puts "Checking blacklists for #{ip} as #{lookup} ..." if debug
    Parallel.each(Servers, :in_threads => threads){ |server|
      begin
        host = "#{lookup}.#{server.strip}"
        Resolv::getaddress(host)
        printf("%-50s: \e[0;31mLISTED on %s\e[0m\n", host, server) if debug
        hits << server.strip
      rescue Resolv::ResolvError => e
        printf("%-50s: \e[0;32mOK\e[0m\n", host) if debug
      rescue Interrupt => e
        puts "\nCaught signal SIGINT. Exiting..."
        exit
      rescue => e
        printf("%-50s: \e[0;47mTIMEOUT\e[0m\n", host) if debug
        timeouts << server.strip
      end
    }

    return hits, timeouts
  end
end

if $0 == __FILE__
  begin
    targets = ['4.2.2.4']
    targets = ARGV if ARGV.length > 0
    targets.each { |target|
      hits, timeouts = DNSRBL.check(target, 20, true)
      if hits.size > 0
        printf "#{target} is listed on the following #{hits.size} blacklists\n\n"
        puts hits.join
      else
        puts "#{target} was not found on any blacklists."
      end
      if timeouts.size > 0
        printf "The following #{timeouts.size} blacklists timed out\n\n"
        puts timeouts.join
      end
    }
  rescue => e
    puts "#{e}"
  end
end
