//=============================================================================
// VMDSkinUpdater.
// Hi. WCCC here. Another note about this one: This actor exists purely to
// add diversity to the appearance of various NPCs throughout the game...
// And I mean that in the purest sense... The sense of not wanting to see the
// exact same NPCs standing shoulder to shoulder in some areas. Mix it up a bit.
// Shoutouts to my main Bogie for coming up with the set of changes.
//=============================================================================
class VMDSkinUpdater extends VMDFillerActors;

var float UpdateTimer;
var bool bRanUpdate;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var bool bRevisionMapSet;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (!bRanUpdate)
	{
 		if (UpdateTimer < 0.01)
		{
			UpdateTimer += DT;
		}
		else if (UpdateTimer > -10)
 		{
 	 		UpdateTimer = -30;
			CommitSkinUpdates();
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

function SyncSkins(Pawn TPawn)
{
	local int i;
	local VMDBufferPawn VMBP;
	
	VMBP = VMDBufferPawn(TPawn);
	if (VMBP != None)
	{
		for(i=0; i<ArrayCount(TPawn.Multiskins); i++)
		{
			if (TPawn.Multiskins[i] != TPawn.Default.Multiskins[i])
			{
				switch(TPawn.Multiskins[i].Name)
				{
					//MADDERS, 10/20/24: Hack. Don't perma assign ballistic armor and such.
					//Ballistic
					case 'VMDTerroristTex1BallisticArmor':
					case 'VMDHKMilitaryTex1BallisticArmor':
					case 'VMDSoldierTex1BallisticArmor':
					case 'VMDMJ12TroopTex2BallisticArmor':
					case 'VMDRiotCopTex2BallisticArmor':
					case 'VMDUNATCOTroopTex2BallisticArmor':
					//Bounty hunters
					case 'VMDNSFBountyHunter2Shirt01Armor':
					case 'VMDNSFBountyHunter2Shirt02Armor':
					case 'VMDNSFBountyHunter2Shirt03Armor':
					case 'VMDNSFBountyHunter2Shirt04Armor':
					case 'VMDNSFBountyHunter2Shirt05Armor':
					//Goggles
					case 'VMDTechGogglesTex1':
					case 'VMDMJ12TroopTex4TechGoggles':
					case 'VMDRiotCopTex3TechGoggles':
					case 'VMDSoldierTex3TechGoggles':
					case 'VMDUNATCOTroopTex3TechGoggles':
					//Cloaking texture. Ugly.
					case 'WhiteStatic':
					break;
					default:
						VMBP.StoredMultiskins[i] = TPawn.Multiskins[i];
					break;
				}
			}
		}
	}
}

//MADDERS: The big one.
function CommitSkinUpdates()
{
	//Parent class junk.
	local Actor A;
	local DeusExCarcass DXC;
 	local DeusExLevelInfo LI;
	local Pawn TPawn;
	local ScriptedPawn SP;
	local VMDBufferPlayer VMP;
	
	local int GM, i, TCounters[32];
	local string MN;
	local Rotator TRot;
	local Texture FilTex[8];
	
	local class<ScriptedPawn> SPLoad;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	if (VMP == None || !VMP.bUpdateVanillaSkins)
	{
		bRanUpdate = true;
		return;
	}
	
 	forEach AllActors(Class'DeusExLevelInfo', LI) break;
	GM = LI.MissionNumber;
	if (GM > 98)
	{
		Lifespan = 1;
		return;
	}
	MN = VMDGetMapName();
	
	switch(GM)
	{
		case 0:
			switch(MN)
			{
				case "00_TRAINING":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Doctor(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 1:
										FilTex[0] = Texture'SkinTex7';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex11';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "00_TRAININGCOMBAT":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'MiscTex13';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex10';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex9';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 4:
										FilTex[0] = Texture'MiscTex13';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "00_TRAININGFINAL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
						}
					}
				break;
			}
		break;
		case 1:
			switch(MN)
			{
				case "01_NYC_UNATCOISLAND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(TPawn))
								{
									case 0:
									case 12:
									case 27:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 1:
									case 10:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
								}
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ThugMale2(TPawn) != None)
							{
								FilTex[0] = None;
								switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(TPawn))
								{
									case 5:
										FilTex[0] = Texture'ThugMale2Tex4';
									break;
									case 9:
										FilTex[0] = Texture'ThugMale2Tex6';
									break;
								}
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "TechSergeantKaplan":
										FilTex[0] = Texture'MikeKaplanTex0';
									break;
									case "CorporalCollins":
										FilTex[0] = Texture'PhilCollinsTex0';
									break;
									case "PrivateLLoyd":
										FilTex[0] = Texture'KyleLloydTex0';
									break;
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MiscTex3';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "01_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								if (UNATCOTroop(TPawn).BindName == "MichaelBerry")
								{
									FilTex[0] = Texture'MichaelBerryTex1';
								}
								else if (UNATCOTroop(TPawn).BindName == "Scott")
								{
									FilTex[0] = Texture'ScottBordinTex1';
								}
								else
								{
									switch(TCounters[0])
									{
										case 0:
											FilTex[0] = Texture'MiscTex14';
										break;
										case 1:
											FilTex[0] = Texture'MiscTex12';
										break;
										case 2:
											FilTex[0] = Texture'MiscTex11';
										break;
										case 3:
											FilTex[0] = Texture'MiscTex9';
										break;
										case 4:
											FilTex[0] = Texture'MiscTex13';
										break;
									}
									TCounters[0] += 1;
									
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 2:
			switch(MN)
			{
				case "02_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										TPawn.MultiSkins[6] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.Multiskins[2] = Texture'PantsTex7';
										VMDBufferPawn(TPawn).StoredMultiskins[2] = TPawn.Multiskins[2];
									break;
									case 1:
										TPawn.Multiskins[1] = Texture'BumMale2Tex2';
										TPawn.Multiskins[4] = Texture'TrenchShirtTex2';
										TPawn.Multiskins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.Multiskins[2] = Texture'PantsTex3';
										TPawn.Multiskins[4] = Texture'TrenchShirtTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (ChildMale(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'ChildMale2Tex0';
										TPawn.MultiSkins[1] = Texture'Male3Tex1';
										TPawn.MultiSkins[3] = Texture'PinkMaskTex';
										TPawn.MultiSkins[4] = Texture'ChildMale2Tex0';
										TPawn.MultiSkins[5] = Texture'Male3Tex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 1:
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
							else if (JunkieMale(TPawn) != None)
							{
								switch(TCounters[5])
								{
									case 1:
										TPawn.MultiSkins[3] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[5] += 1;
							}
							else if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[6])
								{
									case 0:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 2:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 6:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 7:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 8:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 9:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 11:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 12:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 14:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
								}
								TCounters[6] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[7])
								{
									case 0:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex7';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex5';
									break;
								}
								TCounters[7] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "02_NYC_BAR":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Male1(TPawn) != None)
							{
								TPawn.Multiskins[3] = Texture'PantsTex6';
								TPawn.Multiskins[6] = Texture'FramesTex1';
								TPawn.Multiskins[7] = Texture'LensesTex2';
								SyncSkins(TPawn);
							}
							else if (Female2(TPawn) != None)
							{
								TPawn.Multiskins[0] = Texture'NurseTex0';
								TPawn.Multiskins[1] = Texture'NurseTex0';
								TPawn.Multiskins[2] = Texture'NurseTex0';
								TPawn.Multiskins[6] = Texture'GrayMaskTex';
								TPawn.Multiskins[7] = Texture'BlackMaskTex';
								SyncSkins(TPawn);
							}
						}
					}
				break;
				case "02_NYC_FREECLINIC":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'BumFemaleTex0';
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale3Tex0';
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[2] = Texture'PantsTex7';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale2(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PantsTex2';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'BumMale5Tex0';
										TPawn.MultiSkins[1] = Texture'BumMaleTex2';
										TPawn.MultiSkins[5] = Texture'BumMaleTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'BumMale4Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										SyncSkins(TPawn);
									break;
									case 2:
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (Doctor(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 1:
										TPawn.MultiSkins[0] = Texture'SkinTex28';
										TPawn.MultiSkins[3] = Texture'SkinTex3';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
							else if (Female2(TPawn) != None)
							{
								switch(TCounters[5])
								{
									case 0:
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[5] += 1;
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TCounters[6])
								{
									case 1:
										TPawn.MultiSkins[0] = Texture'JunkieFemale2Tex0';
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[6] += 1;
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TCounters[7])
								{
									case 1:
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[7] += 1;
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TCounters[8])
								{
									case 1:
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[8] += 1;
							}
						}
					}
				break;
				case "02_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 1:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 2:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "02_NYC_STREET":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										TPawn.MultiSkins[6] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 1:
										TPawn.MultiSkins[1] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[5] = Texture'BumMale3Tex2';
										SyncSkins(TPawn);
									break;
									case 2:
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale2(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 1:
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[4] = Texture'FordSchickTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale4Tex0';
										TPawn.MultiSkins[3] = Texture'BumMale4Tex0';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'BumMale9Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex4';
										TPawn.MultiSkins[3] = Texture'BumMale9Tex0';
										SyncSkins(TPawn);
									break;
									case 2:
										TPawn.MultiSkins[0] = Texture'BumMale2Tex0';
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[3] = Texture'BumMale2Tex0';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[4])
								{
									case 0:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 7:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
								}
								TCounters[4] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ThugMale2(TPawn) != None)
							{
								switch(TCounters[5])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex6';
										SyncSkins(TPawn);
									break;
								}
								TCounters[5] += 1;
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[6])
								{
									case 0:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex4';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex6';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 6:
										FilTex[0] = Texture'MiscTex7';
									break;
								}
								TCounters[6] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "02_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex21';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex3';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex25';
									break;
									case 4:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex4';
									break;
									case 7:
										FilTex[0] = Texture'TobyAtanweTex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "02_NYC_WAREHOUSE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 3:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 9:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 12:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 15:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 16:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 18:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
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
				case "03_NYC_AIRFIELD":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 7:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 10:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 1:
										FilTex[0] = Texture'MiscTex6';
									break;
									case 4:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 5:
										FilTex[0] = Texture'MiscTex5';
									break;
									case 6:
										FilTex[0] = Texture'MiscTex7';
									break;
									case 7:
										FilTex[0] = Texture'MiscTex4';
									break;
									case 8:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 9:
										FilTex[0] = Texture'MiscTex8';
									break;
									case 11:
										FilTex[0] = Texture'MiscTex2';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_AIRFIELDHELIBASE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 8:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 9:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 10:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 12:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 1:
										FilTex[0] = Texture'MiscTex3';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex12';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 5:
										FilTex[0] = Texture'MiscTex11';
									break;
									case 6:
										FilTex[0] = Texture'MiscTex13';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 1:
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
									case 2:
										TPawn.MultiSkins[1] = Texture'BumFemaleTex0';
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										TPawn.MultiSkins[6] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale9Tex0';
										TPawn.MultiSkins[1] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[3] = Texture'BumMale9Tex0';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										TPawn.MultiSkins[5] = Texture'BumMale3Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PantsTex4';
										TPawn.MultiSkins[4] = Texture'FordSchickTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (ChildMale(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[2] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (RiotCop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[4])
								{
									case 0:
										FilTex[0] = Texture'BartenderTex0';
										SyncSkins(TPawn);
									break;
									case 2:
										FilTex[0] = Texture'MorganEverettTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_BROOKLYNBRIDGESTATION":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "CharlieFann":
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (BumMale2(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[2] = Texture'JunkieMaleTex2';
										TPawn.MultiSkins[3] = Texture'BumMale4Tex0';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex1';
										TPawn.MultiSkins[5] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[6] = Texture'FramesTex1';
										TPawn.MultiSkins[7] = Texture'LensesTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "JunkieFemale":
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[6] = Texture'JunkieMaleTex2';
										SyncSkins(TPawn);
									break;
									case "GangMemberFemale":
										TPawn.MultiSkins[0] = Texture'JunkieFemale2Tex0';
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
									case "ThugWoman3":
										switch(TCounters[1])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'JunkieFemale2Tex0';
												TPawn.MultiSkins[1] = Texture'JunkieFemale2Tex0';
												TPawn.MultiSkins[6] = Texture'PantsTex4';
												SyncSkins(TPawn);
											break;
											case 1:
												TPawn.MultiSkins[1] = Texture'PinkMaskTex';
												TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
												SyncSkins(TPawn);
											break;
										}
										
										TCounters[1] += 1;
									break;
								}
							}
							else if (JunkieMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Don":
										TPawn.MultiSkins[0] = Texture'JunkieMale2Tex0';
										TPawn.MultiSkins[4] = Texture'JunkieMale2Tex0';
										SyncSkins(TPawn);
									break;
									case "Lenny":
										TPawn.MultiSkins[0] = Texture'JunkieMale3Tex0';
										TPawn.MultiSkins[3] = Texture'PantsTex3';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (ThugMale2(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'ThugMale3Tex0';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex6';
										SyncSkins(TPawn);
									break;
									case 3:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex4';
										SyncSkins(TPawn);
									break;
									case 4:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex3';
										TPawn.MultiSkins[4] = Texture'ThugMale2Tex3';
										SyncSkins(TPawn);
									break;
									case 5:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex4';
										TPawn.MultiSkins[4] = Texture'ThugMale2Tex4';
										SyncSkins(TPawn);
									break;
									case 6:
										TPawn.MultiSkins[0] = Texture'ThugMale3Tex0';
										SyncSkins(TPawn);
									break;
									case 7:
										TPawn.MultiSkins[0] = Texture'ThugMale2Tex5';
										TPawn.MultiSkins[4] = Texture'ThugMale2Tex5';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
						}
					}
				break;
				case "03_NYC_HANGAR":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'MiscTex12';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex13';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex8';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 4:
										FilTex[0] = Texture'MiscTex9';
									break;
									case 5:
										FilTex[0] = Texture'MiscTex14';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_MOLEPEOPLE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'BumFemaleTex0';
										TPawn.MultiSkins[2] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale5Tex0';
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "KevinBradley":
										TPawn.MultiSkins[1] = Texture'BumMaleTex2';
										TPawn.MultiSkins[2] = Texture'JunkieMaleTex2';
										TPawn.MultiSkins[5] = Texture'BumMaleTex2';
										SyncSkins(TPawn);
									break;
									case "MolePerson":
										TPawn.MultiSkins[0] = Texture'BumMale4Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex7';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (ChildMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Jimmy":
										TPawn.MultiSkins[0] = Texture'ChildMale2Tex0';
										TPawn.MultiSkins[1] = Texture'ChildMale2Tex1';
										TPawn.MultiSkins[2] = Texture'PantsTex6';
										TPawn.MultiSkins[3] = Texture'PinkMaskTex';
										TPawn.MultiSkins[5] = Texture'PinkMaskTex';
										TPawn.MultiSkins[6] = Texture'FramesTex1';
										TPawn.MultiSkins[7] = Texture'LensesTex2';
										SyncSkins(TPawn);
									break;
									case "MoleKid":
										TPawn.MultiSkins[2] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (JunkieMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "TechBum":
										TPawn.MultiSkins[3] = Texture'PantsTex4';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 0:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
									case 7:
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
									case 9:
										FilTex[0] = Texture'Terrorist2Tex0';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 1:
										FilTex[0] = Texture'Terrorist3Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "CorporalCollins":
										FilTex[1] = Texture'PhilCollinsTex2';
										SyncSkins(TPawn);
									break;
									case "InjuredTrooper1":
										FilTex[1] = Texture'SkinTex3';
										SyncSkins(TPawn);
									break;
									case "InjuredTrooper2":
										FilTex[1] = Texture'Male1Tex0';
										SyncSkins(TPawn);
									break;
									case "MichaelBerry":
										FilTex[1] = Texture'MichaelBerryTex2';
										SyncSkins(TPawn);
									break;
									case "PrisonGuard1":
										FilTex[0] = Texture'MiscTex11';
									break;
									case "PrisonGuard2":
										FilTex[0] = Texture'MiscTex9';
									break;
									case "Scott":
										FilTex[1] = Texture'ScottBordinTex2';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[1])
										{
											case 0:
												FilTex[1] = Texture'Male1Tex0';
											break;
											case 1:
												FilTex[1] = Texture'SkinTex4';
											break;
											case 2:
												FilTex[1] = Texture'SkinTex55';
											break;
										}
										TCounters[1] += 1;
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "03_NYC_UNATCOISLAND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "PrivateLloyd":
										FilTex[1] = Texture'KyleLloydTex2';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MiscTex5';
											break;
											case 2:
												FilTex[0] = Texture'MiscTex6';
											break;
											case 3:
												FilTex[0] = Texture'MiscTex2';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 4:
			switch(MN)
			{
				case "04_NYC_BAR":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
						}
					}
				break;
				case "04_NYC_BATTERYPARK":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'MiscTex7';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex2';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex5';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "04_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'MiscTex10';
									break;
									case 1:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 2:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 3:
										FilTex[0] = Texture'MiscTex12';
									break;
									case 4:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 5:
										FilTex[0] = Texture'MiscTex9';
									break;
									case 6:
										FilTex[0] = Texture'MiscTex11';
									break;
									case 7:
										FilTex[0] = Texture'MiscTex8';
									break;
									case 8:
										FilTex[0] = Texture'MiscTex12';
									break;
									case 9:
										FilTex[0] = Texture'MiscTex13';
									break;
									case 10:
										FilTex[0] = Texture'MiscTex10';
									break;
									case 11:
										FilTex[0] = Texture'MiscTex14';
									break;
									case 12:
										FilTex[0] = Texture'MiscTex9';
									break;
									case 13:
										FilTex[0] = Texture'MiscTex13';
									break;
									case 14:
										FilTex[0] = Texture'MiscTex8';
									break;
									case 15:
										FilTex[0] = Texture'MiscTex12';
									break;
									case 16:
										FilTex[0] = Texture'MiscTex14';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "04_NYC_NSFHQ":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "TrooperTalking1":
										FilTex[0] = Texture'MiscTex13';
									break;
									case "TrooperTalking2":
										FilTex[0] = Texture'MiscTex14';
									break;
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MiscTex14';
											break;
											case 1:
												FilTex[0] = Texture'MiscTex14';
											break;
											case 2:
												FilTex[0] = Texture'MiscTex13';
											break;
											case 3:
												FilTex[0] = Texture'MiscTex9';
											break;
											case 4:
												FilTex[0] = Texture'MiscTex12';
											break;
											case 5:
												FilTex[0] = Texture'MiscTex11';
											break;
											case 6:
												FilTex[0] = Texture'MiscTex10';
											break;
											case 7:
												FilTex[0] = Texture'MiscTex8';
											break;
											case 8:
												FilTex[0] = Texture'MiscTex14';
											break;
											case 9:
												FilTex[0] = Texture'MiscTex13';
											break;
											case 10:
												FilTex[0] = Texture'MiscTex3';
											break;
											case 12:
												FilTex[0] = Texture'MiscTex5';
											break;
											case 16:
												FilTex[0] = Texture'MiscTex2';
											break;
										}
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "04_NYC_STREET":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "StreetBumOld":
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										SyncSkins(TPawn);
									break;
								}
							}
							if (BumMale3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "StreetBum":
										TPawn.MultiSkins[0] = Texture'BumMale2Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex4';
										TPawn.MultiSkins[3] = Texture'BumMale2Tex0';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "SickWoman":
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
										TPawn.MultiSkins[6] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (JunkieMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "SickMan":
										TPawn.MultiSkins[0] = Texture'JunkieMale3Tex0';
										TPawn.MultiSkins[3] = Texture'PantsTex4';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "UNATCOGateGuard":
									break;
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MiscTex3';
											break;
											case 6:
												FilTex[0] = Texture'MiscTex2';
											break;
											case 7:
												FilTex[0] = Texture'MiscTex5';
											break;
											case 8:
												FilTex[0] = Texture'MiscTex4';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "04_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "MichaelBerry":
										FilTex[1] = Texture'MichaelBerryTex2';
									break;
									case "CorporalCollins":
										FilTex[1] = Texture'PhilCollinsTex2';
									break;
									case "LoveTroop":
										FilTex[2] = Texture'SkinTex4';
									break;
									case "Scott":
										FilTex[1] = Texture'ScottBordinTex2';
									break;
									case "PrisonGuard":
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MiscTex9';
											break;
											case 1:
												FilTex[0] = Texture'MiscTex11';
											break;
										}
										TCounters[0] += 1;
									break;
									default:
										switch(TCounters[1])
										{
											case 0:
												FilTex[1] = Texture'SkinTex3';
											break;
											case 1:
												FilTex[1] = Texture'SkinTex26';
											break;
											case 2:
												FilTex[1] = Texture'SkinTex20';
											break;
											case 3:
												FilTex[1] = Texture'SkinTex2';
											break;
										}
										TCounters[1] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "04_NYC_UNATCOISLAND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "PrivateLloyd":
										FilTex[1] = Texture'KyleLloydTex2';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 5:
			switch(MN)
			{
				case "05_NYC_UNATCOHQ":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(TPawn))
								{
									case 0:
										FilTex[0] = Texture'PhilCollinsTex1';
									break;
									case 4:
										FilTex[0] = Texture'ScottBordinTex1';
									break;
									default:
										switch(TCounters[0])
										{
											//case 0:
											//	FilTex[0] = Texture'PhilCollinsTex1';
											//break;
											case 0:
												FilTex[0] = Texture'MiscTex10';
											break;
											case 1:
												FilTex[0] = Texture'MiscTex14';
											break;
											//case 3:
											//	FilTex[0] = Texture'ScottBordinTex1';
											//break;
											case 2:
												FilTex[0] = Texture'MiscTex11';
											break;
											case 3:
												FilTex[0] = Texture'MiscTex13';
											break;
											case 4:
												FilTex[0] = Texture'MiscTex9';
											break;
											case 5:
												FilTex[0] = Texture'MiscTex9';
											break;
											case 6:
												FilTex[0] = Texture'MiscTex12';
											break;
											case 7:
												FilTex[0] = Texture'MiscTex9';
											break;
											case 8:
												FilTex[0] = Texture'MiscTex14';
											break;
											case 9:
												FilTex[0] = Texture'MiscTex14';
											break;
											case 10:
												FilTex[0] = Texture'MiscTex11';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "05_NYC_UNATCOISLAND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (UNATCOTroop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "PrivateLloyd":
										FilTex[0] = Texture'KyleLloydTex0';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "05_NYC_UNATCOMJ12LAB":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Doctor(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												TPawn.MultiSkins[4] = Texture'TrenchShirtTex3';
												TPawn.MultiSkins[6] = Texture'GrayMaskTex';
												TPawn.MultiSkins[7] = Texture'BlackMaskTex';
												SyncSkins(TPawn);
											break;
											case 1:
												TPawn.MultiSkins[0] = Texture'SkinTex7';
												SyncSkins(TPawn);
											break;
										}
										TCounters[0] += 1;
									break;
								}
							}
							else if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								FilTex[2] = None;
								switch(TPawn.BindName)
								{
									case "Sven":
										FilTex[2] = Texture'SkinTex3';
									break;
									default:
										switch(TCounters[1])
										{
											case 0:
												FilTex[2] = Texture'Male1Tex0';
											break;
										}
										TCounters[1] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
								else if (FilTex[2] != None)
								{
									TPawn.Multiskins[0] = FilTex[2];
									TPawn.Multiskins[3] = FilTex[2];
									TPawn.Multiskins[4] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "chattingmj12":
										FilTex[0] = Texture'SkinTex4';
									break;
									default:
										switch(TCounters[2])
										{
											case 2:
												FilTex[0] = Texture'SkinTex4';
											break;
											case 3:
												FilTex[0] = Texture'MichaelBerryTex2';
											break;
											case 5:
												FilTex[0] = Texture'BartenderTex0';
											break;
											case 7:
												FilTex[0] = Texture'SkinTex3';
											break;
											case 11:
												FilTex[0] = Texture'TobyAtanweTex0';
											break;
											case 14:
												FilTex[0] = Texture'SkinTex26';
											break;
											case 15:
												FilTex[0] = Texture'BartenderTex0';
											break;
											case 16:
												FilTex[0] = Texture'SkinTex3';
											break;
										}
										TCounters[2] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Nurse(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[3])
										{
											case 0:
												TPawn.MultiSkins[6] = Texture'FramesTex1';
												TPawn.MultiSkins[7] = Texture'LensesTex1';
												SyncSkins(TPawn);
											break;
										}
										TCounters[3] += 1;
									break;
								}
							}
							else if (ScientistFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ScientistFemaleConsulting":
									break;
									default:
										switch(TCounters[4])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'SecretaryTex0';
												SyncSkins(TPawn);
											break;
										}
										TCounters[4] += 1;
									break;
								}
							}
							else if (ScientistMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "DoctorMoreau":
									break;
									case "ScientistConsulting":
										TPawn.MultiSkins[0] = Texture'SkinTex23';
										TPawn.MultiSkins[1] = Texture'LabCoatTex1';
										TPawn.MultiSkins[2] = Texture'PantsTex1';
										TPawn.MultiSkins[3] = Texture'SkinTex23';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex3';
										TPawn.MultiSkins[5] = Texture'LabCoatTex1';
										TPawn.MultiSkins[6] = Texture'FramesTex1';
										TPawn.MultiSkins[7] = Texture'LensesTex2';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[5])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'SkinTex4';
												TPawn.MultiSkins[6] = Texture'GrayMaskTex';
												TPawn.MultiSkins[7] = Texture'BlackMaskTex';
												SyncSkins(TPawn);
											break;
										}
										TCounters[5] += 1;
									break;
								}
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[6])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'Female1Tex0';
												TPawn.MultiSkins[1] = Texture'Female1Tex0';
												TPawn.MultiSkins[2] = Texture'Female1Tex0';
												SyncSkins(TPawn);
											break;
										}
										TCounters[6] += 1;
									break;
								}
							}
							else if (Terrorist(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "Miguel":
										FilTex[0] = Texture'Terrorist4Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 6:
			switch(MN)
			{
				case "06_HONGKONG_MJ12LAB":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC, 'BoatPersonCarcass')
						{
							DXC.MultiSkins[3] = Texture'PantsTex7';
						}
						
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumMale3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Labrat_Bum":
										TPawn.MultiSkins[0] = Texture'BumMale5Tex0';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Doctor(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MJ12Lab_Doctor":
										TPawn.MultiSkins[0] = Texture'SkinTex27';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'MorganEverettTex0';
											break;
											case 6:
												FilTex[0] = Texture'SkinTex22';
											break;
											case 7:
												FilTex[0] = Texture'BartenderTex0';
											break;
											case 8:
												FilTex[1] = TPawn.Multiskins[0]; //Hack for no helmet
											break;
											case 9:
												FilTex[0] = Texture'SkinTex4';
											break;
											case 13:
												FilTex[0] = Texture'SkinTex3';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
								else if (FilTex[1] != None)
								{
									TPawn.Multiskins[0] = FilTex[1];
									TPawn.Multiskins[3] = FilTex[1];
									TPawn.Multiskins[5] = Texture'GrayMaskTex';
									TPawn.Multiskins[6] = Texture'PinkMaskTex';
									SyncSkins(TPawn);
								}
							}
							else if (ScientistFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MJ12Lab_Psionics":
									break;
									case "MJ12Lab_Genetics":
									break;
									case "MJ12Lab_Computer":
									break;
									case "MJ12Lab_Bioweapons":
									break;
								}
							}
							else if (ScientistMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MJ12Lab_Physics":
										TPawn.MultiSkins[0] = Texture'DoctorTex0';
										TPawn.MultiSkins[3] = Texture'DoctorTex0';
										SyncSkins(TPawn);
									break;
									case "MJ12Lab_Biotech":
									break;
									case "MJ12Lab_Nanotech":
										TPawn.MultiSkins[0] = Texture'SkinTex3';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[1])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'Female2Tex0';
												TPawn.MultiSkins[1] = Texture'Female2Tex0';
												TPawn.MultiSkins[2] = Texture'Female2Tex0';
												SyncSkins(TPawn);
											break;
											case 2:
												TPawn.MultiSkins[0] = Texture'Female1Tex0';
												TPawn.MultiSkins[1] = Texture'Female1Tex0';
												TPawn.MultiSkins[2] = Texture'Female1Tex0';
												SyncSkins(TPawn);
											break;
										}
										TCounters[1] += 1;
									break;
								}
							}
						}
					}
				break;
				case "06_HONGKONG_HELIBASE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'SkinTex3';
											break;
											case 1:
												FilTex[0] = Texture'SkinTex28';
											break;
											case 4:
												FilTex[0] = Texture'SkinTex3';
											break;
											case 5:
												FilTex[0] = Texture'BartenderTex0';
											break;
											case 7:
												FilTex[0] = Texture'SkinTex4';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "06_HONGKONG_STORAGE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (ScientistFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Storage_ComputerTech":
										TPawn.MultiSkins[0] = Texture'Female1Tex0';
										TPawn.MultiSkins[3] = Texture'Female1Tex0';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
							}
						}
					}
				break;
				case "06_HONGKONG_TONGBASE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (TriadLumPath(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'TriadLumPath4Tex0';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex9';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex37';
									break;
									case 3:
										FilTex[0] = Texture'TriadLumPath4Tex0';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex14';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
								if (FilTex[1] != None)
								{
									TPawn.Multiskins[7] = FilTex[1];
									SyncSkins(TPawn);
								}
							}
							else if (TriadRedArrow(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'TriadRedArrow2Tex0';
									break;
									case 1:
										FilTex[0] = Texture'TriadRedArrow8Tex0';
									break;
									case 2:
										FilTex[0] = Texture'TriadRedArrow7Tex0';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "06_HONGKONG_VERSALIFE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Cop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 1:
										FilTex[0] = Texture'Cop2Tex0';
									break;
									case 2:
										FilTex[0] = Texture'Cop4Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Cop5Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Cop3Tex0';
									break;
									case 6:
										FilTex[0] = Texture'Cop6Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Male1(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Disgruntled_Guy":
									break;
									case "DataEntry_Break":
										TPawn.MultiSkins[0] = Texture'SkinTex16';
										TPawn.MultiSkins[4] = Texture'SkinTex16';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[1])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'MichaelBerryTex2';
												TPawn.MultiSkins[4] = Texture'MichaelBerryTex2';
												SyncSkins(TPawn);
											break;
											case 1:
												TPawn.MultiSkins[0] = Texture'SkinTex26';
												TPawn.MultiSkins[4] = Texture'SkinTex26';
												SyncSkins(TPawn);
											break;
											case 2:
												TPawn.MultiSkins[0] = Texture'BartenderTex0';
												TPawn.MultiSkins[4] = Texture'SkinTex4';
												TPawn.MultiSkins[6] = Texture'FramesTex1';
												TPawn.MultiSkins[7] = Texture'LensesTex2';
												SyncSkins(TPawn);
											break;
										}
										TCounters[1] += 1;
									break;
								}
							}
							else if (Male2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "DataEntry_Wander":
										TPawn.MultiSkins[0] = Texture'SkinTex6';
										TPawn.MultiSkins[3] = Texture'PantsTex1';
										TPawn.MultiSkins[5] = Texture'Male1Tex1';
										TPawn.MultiSkins[6] = Texture'FramesTex1';
										TPawn.MultiSkins[7] = Texture'LensesTex1';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[2])
										{
											case 0:
												TPawn.MultiSkins[0] = Texture'Male1Tex0';
												TPawn.MultiSkins[3] = Texture'PantsTex1';
												TPawn.MultiSkins[5] = Texture'Male1Tex1';
												TPawn.MultiSkins[6] = Texture'GrayMaskTex';
												TPawn.MultiSkins[7] = Texture'BlackMaskTex';
												SyncSkins(TPawn);
											break;
										}
										TCounters[2] += 1;
									break;
								}
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Receptionist":
										TPawn.MultiSkins[0] = Texture'NurseTex0';
										TPawn.MultiSkins[1] = Texture'NurseTex0';
										TPawn.MultiSkins[2] = Texture'NurseTex0';
										SyncSkins(TPawn);
									break;
									default:
										switch(TCounters[3])
										{
											case 0:
												TPawn.MultiSkins[1] = Texture'PinkMaskTex';
												TPawn.MultiSkins[6] = Texture'GrayMaskTex';
												TPawn.MultiSkins[7] = Texture'BlackMaskTex';
												SyncSkins(TPawn);
											break;
											case 1:
												TPawn.MultiSkins[0] = Texture'RachelMeadTex0';
												TPawn.MultiSkins[1] = Texture'RachelMeadTex0';
												TPawn.MultiSkins[2] = Texture'RachelMeadTex0';
												SyncSkins(TPawn);
											break;
										}
										TCounters[3] += 1;
									break;
								}
							}
						}
					}
				break;
				case "06_HONGKONG_WANCHAI_CANAL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BoatPerson(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Canal_Drunk":
										TPawn.Multiskins[3] = Texture'PantsTex6';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'TriadLumPathTex0';
											break;
											case 1:
												FilTex[0] = Texture'SkinTex36';
											break;
											case 2:
												FilTex[0] = Texture'SkinTex18';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (SarahMead(TPawn) != None)
							{
								TPawn.MultiSkins[0] = Texture'SkinTex33';
								TPawn.MultiSkins[5] = Texture'SkinTex33';
								TPawn.MultiSkins[6] = Texture'PinkMaskTex';
								TPawn.MultiSkins[7] = Texture'SkinTex33';
								SyncSkins(TPawn);
							}
						}
					}
				break;
				case "06_HONGKONG_WANCHAI_GARAGE":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex34';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex37';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex13';
									break;
									case 3:
										FilTex[0] = Texture'TriadLumPathTex0';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex19';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (TriadLumPath(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'SkinTex15';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex9';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 2:
										FilTex[0] = Texture'TriadLumPath7Tex0';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex37';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
								if (FilTex[1] != None)
								{
									TPawn.Multiskins[7] = FilTex[1];
									SyncSkins(TPawn);
								}
							}
							else if (TriadRedArrow(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 0:
										FilTex[0] = Texture'TriadRedArrow4Tex0';
									break;
									case 1:
										FilTex[0] = Texture'TriadRedArrow8Tex0';
									break;
									case 2:
										FilTex[0] = Texture'TriadRedArrow7Tex0';
									break;
									case 4:
										FilTex[0] = Texture'TriadRedArrow6Tex0';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "06_HONGKONG_WANCHAI_MARKET":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Businessman3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "TeaHouseCustomer":
										TPawn.MultiSkins[0] = Texture'SkinTex12';
										TPawn.MultiSkins[2] = Texture'SkinTex12';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Female3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "TeaHouseWoman":
										TPawn.MultiSkins[0] = Texture'SkinTex32';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Female4(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MarketGoth":
										TPawn.MultiSkins[2] = Texture'PantsTex4';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex43';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex16';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex38';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex7';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex10';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Male3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MarketButcher":
										TPawn.MultiSkins[0] = Texture'SkinTex8';
										TPawn.MultiSkins[3] = Texture'PantsTex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "MarketShopperFlowers":
										TPawn.MultiSkins[0] = Texture'Female1Tex0';
										TPawn.MultiSkins[1] = Texture'Female1Tex0';
										TPawn.MultiSkins[2] = Texture'Female1Tex0';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (TriadLumPath(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'SkinTex6';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex8';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex13';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex16';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex8';
									break;
									case 6:
										FilTex[0] = Texture'TriadLumPath6Tex0';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 7:
										FilTex[0] = Texture'TriadLumPath4Tex0';
										FilTex[1] = Texture'PonytailTex1';
									break;
									case 11:
										FilTex[0] = Texture'SkinTex11';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
								if (FilTex[1] != None)
								{
									TPawn.Multiskins[7] = FilTex[1];
									SyncSkins(TPawn);
								}
							}
							else if (TriadLumPath2(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.Multiskins[0] = Texture'TriadLumPath3Tex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (TriadRedArrow(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "TeaHouseRedArrow":
										FilTex[0] = Texture'TriadRedArrow4Tex0';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "06_HONGKONG_WANCHAI_STREET":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BoatPerson(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[3] = Texture'PantsTex7';
										TPawn.MultiSkins[5] = Texture'Male3Tex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale6Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex6';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (Businessman3(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 0:
										FilTex[0] = Texture'SkinTex17';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex19';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex35';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (JunkieFemale(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[2] = Texture'JunkieFemaleTex0';
										TPawn.MultiSkins[6] = Texture'JunkieMaleTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (SarahMead(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 0:
										TPawn.MultiSkins[5] = Texture'SkinTex33';
										TPawn.MultiSkins[6] = Texture'PinkMaskTex';
										TPawn.MultiSkins[7] = Texture'SkinTex33';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
							else if (TriadLumPath(TPawn) != None)
							{
								FilTex[0] = None;
								FilTex[1] = None;
								switch(TCounters[5])
								{
									case 0:
										FilTex[0] = Texture'SkinTex13';
									break;
								}
								TCounters[5] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
								if (FilTex[1] != None)
								{
									TPawn.Multiskins[7] = FilTex[1];
									SyncSkins(TPawn);
								}
							}
							else if (TriadRedArrow(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[6])
								{
									case 0:
										FilTex[0] = Texture'TriadRedArrow2Tex0';
									break;
								}
								TCounters[6] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "06_HONGKONG_WANCHAI_UNDERWORLD":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Bartender(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClubBartender":
										TPawn.MultiSkins[0] = Texture'SkinTex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (BusinessMan3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "BarSuit":
										TPawn.MultiSkins[0] = Texture'SkinTex3';
										TPawn.MultiSkins[2] = Texture'SkinTex3';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Female2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClubDoorGirl":
										TPawn.MultiSkins[0] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[1] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[2] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[3] = Texture'Hooker2Tex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Female3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Mamasan":
										TPawn.MultiSkins[0] = Texture'SkinTex32';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Female4(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Date2":
										TPawn.MultiSkins[0] = Texture'SkinTex31';
										TPawn.MultiSkins[2] = Texture'PantsTex8';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 0:
										FilTex[0] = Texture'SkinTex9';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex13';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex35';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex15';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Hooker1(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClubMercedes":
										TPawn.MultiSkins[1] = Texture'PantsTex5';
										TPawn.MultiSkins[2] = Texture'SarahMeadTex2';
										TPawn.MultiSkins[4] = Texture'SarahMeadTex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Hooker2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "DanceLisa":
										TPawn.MultiSkins[0] = Texture'NurseTex0';
										TPawn.MultiSkins[7] = Texture'Female1Tex0';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (LowerClassFemale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClubTessa":
										TPawn.MultiSkins[6] = Texture'Male2Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (LowerClassMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "BarManLawrence":
										TPawn.MultiSkins[0] = Texture'SkinTex8';
										TPawn.MultiSkins[3] = Texture'PantsTex1';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (LowerClassMale2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "BarThug":
										TPawn.MultiSkins[0] = Texture'SkinTex34';
										TPawn.MultiSkins[1] = Texture'PantsTex2';
										TPawn.MultiSkins[2] = Texture'SkinTex34';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Sailor(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'Sailor2Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Sailor7Tex0';
									break;
									case 3:
										FilTex[0] = Texture'Sailor6Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (SarahMead(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Date1":
										TPawn.MultiSkins[5] = Texture'SarahMeadTex0';
										TPawn.MultiSkins[6] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "DanceCarole":
										TPawn.MultiSkins[4] = Texture'Businesswoman1Tex1';
										TPawn.MultiSkins[5] = Texture'Businesswoman1Tex1';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (ThugMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "BarManVince":
										TPawn.MultiSkins[2] = Texture'Male2Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (TriadRedArrow(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'TriadRedArrow7Tex0';
									break;
									case 1:
										FilTex[0] = Texture'TriadRedArrow6Tex0';
									break;
									case 3:
										FilTex[0] = Texture'TriadRedArrow8Tex0';
									break;
									case 4:
										FilTex[0] = Texture'TriadRedArrow2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'TriadRedArrow4Tex0';
									break;
									case 6:
										FilTex[0] = Texture'TriadRedArrow4Tex0';
									break;
									case 7:
										FilTex[0] = Texture'TriadRedArrow9Tex0';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 8:
			switch(MN)
			{
				case "08_NYC_FREECLINIC":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "SickBum2":
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[2] = Texture'JunkieMaleTex2';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex2';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (BumMale2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClinicBum2":
										TPawn.MultiSkins[1] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[5] = Texture'BumMale3Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ClinicBum1":
										TPawn.MultiSkins[0] = Texture'BumMale5Tex0';
										TPawn.MultiSkins[1] = Texture'BumMaleTex2';
										TPawn.MultiSkins[2] = Texture'PantsTex3';
										TPawn.MultiSkins[4] = Texture'TrenchShirtTex1';
										TPawn.MultiSkins[5] = Texture'BumMaleTex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (Nurse(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "M08Nurse":
										TPawn.MultiSkins[0] = Texture'RachelMeadTex0';
										TPawn.MultiSkins[1] = Texture'RachelMeadTex0';
										TPawn.MultiSkins[2] = Texture'RachelMeadTex0';
										SyncSkins(TPawn);
									break;
								}
							}
						}
					}
				break;
				case "08_NYC_HOTEL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (RiotCop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 1:
										FilTex[0] = Texture'SkinTex4';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "08_NYC_STREET":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "AlleyBum1":
										TPawn.MultiSkins[0] = Texture'BumMale4Tex0';
										TPawn.MultiSkins[2] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (BumMale3(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "AlleyBum2":
										TPawn.MultiSkins[1] = Texture'BumMale2Tex2';
										TPawn.MultiSkins[2] = Texture'PantsTex4';
										TPawn.MultiSkins[5] = Texture'BumMale2Tex2';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'SkinTex3';
											break;
											case 1:
												FilTex[0] = Texture'MorganEverettTex0';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (RiotCop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'MichaelBerryTex2';
										SyncSkins(TPawn);
									break;
									case 3:
										FilTex[0] = Texture'BartenderTex0';
										SyncSkins(TPawn);
									break;
									case 4:
										FilTex[0] = Texture'MorganEverettTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ThugMale(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "ShadyGuy":
										TPawn.MultiSkins[0] = Texture'SkinTex46';
										TPawn.MultiSkins[2] = Texture'PantsTex5';
										SyncSkins(TPawn);
									break;
								}
							}
						}
					}
				break;
			}
		break;
		case 9:
			switch(MN)
			{
				case "09_NYC_DOCKYARD":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "Mechanic1":
										FilTex[0] = Texture'BartenderTex0';
									break;
									case "Mechanic3":
										FilTex[0] = Texture'SkinTex20';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Soldier(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'Soldier5Tex0';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "09_NYC_GRAVEYARD":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Janitor(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "Gatekeeper":
										FilTex[0] = Texture'SkinTex47';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[0])
										{
											case 0:
												FilTex[0] = Texture'SkinTex4';
											break;
											case 2:
												FilTex[0] = Texture'SkinTex3';
											break;
											case 3:
												FilTex[0] = Texture'SkinTex54';
											break;
											case 5:
												FilTex[0] = Texture'SkinTex6';
											break;
											case 8:
												FilTex[0] = Texture'SkinTex55';
											break;
										}
										TCounters[0] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "09_NYC_SHIP":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex14';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex40';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex37';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex7';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex39';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex36';
									break;
									case 7:
										FilTex[0] = Texture'SkinTex12';
									break;
									case 8:
										FilTex[0] = Texture'SkinTex38';
									break;
									case 9:
										FilTex[0] = Texture'TriadLumPathTex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "CafWorker2":
										FilTex[0] = Texture'SkinTex22';
									break;
									case "CafWorker1":
										FilTex[0] = Texture'SkinTex3';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Sailor(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 1:
										FilTex[0] = Texture'Sailor2Tex0';
									break;
									case 2:
										FilTex[0] = Texture'Sailor4Tex0';
									break;
									case 3:
										FilTex[0] = Texture'Sailor2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Sailor3Tex0';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Soldier(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									default:
										switch(TCounters[2])
										{
											case 0:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
											case 1:
												FilTex[0] = Texture'Soldier4Tex0';
											break;
											case 2:
												FilTex[0] = Texture'Soldier3Tex0';
											break;
											case 5:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
											case 6:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
											case 7:
												FilTex[0] = Texture'Soldier3Tex0';
											break;
											case 9:
												FilTex[0] = Texture'Soldier5Tex0';
											break;
											case 10:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
											case 11:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
											case 12:
												FilTex[0] = Texture'Soldier4Tex0';
											break;
											case 14:
												FilTex[0] = Texture'Soldier4Tex0';
											break;
											case 15:
												FilTex[0] = Texture'Soldier3Tex0';
											break;
											case 17:
												FilTex[0] = Texture'Soldier2Tex0';
											break;
										}
										TCounters[2] += 1;
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "09_NYC_SHIPBELOW":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (HKMilitary(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex16';
									break;
									case 1:
										FilTex[0] = Texture'SkinTex37';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex11';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex19';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex18';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex7';
									break;
									case 7:
										FilTex[0] = Texture'SkinTex17';
									break;
									case 8:
										FilTex[0] = Texture'SkinTex14';
									break;
									case 9:
										FilTex[0] = Texture'SkinTex14';
									break;
									case 10:
										FilTex[0] = Texture'SkinTex17';
									break;
									case 11:
										FilTex[0] = Texture'SkinTex35';
									break;
									case 12:
										FilTex[0] = Texture'SkinTex41';
									break;
									case 13:
										FilTex[0] = Texture'SkinTex10';
									break;
									case 14:
										FilTex[0] = Texture'SkinTex12';
									break;
									case 15:
										FilTex[0] = Texture'SkinTex34';
									break;
									case 16:
										FilTex[0] = Texture'SkinTex13';
									break;
									case 17:
										FilTex[0] = Texture'SkinTex16';
									break;
									case 18:
										FilTex[0] = Texture'SkinTex8';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Sailor(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'Sailor4Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Sailor2Tex0';
									break;
									case 3:
										FilTex[0] = Texture'Sailor4Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Sailor2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Sailor6Tex0';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 10:
			switch(MN)
			{
				case "10_PARIS_CATACOMBS":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Male2(TPawn) != None)
							{
								switch(TPawn.BindName)
								{
									case "Defoe":
										TPawn.MultiSkins[0] = Texture'SkinTex30';
										TPawn.MultiSkins[2] = Texture'SkinTex30';
										TPawn.MultiSkins[4] = Texture'SkinTex26';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex23';
									break;
									case 1:
										FilTex[0] = Texture'BartenderTex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "10_PARIS_CATACOMBS_TUNNELS":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[6] = Texture'PantsTex7';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale2Tex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (Hooker1(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'ScientistFemaleTex3';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[3])
								{
									case 1:
										FilTex[0] = Texture'KyleLloydTex2';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex48';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex45';
									break;
									case 7:
										FilTex[0] = Texture'MichaelBerryTex2';
									break;
								}
								TCounters[3] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ThugMale(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex25';
 										TPawn.MultiSkins[4] = Texture'SkinTex25';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
						}
					}
				break;
				case "10_PARIS_CLUB":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Bartender(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex54';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (BusinessMan3(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex28';
										TPawn.MultiSkins[1] = Texture'SecretServiceTex2';
										TPawn.MultiSkins[2] = Texture'SkinTex28';
										TPawn.MultiSkins[3] = Texture'SecretServiceTex1';
										TPawn.MultiSkins[4] = Texture'SecretServiceTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (Businesswoman1(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[1] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[2] = Texture'MargaretWilliamsTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (Female1(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[6] = Texture'PantsTex5';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (Female4(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'Female1Tex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
							else if (Hooker2(TPawn) != None)
							{
								switch(TCounters[5])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex5';
										TPawn.MultiSkins[6] = Texture'SkinTex5';
										TPawn.MultiSkins[7] = Texture'SkinTex5';
										SyncSkins(TPawn);
									break;
								}
								TCounters[5] += 1;
							}
							else if (LowerClassFemale(TPawn) != None)
							{
								switch(TCounters[6])
								{
									case 0:
										TPawn.MultiSkins[6] = Texture'JunkieMaleTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[6] += 1;
							}
							else if (MargaretWilliams(TPawn) != None)
							{
								switch(TCounters[7])
								{
									case 0:
										TPawn.MultiSkins[4] = Texture'Female3Tex1';
										TPawn.MultiSkins[5] = Texture'Female3Tex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[7] += 1;
							}
							else if (MichaelHamner(TPawn) != None)
							{
								switch(TCounters[8])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex24';
										TPawn.MultiSkins[2] = Texture'SkinTex24';
										SyncSkins(TPawn);
									break;
								}
								TCounters[8] += 1;
							}
							else if (Secretary(TPawn) != None)
							{
								switch(TCounters[9])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'PinkMaskTex';
										TPawn.MultiSkins[4] = Texture'MargaretWilliamsTex1';
										TPawn.MultiSkins[5] = Texture'MargaretWilliamsTex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[9] += 1;
							}
							else if (ThugMale2(TPawn) != None)
							{
								switch(TCounters[10])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex3';
										//TPawn.MultiSkins[3] = Texture'ClubSecurityTex2';
										TPawn.MultiSkins[4] = Texture'PinkMaskTex';
										//TPawn.MultiSkins[5] = Texture'ClubSecurityTex1';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'SkinTex25';
										//TPawn.MultiSkins[3] = Texture'ClubSecurityTex2';
										TPawn.MultiSkins[4] = Texture'PinkMaskTex';
										//TPawn.MultiSkins[5] = Texture'ClubSecurityTex1';
										TPawn.MultiSkins[6] = Texture'FramesTex2';
										TPawn.MultiSkins[7] = Texture'LensesTex3';
										SyncSkins(TPawn);
									break;
								}
								TCounters[10] += 1;
							}
							else if (ThugMale3(TPawn) != None)
							{
								switch(TCounters[11])
								{
									case 0:
										//TPawn.MultiSkins[0] = Texture'ClubSecurityTex3';
										//TPawn.MultiSkins[1] = Texture'ClubSecurityTex2';
										SyncSkins(TPawn);
									break;
									case 1:
										//TPawn.MultiSkins[0] = Texture'ClubSecurityTex3';
										//TPawn.MultiSkins[1] = Texture'ClubSecurityTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[11] += 1;
							}
						}
					}
				break;
				case "10_PARIS_METRO":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Bartender(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex44';
										TPawn.MultiSkins[3] = Texture'PantsTex1';
										TPawn.MultiSkins[4] = Texture'SkinTex44';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (Butler(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex50';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (Businessman1(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex51';
										TPawn.MultiSkins[2] = Texture'SkinTex51';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (Chef(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex24';
 										TPawn.MultiSkins[2] = Texture'SkinTex24';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'SkinTex48';
 										TPawn.MultiSkins[2] = Texture'SkinTex48';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (ChildMale2(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'Male2Tex1';
 										TPawn.MultiSkins[2] = Texture'Male2Tex2';
										TPawn.MultiSkins[5] = Texture'Male2Tex1';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
							else if (Cop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[5])
								{
									case 1:
										FilTex[0] = Texture'Cop5Tex0';
									break;
									case 3:
										FilTex[0] = Texture'Cop2Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Cop7Tex0';
									break;
									case 7:
										FilTex[0] = Texture'Cop5Tex0';
									break;
								}
								TCounters[5] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Female1(TPawn) != None)
							{
								switch(TCounters[6])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex53';
										TPawn.MultiSkins[2] = Texture'SkinTex53';
										TPawn.MultiSkins[5] = Texture'SkinTex53';
										TPawn.MultiSkins[6] = Texture'Male2Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[6] += 1;
							}
							else if (Female2(TPawn) != None)
							{
								switch(TCounters[7])
								{
									case 0:
										TPawn.MultiSkins[3] = Texture'ScientistFemaleTex3';
										SyncSkins(TPawn);
									break;
								}
								TCounters[7] += 1;
							}
							else if (Female3(TPawn) != None)
							{
								switch(TCounters[8])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex52';
										TPawn.MultiSkins[1] = Texture'SkinTex52';
										TPawn.MultiSkins[2] = Texture'SkinTex52';
										SyncSkins(TPawn);
									break;
								}
								TCounters[8] += 1;
							}
							else if (Janitor(TPawn) != None)
							{
								switch(TCounters[9])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex23';
										TPawn.MultiSkins[3] = Texture'SkinTex23';
										SyncSkins(TPawn);
									break;
								}
								TCounters[9] += 1;
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[10])
								{
									case 0:
										FilTex[0] = Texture'SkinTex4';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex4';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex3';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex45';
									break;
									case 8:
										FilTex[0] = Texture'SkinTex21';
									break;
									case 10:
										FilTex[0] = Texture'SkinTex27';
									break;
								}
								TCounters[10] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ThugMale3(TPawn) != None)
							{
								switch(TCounters[11])
								{
									case 0:
										TPawn.MultiSkins[1] = Texture'PantsTex8';
										TPawn.MultiSkins[4] = Texture'PinkMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[11] += 1;
							}
						}
					}
				break;
			}
		break;
		case 11:
			switch(MN)
			{
				case "11_PARIS_CATHEDRAL":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 4:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex3';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex3';
									break;
									case 7:
										FilTex[0] = Texture'SkinTex4';
									break;
									case 9:
										FilTex[0] = Texture'SkinTex23';
									break;
									case 12:
										FilTex[0] = Texture'SkinTex19';
									break;
									case 15:
										FilTex[0] = Texture'BumMale9Tex0';
									break;
									case 17:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 18:
										FilTex[0] = Texture'SkinTex55';
									break;
									case 22:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 23:
										FilTex[0] = Texture'SkinTex41';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "11_PARIS_EVERETT":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								DXC.Multiskins[0] = Texture'SkinTex3';
								DXC.Multiskins[3] = Texture'SkinTex3';
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex3';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "11_PARIS_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Cop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'Cop2Tex0';
									break;
									case 1:
										FilTex[0] = Texture'Cop5Tex0';
									break;
									case 3:
										FilTex[0] = Texture'Cop3Tex0';
									break;
									case 4:
										FilTex[0] = Texture'Cop6Tex0';
									break;
									case 5:
										FilTex[0] = Texture'Cop8Tex0';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[2] = FilTex[0];
									TPawn.Multiskins[4] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex28';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 12:
			switch(MN)
			{
				case "12_VANDENBERG_CMD":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.Multiskins[0] = Texture'PhilCollinsTex2';
										DXC.Multiskins[3] = Texture'PhilCollinsTex2';
									break;
								}
								TCounters[0] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 0:
										FilTex[0] = Texture'SkinTex20';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 0:
										FilTex[0] = Texture'SkinTex17';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex12';
									break;
									case 7:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 9:
										FilTex[0] = Texture'SkinTex27';
									break;
									case 10:
										FilTex[0] = Texture'SkinTex47';
									break;
									case 12:
										FilTex[0] = Texture'SkinTex44';
									break;
									case 15:
										FilTex[0] = Texture'SkinTex23';
									break;
									case 16:
										FilTex[0] = Texture'SkinTex55';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ScientistFemale(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 1:
										TPawn.MultiSkins[0] = Texture'SecretaryTex0';
										TPawn.MultiSkins[3] = Texture'SecretaryTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
							else if (ScientistMale(TPawn) != None)
							{
								switch(TCounters[4])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'DoctorTex0';
										TPawn.MultiSkins[3] = Texture'DoctorTex0';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'SkinTex27';
										TPawn.MultiSkins[3] = Texture'SkinTex27';
										TPawn.MultiSkins[6] = Texture'GrayMaskTex';
										TPawn.MultiSkins[7] = Texture'BlackMaskTex';
										SyncSkins(TPawn);
									break;
								}
								TCounters[4] += 1;
							}
						}
					}
				break;
				case "12_VANDENBERG_COMPUTER":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (ScientistMale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex28';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
						}
					}
				break;
				case "12_VANDENBERG_GAS":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (BumMale3Carcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[1] = Texture'BumMale2Tex2';
										DXC.MultiSkins[2] = Texture'PantsTex2';
										DXC.MultiSkins[5] = Texture'BumMale2Tex2';
									break;
								}
								TCounters[0] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (BumFemale(TPawn) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										TPawn.MultiSkins[6] = Texture'JunkieMaleTex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[1] += 1;
							}
							else if (BumMale(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'BumMale5Tex0';
										TPawn.MultiSkins[1] = Texture'BumMale3Tex2';
										TPawn.MultiSkins[3] = Texture'BumMale5Tex0';
										TPawn.MultiSkins[4] = Texture'FordSchickTex1';
										TPawn.MultiSkins[5] = Texture'BumMale3Tex2';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[3])
								{
									case 1:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 4:
										FilTex[0] = Texture'SkinTex55';
									break;
								}
								TCounters[3] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
		case 14:
			switch(MN)
			{
				case "14_OCEANLAB_LAB":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (ScientistMaleCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'SkinTex2';
										DXC.MultiSkins[3] = Texture'SkinTex2';
									break;
								}
								TCounters[0] += 1;
							}
							else if (SecretaryCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'NurseTex0';
										DXC.MultiSkins[1] = Texture'NurseTex0';
										DXC.MultiSkins[2] = Texture'NurseTex0';
									break;
								}
								TCounters[1] += 1;
							}
						}
					}
				break;
				case "14_OCEANLAB_SILO":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (ScientistMale(TPawn) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex49';
										TPawn.MultiSkins[3] = Texture'SkinTex49';
										SyncSkins(TPawn);
									break;
								}
								TCounters[0] += 1;
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 3:
										FilTex[0] = Texture'SkinTex17';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex55';
									break;
									case 8:
										FilTex[0] = Texture'BartenderTex0';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "14_OCEANLAB_UC":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (ScientistMaleCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[6] = Texture'GrayMaskTex';
										DXC.MultiSkins[7] = Texture'BlackMaskTex';
									break;
								}
								TCounters[0] += 1;
							}
							else if (ScientistFemaleCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'RachelMeadTex0';
										DXC.MultiSkins[3] = Texture'RachelMeadTex0';
									break;
								}
								TCounters[1] += 1;
							}
						}
					}
				break;
				case "14_VANDENBERG_SUB":
					if (!bRevisionMapSet)
					{
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[0])
								{
									case 0:
										FilTex[0] = Texture'SkinTex29';
									break;
								}
								TCounters[0] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[1])
								{
									case 2:
										FilTex[0] = Texture'ScottBordinTex2';
									break;
									case 3:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex3';
									break;
									case 6:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 7:
										FilTex[0] = Texture'SkinTex47';
									break;
									case 8:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 9:
										FilTex[0] = Texture'SkinTex26';
									break;
									case 12:
										FilTex[0] = Texture'SkinTex18';
									break;
									case 16:
										FilTex[0] = Texture'SkinTex48';
									break;
									case 19:
										FilTex[0] = Texture'SkinTex55';
									break;
								}
								TCounters[1] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (ScientistFemale(TPawn) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'MargaretWilliamsTex0';
										TPawn.MultiSkins[3] = Texture'MargaretWilliamsTex0';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'RachelMeadTex0';
										TPawn.MultiSkins[3] = Texture'RachelMeadTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[2] += 1;
							}
							else if (ScientistMale(TPawn) != None)
							{
								switch(TCounters[3])
								{
									case 0:
										TPawn.MultiSkins[0] = Texture'SkinTex8';
										TPawn.MultiSkins[3] = Texture'SkinTex8';
										SyncSkins(TPawn);
									break;
									case 1:
										TPawn.MultiSkins[0] = Texture'DoctorTex0';
										TPawn.MultiSkins[3] = Texture'DoctorTex0';
										SyncSkins(TPawn);
									break;
								}
								TCounters[3] += 1;
							}
						}
					}
				break;
			}
		break;
		case 15:
			switch(MN)
			{
				case "15_AREA51_BUNKER":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'SkinTex16';
										DXC.MultiSkins[3] = Texture'SkinTex16';
									break;
									case 1:
										DXC.MultiSkins[0] = Texture'SkinTex20';
										DXC.MultiSkins[3] = Texture'SkinTex20';
									break;
									case 2:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
										DXC.MultiSkins[3] = Texture'BartenderTex0';
									break;
									case 3:
										DXC.MultiSkins[0] = Texture'NathanMadisonTex0';
										DXC.MultiSkins[3] = Texture'NathanMadisonTex0';
									break;
									case 5:
										DXC.MultiSkins[0] = Texture'Male1Tex0';
										DXC.MultiSkins[3] = Texture'Male1Tex0';
									break;
								}
								TCounters[0] += 1;
							}
							else if (SoldierCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'Soldier4Tex0';
										DXC.MultiSkins[3] = Texture'Soldier4Tex0';
									break;
									case 1:
										DXC.MultiSkins[0] = Texture'Soldier3Tex0';
										DXC.MultiSkins[3] = Texture'Soldier3Tex0';
									break;
									case 3:
										DXC.MultiSkins[0] = Texture'Soldier3Tex0';
										DXC.MultiSkins[3] = Texture'Soldier3Tex0';
									break;
									case 5:
										DXC.MultiSkins[0] = Texture'Soldier2Tex0';
										DXC.MultiSkins[3] = Texture'Soldier2Tex0';
									break;
									case 6:
										DXC.MultiSkins[0] = Texture'Soldier5Tex0';
										DXC.MultiSkins[3] = Texture'Soldier5Tex0';
									break;
									case 7:
										DXC.MultiSkins[0] = Texture'Soldier2Tex0';
										DXC.MultiSkins[3] = Texture'Soldier2Tex0';
									break;
								}
								TCounters[1] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Soldier(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TPawn.BindName)
								{
									case "ScaredSoldier":
										FilTex[0] = Texture'Soldier2Tex0';
									break;
								}
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "15_AREA51_ENTRANCE":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'SkinTex23';
										DXC.MultiSkins[3] = Texture'SkinTex23';
									break;
								}
								TCounters[0] += 1;
							}
							else if (ScientistMaleCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
										DXC.MultiSkins[3] = Texture'BartenderTex0';
										DXC.MultiSkins[6] = Texture'GrayMaskTex';
										DXC.MultiSkins[7] = Texture'BlackMaskTex';
									break;
									case 1:
										DXC.MultiSkins[0] = Texture'SkinTex4';
									break;
								}
								TCounters[1] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 1:
										FilTex[0] = Texture'SkinTex26';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 4:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 7:
										FilTex[0] = Texture'SkinTex41';
									break;
									case 8:
										FilTex[0] = Texture'SkinTex51';
									break;
									case 11:
										FilTex[0] = Texture'SkinTex55';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "15_AREA51_FINAL":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
										DXC.MultiSkins[3] = Texture'BartenderTex0';
									break;
									case 2:
										DXC.MultiSkins[0] = Texture'SkinTex3';
										DXC.MultiSkins[3] = Texture'SkinTex3';
									break;
									case 3:
										DXC.MultiSkins[0] = Texture'Male1Tex0';
										DXC.MultiSkins[3] = Texture'Male1Tex0';
									break;
									case 4:
										DXC.MultiSkins[0] = Texture'SkinTex29';
										DXC.MultiSkins[3] = Texture'SkinTex29';
									break;
									case 5:
										DXC.MultiSkins[0] = Texture'NathanMadisonTex0';
										DXC.MultiSkins[3] = Texture'NathanMadisonTex0';
									break;
									case 6:
										DXC.MultiSkins[0] = Texture'KyleLloydTex2';
										DXC.MultiSkins[3] = Texture'KyleLloydTex2';
									break;
									case 7:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
										DXC.MultiSkins[3] = Texture'BartenderTex0';
									break;
									case 8:
										DXC.MultiSkins[0] = Texture'SkinTex2';
										DXC.MultiSkins[3] = Texture'SkinTex2';
									break;
									case 9:
										DXC.MultiSkins[0] = Texture'SkinTex20';
										DXC.MultiSkins[3] = Texture'SkinTex20';
									break;
								}
								TCounters[0] += 1;
							}
							else if (ScientistFemaleCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'RachelMeadTex0';
										DXC.MultiSkins[3] = Texture'RachelMeadTex0';
									break;
								}
								TCounters[1] += 1;
							}
							else if (ScientistMaleCarcass(DXC) != None)
							{
								switch(TCounters[2])
								{
									case 0:
										DXC.MultiSkins[6] = Texture'GrayMaskTex';
										DXC.MultiSkins[7] = Texture'BlackMaskTex';
									break;
									case 1:
										DXC.MultiSkins[0] = Texture'SkinTex4';
										DXC.MultiSkins[3] = Texture'SkinTex4';
										DXC.MultiSkins[6] = Texture'GrayMaskTex';
										DXC.MultiSkins[7] = Texture'BlackMaskTex';
									break;
									case 3:
										DXC.MultiSkins[0] = Texture'SkinTex25';
										DXC.MultiSkins[3] = Texture'SkinTex25';
									break;
								}
								TCounters[2] += 1;
							}
							else if (SoldierCarcass(DXC) != None)
							{
								switch(TCounters[3])
								{
									case 1:
										DXC.MultiSkins[0] = Texture'Soldier2Tex0';
										DXC.MultiSkins[3] = Texture'Soldier2Tex0';
									break;
									case 2:
										DXC.MultiSkins[0] = Texture'Soldier3Tex0';
										DXC.MultiSkins[3] = Texture'Soldier3Tex0';
									break;
									case 5:
										DXC.MultiSkins[0] = Texture'Soldier2Tex0';
										DXC.MultiSkins[3] = Texture'Soldier2Tex0';
									break;
									case 6:
										DXC.MultiSkins[0] = Texture'Soldier5Tex0';
										DXC.MultiSkins[3] = Texture'Soldier5Tex0';
									break;
								}
								TCounters[3] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (Mechanic(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[4])
								{
									case 0:
										FilTex[0] = Texture'SkinTex26';
									break;
								}
								TCounters[4] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
							else if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[5])
								{
									case 1:
										FilTex[0] = Texture'TobyAtanweTex0';
									break;
									case 2:
										FilTex[0] = Texture'SkinTex51';
									break;
									case 3:
										FilTex[0] = Texture'SkinTex54';
									break;
									case 6:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 7:
										FilTex[0] = Texture'FordSchickTex0';
									break;
								}
								TCounters[5] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
				case "15_AREA51_PAGE":
					if (!bRevisionMapSet)
					{
						forEach AllActors(class'DeusExCarcass', DXC)
						{
							if (MechanicCarcass(DXC) != None)
							{
								switch(TCounters[0])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
										DXC.MultiSkins[3] = Texture'BartenderTex0';
									break;
									case 1:
										DXC.MultiSkins[0] = Texture'SkinTex3';
										DXC.MultiSkins[3] = Texture'SkinTex3';
									break;
									case 3:
										DXC.MultiSkins[0] = Texture'Male1Tex0';
										DXC.MultiSkins[3] = Texture'Male1Tex0';
									break;
								}
								TCounters[0] += 1;
							}
							else if (ScientistMaleCarcass(DXC) != None)
							{
								switch(TCounters[1])
								{
									case 0:
										DXC.MultiSkins[0] = Texture'BartenderTex0';
									break;
									case 1:
										DXC.MultiSkins[6] = Texture'GrayMaskTex';
										DXC.MultiSkins[7] = Texture'BlackMaskTex';
									break;
								}
								TCounters[1] += 1;
							}
						}
						for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
						{
							if (MJ12Troop(TPawn) != None)
							{
								FilTex[0] = None;
								switch(TCounters[2])
								{
									case 1:
										FilTex[0] = Texture'BartenderTex0';
									break;
									case 5:
										FilTex[0] = Texture'SkinTex12';
									break;
									case 6:
										FilTex[0] = Texture'SkinTex54';
									break;
								}
								TCounters[2] += 1;
								
								if (FilTex[0] != None)
								{
									TPawn.Multiskins[0] = FilTex[0];
									TPawn.Multiskins[3] = FilTex[0];
									SyncSkins(TPawn);
								}
							}
						}
					}
				break;
			}
		break;
	}
	
	bRanUpdate = true;
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
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
