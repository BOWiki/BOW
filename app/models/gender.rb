# frozen_string_literal: true

# Encapsulates the many genders that are affected by this
class Gender < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sex, use: :slugged
  has_many :subjects
  alias_attribute :name, :sex
end
