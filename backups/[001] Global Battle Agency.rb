#===============================================================================
# Global Battle Agency
#===============================================================================

# Checks if the player is eligible to use the GBA's services.
def pbCheckGBAEligibility
  unless $player.hasItem?(:BATTLEPASS)
    pbMessage(_INTL("You need a Battle Pass to access the GBA's services."))
    return false
  end
  if $player.badges_count < 1
    pbMessage(_INTL("You need at least one badge to access the GBA's services."))
    return false
  end
  return true
end

#-----------------------------------------
# Tacca Interactions
#-----------------------------------------

class Player
  attr_accessor :gbaIntroNoCount
  attr_accessor :gbaRewardReceived 
end

def pbMeetTacca
  $player.gbaIntroNoCount = 0 if $player.gbaIntroNoCount.nil?
  $player.gbaRewardReceived = false if $player.gbaRewardReceived.nil?
  
  #-----------------------
  # Initial Interaction
  #-----------------------
  pbMessage(_INTL("Well hello there, young Trainer!"))
  pbMessage(_INTL("Are you familiar with the GBA?"))

  commands = [_INTL("Yes"), _INTL("Not really")]
  choice = pbShowCommands(nil, commands, commands.length)

  case choice
  when 0
    pbMessage(_INTL("Great! I trust you're already up to speed then."))
  when 1
    $player.gbaIntroNoCount += 1
    if $player.gbaIntroNoCount >= 2
      pbMessage(_INTL("No worr-- Wait a minute... I'm pretty sure I've seen you on the Leaderboard!"))
      pbMessage(_INTL("I almost fell for your little trick, champ!"))
    else
      pbMessage(_INTL("The GBA, or Global Battle Agency, is a worldwide organization that allows you to meet people from all over the world!"))
      pbMessage(_INTL("Even an old dog like me can learn all sorts of new tricks!"))
    end
  end

  #---------------------------------
  # Main Interactions
  #---------------------------------

  loop do
    pbMessage(_INTL("Now, tell me, what would you like to do today?"))

    commands = []
    cmd_trade  = (commands[commands.length] = _INTL("Start a Trade"))
    cmd_battle = (commands[commands.length] = _INTL("Battle me!"))
    cmd_about  = (commands[commands.length] = _INTL("About the GBA"))
    cmd_quit   = (commands[commands.length] = _INTL("Never mind"))

    choice = pbShowCommands(nil, commands, commands.length)

    case choice
    when 0 # Start a Trade
      pbGBAStartTradeMenu # This calls the function in "Online Trading.rb"
    when 1 # Battle me!
      pbMessage(_INTL("Ah, battle? My team isn't quite ready yet! Check back later and I'll give you a real run for your money!"))
    when 2 # About the GBA
      pbGBAShowAboutDialogue
    else # Never mind
      pbMessage(_INTL("Very well. Come back anytime!"))
      break
    end
  end
end

def pbGBAShowAboutDialogue
  pbMessage(_INTL("The Global Battle Agency is an organization that aims to connect Trainers worldwide, either by battling or trading Pokémon."))
  pbMessage(_INTL("The Agency is fairly new, but incredibly popular nonetheless."))
  pbMessage(_INTL("Do you know of the Battle Legends of Kanto? Champion Red and Champion Blue? They founded this Agency, and numerous Champions lent their support."))
  pbMessage(_INTL("Each Trainer is ranked by their strength in battle, and by battling you can win plenty of rewards!"))
  pbMessage(_INTL("Not just that, though. You can win rewards by trading as well!"))
  pbMessage(_INTL("Some of the Professors from various regions have all pitched in to create one HUGE Pokédex called the Universal Pokédex, which will contain Pokémon from our universe and all the other ones out there! Isn't that amazing?"))  
  
  opts = [_INTL("It's awesome!"), _INTL("What is?")]
  choice = pbShowCommands(nil, opts, opts.length)

  if $player.gbaRewardReceived
    pbMessage(_INTL("I'd give you another token, but I have to save some for the other Trainers!"))
  else
    case choice
    when 0
      pbMessage(_INTL("I'm glad to see you share my passion! I look forward to seeing you around the Agency sometime!"))
      pbMessage(_INTL("Oh! And a token for your troubles! My speech was a bit long!"))
      pbReceiveItem(:BATTLE_CAPSULE_THX)
      $player.gbaRewardReceived = true
    when 1
      pbMessage(_INTL("Oh dear. You weren't listening at all, were you? Here's a token anyway."))
      pbReceiveItem(:BATTLE_CAPSULE)
      $player.gbaRewardReceived = true
    end
  end
end
