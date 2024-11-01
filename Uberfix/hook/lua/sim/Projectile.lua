local prevProjectile = Projectile

Projectile = Class(prevProjectile) {

    --Mithy: Check to make sure instigator is still alive before we do meta impact
    --I'm not actually sure why this needs to doing anything with instigator, but it is, so v0v
    DoMetaImpact = function(self)
        if self.DamageData.Instigator and not self.DamageData.Instigator:IsDead() then
            prevProjectile.DoMetaImpact(self)
        end
    end,

}