//=============================================================================
// VMDMapFixerM20.
//=============================================================================
class VMDMapFixerM20 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		case "CF_04_SUBWAY":
			//MADDERS, 4/5/24: Counterfeit end of campaign, as it comes screeching to a halt.
			NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-246, 111, -84), Rot(0, 16384, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = '';
			}
		break;
		//20_SECRET_BASE: Floating Alex in phase 2.
		case "20_SECRET_BASE":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (AlexJacobson(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.SetLocation(Vect(1323, 437, -2496));
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
