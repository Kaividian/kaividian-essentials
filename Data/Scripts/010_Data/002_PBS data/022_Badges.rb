module GameData
  class Badge
    attr_reader :id
    attr_reader :real_name
    attr_reader :badge_boost
    attr_reader :obedience
    attr_reader :field_moves
    attr_reader :pbs_file_suffix

    DATA = {}
    DATA_FILENAME = "badges.dat"
    PBS_BASE_FILENAME = "badges"
    
    SCHEMA = {
      "SectionName"       => [:id,                   "m"],
      "Name"              => [:real_name,            "s"],
      "BadgeBoost"        => [:badge_boost,          "*e", :Stat],
      "Obedience"         => [:obedience,            "u"],
      "FieldMoves"        => [:field_moves,          "*e", :Move],
      }

    extend ClassMethodsSymbols
    include InstanceMethods

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:real_name]        || "Unnamed"
      @badge_boost      = hash[:badge_boost]      || []
      @obedience        = hash[:real_description] || 10
      @field_moves      = hash[:field_moves]      || []
      @pbs_file_suffix  = hash[:pbs_file_suffix]  || ""
    end


    def self.editor_properties
      return [
        ["ID",                ReadOnlyProperty,        _INTL("The ID of the Badge.")],
        ["Name",              StringProperty,          _INTL("Name of the Badge.")],
        ["BadgeBoost",        StatProperty,            _INTL("Stats boosted by x1.1 for owning this badge.")],
        ["Obedience",         LimitProperty.new(100),  _INTL("Traded Pokemon will obey you up to this level.")],
        ["FieldMoves",        MoveProperty,            _INTL("Field move effect unlocked by owning this badge.")],
      ]
    end

    def name
      return pbGetMessageFromHash(MessageTypes::BADGE_NAMES, @real_name)
    end

    def ==(badge)
      return true if badge.id == @id
      false
    end
    
    alias eql? ==
    
    def hash
      @id.hash
    end
  end
end
