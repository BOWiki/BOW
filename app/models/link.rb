# frozen_string_literal: true

# associate Case property
class Link < ApplicationRecord
  validates :url, presence: true
  belongs_to :linkable, polymorphic: true, touch: true
end
