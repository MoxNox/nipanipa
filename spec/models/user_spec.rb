#
# Unit tests for User model
#

describe User do
  let(:user) { build(:user) }

  it "has a valid factory" do
    create(:user).should be_valid
  end

  it "has a valid soft factory" do
    build(:user).should be_valid
  end

  subject { user }

  it { should respond_to(:availability)        }
  it { should respond_to(:description)         }
  it { should respond_to(:email)               }
  it { should respond_to(:encrypted_password)  }
  it { should respond_to(:languages)           }
  it { should respond_to(:last_sign_in_ip)     }
  it { should respond_to(:latitude)            }
  it { should respond_to(:longitude)           }
  it { should respond_to(:name)                }
  it { should respond_to(:password)            }
  it { should respond_to(:remember_created_at) }
  it { should respond_to(:role)                }
  it { should respond_to(:type)                }

  it { should be_valid }
  specify { user.role.should == "non-admin" }

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

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      user.email = mixed_case_email
      user.save
      user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "feedbacks associations" do
    before { user.save }
    let!(:sent_f) { create(:feedback, sender: user) }
    let!(:old_f)  { create(:feedback, recipient: user, created_at: 1.day.ago)  }
    let!(:new_f)  { create(:feedback, recipient: user, created_at: 1.hour.ago) }

    it "should have the right received feedbacks in the right order" do
      user.received_feedbacks.should == [ new_f, old_f ]
    end

    it "should destroy associated sent feedbacks" do
      sent_feedbacks = user.sent_feedbacks.to_a
      user.destroy
      sent_feedbacks.should_not be_empty
      sent_feedbacks.each do |sent_feedback|
        Feedback.find_by(id: sent_feedback.id).should be_nil
      end
    end

    it "should destroy associated received feedbacks" do
      received_feedbacks = user.received_feedbacks.to_a
      user.destroy
      received_feedbacks.should_not be_empty
      received_feedbacks.each do |feedback|
        Feedback.find_by(id: feedback.id).should be_nil
      end
    end

  end # feedbacks association

  describe "when description too long" do
    before { user.description = 'a' * 2501 }
    it { should_not be_valid }
  end

end
