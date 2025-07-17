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
			//MADDERS, 4/29/25: Stop letting us trigger this early. Bad.
			A = FindActorBySeed(class'MapExit', 0);
			if (A != None)
			{
				A.SetCollision(False, False, False);
			}
			
			//MADDERS, 4/29/25: Stop us from trying to eat this unreachable corpse.
			A = FindActorBySeed(class'ThugMale2Carcass', 0);
			if (A != None)
			{
				DeusExCarcass(A).bBlockAnimalFoodRoutines = true;
			}
			
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
