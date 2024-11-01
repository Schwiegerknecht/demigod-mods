Ability.AchievementTeleport.Cooldown = 30 --Reduce Amulet of Teleport cooldown to 30 from 45
Ability.AchievementAEHeal.CastingTime = 1 -- Reduce Blood Soaked wand castingtime to 1 down from 2
Ability.AchievementAEHeal.CastAction = 'CastItem1sec' --Switch blood soaked wand cast animation to 1 second (because we reduced it from 2)
Buffs.AchievementMovement.Affects.MoveMult.Mult = 0.10 -- Increase Saam-El's clock speed bonus to 10%, up from 5%
Buffs.AchievementCooldown.Affects.Cooldown.Mult = -.13 -- Decrease diamond Pendant cooldown by 13%, up from 10%
Buffs.AchievementCooldown.Affects.MaxEnergy.Add = 525 -- Increase diamond pendant mana bonus to 525 up from 250 (this item was way out of balance whack compared to Staff of renewal, and is even now still weaker)
Buffs.AchievementDeathReduction.Affects.Regen.Add = 10 -- Increase Charm of Life health regeneration to 10 up from 5
Buffs.AchievementFlurryPassive.Affects.MaxHealth.Add = 250 -- Increase Furious Blade health bonus to 250 up from 100
Buffs.AchievementMinionDodge.Affects.Evasion.Add = 20 -- Increase pendant of grace demigod dodge to 20% up from 10%
Buffs.AchievementMinionEvasionBuff.Affects.Evasion.Add = 20 -- Increase pendant of grace minion dodge to 20% up from 15%
Ability.AchievementMinionInvis.Cooldown = 45 -- Decrease Cloak of Night cooldown to 45 down from 60
Buffs.AchievementHealth.Affects.MaxHealth.Add = 600 -- Reduce Blood of the Fallen to 600 health down from 800
Buffs.AchievementMana.Affects.MaxEnergy.Add = 1050 --Staff of the Warmage, increase mana to 1050 up from 800
Ability.AchievementAEMana.AffectRadius = 15 -- Cape of Plentiful Mana: Increase affect radius from 8 to 15, so this item is easier to use
Ability.AchievementAERegen.AffectRadius = 15 --Increase Wings of the Seraphim affect radius from 8 to 15 so this item is easier to use on teams     
Buffs.AchievementSnarePassive.Affects.RateOfFire.Mult = .10 -- Poison Dagger attack speed 10% up from 5%,
Ability.AchievementFreeSpells.Cooldown = 30 --Essence of Magic reduce cooldown timer to 30

--Add +250 health and +175 mana to Brillant Bauble and update description
Buffs.AchievementXPIncome.Affects.MaxHealth = {Add = 250, AdjustEnergy = true}
Buffs.AchievementXPIncome.Affects.MaxEnergy = {Add = 175}
Items.AchievementXPIncome.GetHealthBonus = function(self) return Buffs.AchievementXPIncome.Affects.MaxHealth.Add end
Items.AchievementXPIncome.GetManaBonus = function(self) return Buffs.AchievementXPIncome.Affects.MaxEnergy.Add end
if not Items.AchievementXPIncome.Tooltip.Bonuses then 
	Items.AchievementXPIncome.Tooltip.Bonuses = {}
end
table.insert(Items.AchievementXPIncome.Tooltip.Bonuses, '+[GetHealthBonus] Health')
table.insert(Items.AchievementXPIncome.Tooltip.Bonuses, '+[GetManaBonus] Mana')

--Increase Charred Totem of War damage bonus to 30 up from 15 
--add 5% Attack Bonus to Charred Totem of War minions and update description
Buffs.AchievementMinionDamage.Affects.DamageRating.Add = 30
Buffs.AchievementMinionDamageBuff.Affects.RateOfFire = {Mult = 0.05}
Items.AchievementMinionDamage.GetMinionAttackSpeedBonus = function(self) return math.floor( Buffs['AchievementMinionDamageBuff'].Affects.RateOfFire.Mult * 100 ) end
table.insert(Items.AchievementMinionDamage.Tooltip.MBonuses, '+[GetMinionAttackSpeedBonus]% Minion Attack Speed')

--Horn of battle +100 life over 10 seconds / normally 50 over 20 seconds
Buffs.AchievementMinionInvulnBuff.Affects.Regen.Add = 100
Buffs.AchievementMinionInvulnBuff.Duration = 10

--Bejeweled Goggle; Crit: 10% chance to do 1.5 damage
--Prepend the crit chance and proc adjustment to the description
local critpassive = '[GetCritChance]% chance to deal a critical strike for [GetCritDamage]x damage.'
Items.AchievementVision.Tooltip.Passives = critpassive .. '\n\n' .. Items.AchievementVision.Tooltip.Passives

--Add the crit chance display functions (the string.format parameter '%.2f' rounds floating point numbers to 2 decimals)
Items.AchievementVision.GetCritChance = function(self) return Ability['AchievementVision_Crit'].CritChance end
Items.AchievementVision.GetCritDamage = function(self) return Ability['AchievementVision_Crit'].CritMult end

--Add the crit ability
table.insert(Items.AchievementVision.Abilities, AbilityBlueprint {
	Name = 'AchievementVision_Crit',
	AbilityType = 'WeaponCrit',
	CritChance = 10,
	CritMult = 1.5,
	Icon = '/NewIcons/AchievementRewards/PolishedCrystalGoggles',
})
--End of goggle change

