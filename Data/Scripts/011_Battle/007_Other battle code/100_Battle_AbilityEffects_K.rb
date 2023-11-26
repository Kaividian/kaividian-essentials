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
    anyOoze = false
    targets.each do |b|
      if b.hasActiveAbility?(:LIQUIDOOZE)
        anyOoze = true
        break
      end
    end
    if anyOoze || user.canHeal?
        battle.pbShowAbilitySplash(user)
        targets.each do |b| 
          amt = b.damageState.totalHPLost
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
    end
  }
)

Battle::AbilityEffects::OnBeingHit.add(:SECONDWIND,
  proc { |ability, user, target, move, battle|
    showedSplash = false
    if move.calcType == :FLYING
      if !target.statStageAtMax?(:SPEED)
        showedSplash = true
        battle.pbShowAbilitySplash(target)        
        target.pbRaiseStatStage(:SPEED, 1, target)
      end
    end
    if target.fainted? && target.stages[:SPEED] > 0
      battle.pbShowAbilitySplash(target) if !showedSplash
      showedSplash = true
      battle.pbDisplay(_INTL("{1} is surrounded by strong winds!", target.pbThis))
      battle.positions[target.index].effects[PBEffects::WindSurfer] = target.stages[:SPEED]
    end
    battle.pbHideAbilitySplash(target) if showedSplash
  }
)

Battle::AbilityEffects::OnSwitchOut.add(:SECONDWIND,
  proc { |ability, battler, endOfBattle|
    next if endOfBattle
    next if battler.stages[:SPEED] <= 0
    battler.battle.pbShowAbilitySplash(battler)
    battler.battle.pbDisplay(_INTL("{1} is surrounded by strong winds!", battler.pbThis))
    battler.battle.positions[target.index].effects[PBEffects::WindSurfer] = battler.stages[:SPEED]
    battler.battle.pbHideAbilitySplash(battler)
  }
)