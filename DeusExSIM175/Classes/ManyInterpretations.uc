//=============================================================================
// There are many interpretations... Or... Something.
//=============================================================================
class ManyInterpretations extends DeusExCarcass;

function PostPostBeginplay()
{
 Super.PostPostBeginPlay();
 
 Multiskins[3] = ObtainRandomPanties(); //Many interpretations indeed.
}

function Texture ObtainRandomPanties()
{
 local int R;
 
 R = Rand(8);
 
 switch(R)
 {
  case 0: return Texture'LegsTex2'; break;
  case 1: return Texture'LegsTex1'; break;
  case 2: return Texture'Hooker1Tex1'; break;
  case 3: return Texture'Hooker2Tex1'; break;
  case 4: return Texture'SarahMeadTex3'; break;
  case 5: return Texture'NicoletteDuclareTex3'; break;
  case 6: return Texture'AssaultGun3rdTex1'; break; //Forget sexual assault, this is contextual assault!
  case 7: return Texture'AssaultShotgun3rdTex1'; break;
 }
}

defaultproperties
{
     bExplosive=True //Leaving this in for kicks!
     Mesh2=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB'
     Mesh3=LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC'
     Mesh=LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass'
     DrawScale=1.100000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.NicoletteDuClareTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.NicoletteDuClareTex0'
     MultiSkins(2)=Texture'PinkMaskTex'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.Hooker2Tex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.WIBTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=44.000000
     CollisionHeight=7.700000
}
