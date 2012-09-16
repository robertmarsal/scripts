# searches the Tarragona public library books list
# for the passed book or author parameter

require 'rubygems'
require 'mechanize'

class Argus
  @@base_url = 'http://argus.biblioteques.gencat.cat/iii/encore/search/C|S'
  @@option_text_only = '|Ff:facetmediatype:a:a:MAT%252BTEXTUAL::'
  @@option_tarragona = '|Ff:facetcollections:124:124:TARRAGONA-P%2525C3%2525BAblica%252Bde%252BTarragona::'
  @@option_spanish = '|Ff:facetlanguages:spa:spa:Spanish::'
  def initialize
    @agent = Mechanize.new
    @agent.user_agent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'
  end

  def search(query)
    url = @@base_url+query.gsub(' ', '+')+@@option_text_only+@@option_tarragona+@@option_spanish
    page = @agent.get(url)

    #get page count
    count = page.parser.xpath("//div[@class='pagination1']/a").count
    count == 0 ? count = 1 : nil #if it only has one page

    #search for all the pages
    books = Hash.new
    page = 0
    while page < count
      newbooks = self.get_page(query, page)
      #merge into main array
      books = books.merge(newbooks){|key, first, second| first.to_i + second.to_i }
      page = page + 1
    end

    #sort the books
    books = books.sort
    #display the books
    books.each do |book|
      if book[1].to_i != 1
        puts "#{book[0]} x#{book[1]}"
      else
        puts "#{book[0]}"
      end
    end

  end

  def get_page (query, page)
    url = @@base_url+query.gsub(' ', '+')+@@option_text_only+@@option_tarragona+@@option_spanish+'|P'+page.to_s
    page = @agent.get(url)

    #fetch the content
    books = Hash.new
    page.links.each do |link|
      if link.attributes['id'] =~ /recordDisplayLink2Component/
        key = link.text.strip

        if books.has_key?(key)
          books[key] = books[key].to_i + 1
        else
          books[key] = 1
        end

      end
    end

    return books
  end

end

Library = Argus.new
Library.search(ARGV[0])