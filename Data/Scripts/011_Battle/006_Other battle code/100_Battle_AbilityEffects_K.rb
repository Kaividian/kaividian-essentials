Battle::AbilityEffects::OnSwitchIn.add(:FROSTED,
  proc { |ability, battler, battle, switch_in|
    battler.effects[PBEffects::Type3] = :ICE
  }
)

Battle::AbilityEffects::MoveImmunity.add(:INTANGIBLE,
  proc { |ability, user, target, move, type, battle, show_message|

    if (type == :NORMAL || type == :FIGHTING) && !target.effects[PBEffects::Foresight] && !user.hasActiveAbility?(:SCRAPPY)
      if show_message
        @battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} avoided the attack with {2}!", target.pbThis, target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
    end
  end
    }
)