require "spec_helper"

module DigiDJ
  describe Playlist do
    before(:each) do
      @playlist = Playlist.new("1")
    end

    it "has attributes" do
      @playlist.playlist_id.should eq("1")
      @playlist.playlist_id = "2"
      @playlist.playlist_id.should eq("2")
    end

    it "starts with no playlists" do
      Playlist.all.should be_empty
    end

    describe "#valid?" do
      it "must not be blank" do
        @playlist.playlist_id = nil;
        @playlist.should_not be_valid
        Playlist.new("").should_not be_valid
        Playlist.new("123").should be_valid
      end
    end

    describe "#save" do      
      it "increments playlist count by 1" do
        @playlist.save
        Playlist.all.should have(1).playlist
      end
      
      it "adds self to playlists" do
        @playlist.save
        Playlist.all.first.should eq(@playlist.playlist_id)
      end
    end

    it "starts with no tracks" do
      @playlist.tracks.should be_empty
    end

    describe "#tracks" do
      it "returns tracks with scores" do
        @playlist.add_track("123", 99)
        @playlist.tracks({with_scores: true}).should have(2).tracks
      end
    end

    describe "#update_track" do
      it "adds track" do
        @playlist.should_receive(:add_track).with("123", 99)
        @playlist.update_track("123", 0.99)
      end
      
      it "updates the track cents" do
        @playlist.update_track("123", 0.99)
        @playlist.update_track("123", 2.00)
        @playlist.tracks(with_scores: true).should eq(["123", "299"])
      end
    end

    describe "#tracks_key" do
      it "equals playlists:1:tracks" do
        @playlist.tracks_key.should eq("playlists:#{@playlist.playlist_id}:tracks")
      end
    end

    describe "#track_cents" do
      it "returns cost of track in cents" do
        @playlist.save
        @playlist.add_track("123", 99)
        @playlist.track_cents("123").should eq(99)
      end
    end

    describe "#add_track" do
      it "increments track if doesn't exist" do
        @playlist.add_track("123", 99)
        @playlist.tracks.should have(1).tracks
      end

      it "doesn't increment track if does exist" do
        @playlist.add_track("123", 99)
        @playlist.add_track("123", 99)
        @playlist.tracks.should have(1).track
      end

      it "adds track to playlist" do
        @playlist.add_track("123", 99)
        @playlist.tracks(with_scores: true).should eq(["123", "99"])
      end
    end
  end
end
