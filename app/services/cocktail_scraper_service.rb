# app/services/cocktail_scraper_service.rb

require 'open-uri'
require 'nokogiri'

class CocktailScraperService
  def initialize(cocktail)
    @cocktail = cocktail
    url_name = @cocktail.name.parameterize
    # NOTE: Ensure this base URL is still correct!
    @url = "https://cocktailicious.nl/#{url_name}" 
  end

  def call
    # OpenURI Security Fix: Pass 'User-Agent' to prevent 403 errors and warnings
    html_content = URI.open(@url, "User-Agent" => "Ruby/#{RUBY_VERSION}").read
    doc = Nokogiri::HTML(html_content)

    scrape_description(doc)
    scrape_ingredients(doc)

  rescue OpenURI::HTTPError => e
    Rails.logger.warn "Scraper failed for #{@cocktail.name} (#{@url}): #{e.message}"
    false
  end

  private

  def scrape_description(doc)
    description_text = doc.at_css('.wpurp-recipe-description')&.text&.strip
    @cocktail.update(description: description_text) if description_text.present?
  end

  def scrape_ingredients(doc)
    doc.css('.wpurp-recipe-ingredient').each do |el|
      full_text = el.text.strip
      
      # Logic Fix: Split the text into description and ingredient name
      parts = full_text.split(/ of /i, 2) # Split once by " of " (case-insensitive)

      if parts.size == 2
        description = parts[0].strip
        name = parts[1].strip
      else
        description = ""
        name = full_text
      end
      
      next if name.blank?

      # Find or create ingredient and dose
      ingredient = Ingredient.find_or_create_by(name: name)
      Dose.find_or_create_by(cocktail: @cocktail, ingredient: ingredient, description: description)
    end
  end
end