//=============================================================================
// VMDMapFixerM77.
//=============================================================================
class VMDMapFixerM77 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//77_ZODIAC_ENDGAME1: Floating Page in phase 2.
		case "77_ZODIAC_ENDGAME1":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (PaulDenton(SP) != None)
				{
					SP.Multiskins[6] = SP.Default.Multiskins[6];
					SP.Multiskins[7] = SP.Default.Multiskins[7];
				}
				else if (BobPage(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.SetLocation(Vect(-69, 1251, 816));
						break;
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
