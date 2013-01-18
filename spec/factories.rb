FactoryGirl.define do
  factory :user, aliases: [:sender, :recipient] do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "nipanipa.test+user#{n}@gmail.com" }
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  factory :feedback do
    content "Lorem ipsum"
    sender
    recipient
    score { rand(3)-1 }
  end
end
