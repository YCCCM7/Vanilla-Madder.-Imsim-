//=============================================================================
// VMDMapFixer.
// Hi. WCCC here. I want to apologize for the utter nonsense that is this class.
// As far as I can tell, it doesn't murk performance in any noticable way, as it's only ever ran once.
// I've used switch/cases and minimized AllActor calls when practically possible... But better can be done.
// My rationale for using this actor is largely to fix non-patched maps and to fix other mods.
// In theory, I can use this with non-linear tweaks along the way, but so far this is not the case.
// I'm sure one day this'll get me canceled harder than those times I said the Z word on twitter.
//=============================================================================
class VMDMapFixer extends VMDFillerActors;

var float FixTimer;
var bool bRanFixes;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var bool bRevisionMapSet;

//Localized strings for any keys we add, usually for patching purposes.
var localized string VMDPatchedTruckDesc;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function Conversation GetConversation(Name conName)
{
    	local Conversation c;
	
    	foreach AllObjects(class'Conversation', c)
	{
        	if(c.conName == conName) return c;
    	}
	
    	return None;
}

static function FixConversationGiveItem(Conversation c, string fromName, Class<Inventory> fromClass, Class<Inventory> to)
{
    	local ConEvent e;
    	local ConEventTransferObject t;
	
    	if (c == None) return;
	
    	for(e=c.eventList; e!=None; e=e.nextEvent)
	{
        	t = ConEventTransferObject(e);
        	if(t == None) continue;
		
        	if((t.objectName == fromName) && (t.giveObject == fromClass))
		{
            		t.objectName = string(to.name);
            		t.giveObject = to;
        	}
    	}
}

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (!bRanFixes)
	{
 		if (FixTimer < 0.5)
		{
			FixTimer += DT;
		}
		else if (FixTimer > -10)
 		{
 	 		FixTimer = -30;
			CommitMapFixing();
	 	}
	}
}

//MADDERS: Shortcut for spawning oodles of these things in training.
function SpawnSpeechBubble(Vector NewLocation, int NewIndex, bool NewbUnlit, optional bool bExplodes)
{
	local VMDSpeechBubble SB;
	
	SB = Spawn(class'VMDSpeechBubble',,,NewLocation);
	if (SB != None)
	{
		SB.TipIndex = NewIndex;
		SB.bUnlit = NewbUnlit;
		
		SB.UpdateWrittenData();
		if (bExplodes)
		{
			SB.SpawnExplosionEffect();
		}
	}
}

//MADDERS: Use this for finding actors at locations.
function bool IsApproximateLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 3) && (ALoc.X > TestLoc.X - 3) && (ALoc.Y < TestLoc.Y + 3) && (ALoc.Y > TestLoc.Y - 3) && (ALoc.Z < TestLoc.Z + 10) && (ALoc.Z > TestLoc.Z - 10));
}

//MADDERS: Use this for finding actors at locations.
function bool MoverIsLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 0.5) && (ALoc.X > TestLoc.X - 0.5) && (ALoc.Y < TestLoc.Y + 0.5) && (ALoc.Y > TestLoc.Y - 0.5) && (ALoc.Z < TestLoc.Z + 0.5) && (ALoc.Z > TestLoc.Z - 0.5));
}

//Similar to above, but we only do this
function bool ItemIsLocation(Actor A, Vector TestLoc)
{
	local Vector ALoc;
	
	if (A == None) return false;
	
	ALoc = A.Location;
	return ((ALoc.X < TestLoc.X + 1.5) && (ALoc.X > TestLoc.X - 1.5) && (ALoc.Y < TestLoc.Y + 1.5) && (ALoc.Y > TestLoc.Y - 1.5));
}

function Actor AddBSPPlug(vector SpawnLoc, float Radius, float Height)
{
	local Actor A;
	
	A = Spawn(Class'VMDDynamicBlocker',,,SpawnLoc);
	if (A != None)
	{
		A.SetCollisionSize(Radius, Height);
	}
	
	return A;
}

function Actor CreateHallucination(vector SpawnLoc, int UnlockIndex, bool bIsHidden)
{
	local VMDHallucination Hally;
	
	Hally = Spawn(class'VMDHallucination',,,SpawnLoc);
	if (Hally != None)
	{
		Hally.UnlockIndex = UnlockIndex;
		Hally.bHidden = bIsHidden;
	}
	
	return Hally;
}

function bool GetFlagBool(name FlagName)
{
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(GetPlayerPawn());
	
	if ((DXP != None) && (DXP.FlagBase != None))
	{
		return DXP.FlagBase.GetBool(FlagName);
	}
	
	return false;
}

function SetMoverFragmentType(DeusExMover DXM, string MaterialClass)
{
	if (DXM == None) return;
	
	MaterialClass = CAPS(MaterialClass);
	
	switch(MaterialClass)
	{
		case "GLASS":
     			DXM.ExplodeSound1 = Sound'GlassBreakSmall';
     			DXM.ExplodeSound2 = Sound'GlassBreakLarge';
			DXM.FragmentClass = class'GlassFragment';
		break;
		case "METAL":
     			DXM.ExplodeSound1 = Sound'MediumExplosion1';
     			DXM.ExplodeSound2 = Sound'MediumExplosion1';
			DXM.FragmentClass = class'MetalFragment';
		break;
		case "PLASTIC":
     			DXM.ExplodeSound1 = Sound'PlasticHit1';
     			DXM.ExplodeSound2 = Sound'GlassBreakSmall';
			DXM.FragmentClass = class'PlasticFragment';
		break;
		case "WOOD":
     			DXM.ExplodeSound1 = Sound'WoodBreakSmall';
     			DXM.ExplodeSound2 = Sound'WoodBreakLarge';
			DXM.FragmentClass = class'WoodFragment';
		break;
	}
}

function DumbAllReactions(ScriptedPawn SP)
{
	if (SP == None) return;
	
	SP.bReactFutz = False;
	SP.bReactPresence = False;
	SP.bReactLoudNoise = False;
	SP.bReactAlarm = False;
	SP.bReactShot = False;
	//SP.bReactGore = False;
	SP.bReactCarcass = False;
	SP.bReactDistress = False;
	SP.bReactProjectiles = False;
	SP.bFearHacking = False;
	SP.bFearWeapon = False;
	SP.bFearShot = False;
	SP.bFearInjury = False;
	SP.bFearIndirectInjury = False;
	SP.bFearCarcass = False;
	SP.bFearDistress = False;
	SP.bFearAlarm = False;
	SP.bFearProjectiles = False;
}

