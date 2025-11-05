# app/models/cocktail.rb

class Cocktail < ApplicationRecord
  has_many :doses, dependent: :destroy
  has_many :ingredients, through: :doses
  has_one_attached :image

  validates :name, presence: true, uniqueness: true
  
  # FIX: Remove presence: true to allow cocktails to be created without a photo file attached.
  # The photo is already optional by default if no validation is present.
  # If you want to keep a validation just in case, you can use:
  # validates :photo, allow_nil: true 
end