require 'rails_helper'



  describe '#subject_validation' do   
    it 'should add an error if article has no subjects' do
      article = build(:no_subject_article)
      expect(article).to be_invalid
    end

    it 'should not add an error if article has at least one subject' do
      article = build(:article)
      article.errors.should be_blank
    end
  end

  describe Article do
    it "is invalid without a date" do
      article = build(:article, date: nil)
      expect(article).to be_invalid
    end
    it "is invalid without a state_id" do
      article = build(:article, state_id: nil)
      expect(article).to be_invalid
    end
  end

  describe "#new" do
    it "takes three parameters and returns an Article object" do
		article = build(:article)
        article.should be_an_instance_of Article
    end
  end

  describe "#title" do
    it "returns the correct title" do
	  	article = build(:article)
        expect(article.title).to include "Title"
    end
  end

  describe "#content" do
    it "returns the correct content" do
	  	article = build(:article)
        expect(article.overview).to eq "A new article"
    end
  end

  describe "geocoded" do
    it "has a latitude" do
      article = FactoryGirl.create(:article)
        expect(article.latitude).not_to be_nil
    end
    it "has a longitude" do
      article = FactoryGirl.create(:article)
        expect(article.longitude).not_to be_nil
    end
  end