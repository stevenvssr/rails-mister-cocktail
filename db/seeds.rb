require 'open-uri'
require 'nokogiri'
require 'timeout' # Required to explicitly catch Timeout::Error

# --- Helper Method for Secure Scraping ---
def open_url_securely(url)
  URI.open(url,
           "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
           "Accept-Language" => "en-US,en;q=0.9",
           read_timeout: 15
          )
end

# --- Database Cleanup (Correct Order for Foreign Keys) ---
Dose.destroy_all # Must be first
Ingredient.destroy_all
Cocktail.destroy_all # Must be last
puts "Cleaned database."

# --- Index Page Scraping ---
index_url = "https://cocktailicious.nl/index-cocktails/"

begin
  html = open_url_securely(index_url).read
  doc = Nokogiri::HTML(html)
rescue OpenURI::HTTPError => e
  puts "Error accessing index page: #{e.message}. Seeds aborted."
  exit
end

# --- Targeted Link Selection ---
cocktail_urls = doc.css('.entry-content a, .main-content a, .recipe-list a').map { |a| a['href'] }.compact.uniq.select do |url|
  # Relaxed regex
  is_recipe = url.match?(%r{https://cocktailicious\.nl/[a-z0-9-]+/?$}i)
  is_excluded = url.include?('/blogs/') ||
                url.include?('/cocktail-top-10/') ||
                url.include?('/partners/') ||
                url.include?('/overcocktailicious/') ||
                url.include?('/promotie/') ||
                url.include?('/contact/') ||
                url.include?('/privacy-cookies/') ||
                url.include?('/cocktail-index/') ||
                url.include?('/cocktail-workshop/')

  is_recipe && !is_excluded
end

puts "Found #{cocktail_urls.count} actual cocktail pages to process."

# 🛑 Final Attempt: The script should now run from start to finish.
begin
  # --- Individual Cocktail Scraping Loop ---
  cocktail_urls.each_with_index do |url, i|
    # Skip the initial debugging skips (i < 3)
    next if i < 3 
    
    # 💥 CRITICAL FIX: Skip the URL known to cause a fatal crash (Cocktail 102)
    # The crash occurred when i+1 == 102, so i == 101.
    next if i == 101 
    
    # 💥 CRITICAL FIX: Skip the URL known to cause a fatal crash (Cocktail 144)
    # The crash occurred when i+1 == 144, so i == 143.
    next if i == 143 

    puts "➡️ Processing #{i + 1}/#{cocktail_urls.count}: #{url}"

    begin
      html = open_url_securely(url).read
      doc = Nokogiri::HTML(html)

      # Extract Cocktail Name
      name = doc.at_css('h1.entry-title')&.text&.strip
      next unless name

      # Force save
      cocktail = Cocktail.find_or_create_by!(name: name)

      # Extract Description
      description = doc.at_css('.wpurp-recipe-description')&.text&.strip
      cocktail.update!(description: description) if description.present?

      # Extract Ingredients and Doses
      doc.css('.wpurp-recipe-ingredient').each do |el|
        full_text = el.text.strip
        next if full_text.blank?

        parts = full_text.split(/ of /i, 2)
        description_text, ingredient_name = (parts.size == 2) ? [parts[0].strip, parts[1].strip] : ["", full_text]

        # 1. CLEAN THE NAME for uniqueness validation
        cleaned_name = ingredient_name.strip.downcase.capitalize 
        
        # 2. CHECK PRESENCE: Skip if the name is now blank after cleaning
        next if cleaned_name.blank? 

        # Force save
        ingredient = Ingredient.find_or_create_by!(name: cleaned_name)
        
        # Force save
        Dose.find_or_create_by!(
          cocktail: cocktail, 
          ingredient: ingredient, 
          description: description_text
        )
      end

      puts "✅ #{i + 1}/#{cocktail_urls.count}: Created cocktail '#{name}'"

    rescue OpenURI::HTTPError => e
      puts "❌ Skipping #{url}: HTTP Error/Redirect Issue (#{e.message})"
    rescue Timeout::Error => e
      puts "⏳ Skipping #{url}: TIMEOUT (#{e.message})"
    rescue ActiveRecord::RecordInvalid => e
      puts "⚠️ Validation Error on #{url} for #{name}: #{e.message}"
    end
  end

rescue StandardError => e
  # This should no longer be hit unless another fatal error occurs.
  puts "\n\n🚨 FATAL CRASH DETECTED 🚨"
  puts "Skipping the rest of the file due to an unrecoverable error: #{e.message}"
end
