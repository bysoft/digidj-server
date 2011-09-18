require "sinatra/base"

module DigiDJ
  class Application < Sinatra::Base
    set :root, DigiDJ.root
    enable :logging

    before do
      content_type "application/json"
    end

    get "/playlists" do
      # Playlist.all.to_json
      Playlist.all_hard_coded.to_json
    end

    get "/playlists/:playlist_id/tracks" do |playlist_id|
      Playlist.new(playlist_id).tracks.to_json
    end

    # TODO: This route should be a POST but made a GET is easier for client.
    # post "/playlists/:playlist_id/tracks" do |playlist_id|
    get "/playlists/:playlist_id/tracks/new" do |playlist_id|
      if Playlist.new(playlist_id).update_track(params[:track_id], params[:dollar_amount])
        '{"success":1}'
      else
        '{"error":{"message":"(#200) This API call requires a valid track_id & dollar_amount.","type":"ArgumentException"}}'
      end
    end
  end
end
