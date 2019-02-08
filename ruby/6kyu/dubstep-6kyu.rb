def song_decoder(song)
        w = song.split("WUB")
        w.delete("")
        w.join(" ")
end

puts song_decoder("AWUBBWUBC")
