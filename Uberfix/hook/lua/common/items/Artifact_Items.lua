--Mithy: Deathbringer now has IgnoreFacing, allowing it to be cast properly.
Ability.Item_Artifact_070_Target01.IgnoreFacing = true

# Orb of Veiled Storms - overwrite OnStartAbility to add ArmorImmune.
# A direct overwrite of data.ArmorImmune is not possible because it is declared local within the function.

Ability.Item_Artifact_110.OnStartAbility = function(self, unit, params)
    local pos = unit:GetPosition()

    pos[2] = GetSurfaceHeight(pos[1], pos[3]) - 0.25
    local data = {
        Instigator = unit,
        InstigatorBp = unit:GetBlueprint(),
        InstigatorArmy = unit:GetArmy(),
        Origin = pos,
        Radius = self.AffectRadius,
        Amount = 10,
        Category = 'METAINFANTRY',
    }
    MetaImpact(data)
    local data = {
        Instigator = unit,
        InstigatorBp = unit:GetBlueprint(),
        InstigatorArmy = unit:GetArmy(),
        Origin = unit:GetPosition(),
        Amount = self.Damage,
        Type = self.DamageType,
        DamageAction = self.Name,
        Radius = self.AffectRadius,
        DamageFriendly = false,
        DamageSelf = false,
        Group = 'UNITS',
        CanBeEvaded = false,
        CanCrit = false,
        CanBackfire = true,
        CanMagicResist = true,
        ArmorImmune = true,
    }
    local entities = GetEntitiesInSphere('UNITS', pos, self.AffectRadius )
    local affectedEntities = {}
    DamageArea(data)
end