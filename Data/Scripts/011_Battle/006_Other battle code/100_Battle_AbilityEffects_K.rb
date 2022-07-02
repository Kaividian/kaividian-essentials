Battle::AbilityEffects::OnSwitchIn.add(:FROSTED,
  proc { |ability, battler, battle, switch_in|
    battler.effects[PBEffects::Type3] = :ICE
  }
)