//MADDERS, 12/21/23: Having our cake and eating it, too. When DX rando chair size creates jank, undo it selectively.
function UnRandoSeat(Seat TargetSeat)
{
	if (TargetSeat == None) return;
	
	//NOTE: We do some 0.75 fudge for collision size tweak in Engine.Actor, and some 1.5 fudge for how that impacts both ends of our placement.
	switch(TargetSeat.Class.Name)
	{
		case 'Chair1':
			TargetSeat.SitPoint[0] = Vect(0,-6,-4.5);
			TargetSeat.SetLocation(TargetSeat.Location + vect(0,0,34.33996) - vect(0,0,1.5) - TargetSeat.PrePivot);
			TargetSeat.PrePivot = Vect(0,0,0);
			TargetSeat.SetCollisionSize(23, 33.169998 - 0.75);
		break;
		case 'OfficeChair':
			TargetSeat.SitPoint[0] = Vect(0,-4,0);
			TargetSeat.SetLocation(TargetSeat.Location + vect(0,0,20) - vect(0,0,1.5) - TargetSeat.PrePivot);
			TargetSeat.PrePivot = Vect(0,0,0);
			TargetSeat.SetCollisionSize(16, 25.549999 - 0.75);
		break;
	}
}

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing()
{
	//Parent class junk.
	local Actor A;
	local DeusExDecoration DXD;
 	local DeusExLevelInfo LI;
	local DeusExWeapon DXW;
	local Inventory TInv;
	local Pawn TPawn;
	local ScriptedPawn SP;
	local Seat TSeat;
	local VMDBufferDeco VMD;
	local VMDBufferPlayer VMP;
	
	//Door stuff.
	local vector FrameAdd[8], LocAdd, PivAdd, TestLoc;
	local DeusExMover DXM;
	local Mover TMov;
	
	//Universal bits and bobs.
	local bool FoundFlag;
	local float Diff;
	local int GM, i;
	local string MN;
	local Rotator TRot;
	local Vector PlugVect;
	local Texture FilTex[8];
	
	//Semi-vague classes.
	local Computers Comp;
	local Keypad KP;
	local Light Lig;
	local MapExit MapEx;
	local Nanokey Key;
	local PatrolPoint Pat, StoredPats[3];
	
	//Specific classes
	local AllianceTrigger ATrig;
	local AutoTurret ATur;
	local AutoTurretSmall SATur;
	local ConversationTrigger ConTrig;
	local CrateExplosiveSmall CExpSmall;
	local Credits Cred;
	local DatalinkTrigger DataTrig;
	local Dispatcher TDispatch;
	local ElectronicDevices ED;
	local FlagTrigger FT;
	local OrdersTrigger OTrig;
	local SkillAwardTrigger SAT;
	local VMDCabinetCampActor TCamp;
	local VMDNGPlusPortal NGPortal;
	local WeaponBaton Bat;
	
	//MADDERS: Used for training purposes.
	local Ammo10mm TenMil;
	local Ammo3006 ThirtyOught;
	local DataCube DC;
	local Skill SK;
	
	//MADDERS, 11/1/21: LDDP stuff.
	local class<DeusExCarcass> DXCLoad;
	local class<DeusExWeapon> LDXW;
	local class<ScriptedPawn> SPLoad;
	local class<VMDStaticFunctions> SF;
	local DeusExCarcass DXC;
	local FlagBase Flags;
	
	SF = class'VMDStaticFunctions';
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.FlagBase != None))
	{
		Flags = VMP.FlagBase;
	}
	
 	forEach AllActors(Class'DeusExLevelInfo', LI) break;
	GM = LI.MissionNumber;
	if (GM > 98) // || GM == 0
	{
		Lifespan = 1;
		return;
	}
	MN = VMDGetMapName();
	
	//MADDERS, 4/15/21: Accurate setup for HC movers. Yeah it's trash, but it's reliable.
	forEach AllActors(class'Mover', TMov)
	{
		if ((TMov != None) && (TMov.IsA('CBreakableGlass')))
		{
			TMov.BlendTweenRate[0] = float(TMov.GetPropertyText("DoorStrength"));
		}
	}
	
	switch(GM)
	{
		//TRAINING: Add these various tips to training, to clue people in.
		case 0:
			//MADDERS: Stop making us killable. This is also a vanilla issue.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if ((UNATCOTroop(SP) != None) && (SP.Tag != 'Test_Subject'))
				{
					SP.bInvincible = true;
				}
			}
			
			switch(MN)
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
		break;
		case 1:
			switch(MN)
			{
				//01_NYC_UNATCOISLAND: Add a datalink and fix lack of baton in GOTY.
				case "01_NYC_UNATCOISLAND":
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (UNATCOTroop(SP) != None)
						{
							SP.ChangeAlly('Gunther', 1.0, true);
						}
						else if (SecurityBot2(SP) != None)
						{
							switch(SF.Static.StripBaseActorSeed(SP))
							{
								case 3:
									SP.bHateDistress = false;
								break;
							}
							SP.ChangeAlly('Gunther', 1.0, true);
						}
						else if (PaulDenton(SP) != None)
						{
							SP.ChangeAlly('Gunther', 1.0, true);
						}
						else if (GuntherHermann(SP) != None)
						{
							SP.Alliance = 'Gunther';
							SP.ChangeAlly('Gunther', 1.0, true);
							SP.ChangeAlly('UNATCO', 1.0, true);
						}
					}
					
					if (!bRevisionMapSet)
					{
						FoundFlag = false;
						forEach AllActors(class'WeaponBaton', Bat)
						{
							if ((Bat != None) && (IsApproximateLocation(Bat, vect(-2911, 6977, -239))))
							{
								FoundFlag = true;
							}
						}
						if (!FoundFlag)
						{
							Spawn(class'WeaponBaton',,,vect(-2911,6977,-239));
						}
						
						//MADDERS: Ugly shit for installing a new trigger last minute.
						//UPDATE: This is based in confix until further notice. Don't fuck with it for now.
						//----------------
						//Closest to door
						/*DataTrig = Spawn(class'DatalinkTrigger',,,vect(-1030,167,-100));
						if (DataTrig != None)
						{
							DataTrig.Tag = 'VMDBotPatchedLink1';
							DataTrig.bCollideActors = false;
							DataTrig.bCheckFalse = false;
							DataTrig.CheckFlag = 'StatueMissionComplete';
							DataTrig.DatalinkTag = 'DL_';
						}
						FT = Spawn(Class'FlagTrigger',,,DataTrig.Location);
						if (FT != None)
						{
							FT.Event = 'VMDBotPatchedLink1';
							FT.bTrigger = true;
							FT.bSetFlag = false;
							FT.FlagName = 'DL_FrontEntranceBot_Played';
							FT.FlagValue = false;
							FT.SetCollisionSize(2000, FT.CollisionHeight);
						}
						
						//Furthest from door
						DataTrig = Spawn(class'DatalinkTrigger',,,vect(-2361,154,-100));
						if (DataTrig != None)
						{
							DataTrig.Tag = 'VMDBotPatchedLink2';
							DataTrig.bCollideActors = false;
							DataTrig.bCheckFalse = false;
							DataTrig.CheckFlag = 'StatueMissionComplete';
							DataTrig.DatalinkTag = 'DL_';
						}
						FT = Spawn(Class'FlagTrigger',,,DataTrig.Location);
						if (FT != None)
						{
							FT.Event = 'VMDBotPatchedLink2';
							FT.bTrigger = true;
							FT.bSetFlag = false;
							FT.FlagName = 'DL_FrontEntranceBot_Played';
							FT.FlagValue = false;
							FT.SetCollisionSize(600, FT.CollisionHeight);
						}
						
						//INSIDE statue front door
						DataTrig = Spawn(class'DatalinkTrigger',,,vect(-746,123,-100));
						if (DataTrig != None)
						{
							DataTrig.Tag = 'VMDBotPatchedLink3';
							DataTrig.bCollideActors = false;
							DataTrig.bCheckFalse = false;
							DataTrig.CheckFlag = 'StatueMissionComplete';
							DataTrig.DatalinkTag = 'DL_';
						}
						FT = Spawn(Class'FlagTrigger',,,DataTrig.Location);
						if (FT != None)
						{
							FT.Event = 'VMDBotPatchedLink3';
							FT.bTrigger = true;
							FT.bSetFlag = false;
							FT.FlagName = 'DL_FrontEntranceBot_Played';
							FT.FlagValue = false;
							FT.SetCollisionSize(600, FT.CollisionHeight);
						}*/
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("DeusEx.UNATCOTroop", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'UNATCOTroop',vect(-4721,2039,-191), rot(0,-31072,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.BindName = "LDDPPrivateNash";
									SP.BarkBindName = "UNATCOTroop";
									SP.Alliance = 'UNATCO';
									SP.InitialAlliances[0].AllianceName = 'Player';
									SP.InitialAlliances[0].AllianceLevel = 1.0;
									SP.ConBindEvents();
								}
								SP = Spawn(SPLoad,,'UNATCOTroop',vect(-4782,2023,-191), rot(0,35184,0));
								if (SP != None)
								{
									SP.SetOrders('Sitting','ChairLeather', true);
									SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 2));
									SP.BindName = "LDDPPrivateWills";
									SP.BarkBindName = "UNATCOTroop";
									SP.Alliance = 'UNATCO';
									SP.InitialAlliances[0].AllianceName = 'Player';
									SP.InitialAlliances[0].AllianceLevel = 1.0;
									SP.ConBindEvents();
								}
							}
						}
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 16:
									case 17:
										DXM.bIsDoor = false;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//01_NYC_UNATCOHQ: First easter egg, and return encroach type on Manderley's door.
				case "01_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/17/24: Gunther gives us back our loaned weapon, with interest. Yay.
						if ((VMP != None) && (VMP.LastGenerousWeaponClass != "NULL"))
						{
							LDXW = class<DeusExWeapon>(DynamicLoadObject(VMP.LastGenerousWeaponClass, class'Class', true));
							if (LDXW != None)
							{
								A = Spawn(class'CrateUnbreakableSmall',,, vect(-397,1385,256), Rot(0, 8192, 0));
								A = Spawn(class'Datacube',,, vect(-397,1348,242));
								if (A != None)
								{
									Datacube(A).TextPackage = "VMDText";
									Datacube(A).TextTag = '01_GuntherThanks';
								}
								
								DXW = Spawn(LDXW,,, vect(-397,1385,276));
								if (DXW != None)
								{
									A = Spawn(class'WeaponModAccuracy',,, Vect(-397,1385,296));
									
									DXW.PickupAmmoCount = 0;
									
									if (VMP.LastGenerousWeaponModSilencer > 0) DXW.bHasSilencer = true;
									if (VMP.LastGenerousWeaponModScope > 0) DXW.bHasScope = true;
									if (VMP.LastGenerousWeaponModLaser > 0) DXW.bHasLaser = true;
									
									DXW.ModBaseAccuracy = VMP.LastGenerousWeaponModAccuracy;
									if (DXW.BaseAccuracy == 0.0)
									{
										DXW.BaseAccuracy -= DXW.ModBaseAccuracy;
									}
									else
									{
										DXW.BaseAccuracy -= (DXW.Default.BaseAccuracy * DXW.ModBaseAccuracy);
									}
									
									DXW.ModReloadCount = VMP.LastGenerousWeaponModReloadCount;
									Diff = Float(DXW.Default.ReloadCount) * DXW.ModReloadCount;
									DXW.ReloadCount += Max(Diff, DXW.ModReloadCount / 0.1);
									
									DXW.ModAccurateRange = VMP.LastGenerousWeaponModAccurateRange;
									DXW.RelativeRange += (DXW.Default.RelativeRange * DXW.ModAccurateRange);
									DXW.AccurateRange += (DXW.Default.AccurateRange * DXW.ModAccurateRange);
									
									DXW.ModReloadTime = VMP.LastGenerousWeaponModReloadTime;
									DXW.ReloadTime += (DXW.Default.ReloadTime * DXW.ModReloadTime);
									if (DXW.ReloadTime < 0.0) DXW.ReloadTime = 0.0;
									
									DXW.ModRecoilStrength = VMP.LastGenerousWeaponModRecoilStrength;
									DXW.RecoilStrength += (DXW.Default.RecoilStrength * DXW.ModRecoilStrength);
									
									if (VMP.LastGenerousWeaponModEvolution > 0)
									{
										DXW.bHasEvolution = true;
										DXW.VMDUpdateEvolution();
									}
								}
							}
						}
						VMP.VMDClearGenerousWeaponData();
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (SP != None)
							{
								SP.bFearHacking = false;
								SP.bHateHacking = false;
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(364,1113,280);
							TCamp.MaxCampLocation = Vect(418,1133,328);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
							{
								SP = ScriptedPawn(TPawn);
								if (Female2(SP) != None)
								{
									SP.Destroy();
								}
							}
							
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPChet',vect(140,173,40));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
									SP.InitialInventory[0].Count = 1;
									SP.InitialInventory[1].Inventory = class'AmmoPepper';
									SP.InitialInventory[1].Count = 8;
									SP.BindName = "LDDPChet";
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}

						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 10:
										DXM.MoverEncroachType = ME_ReturnWhenEncroach;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						CreateHallucination(vect(-258, 1265, 290), 0, false);
					}
				break;
			}
		break;
		case 2:
			switch(MN)
			{
				//02_NYC_BATTERYPARK: Unlock the side access, to make it a truly naked solution.
				//Also: Large crates are inside the ground apparently, so WTF.
				case "02_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 6:
										DXM.bLocked = false;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						forEach AllActors(class'DeusExDecoration', DXD)
						{
							if (CrateUnbreakableLarge(DXD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(DXD))
								{
									case 16:
									case 17:
									case 18:
										DXD.SetLocation(DXD.Location + vect(0,0,16));
									break;
								}
							}
						}
						//4/13/23: Fix for civvies freaking the fuck out.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (HumanCivilian(SP) != None)
							{
								HumanCivilian(SP).bHateShot = False;
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBatParkOldBum", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPBatParkOldbum',vect(2030,-3547,297), rot(0,-16408,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.BarkBindName = "Man";
									SP.UnfamiliarName = "Bum";
									SP.InitialAlliances[0].AllianceName = 'Player';
									SP.InitialAlliances[1].AllianceLevel = 1.0;
									SP.InitialAlliances[2].AllianceName = 'UNATCO';
									SP.InitialAlliances[2].bPermanent = True;
									SP.InitialAlliances[3].AllianceName = 'NSF';
									SP.InitialAlliances[3].AllianceLevel = -1.0;
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//02_NYC_BAR: LDDP stuff.
				case "02_NYC_BAR":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBarFly", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1308,319,52));
								if (SP != None)
								{
									SP.SetOrders('Sitting',, true);
									SP.BarkBindName = "Man";
									SP.UnfamiliarName = "Bar Fly";
									SP.SeatActor = Seat(FindActorBySeed(class'Chair1', 4));
									SP.FamiliarName = "Liam";
									SP.bFearWeapon = True;
									SP.bFearInjury = True;
									SP.bFearProjectiles = True;
									SP.ConBindEvents();
								}
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (JordanShea(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
								FoundFlag = true;
								break;
							}
						}
						
						if (FoundFlag)
						{
							forEach AllActors(class'Inventory', TInv)
							{
								if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-519, -491, 0))))
								{
									if (DeusExAmmo(TInv) != None)
									{
										DeusExAmmo(TInv).bOwned = true;
										DeusExAmmo(TInv).bSuperOwned = true;
									}
									else if (DeusExPickup(TInv) != None)
									{
										DeusExPickup(TInv).bOwned = true;
										DeusExPickup(TInv).bSuperOwned = true;
									}
									else if (DeusExWeapon(TInv) != None)
									{
										DeusExWeapon(TInv).bOwned = true;
										DeusExWeapon(TInv).bSuperOwned = true;
									}
								}
							}
						}
					}
				break;
				//02_NYC_FREECLINIC: Balancing changes, baby.
				case "02_NYC_FREECLINIC":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
										if (MoverIsLocation(DXM, Vect(672, -2350, -206)))
										{
											LocAdd = vect(0,0,2);
											PivAdd = vect(0,0,0);
											FrameAdd[0] = vect(0,0,2);
											FrameAdd[1] = vect(0,0,2);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 1:
										if (MoverIsLocation(DXM, Vect(672, -2258, -208)))
										{
											LocAdd = vect(0,0,2);
											PivAdd = vect(0,0,0);
											FrameAdd[0] = vect(0,0,2);
											FrameAdd[1] = vect(0,0,2);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 2:
										if (MoverIsLocation(DXM, Vect(765, -1288, -256)))
										{
											LocAdd = vect(-1,0,0);
											FrameAdd[0] = vect(-1,0,0);
											FrameAdd[1] = vect(-1,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 4:
									case 5:
										DXM.MinDamageThreshold = 8;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if ((Doctor(SP) != None) || (Nurse(SP) != None))
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
								FoundFlag = true;
							}
						}
						
						if (FoundFlag)
						{
							forEach AllActors(class'Inventory', TInv)
							{
								if ((TInv.Owner == None) && (Medkit(TInv) != None))
								{
									Medkit(TInv).bOwned = true;
									Medkit(TInv).bSuperOwned = true;
								}
							}
						}
					}
				break;
				//02_NYC_HOTEL: LDDP stuff.
				case "02_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/17/24: Use this remote binding special phone.
						A = Spawn(class'PaulM02Phone',,, Vect(-610,-3244,96), Rot(0,32768,0));
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHotelAddict", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPHotelAddict',vect(1868,-1333,112));
								if (SP != None)
								{
									SP.InitialInventory[0].Inventory = class'VialCrack';
								}
							}
						}
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 9:
										//Rotation yaw of -16384
										//Base: 1424, -1680, 192
										//Desired: 1424, -1674, 192
										//----------------------
										//IGNORING Z
										if (MoverIsLocation(DXM, Vect(1424, -1680, 192)))
										{
											LocAdd = vect(0,6,0);
											PivAdd = vect(-6,0,0);
											FrameAdd[0] = vect(0,6,0);
											FrameAdd[1] = vect(0,6,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//02_NYC_STREET: Bad fragment classes here. Oops. Also, update trigger with female equivalent.
				case "02_NYC_STREET":
					if (!bRevisionMapSet)
					{
						//MADDERS, 9/21/22: Aggravated by MEGH's inclusion, Paul is a dick and can very rarely end up shooting civilians.
						//Make him too docile to start unloading on civvies. Christ.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (PaulDenton(SP) != None)
							{
								SP.bHateHacking = false;
								SP.bHateWeapon = false;
								SP.bHateShot = false;
								SP.bHateInjury = false;
								SP.bHateIndirectInjury = false;
								SP.bHateCarcass = false;
								SP.bHateDistress = false;
							}
							else if (UNATCOTroop(SP) != None || RiotCop(SP) != None)
							{
								SP.ChangeAlly('Thugs', -1.0, true);
							}
							else if (ThugMale(SP) != None || SandraRenton(SP) != None)
							{
								SP.bUseHome = true;
								SP.HomeLoc = SP.Location;
							}
						}
						
						//Adapt gender reference for LDDP.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							forEach AllActors(class'Actor', A)
							{
								if (SpecialEvent(A) != None)
								{
									switch(SF.Static.StripBaseActorSeed(A))
									{
										case 0:
											SpecialEvent(A).Message = "Sign her up for Liberty!!!";
										break;
									}
								}
							}
						}
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 7:
									case 20:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						forEach AllActors(class'OrdersTrigger', OTrig)
						{
							if (OTrig != None)
							{
								switch(SF.Static.StripBaseActorSeed(OTrig))
								{
									case 8:
										OTrig.SetCollisionSize(4.0, OTrig.CollisionHeight);
										OTrig.Event = 'PaulDenton';
									break;
								}
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPStreetLoser", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPRuss',vect(-2378,-202,-465), rot(0,5040,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.BindName = "LDDPStreetLoser";
									SP.BarkBindName = "ThugMale";
									SP.bReactLoudNoise = false;
									SP.bReactProjectiles = false;
									SP.bReactAlarm = false;
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//02_NYC_UNDERGROUND: Fix the ford bug remotely. Yeet.
				case "02_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'Actor', A)
						{
							if (OfficeChair(A) != None)
							{
								switch(SF.Static.StripBaseActorSeed(A))
								{
									case 2:
										UnRandoSeat(OfficeChair(A));
									break;
								}
							}
						}
						
						forEach AllActors(class'FlagTrigger', FT)
						{
							if (FT != None)
							{
								//Ford's flag isn't set right, notoriously.
								if (FT.FlagName == 'FordSchickRescueDone' || FT.FlagName == 'FordSchickRescued')
								{
									FT.FlagExpiration = 0;
								}
							}
						}
					}
				break;
				//02_NYC_WAREHOUSE: Fix a brick wall that is apparently now too tough.
				case "02_NYC_WAREHOUSE":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((BreakableWall(DXM) != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 1:
										DXM.MinDamageThreshold = 60;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						//Beer inside ground. The little things, with me.
						forEach AllActors(class'Actor', A)
						{
							if (Liquor40Oz(A) != None)
							{
								switch(SF.Static.StripBaseActorSeed(Liquor40Oz(A)))
								{
									case 16:
										A.SetLocation(A.Location + vect(0,0,3));
									break;
								}
							}
						}
					}
				break;
			}
		break;
		case 3:
			switch(MN)
			{
				//03_NYC_AIRFIELD: Doors that don't open properly if you block them, and can soft lock you. Sigh.
				//Also, 2nd easter egg.
				case "03_NYC_AIRFIELD":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 2:
									case 3:
										DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						//Plug a hole in a crate we can walk through. Oops.
						PlugVect = Vect(752, 0, 224);
						for (i=3278; i<3409; i += 26)
						{
							PlugVect.Y = i;
							AddBSPPlug(PlugVect, 13, 64);
						}
						
						CreateHallucination(vect(-262, -1176, 324), 1, false);
					}
				break;
				//03_NYC_AIRFIELDHELIBASE Bad fragment class on these doors.
				//NOTE: This is purely a GOTY fix.
				case "03_NYC_AIRFIELDHELIBASE":
					if (!bRevisionMapSet)
					{
						Comp = Spawn(class'ComputerSecurity',,, Vect(-1160,524,269), Rot(0,16384,0));
						if (Comp != None)
						{
							Comp.SetCollisionSize(0, Comp.CollisionHeight);
							Comp.SetLocation(Vect(-1160,515,269));
							Comp.SetCollisionSize(Comp.Default.CollisionRadius, Comp.CollisionHeight);
							Comp.UserList[0].UserName = "JHEARST";
							Comp.UserList[0].Password = "CHUNKOHONEY";
							Comp.SpecialOptions[0].bTriggerOnceOnly = true;
							Comp.SpecialOptions[0].Text = "Join Call";
							Comp.SpecialOptions[0].TriggerEvent = 'RestoredJuanConvoStart';
							Comp.SpecialOptions[0].TriggerText = "Joined... 2 other members";
						}
						
						TDispatch = Spawn(class'Dispatcher',,'RestoredJuanConvoStart', Vect(-1160,544,269));
						if (TDispatch != None)
						{
							TDispatch.SetCollision(False, False, False);
							TDispatch.OutEvents[0] = 'RestoredJuanConvo';
							TDispatch.OutDelays[0] = 1.2500000;
						}
						
						ConTrig = Spawn(class'ConversationTrigger',,'RestoredJuanConvo', Vect(-1160,544,269));
						if (ConTrig != None)
						{
							ConTrig.SetCollision(False, False, False);
							ConTrig.BindName = "JCDenton";
							ConTrig.bCheckFalse = true;
							ConTrig.CheckFlag = 'OverhearLebedev_Played';
							ConTrig.ConversationTag = 'OverhearLebedev';
							ConTrig.bPopWindow = true;
						}
						
						A = Spawn(class'Button1',,, Vect(-1140,514,268));
						if (A != None)
						{
							A.BindName = "JuanLebedev";
							A.bHidden = true;
							A.FamiliarName = "Unknown";
							A.UnfamiliarName = "Unknown";
							A.SetCollision(False, False, False);
							A.SetPhysics(PHYS_None);
							DeusExDecoration(A).ConBindEvents();
							VMDBufferDeco(A).bDisablePassiveConvos = true;
						}
						
						A = Spawn(class'Button1',,, Vect(-1140,514,278));
						if (A != None)
						{
							A.BindName = "TracerTong";
							A.bHidden = true;
							A.FamiliarName = "Unknown";
							A.UnfamiliarName = "Unknown";
							A.SetCollision(False, False, False);
							A.SetPhysics(PHYS_None);
							DeusExDecoration(A).ConBindEvents();
						}
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 127:
										//Rotation yaw of -49152
										//Base: 64, 816, 4
										//Desired: 64, 812, 56
										//----------------------
										//IGNORING Z
										if (MoverIsLocation(DXM, Vect(64, 816, 64)))
										{
											LocAdd = vect(0,-4,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(0,-4,0);
											FrameAdd[1] = vect(0,-4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 139:
									case 140:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//03_NYC_BATTERYPARK: LDDP stuff.
				case "03_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBatPark2NiceBum", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPBatPark2NiceBum',vect(-2653,1381,370), rot(0,-36640,0));
								if (SP != None)
								{
									SP.Alliance = 'Civilian';
									SP.SetOrders('Standing',, true);
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
						
						//Beer inside ground. The little things, with me.
						forEach AllActors(class'Actor', A)
						{
							if (Liquor40Oz(A) != None)
							{
								switch(SF.Static.StripBaseActorSeed(Liquor40Oz(A)))
								{
									case 47:
										A.SetLocation(A.Location + vect(0,0,6));
									break;
								}
							}
						}
					}
				break;
				//03_NYC_BROOKLYNBRIDGESTATION: Pivot fixes, but also hide the hidden wall panel
				case "03_NYC_BROOKLYNBRIDGESTATION":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 2:
										DXM.bHighlight = false;
									break;
									case 8:
										SetMoverFragmentType(DXM, "Metal");
									break;
									//180 degree offset in rotation
									//Base: -1128, -1440, 192
									//Desired: -1134, -1440, 192
									case 53:
										if (MoverIsLocation(DXM, vect(-1128, -1440, 192)))
										{
											LocAdd = vect(-6,0,0);
											PivAdd = vect(6,0,0);
											FrameAdd[0] = vect(-6,0,0);
											FrameAdd[1] = vect(-6,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						forEach AllActors(class'ElectronicDevices', ED)
						{
							if (CigaretteMachine(ED) != None)
							{
								CigaretteMachine(ED).NumUses = 0;
							}
							if (VendingMachine(ED) != None)
							{
								VendingMachine(ED).NumUses = 0;
							}
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPStationAddict", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPStationAddict',vect(-1005,1315,112), rot(0,-12176,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
								}
							}
						}
					}
				break;
				//03_NYC_HANGAR: Fix for dudes freaking the fuck out in DX rando situations.
				case "03_NYC_HANGAR":
					if (!bRevisionMapSet)
					{
						//4/13/23: Fix for civvies freaking the fuck out.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (HumanCivilian(SP) != None)
							{
								HumanCivilian(SP).bHateShot = False;
							}
						}
					}
				break;
				//03_NYC_MOLEPEOPLE: Add an anti-softlock measure.
				case "03_NYC_MOLEPEOPLE":
					if (!bRevisionMapSet)
					{
						A = Spawn(class'Switch1',,, vect(-2788,-896.75,133), Rot(0,-16384,0));
						
						//This fucker keeps spawning detached from the wall a bit. Yikes.
						A.SetCollisionSize(0, 0);
						A.SetLocation(vect(-2788,-896.75,133));
						A.Event = 'SecretDoor';
						A.SetCollisionSize(A.Default.CollisionRadius, A.Default.CollisionHeight);
						
						//4/13/23: Fix for terrie commander listening to narcs too often.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if ((Terrorist(SP) != None) && (Terrorist(SP).BindName ~= "TerroristLeader"))
							{
								Terrorist(SP).bHateDistress = False;
							}
						}
					}
				break;
				//03_NYC_UNATCOHQ: LDDP stuff.
				case "03_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/18/24: Anna gives us some seriously sweet ammo for being a terrie shredder.
						if ((Flags.GetBool('AmbrosiaTagged')) && (Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('M02MechSlur')) && (Flags.GetBool('SubTerroristsDead')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
						{
							A = Spawn(Class'Datacube',,, Vect(-261,1297,288), Rot(0,8192,0));
							if (A != None)
							{
								Datacube(A).TextPackage = "VMDText";
								Datacube(A).TextTag = '03_AnnaThanks';
							}
							A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1292,244));
							A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1302,244));
						}
						//MADDERS, 11/18/24: Alternatively, Paul gives us some taser slugs for being a thoroughly cool dude.
						else if ((Flags.GetBool('AmbrosiaTagged')) && (!Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
						{
							A = Spawn(Class'Datacube',,, Vect(-336,1054,270));
							if (A != None)
							{
								Datacube(A).TextPackage = "VMDText";
								Datacube(A).TextTag = '03_PaulThanks';
							}
							A = Spawn(class'AmmoTaserSlug',,, Vect(-367,1054,279));
							A = Spawn(class'AmmoTaserSlug',,, Vect(-351,1054,279));
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPChet',vect(112,1714,288));
								if (SP != None)
								{
									SP.SetOrders('Sitting',, true);
									SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
									SP.InitialInventory[0].Count = 1;
									SP.InitialInventory[1].Inventory = class'AmmoPepper';
									SP.InitialInventory[1].Count = 8;
									SP.BindName = "LDDPChet";
									SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 5));
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(364,1113,280);
							TCamp.MaxCampLocation = Vect(418,1133,328);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
					}
					
					forEach AllActors(class'ElectronicDevices', ED)
					{
						if (VendingMachine(ED) != None)
						{
							switch(SF.Static.StripBaseActorSeed(ED))
							{
								case 0:
									VendingMachine(ED).AdvancedUses[0]++;
									VendingMachine(ED).bOrangeGag = true;
								break;
							}
						}
					}
				break;
			}
		break;
		case 4:
			switch(MN)
			{
				//04_NYC_HOTEL: LDDP stuff. Also, we found an issue with renton's reactions, so fix those, too.
				case "04_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							DXCLoad = class<DeusExCarcass>(DynamicLoadObject("FemJC.LDDPHotelAddictCarcass", class'Class', true));
							if (DXCLoad != None)
							{
								DXC = Spawn(DXCLoad,,'LDDPHotelAddictCarcass',vect(1850,-1208,82));
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (SandraRenton(SP) != None)
							{
								//MADDERS: Eliminate fears here.
								SP.bFearHacking = False;
								SP.bFearWeapon = False;
								SP.bFearShot = False;
								SP.bFearCarcass = False;
								SP.bFearDistress = False;
								SP.bFearAlarm = False;
								SP.bFearProjectiles = False;
							}
							else if (GilbertRenton(SP) != None)
							{
								//MADDERS: Eliminate fears here.
								SP.bFearHacking = False;
								SP.bFearWeapon = False;
								SP.bFearShot = False;
								SP.bFearInjury = False;
								SP.bFearIndirectInjury = False;
								SP.bFearCarcass = False;
								SP.bFearDistress = False;
								SP.bFearAlarm = False;
								SP.bFearProjectiles = False;
							}
							else if (PaulDenton(SP) != None)
							{
								//SP.bReactFutz = false;
							}
						}
					}
				break;
				//04_NYC_STREET: Update special event for female again.
				case "04_NYC_STREET":
					if (!bRevisionMapSet)
					{
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							forEach AllActors(class'Actor', A)
							{
								if (SpecialEvent(A) != None)
								{
									switch(SF.Static.StripBaseActorSeed(A))
									{
										case 0:
											SpecialEvent(A).Message = "Sign her up for Liberty!!!";
										break;
									}
								}
							}
						}
					}
				break;
				//04_NYC_NSFHQ: Bad pivot on these doors, and a bad frame position on one in general.
				case "04_NYC_NSFHQ":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 4:
										//FrameAdd[0] = vect(0,0,0);
										FrameAdd[1] = vect(0,-4,0);
										FrameAdd[2] = vect(128,0,0);
										//DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[0] + FrameAdd[1];
										DXM.KeyPos[2] = DXM.KeyPos[1] + FrameAdd[2];
									break;
									case 21:
										if (MoverIsLocation(DXM, vect(-664,-60,-256)))
										{
											LocAdd = vect(-4,0,0);
											PivAdd = vect(0, 4, 0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
										}
									break;
									case 24:
										if (MoverIsLocation(DXM, vect(-288,792,-256)))
										{
											LocAdd = vect(-4,-4,0);
											PivAdd = vect(-4,4,0);
											FrameAdd[0] = vect(0,-4,0);
											FrameAdd[1] = vect(0,-4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 26:
										//Base of -188, 944, -256
										//Intended base of -192, 948, -256.
										//Ignoring Z.
										//Rotation Yaw of 0
										if (MoverIsLocation(DXM, vect(-188,944,-256)))
										{
											LocAdd = vect(-4, 4, 0);
											PivAdd = vect(-4, 4, 0);
											FrameAdd[0] = vect(-4, 4, 0);
											FrameAdd[1] = vect(-4, 4, 0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 72:
										//Base of 1126, 168, 16
										//Intended base of 1120, 168, 16.
										//Ignoring Z.
										//Rotation Yaw of 32768
										if (MoverIsLocation(DXM, vect(1126,168,16)))
										{
											LocAdd = vect(-6, 0, 0);
											//PivAdd = vect(6, 0, 0);
											FrameAdd[0] = vect(-6, 0, 0);
											FrameAdd[1] = vect(-6, 0, 0);
											DXM.SetLocation(vect(1120,168,16));
											//DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(1219,1349,-216);
							TCamp.MaxCampLocation = Vect(1244,1403,-168);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (RepairBot(SP) != None)
							{
								RepairBot(SP).bHubBot = false;
							}
							else if (MedicalBot(SP) != None)
							{
								MedicalBot(SP).bHubBot = false;
							}
						}
					}
				break;
				//04_NYC_UNATCOHQ: Return door encroach type on manderley's door.
				case "04_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 10:
										DXM.MoverEncroachType = ME_ReturnWhenEncroach;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(381,1113,280);
							TCamp.MaxCampLocation = Vect(435,1133,328);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPChet',vect(227,1258,288), rot(0,-16456,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
									SP.InitialInventory[0].Count = 1;
									SP.InitialInventory[1].Inventory = class'AmmoPepper';
									SP.InitialInventory[1].Count = 8;
									SP.BindName = "LDDPChet";
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
					}
					forEach AllActors(class'ElectronicDevices', ED)
					{
						if (VendingMachine(ED) != None)
						{
							switch(SF.Static.StripBaseActorSeed(ED))
							{
								case 0:
									VendingMachine(ED).AdvancedUses[0]++;
									VendingMachine(ED).bOrangeGag = true;
								break;
							}
						}
					}
				break;
				//04_NYC_BAR: LDDP stuff.
				case "04_NYC_BAR":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBarFly", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1728,-362,48), rot(0,-16392,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.BarkBindName = "Man";
									SP.UnfamiliarName = "Bar Fly";
									SP.FamiliarName = "Liam";
									SP.bFearWeapon = True;
									SP.bFearInjury = True;
									SP.bFearProjectiles = True;
									SP.ConBindEvents();
								}
							}
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPNYC2BarGuy", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPNYC2BarGuy',vect(-807,-413,51), rot(0,-16504,0));
								if (SP != None)
								{
									SP.Alliance = 'BarPatrons';
									SP.SetOrders('Standing',, true);
									SP.bFearWeapon = True;
									SP.bFearInjury = True;
									SP.bFearProjectiles = True;
								}
							}
							//MADDERS, 11/1/21: LDDP branching functionality.
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPLyla", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPLyla',vect(-2739,523,22));
								if (SP != None)
								{
									if (SP.CollisionHeight < 42)
									{
										SP.Destroy();
									}
									else
									{
										SP.Alliance = 'BarPatrons';
										SP.bFearWeapon = True;
										SP.bFearInjury = True;
										SP.bFearProjectiles = True;
									}
								}
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (JordanShea(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
								FoundFlag = true;
								break;
							}
						}
						
						if (FoundFlag)
						{
							forEach AllActors(class'Inventory', TInv)
							{
								if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-540, -502, 0)) || ItemIsLocation(TInv, Vect(-514, -499, 0))))
								{
									if (DeusExAmmo(TInv) != None)
									{
										DeusExAmmo(TInv).bOwned = true;
										DeusExAmmo(TInv).bSuperOwned = true;
									}
									else if (DeusExPickup(TInv) != None)
									{
										DeusExPickup(TInv).bOwned = true;
										DeusExPickup(TInv).bSuperOwned = true;
									}
									else if (DeusExWeapon(TInv) != None)
									{
										DeusExWeapon(TInv).bOwned = true;
										DeusExWeapon(TInv).bSuperOwned = true;
									}
								}
							}
						}
					}
				break;
				//04_NYC_BATTERYPARK: Broken trigger collision. Also, bad alliances.
				case "04_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'AllianceTrigger', ATrig)
						{
							switch(SF.Static.StripBaseActorSeed(ATrig))
							{
								case 12:
								case 13:
								case 14:
									ATrig.SetCollision(False, False, False);
								break;
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (Robot(SP) != None)
							{
								SP.ChangeAlly('Gunther', 1.0, true, false);
							}
						}
					}
				break;
			}
		break;
		case 5:
			switch(MN)
			{
				//05_NYC_UNATCOMJ12LAB: Paul keeps losing his shit. We gotta stop this.
				case "05_NYC_UNATCOMJ12LAB":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (PaulDenton(SP) != None)
							{
								DumbAllReactions(SP);
								SP.ChangeAlly('MJ12', 1.0, true, false);
								SP.Alliance = 'MJ12';
							}
							else if (Terrorist(SP) != None)
							{
								SP.bReactLoudNoise = False;
							}
						}
						
						//Busted pivots ahoy.
						forEach AllActors(class'DeusExMover', DXM)
						{
							if (DXM != None)
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									//Base of 2380, -900, -212
									//Intended 2384, -796, -212
									//Ignoring Z
									//Rotation Yaw of 32768 (1/2 spin)
									//FRAME 1: 20480 pitch
									//Corrected: 16384 pitch
									case 3:
										if (MoverIsLocation(DXM, vect(2380,-900,-212)))
										{
											LocAdd = vect(4,104,0);
											PivAdd = vect(-4,-104,0);
											FrameAdd[0] = vect(4,104,0);
											FrameAdd[1] = vect(4,104,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
											DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
										}
									break;
									
									//Base position: 344,3580,-132
									//INTENDED base position: 344, 3576, -132
									//Ignoring Z.
									//Yaw of 49152 (3/4 spin)
									//FRAME 1: 20480 pitch
									//Corrected: 16384 pitch
									case 7:
										if (MoverIsLocation(DXM, vect(344,3580,-132)))
										{
											LocAdd = vect(0,4,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(0,4,0);
											FrameAdd[1] = vect(0,4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
											DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
										}
									break;
									
									//Base position: 76,1708,92
									//INTENDED base position: 76, 1712, 92
									//Ignoring Z.
									//Yaw of 49152 (3/4 spin)
									//FRAME 1: 20480 pitch
									//Corrected: 16384 pitch
									case 11:
										if (MoverIsLocation(DXM, vect(76,1708,92)))
										{
											LocAdd = vect(0,4,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(0,4,0);
											FrameAdd[1] = vect(0,4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
											DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
										}
									break;
									
									//Base position: 180, 1924, 92
									//INTENDED base position: 180, 1920, 92
									//Ignoring Z.
									//Yaw of 16384 (1/4 spin)
									//FRAME 1: 20480 pitch
									//Corrected: 16384 pitch
									case 12:
										if (MoverIsLocation(DXM, vect(180,1924,92)))
										{
											LocAdd = vect(0,-4,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(0,-4,0);
											FrameAdd[1] = vect(0,-4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
											DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
										}
									break;
								}
							}
						}
					}
					forEach AllActors(class'SkillAwardTrigger', SAT)
					{
						switch(SF.Static.StripBaseActorSeed(SAT))
						{
							case 4:
								if (!Flags.GetBool('PaulDenton_Dead'))
								{
									SAT.SkillPointsAdded = 1000;
								}
							break;
						}
					}
				break;
				
				//05_NYC_UNATCOHQ: Bad pivot on cabinets, and encroach type on manderley's door.
				case "05_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 1:
										//----------------------------------
										//EXAMPLE OF PIVOT FIX METHOD:
										//----------------------------------
										//+++Original location+++
										//Loc 416, 1104, 288
										//+++Desired location+++
										//Loc 420, 1108, 280
										if (MoverIsLocation(DXM, vect(416,1104,288)))
										{
											//Add intended offset to the location, and do the same to the frames.
											LocAdd = vect(4,4,-8);
											//Rotation is 90 degrees counter clockwise. X becomes -Y, Y becomes X, -X becomes Y, etc.
											//Use prepivot to tweak the offset all the same
											PivAdd = vect(-4,4,-8);
											FrameAdd[0] = vect(4,4,-8);
											FrameAdd[1] = vect(4,4,-8);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 10:
										DXM.MoverEncroachType = ME_ReturnWhenEncroach;
									break;
								}
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(364,1113,280);
							TCamp.MaxCampLocation = Vect(418,1133,328);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						//03/28/23: Make alex stop freaking out about combat in UNATCO HQ. Saves a lot of hassle.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (AlexJacobson(SP) != None)
							{
								//MADDERS: Eliminate reactions here.
								DumbAllReactions(SP);
							}
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPChet',vect(76, 1860,288), rot(0,16640,0));
								if (SP != None)
								{
									SP.SetOrders('Sitting',, true);
									SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 0));
									SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
									SP.InitialInventory[0].Count = 1;
									SP.InitialInventory[1].Inventory = class'AmmoPepper';
									SP.InitialInventory[1].Count = 8;
									SP.BindName = "LDDPChet";
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
					}
					forEach AllActors(class'ElectronicDevices', ED)
					{
						if (VendingMachine(ED) != None)
						{
							switch(SF.Static.StripBaseActorSeed(ED))
							{
								case 1:
									VendingMachine(ED).AdvancedUses[0]++;
									VendingMachine(ED).bOrangeGag = true;
								break;
							}
						}
					}
				break;
			}
		break;
		case 6:
			switch(MN)
			{
				//06_HONGKONG_HELIBASE: Tweak trigger for its arguable typo, but whatever
				case "06_HONGKONG_HELIBASE":
					if (!bRevisionMapSet)
					{
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							forEach AllActors(class'SkillAwardTrigger', SAT)
							{
								switch(SF.Static.StripBaseActorSeed(SAT))
								{
									case 1:
										SAT.Message = "Goddess shot!";
									break;
								}
							}
						}
					}
				break;
				//06_HONGKONG_WANCHAI_CANAL: Weird gripe: But abnormally strong piece of glass.
				//New state requires a swift kick, but it CAN be done without explosives.
				//Finally, let's shove some stuff around for LDDP interactions.
				case "06_HONGKONG_WANCHAI_CANAL":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 18:
									case 19:
										SetMoverFragmentType(DXM, "Glass");
										DXM.MinDamageThreshold = 25;
									break;
									case 84:
									case 85:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						forEach AllActors(class'DeusExDecoration', DXD)
						{	
							if (HKHangingLantern2(DXD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(DXD))
								{
									case 6:
										DXD.Destroy();
									break;
								}
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (LowerClassMale2(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 4:
										SP.SetLocation(vect(-1623, 1700, -367));
										SP.SetRotation(rot(0, -44128, 0));
										
										if (A != None)
										{
											A = Spawn(class'WHChairDining',,'MBChair', vect(-1671, 1641, -380), rot(0,-28000, 0));
											SP.SeatActor = Seat(A);
											SP.SetOrders('Sitting',, true);
										}
										
										OTrig = spawn(class'OrdersTrigger',,'GoGetJC', vect(-1402,2269,-287));
										if (OTrig != None)
										{
											OTrig.Orders = 'RunningTo';
											OTrig.Event = 'MarketBum1';
											OTrig.SetCollision(false, false, false);
										}
										FT = spawn(class'FlagTrigger',,, vect(-1567,2271,-440));
										if (FT != None)
										{
											FT.Event = 'GoGetJC';
											FT.bTrigger = true;
											FT.bSetFlag = false;
											FT.FlagValue = false;
											FT.FlagName = 'LDDPJCIsFemale';
										}
										FT = spawn(class'FlagTrigger',,, vect(-1567,2271,-440));
										if (FT != None)
										{
											FT.Event = 'GoGetJC';
											FT.bTrigger = true;
											FT.bSetFlag = false;
											FT.FlagValue = false;
											FT.FlagName = 'PaulDenton_Dead';
										}
									break;
								}
							}
							else if (LowerClassFemale(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 0:
										SP.bFearHacking = true;
										SP.bHateHacking = true;
									break;
								}
							}
							else if (Bartender(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
							}
						}
						
						forEach AllActors(class'Inventory', TInv)
						{
							if (TInv.Owner == None)
							{
								if (WineBottle(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 7:
										case 8:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (Liquor40Oz(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 0:
										case 1:
										case 2:
										case 7:
										case 8:
										case 9:
										case 10:
										case 11:
										case 12:
										case 13:
										case 14:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (LiquorBottle(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 6:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (SodaCan(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 8:
										case 9:
										case 10:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (CandyBar(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 1:
										case 2:
										case 3:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (Medkit(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 0:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (Credits(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 3:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
							}
						}
						forEach AllActors(class'VMDBufferDeco', VMD)
						{
							if (CrateBreakableMedGeneral(VMD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(VMD))
								{
									case 0:
									case 6:
										VMD.bOwned = true;
										VMD.bSuperOwned = true;
									break;
								}
							}
							else if (CrateBreakableMedMedical(VMD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(VMD))
								{
									case 4:
										VMD.bOwned = true;
										VMD.bSuperOwned = true;
									break;
								}
							}
							else if (Basket(VMD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(VMD))
								{
									case 0:
									case 1:
									case 2:
										VMD.bOwned = true;
										VMD.bSuperOwned = true;
									break;
								}
							}
						}
					}
				break;
				//06_HONGKONG_WANCHAI_MARKET: Ya' know. The easter egg. And another one.
				//Also: One mover has a bad fragment class.
				case "06_HONGKONG_WANCHAI_MARKET":
					if (!bRevisionMapSet)
					{
						Spawn(class'WeaponModEvolution',,,vect(-162, -318, 389));
						Spawn(class'WeaponModEvolution',,,vect(-146, -318, 389));
						Spawn(class'WineBottle',,,vect(-321, -232, 16));
						
						CreateHallucination(vect(-620, 704, 100), 2, true);
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
										if (MoverIsLocation(DXM, vect(0,688,0)))
										{
											LocAdd = vect(-4,0,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(-4,0,0);
											FrameAdd[1] = vect(-4,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									//Base: 0, 560, 0
									//Intended: -4, 560, 0
									//Rotation: 0
									case 1:
										if (MoverIsLocation(DXM, vect(0,560,0)))
										{
											LocAdd = vect(-4,0,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(-4,0,0);
											FrameAdd[1] = vect(-4,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 3:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHKTourist", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPHKTourist',vect(2278,305,48));
								if (SP != None)
								{
									SP.UnfamiliarName = "Lost Tourist";
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//06_HONGKONG_WANCHAI_STREET: Aw, screw it. Secondary easter egg for this unused vent,
				//which is arguably an easter egg on its own, given the skull's strange, comedic value.
				case "06_HONGKONG_WANCHAI_STREET":
					if (!bRevisionMapSet)
					{
						A = Spawn(class'Credits',,,vect(917.4, -1025.6, 135.7));
						if (A != None)
						{
							TRot = rot(-12000,-16384,0);
							A.DesiredRotation = TRot;
							A.SetRotation(A.DesiredRotation);
							A.bRotateToDesired = True;
							A.SetPhysics(PHYS_None);
							
							//Credits. Get it? Badum-Tss!
							A.Multiskins[0] = Texture'BogieJokeCreditChit';
							Credits(A).NumCredits = 42;
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1442,-1169,2022));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(-1436,-1195,2025);
							TCamp.MaxCampLocation = Vect(-1415,-1140,2073);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 61));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 62));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						//9/11/21: Avert this disaster of junkie engaging every MJ12 troop for no reason.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (MaggieChow(SP) != None || JunkieFemale(SP) != None)
							{
								SP.bReactLoudNoise = false;
							}
						}
					}
				break;
				//06_HONGKONG_WANCHAI_UNDERWORLD: Fix credits count on counter lady.
				case "06_HONGKONG_WANCHAI_UNDERWORLD":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
							{
								SP = ScriptedPawn(TPawn);
								if (SP != None)
								{
									if (SP.Tag == 'ClubTessa' || SP.Tag == 'ClubMercedes')
									{
										SP.Destroy();
									}
									else if (Sailor(SP) != None)
									{
										switch(SF.Static.StripBaseActorSeed(DXM))
										{
											case 4:
												SP.FamiliarName = "Misha";
												SP.UnfamiliarName = "Russian Sailor";
												SP.BindName = "LDDPRussianGuy";
												SP.ConBindEvents();
											break;
										}
									}
								}
							}
							
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPRuss", class'Class', true));
							if (SPLoad != None)
							{
								if (FlagTrigger(FindActorBySeed(class'FlagTrigger', 20)) != None)
								{
									FlagTrigger(FindActorBySeed(class'FlagTrigger', 20)).ClassProximityType = SPLoad;
								}
								SP = Spawn(SPLoad,,'LDDPRuss',vect(-1115,24,-336), rot(0,32760,0));
								if (SP != None)
								{
									SP.SetOrders('Standing',, true);
									SP.BindName = "LDDPRuss";
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHKClubGuy", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPHKClubGuy',vect(-1404,-1089,-336), rot(0,-7648,0));
								if (SP != None)
								{
									SP.HomeTag = 'Start';
									SP.SetOrders('Dancing',, true);
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
						
						//MADDERS, 7/1/24: DXT doesn't fix this flag trigger having collision. Huh.
						forEach AllActors(class'OrdersTrigger', OTrig)
						{
							switch(SF.Static.StripBaseActorSeed(OTrig))
							{
								case 4:
									OTrig.SetCollision(False, False, False);
								break;
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (Bartender(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
							}
						}
						
						forEach AllActors(class'Inventory', TInv)
						{
							if (TInv.Owner == None)
							{
								if (WineBottle(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 25:
										case 26:
										case 27:
										case 28:
										case 29:
										case 30:
										case 31:
										case 32:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (Liquor40Oz(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 42:
										case 43:
										case 44:
										case 45:
										case 46:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
								else if (Credits(TInv) != None)
								{
									switch(SF.Static.StripBaseActorSeed(TInv))
									{
										case 17:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										break;
									}
								}
							}
						}
					}
				break;
				//06_HONGKONG_VERSALIFE: Toughen up our rogue door.
				//Also: Fix hundley's credit count, since it now operates off of a "NumCopies" basis.
				case "06_HONGKONG_VERSALIFE":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 4:
										DXM.MinDamageThreshold = 25;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPVersaEmp", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPVersaEmp',vect(215,1935,208));
								if (SP != None)
								{
									SP.SetOrders('Sitting',, true);
									SP.SeatActor = Seat(FindActorBySeed(class'OfficeChair', 32));
									SP.BarkBindName = "Man";
									SP.Alliance = 'Workers';
									SP.InitialAlliances[0].AllianceName = 'Player';
									SP.InitialAlliances[1].AllianceName = 'MJ12';
									SP.InitialAlliances[2].AllianceName = 'Workers';
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//06_HONGKONG_MJ12LAB: Make maggie and bob invincible. No game breaking, please.
				//Additionally, fix some fragment classes.
				case "06_HONGKONG_MJ12LAB":
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (MaggieChow(SP) != None || BobPage(SP) != None)
						{
							SP.bInvincible = True;
						}
						else if (MIB(SP) != None || WIB(SP) != None)
						{
							SP.ChangeAlly('Security', 1.0, true, false);
						}
						else if (MJ12Troop(SP) != None || MJ12Commando(SP) != None || MIB(SP) != None)
						{
							SP.bFearHacking = true;
							SP.bHateHacking = true;
							SP.ChangeAlly('MJ12', 1.0, true, false);
						}
					}
					
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{

									//Base of -1648, -384, -688
									//Intended base of -1647, -379, -683.
									//Ignoring Z.
									//Rotation Yaw of 16384
									case 12:
										if (MoverIsLocation(DXM, vect(-1648,-384,-688)))
										{
											LocAdd = vect(1,5,0);
											PivAdd = vect(5,-1,0);
											FrameAdd[0] = vect(1,5,0);
											FrameAdd[1] = vect(1,5,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									
									//Base of -1648, -288, -688
									//Intended base of -1647, -289, -681.
									//Ignoring Z.
									//Rotation Yaw of 16384
									case 13:
										if (MoverIsLocation(DXM, vect(-1648,-288,-688)))
										{
											LocAdd = vect(1,-1,0);
											PivAdd = vect(-1,-1,0);
											FrameAdd[0] = vect(1,-1,0);
											FrameAdd[1] = vect(1,-1,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									
									case 55:
									case 56:
									case 57:
									case 58:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1062,-769,450));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(1030,-796,426);
							TCamp.MaxCampLocation = Vect(1052,-741,474);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1174,-2095,449));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(1144,-2124,426);
							TCamp.MaxCampLocation = Vect(1164,-2069,474);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 61));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 62));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						//MADDERS, 4/24/24: Weird fix for and from DX rando folks.
						foreach AllActors(class'DeusExMover', DXM, 'security_doors')
						{
							DXM.bBreakable = false;
							DXM.bPickable = false;
						}
        					foreach AllActors(class'DeusExMover', DXM, 'Lower_lab_doors')
						{
							DXM.bBreakable = false;
							DXM.bPickable = false;
						}

						forEach AllActors(class'Inventory', TInv)
						{
							if (TInv.Owner == None)
							{
								//4/13/24: Stop using seeds on this so DX rando is more consistent.
								if (DeusExAmmo(TInv) != None)
								{
									//switch(SF.Static.StripBaseActorSeed(TInv))
									//{
										//case 0:
											DeusExAmmo(TInv).bOwned = true;
											DeusExAmmo(TInv).bSuperOwned = true;
										//break;
									//}
								}
								else if (AugmentationCannister(TInv) != None)
								{
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								}
								else if (BallisticArmor(TInv) != None)
								{
									//switch(SF.Static.StripBaseActorSeed(TInv))
									//{
										//case 1:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										//break;
									//}
								}
								else if (BioelectricCell(TInv) != None)
								{
									//switch(SF.Static.StripBaseActorSeed(TInv))
									//{
										//case 0:
										//case 6:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										//break;
									//}
								}
								else if (TechGoggles(TInv) != None)
								{
									//switch(SF.Static.StripBaseActorSeed(TInv))
									//{
										//case 0:
											DeusExPickup(TInv).bOwned = true;
											DeusExPickup(TInv).bSuperOwned = true;
										//break;
									//}
								}
								else if (DeusExWeapon(TInv) != None)
								{
									//switch(SF.Static.StripBaseActorSeed(TInv))
									//{
										//case 0:
											DeusExWeapon(TInv).bOwned = true;
											DeusExWeapon(TInv).bSuperOwned = true;
										//break;
									//}
								}
							}
						}
						forEach AllActors(class'VMDBufferDeco', VMD)
						{
							if (AlarmUnit(VMD) != None)
							{
								VMD.bOwned = true;
								VMD.bSuperOwned = true;
							}
							else if (CrateBreakableMedCombat(VMD) != None)
							{
								//switch(SF.Static.StripBaseActorSeed(VMD))
								//{
									//MADDERS, 4/13/24: Make all combat crates owned, for DX Rando compatability.
									//case 0:
									//case 1:
										VMD.bOwned = true;
										VMD.bSuperOwned = true;
									//break;
								//}
							}
						}
					}
				break;
			}
		break;
		case 8:
			switch(MN)
			{
				//08_NYC_STREET: Desist. Stop running away like a bitch. Also, adjust trigger for LDDP.
				case "08_NYC_STREET":
					if (!bRevisionMapSet)
					{
						//Adapt gender reference for LDDP.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							forEach AllActors(class'Actor', A)
							{
								if (SpecialEvent(A) != None)
								{
									switch(SF.Static.StripBaseActorSeed(A))
									{
										case 0:
											SpecialEvent(A).Message = "Sign her up for Liberty!!!";
										break;
									}
								}
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (StantonDowd(SP) != None)
							{
								//MADDERS: Eliminate reactions here.
								DumbAllReactions(SP);
							}
							
							//MADDERS, 1/28/21: Friendly fire is off the charts.
							//MADDERS, 8/8/23: Just found out the real bug. Fuck me lmao.
							//You're not my buddy, guy.
							//You're not my guy, buddy.
							else if (UNATCOTroop(SP) != None)
							{
								SP.ChangeAlly('RiotCop', 1.0, true, false);
								SP.ChangeAlly('Robot', 1.0, true, false);
							}
							else if (RiotCop(SP) != None)
							{
								SP.ChangeAlly('Robot', 1.0, true, false);
								SP.ChangeAlly('UNATCO', 1.0, true, false);
							}
						}
					}
				break;
				//08_NYC_HOTEL: Patrol points be :b:roke
				case "08_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/18/24: Mr Renton returns our lent gat in M08 silently.
						if ((VMP != None) && (VMP.LastGenerousWeaponClass != "NULL") && (!Flags.GetBool('GilbertRenton_Dead')))
						{
							LDXW = class<DeusExWeapon>(DynamicLoadObject(VMP.LastGenerousWeaponClass, class'Class', true));
							if (LDXW != None)
							{
								DXW = Spawn(LDXW,,, Vect(-730,-3146,109), Rot(0, 16384, 0));
								if (DXW != None)
								{
									DXW.PickupAmmoCount = 0;
									
									if (VMP.LastGenerousWeaponModSilencer > 0) DXW.bHasSilencer = true;
									if (VMP.LastGenerousWeaponModScope > 0) DXW.bHasScope = true;
									if (VMP.LastGenerousWeaponModLaser > 0) DXW.bHasLaser = true;
									
									DXW.ModBaseAccuracy = VMP.LastGenerousWeaponModAccuracy;
									if (DXW.BaseAccuracy == 0.0)
									{
										DXW.BaseAccuracy -= DXW.ModBaseAccuracy;
									}
									else
									{
										DXW.BaseAccuracy -= (DXW.Default.BaseAccuracy * DXW.ModBaseAccuracy);
									}
									
									DXW.ModReloadCount = VMP.LastGenerousWeaponModReloadCount;
									Diff = Float(DXW.Default.ReloadCount) * DXW.ModReloadCount;
									DXW.ReloadCount += Max(Diff, DXW.ModReloadCount / 0.1);
									
									DXW.ModAccurateRange = VMP.LastGenerousWeaponModAccurateRange;
									DXW.RelativeRange += (DXW.Default.RelativeRange * DXW.ModAccurateRange);
									DXW.AccurateRange += (DXW.Default.AccurateRange * DXW.ModAccurateRange);
									
									DXW.ModReloadTime = VMP.LastGenerousWeaponModReloadTime;
									DXW.ReloadTime += (DXW.Default.ReloadTime * DXW.ModReloadTime);
									if (DXW.ReloadTime < 0.0) DXW.ReloadTime = 0.0;
									
									DXW.ModRecoilStrength = VMP.LastGenerousWeaponModRecoilStrength;
									DXW.RecoilStrength += (DXW.Default.RecoilStrength * DXW.ModRecoilStrength);
									
									if (VMP.LastGenerousWeaponModEvolution > 0)
									{
										DXW.bHasEvolution = true;
										DXW.VMDUpdateEvolution();
									}
								}
							}
						}
						VMP.VMDClearGenerousWeaponData();
						
						forEach AllActors(class'PatrolPoint', Pat)
						{
							if (Pat != None)
							{
								switch(SF.Static.StripBaseActorSeed(Pat))
								{
									case 44:
										Pat.Tag = 'HotelPatrol2A';
										Pat.NextPatrol = 'HotelPatrol2B';
										StoredPats[0] = Pat;
									break;
									case 48:
										Pat.Tag = 'HotelPatrol2B';
										Pat.NextPatrol = 'HotelPatrol2C';
										StoredPats[1] = Pat;
									break;
									case 49:
										Pat.Tag = 'HotelPatrol2C';
										Pat.NextPatrol = 'HotelPatrol2A';
										StoredPats[2] = Pat;
									break;
								}
							}
						}
						//Let's try this *one* more time.
						for(i=0; i<3; i++)
						{
							if (StoredPats[i] != None)
							{
								StoredPats[i].PreBeginPlay();
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (RiotCop(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 8:
										SP.SetOrders('Patrolling', 'HotelPatrol2A', true);
									break;
								}
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("DeusEx.BumMale2", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'BumMale2',vect(1499,-1590,112));
								if (SP != None)
								{
									SP.bCower = true;
									SP.BarkBindName = "Man";
									SP.BindName = "LDDPM08Bum";
									SP.UnfamiliarName = "Bum";
									SP.FamiliarName = "Bum";
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//08_NYC_FREECLINIC: Microscope inside floor.
				case "08_NYC_FREECLINIC":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExDecoration', DXD)
						{	
							if (Microscope(DXD) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 1:
										DXD.Destroy();
										//DXD.SetPhysics(PHYS_Falling);
										//DXD.SetRotation(rot(0,0,0));
										//DXD.SetLocation(vect(707,-2392,-304));
									break;
								}
							}
						}
					}
				break;
				//08_NYC_UNDERGROUND: Fourth easter egg.
				case "08_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						CreateHallucination(vect(-1103, -92, -828), 3, false);
					}
				break;
				//08_NYC_BAR: LDDP stuff.
				case "08_NYC_BAR":
					if (!bRevisionMapSet)
					{
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBarFly", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1958,-329,48), rot(0,-16392,0));
								if (SP != None)
								{
									SP.SetOrders('Wandering',, true);
									SP.BarkBindName = "Man";
									SP.UnfamiliarName = "Bar Fly";
									SP.FamiliarName = "Liam";
									SP.bFearWeapon = True;
									SP.bFearInjury = True;
									SP.bFearProjectiles = True;
									SP.ConBindEvents();
								}
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (JordanShea(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
								FoundFlag = true;
								break;
							}
						}
						
						if (FoundFlag)
						{
							forEach AllActors(class'Inventory', TInv)
							{
								if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-517, -491, 0))))
								{
									if (DeusExAmmo(TInv) != None)
									{
										DeusExAmmo(TInv).bOwned = true;
										DeusExAmmo(TInv).bSuperOwned = true;
									}
									else if (DeusExPickup(TInv) != None)
									{
										DeusExPickup(TInv).bOwned = true;
										DeusExPickup(TInv).bSuperOwned = true;
									}
									else if (DeusExWeapon(TInv) != None)
									{
										DeusExWeapon(TInv).bOwned = true;
										DeusExWeapon(TInv).bSuperOwned = true;
									}
								}
							}
						}
					}
				break;
				//08_NYC_SMUG: LDDP convo base fix for the augumentation upgrade, courtesy of the boys at DX Rando
				case "08_NYC_SMUG":
				        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        				FixConversationGiveItem(GetConversation('FemJCM08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
				break;
			}
		break;
		case 9:
			switch(MN)
			{
				//09_NYC_DOCKYARD: Fix the infamous infinite skill trigger.
				//5/24/23: Also, now fix this fragment class.
				case "09_NYC_DOCKYARD":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'SkillAwardTrigger', SAT)
						{
							if (SAT != None)
							{
								switch(SF.Static.StripBaseActorSeed(SAT))
								{
									case 10:
										if (SAT.Tag != 'BackGate')
										{
											SAT.Tag = 'BackGate';
										}
									break;
								}
							}
						}
						
						//MADDERS, 11/16/24: Add a box here, to prevent softlocks.
						Spawn(class'CrateUnbreakableSmall',,, Vect(4105, 2149, 24));
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 29:
										DXM.MinDamageThreshold = 50;
										SetMoverFragmentType(DXM, "Metal");
									break;
									case 31:
										SetMoverFragmentType(DXM, "Metal");
									break;
									case 34:
										DXM.GoToState('TriggerOpenTimed');
										DXM.StayOpenTime = 9999;
									break;
								}
							}
						}
					}
				break;
				//09_NYC_GRAVEYARD: Make the janitor invulnerable, so we can't kill him and bug the opening sequence.
				//This is god awful, but part of this is handlined in Mission09's script.
				//3/28/23: Also, make Dowd chill out just for extra measure. Why not?
				case "09_NYC_GRAVEYARD":
					if (!bRevisionMapSet)
					{
						PlugVect = Vect(17, 0, 25);
						for (i=388; i<444; i += 4)
						{
							PlugVect.Y = i;
							AddBSPPlug(PlugVect, 2, 24);
						}
					}
					
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (StantonDowd(SP) != None)
						{
							//MADDERS: Eliminate reactions here.
							DumbAllReactions(SP);
						}
						else if (Janitor(SP) != None)
						{
							SP.bInvincible = true;
						}
					}
				break;
				//09_NYC_SHIP: Fix the infamous infinite skill trigger.
				case "09_NYC_SHIP":
					if (!bRevisionMapSet)
					{
						//MADDERS, 8/1/23: BSP hole in crate near PCS Wall Cloud. 
						AddBSPPlug(vect(-2720, -1264, -460), 45, 32);
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									//Base of 2336, -144, 464
									//Intended base of 2329, -144, 508.
									//Ignoring Z.
									//Rotation Yaw of -65536, but pitch of 32768, in a twist.
									case 26:
										if (MoverIsLocation(DXM, vect(2336,-144,464)))
										{
											LocAdd = vect(-7,0,0);
											PivAdd = vect(7,0,0);
											FrameAdd[0] = vect(-7,0,0);
											FrameAdd[1] = vect(-7,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									
									//Base: 2160, 128, 928
									//Intended: 2160, 124, 936
									//Rotation: -32768, 49152
									case 282:
										if (MoverIsLocation(DXM, vect(2160,128,928)))
										{
											LocAdd = vect(0,-4,8);
											PivAdd = vect(4,0,-8);
											FrameAdd[0] = vect(0,-4,8);
											FrameAdd[1] = vect(0,-4,8);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
							}
						}
						forEach AllActors(class'Seat', TSeat)
						{
							if (OfficeChair(TSeat) != None)
							{
								UnRandoSeat(TSeat);
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (Sailor(SP) != None)
							{
								SP.ChangeAlly('Guards', 1.0, true, false);
							}
							else if (HKMilitary(SP) != None)
							{
								SP.ChangeAlly('Sailors', 1.0, true, false);
							}
							else if (WaltonSimons(SP) != None)
							{
								DumbAllReactions(SP);
							}
						}
					}
				break;
				//09_NYC_SHIPBELOW: Bad door pivot.
				case "09_NYC_SHIPBELOW":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 24:
										if (MoverIsLocation(DXM, vect(-2544,-624,-128)))
										{
											LocAdd = vect(0,-4,0);
											PivAdd = vect(0,-4,0);
											FrameAdd[0] = vect(0,-4,0);
											FrameAdd[1] = vect(0,-4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
			}
		break;
		case 10:
			switch(MN)
			{
				//10_PARIS_CLUB: Omelette Du Fromage: Hide wall painting and the entry vent
				case "10_PARIS_CLUB":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
									case 10:
										DXM.bHighlight = false;
									break;
									
									//Base: 400, -864, -48
									//Intended: 404, -864, -48
									//Rotation: -16384 Yaw
									case 2:
										if (MoverIsLocation(DXM, vect(400,-864,-48)))
										{
											LocAdd = vect(4,0,0);
											PivAdd = vect(0,4,0);
											FrameAdd[0] = vect(4,0,0);
											FrameAdd[1] = vect(4,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									
									//Base: -1712, -1476, -160
									//Intended: -1708, -1476, -160
									//Rotation: -16384 Yaw
									case 4:
										if (MoverIsLocation(DXM, vect(-1712,-1476,-160)))
										{
											LocAdd = vect(4,0,0);
											PivAdd = vect(0,4,0);
											FrameAdd[0] = vect(4,0,0);
											FrameAdd[1] = vect(4,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									
									//Base: -2016, -1168, -176
									//Intended: -2016, -1164, -176
									//Rotation: 0 Yaw
									case 5:
										if (MoverIsLocation(DXM, vect(-2016,-1168,-176)))
										{
											LocAdd = vect(0,4,0);
											PivAdd = vect(0,4,0);
											FrameAdd[0] = vect(0,4,0);
											FrameAdd[1] = vect(0,4,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (Bartender(SP) != None)
							{
								SP.bFearHacking = true;
								SP.bHateHacking = true;
							}
							else if (Hooker2(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 2:
										SP.bFearHacking = true;
										SP.bHateHacking = true;
									break;
								}
							}
						}
						
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPAchille", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPAchille',vect(-217,1144,-144));
								if (SP != None)
								{
									SP.SetOrders('Sitting',, true);
									SP.SeatActor = Seat(FindActorBySeed(class'Chair1', 2));
									SP.Alliance = 'Patrons';
									SP.BarkBindName = "Man";
									SP.InitialAlliances[0].AllianceName = 'ClubStaff';
									SP.InitialAlliances[0].AllianceLevel = 1.0;
									SP.InitialAlliances[1].AllianceName = 'Player';
									SP.InitialInventory[0].Inventory = class'Credits';
									SP.InitialInventory[0].Count = 1;
									SP.ConBindEvents();
								}
							}
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPParisClubGuy", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPParisClubGuy',vect(-463,-327,60), rot(0,-65392,0));
								if (SP != None)
								{
									SP.SetOrders('Dancing',, true);
									SP.BarkBindName = "Man";
									SP.ConBindEvents();
								}
							}
						}
					}
				break;
				//10_PARIS_METRO: BSP error inside a wall.
				//In DXT Maps, hole inside the front desk of the hostel.
				case "10_PARIS_METRO":
					if (!bRevisionMapSet)
					{
						PlugVect = Vect(4373, 0, 860);
						for (i=2161; i<2938; i += 97)
						{
							PlugVect.Y = i;
							AddBSPPlug(PlugVect, 44, 1024);
						}
						
						//One for the hostel, too.
						AddBSPPlug(vect(3281,2240,176), 48, 32);
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 20:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(593,1248,823));
						if (TCamp != None)
						{
							//587, 1220, 825
							//567, 1275, 873
							TCamp.MinCampLocation = Vect(567,1220,825);
							TCamp.MaxCampLocation = Vect(587,1275,873);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
					}
				break;
				//10_PARIS_CATACOMBS: We just came here over beef with the locked cabinet lol.
				case "10_PARIS_CATACOMBS":
					if (!bRevisionMapSet)
					{
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1280,-1092,6));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(-1308,-1085,8);
							TCamp.MaxCampLocation = Vect(-1253,-1065,56);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 17));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 18));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
					}
				break;
				//10_PARIS_CATACOMBS_TUNNELS: Weird fragment classes.
				case "10_PARIS_CATACOMBS_TUNNELS":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
									case 12:
									case 13:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//10_PARIS_CHATEAU: Fifth easter egg.
				case "10_PARIS_CHATEAU":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 16:
										//MADDERS, 6/9/22: This is door is way too fucky.
										//Don't make us crush shit, and don't get diddled by nicolette. Jesus.
										DXM.SetPropertyText("MoverEncroachType", "3");
										DXM.bIsDoor = false;
									break;
								}
							}
						}
						CreateHallucination(vect(-1250, 262, -12), 4, false);
					}
				break;
			}
		break;
		case 11:
			switch(MN)
			{
				//11_PARIS_CATHEDRAL: Gunther isn't friends with a lot of people, and keeps getting froggy. Turn off his hearing.
				case "11_PARIS_CATHEDRAL":
					if (!bRevisionMapSet)
					{
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-6382,291,-542));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(-6479,257,-607);
							TCamp.MaxCampLocation = Vect(-6289,335,-481);
							TCamp.NumWatchedDoors = 1;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'BreakableGlass', 8));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.bIgnoreLockStatus = true;
							TCamp.bLastOpened = true;
						}
						
						//Plug a hole in a crate we can walk through. Oops.
						PlugVect = Vect(2440, 0, 193);
						for (i=-424; i<-188; i += 8)
						{
							PlugVect.Y = i;
							AddBSPPlug(PlugVect, 8, 16);
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (GuntherHermann(SP) != None)
							{
								SP.bReactLoudNoise = false;
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(3536,-2560,-107));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(3541,-2587,-104);
							TCamp.MaxCampLocation = Vect(3562,-2532,-56);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
					}
				break;
				//11_PARIS_EVERETT: Hide the misc, hidden vent, and also the mirror.
				case "11_PARIS_EVERETT":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 2:
									case 4:
									case 5:
										DXM.bHighlight = false;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-252,2553,198));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(-245,2525,200);
							TCamp.MaxCampLocation = Vect(-224,2581,248);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
					}
				break;
			}
		break;
		case 12:
			switch(MN)
			{
				//12_VANDENBERG_CMD: Cabinets and reactions oh my.
				case "12_VANDENBERG_CMD":
					if (!bRevisionMapSet)
					{
						PlugVect = Vect(3081, 0, -1954);
						for (i=1631; i<2094; i += 16)
						{
							PlugVect.Y = i;
							AddBSPPlug(PlugVect, 35, 226);
						}
						
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(2159,1448,-2041));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(2131,1454,-2039);
							TCamp.MaxCampLocation = Vect(2187,1474,-1991);
							TCamp.NumWatchedDoors = 2;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
							TCamp.CabinetDoorClosedFrames[1] = 0;
							TCamp.bLastOpened = true;
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (Mechanic(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 1:
									case 2:
										DumbAllReactions(SP);
									break;
								}
							}
							else if (ScientistMale(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 0:
									case 1:
										DumbAllReactions(SP);
									break;
								}
							}
						}
						
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
									case 3:
									case 4:
									case 10:
										DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//12_VANDENBERG_TUNNEL: Turret needs re-arming.
				//5/24/23: Also, a broken door pivot. Bah.
				case "12_VANDENBERG_TUNNELS":
					if (!bRevisionMapSet)
					{
						//MADDERS, 3/29/21: We're inverted default turret state, since most mods can't keep it in their pants.
						//This is one of very few places where turrets are on by default.
						forEach AllActors(class'AutoTurretSmall', SATur)
						{
							if (SATur != None)
							{
								switch(SF.Static.StripBaseActorSeed(SATur))
								{
									case 0:
										SATur.bDisabled = false;
										SATur.bPreAlarmActiveState = true;
										SATur.bActive = true;
									break;
								}
							}
						}
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 4:
										//Base of -1672, 2522, -2610
										//BEST FIT IS -1672, 2520, -2610.
										//Ignoring Z.
										//Rotation Yaw of 0
										if (MoverIsLocation(DXM, vect(-1672,2522,-2610)))
										{
											LocAdd = vect(0, -2, 0);
											PivAdd = vect(0, -2, 0);
											FrameAdd[0] = vect(0, -2, 0);
											FrameAdd[1] = vect(0, -2, 0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
					}
				break;
				//12_VANDENBERG_COMPUTER: Frobbable softlock doors. Yay.
				case "12_VANDENBERG_COMPUTER":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 11:
									case 12:
										DXM.bFrobbable = false;
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						//MADDERS, 11/1/21: LDDP branching functionality.
						if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
						{
							SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPVanSci", class'Class', true));
							if (SPLoad != None)
							{
								SP = Spawn(SPLoad,,'LDDPVanSci',vect(693,2535,-2167));
								if (SP != None)
								{
									SP.BarkBindName = "Woman";
									SP.FamiliarName = "Stacey Marshall";
									SP.ConBindEvents();
								}
							}
						}
						//Another softlock in such a tiny map? Good grief. Fix scientists breaking trigger positions from things being blown up upstairs.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (SP != None)
							{
								//MADDERS: Eliminate reactions here.
								DumbAllReactions(SP);
							}
						}
					}
				break;
				//12_VANDENBERG_GAS: Fix bad truck key, and add the sixth easter egg.
				//8/11/21: Oops. Loud noise bug inherited from Zodiac attempted fix.
				case "12_VANDENBERG_GAS":
					forEach AllActors(class'ScriptedPawn', SP)
					{
						if (TiffanySavage(SP) != None)
						{
							SP.bReactLoudNoise = false;
						}
					}
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 6:
									case 5:
										DXM.KeyIDNeeded = 'VMDPatchedTruck';
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						Key = Spawn(class'Nanokey',,,vect(-2906,1142,-938));
						if (Key != None)
						{
							Key.Description = VMDPatchedTruckDesc;
							Key.KeyID = 'VMDPatchedTruck';
						}
						
						CreateHallucination(vect(633, 741, -970), 5, false);
					}
				break;
			}
		break;
		case 14:
			//MADDERS note: Defective path node.
			//For all the bullshit we can pull, this ain't under the umbrella.
			//We'll package the minor fix, but otherwise keep it untouched.
			switch(MN)
			{
				//14_OCEANLAB_SILO: Door becomes delet with new path setup, so make it a door, as it should always have been.
				case "14_OCEANLAB_SILO":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'Actor', A)
						{
							DXM = DeusExMover(A);
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 10:
										//Rotation yaw of 0
										//Base: 428, -1456, 513
										//Desired: 424, -1456, 510
										//----------------------
										//IGNORING Z
										if (MoverIsLocation(DXM, Vect(428, -1456, 513)))
										{
											LocAdd = vect(-4,0,0);
											PivAdd = vect(-4,0,0);
											FrameAdd[0] = vect(-4,0,0);
											FrameAdd[1] = vect(-4,0,0);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 15:
										DXM.bIsDoor = true;
									break;
									case 21:
									case 22:
										SetMoverFragmentType(DXM, "Metal");
									break;
								}
								DXM.bMadderPatched = true;
							}
							else if (A.IsA('WeaponModSilencer'))
							{
								switch(SF.Static.StripBaseActorSeed(A))
								{
									case 0:
										Spawn(class'WeaponModReload',,, A.Location, A.Rotation);
										A.Destroy();
									break;
								}
							}
						}
					}
				break;
				//14_VANDENBERG_SUB: Bad door pivot on a hatch... Or two...
				case "14_VANDENBERG_SUB":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 0:
										//Base of 2640, 3228, 340
										//BEST FIT IS 2640, 3228, 344.
										//+++++++++++++++++++++++++++++++
										//Ignoring Z.
										//Rotation Yaw of 16384
										if (MoverIsLocation(DXM, vect(2640,3228,340)))
										{
											LocAdd = vect(0, 0, 4);
											PivAdd = vect(0, 0, 4);
											FrameAdd[0] = vect(0, 0, 4);
											FrameAdd[1] = vect(0, 0, 4);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
									case 11:
										//Base of 3093, 4096, 512
										//BEST FIT IS 3086, 4184, 521.
										//+++++++++++++++++++++++++++++++
										//BUT Intended base of 3083, 4184, 522.
										//Ignoring Y.
										//Rotation Yaw of 0
										if (MoverIsLocation(DXM, vect(3093,4096,512)))
										{
											LocAdd = vect(-10, 0, 10);
											PivAdd = vect(-10, 0, 10);
											FrameAdd[0] = vect(-10, 0, 10);
											FrameAdd[1] = vect(-10, 0, 10);
											DXM.SetLocation(DXM.Location + LocAdd);
											DXM.PrePivot = DXM.PrePivot + PivAdd;
											DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
											DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										}
									break;
								}
								DXM.bMadderPatched = true;
							}
						}
						//Another softlock in such a tiny map? Good grief. Fix scientists breaking trigger positions from things being blown up upstairs.
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (GarySavage(SP) != None)
							{
								//MADDERS: Eliminate reactions here.
								DumbAllReactions(SP);
							}
						}
					}
				break;
				//14_OCEANLAB_LAB: Turrets, plus Simons forgiving the player if they shoot him during the fight, then run.
				//5/24/23: Bad fragments on some lockers, as well.
				case "14_OCEANLAB_LAB":
					if (!bRevisionMapSet)
					{
						//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
						//This is one of very few places where turrets are on by default.
						forEach AllActors(class'AutoTurret', ATur)
						{
							if (ATur != None)
							{
								ATur.bDisabled = false;
								ATur.bPreAlarmActiveState = true;
								ATur.bActive = true;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if (WaltonSimons(SP) != None)
							{
								SP.EnemyTimeout = 3600;
							}
							//MADDERS, 8/18/23: EMP this little guy, to keep paths consistent. He should've drowned anyways.
							else if ((MedicalBot(SP) != None) && (SP.Region.Zone.bWaterZone))
							{
								SP.TakeDamage(250, SP, SP.Location, vect(0,0,0), 'EMP');
							}
						}
						forEach AllActors(class'DeusExMover', DXM)
						{
							if ((DXM != None) && (!DXM.bMadderPatched))
							{
								switch(SF.Static.StripBaseActorSeed(DXM))
								{
									case 1:
									case 12:
									case 14:
									case 15:
									case 16:
									case 17:
									case 18:
									case 19:
										SetMoverFragmentType(DXM, "Metal");
									break;
									
									//MADDERS, 8/8/23: For some reason DXT breaks this key combo. Fix it here.
									case 54:
									case 64:
										DXM.KeyIDNeeded = 'OLStorage';
									break;
								}
							}
						}
					}
				break;
				//14_OCEANLAB_UC: Seventh and final easter egg.
				case "14_OCEANLAB_UC":
					if (!bRevisionMapSet)
					{
						//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
						//This is one of very few places where turrets are on by default.
						forEach AllActors(class'AutoTurret', ATur)
						{
							if (ATur != None)
							{
								ATur.bDisabled = false;
								ATur.bPreAlarmActiveState = true;
								ATur.bActive = true;
							}
						}
						CreateHallucination(vect(1878, 6436, -3083), 6, false);
					}
				break;
			}
		break;
		case 15:
			switch(MN)
			{
				//15_AREA51_BUNKER: Slightly illogical login.
				case "15_AREA51_BUNKER":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'Computers', Comp)
						{
							if (ComputerSecurity(Comp) != None)
							{
								switch(SF.Static.StripBaseActorSeed(Comp))
								{
									case 1:
										Comp.UserList[0].UserName = "A51";
										Comp.UserList[0].Password = "xx15yz";
									break;
								}
							}
						}
					}
				break;
				//15_AREA51_ENTRANCE: Fix nabbable aug through the glass.
				case "15_AREA51_ENTRANCE":
					if (!bRevisionMapSet)
					{
						TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(4805,484,-95));
						if (TCamp != None)
						{
							TCamp.MinCampLocation = Vect(4733,386,-130);
							TCamp.MaxCampLocation = Vect(4898,514,132);
							TCamp.NumWatchedDoors = 1;
							TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 126));
							TCamp.CabinetDoorClosedFrames[0] = 0;
							TCamp.bIgnoreLockStatus = true;
							TCamp.bLastOpened = true;
							TCamp.bOpenOnceOnly = true; //Hack for the fact we can climb INTO this one.
						}
					}
				break;
				case "15_AREA51_FINAL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							SP = ScriptedPawn(TPawn);
							if ((Mechanic(SP) != None) && (SF.Static.StripBaseActorSeed(SP) == 0))
							{
								SP.bReactLoudNoise = false;
								SP.bReactProjectiles = false;
								SP.bHateShot = false;
							}
						}
						
						//MADDERS, 4/3/24: Helios NG plus.
						NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-4001, 892, -1359), Rot(0, -16384, 0));
						if (NGPortal != None)
						{
							NGPortal.FlagRequired = 'HeliosFree';
						}
						
						//MADDERS, 4/3/24: A51 nuke NG plus.
						NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-3279, -4972, -1596), Rot(0, -16384, 0));
						if (NGPortal != None)
						{
							NGPortal.FlagRequired = 'ReactorButton1';
						}
					}
				break;
				//15_Area51_Page: Turret rework, bby.
				case "15_AREA51_PAGE":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'AutoTurret', ATur)
						{
							//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
							//This is one of very few places where turrets are on by default.
							if (ATur != None)
							{
								ATur.bDisabled = false;
								ATur.bPreAlarmActiveState = true;
								ATur.bActive = true;
							}
						}
						
						//MADDERS, 4/3/24: Bob page kill NG plus.
						NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(6268, -6537, -5140), Rot(0, 16384, 0));
						if (NGPortal != None)
						{
							NGPortal.FlagRequired = 'DL_Blue4_Played';
						}
					}
				break;
			}
		break;
		case 16:
			switch(MN)
			{
				//+++++++++++++++++++++++
				//AGENDA Maps... We're secretly M16... Fuck you.
				
				//44_AGENDA10: CameraFOV is so prevalant in some rooms that you will be seen, regardless of camera rotation. Ugh.
				//Additionally, there's a broken door pivot... But the door is so busted it can't be fixed in post.
				case "44_AGENDA10":
					forEach AllActors(class'Actor', A)
					{
						if ((SecurityCamera(A) != None) && (SecurityCamera(A).CameraFOV > 6144))
						{
							SecurityCamera(A).CameraFOV = 6144;
						}
						if ((ScriptedPawn(A) != None) && (class<Weapon>(ScriptedPawn(A).InitialInventory[0].Inventory) == None))
						{
							ScriptedPawn(A).bReactLoudNoise = false;
						}
					}
					
					//MADDERS, 4/5/24: ANT Agenda NG plus. Leave it some distance away from teleporter.
					//6/20/24: Actually found a better way to do this lol.
					/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(2835, 2167, 876), Rot(0, -24576, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = 'DL_Weisshaupt5_Played';
						NGPortal.bUnlit = true; //MADDERS, 4/5/24: Hack because we are easily lost in the dark.
					}*/
				break;
				
				//+++++++++++++++++++++++
				//Utopia Maps
				//UTOPIA_SUBWAY: Need NG Plus Portal
				case "UTOPIA_SUBWAY":
					NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(105, 287, -28), Rot(0, 32768, 0));
				break;
				
				//+++++++++++++++++++++++
				//CARONE Maps
				
				//16_HOTELCARONE_INTRO: Mission number hack? Yeet.
				case "16_HOTELCARONE_INTRO":
					if (!GetFlagBool('mapdone'))
					{
						LI.MissionNumber = 15;
					}
					
					//MADDERS, 4/3/24: HC NG Plus.
					//6/20/24: Actually found a better way to do this lol.
					/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(8444, 29395, -8964), Rot(0, 0, 0));
					NGPortal.FlagRequired = 'MapDone';*/
				break;
				
				//16_HOTELCARONE_HOTEL: Hide alex's walls. Yeah. Work for it.
				//Additionally, there's at least 1 keypad with bad collision vs drawscale. RS2020 flashbacks.
				//Finally, there's some NPCs with vomit for names, so we gotta make it more human friendly, FFS.
				case "16_HOTELCARONE_HOTEL":
					forEach AllActors(class'Keypad', KP)
					{
						if (KP != None)
						{
							KP.SetCollisionSize(KP.Default.CollisionRadius * KP.Drawscale, KP.Default.CollisionHeight * KP.Drawscale);
						}
					}
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								case 93:
								case 161:
									//DXM.bHighlight = false;
								break;
								case 76:
								case 96:
									DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
								break;
							}
							DXM.bMadderPatched = true;
						}
					}
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (SP != None)
						{
							switch (SP.Class.Name)
							{
								case 'HKMilitary':
									switch(SF.Static.StripBaseActorSeed(SP))
									{
										case 0:
										case 1:
											SP.FamiliarName = "UNATCO Back Door Guard";
											SP.UnfamiliarName = SP.FamiliarName;
										break;
										case 2:
										case 3:
											SP.FamiliarName = "Terrorist Back Door Guard";
											SP.UnfamiliarName = SP.FamiliarName;
										break;
									}
								break;
								case 'Female1':
									switch(SF.Static.StripBaseActorSeed(SP))
									{
										case 0:
											SP.FamiliarName = "Toilet Girl";
											SP.UnfamiliarName = SP.FamiliarName;
										break;
									}
								break;
								case 'TerroristCommander':
									switch(SF.Static.StripBaseActorSeed(SP))
									{
										case 0:
											SP.FamiliarName = "Mr. Fish";
										break;
									}
								break;
							}
						}
					}
				break;
				//16_HOTELCARONE_HOUSE: Fix manderley's reactions. Ugh.
				case "16_HOTELCARONE_HOUSE":
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (JosephManderley(SP) != None)
						{
							//MADDERS: Eliminate reactions here.
							DumbAllReactions(SP);
						}
					}
				break;
				//16_THE_HQ: Broken door pivots galore.
				case "16_THE_HQ":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								//Base of 1120, 512, 64
								//Intended base of 1128, 512, 64.
								//Ignoring Z.
								//Rotation Yaw of 32768
								case 15:
									if (MoverIsLocation(DXM, vect(1120,512,64)))
									{
										LocAdd = vect(8,0,0);
										PivAdd = vect(-8,0,0);
										FrameAdd[0] = vect(8,0,0);
										FrameAdd[1] = vect(8,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of 192, -896, -16
								//Intended base of 186, -896, -16.
								//Ignoring Z.
								//Rotation Yaw of 0
								//To fix bad placement, final loc of 188, 196, -16.
								//Another +2 X, in other words.
								case 36:
									if (MoverIsLocation(DXM, vect(192,-896,-16)))
									{
										LocAdd = vect(-4,0,0);
										PivAdd = vect(-6,0,0);
										FrameAdd[0] = vect(-4,0,0);
										FrameAdd[1] = vect(-4,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of -1184, -800, -16
								//Intended base of -1180, -800, -12.
								//Ignoring Z.
								//Rotation Yaw of 0
								case 38:
									if (MoverIsLocation(DXM, vect(-1184,-800,-16)))
									{
										LocAdd = vect(4,0,0);
										PivAdd = vect(4,0,0);
										FrameAdd[0] = vect(4,0,0);
										FrameAdd[1] = vect(4,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of -2368, -1236, -16
								//Intended base of -2368, -1244, -16.
								//Ignoring Z.
								//Rotation Yaw of 16384
								case 39:
									if (MoverIsLocation(DXM, vect(-2368,-1236,-16)))
									{
										LocAdd = vect(0,-8,0);
										PivAdd = vect(-8,0,0);
										FrameAdd[0] = vect(0,-8,0);
										FrameAdd[1] = vect(0,-8,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of 608, -896, 0
								//Intended base of 604, -896, 0.
								//Ignoring Z.
								//Rotation Yaw of 0
								//Also, it's floating by 8 units ffs.
								case 41:
									if (MoverIsLocation(DXM, vect(608,-896,0)))
									{
										LocAdd = vect(-4,0,-8);
										PivAdd = vect(-4,0,0);
										FrameAdd[0] = vect(-4,0,-8);
										FrameAdd[1] = vect(-4,0,-8);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
							}
						}
					}
				break;
				//16_FATAL_WEAPON: Bad teleporter size. Sigh.
				case "16_FATAL_WEAPON":
					forEach AllActors(class'MapExit', MapEx)
					{
						if (MapEx != None)
						{
							switch(SF.Static.StripBaseActorSeed(MapEx))
							{
								case 0:
								case 1:
								case 2:
									MapEx.SetCollisionSize(65, MapEx.CollisionHeight);
								break;
							}
						}
					}
				break;
			}
		break;
		case 20:
			switch(MN)
			{
				case "CF_04_SUBWAY":
					//MADDERS, 4/5/24: Counterfeit end of campaign, as it comes screeching to a halt.
					NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-246, 111, -84), Rot(0, 16384, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = '';
					}
				break;
			}
		case 21:
			switch(MN)
			{
				case "21_TOKYO_BANK":
					//MADDERS, 4/3/24: Helios NG plus.
					NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(0, 395, -268), Rot(0, -16384, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = 'Hacking_Played';
					}
				break;
				
				//+++++++++++++++++++++++
				//REDSUN Maps
				
				//21_OTEMACHILAB: Add food to be merciful
				case "21_OTEMACHILAB_1":
					//Candy near starting area, for generosity
					Spawn(class'CandyBar',,,vect(616.5, 389, 1), rot(0,-5200,0));
					
					//Medical room soyfood
					Spawn(class'SoyFood',,,vect(533, -527, 49), rot(0,0,0));
					
					//Gamer dude's soda
					Spawn(class'SodaCan',,,vect(-808.5, -291, 53), rot(0,0,0));
					Spawn(class'SodaCan',,,vect(-818, -295, 53), rot(0,13000,0));
					
					//Barracks table food
					Spawn(class'SoyFood',,,vect(1760, -1257.25, 31), rot(0,0,0));
					Spawn(class'CandyBar',,,vect(1764, -1284, 31), rot(0,-4640,0));
				break;
				
				//21_OTEMACHIKU: Pivot fixes out the fucking ass.
				case "21_OTEMACHIKU":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
						{
							PivAdd = vect(0,0,0);
							LocAdd = vect(0,0,0);
							for(i=0; i<8; i++)
							{
								FrameAdd[i] = vect(0,0,0);
							}
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								//2nd door on entry; Slightly busted pivot
								case 9:
									FrameAdd[0] = vect(0,0,0);
									PivAdd = (vect(-1,0,0));
									LocAdd = vect(1,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								break;
								//MADDERS, 7/2/24: Door gets stuck. It's crap.
								case 42:
									DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
								break;
								//Vent into CD shop; Lots wrong here.
								case 44:
									FrameAdd[0] = vect(4,0,-0.05);
									FrameAdd[1] = vect(3,1,-1); //X is for forward/back
									PivAdd = (vect(4, 0, 1));
									LocAdd = FrameAdd[0];
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								break;
								//Sewer door; All sorts of fucked.
								case 50:
									FrameAdd[0] = vect(0,-5,0);
									FrameAdd[1] = vect(0,-5,4);
									PivAdd = (vect(-4, 0, 0));
									LocAdd = FrameAdd[0];
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								break;
								//Upstairs lobby; Door clips into wall.
								case 71:
									FrameAdd[1] = vect(0,-4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								break;
							}
							DXM.bMadderPatched = true;
						}
					}
					//MADDERS, 5/31/22: We can step on these filler cleaner bots. JFC.
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (Cleanerbot(SP) != None)
						{
							SP.bProjTarget = false;
							SP.bBlockPlayers = false;
						}
					}
				break;
				//21_TMGComplex: Fix this rogue turret.
				case "21_TMGComplex":
					/*forEach AllActors(class'AutoTurret', ATur)
					{
						if (ATur != None)
						{
							ATur.bActive = false;
						}
					}*/
				break;
				//21_HIBIYAPARK_TOWERS: Hide this mover, for the sake of exploration.
				//Also, fix these rogue turrets.
				case "21_HIBIYAPARK_TOWERS":
					/*forEach AllActors(class'AutoTurret', ATur)
					{
						if (ATur != None)
						{
							ATur.bActive = false;
						}
					}*/
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								case 27:
									DXM.bHighlight = false;
								break;
							}
							DXM.bMadderPatched = true;
						}
					}
				break;
				//21_SHINJUKUSTATION: Sound volume gets fucked up for some players after travel.
				case "21_SHINJUKUSTATION":
					if (VMP != None)
					{
						VMP.SetInstantSoundVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"))));
						VMP.SetInstantMusicVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"))));
						VMP.SetInstantSpeechVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice SpeechVolume"))));
					}
				break;
			}
		break;
		case 22:
			switch(MN)
			{
				//22_TOKYO_AQUA: Broke door pivot. Also, give Quick the boot.
				case "22_TOKYO_AQUA":
					//Broken door pivot to doggo room
					forEach AllActors(class'Actor', A)
					{
						DXM = DeusExMover(A);
						if (DXM != None)
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								//Base of -5632, 2432, -1120
								//Intended base of -5632, 2436, -1120
								//Ignoring Z.
								//Rotation Yaw of 16384, AND pitch of 32768, AND roll of 32768... What the fuck?
								//This is equivalent to 49152 yaw, though.
								//Also, this door sucks at how it moves.
								case 50:
									DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
									if (MoverIsLocation(DXM, vect(-5632,2432,-1120)))
									{
										LocAdd = vect(0,4,0);
										PivAdd = vect(-4,0,0);
										FrameAdd[0] = vect(0,4,0);
										FrameAdd[1] = vect(0,4,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
							}
						}
						//Gordon quick is awkwardly standing here and invincible, with no dialogue. Axe him.
						else if (GordonQuick(A) != None)
						{
							A.Destroy();
						}
					}
				break;
				//22_KUROKUMA_BASE1: Remove silencer, and add a backup password for the bad font usage.
				case "22_KUROKUMA_BASE1":
					forEach AllActors(class'Computers', Comp)
					{
						if ((Comp != None) && (Comp.IsA('RS_ComputerSecurity')))
						{
							switch(SF.Static.StripBaseActorSeed(Comp))
							{
								case 0:
									Comp.UserList[1].UserName = "Basel_Security";
									Comp.UserList[1].Password = "Yakuzza1";
								break;
							}
						}
					}
					
					forEach AllActors(class'Actor', A)
					{
						//Duplicate aug can. Blank aug cans out the whazoo. Fuck's sake, RS2020.
						if (AugmentationCannister(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 1:
									AugmentationCannister(A).AddAugs[0] = 'AugAqualung';
									AugmentationCannister(A).AddAugs[1] = 'AugEMP';
								break;
							}
						}
					}
					
					//MADDERS: No silencer, please.
					forEach AllActors(class'DeusExWeapon', DXW)
					{
						if ((DXW != None) && (DXW.IsA('WeaponPistol')))
						{
							switch(SF.Static.StripBaseActorSeed(DXW))
							{
								case 0:
									DXW.bHasSilencer = false;
								break;
							}
						}
					}
				break;
				//22_KUROKUMA_HIDEOUT: Bad map transfer URL. Duplicate aug can. 2 blank aug cans. Broken door pivot.
				//Undersized button collision. 6 gas grenades that falsely detonate on map start and are hidden.
				//2 gas grenades with 10x their intended collision size for... Some reason. Random BSP hole. JFC.
				//This may genuinely be the worst map fix I ever have to do.
				case "22_KUROKUMA_HIDEOUT":
					//Oops. Improper Map URL.
					forEach AllActors(class'MapExit', MapEx)
					{
						if (MapEx != None)
						{
							switch(SF.Static.StripBaseActorSeed(MapEx))
							{
								case 2:
									MapEx.DestMap = "22_Kurokuma_Base2#Base2ExitElevator";
								break;
							}
						}
					}
					forEach AllActors(class'Actor', A)
					{
						//Duplicate aug can. Blank aug cans out the whazoo. Fuck's sake, RS2020.
						if (AugmentationCannister(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 0:
									AugmentationCannister(A).AddAugs[0] = 'AugBallistic';
									AugmentationCannister(A).AddAugs[1] = 'AugRadarTrans';
								break;
								case 2:
									AugmentationCannister(A).AddAugs[0] = 'AugHeartlung';
									AugmentationCannister(A).AddAugs[1] = 'AugDrone';
								break;
								case 5:
									A.Destroy();
								break;
							}
						}
						//Giant buttons with small collision. JFC.
						if (Button1(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 2:
								case 3:
								case 4:
								case 5:
								case 6:
								case 12:
									A.SetCollisionSize(A.Default.CollisionRadius * A.DrawScale, A.Default.CollisionHeight * A.DrawScale);
								break;
							}
						}
						if (GasGrenade(A) != None)
						{
							A.bHidden = false;
							A.SetCollisionSize(A.Default.CollisionRadius, A.Default.CollisionHeight);
							switch(SF.Static.StripBaseActorSeed(A))
							{
								//Not prox triggered. Oops.
								case 8:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(634, -2541, -6935));
									A.SetRotation(rot(65536, 65536, 0));
								break;
								case 10:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(636, -2367, -6982));
									A.SetRotation(rot(65536, 65536, 0));
								break;
								case 11:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(636, -2787, -6938));
									A.SetRotation(rot(65536, 65536, 0));
								break;
								case 12:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(636, -1905, -6956));
									A.SetRotation(rot(65536, 65536, 0));
								break;
								case 13:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(636, -2178, -6917));
									A.SetRotation(rot(65536, 65536, 0));
								break;
								case 14:
									GasGrenade(A).bProximityTriggered = true;
									A.SetPhysics(PHYS_None);
									A.SetLocation(vect(636, -2864, -6900));
									A.SetRotation(rot(65536, 65536, 0));
								break;
							}
						}
					}
					//Broken door pivot to doggo room
					forEach AllActors(class'DeusExMover', DXM)
					{
						if (DXM != None)
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								//Base of 176, -1856, -6912
								//Intended base of 170, -1856, -6911.
								//Ignoring Z.
								//Rotation Yaw of 49152 (3/4 spin)
								case 11:
									if (MoverIsLocation(DXM, vect(176,-1856,-6912)))
									{
										LocAdd = vect(-6,0,0);
										PivAdd = vect(0,6,0);
										FrameAdd[0] = vect(-6,0,0);
										FrameAdd[1] = vect(-6,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
							}
						}
					}
					AddBSPPlug(vect(-3474, -4089, -7154), 75.0, 2.0);
				break;
				//22_LOSTCITY: Bad door pivots, and DTS clipping through its box. "Circumcised", as one person called it, I believe.
				case "22_LOSTCITY":
					forEach AllActors(class'Actor', A)
					{
						//Clipping DTS. Ech. Drop it on the ground outside the box. Anything is an upgrade from phasing through shit.
						if (WeaponNanoSword(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 0:
									A.SetLocation(vect(2130,1153,-741));
								break;
							}
						}
					}
					//Busted pivots ahoy.
					forEach AllActors(class'DeusExMover', DXM)
					{
						if (DXM != None)
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								//Base of -896, -1040, -368
								//Intended -901, -1040, -367.
								//Ignoring Z.
								//Rotation Yaw of 32768 (1/2 spin)
								case 0:
									if (MoverIsLocation(DXM, vect(-896,-1040,-368)))
									{
										LocAdd = vect(-5,0,0);
										PivAdd = vect(5,0,0);
										FrameAdd[0] = vect(-5,0,0);
										FrameAdd[1] = vect(-5,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of -2288, 320, -880
								//Intended -2288, 321, -880.
								//Ignoring Z.
								//Rotation Yaw of 32768 (1/2 spin)
								case 3:
									if (MoverIsLocation(DXM, vect(-2288,320,-880)))
									{
										LocAdd = vect(0,1,0);
										PivAdd = vect(0,-1,0);
										FrameAdd[0] = vect(0,1,0);
										FrameAdd[1] = vect(0,1,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
								//Base of 496, 1056, -240
								//Intended 502, 1057, -240.
								//UPDATE: Aiming for 506, 1057, -240
								//Ignoring Z.
								//Rotation Yaw of 32768 (1/2 spin)
								case 4:
									if (MoverIsLocation(DXM, vect(496,1056,-240)))
									{
										LocAdd = vect(6,1,0)+vect(4,0,0);
										PivAdd = vect(-6,-1,0);
										FrameAdd[0] = vect(6,1,0)+vect(4,0,0);
										FrameAdd[1] = vect(6,1,0)+vect(4,0,0);
										DXM.SetLocation(DXM.Location + LocAdd);
										DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
										DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
										DXM.PrePivot = DXM.PrePivot + PivAdd;
									}
								break;
							}
						}
					}
				break;
				case "22_TOKYOSTATION":
					forEach AllActors(class'CrateExplosiveSmall', CExpSmall)
					{
						switch(SF.Static.StripBaseActorSeed(CExpSmall))
						{
							case 0:
							case 1:
							case 2:
								CExpSmall.bHidden = true;
							break;
						}
					}
					
					//MADDERS, 4/3/24: Redsun NG plus. Just outside the bossfight.
					//6/20/24: Actually found a better way to do this lol.
					/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(2004, -9783, 426), Rot(0, -16384, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = '';
					}*/
				break;
			}
		break;
		case 50:
			switch(MN)
			{
				case "50_OMEGASTART":
					//MADDERS, 4/3/24: Omega NG plus. Weird hack with the movers, but aight, this way we'll know.
					NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(20, 5295, 812), Rot(0, -8192, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = '';
						NGPortal.CampMovers[0] = Mover(FindActorBySeed(class'ElevatorMover', 0));
						NGPortal.CampMoverFrames[0] = 1;
						NGPortal.CampMovers[1] = Mover(FindActorBySeed(class'ElevatorMover', 1));
						NGPortal.CampMoverFrames[1] = 1;
						NGPortal.CampMovers[2] = Mover(FindActorBySeed(class'ElevatorMover', 2));
						NGPortal.CampMoverFrames[2] = 1;
					}
				break;
				case "50_OMEGAVOL3":
					forEach AllActors(class'Mover', TMov)
					{
						if (ElevatorMover(TMov) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TMov))
							{
								//MADDERS, 7/2/24: Door gets stuck. It's crap.
								case 1:
									TMov.MoverEncroachType = ME_IgnoreWhenEncroach;
								break;
							}
						}
					}
				break;
			}
		break;
		case 56:
			switch(MN)
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
					//MADDERS, 6/21/24: Underground lab NG plus.
					NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(1913, -2120, -2860), Rot(0, -16384, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = 'DL_Finished_Played';
					}
				break;
			}
		break;
		case 58:
			switch(MN)
			{
				//58_YUANDAZHU_STREETS: Fix player's skills not resetting.
				case "58_YUANDAZHU_STREETS":
					if (VMDBufferPlayer(GetPlayerPawn()) != None)
					{
						VMDBufferPlayer(GetPlayerPawn()).VMDResetNewGameVars(5);
					}
				break;
			}
		break;
		case 60:
			switch(MN)
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
			}
		break;
		case 65:
			switch(MN)
			{
				//65_WOODFIBRE_BEACHFRONT: Vending machine is broken lol. Phase 2 onwards issue.
				case "65_WOODFIBRE_BEACHFRONT":
					forEach AllActors(class'Actor', A)
					{
						if (VendingMachine(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 0:
									A.SetRotation(Rot(0, -16384, 0));
								break;
							}
						}
					}
				break;
			}
		break;
		case 70:
			switch(MN)
			{
				//70_NORTHMONROE_ENTRY: Fix player's skills not resetting.
				case "70_NORTHMONROE_ENTRY":
					if (VMDBufferPlayer(GetPlayerPawn()) != None)
					{
						VMDBufferPlayer(GetPlayerPawn()).VMDResetNewGameVars(5);
					}
				break;
				
				//71_MUTATIONS: Tip about bind map key.
				case "70_MUTATIONS":
					if (VMDBufferPlayer(GetPlayerPawn()) != None)
					{
						VMDBufferPlayer(GetPlayerPawn()).BigClientMessage(VMDBufferPlayer(GetPlayerPawn()).MutationsMapTip);
					}
				break;
			}
		break;
		case 71:
			switch(MN)
			{
				//71_MUTATIONS: Turrets are intended to be active, but are not. Fix this.
				case "71_MUTATIONS":
					forEach AllActors(class'AutoTurret', ATur)
					{
						if (ATur != None)
						{
							ATur.bActive = true;
						}
					}
				break;
				//71_ZODIAC_LANGLEY_CIAHQ: Hiding portrait, in-line with prior changes.
				case "71_ZODIAC_LANGLEY_CIAHQ":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
						{
							switch(SF.Static.StripBaseActorSeed(DXM))
							{
								case 1:
									DXM.bHighlight = false;
								break;
							}
							DXM.bMadderPatched = true;
						}
					}
				break;
			}
		break;
		case 72:
			switch(MN)
			{
				//72_MUTATIONS1/3: Turrets are intended to be active, but are not. Fix this.
				case "72_MUTATIONS1":
				case "72_MUTATIONS3":
					forEach AllActors(class'AutoTurret', ATur)
					{
						if (ATur != None)
						{
							ATur.bActive = true;
						}
					}
				break;
				//72_ZODIAC_BUENOSAIRES: Hiding portrait, in-line with prior changes.
				case "72_ZODIAC_BUENOSAIRES":
					forEach AllActors(class'DeusExMover', DXM)
					{
						if ((DXM != None) && (!DXM.bMadderPatched))
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
		break;
		case 73:
			switch(MN)
			{
				//73_ZODIAC_NEWMEXICO_PAGEBIO: Lights here do not work with non-classic d3d10, and barely work with a normal renderer.
				//Fuck with all the values and then call flush to fix this.
				case "73_ZODIAC_NEWMEXICO_PAGEBIO":
					forEach AllActors(class'Light', Lig)
					{
						if (Lig != None)
						{
							switch(SF.Static.StripBaseActorSeed(Lig))
							{
								case 19:
								case 20:
								case 21:
								case 22:
								case 23:
								case 28:
								case 78:
								case 80:
								case 91:
								case 98:
								case 171:
								case 172:
								case 173:
								case 174:
								case 175:
								case 176:
								case 177:
								case 178:
								case 179:
								case 180:
								case 184:
								case 185:
								case 186:
								case 188:
								case 189:
								case 191:
								case 182:
								case 181:
								case 183:
								case 190:
								case 192:
								case 223:
								case 224:
								case 225:
								case 226:
								case 227:
								case 228:
								case 229:
								case 230:
								case 231:
								case 234:
								case 235:
								case 236:
								case 237:
								case 482:
								case 483:
								case 484:
								case 485:
								case 486:
								case 487:
								case 490:
								case 491:
								case 492:
								case 493:
								case 494:
								case 495:
								case 496:
								case 497:
									Lig.LightBrightness = 38;
								break;
								
								case 240:
								case 241:
								case 242:
								case 243:
								case 244:
								case 245:
								case 246:
								case 247:
								case 248:
								case 249:
								case 250:
								case 251:
								case 252:
								case 253:
								case 254:
								case 255:
								case 256:
								case 257:
								case 258:
								case 259:
								case 260:
								case 261:
								case 262:
								case 263:
								case 264:
								case 265:
								case 266:
								case 267:
								case 373:
								case 375:
								case 376:
								case 377:
								case 378:
								case 379:
								case 380:
								case 381:
								case 403:
								case 404:
								case 405:
								case 406:
								case 407:
								case 409:
								case 410:
								case 411:
								case 412:
								case 413:
								case 414:
								case 415:
								case 416:
								case 438:
								case 446:
								case 447:
									Lig.LightBrightness = 42;
								break;
							}
						}
					}
					if (GetPlayerPawn() != None) GetPlayerPawn().ConsoleCommand("FLUSH");
				break;
				//73_ZODIAC_NEWMEXICO_UGROUNDA: Defaults to 1234. Not sure why. Randomize it.
				case "73_ZODIAC_NEWMEXICO_UGROUNDA":
					forEach AllActors(class'Keypad', KP)
					{
						if (Keypad3(KP) != None)
						{
							switch(SF.Static.StripBaseActorSeed(KP))
							{
								case 5:
									switch(Rand(7))
									{
										case 0:
											KP.ValidCode = "1568";
										break;
										case 1:
											KP.ValidCode = "4518";
										break;
										case 2:
											KP.ValidCode = "8624";
										break;
										case 3:
											KP.ValidCode = "5134";
										break;
										case 4:
											KP.ValidCode = "7415";
										break;
										case 5:
											KP.ValidCode = "1264";
										break;
										case 6:
											KP.ValidCode = "7156";
										break;
									}
								break;
							}
						}
					}
				break;
				//73_ZODIAC_NEWMEXICO_UGROUNDB: Sequence break from panicking scientists. Sigh.
				case "73_ZODIAC_NEWMEXICO_UGROUNDB":
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (SP != None)
						{
							if (SP.IsA('EllenBlake') || SP.IsA('ScientistMale') || SP.IsA('WilliamHunt'))
							{
								SP.bReactLoudNoise = false;
							}
						}
					}
				break;
			}
		break;
		76:
			switch(MN)
			{
				case "76_ZODIAC_EGYPT_EBASE":
					//MADDERS, 4/3/24: Zodiac NG Plus, bad guy ending.
					//6/20/24: Actually found a better way to do this lol.
					/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(4522, -11255, -508), Rot(0, 0, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = '';
					}*/
				break;
				case "76_ZODIAC_EGYPT_REACTOR":
					//MADDERS, 4/3/24: Zodiac NG Plus, good guy ending.
					//6/20/24: Actually found a better way to do this lol.
					/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(987, -86, 60), Rot(0, 32768, 0));
					if (NGPortal != None)
					{
						NGPortal.FlagRequired = 'M76_Reactor_Blown';
					}*/
				break;
			}
		break;
	}
	if ((TestLoc != vect(0,0,0)) && (GetPlayerPawn() != None))
	{
		GetPlayerPawn().SetLocation(TestLoc);
		GetPlayerPawn().ConsoleCommand("Invisible 1");
	}
	
	//MADDERS: 11/1/21: Update our convo shit for max compatibility, thanks to some LDDP fuckery we're doing. What a weird methodology I chose.
	DeusExPlayer(GetPlayerPawn()).ConBindEvents();
	
	bRanFixes = true;
}

