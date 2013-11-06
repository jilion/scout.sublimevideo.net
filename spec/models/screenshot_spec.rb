require 'spec_helper'

describe Screenshot do
  let(:image)      { fixture_file('sublimevideo.net.jpg') }
  let(:attributes) { {
    u: 'http://sublimevideo.net',
    f: image
  } }
  let(:screenshot) { described_class.create(attributes) }

  it { should validate_presence_of(:u) }
end
