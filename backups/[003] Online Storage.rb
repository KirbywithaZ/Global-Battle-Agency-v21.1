#===============================================================================
# Global Battle Agency / Online Trading
#===============================================================================

module GlobalBattleAgency
  API_URL = "https://global-battle-agency.kirbywithaz.workers.dev"
  
  # --- CONFIGURATION ---
  STUDIO_NAME   = "KirbyWithAz_Games" 
  SHARED_FOLDER = ENV['AppData'] + "/#{STUDIO_NAME}/"
  IDENTITY_FILE = SHARED_FOLDER + "gba_registry.txt"

  #-----------------------------------------------------------------------------
  # Configuration
  #-----------------------------------------------------------------------------
  
  def self.get_master_key
    return "#{$player.name}_#{$player.id}"
  end

  # Saves the current game's identity into a shared studio map
  def self.save_identity_locally
    begin
      Dir.mkdir(SHARED_FOLDER) if !File.exists?(SHARED_FOLDER)
      
      registry = {}
      if File.exists?(IDENTITY_FILE)
        begin
          registry = eval(File.read(IDENTITY_FILE))
        rescue
          registry = {}
        end
      end

      # Logs the ID under the specific game title from Game.ini
      registry[System.game_title] = self.get_master_key
      
      File.open(IDENTITY_FILE, "w") { |f| f.write(registry.inspect) }
      echoln "GBA: Identity linked locally for #{System.game_title}."
    rescue
      echoln "GBA: Failed to save local identity."
    end
  end

  #-----------------------------------------------------------------------------
  # Actual Storage Function
  #-----------------------------------------------------------------------------
  
  # Sends Pokémon to Cloud and removes from party.
  def self.upload_pokemon(slot = 0)
    pkmn = $player.party[slot]
    return pbMessage(_INTL("No Pokemon found in slot {1}!", slot + 1)) if !pkmn
    return pbMessage(_INTL("You can't deposit your last Pokemon!")) if $player.party.length <= 1

    pokemon_dna = [Marshal.dump(pkmn)].pack("m0")
    payload = { "id" => self.get_master_key, "data" => pokemon_dna }

    pbMessage(_INTL("Sending {1} to the GBA cloud...", pkmn.name))

    begin
      response = HTTPLite.post("#{API_URL}/save", payload)
      if response[:body] && response[:body].include?("OK")
        $player.party.delete_at(slot)
        
        # Automatically update registry on success.
        self.save_identity_locally 
        
        pbMessage(_INTL("Success! {1} has been moved to the cloud.", pkmn.name))
      else
        pbMessage(_INTL("The cloud is full! Try again later."))
      end
    rescue Exception => e
      echoln "GBA Error: #{e.message}"
      pbMessage(_INTL("Failed to connect to the GBA cloud."))
    end
  end

  # Pulls Pokemon from Cloud and deletes the cloud copy.
  def self.download_pokemon
    if $player.party_full?
      return pbMessage(_INTL("Your party is full! Make some room first."))
    end
    
    pbMessage(_INTL("Accessing the GBA cloud..."))
    id = self.get_master_key
    
    self.fetch_and_load(id)
  end

  #-----------------------------------------------------------------------------
  # Reunion System
  #-----------------------------------------------------------------------------

  # Detects and imports Pokemon from other games in the studio folder.
  def self.auto_invite_legacy
    if $player.party_full?
      return pbMessage(_INTL("Your party is full!"))
    end

    if File.exists?(IDENTITY_FILE)
      begin
        registry = eval(File.read(IDENTITY_FILE))
        
        # Excludes the current game from the selection list.
        registry.delete(System.game_title)

        if registry.empty?
          return pbMessage(_INTL("No other local game records were found."))
        end

        commands = registry.keys
        choice = pbMessage(_INTL("Past journeys detected! Which record should be accessed?"), commands, -1)
        
        if choice >= 0
          target_game = commands[choice]
          legacy_id = registry[target_game]
          pbMessage(_INTL("Accessing the cloud for {1}...", target_game))
          self.fetch_and_load(legacy_id)
        end
      rescue Exception => e
        echoln "GBA Reunion Error: #{e.message}"
        pbMessage(_INTL("The identity registry is corrupted."))
      end
    else
      pbMessage(_INTL("No records of a past journey found on this device."))
    end
  end

  #-----------------------------------------------------------------------------
  # Data Handler
  #-----------------------------------------------------------------------------
  
  # The actual "Worker" that talks to the server to get data.
  def self.fetch_and_load(target_id)
    begin
      response = HTTPLite.get("#{API_URL}/get?id=#{target_id}")
      data = response[:body]

      if data && data != "NOT_FOUND" && !data.include?("Error")
        decoded_data = data.unpack("m0")[0]
        pkmn = Marshal.load(decoded_data)
        $player.party.push(pkmn)
        
        # Clean up the cloud after a successful transfer.
        HTTPLite.get("#{API_URL}/delete?id=#{target_id}")
        
        pbMessage(_INTL("Welcome back, {1}!", pkmn.name))
      else
        pbMessage(_INTL("No Pokemon were found in that cloud locker."))
      end
    rescue Exception => e
      echoln "GBA Error: #{e.message}"
      pbMessage(_INTL("Connection failed! Check your internet."))
    end
  end

end
