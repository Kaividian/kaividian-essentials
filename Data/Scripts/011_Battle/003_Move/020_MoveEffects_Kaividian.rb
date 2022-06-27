#===============================================================================
# Entry hazard. Lays strange slime on the opposing side (max. 1 layer).
# (Strange Slime)
#===============================================================================
class Battle::Move::AddStrangeSlimeToFoeSide < Battle::Move
    def canMagicCoat?; return true; end
  
    def pbMoveFailed?(user, targets)
      if user.pbOpposingSide.effects[PBEffects::StrangeSlime]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOpposingSide.effects[PBEffects::StrangeSlime] = true
      @battle.pbDisplay(_INTL("Strange slime was spread all around {1}'s feet!",
                              user.pbOpposingTeam(true)))
    end
  end