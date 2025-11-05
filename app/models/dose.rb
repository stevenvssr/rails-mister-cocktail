# app/models/dose.rb

class Dose < ApplicationRecord
  belongs_to :cocktail
  belongs_to :ingredient

  validates :cocktail, presence: true
  validates :ingredient, presence: true
  # DELETE THIS LINE: validates :description, allow_blank: true 

  validates :ingredient_id, uniqueness: { scope: :cocktail_id, message: "already added to this cocktail" }
end