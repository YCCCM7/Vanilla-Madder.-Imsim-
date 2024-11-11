//=============================================================================
// VMDAmmo10mm.
//=============================================================================
class VMDAmmo10mm expands actor;

#exec MESH IMPORT MESH=Ammo10mm ANIVFILE=Models\VMDAmmo10mm_a.3d DATAFILE=Models\VMDAmmo10mm_d.3d X=0 Y=0 Z=0 LODSTYLE=10 LODFRAME=0 
#exec MESH ORIGIN MESH=Ammo10mm X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=0

#exec MESH SEQUENCE MESH=Ammo10mm SEQ=ALL    STARTFRAME=0 NUMFRAMES=250 RATE=24
#exec MESH SEQUENCE MESH=Ammo10mm SEQ=Still    STARTFRAME=0 NUMFRAMES=1 RATE=24

#exec MESHMAP NEW MESHMAP=Ammo10mm MESH=Ammo10mm
#exec MESHMAP SCALE MESHMAP=Ammo10mm X=0.003125 Y=0.003125 Z=0.003125

#exec TEXTURE IMPORT NAME=Ammo10mmTex.bmp FILE=Textures\Ammo10mmTex.PCX GROUP=Skins FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=Ammo10mm NUM=0 TEXTURE=Ammo10mmTex.bmp

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Ammo10mm
}