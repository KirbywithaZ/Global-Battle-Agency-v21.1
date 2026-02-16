#===============================================================================
# Global Battle Agency / Online Storage
#===============================================================================

module GlobalBattleAgency
  API_URL = "https://global-battle-agency.kirbywithaz.workers.dev"

  def self.upload_pokemon(slot = 0)
    pkmn = $player.party[slot]
    return pbMessage(_INTL("No Pokemon found!")) if !pkmn

    # Package the player name and pokemon species
    payload = {
      "id"   => $player.name,
      "data" => pkmn.species.to_s
    }

    pbMessage(_INTL("Connecting to the GBA..."))

    begin
      # In your version, HTTPLite.post returns a Hash
      response = HTTPLite.post("#{API_URL}/save", payload)
      
      # We check the :body key inside the Hash
      if response[:body] && response[:body].include?("OK")
        pbMessage(_INTL("Success! {1} was sent to the cloud.", pkmn.name))
      else
        echoln "GBA Debug: Status #{response[:status]}, Body: #{response[:body]}"
        pbMessage(_INTL("The server is on, but didn't say OK."))
      end
    rescue Exception => e
      echoln "GBA ERROR: #{e.message}"
      pbMessage(_INTL("Connection failed!"))
    end
  end
end
