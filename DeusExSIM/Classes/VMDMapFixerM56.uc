//=============================================================================
// VMDMapFixerM56.
//=============================================================================
class VMDMapFixerM56 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//UNDERGROUND_LAB: Stone chunks from glass tho. Why do I even bother with this one?
		case "UNDERGROUND_LAB":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if (BreakableWall(DXM) != None)
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 1:
							SetMoverFragmentType(DXM, "Glass");
						break;
					}
				}
			}
		break;
		//UNDERGROUND_LAB2: Some bugs here, but for now just NG plus.
		case "UNDERGROUND_LAB2":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if (DXM.Class == class'DeusExMover')
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 11:
							DXM.KeyRot[1].Yaw = -16384;
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
						break;
						case 12:
							DXM.KeyRot[1].Yaw = -24576;
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
						break;
					}
				}
			}
			
			//MADDERS, 3/2/25: Stupid bullshit abound, these are using attach tag, and not movertag.
			//Mapper error causes bad movement.
			A = FindActorBySeed(class'Switch1', 8);
			if (A != None)
			{
				A.bCollideWorld = false;
			}
			A = FindActorBySeed(class'Switch1', 9);
			if (A != None)
			{
				A.bCollideWorld = false;
			}
			
			//MADDERS, 6/21/24: Underground lab NG plus.
			NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(1913, -2120, -2860), Rot(0, -16384, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = 'DL_Finished_Played';
			}
		break;
	}
}

defaultproperties
{
}
