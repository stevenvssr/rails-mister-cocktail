require 'open-uri'
require 'nokogiri'

index_url = "https://cocktailicious.nl/index-cocktails/"
html = URI.open(index_url).read
doc = Nokogiri::HTML(html)

cocktail_links = doc.css('a').map { |a| a['href'] }.compact.uniq.select { |url| url.include?('/') && !url.include?('blogs') }

puts "Found #{cocktail_links.count} cocktail pages"
cocktail_links.each_with_index do |url, i|
  puts "#{i+1}: #{url}"
end