function string VMDGetMapName()
{
 	local string S, S2;
 	
 	S = GetURLMap();
 	S2 = Chr(92); //What the fuck. Can't type this anywhere!
	
	//MADDERS, 3/23/21: Uuuuh... Oceanlab machine :B:ROKE.
	//No idea how or why this happens, and only post-DXT merge. Fuck it. Chop it down.
	if (Right(S, 1) ~= " ") S = Left(S, Len(S)-1);
	
 	//HACK TO FIX TRAVEL BUGS!
 	if (InStr(S, S2) > -1)
 	{
  		do
  		{
   			S = Right(S, Len(S) - InStr(S, S2) - 1);
  		}
  		until (InStr(S, S2) <= -1);

		if (InStr(S, ".") > -1)
		{
  			S = Left(S, Len(S) - 4);
		}
 	}
 	else
	{
		if (InStr(S, ".") > -1)
		{
			S = Left(S, Len(S)-3);
		}
 	}
	
 	return CAPS(S);
}

function Actor FindActorBySeed(class<Actor> TarClass, int TarSeed)
{
	local Actor TAct;
	
	forEach AllActors(TarClass, TAct)
	{
		if ((TAct != None) && (TarClass == TAct.Class) && (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TAct) == TarSeed))
		{
			return TAct;
		}
	}
	
	return None;
}

defaultproperties
{
     VMDPatchedTruckDesc="Gas station truck"
     
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
