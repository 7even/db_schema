require 'spec_helper'

RSpec.describe DbSchema::Utils do
  describe '.rename_keys' do
    let(:hash) do
      { a: 1, b: 2 }
    end

    it 'returns a new hash with renamed keys' do
      expect(subject.rename_keys(hash, a: :c)).to eq(c: 1, b: 2)
    end

    context 'when called with a block' do
      let(:hash) do
        { precision: 10, scale: 2, null: false }
      end

      it 'yields new hash to the block' do
        new_hash = subject.rename_keys(hash) do |new_hash|
          new_hash[:size] = [new_hash.delete(:precision), new_hash.delete(:scale)]
        end

        expect(new_hash).to eq(null: false, size: [10, 2])
      end
    end
  end

  describe '.filter_by_keys' do
    let(:hash) do
      { a: 1, b: 2, c: 3, d: 4 }
    end

    it 'returns a new hash containing just the given keys' do
      expect(subject.filter_by_keys(hash, :b, :c)).to eq(b: 2, c: 3)
    end
  end

  describe '.delete_at' do
    let(:hash) do
      { a: 1, b: 2, c: 3, d: 4 }
    end

    it 'deletes the given keys from the hash' do
      subject.delete_at(hash, :b, :d)

      expect(hash.keys).to eq([:a, :c])
    end

    it 'returns the deleted values' do
      expect(subject.delete_at(hash, :b, :d)).to eq([2, 4])
    end
  end

  describe '.symbolize_keys' do
    let(:hash) do
      { 'a' => 1, b: 2, 'c' => 3 }
    end

    it 'returns a new hash with symbol keys' do
      expect(subject.symbolize_keys(hash)).to eq(a: 1, b: 2, c: 3)
    end

    context 'with a nested hash' do
      before(:each) do
        hash['d'] = { e: 4, 'f' => 5 }
      end

      it 'returns a new nested hash with symbol keys at all levels' do
        expect(subject.symbolize_keys(hash)).to eq(a: 1, b: 2, c: 3, d: { e: 4, f: 5 })
      end
    end
  end
end
