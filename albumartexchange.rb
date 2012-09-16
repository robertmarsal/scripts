# searches albumartexchange and downloads all 600x600 px covers
# based on the passed query

require 'rubygems'
require 'mechanize'

class AlbumArtExchange
  @@base_url = 'http://www.albumartexchange.com'
  def initialize
    @agent = Mechanize.new
    @agent.robots = false
    @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.57 Safari/536.11'
  end

  def covers(query)
    url = @@base_url+'/covers.php?q='+query.gsub(' ', '+')
    page = @agent.get(url)
    ids = Array.new

    #only 600x600 covers
    page.links.each do |link|
      if link.href =~ /\?id=\d*&q=/ && link.text =~ /600/
        ids << link.href[4..9]
      end
    end

    #download all found covers
    ids.each do |id|
      img_page = @agent.get(@@base_url+'/covers.php?id='+id, [] , @@base_url)

      img_page.links.each do |img|
        if img.text =~ /600/
          file = @agent.get(@@base_url+img.href, [] , @@base_url+'/covers.php?id='+id)
          file.save
        end
      end
    end
  end
end

ArtProvider = AlbumArtExchange.new
ArtProvider.covers(ARGV[0])