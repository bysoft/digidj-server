module DigiDJ
  class Playlist
    PLAYLISTS_KEY = "playlists"

    attr_accessor :playlist_id

    def initialize(playlist_id)
      @playlist_id = playlist_id
    end

    def self.uri_root
      "spotify:user:brianyang:playlist:"
    end

    def self.all_hard_coded
      [
        {
          playlist_id: "7Bdmon1qvlkMQjIIkMKdeC",
          foursquare_venue: { id: "4c5c076c7735c9b6af0e8b72", name: "General Assembly" },
          venmo_user: { username: "bysoft", name: "Brian Yang" }
        },
        {
          playlist_id: "4EfV9dsnmmu6Uj6EDm5kMS",
          foursquare_venue: { id: "4e345b98d22d86185a608ab8", name: "Venmo" },
          venmo_user: { username: "iqram", name: "Iqram Magdon-Ismail" }
        },
        {
          playlist_id: "0rioY4gwnhneL3aoQkdMUT",
          foursquare_venue: { id: "4accdf38f964a520d2c920e3", name: "The Pump Energy Food" },
          venmo_user: { username: "matthew-hamilton", name: "Matthew Hamilton" }
        }
      ]
    end

    def self.all
      DigiDJ.redis.smembers(PLAYLISTS_KEY)
    end

    def valid?
      return !@playlist_id.blank?
    end

    def save
      DigiDJ.redis.sadd(PLAYLISTS_KEY, @playlist_id)
    end

    def tracks(options={})
      DigiDJ.redis.zrevrange(tracks_key, 0, -1, with_scores: options[:with_scores])
    end

    def update_track(track_id, dollars)
      dollars = dollars.to_f
      return false if !self.valid? or dollars <= 0.0 or track_id.blank?
      current_cents = self.track_cents(track_id)
      new_cents = current_cents + dollars*100
      self.add_track(track_id, new_cents)
    end

# private # this breaks tests...

    def tracks_key
      "playlists:#{@playlist_id}:tracks"
    end

    def track_cents(track_id)
      DigiDJ.redis.zscore(tracks_key, track_id).to_i
    end

    def add_track(track_id, cents)
      DigiDJ.redis.zadd(tracks_key, cents, track_id)
    end
  end
end