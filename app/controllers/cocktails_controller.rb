require 'json'
require 'open-uri'
require 'nokogiri'

class CocktailsController < ApplicationController
  before_action :cocktail_find, only: [:show, :edit, :update]
  helper_method :show_description, :show_ingredients

  # GET /restaurants
  def index
    @cocktails = Cocktail.all
  end

  # GET /restaurants/1
  def show
  end

  def show_description
    html_content = "https://www.cocktailicious.nl/#{@cocktail.name.gsub!(" ", "-")}"
    html_file = open(html_content).read
    html_doc = Nokogiri::HTML(html_file)
    search = html_doc.search('.wpurp-recipe-description').text.strip
    return search
  end

def show_ingredients
ingredients = []
html_content = "https://www.cocktailicious.nl/#{@cocktail.name}/"
html_file = open(html_content).read
html_doc = Nokogiri::HTML(html_file)
search = html_doc.search('.wpurp-recipe-ingredient').each do |element|
ingredients << element.text.strip
end
ingredients.uniq!.each do |element|
  puts element
end
end
  # GET /restaurants/new
  def new
    @cocktail = Cocktail.new
  end

  # GET /restaurants/1/edit
  def edit
  end

  # POST /restaurants
  def create
    @cocktail = Cocktail.new(cocktail_params)

    if @cocktail.save
      redirect_to @cocktail, notice: 'Cocktail was successfully created.'
    else
      render :new
    end
  end

  def update
    if @cocktail.update(cocktail_params)
      redirect_to @cocktail, notice: 'Cocktail was successfully updated.'
    else
      render :edit
    end
  end

   def destroy
    @cocktail = cocktail_find
    @cocktail.destroy
    redirect_to cocktails_path
  end


  private

  def cocktail_find
    @cocktail = Cocktail.find(params[:id])
  end

  def cocktail_params
    params.require(:cocktail).permit(:name, :photo)
  end
end
