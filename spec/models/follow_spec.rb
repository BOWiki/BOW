# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subject, type: :model do
  it 'follow growth rate returns the correct percentage' do
    follow = FactoryGirl.create(:follow, created_at: 31.days.ago)
    follow2 = FactoryGirl.create(:follow)
    expect(Follow.first.mom_follows_growth).to eq(100)
  end

  it 'distinct followers is calculated correctly' do
    follow = FactoryGirl.create(:follow)
    follow2 = FactoryGirl.create(:follow, follower_id: 2)
    expect(Follow.distinct.count('follower_id')).to eq(2)
  end

  it 'distinct follower growth rate returns the correct percentage' do
    follow = FactoryGirl.create(:follow, created_at: 31.days.ago)
    follow2 = FactoryGirl.create(:follow, follower_id: 2)
    expect(Follow.first.mom_follows_growth).to eq(100)
  end
end
