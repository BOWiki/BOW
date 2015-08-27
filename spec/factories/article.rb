# This will guess the Article class
FactoryGirl.define do

  factory :article do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.overview "A new article"
    f.city "Albany"
    f.state_id 33
    f.date Date.today
    transient do
      subjects_count 5
    end

    after(:build) do |article, evaluator|
      article.subjects << FactoryGirl.build_list(:subject, evaluator.subjects_count, article: nil)
    end
  end

  factory :invalid_article, class: Article do |f|
    f.title ""
    f.overview ""
    f.city ""
    f.state_id 0
    f.date ""
    # association :state, name: nil
  end

  factory :no_subject_article, class: Article do |f|
    f.sequence(:title) {|n| "#{n}Title"}
    f.overview "A new article"
    f.city "Albany"
    f.state_id 33
    f.date Date.today
    # association :state, name: nil
  end

end