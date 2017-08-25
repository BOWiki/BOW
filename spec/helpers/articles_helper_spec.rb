require "rails_helper"

RSpec.describe ArticlesHelper, :type => :helper do
  describe "#embed" do
    it "returns an empty string if the video URL is blank" do
      expect(helper.embed('')).to eql("")
    end

    it "returns a content tag if youtube video URL is provided" do
      expect(helper.embed('https://www.youtube.com/watch?v=Mgn1r3_eM-s')).to eql("<iframe src=\"//www.youtube.com/embed/Mgn1r3_eM-s\"></iframe>")
    end

    it "returns a content tag if vimeo video URL is provided" do
      expect(helper.embed('https://vimeo.com/136536466')).to eql("<iframe src=\"https://player.vimeo.com/video/136536466\"></iframe>")
    end

  end

  # These specs confirm that the article_sanity_check works as expected
  # If there is data that is not available, then the sanity_check returns
  # false. At that point, the site can throw an error or redirect to
  # another page. This is a more graceful solution that making the error
  # page available.

  describe "#article_sanity_check" do
    it "returns true if all the instance variables needed for the article are present" do
      article = FactoryGirl.create(:article, community_action: 'community text')
      
      assign(:article, article)
      assign(:commentable, article)
      assign(:comment, Comment.new)
      assign(:subjects, article.subjects)
      expect(helper.article_sanity_check).to be_truthy
    end

    it "returns false if any of the instance variables needed for the article are not present" do
      article = FactoryGirl.create(:article, community_action: 'community text')
      
      assign(:article, article)
      assign(:commentable, article)
      assign(:comment, Comment.new)
      expect(helper.article_sanity_check).to be_falsey
    end
  end
  
  describe "#recently_updated_case_list" do
    it "displays title and date of articles when they are found" do
      articles = FactoryGirl.create_list(:article, 10)
      
      expect(helper.recently_updated_case_list).to include(articles.first.title)
      expect(helper.recently_updated_case_list).to include(articles.last.updated_at.strftime("%m.%e, %l:%M %p"))
      expect(helper.recently_updated_case_list).not_to include('No cases added yet')
    end
    it "displays a notice if no articles are found" do
      expect(helper.recently_updated_case_list).not_to include("<td>")
      expect(helper.recently_updated_case_list).to include('No cases added yet')
    end
  end
  
  describe "#agency_dropdown_collection" do
    it "alphabetically sorts agency names" do
      article = FactoryGirl.create(:article)
      agencies = FactoryGirl.create_list(:agency, 10)
      Agency.first.update_attribute(:name, 'zzzzzzz')
      
      expect(helper.agency_dropdown_collection).to include(agencies.last)
      expect(helper.agency_dropdown_collection.last).to eq(agencies.first)
    end
  end

end