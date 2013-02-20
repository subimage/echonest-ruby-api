require 'spec_helper'

describe Echonest::Playlist do

  describe '#initialize' do

    it 'should iniaitlize with an API key and an artist ' do
      seed = Echonest::Playlist.new('BNOAEBT3IZYZI6WXI', 'Weezer')
      seed.should be
    end

  end

  describe '#session_id' do

    it 'should set a playlist session ID' do
      seed = Echonest::Playlist.new('BNOAEBT3IZYZI6WXI', 'Weezer')
      seed.session_id.should be_a String
    end

  end

  describe '#next' do

    it 'should return a Hash object' do
      seed = Echonest::Playlist.new('BNOAEBT3IZYZI6WXI', 'Weezer')
      seed.next.should be_a Hash
    end

    it 'should include the next Song' do
      seed = Echonest::Playlist.new('BNOAEBT3IZYZI6WXI', 'Weezer')
      seed.next[:artist].should be_a Echonest::Artist
      seed.next[:track].should be_a String
    end

  end

end

