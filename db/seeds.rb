require 'json'
require 'open-uri'
require 'nokogiri'

result = JSON.parse(open('http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list').read)
drinks = result['drinks']
drinks.each do |hash|
  hash.each do |k, v|
    Ingredient.create!(name: v)
  end
end

    html_content = 'https://www.cocktailicious.nl/index-cocktails/'
    cocktail_titles = []
    html_file = open(html_content).read
    html_doc = Nokogiri::HTML(html_file)
    html_doc.search('.elementor-post').each do |element|
      name = element.search(".elementor-post__title").text.strip
      picture_path = element.search(".elementor-post__thumbnail__link img").attr("src").value
      p picture_path
      # p name
      # p picture_path.doc.attr('src').value
      # p picture_path.xpath('//div/@src')

      # image_array = []
      # html_doc.search('.attachment-medium').each do |element|
      #   image_array << element.attr('src')
      #   new_array = image_array.each_with_index.map{|url, index| url if index % 2 == 0}
      # end
      # p image_array
      Cocktail.create(name: element.text.strip)
    end
