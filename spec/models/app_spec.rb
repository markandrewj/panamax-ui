require 'spec_helper'

describe App do
  let(:response_attributes) do
    {
      'name' => 'App Daddy',
      'id' => 77,
      "services" => [
          {'name' => 'blah', 'categories' => [ {'name' => 'foo'}, {'name' => 'baz'}]},
          {'name' => 'barf', 'categories' => [ {'name' => 'foo'} ]},
          {'name' => 'barf', 'categories' => [ {'name' => 'bar'} ]}
      ]
    }
  end

  let(:fake_json_response) { response_attributes.to_json }

  describe '.create_from_response' do

    it 'instantiates itself with the parsed json attributes' do
      result = described_class.create_from_response(fake_json_response)
      expect(result).to be_an App
      expect(result.name).to eq 'App Daddy'
      expect(result.id).to eq 77
    end
  end

  describe '#valid?' do
    context 'when errors are empty' do
      it 'is valid' do
        expect(subject.valid?).to be_true
      end
    end

    context 'when errors are present' do
      subject { described_class.new('errors' => {'base' => ['you messed up']}) }

      it 'is not valid' do
        expect(subject.valid?).to be_false
      end
    end
  end

  describe '#to_param' do
    subject { described_class.new('id' => 77) }

    it 'returns the id' do
      expect(subject.to_param).to eq 77
    end
  end

  describe '#as_json' do
    subject { App.new(response_attributes) }

    it 'provides the attributes to be converted to JSON' do
      expected = response_attributes
      expect(subject.as_json).to eq expected
    end
  end

  context 'when dealing with service categories' do
    subject { App.new(response_attributes) }

    it 'returns the union of all service categories for the app services' do
      categories = subject.service_categories
      expect(categories.collect{|c| c['name']}).to include('foo', 'baz', 'bar')
    end

    it 'returns a list of unique service categories' do
      categories = subject.service_categories.find_all{|c| c['name'] == 'foo'}
      expect(categories).to have_at_most(1).item
    end
  end
end