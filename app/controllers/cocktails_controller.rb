class CocktailsController < ApplicationController
  before_action :cocktail_find, only: [:show, :edit, :update]

  # GET /restaurants
  def index
    @cocktails = Cocktail.all
  end

  # GET /restaurants/1
  def show
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
    params.require(:cocktail).permit(:name)
  end
end
