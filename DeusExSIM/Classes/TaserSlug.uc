//=============================================================================
// TaserSlug.
//=============================================================================
class TaserSlug extends DeusExProjectile;

#exec OBJ LOAD FILE=VMDAssets

auto simulated state Flying
{
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (bStickToWall)
		{
			HurtRadiusVMD(Damage, 32, DamageType, 0.0, Location, false);
			/*if (FRand() < 0.5)
			{
				Multiskins[0] = Texture'TaserSlugSpent';
			}
			else
			{
				SpawnAmmoClass = class'AmmoTaserSlug';
			}*/
			bIgnoresNanoDefense = True;
			
			PlaySound(Sound'DeusExSounds.Generic.BulletHitFlesh', SLOT_Interact);
			
			Velocity = vect(0,0,0);
			Acceleration = vect(0,0,0);
			SetPhysics(PHYS_None);
			bStuck = True;
			
			// MBCODE: Do this only on server side
			if ( Role == ROLE_Authority )
			{
            			if (Level.NetMode != NM_Standalone)
               				SetTimer(5.0,False);

				if (Wall.IsA('Mover'))
				{
					SetBase(Wall);
					Wall.TakeDamage(Damage*0.5, Pawn(Owner), Wall.Location, MomentumTransfer*Normal(Velocity), damageType);
				}
			}
		}
		
		if (Wall.IsA('BreakableGlass'))
			bDebris = False;
		
		SpawnEffects(Location, HitNormal, Wall);
		
		Super(Projectile).HitWall(HitNormal, Wall);
	}
}

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	// If the taser slug enters water, extingish it
	if (NewZone.bWaterZone)
		Destroy();
}

defaultproperties
{
     MoverDamageMult=0.000000
     bBlood=True
     bStickToWall=True
     DamageType=stunned
     spawnAmmoClass=None
     bIgnoresNanoDefense=False //MADDERS: This one has a funny interaction.
     ItemName="Taser Slug"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=3000.000000
     Damage=24.000000
     MomentumTransfer=1000
     ImpactSound=Sound'TaserSlugImpact'
     Mesh=LodMesh'VMDTaserSlug'
     CollisionRadius=2.000000
     CollisionHeight=0.500000
     LifeSpan=0.000000
}
