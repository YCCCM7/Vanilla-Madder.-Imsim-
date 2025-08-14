//=============================================================================
// VMDMayhemActor.
//=============================================================================
class VMDNakedSolutionActor extends VMDFillerActors;

var bool bRanTweaks, bRevisionMapSet;
var int RandIndex, RandBarf[100];
var float TweakTimer;

var VMDBufferPlayer VMP;

function VMDUpdateRevisionMapStatus()
{
	switch(class'VMDStaticFunctions'.static.GetIntendedMapStyle(Self))
	{
		case 0:
			bRevisionMapSet = false;
		break;
		case 1:
			bRevisionMapSet = true;
		break;
		case 2:
			bRevisionMapSet = false;
		break;
	}
}

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (!bRanTweaks)
	{
 		if (TweakTimer < 0.9)
		{
			TweakTimer += DT;
		} 
		else if (TweakTimer > -10)
 		{
 	 		TweakTimer = -30;
			VMDUpdateRevisionMapStatus();
			CommitNakedSolutionNerfing();
	 	}
	}
}

function InitRandData(VMDBufferPlayer VMP)
{
	local int i, CurRip, MySeed;
	local float TMission;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	TMission = VMDGetMissionNumber();
	
	MySeed = SF.Static.DeriveStableNakedSolutionSeed(Self, 32, true);
	for(i=0; i<ArrayCount(RandBarf); i++)
	{
		CurRip = SF.Static.RipLongSeedChunk(MySeed, i);
		RandBarf[i] = CurRip;
	}
	
	//MADDERS, 10/28/24: More diversity within seeds. Important for true diversity, if seeds all conspire.
	if (VMP != None)
	{
		RandIndex = VMP.PlayerNakedSolutionSubseed;
	}
}

function float FakeFRand()
{
	local float Ret;
	
	Ret = float(RandBarf[RandIndex]) / 100.0;
	RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
	
	return Ret;
}

