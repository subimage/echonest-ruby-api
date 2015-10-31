require "rubygems"
require "bundler/setup"
require_relative 'base'
require_relative 'blog'
require_relative 'biography'
require_relative 'video'
require_relative 'foreign_id'

module Echonest

  class Artist < Echonest::Base

    attr_accessor :id, :name, :foreign_ids

    def initialize(api_key, name = nil, foreign_ids = nil, id = nil)
      @id = id
      @name = name
      @api_key = api_key
      @foreign_ids = ForeignId.parse_array(foreign_ids) if foreign_ids
    end

    def biographies(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:biographies].collect do |b|
        Biography.new(text: b[:text], site: b[:site], url: b[:url])
      end
    end

    # Stuff from blogspot, etc
    def blogs(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:blogs].collect do |b|
        Blog.new(name: b[:name], site: b[:site], url: b[:url])
      end
    end

    # This appears to be from more "reputable" sources?
    def news(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:news].collect do |b|
        Blog.new(name: b[:name], site: b[:site], url: b[:url])
      end
    end

    def video(options = { results: 1 })
      response = get_response(results: options[:results], name: @name)

      response[:video].collect do |v|
        Video.new(title: v[:title], site: v[:site], url: v[:url], date_found: v[:date_found], image_url: v[:image_url])
      end
    end

    def urls
      get_response(name: @name)[:urls]
    end

    def familiarity
      response = get_response(name: @name)
      response[entity_name.to_sym][__method__.to_sym]
    end

    def genres
      genres = []
      response = get('artist/profile', {name: @name, bucket: 'genre'})
      return response[:artist][:genres].collect {|g| g[:name]}
    end

    def hotttnesss(options = {})
      response = get_response(name: @name, type: options.fetch(:type, 'overall'))
      response[entity_name.to_sym][__method__.to_sym]
    end

    def images(options = { results: 15 })
      response = get_response(results: options[:results], name: @name)
      images = []
      response[:images].each do |i|
        images << i[:url]
      end
      # This server is not returning images, as Last.fm changed paths/servers.
      # Appears Echonest is caching old URLs, so we remove them here
      images.reject! {|url| url.index('userserve-ak.last.fm')}
      images
    end

    def list_genres
      get_response[:genres]
    end

    def search(options = {})
      options = {name: @name}.merge(options)
      artists = []
      get_response(options)[:artists].each do |a|
        artists << Artist.new(@api_key, a[:name], a[:foreign_ids], a[:id])
      end
      artists
    end

    def similar(options = { results: 20 })
      artists = []
      response = get('artist/similar', {name: @name, results: options[:results]})
      response[:artists].each do |a|
        artists << a
      end
      return artists
    end

    def suggest(options = {})
      options = {name: @name}.merge(options)
      artists = []
      get_response(options)[:artists].each do |a|
        artists << Artist.new(@api_key, a[:name], a[:foreign_ids], a[:id])
      end
      artists
    end

    def top_hottt(options = {})
      artists = []
      get_response(options)[:artists].each do |a|
        artists << Artist.new(@api_key, a[:name], a[:foreign_ids], a[:id])
      end
      artists
    end

    def songs(options = { results: 15 })
      songs = []
      get_response(results: options[:results], name: @name)[:songs].each do |s|
        songs << { s[:id] => s[:title] }
      end
      songs
    end

    def profile(options = {})
      options = (@id ? {id: @id} : {name: @name}).merge(options)
      artist_data = get_response(options)[:artist]
      Artist.new(@api_key, artist_data[:name], artist_data[:foreign_ids], artist_data[:id])
    end

    def terms(options = {})
      options = (@id ? { id: @id } : { name: @name }).merge(options)
      get_response(options)[:terms]
    end

  end
end
