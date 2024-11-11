//=============================================================================
// VMDHousingScriptedTexture
//=============================================================================
class VMDHousingScriptedTexture extends ScriptedTexture;

//var Actor NotifyActor;
//var() Texture SourceTexture;

/*simulated event RenderTexture(ScriptedTexture Tex)
{
 	local VMDHousingScriptedTextureManager TexTar;
 	local int UseX, UseY, DimX, DimY, UseU, UseV;
 	local ScriptedTexture UseTex;
 	
 	UseTex = Tex;
 	TexTar = VMDHousingScriptedTextureManager(UseTex.NotifyActor);
	
 	if ((TexTar != None) && (UseTex.SourceTexture != None))
 	{
		if (TexTar.CurLoadedTexture != None)
		{
			UseTex.SourceTexture = TexTar.CurLoadedTexture;
		}
		if (TexTar.CurLoadedPalette != None)
		{
			UseTex.Palette = TexTar.CurLoadedPalette;
		}
		
  		UseU = 0;
  		UseV = 0;
		
		//MADDERS, 4/18/22: Contained for observation.
  		//UseX = (TexTar.Location.X + TexTar.Location.Y) % UseTex.SourceTexture.USize;
  		//UseY = (TexTar.Location.Z) % UseTex.SourceTexture.VSize;
		UseX = 0 % UseTex.SourceTexture.USize;
		UseY = 0 % UseTex.SourceTexture.VSize;
		
  		DimX = UseTex.SourceTexture.UClamp;
  		DimY = UseTex.SourceTexture.VClamp;
  		UseTex.DrawTile(UseX, UseY, DimX, DimY, UseU, UseV, DimX, DimY, UseTex.SourceTexture, False);
 	}
}*/

/*native(473) final function DrawTile( float X, float Y, float XL, float YL, float U, float V, float UL, float VL, Texture Tex, bool bMasked );
native(472) final function DrawText( float X, float Y, string Text, Font Font );
native(474) final function DrawColoredText( float X, float Y, string Text, Font Font, color FontColor );
native(475) final function ReplaceTexture( Texture Tex );
native(476) final function TextSize( string Text, out float XL, out float YL, Font Font );*/

defaultproperties
{
}
