//=============================================================================
// JordanShea.
//=============================================================================
class JordanShea extends HumanCivilian;

defaultproperties
{
     bAugsGuardDown=True
     Energy=75
     EnergyMax=75
     bHasAugmentations=True
     bMechAugs=True
     DefaultAugs(0)=class'AugMechDermal'
     DefaultAugs(1)=class'AugMechEnviro'
     DefaultAugs(2)=class'AugMechTarget'
     DefaultAugs(3)=class'AugMechCombat'
     
     CarcassType=Class'DeusEx.JordanSheaCarcass'
     WalkingSpeed=0.296000
     bImportant=True
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponSawedOffShotgun')
     InitialInventory(1)=(Inventory=Class'DeusEx.AmmoTaserSlug',Count=1)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCrowbar',Count=1)
     InitialInventory(3)=(Inventory=Class'DeusEx.WeaponEMPGrenade',Count=1)
     InitialInventory(4)=(Inventory=Class'DeusEx.BioelectricCell',Count=2)
     walkAnimMult=1.000000
     bIsFemale=True
     GroundSpeed=200.000000
     Health=250
     HealthHead=250
     HealthTorso=250
     HealthLegLeft=250
     HealthLegRight=250
     HealthArmLeft=250
     HealthArmRight=250
     Mesh=LodMesh'TranscendedModels.TransGFM_TShirtPants'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.JordanSheaTex0'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.JordanSheaTex0'
     MultiSkins(3)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(4)=Texture'DeusExItems.Skins.BlackMaskTex'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.JordanSheaTex0'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.PantsTex5'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.JordanSheaTex1'
     CollisionRadius=20.000000
     CollisionHeight=43.000000
     BindName="JordanShea"
     FamiliarName="Jordan Shea"
     UnfamiliarName="Jordan Shea"
     NameArticle=" "
}
