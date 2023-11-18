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

class Battle::Move::ApplyGyroSquallToTarget < Battle::Move
    def pbFailsAgainstTarget?(user, target, show_message)
      if target.effects[PBEffects::GyroSquall] > 0
        @battle.pbDisplay(_INTL("{1} is already in a squall!", target.pbThis)) if show_message
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user, target)
      return if target.fainted? || target.damageState.substitute
      return if target.effects[PBEffects::GyroSquall] > 0
      target.effects[PBEffects::GyroSquall] = 2
      @battle.pbDisplay(_INTL("{1} is facing a strengthening squall!", target.pbThis))
    end
  end