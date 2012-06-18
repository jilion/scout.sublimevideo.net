FactoryGirl.define do

  factory :site do
    sequence(:token) { |n| "abc#{n}" }
  end

  factory :screenshoted_site do
    sequence(:t) { |n| "abc#{n}" }
  end

  factory :screenshot do
    association :site, factory: :screenshoted_site
    u           'http://sublimevideo.net'
    f           { File.new(Rails.root.join('spec/fixtures/sublimevideo.net.jpg')) }
  end

end
