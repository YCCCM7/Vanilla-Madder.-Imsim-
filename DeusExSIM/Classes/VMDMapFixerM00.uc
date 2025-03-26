//=============================================================================
// VMDMapFixerM00.
//=============================================================================
class VMDMapFixerM00 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	//MADDERS: Stop making us killable. This is also a vanilla issue.
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((UNATCOTroop(SP) != None) && (SP.Tag != 'Test_Subject'))
		{
			SP.bInvincible = true;
		}
	}
	
	switch(MapName)
	{
		case "00_TRAINING":
			if (!bRevisionMapSet)
			{
			}
		break;
		case "00_TRAININGCOMBAT":
			if (!bRevisionMapSet)
			{
				//MADDERS: Whoops. LAM nerf just ruined this, so let's fix it real quick.
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (SecurityBot2(SP) != None)
					{
						SP.Health = 5;
					}
				}
				//Rule of thumb: Increase QOL on aiming pistols. Rifles demonstrate skill level.
				forEach AllActors(class'Skill', SK)
				{
					if (SkillDemolition(SK) != None)
					{
						SK.CurrentLevel = 2;
					}
				}
			}
		break;
		case "00_TRAININGFINAL":
			if (!bRevisionMapSet)
			{
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);	
					if (Terrorist(SP) != None)
					{
						SP.Multiskins[6] = Texture'BlackMaskTex';
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
