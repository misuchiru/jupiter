# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  item_id    :integer
#  item_type  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:comment){ FactoryGirl.create :comment }

  it "FactoryGirl" do
    expect(comment).not_to be_new_record
  end
end