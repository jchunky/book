require 'json'

# {
#   "id"=>"1955",
#   "game_id"=>"2",
#   "ts_added"=>"1399929780",
#   "ts_updated"=>"1527180608",
#   "ts_maintenance"=>"1525808106",
#   "title"=>"1812 The Invasion of Canada",
#   "thumb_src"=>"https://upload.snakesandlattes.com/productsimages/2/.thumbs/2-1.jpg",
#   "image_src"=>"https://upload.snakesandlattes.com/productsimages/2/2-1.jpg",
#   "rules_url"=>"http://upload.snakesandlattes.com/rules/1/1812TheInvasionofCanada.pdf",
#   "has_guide"=>"0",
#   "archived"=>"0",
#   "parts_copy"=>"0",
#   "damaged"=>"0",
#   "notes"=>"Rules need to be laminated",
#   "maintenance_frequency"=>"",
#   "default_maintenance_frequency"=>"",
#   "teach_time"=>"0",
#   "curation_notes"=> "STANDARD AMERICAN BOARD GAME (GREEN) SLEEVES\r\n\r\n1 Map\r\n60 Cards\r\n  12 Red British Regulars\r\n  12 Yellow Canadian Militia\r\n  12 Green Native American\r\n  12 Blue American Regulars\r\n  12 White American Militia\r\n160 Units\r\n  25 Red British Regulars\r\n  35 Yellow Canadian Miltia\r\n  25 Green Native Americans\r\n  30 Blue American Regulars\r\n  45 White American Regulars\r\n13 Battle Dice\r\n  2 Red British Regulars\r\n  3 Yellow Canadian Miltia\r\n  3 Green Native American\r\n  2 Blue American Regulars\r\n  3 White American Militia\r\n1 Round Marker Pawn\r\n20 Control Markers (Double Sided)\r\n5 Turn Order Markers (1 of each colour)\r\n",
#   "optimal_players"=>"5",
#   "difficulty_label"=>"3",
#   "2player_label"=>"1",
#   "solo_label"=>"0",
#   "sell_product"=>"1",
#   "shelf_location"=>"34E",
#   "categories"=>[{"id"=>"1", "name"=>"Strategy"}],
#   "title_url"=>"1812-The-Invasion-of-Canada",
#   "employees_played"=>["AaronSlade", "AaronZack", "AnsisKalnins", "MikhailHonoridez"],
#   "employees_teachable"=>["JoanMoriarity", "MikhailHonoridez", "ToddCampbell"],
#   "employee_played"=>0,
#   "employee_teachable"=>0,
#   "ts_maintenance_next"=>1557344106
# }
class Snake
  BLACKLIST = [
    "Atari's Missile Command",
    "Blackbox - Karmaka",
    "Blackbox - OrganATTACK!",
    "Catan: 5-6 Player Extension",
    "Monster Misfits",
    "Stumblewood",
    "The Crow Game",
  ]

  NAMES = {
    "(BlackBox) - Exploding Kittens - 1st edition" => "Exploding Kittens",
    "Abraca What?" => "Abracada...What?",
    "Agricola (2015)" => "Agricola (Revised Edition)",
    "Alien Frontiers 5th Edition" => "Alien Frontiers",
    "Alles Trolli" => "Alles Tomate!",
    "Apples to Apples: Party Box Refresh" => "Apples to Apples",
    "Arkham Horror - 3rd Edition" => "Arkham Horror",
    "Atari Missile Command" => "Atari's Missile Command",
    "Avalon" => "The Resistance: Avalon",
    "Bang! 4th Edition" => "BANG!",
    "Betrayal at the House on the Hill" => "Betrayal at House on the Hill",
    "Blackbox - Joking Hazard (White Box Edition)" => "Joking Hazard",
    "Blokus Refresh" => "Blokus",
    "Blood Bowl Team Manager" => "Blood Bowl: Team Manager ? The Card Game",
    "Bob Ross: the Art of Chill" => "Bob Ross: Art of Chill Game",
    "Bonkers, the Game of" => "This Game is Bonkers!",
    "Boss Monster: Master of the Dungeon" => "Boss Monster: The Dungeon Building Card Game",
    "Brave Rats" => "BraveRats",
    "Britannia the game of the Birth of Britain" => "Britannia",
    "Buy Word" => "BuyWord",
    "Camel Up - Second Edition" => "Camel Up",
    "Candyland" => "Candy Land",
    "Carcassonne: My First Carcassonne" => "My First Carcassonne",
    "Cards Against Humanity (Canadian version)" => "Cards Against Humanity",
    "Cash'N Guns" => "Ca$h 'n Guns (Second Edition)",
    "Catan (5th Edition)" => "Catan",
    "Catan, 5-6 Extension (4th Edition)" => "Catan: 5-6 Player Extension",
    "Checkers - 11.5" => "Checkers",
    "Chess - Folding Board - SET OAK BOOK STYLE 11\" (W/ HANDLE)" => "Chess",
    "Citadels (Classic)" => "Citadels",
    "Connect 4" => "Connect Four",
    "Cranium Party" => "Cranium",
    "Cribbage Board - Board Large 29 3 Track" => "Cribbage",
    "D&D: Castle Ravenloft" => "Dungeons & Dragons: Castle Ravenloft Board Game",
    "D&D: Dungeon!" => "Dungeon!",
    "Deception: Murder in HK" => "Deception: Murder in Hong Kong",
    "Dirty Minds Card Game" => "Dirty Minds: The Game of Naughty Clues",
    "Dominoes: Double 6" => "Dominoes",
    "Eclipse: New Dawn" => "Eclipse",
    "Fake Artist Goes to New York" => "A Fake Artist Goes to New York",
    "Fantome de l'Opera" => "Le Fantome de l'Opera",
    "Fluxx: Adventure Time Fluxx" => "Adventure Time Fluxx",
    "Friends Ultimate Trivia" => "Friends Trivia Game",
    "Game of Life Monsters Inc" => "The Game of Life in Monstropolis",
    "Game of Things" => "Things...",
    "Game of Thrones 2nd Edition" => "A Game of Thrones: The Board Game (Second Edition)",
    "Gloom (2nd Edition)" => "Gloom",
    "Gloom Cthulhu" => "Cthulhu Gloom",
    "Go - 12" => "Go",
    "Grey's Anatomy" => "Grey's Anatomy Trivia Board Game",
    "Grid Stones: Night Sky" => "Gridstones",
    "Hedbanz Adult" => "Hedbanz for Adults!",
    "Hedbanz No Limits" => "Hedbanz for Adults!",
    "Hotels" => "Hotel Tycoon",
    "Jenga Refresh" => "Jenga",
    "Joking Hazard (White Box Edition)" => "Joking Hazard",
    "Jungle Speed (Plastic)" => "Jungle Speed",
    "Kwizniac 2" => "Kwizniac",
    "Lanterns" => "Lanterns: The Harvest Festival",
    "Last Night on Earth" => "Last Night on Earth: The Zombie Game",
    "Legendary: Marvel Deck-Building Game" => "Legendary: A Marvel Deck Building Game",
    "Lift It! Deluxe" => "Lift It!",
    "Loaded Questions The Game" => "Loaded Questions",
    "Lord of the Rings Co-op" => "Lord of the Rings",
    "Lord of the Rings: Fellowship of the Ring DBG" => "The Lord of the Rings: The Fellowship of the Ring Deck-Building Game",
    "Love Letter Premium Edition" => "Love Letter Premium",
    "Love Letter: Clamshell Edition" => "Love Letter",
    "Love Letter: Kanai Factory Limited Edition" => "Love Letter",
    "Mind Trap" => "MindTrap",
    "Monopoly Jr." => "Monopoly Junior",
    "Mr. Jack London" => "Mr. Jack",
    "Netrunner (Revised Core)" => "Android: Netrunner",
    "Never Have I Ever" => "Never Have I Ever: The Card Game of Poor Life Decisions",
    "NMBR9" => "NMBR 9",
    "Once Upon a Time" => "Once Upon a Time: The Storytelling Card Game",
    "Orinoco Gold" => "Gold am Orinoko",
    "Parcheesi" => "Parchisi",
    "Penguin Pile Up" => "Iceberg Seals",
    "Pentago Multiplayer" => "Multiplayer Pentago",
    "Perudo" => "Liar's Dice",
    "Plague Inc." => "Plague Inc.: The Board Game",
    "Playing Cards" => "Traditional Card Games",
    "Poison" => "Friday the 13th",
    "Portrayal" => "Duplik",
    "Quartex EN/FR" => "Quartex",
    "Resistance - 3rd Edition" => "The Resistance",
    "Rick and Morty: Total Rickall" => "Rick and Morty: Total Rickall Card Game",
    "Rock Paper Wizard" => "Dungeons & Dragons: Rock Paper Wizard",
    "Sentinels of the Multiverse: Enhanced Edition" => "Sentinels of the Multiverse",
    "Shrimp Cocktail" => "Shrimp",
    "Simpsons Trivia" => "The Simpsons Trivia Game",
    "Snakes and Ladders" => "Chutes and Ladders",
    "Spank the Yeti" => "Spank the Yeti: The Adult Party Game of Questionable Decisions",
    "Spartacus: Blood and Treachery" => "Spartacus: A Game of Blood & Treachery",
    "Star Realms Deck-Building Game" => "Star Realms",
    "Star Wars Loopin Chewie" => "Loopin' Chewie",
    "Star Wars Trivial Pursuit" => "Trivial Pursuit: Star Wars – The Black Series Edition",
    "Survive: 30th Anniversary Edition" => "Survive: Escape from Atlantis!",
    "Taboo Refresh" => "Taboo",
    "Telestrations Party Pack " => "Telestrations: 12 Player Party Pack ",
    "Telestrations Party Pack" => "Telestrations: 12 Player Party Pack",
    "The Game: On Fire" => "The Game",
    "The Hare & The Tortoise" => "Tales & Games: The Hare & the Tortoise",
    "The Office" => "The Office Trivia Game",
    "Three Little Pigs" => "Tales & Games: The Three Little Pigs",
    "Timeline Science & Discoveries (formerly Timeline Discoveries)" => "Timeline: Discoveries",
    "Trivial Pursuit 2000s" => "Trivial Pursuit: 2000s Edition",
    "Trivial Pursuit Classic" => "Trivial Pursuit",
    "Trivial Pursuit Disney" => "Trivial Pursuit: Disney Edition",
    "Trivial Pursuit Harry Potter" => "Trivial Pursuit: World of Harry Potter",
    "Trivial Pursuit Warner Bros" => "Trivial Pursuit: Warner Bros. All Family Edition",
    "Trivial Pursuit: Dr. Who" => "Trivial Pursuit: Doctor Who",
    "Vegas (formerly Las Vegas)" => "Las Vegas",
    "Welcome to... Your Perfect Home" => "Welcome to...",
    "What Do You Meme" => "What do you Meme?: A Millennial Card Game For Millennials And Their Millennial Friends",
    "Wikipedia - The Game" => "Wikipedia: The Game About Everything ",
    "Wildlife Safari (formerly Botswana)" => "Wildlife Safari",
    "Word Around" => "WordARound",
  }

  FILES = [
    'input/abstract.json',
    'input/childrens.json',
    'input/cooperative.json',
    'input/dexterity.json',
    'input/greatest_hits.json',
    'input/light_strategy.json',
    'input/new_arrivals.json',
    'input/nostalgia.json',
    'input/party.json',
    'input/strategy.json',
    'input/trivia.json',
    'input/word.json',
  ]

  def games
    FILES
      .map { |f| File.read(f) }
      .map { |f| JSON.parse(f) }
      .flat_map do |rows|
        rows.map { |row| build_game(row) }
      end
      .select { |game| display_game?(game) }
  end

  def build_game(data)
    name = normalize_name(data['title'])

    OpenStruct.new(
      name: name,
      rules_url: data['rules_url'],
      difficulty: data['difficulty_label'],
      location: data['shelf_location'],
      categories: data['categories'].map { |c| c['name'] }.join(", "),
      key: Utils.generate_key(name)
    )
  end

  def normalize_name(name)
    NAMES[name] || name
  end

  def display_game?(game)
    game.difficulty.to_i != 3 &&
    game.categories.include?("Strategy") &&
    BLACKLIST.exclude?(game.name)
  end
end
