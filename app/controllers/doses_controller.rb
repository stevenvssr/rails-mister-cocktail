class DosesController < ApplicationController
  before_action :set_cocktail

  def new
    @dose = Dose.new
  end

  def create
    # FIX: Use ingredient_id submitted by the simple_form association
    @dose = Dose.new(description: dose_params[:description], 
                     cocktail: @cocktail, 
                     ingredient_id: dose_params[:ingredient_id])

    if @dose.save
      redirect_to cocktail_path(@cocktail), notice: 'Dose successfully added.'
    else
      render :new
    end
  end

  def destroy
    @dose = Dose.find(params[:id])
    @dose.destroy
    redirect_to cocktail_path(@cocktail), notice: 'Dose successfully removed.'
  end

  private

  def set_cocktail
    @cocktail = Cocktail.find(params[:cocktail_id])
  end

  def dose_params
    # FIX: Permitting ingredient_id instead of ingredient_name
    params.require(:dose).permit(:description, :ingredient_id)
  end
end