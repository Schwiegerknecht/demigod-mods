-- Add angelic fury mode 5% speed
Buffs.HGSA01AngelicFuryBuff01.Affects.MoveMult = {Mult = 0.05}
Buffs.HGSA01AngelicFuryBuff02.Affects.MoveMult = {Mult = 0.05}
Buffs.HGSA01AngelicFuryBuff03.Affects.MoveMult = {Mult = 0.05}
Buffs.HGSA01AngelicFuryBuff04.Affects.MoveMult = {Mult = 0.05}

--update angelic fury skill description
Ability.HGSA01AngelicFury01.GetFurySpeed1 = function(self) return math.floor( Buffs['HGSA01AngelicFuryBuff01'].Affects.MoveMult.Mult * 100 ) end
Ability.HGSA01AngelicFury02.GetFurySpeed2 = function(self) return math.floor( Buffs['HGSA01AngelicFuryBuff02'].Affects.MoveMult.Mult * 100 ) end
Ability.HGSA01AngelicFury03.GetFurySpeed3 = function(self) return math.floor( Buffs['HGSA01AngelicFuryBuff03'].Affects.MoveMult.Mult * 100 ) end
Ability.HGSA01AngelicFury04.GetFurySpeed4 = function(self) return math.floor( Buffs['HGSA01AngelicFuryBuff04'].Affects.MoveMult.Mult * 100 ) end

Ability.HGSA01AngelicFury01.Description = 'Regulus enters a divine rage increasing his speed by [GetFurySpeed1]%. His bolts deal [GetDamage] extra damage and explode on contact. Costs [GetCostPerShot] Mana per shot.'
Ability.HGSA01AngelicFury02.Description = 'Regulus enters a divine rage increasing his speed by [GetFurySpeed2]%. His bolts deal [GetDamage] extra damage and explode on contact. Costs [GetCostPerShot] Mana per shot.'
Ability.HGSA01AngelicFury03.Description = 'Regulus enters a divine rage increasing his speed by [GetFurySpeed3]%. His bolts deal [GetDamage] extra damage and explode on contact. Costs [GetCostPerShot] Mana per shot.'
Ability.HGSA01AngelicFury04.Description = 'Regulus enters a divine rage increasing his speed by [GetFurySpeed4]%. His bolts deal [GetDamage] extra damage and explode on contact. Costs [GetCostPerShot] Mana per shot.'

--Update angelic fury buff description
Buffs.HGSA01AngelicFuryBuff01.Description = 'Movement Speed increased. Damage increased. Each shot drains Mana.'
Buffs.HGSA01AngelicFuryBuff02.Description = 'Movement Speed increased. Damage increased. Each shot drains Mana.'
Buffs.HGSA01AngelicFuryBuff03.Description = 'Movement Speed increased. Damage increased. Each shot drains Mana.'
Buffs.HGSA01AngelicFuryBuff04.Description = 'Movement Speed increased. Damage increased. Each shot drains Mana.'

--Increase Maim 2 and 3 to 10% and 15% snare (normally 7 and 10)
Buffs.HGSA01Maim02.Affects.MoveMult.Mult = -0.10
Buffs.HGSA01Maim03.Affects.MoveMult.Mult = -0.15
 
--Increase Deadeye Proc Chance to 10% normally 3
Ability.HGSA01Deadeye01.WeaponProcChance = 10
