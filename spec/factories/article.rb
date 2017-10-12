# frozen_string_literal: true

# This will guess the Article class
FactoryGirl.define do
  factory :article do |f|
    f.sequence(:title) { |n| "#{n}Title" }
    f.overview 'A new article'
    f.city 'Albany'
    f.date Date.today
    f.state # { FactoryGirl.create(:state) }
    f.subjects { [create(:subject)] }
    f.summary 'A summary of changes'
  end

  factory :invalid_article, class: Article do |f|
    f.title ''
    f.overview ''
    f.city ''
    f.date ''
    # association :state, name: nil
  end
end
