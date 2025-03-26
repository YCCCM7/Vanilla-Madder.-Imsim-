//=============================================================================
// VMDMapFixerM60.
//=============================================================================
class VMDMapFixerM60 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//60_HONGKONG_GREASELPIT: Rogue turret.
		case "60_HONGKONG_GREASELPIT":
			/*forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = false;
				}
			}*/
		break;
		//60_HONGKONG_FORICHI: Floating bouncers after DXT model update.
		case "60_HONGKONG_FORICHI":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (TriadLumPath(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.SetLocation(Vect(579, 1117, -945));
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
