require 'mechanize'
require 'httparty'
require 'json'
require 'yaml'
require 'debugger'

class WOT
  include HTTParty
  base_uri 'api.mywot.com'

  def self.lookup(hosts)
    config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))
    scores = JSON.parse(WOT.get("/0.4/public_link_json2?hosts=#{hosts.join('/')}&key=#{config['WOT_API_KEY']}"))
    scores.keys.each { |sk|
      puts "#{WOT.score_to_s(scores[sk])}"
    }
  end

  def self.score_to_s(score)
    res = []
    desc = {'0' => 'Trustworthiness', '1' => 'Vendor Reliability', '2' => 'Privacy', '4' => 'Child Safety'}
    return "error" unless score['target']
    res = [score['target']]
    %w(0 1 2 4).each { |sk|
      res << "  #{desc[sk]}: #{score[sk]}" if score[sk]
    }
    res.join("\n")
  end
end

if $0 == __FILE__
  WOT.lookup(%w(google.com exploit-db.com thepiratebay.se))
end

