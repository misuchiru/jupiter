# == Schema Information
#
# Table name: records
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  project_id  :integer
#  record_type :string
#  minutes     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Record, type: :model do
  let(:record){ FactoryGirl.create :record }

  it "FactoryGirl" do
    expect(record).not_to be_new_record
  end
end