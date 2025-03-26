//=============================================================================
// VMDMapFixerM72.
//=============================================================================
class VMDMapFixerM72 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//72_MUTATIONS1/3: Turrets are intended to be active, but are not. Fix this.
		case "72_MUTATIONS1":
			A = FindActorBySeed(class'Vase1', 0);
			if (A != None)
			{
				A.SetLocation(Vect(153, 3900, -38));
				A.SetBase(FindActorBySeed(class'CoffeeTable', 1));
				A.SetPhysics(PHYS_None);
			}
			
			//MADDERS, 2/28/25: Fix civvies losing their shit all the time.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (HumanCivilian(SP) != None)
				{
					DumbAllReactions(SP);
				}
			}
			forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = true;
				}
			}
		break;
		case "72_MUTATIONS3":
			//MADDERS, 2/28/25: Fix civvies losing their shit all the time.
			//Also, MJ12 dude is our friend and gets mad too easy..
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (HumanCivilian(SP) != None)
				{
					DumbAllReactions(SP);
				}
				else if ((MJ12Troop(SP) != None) && (SP.Alliance == 'MJ12Friend'))
				{
					SP.bReactProjectiles = false;
					SP.bHateShot = false;
				}
			}
			forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = true;
				}
			}
		break;
		case "72_MUTATIONS2":
		case "72_MUTATIONS4":
		case "72_MUTATIONS5":
		case "72_MUTATIONS6":
			//MADDERS, 2/28/25: Fix civvies losing their shit all the time.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (HumanCivilian(SP) != None)
				{
					DumbAllReactions(SP);
				}
			}
		break;
		//72_ZODIAC_BUENOSAIRES: Hiding portrait, in-line with prior changes.
		//2/18/25: Also, add some more path nodes for fuck's sake.
		case "72_ZODIAC_BUENOSAIRES":
			Spawn(class'PathNodeMobile',,, Vect(-1368,3886,-4272));
			Spawn(class'PathNodeMobile',,, Vect(-1390,4043,-4272));
			Spawn(class'PathNodeMobile',,, Vect(-1328,4225,-4272));
			Spawn(class'PathNodeMobile',,, Vect(-1720,4055,-4129));
			Spawn(class'PathNodeMobile',,, Vect(-1608,4105,-4100));
			Spawn(class'PathNodeMobile',,, Vect(1482,-2604,-4205));
			Spawn(class'PathNodeMobile',,, Vect(-603,-3055,-4145));
			Spawn(class'PathNodeMobile',,, Vect(-849,-3047,-4145));
			Spawn(class'PathNodeMobile',,, Vect(-829,-3451,-4159));
			Spawn(class'PathNodeMobile',,, Vect(-721,-3508,-4159));
			Spawn(class'PathNodeMobile',,, Vect(-938,-3555,-4159));
			Spawn(class'PathNodeMobile',,, Vect(-921,-3746,-4159));
			Spawn(class'PathNodeMobile',,, Vect(-703,-3701,-4159));
			Spawn(class'PathNodeMobile',,, Vect(-404,-3279,-4145));
			Spawn(class'PathNodeMobile',,, Vect(-402,-3595,-4149));
			Spawn(class'PathNodeMobile',,, Vect(-154,-3283,-4145));
			Spawn(class'PathNodeMobile',,, Vect(-152,-3382,-4145));
			Spawn(class'PathNodeMobile',,, Vect(18,-3378,-4145));
			Spawn(class'PathNodeMobile',,, Vect(25,-3271,-4145));
			Spawn(class'PathNodeMobile',,, Vect(1280,-2896,-3522));
			Spawn(class'PathNodeMobile',,, Vect(714,-3189,-3522));
			Spawn(class'PathNodeMobile',,, Vect(670,-3312,-3522));
			Spawn(class'PathNodeMobile',,, Vect(299,-3282,-3522));
			Spawn(class'PathNodeMobile',,, Vect(714,-3189,-3522));
			Spawn(class'PathNodeMobile',,, Vect(670,-3312,-3522));
			Spawn(class'PathNodeMobile',,, Vect(89,-2866,-3522));
			Spawn(class'PathNodeMobile',,, Vect(206,-2871,-3520));
			Spawn(class'PathNodeMobile',,, Vect(2185,-1890,-4180));
			Spawn(class'PathNodeMobile',,, Vect(1652,-1920,-3985));
			Spawn(class'PathNodeMobile',,, Vect(1235,-1959,-3985));
			Spawn(class'PathNodeMobile',,, Vect(522,-3003,-3985));
			Spawn(class'PathNodeMobile',,, Vect(860,-3177,-3985));
			Spawn(class'PathNodeMobile',,, Vect(1334,-3171,-3985));
			Spawn(class'PathNodeMobile',,, Vect(846,-3025,-4145));
			Spawn(class'PathNodeMobile',,, Vect(1209,-3020,-3985));
			Spawn(class'PathNodeMobile',,, Vect(1500,-2877,-3985));
			Spawn(class'PathNodeMobile',,, Vect(1513,-2481,-2985));
			Spawn(class'PathNodeMobile',,, Vect(1709,-2460,-3985));
			Spawn(class'PathNodeMobile',,, Vect(1708,-3028,-3761));
			Spawn(class'PathNodeMobile',,, Vect(1650,-3124,-3745));
			Spawn(class'PathNodeMobile',,, Vect(1365,-3115,-3745));
			Spawn(class'PathNodeMobile',,, Vect(100,-2270,-3985));
			Spawn(class'PathNodeMobile',,, Vect(152,-2445,-3985));
			Spawn(class'PathNodeMobile',,, Vect(516,-2486,-3985));
			Spawn(class'PathNodeMobile',,, Vect(-1038,-3561,-3984));
			Spawn(class'PathNodeMobile',,, Vect(-1303,-2824,-3985));
			Spawn(class'PathNodeMobile',,, Vect(-1658,-3919,-3985));
			Spawn(class'PathNodeMobile',,, Vect(563,-42,-3865));
			Spawn(class'PathNodeMobile',,, Vect(317,-47,-3805));
			Spawn(class'PathNodeMobile',,, Vect(285,-270,-3805));
			Spawn(class'PathNodeMobile',,, Vect(240,-182,-3201));
			Spawn(class'PathNodeMobile',,, Vect(237,-15,-3201));
			Spawn(class'PathNodeMobile',,, Vect(239,-39,-2927));
			Spawn(class'PathNodeMobile',,, Vect(238,-203,-2927));
			Spawn(class'PathNodeMobile',,, Vect(133,-270,-2503));
			Spawn(class'PathNodeMobile',,, Vect(-54,150,-2410));
			VMP.VMDRebuildPaths();
			
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 2:
							DXM.bHighlight = false;
						break;
						case 4:
							if (MoverIsLocation(DXM, vect(1328, -2160, -4176)))
							{
								PivAdd = vect(7, 3, 4);
								LocAdd = vect(-8, 2, 4);
								FrameAdd[0] = LocAdd;
								FrameAdd[1] = FrameAdd[0];
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
	}
}

defaultproperties
{
}
