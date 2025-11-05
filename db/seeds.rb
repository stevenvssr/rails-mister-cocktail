require 'nokogiri'
require 'open-uri'

BASE_URL = "https://cocktailicious.nl"

puts "Fetching cocktail index..."
index_doc = Nokogiri::HTML(URI.open("#{BASE_URL}/index-cocktails/"))

cocktail_links = index_doc.css('h3.ultp-block-title a').map { |a| a['href'] }.uniq
puts "Found #{cocktail_links.count} cocktails."

cocktail_links.each_with_index do |url, index|
  puts "Processing #{index + 1}/#{cocktail_links.count}: #{url}"

  begin
    doc = Nokogiri::HTML(URI.open(url))
    name = doc.css('h1.post-title').text.strip
    description = doc.css('.post-content p').map(&:text).join("\n").strip

    # Create cocktail
    cocktail = Cocktail.create!(name: name, description: description)

    # Attach image
    img_url = doc.at_css('figure.post-thumbnail img')['src']
    downloaded_image = URI.open(img_url)
    cocktail.image.attach(io: downloaded_image, filename: File.basename(img_url))

    # Scrape ingredients + doses
    doc.css('div.wprm-recipe-ingredient-group li.wprm-recipe-ingredient').each do |li|
      ingredient_name = li.at_css('span.wprm-recipe-ingredient-name').text.strip
      dose = li.at_css('span.wprm-recipe-ingredient-notes')&.text&.strip

      ingredient = Ingredient.find_or_create_by!(name: ingredient_name)
      Dose.create!(cocktail: cocktail, ingredient: ingredient, description: dose)
    end

  rescue => e
    puts "⚠️ Failed to process #{url}: #{e.message}"
  end
end

puts "Seeding complete!"
puts "Cocktails: #{Cocktail.count}, Ingredients: #{Ingredient.count}, Doses: #{Dose.count}"
