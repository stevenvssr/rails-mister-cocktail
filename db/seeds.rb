require 'json'
require 'open-uri'

result = JSON.parse(open('http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list').read)
drinks = result['drinks']
drinks.each do |hash|
  hash.each do |k, v|
    Ingredient.create!(name: v)
  end

