# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#  description     :text
#

require 'spec_helper'

describe User do

  let(:user) { build(:user) }

  subject { user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:description) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before { user.toggle(:admin) }
    it { should be_admin }
  end

  describe "after mass assigning admin attribute" do
    it "should raise an error" do
      expect{ User.new(name: "Example User",
                       email: "user@example.com",
                       password: "foobar",
                       password_confirmation: "foobar",
                       admin: 1)
      }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "when name is not present" do
    before { user.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { user.email = " " }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        user.should_not be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        user.should be_valid
      end
    end
  end

  describe "when email address is already taken" do
    let!(:user_with_same_email) { user.dup }
     before do
       user_with_same_email = user.dup
       user_with_same_email.save
     end

     it { should_not be_valid }
  end

  describe "when password is not present" do
    before { user.password = user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { user.save }
    let(:found_user) { User.find_by_email(user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      user.email = mixed_case_email
      user.save
      user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "remember_token is created" do
    before { user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "feedbacks associations" do
    before { user.save }
    let(:s1) { build_stubbed(:user) }
    let(:s2) { build_stubbed(:user) }
    let(:r)  { build_stubbed(:user) }
    let!(:sent_feedback) { create(:feedback, sender: user, recipient: r) }
    let!(:older_feedback) do
      create(:feedback, sender: s1, recipient: user, created_at: 1.day.ago)
    end
    let!(:newer_feedback) do
      create(:feedback, sender: s2, recipient: user, created_at: 1.hour.ago)
    end

    it "should have the right received feedbacks in the right order" do
      user.received_feedbacks.should == [ newer_feedback, older_feedback ]
    end

    it "should destroy associated sent feedbacks" do
      sent_feedbacks = user.sent_feedbacks.dup
      user.destroy
      sent_feedbacks.should_not be_empty
      sent_feedbacks.each do |sent_feedback|
        Feedback.find_by_id(sent_feedback.id).should be_nil
      end
    end

    it "should destroy associated received feedbacks" do
      received_feedbacks = user.received_feedbacks.dup
      user.destroy
      received_feedbacks.should_not be_empty
      received_feedbacks.each do |feedback|
        Feedback.find_by_id(feedback.id).should be_nil
      end
    end

  end # feedbacks association

  describe "when description too long" do
    before { user.description = 'a' * 2501 }
    it { should_not be_valid }
  end

end