function float FakeRand(int Ceil)
{
	local int Ret;
	
	Ret = RandBarf[RandIndex] % Ceil;
	RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
	
	return Ret;
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

function CommitNakedSolutionNerfing()
{
	local int TMission, TranslatedNumber;
	local float TFactor;
	local string TMap;
	
	local int RemoveSolutions[16];
	local Actor TAct;
	local class<VMDStaticFunctions> SF;
	
	bRanTweaks = true;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
	}
	
	if (VMP == None || VMP.SavedNakedSolutionReductionRate <= 0) return;
	
	InitRandData(VMP);
	
	TMission = VMDGetMissionNumber();
	
	TranslatedNumber = VMP.SavedNakedSolutionMissionEnd;
	if (TranslatedNumber > 6)
	{
		TranslatedNumber += 1;
	}
	if (TranslatedNumber > 13)
	{
		TranslatedNumber += 1;
	}
	
	if ((TranslatedNumber <= 15) && (TranslatedNumber < TMission)) return;
	
	//Actual apply some cock blockery now, thanks.
	TFactor = float(VMP.SavedNakedSolutionReductionRate) * 0.2501; //Fudge for 100% always being 100.
	TMap = VMDGetMapName();
	SF = class'VMDStaticFunctions';
	
	/*for(i=0; i<10; i++)
	{
		TestHack = FakeFRand();
		BroadcastMessage(TestHack@TFactor@(TestHack < TFactor)@int(TestHack < TFactor));
	}*/
	
	if (!bRevisionMapSet)
	{
		switch(TMap)
		{
			//1111111111111111111111111111
			//MISSION 01
			case "01_NYC_UNATCOISLAND":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					//At random: Remove some of the TNT to make blowing shit open harder.
					if ((CrateExplosiveSmall(TAct) != None) && (FakeFRand() < TFactor))
					{
						TAct.Destroy();
					}
					else if (CrateUnbreakableSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							//At random: Remove various crates used for stacking out back.
							case 0:
							case 1:
							case 2:
							case 3:
							case 4:
							case 5:
							case 6:
							case 7:
							case 11:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
							//Solution 0: Disable solutions to laser route.
							case 9:
							case 21:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					//Solution 0: Disable solutions to laser route.
					else if (Button1(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 2:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					//Remove the chair you can use for easy stacking around the locked door.
					else if (Chair1(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 5:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "01_NYC_UNATCOHQ":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					//Remove the free key in jacobson's, but keep the other.
					if (Nanokey(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 2:
								if (RemoveSolutions[0] > 0)
								{
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 25;
									}
								}
							break;
						}
					}
				}
			break;
			//2222222222222222222222222222
			//MISSION 02
			case "02_NYC_BATTERYPARK":
				forEach AllActors(class'Actor', TAct)
				{
					//At random: Lock various vents going towards hostage situation.
					//Additionally, re-lock the keypad panel at docks.
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 6:
							case 12:
							case 14:
							case 16:
							case 23:
							case 24:
							case 29:
							case 37:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.2;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 20;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "02_NYC_SMUG":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Make stacking over smuggler's lasers harder.
				if (RemoveSolutions[0] > 0)
				{
					TAct = Spawn(class'BeamTrigger',, 'smugglerlaser', Vect(191, -120, 77), Rot(0, 32768, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'botordertrigger';
					}
					TAct = Spawn(class'BeamTrigger',, 'smugglerlaser', Vect(191, -120, 109), Rot(0, 32768, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'botordertrigger';
					}
				}
			break;
			case "02_NYC_STREET":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Disable osgood tunnels solutions (barrels, pipe).
				if (RemoveSolutions[0] > 0)
				{
					TAct = Spawn(class'LaserTrigger',, 'TunnelTrigs', Vect(255, 2576, -870), Rot(0, 32768, 0));
					if (TAct != None)
					{
						LaserTrigger(TAct).Event = 'TunnelTurret';
					}
					
					forEach AllActors(class'Actor', TAct)
					{
						if (Barrel1(TAct) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TAct))
							{
								case 2:
								case 4:
									Barrel1(TAct).bExplosive = false;
									Barrel1(TAct).HitPoints = 30;
									Barrel1(TAct).Skin = Texture'Barrel1Tex4';
									Barrel1(TAct).SkinColor = SC_Rusty;
									Barrel1(TAct).ResetScaleGlow();
								break;
							}
						}
					}
				}
			break;
			case "02_NYC_FREECLINIC":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Make the clinic doors unbreakable.
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 4:
							case 5:
								if (RemoveSolutions[0] > 0)
								{
									DeusExMover(TAct).bBreakable = false;
								}
							break;
						}
					}
				}
			break;
			case "02_NYC_UNDERGROUND":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Mover the lasers down so you can't duck under them.
				forEach AllActors(class'Actor', TAct)
				{
					if (LaserTrigger(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1:
							case 2:
							case 3:
								if (RemoveSolutions[0] > 0)
								{
									TAct.SetLocation(TAct.Location + Vect(0,0,-8));
									LaserTrigger(TAct).Emitter.SetLocation(LaserTrigger(TAct).Emitter.Location + Vect(0,0,-8));
								}
							break;
						}
					}
				}
			break;
			case "02_NYC_WAREHOUSE":
				//Make the mirror door need explosives/guns to break, instead of mere melee.
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 69:
								if ((FakeFRand() < TFactor) && (DeusExMover(TAct).MinDamageThreshold < 25))
								{
									DeusExMover(TAct).MinDamageThreshold = 25;
								}
							break;
						}
					}
				}
			break;
			//3333333333333333333333333333
			//MISSION 03
			case "03_NYC_BATTERYPARK":
				//Remove the free zyme, make us find some earlier.
				forEach AllActors(class'Actor', TAct)
				{
					if (VialCrack(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "03_NYC_BROOKLYNBRIDGESTATION":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Remove the metal crates that make stacking + grenade climbing super easy.
				forEach AllActors(class'Actor', TAct)
				{
					if (CrateUnbreakableSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0:
							case 1:
							case 4:
							case 6:
							case 8:
							case 9:
							case 11:
							case 13:
							case 16:
							case 17:
							case 18:
							case 25:
							case 26:
							case 28:
							case 29:
							case 34:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "03_NYC_AIRFIELDHELIBASE":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				RemoveSolutions[1] = int(FakeFRand() < TFactor);
				RemoveSolutions[2] = int(FakeFRand() < TFactor);
				
				//Solution 0: Lasers short enough to stack over, or maybe even speed aug over?
				if (RemoveSolutions[0] > 0)
				{
					TAct = Spawn(class'LaserTrigger',, '1stlaser', Vect(-9960, 3177, 103), Rot(0, 16384, 0));
					TAct = Spawn(class'LaserTrigger',, '1stlaser', Vect(-9960, 3177, 123), Rot(0, 16384, 0));
				}
				
				forEach AllActors(class'Actor', TAct)
				{
					//Solution 1: Can use crates to stack onto steam pipes rim, and run over stuff.
					if (CrateUnbreakableSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 2:
							case 3:
								if (RemoveSolutions[1] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (CrateUnbreakableMed(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 2:
								if (RemoveSolutions[1] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					//Remove crate that can blow up lasers effortlessly.
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 15:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							//Lock the vent that circumvents lasers/turrets.
							case 9:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 25;
									}
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.25;
									}
								}
							break;
							//Solution 2: Remove key to control room
							case 14:
								if (RemoveSolutions[2] > 0)
								{
									DeusExMover(TAct).KeyIDNeeded = '';
									
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 70;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 13:
							case 15:
								if (RemoveSolutions[2] > 0)
								{
									DeusExMover(TAct).KeyIDNeeded = '';
									
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 50;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							//Lock the sewer exit from the map.
							case 21:
								if ((FakeFRand() < TFactor) && (!DeusExMover(TAct).bLocked))
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.3;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 30;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					//Solution 2: Remove key to control room
					else if ((Nanokey(TAct) != None) && (Nanokey(TAct).KeyID == 'HeliSecurityRoom') && (Terrorist(TAct.Owner) != None))
					{
						if (RemoveSolutions[2] > 0)
						{
							TAct.Destroy();
						}
					}
				}
			break;
			//4444444444444444444444444444
			//MISSION 04
			case "04_NYC_NSFHQ":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				RemoveSolutions[1] = int(FakeFRand() < TFactor);
				RemoveSolutions[2] = int(FakeFRand() < TFactor);
				RemoveSolutions[3] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					//Solution 3: Remove key to under area
					if (Nanokey(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0:
								if (RemoveSolutions[3] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (TAct.Class == class'DeusExMover')
					{
						if ((DeusExMover(TAct).KeyIDNeeded == 'BasementDoor') && (RemoveSolutions[3] > 0))
						{
							DeusExMover(TAct).KeyIDNeeded = '';
						}
					}
					//Solution 0: Remove explosives from roof, as they can be used to blow open street-level door.
					//Solution 2: Remove explosives downstairs, as they can be used to bypass much of the maze.
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1:
							case 5:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
							case 12:
							case 13:
							case 14:
							case 15:
							case 16:
							case 17:
								if (RemoveSolutions[2] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					//Solution 1: Remove explosive barrels, once again related to street-level door.
					else if ((Barrel1(TAct) != None) && (Barrel1(TAct).bExplosive) && (RemoveSolutions[1] > 0))
					{
						Barrel1(TAct).bExplosive = false;
						Barrel1(TAct).HitPoints = 30;
						Barrel1(TAct).Skin = Texture'Barrel1Tex4';
						Barrel1(TAct).SkinColor = SC_Rusty;
						Barrel1(TAct).ResetScaleGlow();
					}
				}
			break;
			case "04_NYC_SMUG":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Add a couple beams to make stacking over smuggler's harder.
				if (RemoveSolutions[0] > 0)
				{
					TAct = Spawn(class'BeamTrigger',, 'smugglerlaser', Vect(191, -120, 77), Rot(0, 32768, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'botordertrigger';
					}
					TAct = Spawn(class'BeamTrigger',, 'smugglerlaser', Vect(191, -120, 109), Rot(0, 32768, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'botordertrigger';
					}
				}
			break;
			//6666666666666666666666666666
			//MISSION 06
			case "06_HONGKONG_HELIBASE":
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1: //Lock vent next to lockers. Too easy.
							case 5: //Lock vent to munitions bay.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.3;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 30;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "06_HONGKONG_WANCHAI_CANAL":
				//Remove the rebreathers crate that's so accessible.
				forEach AllActors(class'Actor', TAct)
				{
					if (CrateBreakableMedGeneral(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "06_HONGKONG_STORAGE":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				if (RemoveSolutions[0] > 0)
				{
					//Relocate electricity so it can't be swooced around.
					forEach AllActors(class'Actor', TAct)
					{
						if (ElectricityEmitter(TAct) != None)
						{
							ElectricityEmitter(TAct).RandomAngle *= 1.5;
							ElectricityEmitter(TAct).SetLocation(TAct.Location + Vect(0, 0, 0));
							
							switch(SF.Static.StripBaseActorSeed(TAct))
							{
								case 8:
								case 9:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, -16, 0) + Vect(0, -20, 0)) * (5000.0 / 320.0);
								break;
								case 24:
								case 25:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, -16, 0) + Vect(0, 0, 0)) * (5000.0 / 320.0);
								break;
								case 28:
								case 29:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, -16, 0) + Vect(0, 20, 0)) * (5000.0 / 320.0);
								break;
								
								case 10:
								case 11:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, -20, 0)) * (5000.0 / 320.0);
								break;
								case 26:
								case 27:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, 0, 0)) * (5000.0 / 320.0);
								break;
								case 30:
								case 31:
									ElectricityEmitter(TAct).VMDEndTraceOffset = (Vect(0, 20, 0)) * (5000.0 / 320.0);
								break;
							}
						}
					}
				}
			break;
			//9999999999999999999999999999
			//MISSION 09
			case "09_NYC_DOCKYARD":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					//Stop beam triggers being as simple as having shit pushed into them.
					if (BeamTrigger(TAct) != None)
					{
						if (RemoveSolutions[0] > 0)
						{
							BeamTrigger(TAct).TriggerType = TT_AnyProximity;
						}
					}
					//Also, lock the front gate vent sometimes.
					else if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 2:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.4;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 40;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "09_NYC_SHIPFAN":
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 6: //Solution 1: Lock big grate to the elevator area.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.5;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 50;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "09_NYC_SHIP":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				RemoveSolutions[1] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 5: //Solution 1: Lock vents to upper vents that bypasses most doors
							case 12:
								if (RemoveSolutions[1] > 0)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.25;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 25;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 13: //Lock vent to medbot and repairbot
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.45;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 45;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							//Solution 0: Remove wallbang TNT.
							case 0:
							case 1:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "09_NYC_SHIPBELOW":
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 19: //Lock vent to chopper room
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.35;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 35;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							//Reduce free TNT at random.
							case 5:
							case 6:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			
			//1010101010101010101010101010
			//MISSION 10
			case "10_PARIS_CATACOMBS":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (BreakableWall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0: //Reinforce wooden planks to catacombs
							case 1:
							case 2:
								if ((RemoveSolutions[0] > 0) && (DeusExMover(TAct).MinDamageThreshold < 25))
								{
									BreakableWall(TAct).MinDamageThreshold = 25;
								}
							break;
						}
					}
				}
			break;
			case "10_PARIS_CATACOMBS_TUNNELS":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				if (FakeFRand() < TFactor)
				{
					TAct = Spawn(class'Barrel1',,, Vect(-542, -840, -231), Rot(0, 0, 0));
					if (TAct != None)
					{
						Barrel1(TAct).SkinColor = SC_Radioactive;
						Barrel1(TAct).BeginPlay();
						Barrel1(TAct).SetCollisionSize(TAct.CollisionRadius, TAct.CollisionRadius);
						Barrel1(TAct).SetPhysics(PHYS_None);
						Barrel1(TAct).SetRotation(Rot(0, 0, 16384));
						Barrel1(TAct).SetLocation(Vect(-534, -942, -253));
						Barrel1(TAct).SetCollisionSize(TAct.Default.CollisionHeight, TAct.CollisionRadius);
						Barrel1(TAct).bSwappedCollision = true;
					}
				}
				
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0: //Reinforce wooden planks to catacombs
								if ((RemoveSolutions[0] > 0) && (DeusExMover(TAct).MinDamageThreshold < 25))
								{
									BreakableWall(TAct).MinDamageThreshold = 25;
								}
							break;
						}
					}
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							//Reduce free TNT at random.
							case 0:
							case 1:
							case 3:
							case 4:
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "10_PARIS_CHATEAU":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (BreakableWall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 5: //Solution 1: Reinforce wooden planks to catacombs
							case 6:
								if ((RemoveSolutions[0] > 0) && (DeusExMover(TAct).MinDamageThreshold < 25))
								{
									BreakableWall(TAct).MinDamageThreshold = 25;
								}
							break;
						}
					}
					else if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 5: //Lock vents going around planks as well sometimes.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.3;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 30;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			
			//1111111111111111111111111111
			//MISSION 11
			case "11_PARIS_CATHEDRAL":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				RemoveSolutions[1] = int(FakeFRand() < TFactor);
				
				//Block the trellis with a poison barrel. I wanted non-completely-static area of denial.
				//The pros of this are you can break it, but doing so will generate noise and spread the gas.
				if (FakeFRand() < TFactor)
				{
					TAct = Spawn(class'Barrel1',,, Vect(3444, 199, -403), Rot(0, 0, 0));
					if (TAct != None)
					{
						Barrel1(TAct).SkinColor = SC_Poison;
						Barrel1(TAct).BeginPlay();
						Barrel1(TAct).TakeDamage(1, None, TAct.Location, Vect(0,0,0), 'Shot');
					}
				}
				
				//Solution 1: Disable climbing over lasers
				if (RemoveSolutions[1] > 0)
				{
					TAct = Spawn(class'LaserTrigger',, 'gold_laser', Vect(3298, -2577, -546), Rot(0, 0, 0));
					if (TAct != None)
					{
						LaserTrigger(TAct).Event = '';
					}
					TAct = Spawn(class'LaserTrigger',, 'gold_laser', Vect(3298, -2577, -530), Rot(0, 0, 0));
					if (TAct != None)
					{
						LaserTrigger(TAct).Event = '';
					}
					TAct = Spawn(class'LaserTrigger',, 'gold_laser', Vect(3298, -2577, -514), Rot(0, 0, 0));
					if (TAct != None)
					{
						LaserTrigger(TAct).Event = '';
					}
				}
				
				forEach AllActors(class'Actor', TAct)
				{
					if (CrateUnbreakableSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0: //Solution 0: Metal crates stacking into apartment near start.
							case 1:
							case 2:
							case 3:
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (TAct.Class == class'Trashbag')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 3: //Also, remove 1 of the trashbags to make climbing still not solveable without leaving the gate.
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;

			//1212121212121212121212121212
			//MISSION 12
			case "12_VANDENBERG_CMD":
				//Sometimes lock the vent going towards the outside.
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 8:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.35;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 35;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "12_VANDENBERG_TUNNELS":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				//Solution 0: Disable parkour past lasers in hallway
				if (RemoveSolutions[0] > 0)
				{
					TAct = Spawn(class'BeamTrigger',, 'beam_bots', Vect(-2432, 2872, -2584), Rot(0, -20128, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'bot1';
					}
					TAct = Spawn(class'BeamTrigger',, 'beam_bots', Vect(-2433, 2524, -2584), Rot(0, 20080, 0));
					if (TAct != None)
					{
						BeamTrigger(TAct).Event = 'bot1';
					}
				}
				
				//Sometimes lock the vent going to the underwater section.
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.55;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 55;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			case "12_VANDENBERG_GAS":
				//Sometimes lock the vent going to the roof of gas station.
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 9:
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.45;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 45;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
			
			//1414141414141414141414141414
			//MISSION 14
			case "14_VANDENBERG_SUB":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 8: //Don't let us believe there's a key that we cannot acquire, duh.
								if (RemoveSolutions[0] > 0)
								{
									if (!DeusExMover(TAct).bPickable)
									{
										//Update: There's a duplicate of this in the shed. Just make this door pickable when this happens, as an additional solution.
										//Close a door, open 2 windows.
										//DeusExMover(TAct).KeyIDNeeded = '';
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.75;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 75;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 11: //Lock the hatch in corner of the room. Brutal.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.45;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 45;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					else if ((Nanokey(TAct) != None) && (MJ12Troop(Nanokey(TAct).Owner) != None) && (Nanokey(TAct).KeyID == 'Sub_base'))
					{
						if (RemoveSolutions[0] > 0)
						{
							TAct.Destroy();
						}
					}
					else if (Keypad(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 5: //Change "12" code to something else, as it's unnamed and too easy.
								if (FakeFRand() < TFactor)
								{
									Keypad(TAct).ValidCode = String(Rand(100)); //The code is guessable, like the original, though.
									if (Len(Keypad(TAct).ValidCode) < 2)
									{
										Keypad(TAct).ValidCode = "0"$Keypad(TAct).ValidCode;
									}
								}
							break;
						}
					}
				}
			break;
			case "14_OCEANLAB_LAB":
				forEach AllActors(class'Actor', TAct)
				{
					if (OfficeChair(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 1: //Remove chair that can shield against electricity.
								if (FakeFRand() < TFactor)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "14_OCEANLAB_SILO":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 14: //Lock the door going into the repair bot room. Gasp.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.65;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 65;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 26: //Lock the hatch to the secret slide.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.55;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 55;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					else if (Keypad(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 11: //Change "12" code to something else, as it's unnamed and too easy.
								if (FakeFRand() < TFactor)
								{
									Keypad(TAct).ValidCode = String(Rand(100)); //The code is guessable, like the original, though.
									if (Len(Keypad(TAct).ValidCode) < 2)
									{
										Keypad(TAct).ValidCode = "0"$Keypad(TAct).ValidCode;
									}
								}
							break;
						}
					}
				}
			break;
			
			//1515151515151515151515151515
			//MISSION 15
			case "15_AREA51_BUNKER":
				RemoveSolutions[0] = int(FakeFRand() < TFactor);
				RemoveSolutions[1] = int(FakeFRand() < TFactor);
				RemoveSolutions[2] = int(FakeFRand() < TFactor);
				
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 4: //Solution 0: Don't mislead player with the idea of a key.
								if (RemoveSolutions[0] > 0)
								{
									DeusExMover(TAct).KeyIDNeeded = '';
									
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 75;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 26: //Solution 1: Don't mislead player with the idea of a key.
								if (RemoveSolutions[1] > 0)
								{
									DeusExMover(TAct).KeyIDNeeded = '';
									
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 25;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 5: //Lock the hatch to fan area. Brutal.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.6;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 60;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
							case 8: //Lock the door to the elevator disarm. Stacking is likely still possible?
								if (RemoveSolutions[2] > 0)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.35;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 35;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
					else if (CrateExplosiveSmall(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0:
							case 1:
							case 2:
								if (RemoveSolutions[2] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
					else if (Nanokey(TAct) != None)
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 0: //Solution 0: Remove tower key
								if (RemoveSolutions[0] > 0)
								{
									TAct.Destroy();
								}
							break;
							case 1: //Solution 1: Remove storage key
								if (RemoveSolutions[1] > 0)
								{
									TAct.Destroy();
								}
							break;
						}
					}
				}
			break;
			case "15_AREA51_FINAL":
				forEach AllActors(class'Actor', TAct)
				{
					if (TAct.Class == class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(TAct))
						{
							case 13: //Lock this, but still allow forklift up.
								if (FakeFRand() < TFactor)
								{
									if (!DeusExMover(TAct).bLocked)
									{
										DeusExMover(TAct).bLocked = true;
										DeusExMover(TAct).bPickable = true;
										DeusExMover(TAct).LockStrength = 0.45;
									}
									if (!DeusExMover(TAct).bBreakable)
									{
										DeusExMover(TAct).bBreakable = true;
										DeusExMover(TAct).MinDamageThreshold = 45;
										SetMoverFragmentType(DeusExMover(TAct), "Metal");
									}
								}
							break;
						}
					}
				}
			break;
		}
	}
}

function string VMDGetMapName()
{
 	return class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
}

function int VMDGetMissionNumber()
{
	local DeusExLevelInfo DXLI;
	
 	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
	
	if (DXLI != None)
	{
		return DXLI.MissionNumber;
	}
	return 1;
}

defaultproperties
{
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
