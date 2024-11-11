//=============================================================================
// ScubaDiver.
//=============================================================================
class ScubaDiver extends HumanCivilian;

// Transcended - Don't turn into a T-pose if you take gas damage, bloody hell
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if ((!bCollideActors) && (!bBlockActors) && (!bBlockPlayers))
		return;
	else if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage'))
		GotoNextState();
	else if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

defaultproperties
{
     bDoesntSniff=True
     SmellTypes(0)=""
     SmellTypes(1)=""
     SmellTypes(2)=""
     SmellTypes(3)=""
     SmellTypes(4)=""
     SmellTypes(5)=""
     SmellTypes(6)=""
     SmellTypes(7)=""
     
     bAerosolImmune=True
     CarcassType=Class'DeusEx.ScubaDiverCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     UnderWaterTime=-1.000000
     Texture=Texture'DeusExCharacters.Skins.ScubasuitTex1'
     Mesh=LodMesh'DeusExCharacters.GM_Scubasuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.ScubasuitTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.ScubasuitTex0'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.ScubasuitTex1'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="ScubaDiver"
     FamiliarName="Scuba Diver"
     UnfamiliarName="Scuba Diver"
     
     AmbientSound=Sound'DeusExSounds.Pickup.RebreatherLoop'
     SoundRadius=32
     SoundVolume=160
     bFearShot=False // Transcended - Now fearless
     bFearIndirectInjury=False
     bFearCarcass=False
     bFearDistress=False
     bFearAlarm=False
}
