# - sorry it took so god damn long :(

# The background image of the save selection
BackgroundImage = "Graphics/Titles/splash"

class Game_Temp
  attr_accessor :save_slot
end

class SelectableSprite < Sprite
  def initialize(bitmap, viewport = nil)
    super(viewport)
    @selected = false
    self.bitmap = Bitmap.new(bitmap)
    self.src_rect.width = self.bitmap.width / 2
  end
  
  def selected?
    return @selected
  end
  
  def select(*interval)
    @selected = true
    if interval.size > 0
      @time = interval.max + 1
      @interval = interval
      @i = 0
    else
      self.src_rect.x = self.src_rect.width
    end
  end
  
  def deselect
    @selected = false
    self.src_rect.x = 0
  end
  
  def update
    if @time
      if @interval.include?(@i)
        self.select
      else
        self.deselect
      end
      @i += 1
      if @i > @time
        @time = nil
        @interval = nil
        @i = nil
      end
    end
  end
end

# alias save_resize pbSetResizeFactor
# def pbSetResizeFactor(factor = 1, norecalc = false)
#   return if $scene.is_a?(SaveSelection)
#   save_resize(factor, norecalc)
# end

class SaveSelection
  def initialize # Actually the initializer, but it tricks $scene into starting this
    #$PokemonTemp   = PokemonTemp.new
    $game_temp     = Game_Temp.new
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new if !$PokemonSystem
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @path = "Graphics/UI/Load/"
    @sprites = {}
    addBackgroundOrColoredPlane(@sprites, BackgroundImage, "Load/bg", Color.new(248, 248, 248), @viewport)
    @sprites["left"] = SelectableSprite.new(@path + "left_arrow", @viewport)
    @sprites["left"].y = 66
    @sprites["right"] = SelectableSprite.new(@path + "right_arrow", @viewport)
    @sprites["right"].x = 478
    @sprites["right"].y = 66
    @sprites["deletepanel"] = SelectableSprite.new(@path + "delete_button", @viewport)
    @sprites["deletepanel"].x = 160
    @sprites["deletepanel"].y = 288
    # @sprites["delete"]["text"] = TextSprite.new(@viewport, nil, 192, 32)
    # @sprites["delete"]["text"].x = @sprites["delete"]["panel"].x
    # @sprites["delete"]["text"].y = @sprites["delete"]["panel"].y
    # @sprites["delete"]["text"].z = @sprites["delete"]["panel"].z
   # pbSetSmallFont(@sprites["delete"]["panel"].bitmap)
   # @sprites["delete"]["text"].draw([
    pbDrawTextPositions(@sprites["deletepanel"].bitmap, [[_INTL("New Game"), 96, 3, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
    pbDrawTextPositions(@sprites["deletepanel"].bitmap, [[_INTL("New Game"), 96 + 192, 3, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
    #])
    @sprites["down"] = SelectableSprite.new(@path + "down_arrow", @viewport)
    @sprites["down"].x = 194
    @sprites["down"].y = 350
    @sprites["up"] = SelectableSprite.new(@path + "up_arrow", @viewport)
    @sprites["up"].x = 194
    @sprites["up"].y = 384
    @sel = 0
    times = []
    for i in 0..2
      if FileTest.exist?(RTP.getSaveFileName("Game#{i}.rxdata"))
        times << File.mtime(RTP.getSaveFileName("Game#{i}.rxdata")).to_i
      else
        times << 0
      end
    end
    @save_index = times.index(times.max)
    #FontInstaller.install
    load_save(@save_index, true)
    Graphics.transition
    mainloop
  end

  def to_digits(num, size)
    str = num.to_s
    (size - str.size).times { str = str.prepend("0") }
    return str
  end
  
  def load_save(index, initial = false)
    SaveData.setSaveIndex(index)
    filename = RTP.getSaveFileName("Game#{index}.rxdata")
    if FileTest.exist?(filename)
      $Trainer, $stats,
          $game_system, $PokemonSystem, @mapid,
          $PokemonGlobal = try_load(filename)
      @new_game = false
    else
      @new_game = true
    end
    if !initial
      pbSEPlay("load_eject")
      for i in 0...4
        Graphics.update
        Input.update
        update
        @sprites["cartridgepanel"].y += 3
        for i in 0...6 do
          @sprites["cartridgeparty#{i}"].y += 3 if @sprites["cartridgeparty#{i}"]
        end
        @sprites["char"].y += 3 if @sprites["char"]
      end
      4.times { Graphics.update; Input.update; update }
      for i in 0...4
        Graphics.update
        Input.update
        update
        @sprites["cartridgepanel"].y -= 3
        for i in 0...6 do
          @sprites["cartridgeparty#{i}"].y -= 3 if @sprites["cartridgeparty#{i}"]
        end
        @sprites["char"].y -= 3 if @sprites["char"]
      end
      for i in 0...21
        Graphics.update
        Input.update
        update
        sy = -2 * i * 1.1 ** i
        @sprites["cartridgepanel"].y = sy
        for i in 0...6 do
          @sprites["cartridgeparty#{i}"].y = sy + 90 if @sprites["cartridgeparty#{i}"]
        end
        @sprites["char"].y = sy + 10 if @sprites["char"]
        @sprites["deletepanel"].opacity -= 16 if @new_game
      end
      @sprites["cartridgepanel"].y = 0
    end
    @sprites["deletepanel"].opacity = 0 if @new_game
    @sprites["cartridgepanel"].dispose if @sprites["cartridgepanel"]
    @sprites["cartridgepanel"] = nil
    for i in 0...6 do
      @sprites["cartridgeparty#{i}"].dispose if @sprites["cartridgeparty#{i}"]
      @sprites["cartridgeparty#{i}"] = nil if @sprites["cartridgeparty#{i}"]
    end
    @sprites["char"].dispose if @sprites["char"]
    @sprites["char"] = nil
    for i in 0..3
      @sprites["buttons#{i}"].dispose if @sprites["buttons#{i}"]
    end
    @sprites["buttonstext"].dispose if @sprites["buttonstext"]
    if @new_game
      # Credits
      @sprites["buttons0"] = SelectableSprite.new(@path + "panel_top", @viewport)
      @sprites["buttons0"].x = 48
      @sprites["buttons0"].y = 112 + 384
      pbDrawTextPositions(@sprites["buttons0"].bitmap, [[_INTL("CREDITS"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons0"].bitmap, [[_INTL("CREDITS"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # Quit Game
      @sprites["buttons1"] = SelectableSprite.new(@path + "panel_bottom", @viewport)
      @sprites["buttons1"].x = 48
      @sprites["buttons1"].y = 192 + 384
      pbDrawTextPositions(@sprites["buttons1"].bitmap, [[_INTL("EXIT GAME"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons1"].bitmap, [[_INTL("EXIT GAME"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      @sprites["buttonstext"] = Sprite.new(@viewport)
      @sprites["buttonstext"].x = 384
      @sprites["buttonstext"].y = 384
      @sprites["buttonstext"].z = 1

      
      @sprites["cartridgepanel"] = SelectableSprite.new(@path + "new_button", @viewport)
      @sprites["cartridgepanel"].x = 64
      @sprites["cartridgepanel"].y = 40

      @sprites["cartridgepanel"].select
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Slot #{index + 1}: New Game"), 192, 82, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Slot #{index + 1}: New Game"), 192 + 416, 82, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # @sprites["cartridgepanel"]["text"]["textpos"] = TextSprite.new(@viewport, [
      #     "Slot #{index}: New Game", 192, 82, 2, Color.new(255, 255, 255), Color.new(32, 32, 32)
      # ], 384, 192)
      # @sprites["cartridgepanel"]["text"].x = @sprites["cartridgepanel"]["panel"].x
      # @sprites["cartridgepanel"]["text"].y = @sprites["cartridgepanel"]["panel"].y
      # @sprites["cartridgepanel"]["text"].z = @sprites["cartridgepanel"]["panel"].z

    else
      # Options
      @sprites["buttons0"] = SelectableSprite.new(@path + "panel_top", @viewport)
      @sprites["buttons0"].x = 48
      @sprites["buttons0"].y = 48 + 384
      pbDrawTextPositions(@sprites["buttons0"].bitmap, [[_INTL("OPTIONS"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons0"].bitmap, [[_INTL("OPTIONS"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # Mystery Gift
      @sprites["buttons1"] = SelectableSprite.new(@path + "panel", @viewport)
      @sprites["buttons1"].x = 48
      @sprites["buttons1"].y = 128 + 384
      pbDrawTextPositions(@sprites["buttons1"].bitmap, [[_INTL("MYSTERY GIFT"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons1"].bitmap, [[_INTL("MYSTERY GIFT"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # Credits
      @sprites["buttons2"] = SelectableSprite.new(@path + "panel", @viewport)
      @sprites["buttons2"].x = 48
      @sprites["buttons2"].y = 208 + 384
      pbDrawTextPositions(@sprites["buttons2"].bitmap, [[_INTL("CREDITS"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons2"].bitmap, [[_INTL("CREDITS"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # Quit Game
      @sprites["buttons3"] = SelectableSprite.new(@path + "panel_bottom", @viewport)
      @sprites["buttons3"].x = 48
      @sprites["buttons3"].y = 288 + 384
      pbDrawTextPositions(@sprites["buttons3"].bitmap, [[_INTL("EXIT GAME"), 208, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["buttons3"].bitmap, [[_INTL("EXIT GAME"), 208 + 416, 36, 2, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      # @sprites["buttonstext"] = TextSprite.new(@viewport, [
      #     ["OPTIONS", 256, 80, 2, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     ["MYSTERY GIFT", 256, 160, 2, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     ["CREDITS", 256, 240, 2, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     ["EXIT GAME", 256, 320, 2, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      # ])
      # @sprites["buttons"]["text"].x = 0
      # @sprites["buttons"]["text"].y = 384
      # @sprites["buttons"]["text"].z = 1
      
      @sprites["cartridgepanel"] = SelectableSprite.new(@path + "load_save", @viewport)
      @sprites["cartridgepanel"].x = 48
      @sprites["cartridgepanel"].y = 16
      @sprites["cartridgepanel"].select
      #FIX THIS LATER
      # @sprites["cartridgetext"] = TextSprite.new(@viewport,
      #     ["Slot #{index}", 44, 42, 0, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      # 414, 240)
      # @sprites["cartridgepanel"]["text"].x = @sprites["cartridgepanel"]["panel"].x
      # @sprites["cartridgepanel"]["text"].y = @sprites["cartridgepanel"]["panel"].y
      # @sprites["cartridgepanel"]["text"].z = @sprites["cartridgepanel"]["panel"].z

      # @sprites["cartridgepanel"]["small"] = TextSprite.new(@viewport, nil, 414, 240)
      # @sprites["cartridgepanel"]["small"].x = @sprites["cartridgepanel"]["panel"].x
      # @sprites["cartridgepanel"]["small"].y = @sprites["cartridgepanel"]["panel"].y
      # @sprites["cartridgepanel"]["small"].z = @sprites["cartridgepanel"]["panel"].z

      #pbSetSmallFont(@sprites["cartridgepanel"]["small"].bitmap)
      totalsec = $stats.play_time.to_i
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      sec = totalsec % 60
      if hour > 999
        hour = 999
        min = 59
        sec = 59
      end
      hour = to_digits(hour, 2)
      min = to_digits(min, 2)
      sec = to_digits(sec, 2)
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Slot #{index + 1}"), 44, 42, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Slot #{index + 1}"), 44 + 416, 42, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      mapname = pbGetMapNameFromId(@mapid)
      mapname = mapname.gsub(/\\PN/, $Trainer.name)
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL(mapname), 380, 54, 1, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Badges"), 54, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL($Trainer.badge_count.to_s), 192, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Money"), 54, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL(get_money_text($Trainer.money)), 192, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Pokedex"), 218, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL($Trainer.pokedex.owned_count.to_s + "/" + $Trainer.pokedex.seen_count.to_s), 366, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Time"), 218, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("#{hour}:#{min}:#{sec}"), 366, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      
#      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Slot #{index + 1}"), 44 + 416, 42, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])

      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL(mapname), 380 + 416, 54, 1, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Badges"), 54 + 416, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL($Trainer.badge_count.to_s), 192 + 416, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Money"), 54 + 416, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL(get_money_text($Trainer.money)), 192 + 416, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Pokedex"), 218 + 416, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL($Trainer.pokedex.owned_count.to_s + "/" + $Trainer.pokedex.seen_count.to_s), 366 + 416, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("Time"), 218 + 416, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32, 255)]])
      pbDrawTextPositions(@sprites["cartridgepanel"].bitmap, [[_INTL("#{hour}:#{min}:#{sec}"), 366 + 416, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32, 255)]])


      # @sprites["cartridgepanel"]["small"].draw([
      #     [mapname, 380, 54, 1, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     ["Badges", 54, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     [$Trainer.numbadges.to_s, 192, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32)],
      #     ["Money", 54, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     [get_money_text($Trainer.money), 192, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32)],
      #     ["Pokédex", 218, 146, 0, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     [$Trainer.pokedexOwned.to_s + "/" + $Trainer.pokedexSeen.to_s, 366, 146, 1, Color.new(212, 204, 87), Color.new(32, 32, 32)],
      #     ["Time", 218, 178, 0, Color.new(255, 255, 255), Color.new(32, 32, 32)],
      #     ["#{hour}:#{min}:#{sec}", 366, 178, 1, Color.new(212, 204, 87), Color.new(32, 32, 32)],
      # ])
      

      for i in 0...$Trainer.party.size
        p = $Trainer.party[i]
        @sprites["cartridgeparty#{i}"] = PokemonSpeciesIconSprite.new(p.species, @viewport)
        @sprites["cartridgeparty#{i}"].x = 64 + 64 * i
        @sprites["cartridgeparty#{i}"].y = (initial ? 90 : -100)
      end

      #   @sprites["cartridgepanel"]["party"][i] = s
      # end
      meta = GameData::PlayerMetadata.get($Trainer.character_ID) 
      if meta
        filename = pbGetPlayerCharset(meta.walk_charset)
        @sprites["char"] = TrainerWalkingCharSprite.new(filename, @viewport)
        cw = @sprites["char"].bitmap.width
        ch = @sprites["char"].bitmap.height
        @sprites["char"].x = 238
        @sprites["char"].y = (initial ? 10 : -100)
        @sprites["char"].src_rect = Rect.new(0, 0, cw / 4, ch / 4)
      end
    end
    if !initial
      @sprites["cartridgepanel"].y = sy
      12.times {
        Graphics.update
        Input.update
        update
      }
      for i in 0...21
        Graphics.update
        Input.update
        update
        @sprites["cartridgepanel"].y = sy + 2 * i * 1.1 ** i
        @sprites["deletepanel"].opacity += 16 if !@new_game
        if !@new_game
          for i in 0...6
            @sprites["cartridgeparty#{i}"].y = sy + 90 + 2 * i * 1.1 ** i if @sprites["cartridgeparty#{i}"]
          end
          @sprites["char"].y = sy + 10 + 2 * i * 1.1 ** i
        end
      end
      pbSEPlay("load_click")
      @sprites["cartridgepanel"].y = 16
      if !@new_game
        for i in 0...6
          @sprites["cartridgeparty#{i}"].y = 90 if @sprites["cartridgeparty#{i}"]
        end
        @sprites["char"].y = 10
      end
      for i in 0...4
        Graphics.update
        Input.update
        update
        @sprites["cartridgepanel"].y += 3
        if !@new_game
          for i in 0...6
            @sprites["cartridgeparty#{i}"].y +=3 if @sprites["cartridgeparty#{i}"]
          end
          @sprites["char"].y += 3
        end
      end
      4.times { Graphics.update; Input.update; update }
      for i in 0...4
        Graphics.update
        Input.update
        update
        @sprites["cartridgepanel"].y -= 3
        if !@new_game
          for i in 0...6
            @sprites["cartridgeparty#{i}"].y -=3 if @sprites["cartridgeparty#{i}"]
          end
          @sprites["char"].y -= 3
        end
      end
    end
  end
  
  def change_sel(sel)
    mult1 = mult2 = sel == 2 ? 1 : -1
    if sel == 2
      @sprites["down"].select(1, 2, 3, 9, 10, 11)
      @sprites["buttons0"].select
    else
      @sprites["up"].select(1, 2, 3, 9, 10, 11)
      if !@new_game
        @sprites["deletepanel"].select
      end
    end
    pbSEPlay("load_cursor")
    16.times { Graphics.update; Input.update; update }
    frames = 24
    for i in 0...frames
      Graphics.update
      Input.update
      update
      @sprites["cartridgepanel"].y -= mult1 * 384.0 / frames
      @sprites["left"].y -= mult1 * 384.0 / frames
      @sprites["right"].y -= mult1 * 384.0 / frames
      @sprites["deletepanel"].y -= mult1 * 384.0 / frames
      @sprites["down"].y -= mult1 * 384.0 / frames
      @sprites["up"].y -= mult2 * 384.0 / frames
      @sprites["buttons0"].y -= mult2 * 384.0 / frames
      @sprites["buttons1"].y -= mult2 * 384.0 / frames
      @sprites["buttons2"].y -= mult2 * 384.0 / frames if !@new_game
      @sprites["buttons3"].y -= mult2 * 384.0 / frames if !@new_game

      for i in 0...6
        @sprites["cartridgeparty#{i}"].y -= mult1 * 384.0 / frames if  @sprites["cartridgeparty#{i}"] 
      end
      @sprites["char"].y -= mult1 * 384.0 / frames if  @sprites["char"]
    end
    if sel == 2
      @sprites["deletepanel"].deselect
    else
      @sprites["buttons0"].deselect
    end
    if @new_game && sel == 1
      @sel = 0
    else
      @sel = sel
    end
  end
  
  def get_money_text(n)
    return "$0" if n <= 0
    return "$" + n.to_s if n >= 0 && n < 1000
    level = 0
    int = n
    while int > 999
      int = (int / 1000.0).floor
      level += 1
    end
    display = (10 * n / (1000.0 ** level)).floor / 10.0
    suffix = ["k", "M", "B", "T", "P", "E", "Z", "Y"]
    return "$999.9#{suffix[suffix.size - 1]}" if level > suffix.size
    return "$" + display.to_s + suffix[level - 1]
  end
  
  def try_load(filename)
    trainer = nil
    stats = nil
    game_system = nil
    pokemon_system = nil
    mapid = nil
    pokemonglobal = nil
    iterated = false
    File.open(filename) do |f|
      next if iterated
      iterated = true
      data = Marshal.load(f)
      trainer = data[:player]
      stats = data[:stats]
      game_system = data[:game_system]
      pokemon_system = data[:pokemon_system]
      mapid = data[:map_factory].map.map_id || 0
      pokemonglobal = data[:global_metadata]
    end
    raise "Corrupted file" if !trainer.is_a?(Player)
    raise "Corrupted file" if !stats.is_a?(GameStats)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemon_system.is_a?(PokemonSystem)
    #raise "Corrupted file" if !mapid.is_a?(Numeric)
    raise "Corrupted file" if !pokemonglobal.is_a?(PokemonGlobalMetadata)
    return [trainer, stats, game_system, pokemon_system, mapid, pokemonglobal]
  end
  
  def mainloop
    loop do
      Graphics.update
      Input.update
      update
      if @sel == 0 # Save File
        if Input.trigger?(Input::RIGHT)
          @save_index += 1
          @save_index = 0 if @save_index >= 3
          @sprites["right"].select(1, 2, 3, 9, 10, 11)
          load_save(@save_index)
        end
        if Input.trigger?(Input::LEFT)
          @save_index -= 1
          @save_index = 2 if @save_index < 0
          @sprites["left"].select(1, 2, 3, 9, 10, 11)
          load_save(@save_index)
        end
      end
      if Input.trigger?(Input::DOWN)
        if @sel == 0 && !@new_game
          pbSEPlay("load_cursor")
          @sel = 1
          @sprites["cartridgepanel"].deselect
          @sprites["deletepanel"].select
        elsif @sel == 1 || @sel == 0 && @new_game # Delete Button / front card if empty
          change_sel(2)
        elsif !@new_game && @sel < 5 || @new_game && @sel < 3
          pbSEPlay("load_cursor")
          @sprites["buttons#{@sel - 2}"].deselect
          @sel += 1
          @sprites["buttons#{@sel - 2}"].select
        end
      end
      if Input.trigger?(Input::UP)
        if @sel == 1
          pbSEPlay("load_cursor")
          @sel = 0
          @sprites["cartridgepanel"].select
          @sprites["deletepanel"].deselect
        elsif @sel == 2
          change_sel(1)
        elsif @sel > 2
          pbSEPlay("load_cursor")
          @sprites["buttons#{@sel - 2}"].deselect
          @sel -= 1
          @sprites["buttons#{@sel - 2}"].select
        end
      end
      if Input.trigger?(Input::C)
        if @sel == 0
          pbSEPlay("load_go")
        else
          pbSEPlay("load_cursor")
        end
        confirm_choice
      end
      break if @disposed
    end
  end
  
  def confirm_choice
    case @sel
    when 0 # Save File
      filename = RTP.getSaveFileName("Game#{@save_index}.rxdata")
      if FileTest.exist?(filename)
        continue_game
      else
        new_game
      end
    when 1 # Delete Save
      new_game
    when 2 # Options
      @new_game ? credits : options
    when 3 # Mystery Gift
      @new_game ? quit_game : mystery_gift
    when 4 # Credits
      credits
    when 5 # Quit Game
      quit_game
    end
  end
  
  def continue_game
    filename = RTP.getSaveFileName("Game#{@save_index}.rxdata")
    savedata = SaveData.read_from_file(filename)
    dispose
    Game.load(savedata)
    return
    $ItemData = readItemList("Data/items.dat")
    metadata = nil
    $game_temp.save_slot = @save_index
    filename = RTP.getSaveFileName("Game#{@save_index}.rxdata")
    File.open(filename) do |f|
      Marshal.load(f) # Trainer already loaded
      Graphics.frame_count = Marshal.load(f)
      $game_system         = Marshal.load(f)
      Marshal.load(f) # PokemonSystem already loaded
      Marshal.load(f) # Current map id no longer needed
      $game_switches       = Marshal.load(f)
      $game_variables      = Marshal.load(f)
      $game_self_switches  = Marshal.load(f)
      $game_screen         = Marshal.load(f)
      $MapFactory          = Marshal.load(f)
      $game_map            = $MapFactory.map
      $game_player         = Marshal.load(f)
      Marshal.load(f) # PokemonGlobal already loaded
      metadata             = Marshal.load(f)
      $PokemonBag          = Marshal.load(f)
      $PokemonStorage      = Marshal.load(f)
      magicNumberMatches = false
      if $data_system.respond_to?("magic_number")
        magicNumberMatches = ($game_system.magic_number == $data_system.magic_number)
      else
        magicNumberMatches = ($game_system.magic_number == $data_system.version_id)
      end
      if !magicNumberMatches || $PokemonGlobal.safesave
        if pbMapInterpreterRunning?
          pbMapInterpreter.setup(nil,0)
        end
        begin
          $MapFactory.setup($game_map.map_id) # calls setMapChanged
        rescue Errno::ENOENT
          if $DEBUG
            Kernel.pbMessage(_INTL("Map {1} was not found.", $game_map.map_id))
            map = pbWarpToMap()
            if map
              $MapFactory.setup(map[0])
              $game_player.moveto(map[1],map[2])
            else
              $game_map = nil
              $scene = nil
              return
            end
          else
            $game_map = nil
            $scene = nil
            Kernel.pbMessage(_INTL("The map was not found. The game cannot continue."))
          end
        end
        $game_player.center($game_player.x, $game_player.y)
      else
        $MapFactory.setMapChanged($game_map.map_id)
      end
    end
    if !$game_map.events # Map wasn't set up
      $game_map = nil
      $scene = nil
      Kernel.pbMessage(_INTL("The map is corrupt. The game cannot continue."))
      return
    end
    $PokemonMap = metadata
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
    dispose
    #pbSetResizeFactor($PokemonSystem.screensize) # Apply proper screensize
  end
  
  def new_game
    # $ItemData = readItemList("Data/items.dat")
    #  $game_temp.save_slot = @save_index
    # if $game_map && $game_map.events
    #   for event in $game_map.events.values
    #     event.clear_starting
    #   end
    # end
    # $game_temp.common_event_id = 0 if $game_temp
    #  $scene               = Scene_Map.new
    # Graphics.frame_count = 0
    #  $game_system         = Game_System.new
    #  $game_switches       = Game_Switches.new
    #  $game_variables      = Game_Variables.new
    #  $game_self_switches  = Game_SelfSwitches.new
    #  $game_screen         = Game_Screen.new
    #  $game_player         = Game_Player.new
    #  $PokemonMap          = PokemonMapMetadata.new
    #  $PokemonGlobal       = PokemonGlobalMetadata.new
    #  $PokemonStorage      = PokemonStorage.new
    #  $PokemonEncounters   = PokemonEncounters.new
     #$PokemonTemp.begunNewGame = true
    #  $data_system         = pbLoadRxData("Data/System")
    #  $MapFactory          = PokemonMapFactory.new($data_system.start_map_id) # calls setMapChanged
    #  $game_player.moveto($data_system.start_x, $data_system.start_y)
    #  $game_player.refresh
    #  $game_map.autoplay
    #  $game_map.update
    # dispose
    #pbFadeOutAndHide(@sprites) { pbUpdate }
    #pbDisposeSpriteHash(@sprites)
    dispose
    Game.start_new
  end
  
  def confirm_delete
    blk = Sprite.new(@viewport)
    blk = Rect.new(0, 0, Graphics.width, Graphics.height)
    #blk.opacity = 0
    #blk.z = 999998
    confirm = Sprite.new(@viewport)
    confirm.bitmap(@path + "confirm")
    #confirm.height /= 3
    confirm.x = Graphics.width / 2
    confirm.y = Graphics.height / 2
    confirm.ox = confirm.bitmap.width / 2
    confirm.oy = confirm.bitmap.height / 6
    #confirm.opacity = 0
    #confirm.z = 999999
    for i in 0...16
      Graphics.update
      Input.update
      blk.opacity += 12
      confirm.opacity += 16
    end
    cfrm = 0
    loop do
      Graphics.update
      Input.update
      old = cfrm
      if cfrm == 0 && Input.trigger?(Input::DOWN)
        cfrm = 1
      elsif cfrm == 1
        cfrm = 0 if Input.trigger?(Input::UP)
        cfrm = 2 if Input.trigger?(Input::RIGHT)
      elsif cfrm == 2
        cfrm = 0 if Input.trigger?(Input::UP)
        cfrm = 1 if Input.trigger?(Input::LEFT)
      end
      if old != cfrm
        pbSEPlay("load_cursor")
        confirm.src_rect.y = cfrm * confirm.src_rect.height
      end
      if Input.trigger?(Input::C) && cfrm != 0
        break
      elsif Input.trigger?(Input::B)
        cfrm = 1
        break
      end
    end
    pbSEPlay("load_cursor")
    if cfrm == 1 # No
      
    elsif cfrm == 2 # Yes
      # Delete save
      filename = RTP.getSaveFileName("Game#{@save_index}.rxdata")
      if FileTest.exist?(filename)
        File.delete(filename)
      end
      @sel = 0
      @sprites["deletepanel"].deselect
    end
    for i in 0...16
      Graphics.update
      Input.update
      blk.opacity -= 16
      confirm.opacity -= 16
    end
    blk.dispose
    confirm.dispose
    if cfrm == 2
      load_save(@save_index)
    end
  end
  
  def options
    pbFadeOutIn(99999) do
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen(true)
    end
  end
  
  def mystery_gift
    pbFadeOutIn(99999) do
      trainer = pbDownloadMysteryGift($Trainer)
    end
  end
  
  def credits
    oldscene = $scene
    $scene = Scene_Credits.new
    Graphics.freeze
    @sprites.visible = false
    $scene.main
    $scene = oldscene
    @sprites.visible = true
    Graphics.transition
  end
  
  def quit_game
    Kernel.abort
  end
  
  def update
    @i ||= 0
    @i += 1
    for i in 0..6 do
      if @sprites["cartridgeparty#{i}"] && @i % 3 == 0
        @sprites["cartridgeparty#{i}"].update
      end
    end
    if @sprites["char"] && @i % 3 == 0
      @sprites["char"].update
    end
    @sprites.each do |k, v|
      next if k.include? ("cartridge")
      next if k.include? ("button")
      next if k == "char"
      v.update
    end
  end
  
  def dispose
    @disposed = true
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @sprites.each do |sprite|
      sprite.dispose
    end
    @viewport.dispose
  end
end