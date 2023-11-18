Battle::AbilityEffects::OnSwitchIn.add(:FROSTED,
  proc { |ability, battler, battle, switch_in|
    battler.effects[PBEffects::ExtraType] = :ICE
  }
)

Battle::AbilityEffects::MoveImmunity.add(:INTANGIBLE,
  proc { |ability, user, target, move, type, battle, show_message|

    if (type == :NORMAL || type == :FIGHTING) && !target.effects[PBEffects::Foresight] && !user.hasActiveAbility?(:SCRAPPY)
      if show_message
        battle.pbShowAbilitySplash(target)
        if Battle::Scene::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
        else
          battle.pbDisplay(_INTL("{1} avoided the attack with {2}!", target.pbThis, target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
    end
  end
    }
)

Battle::AbilityEffects::OnBeingHit.add(:RESILIENCE,
  proc { |ability, user, target, move, battle|
    next if !Effectiveness.super_effective?(target.damageState.typeMod)
    next if !target.pbCanRaiseStatStage?(:DEFENSE, target) &&
            !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, target)
      battle.pbShowAbilitySplash(target)
      target.pbRaiseStatStageByAbility(:DEFENSE, 1, target, false)
      target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE, 1, target, false)
      battle.pbHideAbilitySplash(target)
    }
)

Battle::AbilityEffects::OnEndOfUsingMove.add(:VAMPIRISM,
  proc { |ability, user, targets, move, battle|
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    battle.pbShowAbilitySplash(user)
    targets.each do |b| 
      amt = b.damageState.hpLost
      if b.hasActiveAbility?(:LIQUIDOOZE)
        battle.pbShowAbilitySplash(b)
        pbReduceHP(amt)
        battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
        battle.pbHideAbilitySplash(b)
      else
        msg = _INTL("{1} had its energy drained!", b.pbThis) if nil_or_empty?(msg)
        battle.pbDisplay(msg)
        if user.canHeal?
          amt = (amt * 1.3).floor if user.hasActiveItem?(:BIGROOT)
          user.pbRecoverHP(amt)
        end
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

Battle::AbilityEffects::OnBeingHit.add(:WINDSURFER,
  proc { |ability, user, target, move, battle|
    if move.calcType == :FLYING
      battle.pbShowAbilitySplash(target)
      target.pbRaiseStatStageByAbility(:SPEED, 1, target)
      battle.pbHideAbilitySplash(target)
    end
    if target.fainted? && target.stages[:SPEED] > 0
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} is surrounded by strong winds!", target))
      battle.positions[target.index].effects[PBEffects::WindSurfer] = target.stages[:SPEED]
      battle.pbHideAbilitySplash(target)
    end
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:WINDSURFER,
  proc { |ability, battler, endOfBattle|
    next if endOfBattle
    next if battler.stages[:SPEED] <= 0
    @battle.pbShowAbilitySplash(battler)
    @battle.pbDisplay(_INTL("{1} is surrounded by strong winds!", battler))
    @battle.positions[target.index].effects[PBEffects::WindSurfer] = battler.stages[:SPEED]
    @battle.pbHideAbilitySplash(battler)  }
)