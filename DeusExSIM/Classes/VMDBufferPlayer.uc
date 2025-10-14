//=============================================================================
// VMDBufferPlayer.
//=============================================================================
class VMDBufferPlayer extends DeusExPlayer
	abstract;

//++++++++++++++++++++++++
//MADDERS ADDITIONS!
var travel bool bInverseAim, bLastWasLoad, bWeaponHideException;
var float VMDLastTickChunk; //Other stuff
var transient float VMDTransientLevelTime;

//#####################
//STAT VARS!
//---------------
//Sugar, Caffeine, Nicotine, Alcohol, Zyme
var(MADDERSADDICTION) travel int AddictionStates[5], ForceAddictions[5], LastRecMission; //Record this, mostly for addiction.
var travel float ActiveStress, StressMomentum; //1-100
var float UnivStressScales[5];
var travel int LastStressPhase, FoodSmellThresholds[2]; //MADDERS, 1/19/21: Stops redundant message tripping. Yay.

//^^^^^^^^^^^^^^^^^^^^^
//TIMER VARS!
var travel bool bKillswitchEngaged, bUpdateTravelTalents; //Death. Is. My. Purse.
var travel float KSHealMult, KSHealthMult, LastEnergy;

//=====================
//TIMER UPDATES!
//=====================
//---------------------
//AutoSave
var float AutoSaveTimer;
var bool bAutoSaved, bAutoSaving, bIsMapTravel;
var travel bool bPendingNGPlusSave;
var int LastMissionNumber;
var travel string LastAutoSaveLoc; //Fix for map save spam.

var travel float SkillNotifierDisplayTimes[11];

//Debilitation
//---------------
//Sugar, Caffeine, Nicotine, Alcohol, Zyme
var(MADDERSADDICTION) travel float AddictionTimers[5], OverdoseTimers[5], AfflictionTimers[5], AddictionKickTimers[5],
			AddictionThresholds[5];
var travel float WaterBuildup, LastGameSpeed; //How much water have we drank?
var travel bool bZymeAffected;
var travel float CigaretteAppetitePeriod; //MADDERS, 8/26/23: Suppress, then increase appetite.

var travel float KillswitchTime, KillswitchThresholds[8]; //96 minutes total time before death.
var travel int KillswitchPhase; //8 phases total. Handle this over time.

var travel float TaseDuration; //Tasing. Yay.
var travel float HUDEMPTimer, HUDScramblerTimer; //Re-enable after this time.
var bool bLastSplashWasSelf, bLastSplashWasDrone; //Used for self EMP skill augment, but it has other uses in theory.
var float LastWeaponDamageSkillMult, FloatDamageValues[6]; //Same as starting health values, but with no health brand health var.
var float TiltEffectPitchFloat, TiltEffectYawFloat;

var localized string MsgNeedMoreTools, MsgNoTools, MsgNeedMorePicks, MsgNoPicks, MsgDontHaveKey,
			MsgNoArmsToCarry, MsgCraving, MsgNewHabit, MsgKickedHabit, MsgHungerReduced,
			SugarName, CaffeineName, AlcoholName, NicotineName, CrackName,
			MsgSkillUpgradeAvailable;

//Temp usage only!
var int BroadUpdateQuarter;
var float KSWobbleTimer, BroadUpdateTimer;
var float StressTimer, StarvationTimer;
var float TaseTimer, OverdoseTimer;

//Roll and jump duck related
var bool bRollAchieved, bWasFallRoll, bJumpDucked, bLastTouchingLadder;
var int RollDir, VMDDodgeDir; //1 = forward, -1 = backward. 2 = right, -2 = left. Yay.
var float RollCooldown, RollTimer, RollDuration, LastDuckTimer, RollTapMax, RollCapAccel,
		DodgeRollCooldown, DodgeRollTimer, DodgeRollDuration, DodgeRollCapAccel,
		UIForceDuckTimer, UIForceDuckTime;
var Rotator VMDRollModifier;
var travel float RollCooldownTimer, DodgeRollCooldownTimer;

//Limb damage stuff?
var bool bLimpActive;
var float ForceLimpTime; //Sorry B-hoppers.
var name DeathDamageType;

//NOTE: This is for stop drop and roll.
var int LastFireRollDir;

//Timer cap! (Used for hunger. Originally a joke)
var travel float HungerTimer, LastHungerTimer;
var float HungerCap;

//Death negation.
var localized string MsgDeathNegated, MsgDeathNegateCooledDown;
var float DamageGateTimer, NegateDeathGateTime;
var travel float NegateDeathCooldown;
var int CurTickDamageTaken[6];

//MADDERS, 4/10/21: Reiterate
var string QueuedBigMessage;
var float BigMessageRetryTime;

//MADDERS, 8/8/23: Tong fudge. Yay.
var localized string StrPostKillswitchFudge;

//MADDERS, 8/22/23: View flash fudge? Oh boy. Had my own fix, but Han's stops invalid color rendering, too.
var Vector CurrentFlashFog;

//MADDERS, 8/26/23: Bullshit hack to stop running iterators every footstep, specifically on maps that don't have any textures.
var transient int HousingScriptedTexcount;

//MADDERS, 1/12/24: Useful for reducing key presses further. Good suggestion by DefaultPlayer001.
var travel bool bMechAugs;
var travel int LastBrowsedAugPage, LastBrowsedAug;

//Player Hands
//---------------
var travel float PlayerHandsLevel;
var float PlayerHandsCap;

var VMDPlayerHands PlayerHands;

//=====================
//TIMER END!
//=====================

//SMELL NODES!
var VMDSmellManager PlayerSmellNode, PlayerAnimalSmellNode,
			PlayerFoodSmellNode, StrongPlayerFoodSmellNode,
			PlayerBloodSmellNode, StrongPlayerBloodSmellNode,
			PlayerZymeSmellNode,
			PlayerSmokeSmellNode, StrongPlayerSmokeSmellNode;
var travel float BloodSmellLevel, ZymeSmellLevel, SmokeSmellLevel; //How deep in red are we? Now also Zyme and Smoke.

var float LastBloodSmellLevel, LastZymeSmellLevel, LastSmokeSmellLevel, LastFoodSmellLevel;

//Neat.
var travel int PlayerSeed, PlayerMayhemSeed, PlayerNakedSolutionSeed, PlayerNakedSolutionSubseed;

//Mod friendly screen overlay. Neat.
var string VMDVisualOverlayPatches[2];

var EPhysics PreParalyzedPhysics;
var Vector PreParalyzedVelocity, PreParalyzedAcceleration;

//---------------------
//Skill Augments!

var travel VMDSkillAugmentManager SkillAugmentManager;
var travel VMDCraftingManager CraftingManager;

//MADDERS, 12/8/23: Fix stupid skill point bullshit with this one simple trick?
var travel int SkillPointsSpent;

//=====================
//LOCALIZED!
var localized string InventoryFullNull, InventoryFullFeedback;

//=====================
//NEW GAME DATA
var travel string CreationCampaign, SelectedCampaign, CampaignNewGameMap, InvokedBindName, AssignedClass, AssignedSimpleDifficulty, AssignedDifficulty, DatalinkID;
var (MADDERSNGPLUS) travel bool bNGPlusKeepInfamy, bNGPlusTravel;
var (MADDERSNGPLUS) travel int bNGPlusKeepInventory, bNGPlusKeepSkills, bNGPlusKeepAugs, bNGPlusKeepMoney, NGPlusLaps;

var (REVISION) travel string RecordedMaps[64]; //Missionscript clears these. Prepare for the worst.
var (REVISION) travel int MapStyle[23];
var (REVISION) globalconfig int FavoriteMapStyle[23];
var string MapStylePlaces[23];
var localized string MapStylePlaceNames[23];

var localized string SaveGameGenders[2], StrDifficultyNames[8], StrCustomDifficulty, SaveGameNGPlus;

//---------------------
var travel bool bAssignedFemale; //Somehow this language has overlapped with reality, but ok
var(LDDPDEBUG) travel bool bDisableFemaleVoice; //8/9/23: For more accessibility by EditActor 
var travel String StoredPlayerSkins[8], StoredPlayerTexture, StoredPlayerMesh, StoredPlayerMeshLeft;
var Texture FabricatedSkins[8], FabricatedTexture;
var int LastMeshHandedness, CurMeshFramesIndex, CurMeshLensesIndex;
var Mesh FabricatedMesh, FabricatedMeshLeft;
var bool bFabricateQueued, bDefabricateQueued, bLastOverdosed;
//---------------------

//+++++++++++++++++++++
//CONFIG VOMIT
//+++++++++++++++++++++
var() globalconfig int bAddictionEnabled; //VMD extra option #1. 0 is none, 2 is all, 1 is some.
var() globalconfig bool bGrimeEnabled; //VMD extra option #2.
var() globalconfig bool bHungerEnabled; //VMD extra option #3.
var() globalconfig bool bBioHungerEnabled; //BONUS ADDITION: Does running out of hunger consume bio first?
var() globalconfig bool bStressEnabled;  //VMD extra option #4.
var() globalconfig bool bSmellsEnabled; //VMD extra option #5.
var() globalconfig bool bSkillAugmentsEnabled; //VMD extra option #6.
var() globalconfig bool bAutosaveEnabled; //VMD extra option #7.
var() globalconfig bool bRefireSemiauto; //VMD extra option #8.
var() globalconfig bool bImmersiveKillswitch; //VMD extra option #9. This one's fun.
var() globalconfig bool bD3DPrecachingEnabled; //VMD extra option #10: R&D division style.
var() globalconfig bool bHitIndicatorHasVisual; //VMD extra option #11. Has a partner.
var() globalconfig bool bHitIndicatorHasAudio; //VMD extra option #12. Sup, nerd.
var() globalconfig bool bAllowFemJC, bAllowFemaleVoice; //VMD extra option #13. Oh boy. What a chore.
var() globalconfig bool bEnvironmentalSoundsEnabled; //1/18/21, option #14. 
var() globalconfig bool bModdedCharacterSetupMusic; //7/20/21: Extra config for character setup.
var() globalconfig bool bAllowTiltEffects; //12/1/21: Do we opt in for tilt effects on weapons?
var() globalconfig bool bAdvancedLimbDamage; //12/14/21: Do we do extra effects for limb damage? These are very silly.
var() globalconfig bool bUseDynamicCamera; //4/19/22: Do we pivot view more realistically? Toggleable because some people get motion sickness, supposedly.
var() globalconfig bool bUseInstantCrafting; //5/12/22: Do we do crafting instantly, or over time?
var() globalconfig bool bCraftingSystemEnabled; //05/17/22: Crafting should be optional. Oops.
var() globalconfig bool bBoostAugNoise; //07/24/23: For players who keep forgetting they have augs on.
var() globalconfig bool bAllowAnyNGPlus; //8/9/23: Not sure if I'll list this, but it's easy to program, so might as well consider it.
var() globalconfig bool bAutoloadAppearanceSlots; //8/9/23: We overhauled how save/load works, so give people a retro option.
var() globalconfig bool bRealtimeUI; //8/25/23: Realtime UI? Sure, why not, while we're at it.
var() globalconfig bool bRealTimeControllerAugs; //8/26/23: Realtime UI for this is handled separately, thank you very much.
var() globalconfig int bRealisticRollCamera; //8/27/23: Fuckette. Why not? Arg. New code, it's 3 mode.
var() globalconfig bool bMEGHRadarPing; //12/2/23: Don't make this if we don't want to. Noise can be annoying.
var() globalconfig bool bAllowPickupTiltEffects; //12/13/23: Do we opt in for tilt effects on pickups? (Skilled Tools)
var() globalconfig bool bPlayerHandsEnabled; //12/23/23: Do we want player hands? Thanks.
var() globalconfig bool bAllowPlayerHandsTiltEffects; //12/23/23: Also one for this, thanks.
var() globalconfig bool bDecorationFrobHolster; //5/3/24: As also implemented in DX rando.
var() globalconfig bool bDoorFrobKeyring; //5/3/24: Derived from conversations in the community, but minimalist realization of concept.
var() globalconfig int DoorFrobLockpick; //5/3/24: Similar to above, but more flexible.
var() globalconfig bool bElectronicsDrawMultitool; //5/9/24: The above option's buddy.
var() globalconfig bool bUpdateVanillaSkins; //10/20/24: For those who prefer the OG ones or have rando? Speculative, but sure.
var() globalconfig bool bJumpDuckFeedbackNoise; //11/27/24: Some people find this annoying.
var() globalconfig bool bClassicSkillPurchasing; //2/19/25: For those who hate the new, modern means.
var() globalconfig bool bAugControllerShowEnergyPoints; //2/25/25: For DX rando players, primarily.
var() globalconfig bool bDamageGateBreakNoise; //5/1/25: For immersive purposes.
var() globalconfig bool bUseGunplayVersionTwo; //5/2/25: EXPERIMENTAL! We want to have tactical shooter gameplay later. Phase 2.5?
var() globalconfig bool bFrobEmptyLowersWeapon; //5/4/25: For people who don't mind using backspace all the time.
var() globalconfig bool bDisplayUncraftableItems; //6/21/25: For optimizing crafting lists a little bit.
var() bool BarfStartupFullscreen, BarfUseDirectInput; //6/24/24: Purely temporary variables. Used in options menu as a metric.
var() globalconfig int CustomUIScale;
var() globalconfig float TacticalRollTime;
var() globalconfig bool VMDbNoFlash; //8/24/25: Force bNoFlash to this like a pest.
var() globalconfig bool bUseRevisionSoundtrack; //7/20/25: Soundtrack options were luckily preserved, and people are opinionated on this.

var() globalconfig bool bAimFocuserVisible, bDroneAllianceVisible, bHUDVisible, bFrobDisplayBordersVisible, bLogVisible, bSmellIndicatorVisible, bLightGemVisible, bSkillNotifierVisible;
var bool VSyncBarf;
var int BarfAugDisplayVisibility, FOVLevelBarf, FPSCapBarf, RenderDeviceBarf, BarfUIScale;

//OBSOLETE NOW.
var() globalconfig bool bCodebreakerPreference; //VMD extra option #13.

//Stored profile flags.
var() globalconfig bool bGaveNewGameTips;

//Not in menu.
var() globalconfig float ScreenEffectScalar;
var() globalconfig bool bShowOwnedMechanical, bShowOwnedMedical, bShowHealthStatuses;

//Appearance saving? Neat.
var() globalconfig int FaveMaleLensIndex[10], FaveMaleFramesIndex[10], FaveMaleChestIndex[10], FaveMaleCoatIndex[10], FaveMalePantsIndex[10],
			FaveMaleMeshIndex[10], FaveMaleSkinIndex[10],
			FaveFemaleLensIndex[10], FaveFemaleFramesIndex[10], FaveFemaleChestIndex[10], FaveFemaleCoatIndex[10], FaveFemalePantsIndex[10],
			FaveFemaleMeshIndex[10], FaveFemaleSkinIndex[10], FaveHandedness;

var travel int PreferredHandedness;

//Ripped apart system that was previously "alt modes". Dumb, bad, bad idea.
//Anyways, here's some bools you can flick on for mod support reasons.
//Ninja footsteps, custom mesh handling, energy rendering as "armor",
//and just disabling OD in case you have something better to do with it.
var bool bDisableReskin, bEnergyArmor, bSoftenFootsteps, bNoKillswitchEnergyDrain, bNegateOverdose, bUseSharedHealth, bCustomStress;
var travel float ModGroundSpeedMultiplier, ModWaterSpeedMultiplier, ModHealthMultiplier, ModHealingMultiplier,
			ModOrganicVisibilityMultiplier, ModRobotVisibilityMultiplier;

//MADDERS, 12/26/20: New food desc stuff.
var localized string CandyEatenDescs[2], SoyEatenDesc, FishEatenDesc, SodaDrankDescs[5], WaterDrankDesc, WaterWoozyDesc, CigarettesSmokedDesc,
			BeerDrankDesc, WhiskeyDrankDesc, WineDrankDesc, ZymeTakenDesc, MedkitUsedDescs[2],
				MedbotVisitedDesc, AnimalEatenDesc, GrayEatenDesc, OverdoseDescs[3],
			FoodSmellDesc[4], BloodSmellDesc[4], ZymeSmellDesc[2], SmokeSmellDesc[4],
			HungerLevelDesc[7], StressLevelDesc[6],
			EnergyBackfireDesc, KillswitchStateDescs[8],
			RollCooldownDesc, DodgeRollCooldownDesc,
			MsgNoHardwareRecipes, MsgNoHardwareSkill, MsgNoMedicineRecipes, MsgNoMedicineSkill,
			MsgCantCraftUnderwater, MsgAlreadyCrafting;

//MADDERS, 1/18/21: Sound feedback stuff for various effects we run.
var float HeartbeatTimer, LastHeartbeatPitch;

//MADDERS, 3/23/21: Save gate. Let's use the food currency wisely.
//--------------------
//MADDERS, 9/20/22: Suprise, mother fucker.
var(MADDERSDIFF) travel bool bAdvancedLimbDamageEnabled, bAmmoReductionEnabled, bComputerVisibilityEnabled, bDoorNoiseEnabled,
				bKillswitchHealthEnabled, bLootDeletionEnabled, bLootSwapEnabled, bMayhemSystemEnabled, bBountyHuntersEnabled,
				bReloadNoiseEnabled, bSaveGateEnabled, bCameraKillAlarm, bMayhemGrenadesEnabled, bPaulMortalEnabled,
				bWeakGrenadeClimbing, bEternalLaserAlarms, bUseCraftingFatigue;

//Pawn modifiers.
var(MADDERSDIFF) travel bool bSmartEnemyWeaponSwapEnabled, bShootExplosivesEnabled, bNoticeBumpingEnabled,
				bRecognizeMovedObjectsEnabled, bDrawMeleeEnabled, bEnemyDamageGateEnabled,
				bEnemyDisarmExplosivesEnabled, bEnemyGEPLockEnabled, bDogJumpEnabled, bBossDeathmatchEnabled,
				bEnemyVisionExtensionEnabled, bEnemyAlwaysAvoidProj, bEnemyReactKOdDudes, bUseAdvancedMelee;
				//, bSeeLaserEnabled

var(MADDERSDIFF) travel float EnemyROFWeight, EnemyAccuracyMod,
				EnemyReactionSpeedMult, EnemySurprisePeriodMax,
				EnemyHearingRangeMult, EnemyVisionRangeMult, EnemyVisionStrengthMult, EnemyGuessingFudge; 

var(MADDERSDIFF) travel int SaveGateCombatThreshold, SavedMayhemForgiveness, SavedGateBreakThreshold, SavedLootSwapSeverity,
				SavedNakedSolutionReductionRate, SavedNakedSolutionMissionEnd, SavedHunterQuantity, SavedHunterThreshold,
				BarfLootReduction,
				BarfCombatThreshold, BarfStartingMayhem, BarfHunterQuantity, BarfHunterThreshold, BarfMayhemForgiveness, BarfGateBreakThreshold, BarfLootSwapSeverity,
				BarfSaveGateTime,
				BarfROFWeight, BarfAccuracyMod,
				BarfReactionSpeedMult, BarfSurprisePeriodMax, EnemyExtraSearchSteps,
				BarfHearingRangeMult, BarfVisionRangeMult, BarfVisionStrengthMult, BarfGuessingFudge,
				BarfDodgeClickTime, BarfTacticalRollTime;

var(MADDERSDIFF) travel float GallowsSaveGateTimer, GallowsSaveGateTime, TimerDifficulty, EnemyHPScale;

var Music ModSwappedMusic;

//4/17/21: Mutations compatibility, I guess.
var bool Mapon;
var Name PlayerCurrentState;
var vector PlayerCurrentLocation;
Var Rotator PlayerCurrentView;
var Inventory CurrentInHand;

var localized string MutationsMapTip;

//!!!!!!!!!!!!!!!!!!!!!!!!
//12/15/21: CRAFTING!
var travel int CurScrap, CurChemicals;
var int MaxScrap, MaxChemicals;

var travel string LastMedicalBreakdown, LastMechanicalBreakdown;

var localized string MsgScrapAdded, MsgScrapFull, MsgChemicalsAdded, MsgChemicalsFull;

//------------------------
//4/19/22: Camera override!
var Vector VMDLastCameraLoc, OverrideCameraLocation;
var Rotator OverrideCameraRotation;

//05/17/22: Mayhem system. Spicy.
//Produce more enemies the more we kill shit. Because JC becomes infamous, ya' know.
//1 point for KO, 2 points per kill, gallows only system, -50 per mission.
//We count based on carcasses. Ones in darkness count for 1 less, as they are hidden.
//Killing a previously not-dead corpse adds 1 instantly. Gibbing a living dude adds 3.
//Place a VMDMayhemActor when leaving levels to finalize counts, and point it to the carcass in question.
var(VMDMayhem) travel bool bCheckedFirstMayhem;
var(VMDMayhem) travel int MayhemFactor, OwedMayhemFactor, AllureFactor;

var(VMDMayhem) int MayhemGibbingValue, MayhemLivingValue, MayhemDarknessValue, MayhemKilledValue, MayhemKOValue, OwedMayhemFloor, OwedMayhemCap, MayhemCap;

//08/30/22: Drone storage and order system. Spicy.
var string LastDroneOrderTargetName;
var Vector LastDroneOrderLocation;

var Actor LastDroneOrderActor;
var VMDFakeRadarMarker FirstRadarMark;

var localized string StrDroneNameTerrain, MsgNoDroneGrid, MsgDroneCollision;

//9/2/22: TRAVEL VARS ON DRONE!
var travel bool bHadMEGH, bDroneHealthBuffed, bDroneHasHeal, bDroneReconMode, bDroneAutoReload;
var travel int DroneHealth, DroneEMPHitPoints, DroneAmmoLeft,
		DroneWeaponModSilencer, DroneWeaponModScope, DroneWeaponModLaser, DroneWeaponModEvolution;
var travel float DroneWeaponModBaseAccuracy, DroneWeaponModReloadCount, DroneWeaponModAccurateRange,
		DroneWeaponModReloadTime, DroneWeaponModRecoilStrength;
var travel string DroneCustomName, DroneGunClass;

var travel name StoredDroneAlliances[128], StoredDroneHostilities[128]; //Remember all the goods and bads we have.

//11/17/24: Store some given weapon info, as a misc thing.
var travel string LastGenerousWeaponClass;
var travel int LastGenerousWeaponModLaser, LastGenerousWeaponModScope, LastGenerousWeaponModSilencer, LastGenerousWeaponModEvolution;
var travel float LastGenerousWeaponModAccuracy, LastGenerousWeaponModReloadCount, LastGenerousWeaponModAccurateRange,
		LastGenerousWeaponModReloadTime, LastGenerousWeaponModRecoilStrength;

//12/21/23: Misc fix for sticking grenades on shit.
var Mover LastMoverFrobTarget;

//1/5/24: Weird shit for music not fixing on level transfer.
var float BarfMusicFixTimer, MusicFixSkipWindow;
var bool HackPatchedNihilumEnding, bAlarmInfamyAddedThisTick;

//~~~~~~~~~~~~~~~~~~~~~~~~
//DXT ADDITIONS!
//~~~~~~~~~~~~~~~~~~~~~~~~

var localized string CountRemainingString;

// Transcended - Build version
CONST VERSION_MAJOR = 1;
CONST VERSION_MINOR = 5;
CONST VERSION_BUILD = 3;
CONST VERSION_REVISION = 0;
CONST VERSION_TITLE = " - 01/18/21"; 	 	// US version of date MM/DD/YY
CONST VERSION_TITLE_ALT = " - 18/01/21"; 	// EU version of date DD/MM/YY

var globalconfig Bool bVMDUpdateDone; //MADDERS, 3/3/21: Repurposed from DXT.
var globalconfig int	QuickSaveNumber;		// Which was the last slot I quicksaved to?

var(DXTSettings) globalconfig /*int*/ bool bUseAutosave;

var travel bool bCloaked, bRadarCloaked;

var(ItemRefusal) globalconfig int bRefuseWeaponAssaultGun, bRefuseWeaponAssaultShotgun, bRefuseWeaponBaton, bRefuseWeaponCombatKnife, bRefuseWeaponCrowbar, bRefuseWeaponEMPGrenade, bRefuseWeaponFlamethrower, bRefuseWeaponGasGrenade, bRefuseWeaponGEPGun, bRefuseWeaponHideAGun, bRefuseWeaponLAM, bRefuseWeaponLAW, bRefuseWeaponMiniCrossbow, bRefuseWeaponNanoSword, bRefuseWeaponNanoVirusGrenade, bRefuseWeaponPepperGun, bRefuseWeaponPistol, bRefuseWeaponPlasmaRifle, bRefuseWeaponProd, bRefuseWeaponRifle, bRefuseWeaponSawedOffShotgun, bRefuseWeaponShuriken, bRefuseWeaponStealthPistol, bRefuseWeaponSword;

var(ItemRefusal) globalconfig int bRefuseWeaponMod;

var(ItemRefusal) globalconfig int bRefuseAugmentationCannister, bRefuseAugmentationUpgradeCannister, bRefuseBinoculars, bRefuseBioelectricCell, bRefuseCandybar, bRefuseCigarettes, bRefuseVMDCombatStim, bRefuseFireExtinguisher, bRefuseFlare, bRefuseLiquor40oz, bRefuseLiquorBottle, bRefuseMedKit, bRefuseVMDMedigel, bRefuseSodacan, bRefuseSoyFood, bRefuseVialAmbrosia, bRefuseVialCrack, bRefuseWineBottle;

var(ItemRefusal) globalconfig int bRefuseMultitool, bRefuseLockpick, bRefuseVMDChemistrySet, bRefuseVMDToolbox;

var(ItemRefusal) globalconfig int bRefuseAdaptiveArmor, bRefuseBallisticArmor, bRefuseHazMatSuit, bRefuseRebreather, bRefuseTechGoggles;

//MADDERS, 6/21/25: Nihilum guns.
var(ItemRefusal) globalconfig int bRefuseWeaponAssault17, bRefuseWeaponBRGlock, bRefuseWeaponM249DXN, bRefuseWeaponTakaraGun;

var localized string ItemRefusedString;
var localized string TooHotToLift;

var() float dripRate;
var() float waterDripCounter;

var(DXTSettings) globalconfig bool 		bEpilepsyReduction;		// Disable flashing lights?
var(DXTSettings) globalconfig bool 		bAltKeypad; 			// Use a numpad keypad instead of a phone one?
var(DXTSettings) globalconfig bool		bInformationDevices;	// Choose if datacubes or all information devices add info to datavault.
var(DXTSettings) globalconfig bool		bAltSpyDroneView;		// True = Spydrone window is Player's view while player's view is the spydrone. False = original way.
var(DXTSettings) globalconfig bool		bNoAugIdleHumSound;		// Do augmentations play their idle hum sound when active?

var(TransSettings) globalconfig bool	bAISmartWeaponSwap;			// Switch to a different weapon when needing to reload on realistic?
var(TransSettings) globalconfig bool	bAIRecogniseMovedObjects;	// AI recognise when objects have been moved out of place or set on fire on realistic?
var(TransSettings) globalconfig bool	bAILookAtPlayer;			// AI turn their head to look at the player when near?
var(TransSettings) globalconfig bool	bAIReactToLaser;			// AI react to laser dot on realistic difficulty?
var(TransSettings) globalconfig bool	bAIReactToWeapon;			// AI complain if you point a gun at them?
var(TransSettings) globalconfig bool	bAIGEPGunLocking;			// AI able to use the GEP gun lock-on feature on realistic?
var(TransSettings) globalconfig bool	bCamerasSeeBodies;			// Cameras able to see bodies on realistic?
var(TransSettings) globalconfig bool	bAIDropArmedGrenades;		// AI drop armed grenades if they die holding one on realistic?
var(TransSettings) globalconfig bool	bAISmartAiming;				// AI aim for explosive objects around the player on realistic?
var(TransSettings) globalconfig bool	bComputerNoInvisibility;	// Using a computer not make you invisible?
var(TransSettings) globalconfig bool	bEmailSavingOption;			// Add a button to save emails to the datavault?
var(TransSettings) globalconfig bool	bAIDogJumping;				// Allow or remove WeaponDogJump?
var(TransSettings) globalconfig bool	bNoisyObjectUsage;			// Objects make noise when frobbing them to alert AI?
var(TransSettings) globalconfig bool	bAIReactUnconscious;		// Allow the AI to react to bNotDead carcasses?
var(TransSettings) globalconfig bool	bAINonStandardAmmo;			// Allow the AI to use non-primary ammo types if they have been given them?
var(TransSettings) globalconfig bool	bRegenStayOn;			// Allow the AI to use non-primary ammo types if they have been given them?

//=============================================================================
// Deus Ex: Transcended functions
//=============================================================================

function RefreshInvWindow()
{
	DeusExRootWindow(rootWindow).PopWindow();
	ShowInventoryWindow();
}

function string BuildVersionString()
{
	local String verstr;
	verstr = "v" $ VERSION_MAJOR $ "." $ VERSION_MINOR;

	if (VERSION_REVISION!= 0)
	{
		verstr = verstr $ "." $ VERSION_BUILD;
		verstr = verstr $ "." $ VERSION_REVISION;
	}
	else if (VERSION_BUILD != 0)
		verstr = verstr $ "." $ VERSION_BUILD;

	// Transcended - Contained in RFPlayer
	if (bool(GetPropertyText("bUseEUTimestamps")))
	{
		if (VERSION_TITLE_ALT != "")
			verstr = verstr $ VERSION_TITLE_ALT;
		else if (VERSION_TITLE != "")
			verstr = verstr $ VERSION_TITLE;
	}
	else if (VERSION_TITLE != "")
		verstr = verstr $ VERSION_TITLE;

	return verstr;
}

// ----------------------------------------------------------------------
// BuildOptionString()
// ----------------------------------------------------------------------
function string BuildOptionString()
{
	return "?Difficulty=" $ combatDifficulty;
}

// ----------------------------------------------------------------------
// GetWallMaterial()
//
// gets the name of the texture group that we are facing
// Overridden to used fixed TraceTexture.
// ----------------------------------------------------------------------
function name GetWallMaterial(out vector wallNormal)
{
	local int TexFlags;
	local float GrabDist;
	local name TexName, TexGroup;
	local Vector EndTrace, HitLocation, HitNormal;
	local Actor Target;
	local VMDHousingScriptedTexture STex;
	
	if (Physics == PHYS_Falling)
		GrabDist = 3.0;
	else
		GrabDist = 1.5;
	
	EndTrace = Location + (Vector(Rotation) * CollisionRadius * GrabDist);
	foreach TraceTexture(class'Actor', Target, TexName, TexGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}
	
	if ((TexName != '') && (VMDGetHousingScriptedTexCount() > 0))
	{	
		forEach AllObjects(class'VMDHousingScriptedTexture', STex)
		{
			if (STex.Name == TexName)
			{
				if (STex.LastTexGroup != '')
				{
					TexGroup = STex.LastTexGroup;
				}
				break;
			}
		}
	}
	
	wallNormal = HitNormal;
	
	return TexGroup;
}

// ----------------------------------------------------------------------
// GetFloorMaterial()
//
// gets the name of the texture group that we are standing on
// Overridden to used fixed TraceTexture.
// ----------------------------------------------------------------------
function name GetFloorMaterial()
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local VMDHousingScriptedTexture STex;
	
	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
			break;
	}
	if ((TexName != '') && (VMDGetHousingScriptedTexCount() > 0))
	{
		forEach AllObjects(class'VMDHousingScriptedTexture', STex)
		{
			if (STex.Name == TexName)
			{
				if (STex.LastTexGroup != '')
				{
					TexGroup = STex.LastTexGroup;
				}
				break;
			}
		}
	}
	
	return texGroup;
}

// ----------------------------------------------------------------------
// TextureGroupStepSound()
//
// Used for Bsp based footsteps.
// ----------------------------------------------------------------------
simulated function Sound TextureGroupStepSound( out float Volume, out float VolumeMultiplier, Texture Texture, Name TextureGroup )
{
	local float Rnd;
	local bool bSoften;
	
	if (bSoftenFootsteps) bSoften = true;
	
	// Set Volume and VolumeMul first.
	switch ( TextureGroup )
	{
		case 'Metal':
		case 'Ladder':
			VolumeMultiplier = 1.0;
			break;
		case 'Foliage':
		case 'Earth':
			VolumeMultiplier = 0.6;
			break;
		default:
			VolumeMultiplier = 0.7;
			break;
	}

	// Use Texture.FootstepSound if available.
	if ((Texture != None) && (Texture.FootstepSound != None))
		return Texture.FootstepSound;

	Rnd = FRand();
	switch ( TextureGroup )
	{
		case 'Plastic':
			VolumeMultiplier = 0.7;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5)  return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
		break;
		case 'Textile':
		case 'Paper':
			VolumeMultiplier = 0.7;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5)  return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
		break;

		case 'Earth':
			VolumeMultiplier = 0.6;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5)  return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
		break;
		case 'Foliage':
			VolumeMultiplier = 0.6;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5)  return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
		break;

		case 'Metal':
		case 'Ladder':
			if (bSoften)
			{
				volumeMultiplier = 1.0;
				if (rnd < 0.5)
					return Sound'CombatKnifeHitHard';
				else
					return Sound'CombatKnifeHitFlesh';
			}
			else
			{
				VolumeMultiplier = 1.0;
				if (Rnd < 0.25) return Sound'MetalStep1';
				if (Rnd < 0.5)  return Sound'MetalStep2';
				if (Rnd < 0.75) return Sound'MetalStep3';
				else return Sound'MetalStep4';
			}
		break;

		case 'Ceramic':
		case 'Glass':
		case 'Tiles':
			if (bSoften)
			{
				volumeMultiplier = 1.0;
				if (rnd < 0.5)
					return Sound'TileStep3';
				else
					return Sound'TileStep4';
			}
			else
			{
				VolumeMultiplier = 0.7;
				if (Rnd < 0.25) return Sound'TileStep1';
				if (Rnd < 0.5)  return Sound'TileStep2';
				if (Rnd < 0.75) return Sound'TileStep3';
				else return Sound'TileStep4';
			}
		break;

		case 'Wood':
			VolumeMultiplier = 0.7;
			if (Rnd < 0.25) return Sound'WoodStep1';
			if (Rnd < 0.5)  return Sound'WoodStep2';
			if (Rnd < 0.75) return Sound'WoodStep3';
			else return Sound'WoodStep4';
		break;

		case 'Brick':
		case 'Concrete':
		case 'Stone':
		case 'Stucco':
		default:
			if (bSoften)
			{
				volumeMultiplier = 0.7;
				return Sound'CombatKnifeHitSoft';
			}
			else
			{
				VolumeMultiplier = 0.7;
				if (Rnd < 0.25) return Sound'StoneStep1';
				if (Rnd < 0.5)  return Sound'StoneStep2';
				if (Rnd < 0.75) return Sound'StoneStep3';
				else return Sound'StoneStep4';
			}
		break;
	}
}

// ----------------------------------------------------------------------
// CarcassStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------
simulated function Sound CarcassStepSound( out float Volume, out float VolumeMul, DeusExCarcass Carcass )
{
	VolumeMul = 0.5;
	Volume    = 0.5;
	return Sound'KarkianFootstep';
}

// ----------------------------------------------------------------------
// DecorationStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------
simulated function Sound DecorationStepSound( out float Volume, out float VolumeMul, DeusExDecoration Decoration )
{
	if ( Decoration.FragType == None )
	{
		Log( Decoration@"has empty FragType. Report this as a Bug." );
		return Sound'TouchTone11';
	}
	switch ( Decoration.FragType.Name )
	{
		case 'GlassFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Glass' );
		case 'MetalFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Metal' );
		case 'PaperFragment':
			VolumeMul = 0.3;
			Volume    = 1.2;
			return Sound'StallDoorClose';
		case 'PlasticFragment':	return TextureGroupStepSound( Volume, VolumeMul, None, 'Plastic' );
		case 'WoodFragment':		return TextureGroupStepSound( Volume, VolumeMul, None, 'Wood' );
		case 'Rockchip':				return TextureGroupStepSound( Volume, VolumeMul, None, 'Stone' );
		case 'FleshFragment':
			VolumeMul = 0.5;
			Volume    = 0.5;
			return Sound'KarkianFootstep';
		case 'GrassFragment': return TextureGroupStepSound( Volume, VolumeMul, None, 'Foliage' );
		default:
			Log( "Unhandled FragType="$Decoration.FragType.Name$" in GetFootStepGroup() Report this as a Bug." );
			return Sound'TouchTone5';
	}
}

// ----------------------------------------------------------------------
// FallbackStepSound()
// ----------------------------------------------------------------------
simulated function Sound FallbackStepSound( out float Volume, out float VolumeMul )
{
	return TextureGroupStepSound( Volume, VolumeMul, None, 'Brick' );
}

// ----------------------------------------------------------------------
// SwimmingStepSound()
// ----------------------------------------------------------------------
simulated function Sound SwimmingStepSound( out float Volume, out float VolumeMul )
{
	VolumeMul = 0.5;
	if (FRand() < 0.5)
		return Sound'Swimming';
	else
		return Sound'Treading';
}

// ----------------------------------------------------------------------
// WaterStepSound()
// ----------------------------------------------------------------------
simulated function Sound WaterStepSound( out float Volume, out float VolumeMul )
{
	local float Rnd;
	VolumeMul = 1.0;
	Rnd = FRand();
	if (Rnd < 0.33)
		return Sound'WaterStep1';
	if (Rnd < 0.66)
		return Sound'WaterStep2';
	else
		return Sound'WaterStep3';
}

// ----------------------------------------------------------------------
// FootStepSound()
//
// Tries to figure out which footstep sound to use.
//
// Potential Additional Footstep Sounds:
//	* MoverSFX.StallDoorClose
//  * DeusExSounds.KarkianFootstep
//  * DeusExSounds.GreaselFootstep
//  * DeusExSounds.GrayFootstep
// ----------------------------------------------------------------------
simulated function Sound FootStepSound( out float Volume, out float VolumeMul )
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local Texture      Tex;
	local Mover        Mover;
	local DeusExDecoration Decoration;
	local DeusExCarcass    Carcass;
	local float        Rnd;
	
	local VMDWaterLevelActor TAct;
	local VMDHousingScriptedTexture STex;

	Volume	  = 1.0;
	VolumeMul = 1.0;

	// Handle Water
	if ( IsInState('PlayerSwimming') || Physics == PHYS_Swimming )
		return SwimmingStepSound( Volume, VolumeMul );
	if ( FootRegion.Zone.bWaterZone )
		return WaterStepSound( Volume, VolumeMul );

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);

	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((TexName != '') && (VMDGetHousingScriptedTexCount() > 0))
		{
			forEach AllObjects(class'VMDHousingScriptedTexture', STex)
			{
				if (STex.Name == TexName)
				{
					if (STex.LastTexGroup != '')
					{
						TexGroup = STex.LastTexGroup;
					}
					break;
				}
			}
		}
		
		// Vanilla behaviour for Level Geometry.
		if ( target == Level )
		{
			//MADDERS, 11/6/22: Hacktacular. Return a water step sound for custom, scaling water zones, when not totally empty.
			if ((WaterZone(FootRegion.Zone) != None) && (WaterZone(FootRegion.Zone).OwningTrigger != None))
			{
				TAct = WaterZone(FootRegion.Zone).OwningTrigger.WaterLevelActor;
				if ((TAct != None) && (!TAct.bHidden))
				{
					return WaterStepSound(Volume, VolumeMul);
				}
			}
			return TextureGroupStepSound( Volume, VolumeMul, Tex, TexGroup );
		}
		
		// Choose Decoration FootStepSound based on FragType.
		Decoration = DeusExDecoration(target);
		if ( Decoration != None )
			return DecorationStepSound( Volume, VolumeMul, Decoration );

		// Carcass.
		Carcass = DeusExCarcass(target);
		if ( Carcass != None )
			return CarcassStepSound( Volume, VolumeMul, Carcass );

		// Not yet supported.
		// Mover = Mover(target);
		// if ( Mover != None )
			// ;
	}
	return FallbackStepSound( Volume, VolumeMul );
}

// ----------------------------------------------------------------------
// DisableFlashingLights()
//
// Disables all lights on the level when anti-epilepsy setting is changed.
// ----------------------------------------------------------------------
function DisableFlashingLights()
{
	local Light 					light;
	local BarrelFire 				BarrelFire;

	if (bEpilepsyReduction) // Disable all flickering lights.
	{
		foreach AllActors(class'Light', light)
		{
			if (light.LightType == LT_Flicker || light.LightType == LT_Strobe)
			{
				light.LightType = LT_Steady;
				light.bLightChanged = True;
			}
		}

		foreach AllActors(class'BarrelFire', BarrelFire) // These too, just incase.
		{
			BarrelFire.LightType = LT_Steady;
		}
	}
}

state QuickLoading
{
	ignores all;

	function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
	{
	}

	function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
	{
		local vector ViewVect, HitLocation, HitNormal, whiteVec;
		local float ViewDist;
		local actor HitActor;
		local float time;

		ViewActor = Self;
		if (bHidden)
		{
			time = Level.TimeSeconds - FrobTime;
			whiteVec.X = time / 16.0;
			whiteVec.Y = time / 16.0;
			whiteVec.Z = time / 16.0;
			CameraRotation.Pitch = -16384;
			CameraRotation.Yaw = (time * 8192.0) % 65536;
			ViewDist = 32 + time * 32;
			InstantFog = whiteVec;
			InstantFlash = 0.5;
			ViewFlash(1.0);
			ViewVect = vect(0,0,1);
			CameraLocation = Location;
			CameraLocation.Z -= CollisionHeight;
			CameraLocation.Z += (time * 64.0);
		}
	}

	function bool CanStartConversation()
	{
		return False;
	}

	function bool StartConversation(Actor invokeActor, EInvokeMethod invokeMethod, optional Conversation con, optional bool bAvoidState, optional bool bForcePlay)
	{
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
	}

	event PlayerTick( float DeltaTime )
	{
	}

	function PlayerMove(float DeltaTime)
	{
	}

Begin:
	SetCollision(false, false, false);
	bCollideWorld = false;
	SetPhysics(PHYS_Flying);
	FrobTime = Level.TimeSeconds;
	Sleep(0.15);
	QuickLoadConfirmed();
}

function int GetItemRefusalSetting(inventory anItem)
{
	local string className;
	local string checkString;
	local int result;
	
	className = GetItemRefusalName(anItem);
		
	checkString = "bRefuse"$className;
	
	result = int(GetPropertyText(checkString));
		return result;
}

function string GetItemRefusalName(inventory anItem)
{
	local string className;	

	className = string(anItem.Class.Name);
	if (anItem.IsA('WeaponMod'))
	{
		className = "WeaponMod";
	}
	else
	{
		switch(AnItem.Class.Name)
		{
			case 'WeaponDXNGaussGun':
				ClassName = "WeaponPlasmaRifle";
			break;
			case 'WeaponWaltherDXN':
				ClassName = "WeaponBRGlock";
			break;
			case 'WeaponPara17':
				ClassName = "WeaponM249DXN";
			break;
			case 'WeaponA17':
				ClassName = "WeaponAssault17";
			break;
		}
	}
	
	return className;
}

// ----------------------------------------------------------------------
// DripWater()
// ----------------------------------------------------------------------

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	local WaterDrop WD;
	
	if (Human(Self) == None) return;
	
	// Copied from ScriptedPawn::Tick()
	dripRate = FClamp(dripRate, 0.0, 15.0);
	if (Human(Self).dripRate > 0)
	{
		adjustedRate = 1;
		dripPeriod = adjustedRate / FClamp(VSize(Velocity)/512.0, 5, 10);
		waterDripCounter += deltaTime;
		while (waterDripCounter >= dripPeriod)
		{
			vel = 0.1*Velocity;
			vel.Z = 0;
			
			SpawnRotation = rot(0,0,0);
			SpawnRotation.Pitch = 49152;
			
			WaterVector.X = FClamp(FRand(), 0.15, 1.0) * ((Rand(2) * 2) - 1) * CollisionRadius;
			WaterVector.Y = FClamp(FRand(), 0.15, 1.0) * ((Rand(2) * 2) - 1) * CollisionRadius;
			WaterVector.Z = FClamp(FRand(), 0.15, 1.0) * ((Rand(2) * 2) - 1) * CollisionHeight * 0.5;
			//waterVector = VRand() * CollisionRadius;
			
			if (VSize(Velocity) > 2)
			{
				WD = spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			}
			else
			{
				WD = spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			}
			
			//MADDERS, 3/18/21: Because this looks bad when trailing. Thanks.
			if (WD != None)
			{
				WD.Instigator = Self;
				WD.Velocity += Velocity / 2;
			}
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	if (dripRate <= 0)
	{
		dripRate = 0;
		waterDripCounter = 0;
	}
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Deus Ex: Transcended end [HACKZ]
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function VMDPlayDamageGatebreakNoise()
{
	PlaySound(Sound'FleshHit1', SLOT_Interface, 3.0,,, 1.3);
	PlaySound(Sound'FleshHit1', SLOT_Talk, 3.0,,, 1.3);
}

function float VMDGetLeanSpeedMult()
{
	local float Ret, HMult, HFactor;
	
	Ret = 1.5;
	
	if (HasSkillAugment('SwimmingCoreWorkout'))
	{
		Ret *= 2.0;
	}
	
	HMult = 1.0;
	if (KSHealthMult > 0)
	{
		HMult *= KSHealthMult;
	}
	if (ModHealthMultiplier > 0)
	{
		HMult *= ModHealthMultiplier;
	}
	
	HFactor = (HealthLegLeft + HealthLegRight) / ((Default.HealthLegLeft + Default.HealthLegRight) * HMult);
	HFactor = FMax(0.35, HFactor);
	
	Ret *= HFactor;
	
	return Ret;
}

function VMDAttemptAddOwedInfamy(int AddAmount, name Context)
{
	if ((Context == 'Alarm') && (bAlarmInfamyAddedThisTick))
	{
		return;
	}
	
	if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Mayhem"))
	{
		return;
	}
	
	if (AddAmount > 0)
	{
		OwedMayhemFactor += AddAmount;
		if (Context == 'Alarm')
		{
			bAlarmInfamyAddedThisTick = true;
		}
	}
}

simulated function bool VMDMoveDrone( float DeltaTime, Vector loc )
{
	local int i;
	local Vector TExtent, StartPos, EndPos, TVel, HL, HN, MoveMults[7], AntiMults[7];
	local Actor HitAct;
	
	TExtent = vect(1,1,0)*ADrone.Default.CollisionRadius;
	TExtent.Z = ADrone.Default.CollisionHeight;
	
	MoveMults[0] = Vect(1, 1, 1);
	MoveMults[1] = Vect(1, 1, 0);
	MoveMults[2] = Vect(1, 0, 1);
	MoveMults[3] = Vect(0, 1, 1);
	MoveMults[4] = Vect(1, 0, 0);
	MoveMults[5] = Vect(0, 1, 0);
	MoveMults[6] = Vect(0, 0, 1);
	AntiMults[0] = Vect(1.0, 1.0, 1.0);
	AntiMults[1] = Vect(1.0, 1.0, 0.8);
	AntiMults[2] = Vect(1.0, 0.8, 1.0);
	AntiMults[3] = Vect(0.8, 1.0, 1.0);
	AntiMults[4] = Vect(1.0, 0.8, 0.8);
	AntiMults[5] = Vect(0.8, 1.0, 0.8);
	AntiMults[6] = Vect(0.8, 0.8, 1.0);
	for (i=0; i<ArrayCount(MoveMults); i++)
	{
		StartPos = ADrone.Location;
		EndPos = ADrone.Location + (Loc * MoveMults[i] * ADrone.MaxSpeed * DeltaTime);
		
		HitAct = ADrone.Trace(HL, HN, EndPos, StartPos, true, TExtent);
		if ((HitAct != None) && (Pawn(HitAct) == None))
		{
			continue;
		}
		
		// if the wanted velocity is zero, apply drag so we slow down gradually
		if (VSize(loc) == 0)
   		{
      			aDrone.Velocity *= 0.9;
   		}
		if (i > 0)
		{
      			aDrone.Velocity = (ADrone.Velocity * AntiMults[i]) + (deltaTime * aDrone.MaxSpeed * loc * MoveMults[i]);
			return true;
		}
		else
		{
      			aDrone.Velocity += deltaTime * aDrone.MaxSpeed * loc;
		}
		
		if (i == 0)
		{
			// add slight bobbing
   			// DEUS_EX AMSD Only do the bobbing in singleplayer, we want stationary drones stationary.
   			if (Level.Netmode == NM_Standalone)
			{
      				aDrone.Velocity += deltaTime * Sin(Level.TimeSeconds * 2.0) * vect(0,0,1);
			}
			return true;
		}
	}
	
	return false;
}

function bool VMDShouldPutItemOnBelt(Inventory TestItem)
{
	if (TestItem == None) return true;
	
	if (GetItemRefusalSetting(TestItem) != 1 && GetItemRefusalSetting(TestItem) != 4) return true;
	
	if (VMDTransientLevelTime > 0.1) return false;
	
	return true;
}

exec function GetMyPackage()
{
	local string TStr;
	local int InPos;
	
	TStr = string(Class);
	InPos = InStr(TStr, ".");
	if (InPos > -1)
	{
		TStr = Left(TStr, InPos);
	}
	
	ClientMessage(TStr);
}

exec function LogBrushSurfaces()
{
	class'VMDNative.VMDTerrainReskinner'.Static.LogSurfaceTextures(XLevel);
}

exec function TestGetURLMap()
{
	ClientMessage(GetURLMap());
}

function VMDRecordMap(string NewMap)
{
	local int i;
	
	for(i=0; i<ArrayCount(RecordedMaps); i++)
	{
		if (RecordedMaps[i] ~= NewMap)
		{
			return;
		}
	}
	
	for(i=0; i<ArrayCount(RecordedMaps); i++)
	{
		if (RecordedMaps[i] ~= "")
		{
			RecordedMaps[i] = NewMap;
			break;
		}
	}
}

function VMDUnrecordMap(int TarIndex)
{
	local int i;
	
	for(i=TarIndex; i<ArrayCount(RecordedMaps)-1; i++)
	{
		RecordedMaps[i] = RecordedMaps[i+1];
	}
	RecordedMaps[ArrayCount(RecordedMaps)-1] = "";
}

function VMDClearRecordedMapsBefore(int TarMission)
{
	local int i, TMission;
	
	for(i=0; i<ArrayCount(RecordedMaps); i++)
	{
		if (RecordedMaps[i] != "")
		{
			TMission = int(Left(RecordedMaps[i], 2));
			if (TMission < TarMission)
			{
				VMDUnrecordMap(i);
				i -= 1;
			}
		}
	}
}

function bool VMDCanStartFirstPersonConversation()
{
	if ((conPlay != None && conPlay.CanInterrupt() == False) ||
		(conPlay != None && !conPlay.con.bFirstPerson) ||
		 //(( bForceDuck == True ) && ((HealthLegLeft > 0) || (HealthLegRight > 0))) ||
		 ( IsInState('Dying') ) ||
		 //( IsInState('PlayerSwimming') ) ||  
		 ( IsInState('CheatFlying') ) ||
		 //( Physics == PHYS_Falling ) || 
		 ( Level.bPlayersOnly ) ||
	     (!DeusExRootWindow(rootWindow).CanStartConversation()))
		return False;
	else	
		return True;
}

function ClientSetMusic( music NewSong, byte NewSection, byte NewCdTrack, EMusicTransition NewTransition )
{
	//MADDERS, 4/28/25: If we're still fading, brute force
	if (MusicFixSkipWindow > 0)
	{
		NewTransition = MTRAN_Instant;
	}
	
	switch(NewTransition)
	{
		case MTRAN_SlowFade:
			MusicFixSkipWindow = 6.0;
		break;
		case MTRAN_FastFade:
		case MTRAN_Fade:
			MusicFixSkipWindow = 4.0;
		break;
	}
	
	Super.ClientSetMusic(NewSong, NewSection, NewCDTrack, NewTransition);
}

exec function PrintDistanceFromPlayer()
{
	local Pawn TPawn;
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		ClientMessage(TPawn@TPawn.DistanceFromPlayer@TPawn.LastRendered());
	}
}

exec function ShowProp(string NewProp)
{
	local DeusExRootWindow root;
	
	if (!bCheatsEnabled)
		return;
	
	root = DeusExRootWindow(rootWindow);
	if (root != None)
	{
		if (root.actorDisplay != None)
		{
			if (NewProp == "")
			{
				root.actorDisplay.ShowCustomProp(false);
			}
			else
			{
				root.actorDisplay.CustomProp = NewProp;
				root.actorDisplay.ShowCustomProp(true);
			}
		}
	}
}

exec function ModifyPlayerAppearance()
{
	local DeusExRootWindow Root;
	local VMDMenuModifyAppearance StartingWindow;
	
	if (Physics != PHYS_Walking || CollisionHeight < 33 || IsInState('Dying'))
	{
		return;
	}
	
	bBehindView = true;
	bUnlit = true;
	OverrideCameraLocation = Location + (Vect(80, 0, 24) >> Rotation);
	OverrideCameraRotation.Yaw = Rotation.Yaw + 32768;
	OverrideCameraRotation.Pitch = 65536 - 2048;
	
	Root = DeusExRootWindow(RootWindow);
	
  	if (Root != None)
  	{
   		StartingWindow = VMDMenuModifyAppearance(Root.InvokeMenuScreen(Class'VMDMenuModifyAppearance', True));
		
		if (StartingWindow != None)
		{
			StartingWindow.SetCampaignData(CreationCampaign);
		}
  	}
}

exec function TestTargetLostLines()
{
	local float BestDist;
	local VMDBountyHunter THunter, Best;
	
	BestDist = 9999;
	forEach AllActors(class'VMDBountyHunter', THunter)
	{
		if (VSize(THunter.Location - Location) < BestDist)
		{
			Best = THunter;
			BestDist = VSize(THunter.Location - Location);
		}
	}
	
	if (Best != None)
	{
		StartAIBarkConversation(Best, BM_TargetLost);
	}
}

exec function TestGetMultiskin(int TarIndex)
{
	ClientMessage(class'VMDNative.VMDGenericNativeFunctions'.Static.GetArrayPropertyText(Self, "Engine.Actor.Multiskins", TarIndex));
}

exec function TestScriptRedundancy()
{
	ClientMessage(class'VMDNative.VMDGenericNativeFunctions'.Static.TargetScriptsAreEqual("DeusEx.ScriptedPawn.PostBeginPlay", "DeusEx.DeusExPlayer.PostBeginPlay"));
	ClientMessage(class'VMDNative.VMDGenericNativeFunctions'.Static.TargetScriptsAreEqual("DeusEx.ScriptedPawn.PostBeginPlay", "DeusEx.ScriptedPawn.PostBeginPlay"));
}

exec function TestSetMultiskins(int TarIndex, string TextureName)
{
	local DeusExDecoration DXD;
	local Texture TTex;
	
	TTex = Texture(DynamicLoadObject(TextureName, class'Texture', false));
	if (TTex == None)
	{
		ClientMessage("Can't find texture"@TextureName$".");
		return;
	}
	
	foreach AllActors(class'DeusExDecoration', DXD)
	{
		if (!class'VMDNative.VMDGenericNativeFunctions'.Static.SetArrayPropertyText(DXD, "Engine.Actor.Multiskins", TarIndex, string(TTex)))
		{
			ClientMessage("Failed to set on"@DXD);
		}
	}
}

exec function GetTestFileList()
{
	local DeusExRootWindow Root;
	local VMDMenuModLocatorWindow StartingWindow;
	
	Root = DeusExRootWindow(RootWindow);
	
  	if (Root != None)
  	{
   		StartingWindow = VMDMenuModLocatorWindow(Root.InvokeMenuScreen(Class'VMDMenuModLocatorWindow', True));
		
		if (StartingWindow != None)
		{
			StartingWindow.VMP = Self;
			
			StartingWindow.PopulateFileList();
		}
  	}
}

exec function TestPathBullshit()
{
	local Male2 SP;
	
	ConsoleCommand("KillAll HumanCivilian");
	
	SP = Spawn(class'Male2',,, Location + Vector(Rotation) * CollisionRadius * 2.25, Rotation);
	SP.SetOrders('GoingTo', 'ExitGoal', true);
}

//MADDERS, 10/4/24: Shout out to DX rando for this one. Thanks.
// a lot like the vanilla PutCarriedDecorationInHand()
function ForcePutCarriedDecorationInHand()
{
	local vector lookDir, upDir;
	
	if (CarriedDecoration != None)
	{
		lookDir = Vector(Rotation);
		lookDir.Z = 0;
		upDir = vect(0,0,0);
		upDir.Z = CollisionHeight / 2;		// put it up near eye level
		CarriedDecoration.SetPhysics(PHYS_None);
		CarriedDecoration.SetCollision(False, False, False);
		CarriedDecoration.bCollideWorld = False;
		
		if ( CarriedDecoration.SetLocation(Location + upDir + (0.5 * CollisionRadius + CarriedDecoration.CollisionRadius) * lookDir) )
		{
			CarriedDecoration.SetBase(self);
			// make it translucent
			CarriedDecoration.Style = STY_Translucent;
			CarriedDecoration.ScaleGlow = 1.0;
			CarriedDecoration.bUnlit = True;
			
			FrobTarget = None;
		}
		else
		{
			log("ERROR: Why would ForcePutCarriedDecorationInHand() fail? " $ CarriedDecoration);
			CarriedDecoration = None;
		}
	}
}

exec function TestProjectileLocation()
{
	local float TTime, MaxTime, Elasticity, LandingSpeed, Range, TDist;
	local Vector FirstPos, FinalPos, TExtent, FireLoc, SimulatedVelocity, X, Y, Z;
	local CandyBar TBar;
	local DeusExWeapon DXW;
	local SodaCan TCan;
	local class<DeusExProjectile> DXProj;
	local class<ThrownProjectile> ThrownProj;
	
	LandingSpeed = 60;
	DXW = DeusExWeapon(InHand);
	if (DXW == None || class<DeusExProjectile>(DXW.ProjectileClass) == None)
	{
		return;
	}
	
	DXProj = class<DeusExProjectile>(DXW.ProjectileClass);
	ThrownProj = class<ThrownProjectile>(DXProj);
	
	SimulatedVelocity = DXProj.Default.Speed * Vector(ViewRotation);
	if (Region.Zone != None)
	{
		SimulatedVelocity += Region.Zone.ZoneGravity / 60.0;
	}
	
	GetAxes(ViewRotation,X,Y,Z);
	FireLoc = DXW.ComputeProjectileStart(X, Y, Z);
	
	TExtent = vect(1,1,0)*DXProj.Default.CollisionRadius;
	TExtent.Z = DXProj.Default.CollisionHeight;
	
	MaxTime = 2.0;
	if (ThrownProj != None)
	{
		Maxtime = ThrownProj.Default.FuseLength;
	}
	
	Elasticity = 0.2;
	if (ThrownProj != None)
	{
		Elasticity = ThrownProj.Default.Elasticity;
	}
	
	Range = CollisionRadius + 60;
	if (DXProj.Default.bExplodes)
	{
		Range += DXProj.Default.BlastRadius;
	}
	
	ParabolicTrace(FirstPos, SimulatedVelocity, FireLoc, True, TExtent, MaxTime, Elasticity, False, 60);
	TTime = ParabolicTrace(FinalPos, SimulatedVelocity, FireLoc, True, TExtent, MaxTime, Elasticity, DXProj.Default.bBounce, 60);
	if (TTime > 0)
	{
		TDist = VSize(Location - FinalPos);
		TBar = Spawn(Class'CandyBar',,, FirstPos);
		if (TBar != None)
		{
			TBar.SetPhysics(PHYS_None);
		}
		TCan = Spawn(Class'SodaCan',,, FinalPos);
		if (TCan != None)
		{
			TCan.SetPhysics(PHYS_None);
		}
	}
}

/*exec function string TestMapLoadHack()
{
	ClientMessage("FIND ISLAND:"@GetMapName("..\\VMDMapTest\\Maps\\01_NYC_UNATCOIsland", "", 0));
	ClientMessage("FIND HQ:"@GetMapName("..\\VMDMapTest\\Maps\\01_NYC_UNATCOHQ", "", 0));
	ClientMessage("FIND NULL:"@GetMapName("..\\VMDMapTest\\Maps\\NULL", "", 0));
}*/

exec function SpawnTestHunters(name Type, int Amount, name Alliance, name Enemy)
{
	local int i, j;
	local Rotator TRot;
	local Vector TVect;
	local class<VMDBountyHunter> HuntClass;
	local VMDBountyHunter THunt;
	
	switch(Type)
	{
		case 'NSF':
		case 'Terrorist':
			HuntClass = class'NSFMechBountyHunter';
		break;
		case 'MJ12Commando':
		case 'Commando':
		case 'Cyborg':
			HuntClass = class'MJ12CyborgBountyHunter';
		break;
		case 'MJ12Troop':
		case 'Nanoaug':
		case 'Revenant':
			HuntClass = class'MJ12NanoAugBountyHunter';
		break;
		
	}
	
	if (HuntClass == None || Amount < 1) return;
	
	if (Alliance == '') Alliance = 'BountyHunter';
	if (Enemy == '') Enemy = 'Player';
	
	for(i=0; i<Amount; i++)
	{
		for (j=0; j<20; j++)
		{
			TRot.Yaw = Rand(65536);
			TVect = Location + Vector(TRot) * 128;
			TRot = Rotation;
			
			THunt = Spawn(HuntClass,,, TVect, TRot);
			if (THunt != None)
			{
				THunt.AssignedID = i % 3;
				THunt.InitializeBountyHunter(i, Self, 15);
				THunt.Alliance = Alliance;
				THunt.ChangeAlly('Player', 1.0, true);
				THunt.ChangeAlly(Alliance, 1.0, true);
				THunt.ChangeAlly(Enemy, -1.0, true);
				break;
			}
		}
	}
}

exec function TestWarcrimes()
{
	ExecuteWarCrimes(None);
}

exec function PrintCurrentMap()
{
	ClientMessage(class'VMDStaticFunctions'.Static.VMDGetMapName(Self));
}

exec function PrintAllure()
{
	ClientMessage("Current Allure Factor:"@AllureFactor);
}

function ExecuteWarCrimes(Terrorist Terrie)
{
	local int OldMission;
	local string OldConvo;
	local DeusExLevelInfo DXLI;
	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
	
	if (Terrie == None)
	{
		Terrie = Spawn(class'Terrorist',, 'TestMiguel', Location + ((Vect(2.5, 0, 0) * CollisionRadius) >> ViewRotation));
	}
	
	if (Terrie != None)
	{
		OldMission = DXLI.MissionNumber;
		OldConvo = DXLI.ConversationPackage;
		DXLI.ConversationPackage = "DeusExConversations";
		DXLI.MissionNumber = 5;
		Terrie.BindName = "Miguel";
		Terrie.ConBindEvents();
		DXLI.ConversationPackage = OldConvo;
		DXLI.MissionNumber = OldMission;
	}
}

function int VMDShouldDrawCrowbar(DeusExMover DXM)
{
	local float DoorStrength, TThresh;
	local WeaponCrowbar TCrowbar;
	
	if (DXM == None || !DXM.bFrobbable || !DXM.bPickable || DoorFrobLockpick == 0)
	{
		return 0;
	}
	
	TCrowbar = WeaponCrowbar(FindInventoryType(class'WeaponCrowbar'));
	if (TCrowbar == None || class'VMDStaticFunctions'.Static.VMDIsWeaponSensitiveMap(Self))
	{
		return 0;
	}
	
	DoorStrength = DXM.LockStrength;
	if (TCrowbar.VMDHasSkillAugment('TagTeamDoorCrackingMetal'))
	{
		TThresh = TCrowbar.VMDGetBruteForceThresh() + 0.005;
	}
	if ((DXM.VMDIsSoftDoor()) && (TCrowbar.VMDHasSkillAugment('MeleeDoorCrackingWood')))
	{
		TThresh = FMax(TThresh, 0.15 + 0.005);
	}
	
	if (DoorStrength <= TThresh)
	{
		return 2;
	}
}

function int VMDShouldDrawLockpick(DeusExMover DXM)
{
	local int PicksNeeded, NumPicks;
	local float TStrength, PickValue;
	local Lockpick TPick;
	
	if (DXM == None || !DXM.bFrobbable || !DXM.bPickable || DoorFrobLockpick == 0)
	{
		return 0;
	}
	
	if ((DXM.KeyIDNeeded != '') && (DoorFrobLockpick == 1))
	{
		ClientMessage(MsgDontHaveKey);
		return 1;
	}
	
	TStrength = DXM.LockStrength;
	PickValue = 0.1;
	if (SkillSystem != None)
	{
		PickValue = SkillSystem.GetSkillLevelValue(class'SkillLockpicking');
	}
	
	TPick = Lockpick(FindInventoryType(class'Lockpick'));
	if ((TPick != None) && (PickValue > 0))
	{
		NumPicks = TPick.NumCopies;
		PicksNeeded = int((TStrength / PickValue) + 0.9999);
		
		if (NumPicks >= PicksNeeded)
		{
			return 2;
		}
		else
		{
			ClientMessage(SprintF(MsgNeedMorePicks, (PicksNeeded - NumPicks)));
			return 1;
		}
	}
	
	ClientMessage(MsgNoPicks);
	return 1;
}

function int VMDShouldDrawKeyring(DeusExMover DXM)
{
	local NanoKeyRing TRing;
	
	if (DXM == None || !DXM.bFrobbable || DXM.KeyIDNeeded == '' || !bDoorFrobKeyring)
	{
		return 0;
	}
	
	TRing = NanoKeyRing(FindInventoryType(class'NanoKeyRing'));
	if ((TRing != None) && (TRing.HasKey(DXM.KeyIDNeeded)))
	{
		return 2;
	}
	
	if (DoorFrobLockpick < 2 || !DXM.bPickable)
	{
		ClientMessage(MsgDontHaveKey);
		return 1;
	}
	
	return 0;
}

function int VMDShouldDrawMultitool(HackableDevices HD)
{
	local int ToolsNeeded, NumTools, i;
	local float TStrength, ToolValue;
	local name TName;
	local string TStr;
	local Multitool TTool;
	
	if (HD == None || Keypad(HD) != None || !HD.bHackable || !bElectronicsDrawMultitool)
	{
		return 0;
	}
	
	//MADDERS, 7/21/25: Tacticool new native tech can't find this property. What the fuck?
	if ((HD.IsA('HandScanner')) && (FlagBase != None))
	{
		for (i=0; i<9; i++)
		{
			TStr = HD.GetPropertyText("clearanceflag");
			TName = FlagBase.StringToName(TStr);
			if ((TName != '') && (FlagBase.GetBool(TName)))
			{
				return 0;
			}
		}
	}
	
	TStrength = HD.HackStrength;
	ToolValue = 0.1;
	if (SkillSystem != None)
	{
		ToolValue = SkillSystem.GetSkillLevelValue(class'SkillTech');
	}
	
	TTool = Multitool(FindInventoryType(class'Multitool'));
	if (TTool != None)
	{
		NumTools = TTool.NumCopies;
		ToolsNeeded = int((TStrength / ToolValue) + 0.9999);
		
		if (NumTools >= ToolsNeeded)
		{
			return 2;
		}
		else
		{
			ClientMessage(SprintF(MsgNeedMoreTools, (ToolsNeeded - NumTools)));
			return 1;
		}
	}
	
	ClientMessage(MsgNoTools);
	return 1;
}

//---------------------------------
//WCCC, 4/24/24: Shout out to DX Rando gang actually fixing the fucking bug lol, nice try CyberP.
function HandleWalking()
{
	local Decoration TDeco;
	
	TDeco = CarriedDecoration;
	
	Super.HandleWalking();
	
	if ((CarriedDecoration == None) && (TDeco != None))
	{
        	CarriedDecoration = TDeco;
        	PutCarriedDecorationInHand();
	}
}

function int VMDGetMissionNumber()
{
	local DeusExLevelInfo DXLI;
	
	ForEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		return DXLI.MissionNumber;
	}
	
	return 1;
}

function UpdateInHand()
{
	local bool bSwitch;
	
	//sync up clientinhandpending.
	if (inHandPending != inHand)
		ClientInHandPending = inHandPending;
	
   	//DEUS_EX AMSD  Don't let clients do this.
   	if (Role < ROLE_Authority)
      		return;
	
	if (inHand != inHandPending)
	{
		bInHandTransition = True;
		bSwitch = False;
		if (inHand != None)
		{
			// turn it off if it is on
			if ((inHand.bActive) && (!inHand.IsA('ChargedPickup')))
				inHand.Activate();
			
			if (inHand.IsA('SkilledTool'))
			{
				if (inHand.IsInState('Idle'))
            			{
					SkilledTool(inHand).PutDown();
            			}
				else if (inHand.IsInState('Idle2'))
            			{
					bSwitch = True;
            			}
			}
			else if (inHand.IsA('DeusExWeapon'))
			{
				if (inHand.IsInState('Idle') || inHand.IsInState('Reload'))
					DeusExWeapon(inHand).PutDown();
				else if (inHand.IsInState('DownWeapon') && (Weapon == None))
					bSwitch = True;
			}
			else
			{
				bSwitch = True;
			}
		}
		else
		{
			bSwitch = True;
		}
		
		// OK to actually switch?
		if (bSwitch)
		{
			if (!bPlayerHandsEnabled)
			{
				PlayerHandsLevel = 0.0;
			}
			else if (POVCorpse(InHandPending) != None || VMDPOVDeco(InHandPending) != None)
			{
				PlayerHandsLevel = 0.0;
			}
			else if (InHandPending == None)
			{
				PlayerHandsLevel = 0.0;
			}
			
			if (PlayerHandsLevel > 0)
			{
				//MADDERS, 12/23/23: Uh... Do something? Maybe? To be developed...
			}
			else
			{
				SetInHand(inHandPending);
				SelectedItem = inHandPending;
				
				if (inHand != None)
				{
					if (inHand.IsA('SkilledTool'))
					{
						SkilledTool(inHand).BringUp();
					}
					else if (inHand.IsA('DeusExWeapon'))
					{
						SwitchWeapon(DeusExWeapon(inHand).InventoryGroup);
					}
				}
			}
		}
	}
	else
	{
		bInHandTransition = False;
		
		// Added this code because it's now possible to reselect an in-hand
		// item while we're putting it down, so we need to bring it back up...
		
		if (inHand != None)
		{
			// if we put the item away, bring it back up
			if (inHand.IsA('SkilledTool'))
			{
				if (inHand.IsInState('Idle2'))
					SkilledTool(inHand).BringUp();
			}
			else if (inHand.IsA('DeusExWeapon'))
			{
				if (inHand.IsInState('DownWeapon') && (Weapon == None))
					SwitchWeapon(DeusExWeapon(inHand).InventoryGroup);
			}
		}

	}
	
	UpdateCarcassEvent();
}

function int VMDGetHousingScriptedTexCount()
{
	local int TCount;
	local VMDHousingScriptedTexture STex;
	
	if (HousingScriptedTexCount < 0) return -1;
	
	forEach AllObjectS(class'VMDHousingScriptedTexture', STex)
	{
		TCount++;
		break; //Hack. We just need to know they exist.
	}
	
	if (TCount > 0) HousingScriptedTexCount = TCount;
	else HousingScriptedTexCount = -1;
	
	return HousingScriptedTexCount;
}

// check to see if the player can lift a certain decoration taking
// into account his muscle augs
function bool CanPOVBeLifted(VMDPOVDeco Deco)
{
	local float augLevel, maxLift, augMult;
	
	maxLift = 50;
	if (VMDBufferAugmentationManager(AugmentationSystem) != None)
	{
		//MADDERS: Use custom function for this vs drop strength
		AugLevel = VMDBufferAugmentationManager(AugmentationSystem).VMDConfigureDecoLiftMult();
		maxLift *= augLevel;
	}
	
	if (!deco.StoredbPushable || deco.StoredMass > maxLift)
	{
		if (deco.StoredbPushable)
			ClientMessage(TooHeavyToLift);
		else
			ClientMessage(CannotLift);
		
		return False;
	}
	
	return True;
}

function Vector VMDGetLimbOffset(int GetPart)
{
	//local bool TDuck;
	
	//TDuck = (bDuck == 1 || bForceDuck);
	switch(GetPart)
	{
		case 0: //Head
			return (vect(0,0,0.79) * CollisionHeight) >> Rotation;
		break;
		case 1: //Torso
			return vect(0,0,0);
		break;
		case 2: //Left arm
			return (vect(0,-0.36,0) * CollisionRadius) >> Rotation;
		break;
		case 3: //Right arm
			return (vect(0,0.36,0) * CollisionRadius) >> Rotation;
		break;
		case 4: //Left leg
			return (vect(0,-1,0) + vect(0,0,-1)) >> Rotation;
		break;
		case 5: //Right leg
			return (vect(0,1,0) + vect(0,0,-1)) >> Rotation;
		break;
	}
}

function int VMDGetDamageLocation(Vector HitLocation)
{
	local float headOffsetZ, headOffsetY, armOffset;
	local Vector Offset;
	
	headOffsetZ = CollisionHeight * 0.78;
	headOffsetY = CollisionRadius * 0.35;
	armOffset = CollisionRadius * 0.35;
	
	offset = (hitLocation - Location) << Rotation;
	
	if (offset.z > headOffsetZ)
	{
		// narrow the head region
		if (Abs(offset.x) < headOffsetY || Abs(offset.y) < headOffsetY)
		{
			return 0; //Headshot
		}
	}
	else if (offset.z < 0.0)
	{
		if (offset.y > 0.0)
		{
			return 5; //Right leg
		}
		else
		{
			return 4; //Left leg
		}
	}
	else
	{
		if (offset.y > armOffset)
		{
			return 3;//Right arm
		}
		else if (offset.y < -armOffset)
		{
			return 2; //Left arm
		}
		else
		{
			return 1; //Torso
		}
	}
	
	return -1;
}

function Mesh GetHandednessPlayerMesh(out int Hand)
{
	local Mesh Ret;
	
	Hand = PreferredHandedness;
	
	if (VMDDoAdvancedLimbDamage())
	{
		if (Hand == 1)
		{
			if ((HealthArmLeft < 1) && (HealthArmRight > 0))
			{
				Hand = -1;
			}
		}
		else
		{
			if ((HealthArmRight < 1) && (HealthArmLeft > 0))
			{
				Hand = 1;
			}
		}
	}
	
	if ((Hand == 1) && (FabricatedMeshLeft != None))
	{
		Ret = FabricatedMeshLeft;
	}
	else
	{
		Hand = -1;
		Ret = FabricatedMesh;
	}
	
	return Ret;
}

event EncroachedBy( actor Other )
{
	if (VMDMegh(Other) != None)
	{
		VMDMegh(Other).ReturnToItem();
		ClientMessage(MsgDroneCollision);
	}
	else if (Pawn(Other) != None)
	{
		gibbedBy(Other);
	}
}

function VMDMegh FindProperMegh()
{
	local VMDMegh TMegh;
	
	ForEach AllActors(class'VMDMegh', TMegh)
	{
		if ((TMegh != None) && (TMegh.EMPHitPoints > 0))
		{
			return TMegh;
		}
	}
	
	return None;
}

function bool HasAnyMegh()
{
	local Inventory TInv;
	
	if (bHadMEGH)
	{
		return true;
	}
	
	if (FindProperMEGH() != None)
	{
		return true;
	}
	
	for(TInv = Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if (VMDMeghPickup(TInv) != None)
		{
			return true;
		}
	}
	
	return false;
}

function bool VMDUsingBlacklessRenderDevice()
{
	local string GetDevice, GetVal;
	
	GetDevice = CAPS(GetConfig("Engine.Engine", "GameRenderDevice"));
	switch(GetDevice)
	{
		case "D3D10Drv.D3D10RenderDevice":
		case "D3D11Drv.D3D11RenderDevice":
			return true;
		break;
	}
	
	return false;
}

//MADDERS, 11/18/24: Used in M09 script. If we have reason to believe our precaching is gonna lag like crazy, don't flush.
function bool VMDIsFlushGoodIdea()
{
	local string GetDevice;
	
	GetDevice = CAPS(GetConfig("Engine.Engine", "GameRenderDevice"));
	switch(GetDevice)
	{
		case "D3D10Drv.D3D10RenderDevice":
		case "D3D11Drv.D3D11RenderDevice":
			return (!bD3DPrecachingEnabled);
		break;
		default:
			return true;
		break;
	}
}

function bool VMDShouldPackUpDrone()
{
	local string TMap;
	
	TMap = VMDGetMapName();
	if ((FlagBase != None) && (FlagBase.GetBool('TalkedToPaulAfterMessage_Played')) && (FlagBase.GetBool('MS_PlayerCaptured')))
	{
		if ((FlagBase.GetBool('AnnaNavarre_Dead')) && (TMap == "04_NYC_BATTERYPARK"))
		{
			return true;
		}
		return false;
	}
	else
	{
		return true;
	}
}

function VMDClearGenerousWeaponData()
{
	LastGenerousWeaponModSilencer = 0;
	LastGenerousWeaponModScope = 0;
	LastGenerousWeaponModLaser = 0;
	LastGenerousWeaponModEvolution = 0;
	LastGenerousWeaponModAccuracy = 0.000000;
	LastGenerousWeaponModReloadCount = 0.000000;
	LastGenerousWeaponModAccurateRange = 0.000000;
	LastGenerousWeaponModReloadTime = 0.000000;
	LastGenerousWeaponModRecoilStrength = 0.000000;
	LastGenerousWeaponClass = "";
}

function VMDClearDroneData()
{
	bHadMegh = false;
	bDroneHealthBuffed = false;
	bDroneHasHeal = false;
	bDroneReconMode = false;
	bDroneAutoReload = false;
	
	DroneHealth = 0;
	DroneEMPHitPoints = 0;
	DroneAmmoLeft = 0;
	
	DroneWeaponModSilencer = 0;
	DroneWeaponModScope = 0;
	DroneWeaponModLaser = 0;
	DroneWeaponModEvolution = 0;

	DroneWeaponModBaseAccuracy = 0.0;
	DroneWeaponModReloadCount = 0.0;
	DroneWeaponModAccurateRange = 0.0;
	DroneWeaponModReloadTime = 0.0;
	DroneWeaponModRecoilStrength = 0.0;
	
	DroneCustomName = "";
	DroneGunClass = "";
}

function VMDAddDroneAlliance(name NewAlliance)
{
	local int i;
	
	//Step 1: Purge all hostilities. We're friends now.
	for (i=0; i<ArrayCount(StoredDroneHostilities); i++)	
	{
		if (StoredDroneHostilities[i] == NewAlliance)
		{
			StoredDroneHostilities[i] = 'BLANK'; //Hack for travel export.
		}
		else if (StoredDroneHostilities[i] == '')
		{
			break;
		}
	}
	
	//Step 2. Make sure this isn't redundant.
	for(i=0; i<ArrayCount(StoredDroneAlliances); i++)
	{
		if (StoredDroneAlliances[i] == NewAlliance)
		{
			break;
		}
	}
	//Step 3. Apply this to the first open space.
	for(i=0; i<ArrayCount(StoredDroneHostilities); i++)
	{
		if (StoredDroneAlliances[i] == '' || StoredDroneAlliances[i] == 'BLANK')
		{
			StoredDroneAlliances[i] = NewAlliance;
			break;
		}
	}
}

function VMDAddDroneHostility(name NewHostility)
{
	local int i;
	
	//Step 1: Purge all alliances. We're not friends anymore.
	for (i=0; i<ArrayCount(StoredDroneAlliances); i++)	
	{
		if (StoredDroneAlliances[i] == NewHostility)
		{
			StoredDroneAlliances[i] = 'BLANK'; //Hack for travel export.
		}
		else if (StoredDroneAlliances[i] == '')
		{
			break;
		}
	}
	
	//Step 2. Make sure this isn't redundant.
	for(i=0; i<ArrayCount(StoredDroneHostilities); i++)
	{
		if (StoredDroneHostilities[i] == NewHostility)
		{
			return;
		}
	}
	//Step 3. Apply this to the first open space.
	for(i=0; i<ArrayCount(StoredDroneHostilities); i++)
	{
		if (StoredDroneHostilities[i] == '' || StoredDroneHostilities[i] == 'BLANK')
		{
			StoredDroneHostilities[i] = NewHostility;
			break;
		}
	}
}

function int VMDGetDroneAllianceStatus(name TarAlliance)
{
	local int i;
	
	if (TarAlliance == '' || TarAlliance == 'Player' || TarAlliance == 'PlayerDrone')
	{
		return -2;
	}
	
	for(i=0; i<ArrayCount(StoredDroneHostilities); i++)
	{
		if (StoredDroneHostilities[i] == TarAlliance)
		{
			return -1;
		}
	}
	for(i=0; i<ArrayCount(StoredDroneAlliances); i++)
	{
		if (StoredDroneAlliances[i] == TarAlliance)
		{
			return 1;
		}
	}
	
	return 0;
}

function name VMDGetDroneAlliance(int TarIndex)
{
	return StoredDroneAlliances[TarIndex];
}

function name VMDGetDroneHostility(int TarIndex)
{
	return StoredDroneHostilities[TarIndex];
}

function int VMDGetMaxDroneAlliances()
{
	return ArrayCount(StoredDroneAlliances);
}

function int VMDGetMaxDroneHostilities()
{
	return ArrayCount(StoredDroneHostilities);
}

function VMDPackUpDrones()
{
	local bool bArmorTalent;
	local int MaxEMPPoints, MaxHealthPoints;
	
	local VMDMeghPickup InvMegh;
	local VMDMegh Meghs, TMegh;
	local DeusExWeapon DXW;
	
	local VMDFakeDestroyOtherPawn TDest;
	local VMDFakePathNode TPath;
	local VMDFakePatrolPoint TPat;
	
	VMDClearDroneData();
	
	forEach AllActors(class'VMDMeghPickup', InvMegh)
	{
		if (InvMegh.Owner == None)
		{
			InvMegh.Destroy();
		}
	}
	forEach AllActors(class'VMDMegh', Meghs)
	{
		if ((Meghs.EMPHitPoints > 0) && (Meghs.Health > 0) && (!Meghs.IsInState('Disabled')))
		{
			TMegh = Meghs;
		}
		else
		{
			Meghs.Destroy();
		}
	}
	
	forEach AllActors(class'VMDFakeDestroyOtherPawn', TDest)
	{
		TDest.Destroy();
	}
	forEach AllActors(class'VMDFakePathNode', TPath)
	{
		TPath.Destroy();
	}
	forEach AllActors(class'VMDFakePatrolPoint', TPat)
	{
		TPat.Destroy();
	}
	
	if ((TMegh != None) && (VMDShouldPackUpDrone()))
	{
		bHadMegh = true;
		bDroneHealthBuffed = TMegh.bHealthBuffed;
		bDroneHasHeal = TMegh.bHasHeal;
		bDroneReconMode = TMegh.bReconMode;
		bDroneAutoReload = TMegh.bAutoReload;
		
		bArmorTalent = HasSkillAugment('ElectronicsDroneArmor');
		
		if (VMDGetMissionNumber() < 5)
		{
			if (!bArmorTalent)
			{
				MaxHealthPoints = 25;
			}
			else
			{
				MaxHealthPoints = 75;
			}
		}
		else
		{
			if (!bArmorTalent)
			{
				MaxHealthPoints = 50;
			}
			else
			{
				MaxHealthPoints = 150;
			}
		}
		
		MaxEMPPoints = 100;
		if (bArmorTalent)
		{
			MaxEMPPoints += 200;
		}
		
		if (bMayhemSystemEnabled)
		{
			MaxHealthPoints *= 2;
			MaxEMPPoints *= 2;
		}
		
		DroneHealth = Clamp(TMegh.Health, 1, MaxHealthPoints);
		DroneEMPHitPoints = Clamp(TMegh.EMPHitPoints, 1, MaxEMPPoints);
		DroneCustomName = TMegh.CustomName;
		DXW = TMegh.FirstWeapon();
		if (DXW != None)
		{
			DroneGunClass = string(DXW.Class);
			
			if (DXW.AmmoType != None)
			{
				DroneAmmoLeft = DXW.AmmoType.AmmoAmount;
				DXW.AmmoType.Destroy();
			}
			else
			{
				DroneAmmoLeft = 0;
			}
			DroneWeaponModSilencer = int(DXW.bHasSilencer);
			DroneWeaponModScope = int(DXW.bHasScope);
			DroneWeaponModLaser = int(DXW.bHasLaser);
			DroneWeaponModEvolution = int(DXW.bHasEvolution);
			
			DroneWeaponModBaseAccuracy = DXW.ModBaseAccuracy;
			DroneWeaponModReloadCount = DXW.ModReloadCount;
			DroneWeaponModAccurateRange = DXW.ModAccurateRange;
			DroneWeaponModReloadTime = DXW.ModReloadTime;
			DroneWeaponModRecoilStrength = DXW.ModRecoilStrength;
			
			DXW.Destroy();
		}
		
		TMegh.Destroy();
	}
}

function VMDEmergencyPackUpDrones(VMDMegh TMegh)
{
	local DeusExWeapon DXW;
	
	if (TMegh != None)
	{
		bHadMegh = true;
		bDroneHealthBuffed = TMegh.bHealthBuffed;
		bDroneHasHeal = TMegh.bHasHeal;
		bDroneReconMode = TMegh.bReconMode;
		bDroneAutoReload = TMegh.bAutoReload;
		
		DroneHealth = TMegh.Health;
		DroneEMPHitPoints = TMegh.EMPHitPoints;
		DroneCustomName = TMegh.CustomName;
		
		DXW = TMegh.FirstWeapon();
		if (DXW != None)
		{
			DroneGunClass = string(DXW.Class);
			
			if (DXW.AmmoType != None)
			{
				DroneAmmoLeft = DXW.AmmoType.AmmoAmount;
			}
			else
			{
				DroneAmmoLeft = 0;
			}
			DroneWeaponModSilencer = int(DXW.bHasSilencer);
			DroneWeaponModScope = int(DXW.bHasScope);
			DroneWeaponModLaser = int(DXW.bHasLaser);
			DroneWeaponModEvolution = int(DXW.bHasEvolution);
			
			DroneWeaponModBaseAccuracy = DXW.ModBaseAccuracy;
			DroneWeaponModReloadCount = DXW.ModReloadCount;
			DroneWeaponModAccurateRange = DXW.ModAccurateRange;
			DroneWeaponModReloadTime = DXW.ModReloadTime;
			DroneWeaponModRecoilStrength = DXW.ModRecoilStrength;
		}
	}
}

function bool VMDUnpackDrones()
{
	local bool bWon, bArmorTalent;
	local int MissionNumber, MaxHealthPoints, MaxEMPPoints;
	local float Diff;
	local string TName;
	
	local DeusExLevelInfo DXLI;
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local PathNode TNode;
	local VMDMedigel TGel;
	local VMDMeghPickup TMegh2;
	local VMDMegh TMegh;
	
	local class<DeusExWeapon> LDXW;
	
	DXLI = GetLevelInfo();
	if (DXLI != None)
	{
		MissionNumber = DXLI.MissionNumber;
	}
	
	//MADDERS NOTE, 3/1/25: We can't read skill augments yet in TravelPostAccept. Fuck's sake.
	//Instead, don't cap, only set a floor for health values.
	bArmorTalent = HasSkillAugment('ElectronicsDroneArmor');
	
	if (VMDGetMissionNumber() < 5)
	{
		if (!bArmorTalent)
		{
			MaxHealthPoints = 25;
		}
		else
		{
			MaxHealthPoints = 75;
		}
	}
	else
	{
		if (!bArmorTalent)
		{
			MaxHealthPoints = 50;
		}
		else
		{
			MaxHealthPoints = 150;
		}
	}
	
	MaxEMPPoints = 100;
	if (bArmorTalent)
	{
		MaxEMPPoints += 200;
	}
	
	if (bMayhemSystemEnabled)
	{
		MaxHealthPoints *= 2;
		MaxEMPPoints *= 2;
	}
	
	if ((bHadMEGH) && (DroneEMPHitPoints > 0))
	{
		//Huh. 
		if ((MissionNumber == 5) && (FlagBase != None) && (!FlagBase.GetBool('MS_InventoryRemoved')))
		{
			TMegh2 = Spawn(class'VMDMeghPickup',,, vect(-8825, 1231, -116));
			if (TMegh2 != None)
			{
				TMegh2.bDroneHealthBuff = bDroneHealthBuffed;
				TMegh2.bDroneHealing = bDroneHasHeal;
				TMegh2.bDroneReconMode = false;
				TMEgh2.bDroneAutoReload = bDroneAutoReload;
				//TMegh2.DroneHealth = Clamp(DroneHealth, 1, MaxHealthPoints);
				//TMegh2.DroneEMPHealth = Clamp(DroneEMPHitPoints, 1, MaxEMPPoints);
				TMegh2.DroneHealth = Max(1, DroneHealth);
				TMegh2.DroneEMPHealth = DroneEMPHitPoints;
				TMegh2.CustomName = DroneCustomName;
				bWon = true;
			}
			
			if (bDroneHasHeal)
			{
				TGel = Spawn(class'VMDMedigel',,, vect(-8825, 1231, -76));
			}
			
			LDXW = class<DeusExWeapon>(DynamicLoadObject(DroneGunClass, class'Class', true));
			if (LDXW != None)
			{
				DXW = Spawn(LDXW,,, vect(-8825, 1231, -96));
				if (DXW != None)
				{
					DXW.PickupAmmoCount = 0;
					
					if (DroneWeaponModSilencer > 0) DXW.bHasSilencer = true;
					if (DroneWeaponModScope > 0) DXW.bHasScope = true;
					if (DroneWeaponModLaser > 0) DXW.bHasLaser = true;
					
					DXW.ModBaseAccuracy = DroneWeaponModBaseAccuracy;
					if (DXW.BaseAccuracy == 0.0)
					{
						DXW.BaseAccuracy -= DXW.ModBaseAccuracy;
					}
					else
					{
						DXW.BaseAccuracy -= (DXW.Default.BaseAccuracy * DXW.ModBaseAccuracy);
					}
					
					DXW.ModReloadCount = DroneWeaponModReloadCount;
					Diff = Float(DXW.Default.ReloadCount) * DXW.ModReloadCount;
					DXW.ReloadCount += Max(Diff, DXW.ModReloadCount / 0.1);
					
					DXW.ModAccurateRange = DroneWeaponModAccurateRange;
					DXW.RelativeRange += (DXW.Default.RelativeRange * DXW.ModAccurateRange);
					DXW.AccurateRange += (DXW.Default.AccurateRange * DXW.ModAccurateRange);
					
					DXW.ModReloadTime = DroneWeaponModReloadTime;
					DXW.ReloadTime += (DXW.Default.ReloadTime * DXW.ModReloadTime);
					if (DXW.ReloadTime < 0.0) DXW.ReloadTime = 0.0;
					
					DXW.ModRecoilStrength = DroneWeaponModRecoilStrength;
					DXW.RecoilStrength += (DXW.Default.RecoilStrength * DXW.ModRecoilStrength);
					
					if (DroneWeaponModEvolution > 0)
					{
						DXW.bHasEvolution = true;
						DXW.VMDUpdateEvolution();
					}
				}
			}
		}
		else
		{
			TMegh = Spawn(class'VMDMegh',,, Location - ((vect(1.75, 0, 0) * CollisionRadius) >> Rotation));
			if (TMegh == None) TMegh = Spawn(class'VMDMegh',,, Location + ((vect(1.75, 0, 0) * CollisionRadius) >> Rotation));
			if (TMegh == None) TMegh = Spawn(class'VMDMegh',,, Location - ((vect(0, 1.75, 0) * CollisionRadius) >> Rotation));
			if (TMegh == None) TMegh = Spawn(class'VMDMegh',,, Location + ((vect(0, 1.75, 0) * CollisionRadius) >> Rotation));
			if (TMegh == None)
			{
				forEach AllActors(class'PathNode', TNode)
				{
					TMegh = Spawn(class'VMDMegh',,, TNode.Location);
					if (TMegh != None)
					{
						break;
					}
				}
				
				if (TMegh == None)
				{
					Log("WARNING! FAILED TO SPAWN MEGH IN MAP "@class'VMDStaticFunctions'.Static.VMDGetMapName(Self));
				}
			}
			
			if (TMegh != None)
			{
				TMegh.bHealthBuffed = bDroneHealthBuffed;
				TMegh.bHasHeal = bDroneHasHeal;
				
				//TMegh.Health = Clamp(DroneHealth, 1, MaxHealthPoints);
				//TMegh.EMPHitPoints = Clamp(DroneEMPHitPoints, 1, MaxEMPPoints);
				TMegh.Health = Max(1, DroneHealth);				
				TMegh.EMPHitPoints = DroneEMPHitPoints;				
				TMegh.CustomName = DroneCustomName;
				
				TMegh.bReconMode = bDroneReconMode;
				TMegh.bAutoReload = bDroneAutoReload;
				
				//TMegh.UpdateTalentEffects(Self);
				TMegh.bQueueTalentUpdate = true;
				
				LDXW = class<DeusExWeapon>(DynamicLoadObject(DroneGunClass, class'Class', true));
				if (LDXW != None)
				{
					DXW = Spawn(LDXW,,, TMegh.Location);
					if (DXW != None)
					{
						DXA = DeusExAmmo(Spawn(DXW.Default.AmmoName,,, TMegh.Location));
						if (DXA != None)
						{
							DXW.AmmoType = DXA;
							DXA.GiveTo(TMegh);
							DXA.SetBase(TMegh);
							DXA.AmmoAmount = DroneAmmoLeft;
						}
						
						DXW.PickupAmmoCount = 0;
						
						if (DroneWeaponModSilencer > 0) DXW.bHasSilencer = true;
						if (DroneWeaponModScope > 0) DXW.bHasScope = true;
						if (DroneWeaponModLaser > 0) DXW.bHasLaser = true;
						
						DXW.ModBaseAccuracy = DroneWeaponModBaseAccuracy;
						if (DXW.BaseAccuracy == 0.0)
						{
							DXW.BaseAccuracy -= DXW.ModBaseAccuracy;
						}
						else
						{
							DXW.BaseAccuracy -= (DXW.Default.BaseAccuracy * DXW.ModBaseAccuracy);
						}
						
						DXW.ModReloadCount = DroneWeaponModReloadCount;
						Diff = Float(DXW.Default.ReloadCount) * DXW.ModReloadCount;
						DXW.ReloadCount += Max(Diff, DXW.ModReloadCount / 0.1);
						
						DXW.ModAccurateRange = DroneWeaponModAccurateRange;
						DXW.RelativeRange += (DXW.Default.RelativeRange * DXW.ModAccurateRange);
						DXW.AccurateRange += (DXW.Default.AccurateRange * DXW.ModAccurateRange);
						
						DXW.ModReloadTime = DroneWeaponModReloadTime;
						DXW.ReloadTime += (DXW.Default.ReloadTime * DXW.ModReloadTime);
						if (DXW.ReloadTime < 0.0) DXW.ReloadTime = 0.0;
						
						DXW.ModRecoilStrength = DroneWeaponModRecoilStrength;
						DXW.RecoilStrength += (DXW.Default.RecoilStrength * DXW.ModRecoilStrength);
						
						if (DroneWeaponModEvolution > 0)
						{
							DXW.bHasEvolution = true;
							DXW.VMDUpdateEvolution();
						}
						
						DXW.GiveTo(TMegh);
						DXW.SetBase(TMegh);
						
						DXW.VMDSignalPickupUpdate();
					}
				}
				
				TMegh.UpdateWeaponModel();
				
				bWon = true;
			}
		}
		if (bWon)
		{
			VMDClearDroneData();
		}
	}
	
	return bWon;
}

// ----------------------------------------------------------------------
// RenderOverlays()
// render our in-hand object
// ----------------------------------------------------------------------

simulated event RenderOverlays( canvas Canvas )
{
	local VMDFakeRadarMarker TMark;
	
	if (FirstRadarMark != None)
	{
		for(TMark = FirstRadarMark; TMark != None; TMark = TMark.NextMark)
		{
			TMark.RenderOverlays(Canvas);
		}
	}
	
	//MADDERS, 12/23/23: Render this shiat as needed.
	if ((PlayerHands != None) && (!PlayerHands.bDeleteMe) && (PlayerHands.ShouldRenderHands(Self)) && (!PlayerHands.bHideHands))
	{
		PlayerHands.RenderOverlays(Canvas);
	}
	
	Super.RenderOverlays(Canvas);
}

exec function OpenMechanicalCraftingWindow()
{
	local DeusExRootWindow DXRW;
	local RepairBot TBot;
	local PersonaScreenInventory InvScreen;
	local VMDToolbox TBox;
	
	if (RestrictInput()) return;
	
	DXRW = DeusExRootWindow(RootWindow);
	
	if (DXRW == None || DXRW.GetTopWindow() != None)
	{
		return;
	}
	
	TBot = RepairBot(FrobTarget);
	if (TBot != None)
	{
		if (!CanCraftMechanical(True))
		{
			return;
		}
		
		DXRW.UIPauseGame(); //MADDERS, 4/23/15: Hack because we don't have the previous window locking down the bot.
		TBot.VMDInvokeCraftingScreen(DXRW);
	}
	else
	{
		TBox = VMDToolbox(FindInventoryType(class'VMDToolbox'));
		if (TBox != None)
		{
			if (!CanCraftMechanical(True))
			{
				return;
			}
			
			TBox.OpenCraftingWindow(Self);
		}
		else
		{
			if (!CanCraftMechanical(False, False, True)) //Toolbox is not a recipe.
			{
				return;
			}
			
			ShowInventoryWindow();
			InvScreen = PersonaScreenInventory(DXRW.GetTopWindow());
			if ((InvScreen != None) && (InvScreen.WinScrap != None) && (InvScreen.WinScrap.WinIcon != None))
			{
				InvScreen.SelectInventory(InvScreen.WinScrap.WinIcon);
				InvScreen.UpdateMechanicalCraftingDisplay();
			}
		}
	}
}

exec function OpenMedicalCraftingWindow()
{
	local DeusExRootWindow DXRW;
	local MedicalBot TBot;
	local PersonaScreenInventory InvScreen;
	local VMDChemistrySet TSet;
	
	if (RestrictInput()) return;
	
	DXRW = DeusExRootWindow(RootWindow);
	
	if (DXRW == None || DXRW.GetTopWindow() != None)
	{
		return;
	}
	
	TBot = MedicalBot(FrobTarget);
	if (TBot != None)
	{
		if (!CanCraftMedical(True))
		{
			return;
		}
		
		DXRW.UIPauseGame(); //MADDERS, 4/23/15: Hack because we don't have the previous window locking down the bot.
		TBot.VMDInvokeCraftingScreen(DXRW);
	}
	else
	{
		TSet = VMDChemistrySet(FindInventoryType(class'VMDChemistrySet'));
		if (TSet != None)
		{
			if (!CanCraftMedical(True))
			{
				return;
			}
			
			TSet.OpenCraftingWindow(Self);
		}
		else
		{
			if (!CanCraftMedical(False, False, True)) //Chemistry set is not a recipe.
			{
				return;
			}
			
			ShowInventoryWindow();
			InvScreen = PersonaScreenInventory(DXRW.GetTopWindow());
			if ((InvScreen != None) && (InvScreen.WinChemicals != None) && (InvScreen.WinChemicals.WinIcon != None))
			{
				InvScreen.SelectInventory(InvScreen.WinChemicals.WinIcon);
				InvScreen.UpdateMedicalCraftingDisplay();
			}
		}
	}
}

function bool CanCraftMechanical(bool bRequireRecipes, optional bool bNoFeedback, optional bool bNoSkillNameFeedback)
{
	local int i, Wins;
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TType;
	
	if (SkillSystem == None || !bCraftingSystemEnabled)
	{
		return false;
	}
	
	if (bRequireRecipes)
	{
		if (CraftingManager == None || CraftingManager.StatRef == None)
		{
			return false;
		}
		
		CF = CraftingManager.StatRef;
		
		if (CF != None)
		{
			for (i=1; i<ArrayCount(CF.Default.MechanicalItemsGlossary); i++)
			{
				TType = CF.GetMechanicalItemGlossary(i);
				if (TType == None || !DiscoveredItem(TType))
				{
					continue;
				}
				Wins++;
			}
		}
		
		if (Wins <= 0)
		{
			if (!bNoFeedback)
			{
				ClientMessage(MsgNoHardwareRecipes);
			}
			return false;
		}
	}
	
	if ((SkillSystem.GetSkillLevel(class'SkillTech') < 1) && (!IsSpecializedInSkill(class'SkillTech')))
	{
		if ((!bNoFeedback) && (!bNoSkillNameFeedback))
		{
			ClientMessage(MsgNoHardwareSkill);
		}
		return false;
	}
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
	{
		if (!bNoFeedback)
		{
			ClientMessage(MsgCantCraftUnderwater);
		}
		return false;
	}
	if (VMDPlayerIsCrafting(False))
	{
		if (!bNoFeedback)
		{
			ClientMessage(MsgAlreadyCrafting);
		}
		return false;
	}
	return true;
}

function bool CanCraftMedical(bool bRequireRecipes, optional bool bNoFeedback, optional bool bNoSkillNameFeedback)
{
	local int i, Wins;
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TType;
	
	if (SkillSystem == None || !bCraftingSystemEnabled)
	{
		return false;
	}
	
	if (bRequireRecipes)
	{
		if (CraftingManager == None || CraftingManager.StatRef == None)
		{
			return false;
		}
		
		CF = CraftingManager.StatRef;
		
		if (CF != None)
		{
			for (i=1; i<ArrayCount(CF.Default.MedicalItemsGlossary); i++)
			{
				TType = CF.GetMedicalItemGlossary(i);
				if (TType == None || !DiscoveredItem(TType))
				{
					continue;
				}
				Wins++;
			}
		}
		
		if (Wins <= 0)
		{
			if (!bNoFeedback)
			{
				ClientMessage(MsgNoMedicineRecipes);
			}
			return false;
		}
	}
	
	if ((SkillSystem.GetSkillLevel(class'SkillMedicine') < 1) && (!IsSpecializedInSkill(class'SkillMedicine')))
	{
		if ((!bNoFeedback) && (!bNoSkillNameFeedback))
		{
			ClientMessage(MsgNoMedicineSkill);
		}
		return false;
	}
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
	{
		if (!bNoFeedback)
		{
			ClientMessage(MsgCantCraftUnderwater);
		}
		return false;
	}
	if (VMDPlayerIsCrafting(False))
	{
		if (!bNoFeedback)
		{
			ClientMessage(MsgAlreadyCrafting);
		}
		return false;
	}
	return true;
}

exec function OpenControllerAugWindow()
{
 	local DeusExRootWindow Root;
	local VMDMenuAugsSelector TarWindow;
	
	if (RestrictInput()) return;
	
  	Root = DeusExRootWindow(RootWindow);
    	if (Root != None)
  	{
   		TarWindow = VMDMenuAugsSelector(Root.InvokeMenuScreen(Class'VMDMenuAugsSelector', bRealTimeControllerAugs));
		if (TarWindow != None)
		{
			if (LastBrowsedAugPage > -1)
			{
				TarWindow.LoadAugPage(LastBrowsedAugPage);
			}
			if (LastBrowsedAug > -1)
			{
				TarWindow.SelectedAug = LastBrowsedAug;
				TarWindow.UpdateHighlighterPos();
			}
		}
	}
}

exec function OpenControllerHealthWindow()
{
 	local DeusExRootWindow Root;
	local VMDMenuHealthSelector TarWindow;
	
	if (RestrictInput()) return;
	
  	Root = DeusExRootWindow(RootWindow);
    	if (Root != None)
  	{
   		TarWindow = VMDMenuHealthSelector(Root.InvokeMenuScreen(Class'VMDMenuHealthSelector', bRealTimeControllerAugs));
	}
}

//MADDERS, 8/29/22: New drone order command. Cheers.
exec function IssueDroneOrder()
{
	local bool bWon, FlagAlliedPawn, bTerrainStuff;
	local float BestDist, TDist;
	local string OrderTargetName;
	local Vector HitLocation, HitNormal, TraceEnd, TraceStart, OrderLocation;
	
	local Actor HitActor;
	local Computers Comp;
	local DeusExCarcass DXC;
	local DeusExDecoration DXD;
	local DeusExWeapon DXW;
	local NavigationPoint PN, BestPN;
	local ScriptedPawn SP;
	local VMDMegh TMegh;
	local VMDFakePathNode FakePN;
	
	if (RestrictInput()) return;
	
	BestDist = 999;
	TraceStart = Location + vect(0,0,1) * BaseEyeHeight;
	TraceEnd = TraceStart + 4096 * Vector(ViewRotation);
	
	forEach AllActors(class'VMDMegh', TMegh) break;
	
	HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart,true);
	OrderLocation = HitLocation;
	if (HitActor == Level || Mover(HitActor) != None || (DeusExCarcass(HitActor) != None && DeusExCarcass(HitActor).Alliance == ''))
	{
		ForEach RadiusActors(class'DeusExWeapon', DXW, 40, HitLocation)
		{
			if ((!DXW.bHidden) && (DXW.bDisplayableInv) && (TMegh != None) && (TMegh.FirstWeapon() == None || TMegh.VMDMeghCanDropWeapon()) && (TMegh.VMDDroneCanEquipWeapon(DXW)))
			{
				OrderTargetName = DXW.ItemName;
				bWon = InvokeDroneOrderMenu(DXW, OrderLocation, OrderTargetName, 9);
			}
		}
		
		if (!bWon)
		{
			ForEach RadiusActors(class'NavigationPoint', PN, 320, HitLocation)
			{
				TDist = VSize(HitLocation - PN.Location);
				if ((BestPN == None || TDist < BestDist) && (FastTrace(HitLocation, PN.Location)))
				{
					BestPN = PN;
					BestDist = TDist;
				}
			}
			
			bTerrainStuff = true;
			OrderTargetName = StrDroneNameTerrain;
			if (BestPN == None)
			{
				FakePN = Spawn(class'VMDFakePathNode',,, OrderLocation);
				if (FakePN != None)
				{
					bWon = InvokeDroneOrderMenu(FakePN, OrderLocation, OrderTargetName, 0);
				}
			}
			else
			{
				FakePN = Spawn(class'VMDFakePathNode',,, OrderLocation);
				if (FakePN != None)
				{
					bWon = InvokeDroneOrderMenu(FakePN, OrderLocation, OrderTargetName, 1);
				}
				else
				{
					bWon = InvokeDroneOrderMenu(BestPN, OrderLocation, OrderTargetName, 1);
				}
			}
		}
	}
	else if ((ScriptedPawn(HitActor) != None) && (!HitActor.IsA('VMDMEGH')) && (!HitActor.IsA('VMDSIDD')))
	{
		SP = ScriptedPawn(HitActor);
		OrderTargetName = SP.UnfamiliarName;
		
		FlagAlliedPawn = (SP.GetPawnAllianceType(Self) != ALLIANCE_Hostile);
		if (FlagAlliedPawn)
		{
			if (!SP.bInvincible)
			{
				bWon = InvokeDroneOrderMenu(SP, OrderLocation, OrderTargetName, 2);
			}
			else
			{
				bWon = InvokeDroneOrderMenu(SP, OrderLocation, OrderTargetName, 3);
			}
		}
		else if (!SP.bInvincible)
		{
			bWon = InvokeDroneOrderMenu(SP, OrderLocation, OrderTargetName, 4);
		}
	}
	else if ((DeusExCarcass(HitActor) != None) && (DeusExCarcass(HitActor).Alliance != ''))
	{
		DXC = DeusExCarcass(HitActor);
		OrderTargetName = DXC.ItemName;
		
		bWon = InvokeDroneOrderMenu(DXC, OrderLocation, OrderTargetName, 8);
	}
	else if (DeusExDecoration(HitActor) != None)
	{
		DXD = DeusExDecoration(HitActor);
		Comp = Computers(DXD);
		
		OrderTargetName = DXD.ItemName;
		if (!DXD.bHighlight) OrderTargetName = StrDroneNameTerrain;
		
		if (Comp == None)
		{
			if ((!DXD.bInvincible) && (!DXD.bStatic))
			{
				bWon = InvokeDroneOrderMenu(DXD, OrderLocation, OrderTargetName, 5);
			}
			else
			{
				bWon = InvokeDroneOrderMenu(DXD, OrderLocation, OrderTargetName, 6);
			}
		}
		else
		{
			bWon = InvokeDroneOrderMenu(Comp, OrderLocation, OrderTargetName, 7);
		}
	}
	else if (HitActor == None)
	{
		bTerrainStuff = true;
	}
	
	if (bWon)
	{
		PlaySound(Sound'Menu_Activate', SLOT_None);
	}
	else
	{
		if ((bTerrainStuff) && (FindProperMegh() != None))
		{
			ClientMessage(MsgNoDroneGrid);
		}
		PlaySound(Sound'Menu_Slider', SLOT_None);
	}
}

function bool InvokeDroneOrderMenu(Actor OrderAct, Vector OrderLocation, string OrderName, int OrderContext)
{
	local bool bAddRegroup, bAddRecon, bAddStartPatrol;
 	local DeusExRootWindow Root;
	local VMDMenuIssueDroneOrder TarWindow;
	local VMDMegh TMegh;
	local VMDSidd TSidd, UseSidd;
	
	//0: Empty
	//1: Path node
	//2: Allied/Neutral Pawn
	//3: Allied/Neutral Invuln Pawn
	//4: Hostile Pawn
	//5: Breakable Decoration
	//6: Invuln Decoration
	//7: Computer
	//8: Carcass
	//9: Weapon
	
	if (OrderAct == None) return false;
	
	if (Len(OrderName) > 14)
	{
		OrderName = Left(OrderName, 11)$"...";
	}
	
	LastDroneOrderActor = OrderAct;
	LastDroneOrderLocation = OrderLocation;
	LastDroneOrderTargetName = OrderName;
	
	TMegh = FindProperMegh();
	forEach AllActors(class'VMDSidd', TSidd)
	{
		if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			UseSidd = TSidd;
			break;
		}
	}
	
	//No turrets or drones? Don't bother.
	if ((TMegh == None) && (UseSidd == None)) return false;
	
	//If we only have a turret, and the turret can't do anything with the actor, give up.
	if ((TMegh == None) && (OrderContext != 8) && (OrderContext < 2 || OrderContext > 5))
	{
		return false;
	}
	
	if (TMegh != None) // || UseSidd != None
	{
		bAddRecon = true;
	}
	if ((TMegh != None) && (TMegh.GetStateName() != 'MeghFollowing'))
	{
		bAddRegroup = true;
	}
	if ((TMegh != None) && (!TMegh.IsInState('MeghPatrolling')) && (GetClosestPatrolPoint(TMegh) != None))
	{
		bAddStartPatrol = true;
	}
	
  	Root = DeusExRootWindow(RootWindow);
    	if (Root != None)
  	{
		//Set to true for real time ordering.
   		TarWindow = VMDMenuIssueDroneOrder(Root.InvokeMenuScreen(Class'VMDMenuIssueDroneOrder', False));
		
   		if (TarWindow != None)
   		{
			TarWindow.OrderPlayer = Self;
			switch(OrderContext)
			{
				//Empty
				case 0:
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddStartPatrol)
					{
						TarWindow.AddNewOrder("Start Patrol");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Path node
				case 1:
					if (TMegh != None)
					{
						TarWindow.AddNewOrder("Move To");
						TarWindow.AddNewOrder("Add Patrol %s");
					}
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddStartPatrol)
					{
						TarWindow.AddNewOrder("Start Patrol");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Allied/Neutral Pawn
				case 2:
					TarWindow.AddNewOrder("Move To");
					TarWindow.AddNewOrder("Heal");
					TarWindow.AddNewOrder("Guard");
					TarWindow.AddNewOrder("Mark Enemy");
					TarWindow.AddNewOrder("Mark Ally");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Allied/Neutral Invuln Pawn
				case 3:
					TarWindow.AddNewOrder("Move To");
					TarWindow.AddNewOrder("Guard");
					TarWindow.AddNewOrder("Mark Ally");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Hostile Pawn
				case 4:
					TarWindow.AddNewOrder("Move To");
					TarWindow.AddNewOrder("Oppress");
					TarWindow.AddNewOrder("Mark Enemy");
					TarWindow.AddNewOrder("Ignore");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Breakable Decoration
				case 5:
					TarWindow.AddNewOrder("Move To");
					TarWindow.AddNewOrder("Destroy");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddStartPatrol)
					{
						TarWindow.AddNewOrder("Start Patrol");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Invuln Decoration
				case 6:
					TarWindow.AddNewOrder("Move To");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddStartPatrol)
					{
						TarWindow.AddNewOrder("Start Patrol");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Computer
				case 7:
					TarWindow.AddNewOrder("Move To");
					TarWindow.AddNewOrder("Lite Hack");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddStartPatrol)
					{
						TarWindow.AddNewOrder("Start Patrol");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Carcass
				case 8:
					TarWindow.AddNewOrder("Mark Ally");
					TarWindow.AddNewOrder("Mark Enemy");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
				//Weapon
				case 9:
					TarWindow.AddNewOrder("Equip Weapon");
					if (bAddRegroup)
					{
						TarWindow.AddNewOrder("Regroup");
					}
					if (bAddRecon)
					{
						TarWindow.AddNewOrder("Toggle Recon");
					}
					TarWindow.AddNewOrder("Cancel");
				break;
			}
			
			return true;
		}
	}
	
	return false;
}

function VMDFakePatrolPoint GetClosestPatrolPoint(VMDMegh TMegh)
{
	local float BestDist, TDist;
	local VMDFakePatrolPoint BestPat, FakePat;
	
	if (TMegh == None) return None;
	BestDist = 9999;
	
	ForEach AllActors(class'VMDFakePatrolPoint', FakePat)
	{
		if ((FakePat != None) && (FastTrace(FakePat.Location, TMegh.Location)))
		{
			TDist = VSize(FakePat.Location - TMegh.Location);
			if (TDist < BestDist)
			{
				BestDist = TDist;
				BestPat = FakePat;
			}
		}
	}
	
	return BestPat;
}

//MADDERS, 8/29/22: Did we get shot? Yeah? Trigger aggro on our drones.
function VMDTriggerDroneAggro(ScriptedPawn TAggro)
{
	local bool FlagHeal;
	local VMDMegh TMegh;
	local VMDBufferPawn TGuard;
	
	//if (TAggro == None) return;
	
	//MADDERS, 8/30/22: Overhauled: Now use this as a lens for heaing.
	TMegh = FindProperMegh();
	
	if (TMegh != None)
	{
		FlagHeal = ((TMegh.bHasHeal) && (!TMegh.IsInState('HealingOther')) && (!TMegh.IsInState('HealingGuardedOther')));
		if (TMegh.GuardedOther != None)
		{
			if (TAggro != None)
			{
				TMegh.IncreaseAgitation(TAggro, 1.0);
				TMegh.IncreaseAgitation(TAggro, 1.0);
			}
			
			TGuard = TMegh.GuardedOther;
			if ((TGuard.Health < TGuard.StartingHealthValues[6] / 2) && (Robot(TGuard) == None) && (FlagHeal))
			{
				TMegh.MEGHIssueOrder('HealingGuardedOther', TGuard);
			}
			else
			{
				if (TAggro != None)
				{
					TMegh.MEGHIssueOrder('Attacking', TAggro,, true);
				}
			}
		}
		else if (FlagHeal)
		{
			if (HealthTorso < 50 || HealthHead < 50 || (HealthLegLeft < 1 && HealthLegRight < 1) || (HealthArmLeft < 1 || HealthArmRight < 1))
			{
				TMegh.MEGHIssueOrder('HealingOther', Self);
			}
		}
	}
}

//MADDERS, 8/7/23: Let our drone return to following, and break out of healing order, if we heal ourselves adequately before it shows up.
function VMDReevaluateDroneHealing()
{
	local bool FlagHeal;
	local VMDMegh TMegh;
	
	TMegh = FindProperMegh();
	
	if ((TMegh != None) && (TMegh.bHasHeal) && (TMegh.IsInState('HealingOther')) && (TMegh.OrderActor == Self))
	{
		if ((HealthTorso >= 50 && HealthHead >= 50 && (HealthLegLeft >= 1 || HealthLegRight >= 1) && (HealthArmLeft >= 1 || HealthArmRight >= 1)))
		{
			TMegh.MEGHIssueOrder('MEGHFollowing', Self);
		}
	}
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
}

function VMDCountMayhemNodes()
{
	local int CrudeMayhemCalc, AllureCalc;
	local DeusExCarcass DXC;
	local VMDBountyHunterSpawnFlag TFlag;
	local VMDBufferPawn VMBP;
	
	forEach AllActors(class'DeusExCarcass', DXC)
	{
		if (VMDBountyHunterSuperCarcass(DXC) != None)
		{
			if (DXC.bMayhemSuspect)
			{
				AllureFactor = Max(0, AllureFactor - 5);
				OwedMayhemFactor -= MayhemKOValue * 2;
				if (!DXC.bNotDead)
				{
					OwedMayhemFactor -= MayhemKilledValue * 3;
				}
				DXC.bMayhemSuspect = false;
				
				if (DXC.AIGetLightLevel(DXC.Location) < 0.01)
				{
					OwedMayhemFactor += MayhemDarknessValue * 2;
				}
			}
		}
		else
		{
			if (DXC.bMayhemSuspect)
			{
				OwedMayhemFactor += MayhemKOValue;
				if (!DXC.bNotDead)
				{
					OwedMayhemFactor += MayhemKilledValue;
				}
				DXC.bMayhemSuspect = false;
				
				if (DXC.AIGetLightLevel(DXC.Location) < 0.01)
				{
					OwedMayhemFactor -= MayhemDarknessValue;
				}
				
				if (DXC.bMayhemPayback)
				{
					OwedMayhemFactor += MayhemLivingValue;
					DXC.bMayhemPayback = false;
				}
			}
		}
	}
	
	forEach AllActors(class'VMDBufferPawn', VMBP)
	{
		if ((VMBP != None) && (IsntPacifistPawn(VMBP)))
		{
			//Erase bounty hunters on pre travel. We spawn them on travel post accept, is why.
			if (VMDBountyHunter(VMBP) != None)
			{
				VMBP.Destroy();
			}
			else if (SavedMayhemForgiveness < 0)
			{
				VMBP.bAntiMayhemSuspect = true;
				OwedMayhemFactor -= MayhemLivingValue;
			}
		}
	}
	
	//MADDERS, 6/22/24: Killing a bounty hunter keeps bounty hunters gone from that area.
	//I COULD double back on this, but I think this is healthier.
	forEach AllActors(class'VMDBountyHunterSpawnFlag', TFlag)
	{
		if (!TFlag.bDeleteMe)
		{
			TFlag.Destroy();
		}
	}
	
	CrudeMayhemCalc = Max(OwedMayhemFactor, OwedMayhemFloor);
	OwedMayhemFactor = Clamp(OwedMayhemFactor, OwedMayhemFloor, OwedMayhemCap);
	
	//MADDERS, 6/22/24: Excess momentary mayhem bleeds over into allure at a 10:1 ratio.
	if (CrudeMayhemCalc > OwedMayhemFactor)
	{
		AllureCalc = int(float(CrudeMayhemCalc - OwedMayhemFactor) / 10.0);
		AllureFactor += Max(AllureCalc, 0);
	}
}

function bool IsntPacifistPawn(VMDBufferPawn VMBP)
{
	if (VMBP == None) return false;
	
	if (VMBP.bInsignificant || VMBP.bAntiMayhemSuspect || VMBP.GetPawnAllianceType(Self) != ALLIANCE_Hostile)
	{
		return false;
	}
	if ((VMBP.IsA('Robot')) && (VMBP.IsA('MedicalBot') || VMBP.IsA('RepairBot') || VMBP.IsA('CleanerBot')))
	{
		return false;
	}
	if ((VMBP.IsA('Animal')) && (!VMBP.IsA('Doberman')) && (!VMBP.IsA('Greasel')) && (!VMBP.IsA('Gray')) && (!VMBP.IsA('Karkian')))
	{
		return false;
	}
	
	return true;
}

function VMDUpdateMayhemLevel()
{
	local int CrudeMayhemCalc, AllureCalc;
	
	if (MayhemFactor < 0) MayhemFactor = 0;
	
	if (!bCheckedFirstMayhem)
	{
		bCheckedFirstMayhem = true;
		return;
	}
	
	OwedMayhemFactor = Clamp(OwedMayhemFactor, OwedMayhemFloor, OwedMayhemCap);
	
	CrudeMayhemCalc = Max(MayhemFactor + (OwedMayhemFactor + SavedMayhemForgiveness), 0);
	
	MayhemFactor = Clamp(MayhemFactor + (OwedMayhemFactor + SavedMayhemForgiveness), 0, MayhemCap);
	
	//MADDERS, 6/22/24: Excess final mayhem bleeds over into alure at a 5:1 ratio.
	if (CrudeMayhemCalc > MayhemFactor)
	{
		AllureCalc = int((CrudeMayhemCalc - MayhemFactor) / 5.0);
		AllureFactor += Max(0, AllureCalc);
	}
	
	OwedMayhemFactor = 0;
}

function VMDAdvancedRefreshInvWindow(int CraftSelection, int ScrollProgress, VMDScrapMetal LastScrap, VMDChemicals LastChem)
{
	local DeusExRootWindow DXRW;
	local PersonaScreenInventory PSI;
	
	DXRW = DeusExRootWindow(RootWindow);
	if (DXRW != None)
	{
		DXRW.PopWindow();
		ShowInventoryWindow();
		
		PSI = PersonaScreenInventory(DXRW.GetTopWindow());
		if (PSI != None)
		{
			PSI.ChemCrammer = LastChem;
			PSI.ScrapCrammer = LastScrap;
			
			if (CraftSelection > 0)
			{
				if (CraftSelection == 1)
				{
					PSI.UpdateMechanicalCraftingDisplay();
				}
				if (CraftSelection == 2)
				{
					PSI.UpdateMedicalCraftingDisplay();
				}
				PSI.LastScrollPos = ScrollProgress;
				PSI.bTickEnabled = true;
				PSI.bQueuedScrollFix = true;
			}
		}
	}
}

function VMDInvokeToolboxWindow(optional bool bHasRepairBot, optional RepairBot RBot)
{
	local DeusExRootWindow DXRW;
	local VMDMenuCraftingToolboxWindow CTBW;
	
	DXRW = DeusExRootWindow(RootWindow);
	if (DXRW != None)
	{
		DXRW.PopWindow();
		DXRW.InvokeUIScreen(Class'VMDMenuCraftingToolboxWindow', False);
		
		CTBW = VMDMenuCraftingToolboxWindow(DXRW.GetTopWindow());
		if (CTBW != None)
		{
			if (bHasRepairBot)
			{
				CTBW.SetRepairBot(RBot);
			}
			if (RBot != None)
			{
				CTBW.SetRepairBot(RBot);
			}
		}
	}
}

function VMDInvokeChemistrySetWindow()
{
	local DeusExRootWindow DXRW;
	
	DXRW = DeusExRootWindow(RootWindow);
	if (DXRW != None)
	{
		DXRW.PopWindow();
		DXRW.InvokeUIScreen(Class'VMDMenuCraftingChemistrySetWindow', False);
	}
}

function VMDCancelCrafting()
{
	local VMDCraftingAura CA;
	
	CA = VMDCraftingAura(FindInventoryType(class'VMDMechanicalCraftingAura'));
	if (CA == None)
	{
		CA = VMDCraftingAura(FindInventoryType(class'VMDMedicalCraftingAura'));
	}
	if (CA != None)
	{
		CA.VMDCancelCrafting();
	}
}

function VMDCraftingStartCrafting(class<Inventory> CraftTarget, bool bMedical, bool bToolsRequired, optional int QuanMultiplier)
{
	local VMDCraftingAura CA;
	local VMDNonStaticCraftingFunctions CF;
	
	local bool bMedTalent, bHardTalent;
	local int MedSkill, HardSkill, RelLevel;
	local float TimeMult;
	
	if (VMDPlayerIsCrafting(false)) return;
	if (CraftTarget == None) return;
	if (DeusExRootWindow(RootWindow) == None) return;
	if (SkillSystem == None) return;
	if (CraftingManager == None || CraftingManager.StatRef == None) return;
	
	if (QuanMultiplier < 1)
	{
		QuanMultiplier = 1;
	}
	
	CF = CraftingManager.StatRef;
	if ((bMedical) && (CF.GetMedicalItemGlossaryArray(CraftTarget) < 0)) return;
	else if ((!bMedical) && (CF.GetMechanicalItemGlossaryArray(CraftTarget) < 0)) return;
	
	HardSkill = SkillSystem.GetSkillLevel(class'SkillTech');
	MedSkill = SkillSystem.GetSkillLevel(class'SkillMedicine');
	RelLevel = HardSkill;
	if (bMedical) RelLevel = MedSkill;
	
	bHardTalent = HasSkillAugment('ElectronicsCrafting');
	bMedTalent = HasSkillAugment('MedicineCrafting');
	
	if (bMedical)
	{
		CA = Spawn(class'VMDMedicalCraftingAura');
	}
	else
	{
		CA = Spawn(class'VMDMechanicalCraftingAura');
	}
	
	if (CA != None)
	{
		//DeusExRootWindow(RootWindow).PopWindow();
		
		//MADDERS, 5/28/23: Barftacular, but this now determines batch crafting time.
		//Hard-baking root values for now because fuck me old engine.
		TimeMult = 1.0;
		if (RelLevel > 1)
		{
			switch(QuanMultiplier)
			{
				case 1:
				case 2:
					if (RelLevel == 2) TimeMult = 0.63 * QuanMultiplier;
					else TimeMult = 0.595 * QuanMultiplier;
				break;
				case 3:
					if (RelLevel == 2) TimeMult = 1.44;
					else TimeMult = 1.31;
				break;
				case 4:
					if (RelLevel == 2) TimeMult = 1.58;
					else TimeMult = 1.41;
				break;
				case 5:
					if (RelLevel == 2) TimeMult = 1.71;
					else TimeMult = 1.49;
				break;
			}
		}
		else if (RelLevel > 0)
		{
			TimeMult *= Sqrt(QuanMultiplier);
		}
		
		CA.Charge *= TimeMult;
		CA.MaxCharge = CA.Charge;
		CA.bToolsRequired = bToolsRequired;
		
		if (bMedical)
		{
			CA.ComponentCost = CF.GetMedicalItemPrice(CraftTarget) * CF.GetCraftSkillMult(MedSkill, bMedTalent) * QuanMultiplier;
			CA.CraftQuan = CF.GetMedicalItemQuanMade(CraftTarget) * QuanMultiplier;
			
			CA.MatQuanA = CF.GetMedicalItemQuanReq(CraftTarget, 0) * QuanMultiplier;
			CA.MatQuanB = CF.GetMedicalItemQuanReq(CraftTarget, 1) * QuanMultiplier;
			CA.MatQuanC = CF.GetMedicalItemQuanReq(CraftTarget, 2) * QuanMultiplier;
			
			CA.CraftClass = CraftTarget;
			CA.TravelCraftClass = string(CA.CraftClass);
			
			CA.CraftMatA = CF.GetMedicalItemItemReq(CraftTarget, 0);
			CA.CraftMatB = CF.GetMedicalItemItemReq(CraftTarget, 1);
			CA.CraftMatC = CF.GetMedicalItemItemReq(CraftTarget, 2);
			CA.TravelCraftMatA = String(CA.CraftMatA);
			CA.TravelCraftMatB = String(CA.CraftMatB);
			CA.TravelCraftMatC = String(CA.CraftMatC);
		}
		else
		{
			CA.ComponentCost = CF.GetMechanicalItemPrice(CraftTarget) * CF.GetCraftSkillMult(HardSkill, bHardTalent) * QuanMultiplier;
			if ((CraftTarget == class'VMDMEGHPickup') && (HasSkillAugment('ElectronicsDroneArmor')))
			{
				CA.ComponentCost *= 1.5;
			}
			CA.CraftQuan = CF.GetMechanicalItemQuanMade(CraftTarget) * QuanMultiplier;
			
			CA.MatQuanA = CF.GetMechanicalItemQuanReq(CraftTarget, 0) * QuanMultiplier;
			CA.MatQuanB = CF.GetMechanicalItemQuanReq(CraftTarget, 1) * QuanMultiplier;
			CA.MatQuanC = CF.GetMechanicalItemQuanReq(CraftTarget, 2) * QuanMultiplier;
			
			CA.CraftClass = CraftTarget;
			
			CA.CraftMatA = CF.GetMechanicalItemItemReq(CraftTarget, 0);
			CA.CraftMatB = CF.GetMechanicalItemItemReq(CraftTarget, 1);
			CA.CraftMatC = CF.GetMechanicalItemItemReq(CraftTarget, 2);
			CA.TravelCraftMatA = String(CA.CraftMatA);
			CA.TravelCraftMatB = String(CA.CraftMatB);
			CA.TravelCraftMatC = String(CA.CraftMatC);
		}
		CA.Frob(Self, None);
		CA.Activate();
		
		if (bToolsRequired)
		{
			if (bMedical)
			{
				PutInHand(FindInventoryType(class'VMDChemistrySet'));
			}
			else
			{
				PutInHand(FindInventoryType(class'VMDToolbox'));
			}
		}
		else
		{
			//MADDERS, 5/18/22: Stop putting shit in hand redundantly.
			if ((bMedical) && (VMDChemistrySet(InHand) != None))
			{
			}
			else if ((!bMedical) && (VMDToolbox(InHand) != None))
			{
			}
			else
			{
				PutInHand(None);
			}
		}
	}
}

function VMDCraftingStartBreakdown(class<Inventory> BreakdownTarget, int QuantityNeeded, int ComponentGain, bool bMedical, bool bToolsRequired, optional int QuanMultiplier)
{
	local VMDCraftingAura CA;
	
	local int MedSkill, HardSkill, RelLevel;
	local float TimeMult;
	
	if (VMDPlayerIsCrafting(false)) return;
	if (BreakdownTarget == None || ComponentGain < 1) return;
	if (DeusExRootWindow(RootWindow) == None) return;
	if (SkillSystem == None) return;
	
	HardSkill = SkillSystem.GetSkillLevel(class'SkillTech');
	MedSkill = SkillSystem.GetSkillLevel(class'SkillMedicine');
	RelLevel = HardSkill;
	if (bMedical) RelLevel = MedSkill;
	
	if (QuanMultiplier < 1) QuanMultiplier = 1;
	
	if (bMedical)
	{
		CA = Spawn(class'VMDMedicalCraftingAura');
	}
	else
	{
		CA = Spawn(class'VMDMechanicalCraftingAura');
	}
	
	if (CA != None)
	{
		//DeusExRootWindow(RootWindow).PopWindow();
		
		//MADDERS, 5/28/23: Barftacular, but this now determines batch crafting time.
		//Hard-baking root values for now because fuck me old engine.
		TimeMult = 1.0;
		if (RelLevel > 1)
		{
			switch(QuanMultiplier)
			{
				case 1:
				case 2:
					if (RelLevel == 2) TimeMult = 0.63 * QuanMultiplier;
					else TimeMult = 0.595 * QuanMultiplier;
				break;
				case 3:
					if (RelLevel == 2) TimeMult = 1.44;
					else TimeMult = 1.31;
				break;
				case 4:
					if (RelLevel == 2) TimeMult = 1.58;
					else TimeMult = 1.41;
				break;
				case 5:
					if (RelLevel == 2) TimeMult = 1.26;
					else TimeMult = 1.49;
				break;
			}
		}
		else if (RelLevel > 0)
		{
			TimeMult *= Sqrt(QuanMultiplier);
		}
		
		CA.Charge *= TimeMult;
		CA.MaxCharge = CA.Charge;
		CA.bBreakdown = true;
		CA.bToolsRequired = bToolsRequired;
		
		CA.CraftMatA = BreakdownTarget;
		CA.TravelCraftMatA = String(CA.CraftMatA);
		CA.MatQuanA = QuantityNeeded * QuanMultiplier;
		CA.ComponentCost = ComponentGain * QuanMultiplier;
		
		CA.Frob(Self, None);
		CA.Activate();
		
		if (bToolsRequired)
		{
			if (bMedical)
			{
				PutInHand(FindInventoryType(class'VMDChemistrySet'));
			}
			else
			{
				PutInHand(FindInventoryType(class'VMDToolbox'));
			}
		}
		else
		{
			//MADDERS, 5/18/22: Stop putting shit in hand redundantly.
			if ((bMedical) && (VMDChemistrySet(InHand) != None))
			{
			}
			else if ((!bMedical) && (VMDToolbox(InHand) != None))
			{
			}
			else
			{
				PutInHand(None);
			}
		}
	}
}

function bool VMDPlayerIsCrafting(optional bool bIntense)
{
	local VMDCraftingAura CA;
	
	CA = VMDCraftingAura(FindInventoryType(class'VMDMechanicalCraftingAura'));
	if ((CA != None) && (!bIntense || CA.bToolsRequired)) return true;
	
	CA = VMDCraftingAura(FindInventoryType(class'VMDMedicalCraftingAura'));
	if ((CA != None) && (!bIntense || CA.bToolsRequired)) return true;
	
	return false;
}

function bool ShouldUseSkillAugments()
{
	switch(SelectedCampaign)
	{
		case "HiveDays":
			return false;
		break;
	}
	
	if (bSkillAugmentsEnabled) return true;
	
	return false;
}

function SetupCraftingManager(optional bool bOverride)
{
	if (CraftingManager == None || bOverride)
	{
		if (CraftingManager != None) CraftingManager.Destroy();
		CraftingManager = Spawn(class'VMDCraftingManager', Self);
		CraftingManager.SetPlayer(Self);
	}
}

function bool DiscoveredItem(class<Inventory> CheckClass)
{
	if (CraftingManager != None)
	{
		return CraftingManager.DiscoveredItem(CheckClass);
	}
	return false;
}

function MarkItemDiscovered(Inventory TItem)
{
	if (TItem == None) return;
	
	//MADDERS, 5/12/24: NG+ fuckery. Stop discovering items we haven't unlocked legitimately.
	switch(TItem.Class.Name)
	{
		case 'VMDCombatStim':
		case 'VMDMedigel':
		case 'VMDMEGHPickup':
		case 'VMDSIDDPickup':
			return;
		break;
	}
	
	if (CraftingManager != None)
	{
		CraftingManager.MarkItemDiscovered(TItem.Class);
	}
	
	if (DeusExWeapon(TItem) != None)
	{
		if (DeusExWeapon(TItem).AmmoType != None)
		{
			CraftingManager.MarkItemDiscovered(DeusExWeapon(TItem).AmmoType.Class);
		}
		else
		{
			CraftingManager.MarkItemDiscovered(DeusExWeapon(TItem).AmmoName);
		}
		
		if (WeaponGasGrenade(TItem) != None || WeaponEMPGrenade(TItem) != None)
		{
			CraftingManager.MarkItemDiscovered(class'VMDEmptyGrenade');
		}
	}
}

function MarkItemClassDiscovered(class<Inventory> TItem)
{
	if (TItem == None) return;
	
	//MADDERS, 5/12/24: NG+ fuckery. Stop discovering items we haven't unlocked legitimately.
	switch(TItem.Name)
	{
		case 'VMDCombatStim':
		case 'VMDMedigel':
		case 'VMDMEGHPickup':
		case 'VMDSIDDPickup':
			return;
		break;
	}
	
	if (CraftingManager != None)
	{
		CraftingManager.MarkItemDiscovered(TItem);
	}
}

function PlayItemDiscoverySound()
{
	if (IsInState('PlayerWalking') || IsInState('PlayerSwimming'))
	{
		//UPDATE: Don't use this sound anymore. Sounds bad.
		//PlaySound(sound'Menu_Incoming', SLOT_None,,, 255, 1.35);
		PlaySound(sound'LogNoteAdded', SLOT_None,,, 255, 1.35);
	}
}

function AddScrap(int AddAmount, optional bool bOverflow)
{
	local int OldScrap, AmountAdded;
	local VMDScrapMetal TScrap;
	
	OldScrap = CurScrap;
	CurScrap = Clamp(CurScrap+AddAmount, 0, MaxScrap);
	
	AmountAdded = CurScrap - OldScrap;
	
	if (AmountAdded < 1)
	{
		ClientMessage(MsgScrapFull);
	}
	else
	{
		ClientMessage(SprintF(MsgScrapAdded, AmountAdded));
	}
	
	if ((AmountAdded < AddAmount) && (bOverflow))
	{
		TScrap = Spawn(class'VMDScrapMetal',,,Location, Rotation);
		if (TScrap != None)
		{
			TScrap.NumCopies = AddAmount - AmountAdded;
			TScrap.UpdateModel();
		}
	}
}

function AddChemicals(int AddAmount, optional bool bOverflow)
{
	local int OldChemicals, AmountAdded;
	local VMDChemicals TChem;
	
	OldChemicals = CurChemicals;
	CurChemicals = Clamp(CurChemicals+AddAmount, 0, MaxChemicals);
	
	AmountAdded = CurChemicals - OldChemicals;
	
	if (AmountAdded < 1)
	{
		ClientMessage(MsgChemicalsFull);
	}
	else
	{
		ClientMessage(SprintF(MsgChemicalsAdded, AmountAdded));
	}
	
	if ((AmountAdded < AddAmount) && (bOverflow))
	{
		TChem = Spawn(class'VMDChemicals',,,Location, Rotation);
		if (TChem != None)
		{
			TChem.NumCopies = AddAmount - AmountAdded;
			TChem.UpdateModel();
		}
	}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	Super.CalcBehindView(CameraLocation, CameraRotation, Dist);
	
	if (OverrideCameraRotation != rot(0,0,0))
	{
		CameraRotation = OverrideCameraRotation;
	}
	if (OverrideCameraLocation != vect(0,0,0))
	{
		CameraLocation = OverrideCameraLocation;
	}
}

function Vector VMDGetDynamicCameraOffset()
{
	local float AddGap;
	local Vector Ret;
	
	//WCCC, 5/22/19: Fix pointed out by Kaiser & DefaultPlayer.
	//Pivot the viewpoint slightly forward of our rotation, like a real view.
	AddGap = 5;
	
	//Gnarly hack. If JC is bigger (for some reason) scale the offset, too.
	AddGap *= (CollisionRadius / Default.CollisionRadius);
	
	//wCCC, 4/27/25: Don't do Z axis. It comes out bad.
	Ret = Vector(ViewRotation) * AddGap;
	Ret.Z = 0;
	
	return Ret;
}

event PlayerCalcView( out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local float AddGap;
	local Rotator RollMod;
	local Vector AddVect;
	
	// check for spy drone and freeze player's view
	if (bSpyDroneActive)
	{
		if (aDrone != None)
		{
			// First-person view.			
			if (bAltSpyDroneView) // Spydrone is big view, player view is small window.
			{
				CameraLocation = aDrone.Location;
				CameraRotation = aDrone.Rotation;
				// Required to make JC appear in the main view.
				bBehindView = True;
			}
			else // Player view is main view, spydrone is small box.
			{
				CameraLocation = Location;
				CameraLocation.Z += EyeHeight;
				CameraLocation += WalkBob;
			}
		}
	}
	
	// Check if we're in first-person view or third-person.  If we're in first-person then
	// we'll just render the normal camera view.  Otherwise we want to place the camera
	// as directed by the conPlay.cameraInfo object.
	
	if (bBehindView && (!InConversation()))
	{
		Super(PlayerPawnExt).PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
		return;
	}
	
	if ((!InConversation()) || ((conPlay != None) && (conPlay.GetDisplayMode() == DM_FirstPerson)))
	{
		if ((RollTimer > 0) && (bRealisticRollCamera > 1))
		{
			RollMod.Pitch = -65536 * RollDir * (1.0 - (RollTimer / RollDuration));
		}
		else if ((DodgeRollTimer > 0) && (bRealisticRollCamera % 2 == 1))
		{
			if (Abs(VMDDodgeDir) < 2)
			{
				RollMod.Pitch = -65536 * 2 * VMDDodgeDir * (1.0 - (DodgeRollTimer / DodgeRollDuration));
			}
			else
			{
				//Remember: Sideways is 2, so don't double speed.
				RollMod.Roll = -65536 * 2 * (VMDDodgeDir * 0.5) * (1.0 - (DodgeRollTimer / DodgeRollDuration));
			}
		}
		VMDRollModifier = RollMod;
		
		// First-person view.
		ViewActor = Self;
		CameraRotation = ViewRotation + RollMod;
		CameraLocation = Location;
		CameraLocation.Z += EyeHeight;
		CameraLocation += WalkBob;
		
		if (OverrideCameraRotation != rot(0,0,0))
		{
			CameraRotation = OverrideCameraRotation;
		}
		if (OverrideCameraLocation != vect(0,0,0))
		{
			CameraLocation = OverrideCameraLocation;
			return;
		}
		else if (bUseDynamicCamera)
		{
			CameraLocation += VMDGetDynamicCameraOffset();
			VMDLastCameraLoc = CameraLocation;
			return;
		}
	}
	
	// Allow the ConCamera object to calculate the camera position and 
	// rotation for us (in other words, take this sloppy routine and 
	// hide it elsewhere).
	
	if (conPlay == None || conPlay.CameraInfo == None || conPlay.cameraInfo.CalculateCameraPosition(ViewActor, CameraLocation, CameraRotation) == False)
		Super(PlayerPawnExt).PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
}

function bool VMDDoAdvancedLimbDamage()
{
	//MADDERS, 7/24/23: 
	//bAdvancedLimbDamage || 
	return (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Advanced Limb Damage"));
}

function VMDDisarmPlayer(bool bRightHand)
{
	local float GSpeed;
	local int THand, RemoveAmount;
	local DeusExWeapon DXW, DWP, TarDXW, SpawnWep;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	DXW = DeusExWeapon(InHand);
	if (DXW != None)
	{
		DWP = DXW.DualWieldPartner;
	}
	
	if ((DXW != None) && ((DXW.GetHandType() == -1) == bRightHand))
	{
		TarDXW = DXW;
	}
	else if ((DWP != None) && ((DWP.GetHandType() == -1) == bRightHand))
	{
		TarDXW = DWP;
	}
	
	if (TarDXW != None)
	{
		if (TarDXW.VMDIsWeaponName("Shuriken"))
		{
			if (TarDXW.AmmoType != None)
			{
				RemoveAmount = Min(TarDXW.AmmoType.AmmoAmount, Rand(3) + 1);
				
				SpawnWep = Spawn(TarDXW.Class,,, Location);
				if (SpawnWep != None)
				{
					SpawnWep.PickupAmmoCount = RemoveAmount;
					TarDXW.AmmoType.AmmoAmount -= RemoveAmount;
					if (TarDXW.AmmoType.AmmoAmount <= 0)
					{
						TarDXW.Destroy();
					}
				}
			}
		}
		else
		{
			if (TarDXW.bZoomed)
			{
				TarDXW.ScopeOff();
			}
			if (TarDXW.bHasLaser)
			{
				TarDXW.LaserOff();
			}
			
			if (TarDXW == InHand)
			{
				if (DWP != None)
				{
					PutInHand(DWP);
					TarDXW.DualWieldPartner = None;
					DWP.bDualWieldSlave = False;
					TarDXW.DropFrom(Location);
				}
				else
				{
					TarDXW.DropFrom(Location);
					PutInHand(None);
					SetInHandPending(None);
				}
			}
			else
			{
				TarDXW.DropFrom(Location);
			}
			PlaySound(sound'ArmorRicochet', SLOT_None,,,, 1.37 * GSpeed);
		}
	}
}

exec function ToggleFiringMode()
{
	if (RestrictInput())
		return;
	
	if (DeusExWeapon(Weapon) != None)
	{
		DeusExWeapon(Weapon).VMDChangeFiringMode();
	}
}

//MADDERS, 4/17/21: Mutations map function support.
exec function ShowMap()
{
	if (Inconversation())
		Return;
	else if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		PlaySound(sound'Menu_OK',, 255);
		ClientMessage("MAP NOT AVAILABLE WHILE SWIMMING!!");
		Return;
	}
	
	Getmap();
}

function GetMap()
{
	local Vector SymbolLocation;
	local DeusExLevelInfo info;
	local PoolBall B;
	local CameraPoint CP;
	local float MapCenter_X, MapCenter_Y, Level_CX, Level_CY, Zconstant;
	local Float Scale_X, Scale_Y , Level_Xlength, Level_Ylength, MapTop, MapRight;
	
	if (!(DatalinkID ~= "Mutations")) return;
	info = GetLevelInfo();
	
	if (Info == None) return;
	
	if ((info.MissionNumber != 70) && (info.MissionNumber != 71))
   	{
   		PlaySound(sound'Menu_OK',, 255);
   		ClientMessage("NO MAP AVAILABLE FOR THIS LEVEL");
   		Return;
   	}
   	
	if (info.MissionNumber == 70)
   	{
		//map512
		Level_Ylength = 7440;
		Level_Xlength = 8136;
      		Level_CX = 4352; // X center of level
   		Level_CY = 4324; // Y center of level
   		MapCenter_X = 8192 + 30; //x center of scaled map
   		MapCenter_Y = 1792 + 30; //y center of scaled map
  		Scale_X = 436/Level_Xlength * 1.20;
  		Scale_Y= 446/Level_Ylength;
		
   		ZConstant = -769;
   		MapTop = 7974;
   		MapRight = 1573;
   	}
	else if (info.MissionNumber == 71)
   	{
   		//Map 512
   		Level_Xlength = 8336;
   		Level_Ylength = 7936;
   		Level_CX = 4224; // X center of level
   		Level_CY = 4926; // Y center of level
   		MapCenter_X = 3684 + 10; //x center of scaled map + fudge
   		MapCenter_Y = 382 - 10; //y center of scaled map + fudge
		
   		Zconstant = -204;
   		Scale_X = 424/Level_Xlength;
   		Scale_Y= 449/Level_Ylength;
   		MapTop = 3896;
   	}
	
    	if (!mapOn)
        {
		//Save player current status
           	PlayerCurrentLocation = location;
           	PlayerCurrentView = ViewRotation;
		CurrentInHand = InHand;
            	PutInHand(None);
           	SetInHandPending(none);
           	PlayerCurrentState = getstatename();
		
		//Position map symbol
		SymbolLocation.z = Zconstant; //Constant Z
		
                SymbolLocation.y = MapCenter_Y + ( Location.y - Level_CY ) * Scale_Y; //scale y
		
               	if (info.MissionNumber == 70) //Fudge Y value for map 70
			SymbolLocation.y = SymbolLocation.y - ((0.0165 * (MapRight - SymbolLocation.y)) * (0.0165 * (MapRight -SymbolLocation.y)));
		
		SymbolLocation.x = MapCenter_X + ( Location.x - Level_CX) * Scale_X ; //scale x

		if (info.MissionNumber == 71) //Fudge the x value for map 71
			SymbolLocation.x = SymbolLocation.x - ((0.013 * (MapTop - SymbolLocation.x)) * (0.013 * (MapTop - SymbolLocation.x)));
		
                foreach allactors(Class'PoolBall',B, 'LocateSymbol')
			break;
		
		if ( B != none)
			B.SetLocation(symbolLocation); //set position
		
		//Activate Cam
		foreach allactors(Class'CameraPoint',CP,'MyCam')
			break;
 		if (CP != none)
		{
			CP.GotoState('Running', 'Begin');
			GotoState('Paralyzed');
          	}
		
		MapOn = !MapOn;
	}
    	else
        {
		//Deactivate cam	
		foreach allactors(Class'CameraPoint',CP,'MyCam')
			break;
		if (CP != none)
		{	
                    	CP.GotoState('Idle', 'Wait');
		}
		
		//Restore some Player attributes
				
		bdetectable = true;
	        SetLocation(PlayercurrentLocation);
               	ViewRotation = PlayerCurrentView;
                GotoState(PlayerCurrentState);
		
		ShowHud(True);
		if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).AugDisplay != None))
		{
			DeusExRootWindow(RootWindow).AugDisplay.Show();
		}
		
		if (CurrentInHand != None)
		{
                	PutInHand(CurrentInHand);
		}
			
   		Mapon = !Mapon;
	}
}

function bool VMDIsBurdenPlayer()
{
	if (IsA('BurdenPeterKent')) return true;
	if (DatalinkID ~= "Burden") return true;
	
	return false;
}

function bool VMDUseGallowsModifiers()
{
	if (CombatDifficulty > 6.0)
	{
		return true;
	}
	return false;
}

function bool VMDUseNightmareModifiers()
{
	if (CombatDifficulty > 4.0)
	{
		return true;
	}
	return false;
}

function StartPoison( Pawn poisoner, int Damage )
{
	Super.StartPoison(Poisoner, Damage);
	
	VMDGiveBuffType(class'PoisonEffectAura', 8 * 40.0);
}

function StopPoison()
{
	local PoisonEffectAura PEA;
	
	Super.StopPoison();
	
	PEA = PoisonEffectAura(FindInventoryType(class'PoisonEffectAura'));
	if (PEA != None)
	{
		PEA.UsedUp();
	}
}

function bool VMDHasBuffType(class<VMDFakeBuffAura> BuffType)
{
	return bool(FindInventoryType(BuffType));
}

function VMDFakeBuffAura VMDGiveBuffType(class<VMDFakeBuffAura> BuffType, float SuggestedDuration, optional bool bNoSpawn)
{
	local VMDFakeBuffAura TBuff;
	
	TBuff = VMDFakeBuffAura(FindInventoryType(BuffType));
	if ((TBuff == None) && (!bNospawn))
	{
		TBuff = Spawn(BuffType);
		if (TBuff != None)
		{
			TBuff.Frob(Self, None);
			TBuff.Activate();
		}
	}
	if (TBuff != None)
	{
		TBuff.Charge = SuggestedDuration;
	}
	
	return TBuff;
}

function bool VMDHasForwardPressureObjection()
{
	//MADDERS, 9/16/22: Don't run this if we're fixing some bullshit in console.
	if ((Player != None) && (Player.Console != None) && (Player.Console.IsInState('Typing'))) return false;
	
	if (DatalinkPlay != None) return true;
	if (InformationDevices(FrobTarget) != None) return true;
	if (ActiveComputer != None) return true;
	if (IsInState('Conversation')) return true;
	
	return false;
}

exec function SetMusicTrack(byte NewTrack)
{
	ClientSetMusic(Level.Song, NewTrack, 255, MTRAN_Fade);
}

function UpdateDynamicMusic(float deltaTime)
{
	local bool bCombat;
	local ScriptedPawn npc;
   	local Pawn CurPawn;
	local DeusExLevelInfo info;
	
	if (ModSwappedMusic == None)
	{
		ModSwappedMusic = Level.Song;
	}
	
	if (ModSwappedMusic == None)
		return;
	
   	// DEUS_EX AMSD In singleplayer, do the old thing.
   	// In multiplayer, we can come out of dying.
   	if (!PlayerIsClient())
   	{
      		if ((musicMode == MUS_Dying) || (musicMode == MUS_Outro))
         		return;
   	}
   	else
   	{
      		if (musicMode == MUS_Outro)
         		return;
   	}
	
	musicCheckTimer += deltaTime;
	musicChangeTimer += deltaTime;
	
	if (IsInState('Interpolating'))
	{
		// don't mess with the music on any of the intro maps
		info = GetLevelInfo();
		if ((info != None) && (info.MissionNumber < 0))
		{
			musicMode = MUS_Outro;
			return;
		}
		
		if (musicMode != MUS_Outro)
		{
			ClientSetMusic(ModSwappedMusic, 5, 255, MTRAN_FastFade);
			musicMode = MUS_Outro;
		}
	}
	else if (IsInState('Conversation'))
	{
		if (!VMDIsBurdenPlayer())
		{
			if (musicMode != MUS_Conversation)
			{
				// save our place in the ambient track
				if (musicMode == MUS_Ambient)
					savedSection = SongSection;
				else
					savedSection = 255;
				
				ClientSetMusic(ModSwappedMusic, 4, 255, MTRAN_Fade);
				musicMode = MUS_Conversation;
			}
		}
	}
	else if (IsInState('Dying'))
	{
		if (musicMode != MUS_Dying)
		{
			ClientSetMusic(ModSwappedMusic, 1, 255, MTRAN_Fade);
			musicMode = MUS_Dying;
		}
	}
	else
	{
		// only check for combat music every second
		if (musicCheckTimer >= 1.0)
		{
			musicCheckTimer = 0.0;
			bCombat = False;
			
			// check a 100 foot radius around me for combat
         		// XXXDEUS_EX AMSD Slow Pawn Iterator
         		//foreach RadiusActors(class'ScriptedPawn', npc, 1600)
        		for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
         		{
            			npc = ScriptedPawn(CurPawn);
            			if ((npc != None) && (VSize(npc.Location - Location) < (1600 + npc.CollisionRadius)))
            			{
               				if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == Self))
               				{
                  				bCombat = True;
                  				break;
               				}
            			}
         		}
			
			if (bCombat)
			{
				if (!VMDIsBurdenPlayer())
				{
					musicChangeTimer = 0.0;
					
					if (musicMode != MUS_Combat)
					{
						// save our place in the ambient track
						if (musicMode == MUS_Ambient)
							savedSection = SongSection;
						else
							savedSection = 255;
						
						ClientSetMusic(ModSwappedMusic, 3, 255, MTRAN_FastFade);
						musicMode = MUS_Combat;
					}
				}
			}
			else if (musicMode != MUS_Ambient)
			{
				if (!VMDIsBurdenPlayer())
				{
					// wait until we've been out of combat for 5 seconds before switching music
					if (musicChangeTimer >= 5.0)
					{
						// use the default ambient section for this map
						if (savedSection == 255)
							savedSection = Level.SongSection;
						
						// fade slower for combat transitions
						if (musicMode == MUS_Combat)
							ClientSetMusic(ModSwappedMusic, savedSection, 255, MTRAN_SlowFade);
						else
							ClientSetMusic(ModSwappedMusic, savedSection, 255, MTRAN_Fade);
						
						savedSection = 255;
						musicMode = MUS_Ambient;
						musicChangeTimer = 0.0;
					}
				}
			}
		}
	}
}

function bool VMDPlayerIsCloaked()
{
	local AugmentationManager AM;
	
	if (bHidden) return true;
	
	AM = AugmentationSystem;
	if (Style == STY_Translucent)
	{
		if (Default.Style != STY_Translucent) return true;
		else if ((AM != None) && (AM.GetAugLevelValue(class'AugCloak') != -1.0 || AM.GetAugLevelValue(class'AugMechCloak') != -1.0)) return true;
		else if (UsingChargedPickup(class'AdaptiveArmor')) return true;
	}
	return false;
}

function bool VMDPlayerIsRadarTrans()
{
	local AugmentationManager AM;
	
	if (bHidden) return true;
	
	AM = AugmentationSystem;
	
	if ((AM != None) && (AM.GetAugLevelValue(class'AugRadarTrans') != -1.0)) return true;
	else if (UsingChargedPickup(class'AdaptiveArmor')) return true;
	
	return false;
}

function bool VMDIsInHandZoomed()
{
	if ((DeusExWeapon(InHand) != None) && (DeusExWeapon(InHand).bZoomed))
	{
		return true;
	}
	if ((Binoculars(InHand) != None) && (Binoculars(InHand).IsInState('Activated')))
	{
		return true;
	}
	
	return false;
}

function VMDResetPlayerToDefaultsHook()
{
	local int i;
	
	HungerTimer = 0;
	bInverseAim = False;
	
	ModGroundSpeedMultiplier = -1.0;
	ModWaterSpeedMultiplier= -1.0;
	ModHealthMultiplier = -1.0;
	ModHealingMultiplier = -1.0;
	
	for (i=0; i<ArrayCount(AddictionStates); i++)
	{
		AddictionStates[i] = 0;
		AddictionTimers[i] = 0;
		AfflictionTimers[i] = 0;
		ForceAddictions[i] = 0;
	}
	LastRecMission = 0;
	
	bMechAugs = False;
	bKillswitchEngaged = False;
	KillswitchPhase = 0;
	KillswitchTime = 0;
	KSHealMult = 1.0;
	KSHealthMult = 1.0;
	
	dripRate = 0;
	waterDripCounter = 0;
}

//MADDERS: Clean up after heli rides and shit.
function VMDInterpolateHook()
{
	BloodSmellLevel = 0;
	ZymeSmellLevel = 0;
	SmokeSmellLevel = 0;
}

//MADDERS: Inventory system big poopy butt.
function VMDUpdateInventoryJank()
{
	local Inventory Inv;
	local int R, C, PX, PY, SizeX, SizeY, i, u;
	
	for(i=0; i<ArrayCount(InvSlots); i++)
	{
		InvSlots[i] = 0;
	}
	
	for(Inv=Inventory; Inv != None; Inv = Inv.Inventory)
	{
		PX = Inv.InvPosX;
		PY = Inv.InvPosY;
		SizeX = VMDConfigureInvSlotsX(Inv);
		SizeY = VMDConfigureInvSlotsY(Inv);
		
		if (SizeX < 0 || SizeY < 0 || PX < 0 || PY < 0)
		{
			continue;
		}
		
		for (R=PX; R < (PX + SizeX); R++)
		{
			for (C=PY; C < (PY + SizeY); C++)
			{
				u = (C * MaxInvCols) + (R);
                  		InvSlots[u] = 1;
			}
		}
	}
}

function bool ShouldAllowHungerAndStress()
{
	local DeusExLevelInfo Info;
	
	Info = GetLevelInfo();
	
	//MADDERS, 9/16/22: Don't run this if we're fixing some bullshit in console.
	if ((Player != None) && (Player.Console != None) && (Player.Console.IsInState('Typing'))) return false;
	
	//MADDERS, 8/3/23: Don't run this as trestkon, thanks.
	if (IsA('Trestkon')) return false;
	
	if ((info != None) && ((Info.MissionNumber <= 0) || (Info.MissionNumber >= 98))) return false; 
	if (IsInState('Dying') || IsInState('Paralyzed') || IsInState('TrulyParalyzed') || IsInState('Conversation') || IsInState('Interpolating')) return false;
	if (Level.Netmode != NM_Standalone) return false;
	if (ReducedDamageType == 'All' || bHidden || IsInState('CheatFlying')) return false;
	if (VMDIsBurdenPlayer()) return false;
	
	return true;
}

function bool VMDHasCinematicClickObjection()
{
	switch(VMDGetMapName())
	{
		case "CF_00_INTRO":
		case "CF_02_CUTSCENE":
		case "00_BASEINTRO":
		case "02_BASEENDMOVIE":
		case "02_BASEENDMOVIELAST":
		case "16_RESCUE_END":
		case "20_DISCLOSURE_INTRO":
		case "21_INTRO1":
		case "21_INTRO2":
		case "21_SHUTTLE_BUS_VID":
		case "22_CAN_VID":
		case "22_EXTRO1":
		case "22_EXTRO2":
		case "59_INTRO":
		case "68_ENDING_1":
		case "68_ENDING_2":
		case "68_ENDING_3":
		case "68_ENDING_4":
		case "68_COMPLEXINTRO":
		case "69_MUTATIONSINTRO":
		case "69_TCP_INTRP":
		case "69_ZODIAC_INTRO":
		case "73_MUTATIONS_ENDING":
		case "76_ZODIAC_EGYPT_TRANS":
		case "77_ZODIAC_ENDGAME1":
		case "77_ZODIAC_ENDGAME2":
		case "80_BURDEN_INTRO":
			return true;
		break;
	}
	
	return false;
}

function VMDSignalCinematicClick()
{
	local string TravelTar;
	local bool bSendingSomewhere, bNGPlus;
	
	bSendingSomewhere = true;
	
	TravelTar = "";
	switch(VMDGetMapName())
	{
		case "20_DISCLOSURE_INTRO":
			TravelTar = "20_Secret_Base";
		break;
		case "CF_00_INTRO":
			TravelTar = "CF_01_UNRC";
		break;
		case "CF_02_CUTSCENE":
			TravelTar = "CF_03_BRIDGE";
		break;
		case "00_BASEINTRO":
			//MADDERS, 1/29/21: Yikes. This mod is *wildly* unstable. Fuck that.
			//We'll figure this out in a minute.
			//TravelTar = "00_AmmoMap";
			if (bNGPlusKeepInventory < 3) LoadBLVKit();
			TravelTar = "01_Base";
		break;
		case "02_BASEENDMOVIE":
			TravelTar = "02_BaseEnd";
		break;
		//MADDERS, 4/23/24: NG plus for BLV, bb.
		case "02_BASEENDMOVIELAST":
			bSendingSomewhere = false;
			bNGPlus = true;
		break;
		//MADDERS, 6/21/24: Start NG plus in the end cinematic, thanks.
		case "16_RESCUE_END":
			bSendingSomewhere = false;
			bNGPlus = true;
		break;
		case "21_INTRO1":
			TravelTar = "21_Intro2";
		break;
		case "21_INTRO2":
			TravelTar = "21_OtemachiLab_1";
		break;
		case "21_SHUTTLE_BUS_VID":
			TravelTar = "21_ShinjukuStation";
		break;
		case "22_CAN_VID":
			TravelTar = "22_OtemachiReturn";
		break;
		case "22_EXTRO1":
			TravelTar = "22_Extro1_2";
		break;
		
		//MADDERS: Let us skip this shit even harder now in VMD.
		case "59_INTRO":
			TravelTar = "60_HongKong_MPSHelipad";
		break;
		
		case "68_ENDING_1":
		case "68_ENDING_2":
		case "68_ENDING_3":
		case "68_ENDING_4":
		case "73_MUTATIONS_ENDING":
			bSendingSomewhere = false;
			bNGPlus = true;
		break;
		
		case "68_COMPLEXINTRO":
			TravelTar = "72_Mutations1";
		break;
		case "69_MUTATIONSINTRO":
			if (bNGPlusKeepInventory < 3) LoadMutationsKit();
			TravelTar = "70_Mutations";
		break;
		
		case "69_TCP_Intro":
			if (bNGPlusKeepInventory < 3) LoadCassandraKit();
			TravelTar = "69_TCP_BrumStreets";
		break;
		case "69_ZODIAC_INTRO":
			if (bNGPlusKeepInventory < 3) LoadZodiacKit();
			TravelTar = "70_Zodiac_HongKong_TongBase";
		break;

		case "76_ZODIAC_EGYPT_TRANS":
			TravelTar = "76_Zodiac_Egypt_Entrance";
		break;
		
		//MADDERS: Boot back to main menu. The player's wish is our command.
		case "22_EXTRO2":
		case "77_ZODIAC_ENDGAME1":
		case "77_ZODIAC_ENDGAME2":
			bSendingSomewhere = false;
			bNGPlus = true;
			//TravelTar = "DXOnly";
		break;
		case "80_BURDEN_INTRO":
			TravelTar = "80_Burden_Apartment";
		break;
		default:
			bSendingSomewhere = false;
		break;
	}
	
	//MADDERS, 9/7/21: Do this bullshit now to fix bad compatibility.
	if (bSendingSomewhere)
	{
		ClientTravel(TravelTar, TRAVEL_Relative, True);
	}
	else if (bNGPlus)
	{
		StartNewGamePlus();
	}
}

function bool VMDHasInterpolationClickObjection()
{
	local DeusExLevelInfo DXLI;
	
	ForEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		break;
	}
	
	switch(VMDGetMapName())
	{
		case "16_HOTELCARONE_INTRO":
			if (DXLI.MissionNumber == 15)
			{
				return true;
			}
			else
			{
				return false;
			}
		break;
	}
	
	return false;
}

function VMDSignalInterpolationClick()
{
	local string TravelTar;
	local bool bSendingSomewhere;
	
	bSendingSomewhere = true;
	
	TravelTar = "";
	switch(VMDGetMapName())
	{
		case "16_HOTELCARONE_INTRO":
			if (bNGPlusKeepInventory < 3) LoadCaroneKit();
			TravelTar = "16_HotelCarone_House";
		break;
		default:
			bSendingSomewhere = false;
		break;
	}
	
	//MADDERS, 9/7/21: Do this bullshit now to fix bad compatibility.
	if (bSendingSomewhere)
	{
		ClientTravel(TravelTar, TRAVEL_Relative, True);
	}
}

function string VMDGetMapName()
{
 	return class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
}

// ----------------------------------------------------------------------
// PostIntro()
// ----------------------------------------------------------------------

function PostIntro()
{
	local PlayerPawn PP;
	
	if ((Inventory != None) && (Nanokeyring(Inventory) == None))
	{
		bStartNewGameAfterIntro = True;
	}
	
	if (bStartNewGameAfterIntro)
	{
		bStartNewGameAfterIntro = False;
		StartNewGame(CampaignNewGameMap);
		//StartNewGame(strStartMap);
	}
	else
	{
		Level.Game.SendPlayer(Self, "dxonly");
	}
}
// ----------------------------------------------------------------------
// ShowCustomIntro()
// ----------------------------------------------------------------------

function ShowCustomIntro(string CNGM)
{
	local string PM;
	
	if (DeusExRootWindow(rootWindow) != None)
		DeusExRootWindow(rootWindow).ClearWindowStack();
	
	bStartNewGameAfterIntro = True;
	
	// Make sure all augmentations are OFF before going into the intro
	AugmentationSystem.DeactivateAll();
	
	switch(CAPS(SelectedCampaign))
	{
		case "REDSUN":
		case "REDSUN 2020":
			CampaignNewGameMap = "21_OtemachiLab_1";				
		break;
		case "ZODIAC":
			CampaignNewGameMap = "70_Zodiac_HongKong_TongBase";
		break;
		case "CARONE":
		case "HOTEL CARONE":
			CampaignNewGameMap = "16_HotelCarone_Intro";
		break;
		case "TNM":
			CampaignNewGameMap = "";
		break;
		case "OMEGA":
			CampaignNewGameMap = "50_OmegaStart";
		break;
		case "NIHILUM":
			CampaignNewGameMap = "60_HongKong_MPSHelipad";
		break;
		case "DISCLOSURE":
			CampaignNewGameMap = "20_Secret_Base";
		break;
		case "COUNTERFEIT":
			CampaignNewGameMap = "CF_01_Intro";
		break;
		case "MUTATIONS":
			CampaignNewGameMap = "69_MutationsIntro";
		break;
		case "BLOODLIKEVENOM":
			//MADDERS, 1/29/21: Yikes. This mod is *wildly* unstable. Fuck that.
			//We'll figure this out in a minute.
			//CampaignNewGameMap = "00_AmmoMap";
			CampaignNewGameMap = "01_Base";
		break;
		case "IWR":
			CampaignNewGameMap = "51_Gville_Downtown";
		break;
		case "BURDEN":
			CampaignNewGameMap = "80_Burden_Apartment";
		break;
		case "CASSANDRA":
			CampaignNewGameMap = "69_TCP_Brum_Streets";
		break;
		case "VANILLA":
		case "REVISION":
		case "CUSTOM REVISION":
		default:
			CampaignNewGameMap = "01_NYC_UNATCOIsland";
		break;
	}
	
	// Reset the player
	Level.Game.SendPlayer(Self, CNGM);
}


//MADDERS: Hacky convo support for fem jc. It's a start.
state Conversation
{
ignores SeePlayer, HearNoise, Bump;
	
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if ((bAssignedFemale) && (!bAllowFemaleVoice || bDisableFemaleVoice))
		{
			TransientSoundVolume = 0;
		}
		
		//MADDERS, 8/7/24: Do this so chaining convos doesn't just re-invoke the issue, though.
		BarfMusicFixTimer = 0.0;
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if ((bAssignedFemale) && (!bAllowFemaleVoice || bDisableFemaleVoice))
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
		
		//MADDERS, 7/14/24: Add a quick fix for possibly fucking up audio post-convo.
		BarfMusicFixTimer = 5.0;
  	}

	event PlayerTick(float deltaTime)
	{
		Super.PlayerTick(DeltaTime);
		
		if ((bAssignedFemale) && (!bAllowFemaleVoice || bDisableFemaleVoice) && (SoundVolume > 0))
		{
			TransientSoundVolume = 0;
		}
	}
Begin:
	// Make sure we're stopped
	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = 0;

	Acceleration = Velocity;

	PlayRising();

	// Make sure the player isn't on fire!
	if (bOnFire)
		ExtinguishFire();

	// Make sure the PC can't be attacked while in conversation
	MakePlayerIgnored(true);

	LookAtActor(conPlay.startActor, true, false, true, 0, 0.5);

	SetRotation(DesiredRotation);

	PlayTurning();
//	TurnToward(conPlay.startActor);
//	TweenToWaiting(0.1);
//	FinishAnim();

	if (!conPlay.StartConversation(Self))
	{
		AbortConversation(True);
	}
	else
	{
		// Transcended - Added
		// Put away whatever the PC may be holding.
		// Don't put away if it's a lockpick/nanokeyring/ambrosia vial/weaponmod/light weapon.
		// Weapons/items listed are an exception since they look odd.
		if (inhand != None)
		{
			//MADDERS, 8/27/23: Drop dorky shit when in convos, so long as it won't kill us.
			if ((VMDPOVDeco(InHand) != None) && (!VMDPOVDeco(InHand).StoredbExplosive))
			{
				DropDecoration();
			}
			else if ((POVCorpse(InHand) != None) && (!POVCorpse(InHand).bExplosive))
			{
				DropItem(POVCorpse(InHand), True);
			}
			
			//MADDERS, 8/27/23: New weapon weights, so uh... Oops. Invalidated table.
			// && inhand.mass >=20) || inhand.IsA('WeaponCombatKnife') || inhand.IsA('WeaponCrowbar') || inhand.IsA('WeaponEMPGrenade') || inhand.IsA('WeaponNanoVirusGrenade') || inhand.IsA('WeaponSawedOffShotgun') || inhand.IsA('WeaponShuriken')  || inhand.IsA('WeaponNPCMelee') || inhand.IsA('WeaponNPCRanged') || inhand.IsA('Multitool') || (!inhand.IsA('DeusExWeapon') && !inhand.IsA('WeaponMod') && !inhand.IsA('SkilledTool') && !inhand.IsA('VialAmbrosia'))
			else if (!inhand.IsA('DeusExWeapon') && !inhand.IsA('Multitool') && !inhand.IsA('WeaponMod') && !inhand.IsA('SkilledTool') && !inhand.IsA('VialAmbrosia'))
			{
				conPlay.SetInHand(InHand);
				PutInHand(None);
				UpdateInHand();
			}
		}
		else if (CarriedDecoration != None)
		{
			if (DeusExDecoration(CarriedDecoration) == None || !DeusExDecoration(CarriedDecoration).bExplosive)
			{
				DropDecoration();
			}
		}
		else // Very ugly hack to drop deco that is for some reason None.
		{
			conPlay.SetInHand(None);
			PutInHand(None);
			UpdateInHand();
		}
		
		// Turn off the laser on the weapon before the convo to prevent weird dots in third person view.
		if (DeusExWeapon(inHand) != None)
		{
			//DeusExWeapon(inHand).bWasLasing = DeusExWeapon(inHand).bLasing;
			DeusExWeapon(inHand).LaserOff();
		}
		
		if ( conPlay.GetDisplayMode() == DM_ThirdPerson )
			bBehindView = true;		
	}
}

function VMDUpdateBaseEyeHeight()
{
	//MADDERS: Update female sounds a bit here.
	if (bAssignedFemale)
	{
		//MADDERS, 5/11/25: Used to be -2, but oops, walk bob fucks everything up.
		//MADDERS, 10/3/25: Gonna shove this back the other way, actually, because of how it fucks up convo cam.
		BaseEyeHeight = CollisionHeight - (GetDefaultCollisionHeight() - Default.BaseEyeHeight) - 2.0;
	}
	else
	{
		BaseEyeHeight = CollisionHeight - (GetDefaultCollisionHeight() - Default.BaseEyeHeight);
	}
}

function FabricatePlayerAppearance()
{
	local int i;
	local bool bDefab;
	
	if (IsA('BurdenPeterKent') || IsA('TCPPlayerCharlotte'))
	{
		DefabricatePlayerAppearance();
		return;
	}
	
	//MADDERS, 1/13/21: Fix for Rescue (non-Aroo)
	if (IsA('Thug'))
	{
		DefabricatePlayerAppearance();
		return;
	}

	//MADDERS, 8/3/23: Fix for TNM base usage.
	if (IsA('Trestkon'))
	{
		return;
	}
	
	for (i=0; i<ArrayCount(StoredPlayerSkins); i++)
	{
		FabricatedSkins[i] = Texture(DynamicLoadObject(StoredPlayerSkins[i], class'Texture', true));
		if (FabricatedSkins[i] != None)
		{
			Multiskins[i] = FabricatedSkins[i];
		}
		else
		{
			bDefabricateQueued = True;
			Multiskins[i] = Default.Multiskins[i];
		}
	}
	FabricatedTexture = Texture(DynamicLoadObject(StoredPlayerTexture, class'Texture', true));
	if (FabricatedTexture != None)
	{
		Texture = FabricatedTexture;
	}
	
	FabricatedMesh = Mesh(DynamicLoadObject(StoredPlayerMesh, class'Mesh', true));
	FabricatedMeshLeft = Mesh(DynamicLoadObject(StoredPlayerMeshLeft, class'Mesh', true));
	if (FabricatedMesh != None)
	{
		Mesh = FabricatedMesh;
	}
	else
	{
		bDefabricateQueued = True;
		Mesh = Default.Mesh;
	}
	
	VMDUpdateBaseEyeHeight();
	
	//MADDERS: Update female sounds a bit here.
	if (bAssignedFemale)
	{
		Land = sound'VMDFJCLand';
	}
	else
	{
		Land = Default.Land;
	}
	
	//MADDERS, 6/4/23: Our weapons panic at our lack of left handed mesh, so let them know it's cool now.
	if (DeusExWeapon(InHand) != None)
	{
		DeusExWeapon(InHand).SetHand(PreferredHandedness);
		if (DeusExWeapon(InHand).DualWieldPartner != None)
		{
			DeusExWeapon(InHand).DualWieldPartner.SetHand(PreferredHandedness);
		}
	}
	else if (SkilledTool(InHand) != None)
	{
		SkilledTool(InHand).SetHand(PreferredHandedness);
	}
	else if (POVCorpse(InHand) != None)
	{
		POVCorpse(InHand).SetHand(PreferredHandedness);
	}
	else if (VMDPlayerHands(InHand) != None)
	{
		VMDPlayerHands(InHand).SetHand(PreferredHandedness);
	}
	
	FlagBase.SetBool('JCOutfits_Equipped_NoLeather', True,, 99);
	for(i=0; i<ArrayCount(Multiskins); i++)
	{
		if (Multiskins[i] == Texture'JCDentonTex3')
		{
			FlagBase.SetBool('JCOutfits_Equipped_NoLeather', False,, 99);
			break;
		}
	}
	
	FlagBase.SetBool('JCOutfits_No_Coat', True,, 99);
	switch(Mesh.Name)
	{
		case 'GM_Trench':
		case 'GM_TrenchLeft':
		case 'VMDGM_Trench_F':
		case 'GM_Trench_F':
		case 'GM_Trench_FLeft':
		case 'VMDGFM_Trench':
		case 'GFM_Trench':
		case 'GFM_TrenchLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
			FlagBase.SetBool('JCOutfits_No_Coat', False,, 99);
		break;
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
		case 'MP_JumpsuitLeft':
			CurMeshLensesIndex = -1;
			CurMeshFramesIndex = -1;
		break;
		case 'VMDGM_Suit':
		case 'GM_Suit':
		case 'GM_SuitLeft':
			CurMeshLensesIndex = 6;
			CurMeshFramesIndex = 5;
		break;
		case 'VMDGM_DressShirt_S':
		case 'GM_DressShirt_S':
		case 'VMDGM_DressShirt':
		case 'GM_DressShirt':
		case 'VMDGM_DressShirt_F':
		case 'GM_DressShirt_F':
		case 'GM_DressShirt_SLeft':
		case 'GM_DressShirtLeft':
		case 'GM_DressShirt_FLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
		break;
		case 'VMDGFM_SuitSkirt':
		case 'GFM_SuitSkirt':
		case 'VMDGFM_SuitSkirt_F':
		case 'GFM_SuitSkirt_F':
		case 'GFM_SuitSkirtLeft':
		case 'GFM_SuitSkirt_FLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
		break;
	}
}

//MADDERS: You can't set arrays with set property text, so add a function for storing these retroactively.
function DeFabricatePlayerAppearance()
{
	local int i;
	local Mesh TMesh, TMeshLeft;
	
	//MADDERS, 7/20/21: Cockblock bad appearance attempts.
	if ((IsA('MadIngramPlayer') || IsA('Venom') || IsA('Trestkon')) && (!bAssignedFemale)) return;
	
	for (i=0; i<ArrayCount(StoredPlayerSkins); i++)
	{
		FabricatedSkins[i] = Multiskins[i];
		StoredPlayerSkins[i] = string(Multiskins[i]);
	}
	FabricatedTexture = Texture;
	StoredPlayerTexture = string(Texture);
	
	StoredPlayerMesh = string(Mesh);
	switch(CAPS(StoredPlayerMesh))
	{
		case "DEUSEXCHARACTERS.GM_TRENCH":
		case "VMDASSETS.GM_TRENCH_LEFT":
			StoredPlayerMesh = "DeusExCharacters.GM_Trench";
			StoredPlayerMeshLeft = "VMDAssets.GM_TrenchLeft";
		break;
		case "DEUSEXCHARACTERS.GM_TRENCH_F":
		case "VMDASSETS.VMDGM_TRENCH_F":
		case "VMDASSETS.GM_TRENCH_FLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGM_Trench_F";
			StoredPlayerMeshLeft = "VMDAssets.GM_Trench_FLeft";
		break;
		case "MPCHARACTERS.MP_JUMPSUIT":
		case "VMDASSETS.VMDMP_JUMPSUIT":
		case "VMDASSETS.MP_JUMPSUITLEFT":
			StoredPlayerMesh = "VMDAssets.VMDMP_Jumpsuit";
			StoredPlayerMeshLeft = "VMDAssets.MP_JumpsuitLeft";
		break;
		case "DEUSEXCHARACTERS.GM_SUIT":
		case "VMDASSETS.VMDGM_SUIT":
		case "VMDASSETS.GM_SUITLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGM_Suit";
			StoredPlayerMeshLeft = "VMDAssets.GM_SuitLeft";
		break;
		case "DEUSEXCHARACTERS.GM_DRESSSHIRT_S":
		case "VMDASSETS.VMDGM_DRESSSHIRT_S":
		case "VMDASSETS.GM_DRESSSHIRT_SLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGM_DressShirt_S";
			StoredPlayerMeshLeft = "VMDAssets.GM_DressShirt_SLeft";
		break;
		case "DEUSEXCHARACTERS.GM_DRESSSHIRT":
		case "VMDASSETS.VMDGM_DRESSSHIRT":
		case "VMDASSETS.GM_DRESSSHIRTLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGM_DressShirt";
			StoredPlayerMeshLeft = "VMDAssets.GM_DressShirtLeft";
		break;
		case "DEUSEXCHARACTERS.GM_DRESSSHIRT_F":
		case "VMDASSETS.VMDGM_DRESSSHIRT_F":
		case "VMDASSETS.GM_DRESSSHIRT_FLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGM_DressShirt_F";
			StoredPlayerMeshLeft = "VMDAssets.GM_DressShirt_FLeft";
		break;
		
		case "DEUSEXCHARACTERS.GFM_TRENCH":
		case "VMDASSETS.VMDGFM_TRENCH":
		case "VMDASSETS.GFM_TRENCHLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGFM_Trench";
			StoredPlayerMeshLeft = "VMDAssets.GFM_TrenchLeft";
		break;
		case "DEUSEXCHARACTERS.GFM_SUITSKIRT":
		case "VMDASSETS.VMDGFM_SUITSKIRT":
		case "VMDASSETS.GFM_SUITSKIRTLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGFM_SuitSkirt";
			StoredPlayerMeshLeft = "VMDAssets.GFM_SuitSkirtLeft";
		break;
		case "DEUSEXCHARACTERS.GFM_SUITSKIRT_F":
		case "VMDASSETS.VMDGFM_SUITSKIRT_F":
		case "VMDASSETS.GFM_SUITSKIRT_FLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGFM_SuitSkirt_F";
			StoredPlayerMeshLeft = "VMDAssets.GFM_SuitSkirt_FLeft";
		break;
		case "DEUSEXCHARACTERSE.GFM_DRESS":
		case "VMDASSETS.VMDGFM_DRESS":
		case "VMDASSETS.VMDGFM_DRESSLEFT":
			StoredPlayerMesh = "VMDAssets.VMDGFM_Dress";
			StoredPlayerMeshLeft = "VMDAssets.VMDGFM_DressLeft";
		break;
	}
	
	TMesh = Mesh(DynamicLoadObject(StoredPlayerMesh, class'Mesh', true));
	if (StoredPlayerMeshLeft != "") TMeshLeft = Mesh(DynamicLoadObject(StoredPlayerMeshLeft, class'Mesh', true));
	
	if (TMesh != None) FabricatedMesh = TMesh;
	if (TMeshLeft != None) FabricatedMeshLeft = TMeshLeft;
	
	FlagBase.SetBool('JCOutfits_Equipped_NoLeather', True,, 99);
	for(i=0; i<ArrayCount(Multiskins); i++)
	{
		if (Multiskins[i] == Texture'JCDentonTex3')
		{
			FlagBase.SetBool('JCOutfits_Equipped_NoLeather', False,, 99);
			break;
		}
	}
	
	FlagBase.SetBool('JCOutfits_No_Coat', True,, 99);
	switch(Mesh.Name)
	{
		case 'GM_Trench':
		case 'GM_TrenchLeft':
		case 'GM_Trench_F':
		case 'VMDGM_Trench_F':
		case 'GM_Trench_FLeft':
		case 'GFM_Trench':
		case 'VMDGFM_Trench':
		case 'GFM_TrenchLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
			FlagBase.SetBool('JCOutfits_No_Coat', False,, 99);
		break;
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
		case 'MP_JumpsuitLeft':
			CurMeshLensesIndex = -1;
			CurMeshFramesIndex = -1;
		break;
		case 'GM_Suit':
		case 'VMDGM_Suit':
		case 'GM_SuitLeft':
			CurMeshLensesIndex = 6;
			CurMeshFramesIndex = 5;
		break;
		case 'GM_DressShirt_S':
		case 'GM_DressShirt':
		case 'GM_DressShirt_F':
		case 'VMDGM_DressShirt_S':
		case 'VMDGM_DressShirt':
		case 'VMDGM_DressShirt_F':
		case 'GM_DressShirt_SLeft':
		case 'GM_DressShirtLeft':
		case 'GM_DressShirt_FLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
		break;
		case 'GFM_SuitSkirt':
		case 'GFM_SuitSkirt_F':
		case 'VMDGFM_SuitSkirt':
		case 'VMDGFM_SuitSkirt_F':
		case 'GFM_SuitSkirtLeft':
		case 'GFM_SuitSkirt_FLeft':
			CurMeshLensesIndex = 7;
			CurMeshFramesIndex = 6;
		break;
	}
}

exec function ReloadColorThemes()
{
	if (ThemeManager != None) ThemeManager.Destroy();
	CreateColorThemeManager();
}

exec function BindKey(string S)
{
	local string KeyName, Value;
	local int InPos;
	
	InPos = InStr(S, " ");
	if (InPos > -1)
	{
		KeyName = CAPS(Left(S, InPos));
		Value = Right(S, Len(S)-InPos-1);
		ConsoleCommand("SET InputExt"@KeyName@Value);
		SaveConfig();
	}
}

//MADDERS, misc function
exec function Char(int Index)
{
	ClientMessage("INDEX"@Index$":"@Chr(Index));
}

// ----------------------------------------------------------------------
// PutInHand()
//
// put the object in the player's hand and draw it in front of the player
// ----------------------------------------------------------------------

exec function PutInHand(optional Inventory inv)
{
	if (RestrictInput())
		return;
	
	// can't put anything in hand if you're using a spy drone
	if ((inHand == None) && (bSpyDroneActive))
		return;
	
	// can't do anything if you're carrying a corpse
	if (POVCorpse(InHand) != None || VMDPOVDeco(InHand) != None)
		return;
	
	if (inv != None)
	{
		// can't put ammo in hand
		if (inv.IsA('Ammo'))
			return;

		// Can't put an active charged item in hand
		//-------------------
		//MADDERS, 6/6/23: Fixed inability to do this even though now anyone can deactivate.
		//if ((inv.IsA('ChargedPickup')) && (ChargedPickup(inv).IsActive()) && (!HasSkillAugment('EnviroDeactivate')))
		//	return;
	}
	
	if (CarriedDecoration != None)
		DropDecoration();
	
	SetInHandPending(inv);
}

function VMDResetNewGameVars(int Phase)
{
	local int i;
	
	//MADDERS: Abuse switch case's jank factor when forgetting breaks, and speeddial this shit.
	switch(Phase)
	{
		//----------------
		case 0: //Difficulty
			ResetDifficultyVars();
			AssignedDifficulty = StrDifficultyNames[1];
			AssignedSimpleDifficulty = AssignedDifficulty;
		//----------------
		case 1: //Campaign
			bMechAugs = false;
			DatalinkID = "";
			SelectedCampaign = "Vanilla";
			InvokedBindName = "";
			CampaignNewGameMap = "01_NYC_UNATCOIsland";
			for(i=0; i<ArrayCount(MapStyle); i++)
			{
				MapStyle[i] = 0;
			}
			VMDClearRecordedMapsBefore(100);
		//----------------
		case 2: //Appearance, name, and gender
			PlayerSkin = 0;
			TruePlayerName = Default.TruePlayerName;
			bAssignedFemale = false;
		//----------------
		case 3: //Class select (custom or premade are both choices)
			AssignedClass = "Custom";
		//----------------
		case 4: //Specialization select
			ResetSkillSpecializations();
		//----------------
		case 5: //Skills and augments
			SkillSystem.ResetSkills();
			ResetSkillAugments();
			SkillPointsAvail = Default.SkillPointsAvail;
			SkillPointsTotal = Default.SkillPointsTotal;
			SkillPointsSpent = 0;
			
			VMDNewGameSkillsHook();
		//----------------
		case 6: //Augments only. Specialized.
			ResetSkillAugmentsNewGame();
			FormatSkillAugmentPointsLeft();
			bStartNewGameAfterIntro = False;
			VMDClearDroneData();
			VMDClearGenerousWeaponData();
		break;
	}
}

//MADDERS, 9/20/22: What a beast. I hate it, but hey, here we are anyways. Infinitely futureproofed.
function ResetDifficultyVars()
{
	bAdvancedLimbDamageEnabled = Default.bAdvancedLimbDamageEnabled;
	bAmmoReductionEnabled = Default.bAmmoReductionEnabled;
	bComputerVisibilityEnabled = Default.bComputerVisibilityEnabled;
	bDoorNoiseEnabled = Default.bDoorNoiseEnabled;
	bKillswitchHealthEnabled = Default.bKillswitchHealthEnabled;
	bLootDeletionEnabled = Default.bLootDeletionEnabled;
	bLootSwapEnabled = Default.bLootSwapEnabled;
	bMayhemSystemEnabled = Default.bMayhemSystemEnabled;
	bBountyHuntersEnabled = Default.bBountyHuntersEnabled;
	bReloadNoiseEnabled = Default.bReloadNoiseEnabled;
	bSaveGateEnabled = Default.bSaveGateEnabled;
	bCameraKillAlarm = Default.bCameraKillAlarm;
	bMayhemGrenadesEnabled = Default.bMayhemGrenadesEnabled;
	bPaulMortalEnabled = Default.bPaulMortalEnabled;
	bWeakGrenadeClimbing = Default.bWeakGrenadeClimbing;
	bEternalLaserAlarms = Default.bEternalLaserAlarms;
	
	//bSmartEnemyWeaponSwapEnabled = Default.bSmartEnemyWeaponSwapEnabled;
	bShootExplosivesEnabled = Default.bShootExplosivesEnabled;
	bNoticeBumpingEnabled = Default.bNoticeBumpingEnabled;
	bRecognizeMovedObjectsEnabled = Default.bRecognizeMovedObjectsEnabled;
	//bDrawMeleeEnabled = Default.bDrawMeleeEnabled;
	bEnemyDamageGateEnabled = Default.bEnemyDamageGateEnabled;
	bEnemyDisarmExplosivesEnabled = Default.bEnemyDisarmExplosivesEnabled;
	//bEnemyGEPLockEnabled = Default.bEnemyGEPLockEnabled;
	bDogJumpEnabled = Default.bDogJumpEnabled;
	bBossDeathmatchEnabled = Default.bBossDeathmatchEnabled;
	bEnemyVisionExtensionEnabled = Default.bEnemyVisionExtensionEnabled;
	bEnemyAlwaysAvoidProj = Default.bEnemyAlwaysAvoidProj;
	bEnemyReactKOdDudes = Default.bEnemyReactKOdDudes;
	//bSeeLaserEnabled = Default.bSeeLaserEnabled;
	
	EnemyROFWeight = Default.EnemyROFWeight;
	EnemyAccuracyMod = Default.EnemyAccuracyMod;
	EnemyReactionSpeedMult = Default.EnemyReactionSpeedMult;
	EnemySurprisePeriodMax = Default.EnemySurprisePeriodMax;
	EnemyHearingRangeMult = Default.EnemyHearingRangeMult;
	EnemyVisionRangeMult = Default.EnemyVisionRangeMult;
	EnemyVisionStrengthMult = Default.EnemyVisionStrengthMult;
	EnemyGuessingFudge = Default.EnemyGuessingFudge;
	
	SaveGateCombatThreshold = Default.SaveGateCombatThreshold;
	BarfStartingMayhem = Default.BarfStartingMayhem;
	SavedMayhemForgiveness = Default.SavedMayhemForgiveness;
	SavedGateBreakThreshold = Default.SavedGateBreakThreshold;
	SavedLootSwapSeverity = Default.SavedLootSwapSeverity;
	SavedNakedSolutionReductionRate = Default.SavedNakedSolutionReductionRate;
	SavedNakedSolutionMissionEnd = Default.SavedNakedSolutionMissionEnd;
	BarfHunterThreshold = Default.BarfHunterThreshold;
	SavedHunterThreshold = Default.SavedHunterThreshold;
	BarfLootReduction = Default.BarfLootReduction;
	BarfCombatThreshold = Default.BarfCombatThreshold;
	BarfMayhemForgiveness = Default.BarfMayhemForgiveness;
	BarfGateBreakThreshold = Default.BarfGateBreakThreshold;
	BarfLootSwapSeverity = Default.BarfLootSwapSeverity;
	BarfSaveGateTime = Default.BarfSaveGateTime;
	BarfROFWeight = Default.BarfROFWeight;
	BarfAccuracyMod = Default.BarfAccuracyMod;
	BarfReactionSpeedMult = Default.BarfReactionSpeedMult;
	BarfSurprisePeriodMax = Default.BarfSurprisePeriodMax;
	EnemyExtraSearchSteps = Default.EnemyExtraSearchSteps;
	BarfHearingRangeMult = Default.BarfHearingRangeMult;
	BarfVisionRangeMult = Default.BarfVisionRangeMult;
	BarfVisionStrengthMult = Default.BarfVisionStrengthMult;
	BarfGuessingFudge = Default.BarfGuessingFudge;
	BarfDodgeClickTime = Default.BarfDodgeClickTime;
	BarfTacticalRollTime = Default.BarfTacticalRollTime;
	
	GallowsSaveGateTimer = Default.GallowsSaveGateTimer;
	GallowsSaveGateTime = Default.GallowsSaveGateTime;
	TimerDifficulty = Default.TimerDifficulty;
	EnemyHPScale = Default.EnemyHPScale;
	
	bCheckedFirstMayhem = false;
	MayhemFactor = 0;
	OwedMayhemFactor = 0;
	AllureFactor = 0;
}

function VMDNewGameSkillsHook()
{
	local Skill TSkill;
	
	//MADDERS: Bonus computers skill for carone.
	switch(CAPS(SelectedCampaign))
	{
		case "CARONE":
		case "HOTEL CARONE":
			/*if (SkillSystem != None)
			{
				TSkill = SkillSystem.GetSkillFromClass(class'SkillComputer');
				if (TSkill != None)
				{
					SkillPointsAvail += 950;
					if (TSkill.CurrentLevel < 3) TSkill.CurrentLevel++;
					SkillPointsTotal = SkillPointsAvail;
				}
			}*/
		break;
		case "MUTATIONS":
			//if (SkillSystem != None)
			//{
				SkillPointsAvail += 1350+725+1350+1325+950;
				SkillPointsAvail += 950+1800+3000 +725+1350+2250 +1325+2700+4500 +1325+2700+4500 +725+1350+2250-5000;
				SkillPointsTotal = SkillPointsAvail;
			//}
		break;
	}
}

//MADDERS, 7/20/21: For nihilum starting inventory to not break, thank you.
function FudgeResetPlayer(optional bool bTraining)
{
	local inventory anItem;
	local inventory nextItem;
	local VMDBufferPlayer VMP;
	
	//Barf. Selective bullshit, ahoy.
	if (!bNGPlusTravel)
	{
		ResetPlayerToDefaults();
		
		// Reset Augmentations
		if (AugmentationSystem != None)
		{
			AugmentationSystem.ResetAugmentations();
			AugmentationSystem.Destroy();
			AugmentationSystem = None;
		}
	}
	
	// Give the player their starting kit
	if (!bTraining)
	{
		VMP.VMDResetPlayerHook(bTraining);
	}
}

function VMDResetPlayerHook(bool bTraining)
{
	local int i;
	local Inventory Inv;
	
	//MADDERS, 10/5/22: This now travels, so reset it.
	RollCooldownTimer = 0;
	DodgeRollCooldownTimer = 0;
	NegateDeathCooldown = 0;
	HungerTimer = 0.0; //MADDERS, 4/18/24: Give us release from the agony of nihilum hunger.
	
	//MADDERS, 1/15/21: Expanded player seed from 10 to 26. Additionally, we're running this in here now.
	PlayerSeed = Rand(26);
	PlayerMayhemSeed = Rand(26);
	PlayerNakedSolutionSeed = Rand(26);
	PlayerNakedSolutionSubseed = Rand(100);
	
	if (bNGPlusKeepInventory < 3)
	{
		if (!bTraining)
		{
			switch(CAPS(SelectedCampaign))
			{
				case "VANILLA":
				case "REVISION":
				case "CUSTOM REVISION":
					LoadVanillaKit();
				break;
				case "CARONE":
				case "HOTEL CARONE":
					LoadCaroneKit();
				break;
				case "MUTATIONS":
					LoadMutationsKit();
				break;
				case "REDSUN":
				case "REDSUN2020":
				break;
				case "BURDEN":
				break;
				case "CASSANDRA":
					LoadCassandraKit();
				break;
				case "ZODIAC":
					LoadZodiacKit();
				break;
				case "NIHILUM":
					//LoadNihilumKit();
				break;
				case "IWR":
					LoadIWRKit();
				break;
				case "OTHER":
				case "DISCLOSURE":
				break;
				case "OTHERNOFOOD":
				case "OTHERPAULNOFOOD":
				case "OTHERNOFOODNOINTRO":
				case "OTHERPAULNOFOODNOINTRO":
				case "COUNTERFEIT":
					LoadOtherNoFoodKit();
				break;
				case "BLOODLIKEVENOM":
					LoadBLVKit();
				break;
				case "OMEGA":
				case "OTHERZEROFOOD": 
				case "OTHERZEROFOODNOINTRO": 
				case "OTHERPAULZEROFOOD":
				case "OTHERPAULZEROFOODNOINTRO":
					LoadOmegaKit();
				break;
			}
		}
	}
	else
	{
		LoadOtherLowFoodKit();	
	}
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		MarkItemDiscovered(Inv);
	}
}

function bool FakeParseRightClick(Actor FakeFrobTarget)
{
	if (FakeFrobTarget != None)
	{
		if (FakeFrobTarget.IsA('NanoKey'))
		{
			PickupNanoKey(NanoKey(FakeFrobTarget));
			FakeFrobTarget.Destroy();
			FakeFrobTarget = None;
			return true;
		}
		else if (FakeFrobTarget.IsA('Inventory'))
		{
			if (HandleItemPickup(FakeFrobTarget, True) == False)
				return false;
			
			if (FakeFrobTarget == None || FakeFrobTarget.bDeleteMe)
				return false;
			
			FrobTarget = FakeFrobTarget;
			DoFrob(Self, None);
			if (Inventory(FakeFrobTarget).Owner == Self)
			{
               			FindInventorySlot(Inventory(FakeFrobTarget));
				FakeFrobTarget = None;
				return true;
			}
		}
	}
	
	return false;
}

//MADDERS: This gets called so much, and checking for accessed nones is good practice.
//As such, do this in an elegant fashion.
function Inventory DonateNGItem(class<Inventory> ItemClass, optional string StartProp, optional string PropSetting)
{
	local int i;
	local DeusExRootWindow DXRW;
	local HUDObjectBelt TBelt;
	local Inventory AnItem, TItem, BeltItems[10];
	
	if (ItemClass == None) return None;
	
	AnItem = Spawn(ItemClass);
	if (AnItem != None)
	{
		for(TItem = Inventory; TItem != None; TItem = TItem.Inventory)
		{
			if ((TItem.bInObjectBelt) && (TItem.BeltPos > -1))
			{
				BeltItems[TItem.BeltPos] = TItem;
			}
		}
		
		if (StartProp != "")
		{
			AnItem.SetPropertyText(StartProp, PropSetting);
		}
		
		if (!FakeParseRightClick(AnItem))
		{
			AnItem.Destroy();
			AnItem = None;
		}
		else
		{
			MarkItemDiscovered(AnItem);
		}
		
		for(TItem = Inventory; TItem != None; TItem = TItem.Inventory)
		{
			if ((TItem.bInObjectBelt) && (TItem.BeltPos > -1) && (BeltItems[TItem.BeltPos] != None))
			{
				TItem.bInObjectBelt = false;
				TITem.BeltPos = -1;
			}
		}
		
		for(i=0; i<ArrayCount(BeltItems); i++)
		{
			if (BeltItems[i] != None)
			{
				BeltItems[i].bInObjectBelt = true;
				BeltItems[i].BeltPos = i;
			}
		}
	}
	
	return AnItem;
}

function Inventory LoadNGItem(String ItemClass, optional string StartProp, optional string PropSetting)
{
	local class<Inventory> ToClass;
	
	ToClass = class<Inventory>(DynamicLoadObject(ItemClass, class'Class', true));
	
	if (ToClass != None)
	{
		return DonateNGItem(ToClass, StartProp, PropSetting);
	}
	return None;
}

function DeleteNGItem(Name CheckType, optional bool bExact)
{
	local Inventory TItem, NextItem;
	
	for (TItem = Inventory; TItem != None; TItem = NextItem)
	{
		NextItem = TItem.Inventory;
		if (TItem.IsA(CheckType) && (!bExact || TItem.Class.Name == CheckType))
		{
			DeleteInventory(TItem);
			TItem.Destroy();
		}
	}
}

function Inventory ReplaceNGItem(name DetectType, string ReplaceClass)
{
	local Inventory TItem, LastItem, NextItem, SpawnedItem;
	local Ammo SpawnedAmmo;
	local DeusExWeapon FoundWeapon, SpawnedWeapon;
	local class<Inventory> LoadedClass;
	local class<Weapon> LoadedWeapon;
	local class<Ammo> FoundAmmo, LoadedAmmo, HuntAmmo;
	
	LoadedClass = class<Inventory>(DynamicLoadObject(ReplaceClass, class'Class', true));
	
	if (LoadedClass == None)
	{
		return None;
	}
	
	LoadedWeapon = class<Weapon>(LoadedClass);
	if (LoadedWeapon != None)
	{
		LoadedAmmo = LoadedWeapon.Default.AmmoName;
	}
	
	for (TItem = Inventory; TItem != None; TItem = NextItem)
	{
		NextItem = TItem.Inventory;
		
		FoundWeapon = DeusExWeapon(TItem);
		FoundAmmo = None;
		if (FoundWeapon != None)
		{
			FoundAmmo = FoundWeapon.AmmoName;
		}
		
		if (TItem.Class.Name == DetectType)
		{
			SpawnedItem = Spawn(LoadedClass);
			SpawnedWeapon = DeusExWeapon(SpawnedItem);
			
			RemoveItemFromSlot(TItem);
			RemoveObjectFromBelt(TItem);
			if (SpawnedWeapon != None)
			{
				SpawnedWeapon.PickupAmmoCount = 0;
				if ((LoadedAmmo != FoundAmmo) && (LoadedAmmo != None) && (FoundAmmo != None) && (SpawnedAmmo == None))
				{
					HuntAmmo = FoundAmmo;
					SpawnedAmmo = Spawn(LoadedAmmo);
					SpawnedAmmo.AmmoAmount = 0;
					
					FrobTarget = SpawnedAmmo;
					ParseRightClick();
				}
			}
			
			LastItem.Inventory = NextItem;
			TItem.Destroy();
			VMDUpdateInventoryJank();
			
			FrobTarget = SpawnedItem;
			ParseRightClick();
		}
		
		LastItem = TItem;
	}
	
	if (HuntAmmo != None)
	{
		for (TItem = Inventory; TItem != None; TItem = NextItem)
		{
			NextItem = TItem.Inventory;
			
			if (TItem.Class == HuntAmmo)
			{
				if (SpawnedAmmo != None)
				{
					SpawnedAmmo.AmmoAmount = Max(SpawnedAmmo.AmmoAmount, Ammo(TItem).AmmoAmount);
				}
				
				LastItem.Inventory = NextItem;
				TItem.Destroy();
			}
			
			LastItem = TItem;
		}
	}
}

function LoadCassandraKit()
{
}

//MADDERS: This barf is for BLV's nasty ass starting situation.
//Start map is fucked. For now, randomize it outright.
//--------------------
//To explain, BLV dumps you in the "ammomap" with a 30 second snatch-fest.
//It's not possible to simulate this exact experience without remaking the map outright...
//That's not happening, though. So for now, give us 1 of each category, and 2 random pickups.
//For weapons with bonus ammo, we give the ammo just assumed, and pre-simulate which ones were swapped out in testing.
function LoadBLVKit()
{
	local int MWR, HWR, RWR, PWR, PickR1, PickR2, i;
	
	HWR = Rand(4);
	switch(HWR)
	{
		case 0:
			DonateNGItem(class'WeaponFlamethrower');
		break;
		case 1:
			DonateNGItem(class'WeaponGEPGun');
		break;
		case 2:
			DonateNGItem(class'WeaponPlasmaRifle');
		break;
		case 3:
			DonateNGItem(class'WeaponLAM');
		break;
	}
	RWR = Rand(4);
	switch(RWR)
	{
		case 0:
			DonateNGItem(class'WeaponRifle');
			DonateNGItem(class'Ammo3006HEAT');
		break;
		case 1:
			DonateNGItem(class'WeaponAssaultGun');
			DonateNGItem(class'Ammo762mm');
		break;
		case 2:
			DonateNGItem(class'WeaponAssaultShotgun');
		break;
		case 3:
			DonateNGItem(class'WeaponSawedOffShotgun');
		break;
	}
	MWR = Rand(4);
	switch(MWR)
	{
		case 0:
			DonateNGItem(class'WeaponCombatKnife');
		break;
		case 1:
			DonateNGItem(class'WeaponBaton');
		break;
		case 2:
			DonateNGItem(class'WeaponCrowbar');
		break;
		case 3:
			DonateNGItem(class'WeaponShuriken');
		break;
	}
	PWR = Rand(3);
	switch (PWR)
	{
		case 0:
			DonateNGItem(class'WeaponPistol');
			DonateNGItem(class'Ammo10mm');
			
			//MADDERS, 1/29/21: Fudging this, just for fun. It WAS gascaps, though.
			DonateNGItem(class'Ammo10mmHEAT');
		break;
		case 1:
			DonateNGItem(class'WeaponStealthPistol');
			DonateNGItem(class'Ammo10mm');
			DonateNGItem(class'Ammo10mmGasCap');
		break;
		case 2:
			DonateNGItem(class'WeaponMiniCrossbow');
		break;
	}
	
	PickR1 = Rand(9);
	switch (PickR1)
	{
		case 0:
			DonateNGItem(class'Binoculars');
		break;
		case 1:
			DonateNGItem(class'Multitool');
		break;
		case 2:
			DonateNGItem(class'WeaponModAccuracy');
		break;
		case 4:
			DonateNGItem(class'Flare');
		break;
		case 5:
			DonateNGItem(class'BallisticArmor');
		break;
		case 6:
			DonateNGItem(class'CandyBar');
		break;
		case 7:
			DonateNGItem(class'VialCrack');
		break;
		case 8:
			DonateNGItem(class'Medkit');
		break;
	}
	for (i=0; i<40; i++)
	{
		PickR2 = Rand(9);
		if (PickR2 != PickR1) break;
	}
	switch (PickR2)
	{
		case 0:
			DonateNGItem(class'Binoculars');
		break;
		case 1:
			DonateNGItem(class'Multitool');
		break;
		case 2:
			DonateNGItem(class'WeaponModAccuracy');
		break;
		case 4:
			DonateNGItem(class'Flare');
		break;
		case 5:
			DonateNGItem(class'BallisticArmor');
		break;
		case 6:
			DonateNGItem(class'CandyBar');
		break;
		case 7:
			DonateNGItem(class'VialCrack');
		break;
		case 8:
			DonateNGItem(class'Medkit');
		break;
	}
	
	//MADDERS, 1/29/21: Front gate code isn't give for some reason.
	//How 'bout we DON'T get softlocked minute 1?
	DonateNGItem(class'Multitool', "NumCopies", "2");
	if (bHungerEnabled)
	{
		DonateNGItem(class'SoyFood', "NumCopies", "5");
	}
}

//MADDERS: Use this icky shit for carrying over gear from cinematic skips.
function LoadOtherNoFoodKit()
{
	if (bHungerEnabled)
	{
		DonateNGItem(class'SoyFood', "NumCopies", "5");
	}
}

function LoadOtherLowFoodKit()
{
	if (bHungerEnabled)
	{
		DonateNGItem(class'SoyFood', "NumCopies", "10");
		DonateNGItem(class'CandyBar', "NumCopies", "10");
		DonateNGItem(class'SodaCan', "NumCopies", "10");
	}
}

//MADDERS: Use this icky shit for carrying over gear from cinematic skips.
function LoadVanillaKit()
{
	DonateNGItem(class'WeaponPistol');
	DonateNGItem(class'WeaponProd');
	DonateNGItem(class'Medkit');
	
	//MADDERS: To be all-too-allowing, we're giving a small ration of food to the player at start.
	DonateNGItem(class'Soyfood');
	DonateNGItem(class'SodaCan', "SkinIndices", "0");
}

//MADDERS: Use this icky shit for carrying over gear from cinematic skips.
function LoadZodiacKit()
{
	DonateNGItem(class'WeaponPistol');
	DonateNGItem(class'WeaponProd');
	DonateNGItem(class'Medkit');
	if (bHungerEnabled)
	{
		DonateNGItem(class'SoyFood', "NumCopies", "5");
	}
}

//MADDERS: Custom kit for IWR start.
function LoadIWRKit()
{
	if (bHungerEnabled)
	{
		DonateNGItem(class'SoyFood', "NumCopies", "5");
	}
}

function LoadNihilumKit()
{
	DonateNGItem(class'Ammo10mm', "AmmoAmount", "10");
	LoadNGItem("FGRHK.Burger", "NumCopies", "2");
	SkillPointsTotal += 575; //MADDERS, 5/13/25: Turns out nihilum has a difference between skillpointstotal and skillpointsavail. Why tho?
	
	//MADDERS: We're already wiping new game inventory with our main menu swap out, so skip this part.
	//We wanted that damned sandwich, and we're gonna have it.
	if (FlagBase != None)
	{
		FlagBase.SetBool('M60_InventoryRemoved', True,, 70);
	}
}

function LoadOmegaKit()
{
	if (bHungerEnabled)
	{
		DonateNGItem(class'SuperSoyFood', "NumCopies", "40");
	}
}

function LoadCaroneKit()
{
	//MADDERS: Give us trained computers equiv in points because fuck me. These PC's are hard.
	//Also: This function is an adaptation of the HC starting inventory function... I need not explain why.
	//SkillPointsAvail += 950;
	//SkillPointsTotal += 950;
	
	// Give the player a pistol and a prod (HC: and some more shtuff) =)
	DonateNGItem(class'WeaponRifle', "bHasSilencer", "True");
	DonateNGItem(class'Ammo3006', "AmmoAmount", "10");
	DonateNGItem(class'WeaponProd');
	LoadNGItem("HotelCarone.WeaponHCLAM");
	DonateNGItem(class'WeaponPistol');
	DonateNGItem(class'Ammo10mm', "AmmoAmount", "10");
	DonateNGItem(class'AmmoBattery');
	DonateNGItem(class'Medkit');
	DonateNGItem(class'WeaponCrowbar');
	DonateNGItem(class'Lockpick', "NumCopies", "3");
	DonateNGItem(class'Multitool', "NumCopies", "3");
	if (bHungerEnabled)
	{
		DonateNGItem(class'SuperSoyFood', "NumCopies", "8");
	}
}

function LoadMutationsKit()
{
	// MUTATIONS: Give the player a pistol, multitool, lockpick, and medkit
	DonateNGItem(class'WeaponPistol');
	DonateNGItem(class'Lockpick', "NumCopies", "1");
	DonateNGItem(class'Multitool', "NumCopies", "1");
	DonateNGItem(class'Medkit', "NumCopies", "1");
	
	if (bHungerEnabled)
	{
		DonateNGItem(class'SuperSoyFood', "NumCopies", "40");
	}
}

//MADDERS: Do this smarter later on, but for now just block anything but vanilla.
function bool VMDHasStartKitObjection()
{
	switch(CAPS(SelectedCampaign))
	{
		//MADDERS: Start with soyfood and soda, so we'll just always customize the kit.
		case "VANILLA":
		case "REVISION":
		case "CUSTOM REVISION":
		//break;
		default:
			return true;
		break;
	}
	return false;
}

function SetupSkillAugmentManager(optional bool bOverride)
{
	if (SkillAugmentManager == None || bOverride)
	{
		if (SkillAugmentManager != None) SkillAugmentManager.Destroy();
		SkillAugmentManager = Spawn(class'VMDSkillAugmentManager', Self);
		SkillAugmentManager.SetPlayer(Self);
	}
}

function bool IsSpecializedIn(int i)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.IsSpecializedIn(i);
	}
	
	return false;
}

function bool IsSpecializedInSkill(class<Skill> S)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.IsSpecializedInSkill(S);
	}
	
	return false;
}

function int GetSkillAugmentPointsFromSkill(class<Skill> S)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.GetSkillAugmentPointsFromSkill(S);
	}
	return 0;
}

function FormatSkillAugmentPointsLeft()
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.FormatSkillAugmentPointsLeft();
	}
}

function int SkillAugmentPointWeightOf(int i)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.SkillAugmentPointWeightOf(i);
	}
}

function class<Skill> GetSecondarySkillAugmentSkillRequired(int Array)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.GetSecondarySkillAugmentSkillRequired(Array);
	}
}

function class<Skill> GetSkillAugmentSkillRequired(int Array)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.GetSkillAugmentSkillRequired(Array);
	}
}

function int SkillArrayOf(class<Skill> RelSkill)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.SkillArrayOf(RelSkill);
	}
}

function int SkillAugmentArrayOf(Name SkillAugmentName)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.SkillAugmentArrayOf(SkillAugmentName);
	}
}

function bool ProcessSkillAugmentCostException(Name S)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.ProcessSkillAugmentCostException(S);
	}
}

function bool HasSkillAugment(Name S)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.HasSkillAugment(S);
	}
}

function bool CanBuySkillAugment(int i, optional bool bAlt, optional bool bBoth, optional bool bBypassCost)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.CanBuySkillAugment(i, bAlt, bBoth, bBypassCost);
	}
}

function bool CanAffordSkillAugment(Name S, bool bAlt, bool bBoth)
{
	if (SkillAugmentManager != None)
	{
		return SkillAugmentManager.CanAffordSkillAugment(S, bAlt, bBoth);
	}
}

function BuySkillAugment(Name S, optional bool bAlt, optional bool bBoth)
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.BuySkillAugment(S, bAlt, bBoth);
	}
}

//Respecs might be a thing one day? Who knows.
function LockSkillAugment(Name S)
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.LockSkillAugment(S);
	}
}

function UnlockSkillAugment(Name S)
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.UnlockSkillAugment(S);
	}
}

function AddSkillAugmentPoints(class<Skill> RefSkill, int AddAmount)
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.AddSkillAugmentPoints(RefSkill, AddAmount);
	}
}

function RemoveSkillAugmentPoints(class<Skill> RefSkill, int NewLevel)
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.RemoveSkillAugmentPoints(RefSkill, NewLevel);
	}
}

function ResetSkillAugments()
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.ResetSkillAugments();
	}
}

function ResetSkillAugmentsNewGame()
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.ResetSkillAugmentsNewGame();
	}
}

function ResetSkillSpecializations()
{
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.ResetSkillSpecializations();
	}
}

function VMDSignalSkillAugmentUpdate(Name S, bool bUnlock)
{
	local Inventory Inv;
	local ChargedPickup First;
	local DeusExMover DXM;
	
	local VMDMegh TMegh;
	local VMDSidd TSidd;
	
	switch(S)
	{
		//Allow these to space apart in new inv slots.
		case 'ENVIROCOPIES':
			/*for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
			{
				if (ChargedPickup(Inv) != None)
				{
					ChargedPickup(Inv).MaxCopies = 2;
				}
			}*/
		break;
		case 'ENVIROCOPYSTACKS':
			/*for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
			{
				if (ChargedPickup(Inv) != None)
				{
					ChargedPickup(Inv).MaxCopies = 3;
				}
			}*/
		break;
		//MADDERS: Scout our shiat.
		//case 'LOCKPICKSCOUTNOISE':
		case 'LOCKPICKSTARTSTEALTH':
			forEach AllActors(class'DeusExMover', DXM)
			{
				DXM.VMDApplySpecialDoorStats(True);
			}
		break;
		case 'TAGTEAMMINITURRET':
			if (CraftingManager != None)
			{
				CraftingManager.MarkItemDiscovered(class'VMDSIDDPickup');
			}
		break;
		case 'ELECTRONICSDRONES':
			if (CraftingManager != None)
			{
				CraftingManager.MarkItemDiscovered(class'VMDMEGHPickup');
			}
		break;
		case 'ELECTRONICSDRONEARMOR':
			TMegh = FindProperMegh();
			if (TMegh != None)
			{
				TMegh.UpdateTalentEffects(Self);
			}
		break;
		case 'TAGTEAMSKILLWARE':
			TMegh = FindProperMegh();
			if (TMegh != None)
			{
				TMegh.UpdateTalentEffects(Self);
			}
			forEach AllActors(class'VMDSIDD', TSidd)
			{
				if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
				{
					TSidd.UpdateTalentEffects(Self);
				}
			}
		break;
		case 'TAGTEAMLITEHACK':
			TMegh = FindProperMegh();
			if (TMegh != None)
			{
				TMegh.UpdateTalentEffects(Self);
			}
		break;
		case 'TAGTEAMMEDICALSYRINGE':
			if (CraftingManager != None)
			{
				CraftingManager.MarkItemDiscovered(class'VMDMedigel');
			}
			
			TMegh = FindProperMegh();
			if (TMegh != None)
			{
				TMegh.UpdateTalentEffects(Self);
			}
		break;
		case 'MEDICINECOMBATDRUGS':
			if (CraftingManager != None)
			{
				CraftingManager.MarkItemDiscovered(class'VMDCombatStim');
			}
		break;
	}
}

function float VMDConfigureWeaponMassSpeed(float InSpeed, float DefSpeed, DeusExWeapon DXW)
{
	local int SkillLevel;
	local VMDBufferAugmentationManager VMA;
	
	VMA = VMDBufferAugmentationManager(AugmentationSystem);
	if (DXW.GoverningSkill == class'SkillWeaponHeavy')
	{
		SkillLevel = SkillSystem.GetSkillLevel(class'SkillWeaponHeavy');
		if (HasSkillAugment('HeavySpeed'))
		{
			if (SkillLevel <= 0) SkillLevel = 1;
			else SkillLevel *= 2;
		}
		if (VMA != None)
		{
			SkillLevel += int((VMA.VMDConfigureDecoLiftMult()-1.0)*3);
		}
		
		SkillLevel = Min(6, SkillLevel);
		return InSpeed * (0.5 + ((0.5 / 6) * SkillLevel));
	}
	else
	{
		if (DeusExWeapon(Weapon).GetWeaponSkill() > -0.25) return 0;
		else return InSpeed;
	}
}

//MADDERS: Use this for identifying classes and packages. Spicy.
function bool VMDOtherIsName(Actor Other, string S)
{
	if (Other == None) return false;
	
 	if (InStr(CAPS(String(Other.Class)), CAPS(S)) > -1) return true;
 	return false;
}

function int VMDGetBloodLevel()
{
 	local int Ret, SkillLevel;
	local float SmellMult;
 	
	if (SkillSystem != None)
	{
		SkillLevel = SkillSystem.GetSkillLevel(class'SkillLockpicking');
	}
	
	//Scale smell with our augment for it now.
	SmellMult = 1.0;
	if (HasSkillAugment('LockpickScent'))
 	{
		SmellMult = 1.25 + (0.25 * SkillLevel);
	}
	
 	if (BloodSmellLevel >= 45*SmellMult) Ret = 1;
 	if (BloodSmellLevel >= 90*SmellMult) Ret = 2;
 	
 	return Ret;
}

//MADDERS: Add to our current blood soak level. Messy.
function AddBloodLevel(int AddLevel)
{
	//MADDERS, 1/15/21: Make blood turn off on low gore. Why not?
	if (Level.Game.bLowGore || Level.Game.bVeryLowGore)
	{
		BloodSmellLevel = 0;
		return;
	}
	BloodSmellLevel = FClamp(BloodSmellLevel+AddLevel, 0, 180); //Cap is currently 3 minutes.
}

//MADDERS: Add to our current blood soak level. Messy.
function AddWaterLevel(int AddLevel)
{
	local Inventory I;
	local DeusExWeapon DXW;
	
	if (Human(Self) != None)
	{
		Human(Self).dripRate = FClamp(Human(Self).DripRate + AddLevel, 0, 15);
	}
	for(I = Inventory; I != None; I = I.Inventory)
	{
		DXW = DeusExWeapon(I);
		if (DXW != None)
		{
			DXW.VMDIncreaseWaterLogLevel(AddLevel);
		}
	}
}

exec function InvokeBindName(String S)
{
	local VMDBufferPawn VMP;
	
 	InvokedBindName = S;
 	BindName = S;
 	ConBindEvents();
	
	forEach AllActors(class'VMDBufferPawn', VMP)
	{
		VMP.VMDConvoBindHook();
	}
}

//MADDERS: Splash off some blood when underwater.
function VMDZoneChangeHook(ZoneInfo NewZone)
{
 	local int BL;
 	
 	BL = VMDGetBloodLevel();
 	if ((NewZone != None) && (NewZone.bWaterZone))
 	{
		if (ZymeSmellLevel > 0)
		{
			ZymeSmellLevel = FClamp(ZymeSmellLevel - 30, 0, 180);
		}
		if (SmokeSmellLevel > 0)
		{
			SmokeSmellLevel -= FClamp(SmokeSmellLevel - 30, 0, 180);
		}
		
  		if (BL == 2)
  		{
   			Spawn(class'BloodCloudEffectLarge',,,Location+(Velocity/60));
   			BloodSmellLevel -= 25;
  		}
  		else if (BL == 1)
  		{
   			Spawn(class'BloodCloudEffectSmall',,,Location+(Velocity/60));
   			BloodSmellLevel -= 15;
  		}
 	}
}

function int VMDConfigureInvSlotsX(Inventory I)
{
	if (I == None) return 0;
	
 	if (DeusExWeapon(I) != None) return DeusExWeapon(I).VMDConfigureInvSlotsX(Self);
	if (DeusExPickup(I) != None) return DeusExPickup(I).VMDConfigureInvSlotsX(Self);
 	return I.InvSlotsX;
}
function int VMDConfigureInvSlotsY(Inventory I)
{
	if (I == None) return 0;
	
 	if (DeusExWeapon(I) != None) return DeusExWeapon(I).VMDConfigureInvSlotsY(Self);
	if (DeusExPickup(I) != None) return DeusExPickup(I).VMDConfigureInvSlotsY(Self);
 	return I.InvSlotsY;
}

//MADDERS: Sneaky boi. Used in healing rollover via persona health screen.
//For cleanliness sake.
function int HealPlayerSilent(int baseHealPoints, optional Bool bUseMedicineSkill)
{
	local float mult, GMult;
	local int adjustedHealAmount, aha2, tempaha;
	local int origHealAmount;
	local float dividedHealAmount;

	if (bUseMedicineSkill)
		adjustedHealAmount = CalculateSkillHealAmount(baseHealPoints);
	else
		adjustedHealAmount = baseHealPoints;

	origHealAmount = adjustedHealAmount;

	if (adjustedHealAmount > 0)
	{
		if (bUseMedicineSkill)
		{
			GMult = 1.0;
			if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
			
			if (HeadRegion.Zone.bWaterZone) PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 0.7 * GMult);
			else PlaySound(sound'MedicalHiss', SLOT_None,,, 256, GMult);
		}
		
		// Heal by 3 regions via multiplayer game
		if (( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer ))
		{
         		// DEUS_EX AMSD If legs broken, heal them a little bit first
         		if (HealthLegLeft == 0)
         		{
            			aha2 = adjustedHealAmount;
            			if (aha2 >= 5)
               				aha2 = 5;
            			tempaha = aha2;
            			adjustedHealAmount = adjustedHealAmount - aha2;
            			HealPart(HealthLegLeft, aha2);
            			HealPart(HealthLegRight,tempaha);
				mpMsgServerFlags = mpMsgServerFlags & (~MPSERVERFLAG_LostLegs);
         		}
			HealPart(HealthHead, adjustedHealAmount);

			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				HealPart(HealthTorso, aha2);
				aha2 = adjustedHealAmount;
				HealPart(HealthArmRight,aha2);
				HealPart(HealthArmLeft, adjustedHealAmount);
			}
			if ( adjustedHealAmount > 0 )
			{
				aha2 = adjustedHealAmount;
				HealPart(HealthLegRight, aha2);
				HealPart(HealthLegLeft, adjustedHealAmount);
			}
		}
		else
		{
			HealPart(HealthHead, adjustedHealAmount);
			HealPart(HealthTorso, adjustedHealAmount);
			HealPart(HealthLegRight, adjustedHealAmount);
			HealPart(HealthLegLeft, adjustedHealAmount);
			HealPart(HealthArmRight, adjustedHealAmount);
			HealPart(HealthArmLeft, adjustedHealAmount);
		}

		GenerateTotalHealth();

		adjustedHealAmount = origHealAmount - adjustedHealAmount;

		/*if (origHealAmount == baseHealPoints)
		{
			if (adjustedHealAmount == 1)
				ClientMessage(Sprintf(HealedPointLabel, adjustedHealAmount));
			else
				ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));
		}
		else
		{
			ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));
		}*/
	}
	
	VMDReevaluateDroneHealing();
	
	return adjustedHealAmount;
}

exec function AddSkillPoints(int NewAmount)
{
	if (!bCheatsEnabled) return;
	
	SkillPointsAdd(NewAmount);
}

exec function RespecTalents()
{
	if (!bCheatsEnabled) return;
	
	SetupSkillAugmentManager();
	SetupCraftingManager();
	
	ResetSkillAugments();
	FormatSkillAugmentPointsLeft();
}

exec function VMDSingleSet(string Params)
{	
 	local string A, B;
 	local int IS;
 	local Actor HitTar;
 	local Vector Start, End, Norm, Loc;
	
	if (!bCheatsEnabled) return;
	 	
 	IS = InStr(Params, " ");
 	A = Left(Params, IS);
 	B = Right(Params, Len(Params) - 1 - IS);
 	
 	Start = Location + (Vect(0,0,1) * BaseEyeHeight);
 	End = Start + (Vector(ViewRotation) * 10000);
 	
 	HitTar = Trace(Loc, Norm, End, Start, true);
 	if ((HitTar != None) && (HitTar != Level))
 	{
  		HitTar.SetPropertyText(A, B);
  		ClientMessage("Set"@HitTar@"'s property of"@A@"to"@B$"!");
	}
}

function VMDProcessDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local float AugLevel, SkillLevel;
	local Inventory I;
	
	if (bNintendoImmunity || ReducedDamageType == 'All')
		return;
	
	switch(ReducedDamageType)
	{
		case 'EMP':
		case 'Nanovirus':
			return;
		break;
	}
	
	SkillLevel = VMDConfigurePickupDamageMult(DamageType, Damage, HitLocation);
	
	AugLevel = 1.0;
	if (VMDBufferAugmentationManager(AugmentationSystem) != None)
	{
		AugLevel = (VMDBufferAugmentationManager(AugmentationSystem).VMDConfigureDamageMult(DamageType, Damage, HitLocation));
	}
	
	//MADDERS: Pain underwater saps our swim timer. Blurb.
	if ((HeadRegion.Zone.bWaterZone) && (!HasSkillAugment('SwimmingDrowningRate'))) SwimTimer -= Damage * 0.33 * AugLevel * SkillLevel;
	
	//MADDERS: Add gunk to our gear from our fall. Not even just what's in hand.
	if ((DamageType == 'Fell') && (Inventory != None))
	{
		for(I = Inventory; I != None; I = I.Inventory)
		{
			if (DeusExWeapon(I) != None)
			{
				DeusExWeapon(I).VMDIncreaseGrimeLevel(Damage);
			}
		}
	}
	
	if (DamageType == 'Burned')
	{
		SmokeSmellLevel += Damage * 2.5;
	}
	if (DamageType == 'Flamed')
	{
		SmokeSmellLevel += Damage * 6;
	}
	
	//MADDERS: Anxiety = damage. Yeet.
	if (bStressEnabled)
	{
		VMDModPlayerStress(Damage*0.25*AugLevel*SkillLevel, true, 2, true);
	}
}

function float GetStressFloor()
{
	local int HT;
	local float Ret, HM;
	local TimerDisplay TTimer;
	
	//MADDERS, 5/17/22: Get absolutey thrown out of our minds.
	if (VMDHasBuffType(class'CombatStimAura')) return 100.0;
	
	//MADDERS, 1/31/21: Buff time, bby.
	if (VMDHasBuffType(class'ZymeArmorAura') || VMDHasBuffType(class'CigarettesBuffAura')) return 0.0;
	
	//MADDERS: First calculate health.
	HT = VMDGetHealthTotal();
	HM = (HT / (600*GetHealthMult("ALL")));
	Ret = FClamp(Ret + ((1.0 - HM) * 100 * UnivStressScales[2]) - 0.1, 0, GetStressCeiling());
	
	//Then calculate spooky shit.
	if (CountScaryAnimals() > 0) Ret = FClamp(Ret + (CountScaryAnimals() * 5), 0, GetStressCeiling());
	
	//Then calculate hunger level. It used to be called "MarkieTimer"
	if (HungerTimer > HungerCap * 0.7)
	{
		if (HungerTimer > HungerCap * 0.85) Ret = FClamp(Ret+30.0, 0, GetStressCeiling());
		else Ret = FClamp(Ret+15.0, 0, GetStressCeiling());
	}
	
	if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).HUD != None))
	{
		TTimer = DeusExRootWindow(RootWindow).HUD.Timer;
		if ((TTimer != None) && (TTimer.Message ~= "Rocket Launch") && (TTimer.Time < 300))
		{
			Ret += ((300.0 - TTimer.Time) / 3.0);
		}
		Ret = FClamp(Ret, 0, GetStressCeiling());
	}
	
	return Ret;
}

function float GetStressCeiling()
{
	local float Ret;
	
	//MADDERS, 5/17/22: Get absolutely thrown out of our minds.
	if (VMDHasBuffType(class'CombatStimAura')) return 100.0;
	
	Ret = 100.0;
	Ret = FClamp(Ret - (DrugEffectTimer*2), 25, 100);
	
	return Ret;
}

function int VMDGetHealthTotal()
{
 	return (HealthHead+HealthTorso+HealthArmLeft+HealthArmRight+HealthLegLeft+HealthLegRight);
}

function ForceAugOverride()
{
	local AugmentationManager NewAug;
	
	if ((VMDIsBurdenPlayer()) && (AugmentationSystem != None) && (AugmentationSystem.FindAugmentation(class'AugLight') != None))
	{
		AugmentationSystem.Destroy();
		AugmentationSystem = None;
	}
	
	//-------------------------
	//MADDERS: Thanks to sorcery, we have to cast this.
	//Somehow non-VMD aug managers keep spawning.
	//Notepad++ can't find SHIT on the cause. Spooky AF.
	//=========================
	//UPDATE: The engine is spawning the old aug
	//manager by pure magic. Fuck it. Just bury 'em.
	//It only does it once per new map. WTF.
	if (VMDBufferAugmentationManager(AugmentationSystem) == None || (VMDMechAugmentationManager(AugmentationSystem) != None) != bMechAugs)
	{
		if (bMechAugs)
		{
			NewAug = Spawn(class'VMDMechAugmentationManager', Self);
		}
		else
		{
			NewAug = Spawn(class'VMDBufferAugmentationManager', Self);
		}
		
		if (NewAug != None)
		{
			NewAug.CreateAugmentations(Self);
			if (!VMDIsBurdenPlayer())
			{
				NewAug.AddDefaultAugmentations();        
				NewAug.SetOwner(Self);
				
				//Slick hack. Give us all your shiat.
				if (AugmentationSystem != None)
				{
					NewAug.FirstAug = AugmentationSystem.FirstAug;
				}
			}
			AugmentationSystem = NewAug;
		}
	}
	else
	{
		AugmentationSystem.SetPlayer(Self);
		AugmentationSystem.SetOwner(Self);
	}
}

function VMDForceColorUpdate()
{
	local ColorTheme GHT, GMT;
	
	if (ThemeManager != None)
	{
		//MADDERS, 9/14/21: Note that these will not be added if already had.
		ThemeManager.AddTheme(class'ColorThemeMenu_VMDPhase1');
		ThemeManager.AddTheme(class'ColorThemeHUD_VMDPhase1');
		ThemeManager.AddTheme(class'ColorThemeMenu_VMDPhase2');
		ThemeManager.AddTheme(class'ColorThemeHUD_VMDPhase2');
		
		GMT = ThemeManager.GetCurrentMenuColorTheme();
		GHT = ThemeManager.GetCurrentHUDColorTheme();
		
		if (ColorThemeMenu_VMD(GMT) != None)
		{
			MenuThemeName = "VMD PH1";
			SaveConfig();
			ThemeManager.SetMenuThemeByName(MenuThemeName);
			ThemeManager.DeleteColorThemeAdvanced("VMD", 0);
		}
		if (ColorThemeHUD_VMD(GHT) != None)
		{
			HUDThemeName = "VMD PH1";
			SaveConfig();
			ThemeManager.SetHUDThemeByName(HUDThemeName);
			ThemeManager.DeleteColorThemeAdvanced("VMD", 1);
			
			if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootwindow(RootWindow).HUD != None))
			{
				DeusExRootWindow(RootWindow).HUD.ChangeStyle();
			}
		}
	}
}

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
	local DeusExWeapon DXW;
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	
 	if (bCheckOnly) return;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		DXW = DeusExWeapon(Inv);
		
  		if ((DXP != None) && (!DXP.IsA('ChargedPickup') || ChargedPickup(DXP).bIsActive))
		{
   			DXP.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
		else if (DXW != None)
		{
			DXW.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
	}
}

function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
 	local DeusExPickup DXP;
	local DeusExWeapon DXW;
 	local Inventory Inv;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		DXW = DeusExWeapon(Inv);
		
  		if ((DXP != None) && (!DXP.IsA('ChargedPickup') || ChargedPickup(DXP).bIsActive))
		{
   			Ret *= DXP.VMDConfigurePickupDamageMult(DT, HitDamage, HitLocation);
		}
		else if (DXW != None)
		{
			Ret *= DXW.VMDConfigurePickupDamageMult(DT, HitDamage, HitLocation);
		}
 	}
	
	if (Ret < 0) Ret = 1.0;
 	
 	return Ret;
}

function bool HasRollObjection(bool bManualRoll)
{
	local int TRollDir;
 	local Vector HN, HL, TVel;
 	local Actor HitAct;
 	
	if (RollTimer > 0 || DodgeRollTimer > 0) return true;	
	
	//MADDERS: Don't allow for leg damage and non-straight trajectory.
	if (HealthLegLeft < 1 || HealthLegRight < 1) return true;
 	if (Abs((Velocity << Rotation).Y) > 80) return true;
	if (CarriedDecoration != None || VMDPOVDeco(InHand) != None || POVCorpse(InHand) != None) return true;
	
	//MADDERS, 4/12/21: Don't let us mid-air roll without jumpduck. Thanks.
	if ((Physics == PHYS_Falling) && (bManualRoll) && (!HasSkillAugment('SwimmingFitness'))) return true;
	
	//MADDERs, 1/16/21: Don't allow rolling without sufficient X/Y movement.
	TVel = Velocity;
	TVel.Z = 0;
	if (VSize(TVel) < 20) return true;
	
 	if (RollCooldownTimer > 0.0) return true;
 	if (bDuck == 0) return true;
 	if (VMDUsingLadder()) return true;
	
	TRollDir = 1;
	if ((Velocity << Rotation).X < 0) TRollDir = -1;
	
 	HitAct = Trace(HL, HN, Location + ((vect(4.0, 0, 0) * TRollDir * CollisionRadius) + (vect(0,0,-1) * (CollisionHeight-MaxStepHeight)) >> Rotation), Location, true, (vect(0, 2.0, 0) * CollisionRadius) >> Rotation);
	if (HitAct == Level || Mover(HitAct) != None)
	{
		if ((Abs(HN.Z) > 0) && (Abs(HN.Z) <= 0.7071)) //Square root of 2, AKA, 45 degrees.
		{
			return true;
		}
	}
 	else if (HitAct != None)
 	{
		return true;
 	}
	
 	return false;
}

//MADDERS: Allow for shwifty rolls.
function InitiatePlayerRoll(int NewRollDir)
{
	local float GSpeed;
	local Vector InSpeed;
	local RollCooldownAura RCA;
	
	bWasFallRoll = false;
	InSpeed = GetCurrentGroundSpeed() * vect(1,0,0) * NewRollDir;
	RollDir = NewRollDir;
	
	RollCapAccel = VSize(InSpeed);
	RollTimer = RollDuration;
	if (HasSkillAugment('SwimmingCoreWorkout'))
	{
		RollCooldownTimer = RollCooldown * 0.75;
	}
	else
	{
		RollCooldownTimer = RollCooldown;
	}
	
	//MADDERS, 8/9/23: Keeping example due to unique status update.
	RCA = RollCooldownAura(FindInventoryType(class'RollCooldownAura'));
	if (RCA == None)
	{
		RCA = Spawn(class'RollCooldownAura');
		RCA.Frob(Self, None);
		RCA.Activate();
	}
	else
	{
		RCA.Charge = 450;
		RCA.UpdateAugmentStatus();
	}
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	//PlaySound(Sound'BodyHit',SLOT_Interact,,,96, GSpeed);
	PlaySound(Sound'DodgeRoll',SLOT_Interact,,,96, GSpeed);
}

function bool HasDodgeRollObjection(EDodgeDir DodgeMove)
{
 	local Vector HN, HL;
 	local Actor HitAct;
 	
	if (RollTimer > 0 || DodgeRollTimer > 0) return true;	
	
	//MADDERS: Don't allow for leg damage and non-straight trajectory.
	if (HealthLegLeft < 1 || HealthLegRight < 1) return true;
	if (CarriedDecoration != None || VMDPOVDeco(InHand) != None || POVCorpse(InHand) != None) return true;
 	if (DodgeRollCooldownTimer > 0.0) return true;
 	if (VMDUsingLadder()) return true;
	
	switch(DodgeMove)
	{
		case DODGE_Forward:
			HitAct = Trace(HL, HN, Location + ((vect(4.0, 0, 0) * CollisionRadius) + (vect(0,0,-1) * (CollisionHeight-MaxStepHeight)) >> Rotation), Location, true, (vect(0, 2.0, 0) * CollisionRadius) >> Rotation);
		break;
		case DODGE_Back:
			HitAct = Trace(HL, HN, Location + ((vect(-4.0, 0, 0) * CollisionRadius) + (vect(0,0,-1) * (CollisionHeight-MaxStepHeight)) >> Rotation), Location, true, (vect(0, 2.0, 0) * CollisionRadius) >> Rotation);
		break;
		case DODGE_Left:
			HitAct = Trace(HL, HN, Location + ((vect(0, 4.0, 0) * CollisionRadius) + (vect(0,0,-1) * (CollisionHeight-MaxStepHeight)) >> Rotation), Location, true, (vect(2.0, 0, 0) * CollisionRadius) >> Rotation);
		break;
		case DODGE_Right:
			HitAct = Trace(HL, HN, Location + ((vect(0, -4.0, 0) * CollisionRadius) + (vect(0,0,-1) * (CollisionHeight-MaxStepHeight)) >> Rotation), Location, true, (vect(2.0, 0, 0) * CollisionRadius) >> Rotation);
		break;
	}
	
	if (HitAct == Level || Mover(HitAct) != None)
	{
		if ((Abs(HN.Z) > 0) && (Abs(HN.Z) <= 0.7071)) //Square root of 2, AKA, 45 degrees.
		{
			return true;
		}
	}
	
 	return false;
}

//MADDERS: Allow for shwifty rolls.
function InitiatePlayerDodgeRoll(EDodgeDir DodgeMove, Vector InSpeed)
{
	local float GSpeed;
	local DodgeRollCooldownAura DRCA;
	
	InSpeed = (FMax(VSize(InSpeed), GetCurrentGroundSpeed()) * Normal(InSpeed));
	switch(DodgeMove)
	{
		case DODGE_Forward:
			InSpeed = GetCurrentGroundSpeed() * vect(1,0,0);
			VMDDodgeDir = 1;
		break;
		case DODGE_Back:
			InSpeed = GetCurrentGroundSpeed() * vect(-1,0,0);
			VMDDodgeDir = -1;
		break;
		case DODGE_Left:
			InSpeed = GetCurrentGroundSpeed() * vect(0,1,0);
			VMDDodgeDir = -2;
		break;
		case DODGE_Right:
			VMDDodgeDir = 2;
			InSpeed = GetCurrentGroundSpeed() * vect(0,-1,0);
		break;
	}
	
	SetPhysics(PHYS_Falling);
	//Velocity.Z += VMDConfigureJumpZ() * 1.0;
	Velocity.Z += Default.JumpZ * 1.0;
	
	DodgeRollCapAccel = VSize(InSpeed);
	DodgeRollTimer = DodgeRollDuration;
	DodgeRollCooldownTimer = DodgeRollCooldown;
	
	//MADDERS, 8/9/23: Keeping example due to unique status update.
	DRCA = DodgeRollCooldownAura(FindInventoryType(class'DodgeRollCooldownAura'));
	if (DRCA == None)
	{
		DRCA = Spawn(class'DodgeRollCooldownAura');
		DRCA.Frob(Self, None);
		DRCA.Activate();
	}
	else
	{
		DRCA.Charge = 400;
		DRCA.UpdateAugmentStatus();
	}
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	//PlaySound(Sound'BodyHit',,,,96, 1.1 * GSpeed);
	if (!bAssignedFemale)
	{
		PlaySound(sound'MaleJumpDuck', SLOT_None,,,, GSpeed);
	}
	else
	{
		PlaySound(sound'VMDFJCJumpDuck', SLOT_None,,,, GSpeed);
	}
}

//====================================================
//MADDERS: Patch anim issues
//====================================================
function AttemptPlayAnim(name S, optional float R, optional float T)
{
 	if (HasAnim(S))
	{
		if (R > 0.0)
		{
			if (T > 0.0)
			{
				PlayAnim(S, R, T);
			}
			else
			{
				PlayAnim(S, R);
			}
		}
		else
		{
			if (T > 0.0)
			{
				PlayAnim(S,,T);
			}
			else
			{
				PlayAnim(S);
			}
		}
	}
	else
	{
		switch(S)
		{
			case 'Walk2H':
				AttemptPlayAnim('Walk', R, T);
			break;
			case 'Strafe2H':
				AttemptPlayAnim('Strafe', R, T);
			break;
			case 'RunShoot2H':
				AttemptPlayAnim('RunShoot', R, T);
			break;
			case 'Shoot2H':
				AttemptPlayAnim('Shoot', R, T);
			break;
			case 'BreatheLight2H':
				AttemptPlayAnim('BreatheLight', R, T);
			break;
			case 'Idle12H':
				AttemptPlayAnim('Idle1', R, T);
			break;
		}
	}
}
function AttemptLoopAnim(name S, optional float R, optional float T, optional float M)
{
 	if (HasAnim(S))
	{
		if (R > 0.0)
		{
			if (T > 0.0)
			{
				if (M > 0.0)
				{
					LoopAnim(S, R, T, M);
				}
				else
				{
					LoopAnim(S, R, T);
				}
			}
			else
			{
				if (M > 0.0)
				{
					LoopAnim(S, R,, M);
				}
				else
				{
					LoopAnim(S, R);
				}
			}
		}
		else
		{
			if (T > 0.0)
			{
				if (M > 0.0)
				{
					LoopAnim(S,, T, M);
				}
				else
				{
					LoopAnim(S,, T);
				}
			}
			else
			{
				if (M > 0.0)
				{
					LoopAnim(S,,, M);
				}
				else
				{
					LoopAnim(S);
				}
			}
		}
	}
	else
	{
		switch(S)
		{
			case 'Walk2H':
				AttemptLoopAnim('Walk', R, T, M);
			break;
			case 'Strafe2H':
				AttemptLoopAnim('Strafe', R, T, M);
			break;
			case 'RunShoot2H':
				AttemptLoopAnim('RunShoot', R, T, M);
			break;
			case 'Shoot2H':
				AttemptLoopAnim('Shoot', R, T, M);
			break;
			case 'BreatheLight2H':
				AttemptLoopAnim('BreatheLight', R, T, M);
			break;
			case 'Idle12H':
				AttemptLoopAnim('Idle1', R, T, M);
			break;
		}
	}
}
function AttemptTweenAnim(name S, optional float T)
{
 	if (HasAnim(S))
	{
		TweenAnim(S, T);
	}
	else
	{
		switch(S)
		{
			case 'Walk2H':
				AttemptTweenAnim('Walk', T);
			break;
			case 'Strafe2H':
				AttemptTweenAnim('Strafe', T);
			break;
			case 'RunShoot2H':
				AttemptTweenAnim('RunShoot', T);
			break;
			case 'Shoot2H':
				AttemptTweenAnim('Shoot', T);
			break;
			case 'BreatheLight2H':
				AttemptTweenAnim('BreatheLight', T);
			break;
			case 'Idle12H':
				AttemptTweenAnim('Idle1', T);
			break;
		}
	}
}

function bool VMDHasItemDropObjection(Inventory Item)
{
	//MADDERS: Don't let us drop items in the MJ12 lab before the wipe.
	if ((VMDGetMapName() ~= "05_NYC_UNATCOMJ12Lab") && (FlagBase != None) && (!FlagBase.GetBool('MS_InventoryRemoved')))
	{
		return true;
	}
	else if ((DeusExPickup(Item) != None) && (DeusExPickup(Item).VMDHasDropObjection()))
	{
		return true;
	}
	else if ((DeusExWeapon(Item) != None) && (DeusExWeapon(Item).VMDHasDropObjection()))
	{
		return true;
	}
	
	return false;
}

function bool RejectWeaponFire()
{
 	if ((DeusExWeapon(InHand) != None) && (DeusExWeapon(InHand).VMDHasFireObjection())) return True;
 	
 	return False;
}

// ----------------------------------------------------------------------
// PlayFootStep()
//
// plays footstep sounds based on the texture group
// yes, I know this looks nasty -- I'll have to figure out a cleaner 
// way to do this
// ----------------------------------------------------------------------

simulated function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local float speedFactor, massFactor;
	local float volume, pitch, range;
	local float radius, mult;
	local float volumeMultiplier;
	local DeusExPlayer pp;
	local bool bOtherPlayer;
	local bool bSoften;
	
	//MADDERS, 3/29/21: Hack fix for fat JC making footstep noises still. Ech.
	if ((bDuck == 1 || bForceDuck) && (Physics != PHYS_Falling)) return;
	
	//MADDERS, 7/11/25: Fix for weird shit on ladders. Sometimes you can play footsteps, sometimes not.
	if (VMDUsingLadder()) return;
	
	// Only do this on ourself, since this takes into account aug stealth and such
	if ( Level.NetMode != NM_StandAlone )
		pp = DeusExPlayer( GetPlayerPawn() );

	if ( pp != Self )
		bOtherPlayer = True;
	else
		bOtherPlayer = False;

	rnd = FRand();
	
	if (bSoftenFootsteps) bSoften = true;
	
	StepSound = FootStepSound( Volume, VolumeMultiplier );

	// compute sound volume, range and pitch, based on mass and speed
	if (IsInState('PlayerSwimming') || Physics == PHYS_Swimming)
	{
		speedFactor = WaterSpeed/180.0;
	}
	else
	{
		speedFactor = VSize(Velocity)/180.0;
		
		//MADDERS, 1/29/21: Don't penalize athletics for making you faster, thanks.
		if (VMDConfigureGroundSpeed(true) > 1.0)
		{
			SpeedFactor /= VMDConfigureGroundSpeed(true);
		}
	}
	
	massFactor  = Mass/150.0;
	radius      = 375.0;
	volume      = (speedFactor+0.2) * massFactor;
	range       = radius * volume;
	pitch       = (volume+0.5);
	volume      = FClamp(volume, 0, 1.0) * 0.5;		// Hack to compensate for increased footstep volume.											
	range       = FClamp(range, 0.01, radius*4);
	pitch       = FClamp(pitch, 1.0, 1.5);
	
	//MADDERS, 9/18/22: Scale pitch and volume when limping.
	if (bLimpActive)
	{
		Pitch *= 0.75;
		Volume *= 2;
	}
	
	//MADDERS, 11/10/22: Scale pitch with slomo command.
	if ((Level != None) && (Level.Game != None))
	{
		Pitch *= Level.Game.GameSpeed;
	}
	
	//MADDERS: Configure this remotely.
	if (VMDBufferAugmentationManager(AugmentationSystem) != None)
	{
		RunSilentValue = VMDBufferAugmentationManager(AugmentationSystem).VMDConfigureNoiseMult();
	}
	
	// AugStealth decreases our footstep volume
	volume *= RunSilentValue;

	if ( Level.NetMode == NM_Standalone )
		PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
	else	// special case for multiplayer
	{
		if ( !bIsWalking )
		{
			// Tone down player's own footsteps
			if ( !bOtherPlayer )
			{
				volume *= 0.33;
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
			else // Exagerate other players sounds (range slightly greater than distance you see with vision aug)
			{
				volume *= 2.0;
				range = (class'AugVision'.Default.LevelValues[3] * 1.2);
				volume = FClamp(volume, 0, 1.0);
				PlaySound(stepSound, SLOT_Interact, volume, , range, pitch);
			}
		}
	}
	AISendEvent('LoudNoise', EAITYPE_Audio, volume*volumeMultiplier, range*volumeMultiplier);
}

function int Sign( float In )
{
 	if (In == 0) return 0;
 	
 	return int(In / Abs(In));
}

function VMDProcessMoveHook(float DT)
{
}

//MADDERS: Thankfully obsolete, since it wasn't built to be rebound.
function bool JumpIsHeld()
{
 	if ((RootWindow != None) && (RootWindow.IsKeyDown( IK_Space )))
 	{
  		return True;
 	}
 	
 	return False;
}

function ProjectHeadshotSound()
{
	local float GSpeed;
	
	if (bHitIndicatorHasAudio)
	{
		GSpeed = 1.0;
		if ((Level != None) && (Level.Game != None))
		{
			GSpeed = Level.Game.GameSpeed;
		}
		
 		PlaySound(sound'NanoSwordHitFlesh', SLOT_None,,,, GSpeed);
	}
}

function GiveCameraKick(float KPitch, float KYaw, float KRoll, float UMult, optional float VertMult)
{
 	local Rotator TR, PR;
 	
	//MADDERS, 6/5/22: Annoying when trying to read.
	if (InformationDevices(FrobTarget) != None || HackableDevices(FrobTarget) != None)
	{
		return;
	}
	
 	if (VertMult <= 0) VertMult = 1.0;
 	
	UMult *= ScreenEffectScalar;
 	TR.Pitch = KPitch * UMult * Frand() * (Rand(2) * 2 - 1) / 2;
 	TR.Yaw = KYaw * UMult * Frand() * (Rand(2) * 2 - 1) / 2;
 	TR.Roll = KRoll * UMult * Frand() * (Rand(2) * 2 - 1) / 2;
 	
 	PR = ViewRotation + TR;
 	if ((PR.Pitch > 18000) && (PR.Pitch < 32768))
 	{
  		PR.Pitch = 18000;
 	}
	else if ((PR.Pitch >= 32768) && (PR.Pitch < 49152))
	{
		PR.Pitch = 49152;
	}
 	
 	ClientSetRotation(PR);
 	ShakeView(0.25, 128, 16*VertMult);
}

function DoKillswitchWobble()
{
 	GiveCameraKick(480, 480, 320, 3.0, 0.5);
}

function UpdateKillswitchHealth( float InTime )
{
 	local float Det, ModMult;
	
	ModMult = 1.0;
	if (ModHealthMultiplier > 0) ModMult = ModHealthMultiplier;
	
 	//MADDERS: Don't do this on easy and normal.
 	if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Killswitch Health"))
 	{
 		Det = FMin(1.0, InTime / 4320.0) * 0.75;
 		KSHealMult = (1.0 - Det);
 		
 		Det = FMin(1.0, InTime / 2880) * 0.5;
 		KSHealthMult = (1.0 - Det);
 		
 		if (HealthHead > KSHealthMult * float(Default.HealthHead) * ModMult) HealthHead = ModMult * KSHealthMult * float(Default.HealthHead);
 		if (HealthTorso > KSHealthMult * float(Default.HealthTorso) * ModMult) HealthTorso = ModMult * KSHealthMult * float(Default.HealthTorso);
 		if (HealthArmLeft > KSHealthMult * float(Default.HealthArmLeft) * ModMult) HealthArmLeft = ModMult * KSHealthMult * float(Default.HealthArmLeft);
 		if (HealthArmRight > KSHealthMult * float(Default.HealthArmRight) * ModMult) HealthArmRight = ModMult * KSHealthMult * float(Default.HealthArmRight);
 		if (HealthLegLeft > KSHealthMult * float(Default.HealthLegLeft) * ModMult) HealthLegLeft = ModMult * KSHealthMult * float(Default.HealthLegLeft);
 		if (HealthLegRight > KSHealthMult * float(Default.HealthLegRight) * ModMult) HealthLegRight = ModMult * KSHealthMult * float(Default.HealthLegRight);
	}
	else
	{
 		if (HealthHead > float(Default.HealthHead) * ModMult) HealthHead = ModMult * float(Default.HealthHead);
 		if (HealthTorso > float(Default.HealthTorso) * ModMult) HealthTorso = ModMult * float(Default.HealthTorso);
 		if (HealthArmLeft > float(Default.HealthArmLeft) * ModMult) HealthArmLeft = ModMult * float(Default.HealthArmLeft);
 		if (HealthArmRight > float(Default.HealthArmRight) * ModMult) HealthArmRight = ModMult * float(Default.HealthArmRight);
 		if (HealthLegLeft > float(Default.HealthLegLeft) * ModMult) HealthLegLeft = ModMult * float(Default.HealthLegLeft);
 		if (HealthLegRight > float(Default.HealthLegRight) * ModMult) HealthLegRight = ModMult * float(Default.HealthLegRight);
	}
}

function RunKillswitchEffects(float DT)
{
 	local float DiffMult;
	local DeusExGoal NewGoal;
	
 	if (!bKillswitchEngaged || !bImmersiveKillswitch) return;
	if (VMDHasForwardPressureObjection()) return;
 	
 	if (FlagBase.GetBool('DL_TongFixesKillswitch2_Played'))
 	{
		BigClientMessage(KillswitchStateDescs[7]);
  		UpdateKillswitchHealth(0);
  		KillswitchTime = 0;
		KillswitchPhase = 0;
  		bKillswitchEngaged = False;
		
		if (FindGoal('VMDMeetTongPostKS') == None)
		{
			NewGoal = AddGoal('VMDMeetTongPostKS', true);
			NewGoal.SetText(StrPostKillswitchFudge);
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMDCheckForTongGoal', true,, 7);
			}
		}
		
  		return;
 	}
 	
 	//72*60 = 4320
 	if (KillswitchTime > (4320))
 	{
  		if (KSWobbleTimer > 0)
  		{
   			KSWobbleTimer -= DT;
  		}
  		else
  		{
   			KSWobbleTimer = 1.25;
   			DoKillswitchWobble();
  		}
 	}
 	
 	DiffMult = Sqrt(TimerDifficulty)/2.0;
	
 	//96*60 = 5760
 	if (KillswitchTime < (5760))
 	{
  		UpdateKillswitchHealth(KillswitchTime);
  		KillswitchTime += DT * DiffMult;
		if ((KillswitchPhase < 7) && (KillswitchTime > KillswitchThresholds[KillswitchPhase+1]))
		{
			BigClientMessage(KillswitchStateDescs[KillswitchPhase+1]);
			KillswitchPhase += 1;
		}
 	}
 	else
	{
		KillswitchTime = 5760 + ((KillswitchTime-5760) % (1.0*DiffMult)) + (DT*DiffMult);
		if (Frand()*10 < DT)
 		{
  			TakeDamage(5, Self, Location+VMDGetLimbOffset(Rand(6)), vect(0,0,0), 'Killswitch');
		}
 	}
}

function BroadUpdateKillswitch()
{
	local float TEnergy;
	
 	if (!bKillswitchEngaged || !bImmersiveKillswitch || bNoKillswitchEnergyDrain) return;
	
 	if (Energy > 0)
 	{
		if (LastEnergy <= 0) ClientMessage(EnergyBackfireDesc);
		
		TEnergy = FMax(Energy / 15, 3.0);
		
		KillswitchTime += TEnergy*5;
		//TakeDamage(TEnergy, Self, Location, vect(0,0,0), 'Killswitch');
		
  		Energy = Clamp(Energy-TEnergy, 0, EnergyMax);
 	}
	LastEnergy = Energy;
}

function bool IsOverdosed()
{
 	if ((OverdoseTimers[4] <= (AddictionThresholds[4]*2.5)) && (OverdoseTimers[3] < (AddictionThresholds[3]*0.3)) && (WaterBuildup < 300))
	{
		return false;
	}
 	return true;
}

function RunOverdoseEffects(float DT)
{
 	local float ODWeight;
 	
 	if (!IsOverdosed())
	{
		bLastOverdosed = false;
		return;
 	}
	
	if (!bLastOverdosed)
	{
		//Zyme
		if (OverdoseTimers[4] > AddictionThresholds[4]*2.5)
		{
			ClientMessage(OverdoseDescs[0]);
		}
		//Alcohol
		if (OverdoseTimers[3] > AddictionThresholds[3]*3)
		{
			ClientMessage(OverdoseDescs[1]);
		}
		//Water
		if (WaterBuildup >= 300)
		{
			ClientMessage(OverdoseDescs[2]);
		}
	}
	
 	if (OverdoseTimer > 0)
 	{
  		OverdoseTimer -= DT;
 	}
 	else
 	{
  		OverdoseTimer = 0.25;
  		DoKillswitchWobble();
 	}
 	
 	ODWeight = Max(AddictionTimers[4]-600, AddictionTimers[3]-899);
 	ODWeight = FClamp(int((ODWeight + 20.0) / 20.0), 1, 11);
 	
 	//MADDERS: Water poisoning is very mild.
 	if (WaterBuildup > 305)
	{
		if (WaterBuildup > 325) WaterBuildup = 325;
		
		ODWeight = 1.0;
		if ((Frand()*2.65)/(ODWeight) < DT)
		{
			ODWeight = 0.0;
			TakeDamage(3, Self, Location, vect(0,0,0), 'Overdose');
			WaterBuildup -= 10.0;
		}
 	}
	else if ((WaterBuildup < 300) && (ODWeight > 0.0))
	{
 		if ((Frand()*2.65)/(ODWeight) < DT)
 		{
  			if (ODWeight > 10) TakeDamage(5, Self, Location, vect(0,0,0), 'Overdose');
  			else if (ODWeight > 5) TakeDamage(4, Self, Location, vect(0,0,0), 'Overdose');
  			else TakeDamage(3, Self, Location, vect(0,0,0), 'Overdose');
 		}
	}
	bLastOverdosed = true;
}

function float VMDConfigureAimModifier()
{
 	local float TAdd, TMult;
 	
	if (IsInState('PlayerWalking'))
	{
		if (bUseGunplayVersionTwo)
		{
			TMult = 1.0;
			if (DeusExWeapon(InHand) != None)
			{
				TMult = DeusExWeapon(InHand).FactorWM2ADSMultiplier();
			}
			
			//MADDERS, 5/4/25: In GP2, no penalty for not ducking, but reduced bonus. Walking also gives us this bonus.
 			if ((bDuck == 1) && (!bForceDuck || HealthLegLeft > 0 || HealthLegRight > 0))
			{
				TAdd -= 0.10 * TMult;
			}
			else if (bIsWalking)
			{
				TAdd -= 0.10 * TMult;
			}
		}
		else
		{
 			TAdd += 0.05; //Balance the equation.
 			if ((bDuck == 1) && (!bForceDuck || HealthLegLeft > 0 || HealthLegRight > 0))
			{
				TAdd -= 0.15; //MADDERS: Provide a boost for crouch shooting!
			}
		}
 	}
	
	if (IsInState('PlayerSwimming'))
	{
		if (HasSkillAugment('SwimmingDrowningRate'))
		{
			TAdd -= 0.3;
		}
	}
	
 	//Alcohol lowers base accuracy by 10%.
 	if ((AddictionStates[3] > 0) && (AddictionTimers[3] <= 0)) TAdd += 0.2;
 	
	//MADDERS, 8/29/23: Nerf aim for rolling around. Kinda makes sense. Dodge roll especially, since it's defensive.
	if (RollTimer > 0)
	{
		TAdd += 0.125;
	}
	else if (DodgeRollTimer > 0)
	{
		TAdd += 0.25;
	}
	
 	return TAdd;
}

function float ConfigureVMDAimSpeed()
{
 	local float TMult;
 	
 	//Nicotene and crack slow aim speeds during withdrawal.
 	TMult = 1.0;
	
 	if ((AddictionStates[2] > 0) && (AddictionTimers[2] <= 0)) TMult *= 0.8;
 	if ((AddictionStates[4] > 0) && (AddictionTimers[4] <= 0)) TMult *= 0.8;
 	if (bInverseAim) TMult *= -1;
 	
	if ((bStressEnabled) && (!IsA('Trestkon')))
	{
 		if (ActiveStress > 80)
 		{
  			TMult *= 0.65;
 		}
 		else if (ActiveStress > 60) TMult *= 0.84;
 		else if (ActiveStress > 30) TMult *= 1.0;
 		else TMult *= 1.25;
 	}
	//MADDERS: QOL nonsense.
	else
	{
		TMult *= 1.125;
	}
	
	if (VMDHasBuffType(class'SodaBuffAura'))
	{
		TMult *= 1.65;
	}
	if (VMDHasBuffType(class'CombatStimAura'))
	{
		TMult *= 1.65;
	}
	
 	return TMult;
}

//MADDERS: This is kinda shitty, and isn't modular for changing JumpZ on the fly, but it is what it is.
//This fixes the exploit with pause menu stacking the buffs from AugSpeed.
function float VMDConfigureJumpZ()
{
	local float Ret;
	local Augmentation AS;
	
	Ret = JumpZ;
	
	if (VMDBufferAugmentationManager(AugmentationSystem) != None)
	{
		Ret *= VMDBufferAugmentationManager(AugmentationSystem).VMDConfigureJumpMult();
	}
	
	return Ret;
}

function float VMDConfigureGroundSpeed(optional bool bNoiseReductionOnly)
{
	local bool bLeftFirst, bRunValidated, FlagRunning, bTrestkon;
	local int FitnessLevel;
	local float TMult, TMath, OAnimFrame;
	
	TMult = 1.0;
	
	bLimpActive = false;
	OAnimFrame = AnimFrame;
	
	bTrestkon = IsA('Trestkon');
	
	//Swimming scales speed slightly now, being "Fitness".
	if ((SkillSystem != None) && (!bTrestkon))
	{
		FitnessLevel = SkillSystem.GetSkillLevel(class'SkillSwimming');
		switch(FitnessLevel)
		{
			case 0:
				TMult *= 0.925;
			break;
			case 2:
				TMult *= 1.075;
			break;
			case 3:
				TMult *= 1.15;
			break;
		}
	}
	
	//Sugar, caffeine, and crack withdrawal slows you down 20%.
	//MADDERS patch: Don't stack these. For the love of god.
	//Note 3: Sugar doesn't slow anymore. That's just too much.
	//if ((AddictionStates[0] > 0) && (AddictionTimers[0] <= 0) && (!bTrestkon)) TMult *= 0.8;
	if ((AddictionStates[1] > 0) && (AddictionTimers[1] <= 0) && (!bTrestkon)) TMult *= 0.8;
	
	//MADDERS, 12/23/23: Slap on a tax-free bonus to counteract our lost speed with tilt effects throwing off our view all the damn time.
	if ((InHand == None) && (bPlayerHandsEnabled) && (bAllowPlayerHandsTiltEffects))
	{
		TMult *= 1.0006;
	}
	
	if (!bNoiseReductionOnly)
	{
		//MADDERS, 12/23/23: You now run faster with empty hands, in exchange for that 0.3 seconds of swap time.
		if ((InHand == None) && (bPlayerHandsEnabled))
		{
			TMult *= 1.05;
		}
		
		//MADDERS, 2/10/21: Candy speed buff? Hell yeah.
		if (VMDHasBuffType(class'CandyBuffAura'))
		{
			TMult *= 1.15;
		}
		if (VMDHasBuffType(class'CombatStimAura'))
		{
			TMult *= 1.35;
		}
	}
	
	//If using energy armor, allow for a patch for low armor increasing speed. Scale total energy upwards for what this means relatively?
	if (ModGroundSpeedMultiplier >= 0)
	{
 		TMult *= ModGroundSpeedMultiplier;
	}
	
	//Rolling makes you faster
	if (RollTimer > 0)
	{
		TMult *= 3.5;
	}
	//Dodge rolling makes you kinda fast, but not too much.
	else if (DodgeRollTimer > 0)
	{
		if (!bNoiseReductionOnly) //Irrelevant?
		{
			TMult *= 0.45;
		}
	}
	//On nightmare or gallows, force advanced limb damage.
	else if (VMDDoAdvancedLimbDamage())
	{
		switch(AnimSequence)
		{
			case 'Walk':
			case 'Walk2H':
			case 'CrouchWalk':
			case 'CrouchWalk2H':
				bLeftFirst = true;
				bRunValidated = true;
			break;
			case 'Attack':
			case 'AttackSide':
			case 'Run':
			case 'Run2H':
			case 'Strafe':
			case 'Strafe2H':
			case 'RunShoot':
			case 'RunShoot2H':
			case 'Shoot':
			case 'Shoot2H':
				FlagRunning = true;
				bRunValidated = true;
			break;
		}
		switch(Mesh.Name)
		{
			case 'GM_Trench':
			case 'GFM_Trench':
			case 'VMDGFM_Trench':
			case 'GM_Trench_F':
			case 'VMDGM_Trench_F':
			//Special cases where we're a weirdo.
			case 'VMDGFM_DressLeft':
			case 'GFM_SuitSkirtLeft':
			case 'GFM_SuitSkirt_FLeft':
			case 'GM_DressShirt_SLeft':
			case 'GM_DressShirtLeft':
			case 'GM_DressShirt_FLeft':
			case 'GM_SuitLeft':
			case 'GM_Jumpsuit':
			case 'MP_Jumpsuit':
			case 'VMDMP_Jumpsuit':
			break;
			
			case 'GM_TrenchLeft':
			case 'GFM_TrenchLeft':
			case 'GM_Trench_FLeft':
			//Special cases where we're a weirdo.
			case 'GFM_Dress':
			case 'VMDGFM_Dress':
			case 'GFM_SuitSkirt':
			case 'VMDGFM_SuitSkirt':
			case 'GFM_SuitSkirt_F':
			case 'VMDGFM_SuitSkirt_F':
			case 'GM_DressShirt_S':
			case 'GM_DressShirt':
			case 'GM_DressShirt_F':
			case 'VMDGM_DressShirt_S':
			case 'VMDGM_DressShirt':
			case 'VMDGM_DressShirt_F':
			case 'GM_Suit':
			case 'VMDGM_Suit':
			case 'MP_JumpsuitLeft':
				bLeftFirst = !bLeftFirst;
			break;
		}
		
		if (ForceLimpTime > 0)
		{
			bLimpActive = true;
			TMult = 1.0 - ForceLimpTime;
		}
		else if (bRunValidated)
		{
			if (AnimFrame > 0.5)
			{
				TMath = Clamp(Abs((1.0-AnimFrame)-0.35), 0.0, 0.15);
			}
			else
			{
				TMath = Clamp(Abs(AnimFrame-0.35), 0.0, 0.15);
			}
			
			if ((HealthLegLeft > 0) && (HealthLegRight <= 0) && ((AnimFrame < 0.5 && !bLeftFirst) || (bLeftFirst && AnimFrame > 0.5)))
			{
				bLimpActive = true;
				TMult *= 0.5 + TMath;
			}
			else if ((HealthLegRight > 0) && (HealthLegLeft <= 0) && ((AnimFrame > 0.5 && !bLeftFirst) || (bLeftFirst && AnimFrame < 0.5)))
			{
				bLimpActive = true;
				TMult *= 0.5 + TMath;
			}
		}
	}
	
	//Tasing and overdosing debilitates you massively.
	if ((TaseDuration > 0 || IsOverdosed()) && (!bTrestkon))
	{
		TMult = 0.65;
	}
	
	return TMult;
}

function StartAddiction(int TIndex)
{
	switch(TIndex)
	{
  		case 0:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_SugarAddicted', True, True, 0);
			}
  		break;
  		case 1:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_CaffeineAddicted', True, True, 0);
			}
  		break;
  		case 2:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_NicotineAddicted', True, True, 0);
			}
  		break;
  		case 3:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_AlcoholAddicted', True, True, 0);
			}
  		break;
  		case 4:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_ZymeAddicted', True, True, 0);
			}
  		break;
	}
	
	AddictionStates[TIndex] = 1;
	ClientMessage(SprintF(MsgNewHabit, GetSubstanceName(TIndex)));
}

function CureAddiction(int TIndex)
{
	//Sugar, Caffeine, Nicotine, Alcohol, Zyme
	switch(TIndex)
 	{
  		case 0:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_SugarAddicted', False, True, 0);
			}
   			bInverseAim = False;
  		break;
  		case 1:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_CaffeineAddicted', False, True, 0);
			}
  		break;
  		case 2:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_NicotineAddicted', False, True, 0);
			}
  		break;
  		case 3:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_AlcoholAddicted', False, True, 0);
			}
  		break;
  		case 4:
			if (FlagBase != None)
			{
				FlagBase.SetBool('VMD_ZymeAddicted', False, True, 0);
			}
  		break;
 	}
	
	AddictionStates[TIndex] = 0;
	AddictionKickTimers[TIndex] = 0;
	
	if ((bAddictionEnabled >= 1 && TIndex >= 2) || (bAddictionEnabled >= 2 && TIndex < 2))
	{
   		ClientMessage(SprintF(MsgKickedHabit, GetSubstanceName(TIndex)));
	}
}

function InflictAddictionWrath(int TIndex)
{
 	local Rotator TR;
 	
 	switch(TIndex)
 	{
  		case 0:
			if (bAddictionEnabled >= 2)
			{
   				//Invert our aim.
   				//MADDERS: Nerfed from 0.34, and then from 0.25, and finally from 0.15. Sugar isn't that bad.
   				if ((bInverseAim) || (FRand() < 0.1)) bInverseAim = !bInverseAim;
			}
  		break;
  		case 1:
			if (bAddictionEnabled >= 2)
			{
    				GiveCameraKick(120, 120, 90, 0.75, 0.175);
			}
  		break;
  		case 2:
  		break;
  		case 3:
			//MADDERS, 7/24/23: Kick this out, as well. Nicer drunkness, please.
   			//GiveCameraKick(160, 160, 120, 1.25, 0.25);
  		break;
  		case 4:
  		break;
 	}
}

function UpdateAddictionWrath(int TIndex, float DT)
{
 	local float TTime;
 	
	if (!ShouldAllowHungerAndStress()) return;
	
 	if (AfflictionTimers[TIndex] > 0)
 	{
  		AfflictionTimers[TIndex] -= DT;
 	}
 	if (AfflictionTimers[TIndex] <= 0)
 	{
  		//Change for any cases?
  		TTime = 2.0;
  		if (TIndex == 0) TTime = 0.5;
  		if (TIndex == 1 || TIndex == 3) TTime = 1.25;
  		
  		AfflictionTimers[TIndex] = TTime;
  		InflictAddictionWrath(TIndex);
 	}
}

function int EnemiesLeft()
{
	local int Ret;
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP != None) && (SP.GetPawnAllianceType(Self) == ALLIANCE_Hostile) && (VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant))
		{
			Ret++;
		}
	}
	
	return Ret;
}

function int EnemiesOrNeutralLeft()
{
	local int Ret;
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP != None) && (SP.GetPawnAllianceType(Self) != ALLIANCE_Friendly) && (VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant))
		{
			Ret++;
		}
	}
	
	return Ret;
}

function NumOnlookers(out int HostileCount, out int AnyCount)
{
 	local ScriptedPawn SP;
 	local int RotDif;
 	local float GDist, GDM, RDM, VD, DarkMult;
	local DeusExPlayer DXP;
	local AugmentationManager AM;
 	
	if (VMDPlayerIsCloaked()) return;
	
 	forEach RadiusActors(Class'ScriptedPawn', SP, 1920)
 	{
		// && (FastTrace(SP.Location, Location))
  		if ((SP != None) && (SP != Self) && (SP.bInWorld) && (Animal(SP) == None) && (Robot(SP) == None) && (SP.GetPawnAllianceType(Self) > 0))
  		{
			if ((VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant) && (!SP.IsInState('Stunned')) && (!SP.IsInState('RubbingEyes')))
			{
				if (SP.AICanSee(Self, SP.ComputeActorVisibility(Self), false, true, true, true) > 0)
				{
					AnyCount++;
					if (SP.GetPawnAllianceType(Self) == 2) HostileCount++;
				}
   				/*VD = SP.SightRadius / 3.0;
   				GDist = VSize(SP.Location - Location);
   				GDM = (VD - GDist) / VD;
   				RotDif = SP.Rotation.Yaw - Rotator(Location - SP.Location).Yaw;
   				RDM = Abs(RotDif);
   				
   				//MADDERS: Calculate for darkness as well. Bit of a hack, but 0.15 is cap visibility, and 0.005 is zero visibility.
   				DarkMult = FMin(1.0, ((AIGETLIGHTLEVEL(Location) - 0.005) / 0.01));
   				
   				if (RDM < 16384 * GDM * DarkMult)
   				{
					AnyCount++;
					if (SP.GetPawnAllianceType(Self) == 2) HostileCount++;
				}*/
			}
  		}
 	}
}

function UpdateStressWrath(float DT)
{
	local bool bHeartbeatObjection;
	local float TTime, KickPow, GSpeed;
 	local int HOL, AOL;
	local Rotator TR;
 	
	if (!ShouldAllowHungerAndStress() || EnemiesOrNeutralLeft() <= 0) return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
 	if (ActiveStress > 80)
 	{
		if ((DeusExWeapon(InHand) != None) && (!DeusExWeapon(InHand).bWeaponUp))
		{
			bHeartbeatObjection = true;
		}
		
		if (bEnvironmentalSoundsEnabled)
		{
			if (HeartbeatTimer > 0) HeartbeatTimer -= DT;
			else
			{
				NumOnlookers(HOL, AOL);
				
				if (MusicMode == MUS_Combat || HOL > 0 || AOL > 1)
				{
					if (!bHeartbeatObjection) PlaySound(sound'CarpetStep3',,0.5,,,LastHeartbeatPitch);
				}
				HeartbeatTimer = 20;
			}
		}
		
  		if (StressTimer > 0) StressTimer -= DT;
  		if (StressTimer <= 0)
  		{
			NumOnlookers(HOL, AOL);
			if ((bEnvironmentalSoundsEnabled) && (MusicMode == MUS_Combat || HOL > 0 || AOL > 1))
			{
				if (!bHeartbeatObjection) PlaySound(sound'CarpetStep1',,0.5,,,LastHeartbeatPitch);
				LastHeartbeatPitch = (0.95 + (FRand() * 0.1)) * GSpeed;
			}
			
   			KickPow = (ActiveStress / 100.0);
   			KickPow = (KickPow^3);
   			GiveCameraKick(320, 320, 240, 1.5*KickPow*0.25, 0.5);
   			
   			TTime = 0.85;
   			StressTimer = TTime;
			HeartbeatTimer = TTime - 0.25;
  		}
 	}
	else
	{
		HeartbeatTimer = 20;
	}
}

function UpdateTaseWrath(float DT)
{
 	local float TTime;
 	local Rotator TR;
 	
	//MADDERS, 11/8/22: Shit gets fucked up if ran in bad circumstances. Let's not.
	//if (!ShouldAllowHungerAndStress()) return;
	
 	if (TaseDuration > 0)
 	{
  		if (TaseTimer > 0) TaseTimer -= DT;
  		if (TaseTimer <= 0)
  		{
   			GiveCameraKick(640, 640, 480, 3.5, 1.0);
   			
   			TTime = 0.1;
   			TaseTimer = TTime;
  		}
  		TaseDuration -= DT;
 	}
}

function Texture RestoreNormalcy()
{
 	local Texture T;
 	
 	if (bDisableReskin)
 	{
  		return Multiskins[0];
 	}
	if (FabricatedSkins[0] != None)
	{
		return FabricatedSkins[0];
	}
 	
 	switch(PlayerSkin)
 	{
  		case 0: T = Texture'JCDentonTex0'; break;
  		case 1: T = Texture'JCDentonTex4'; break;
  		case 2: T = Texture'JCDentonTex5'; break;
  		case 3: T = Texture'JCDentonTex6'; break;
  		case 4: T = Texture'JCDentonTex7'; break;
 	}
 	
 	return T;
}

function float GetEnergyMult()
{
 	if (IsA('HatchetPlayer')) return int(GetPropertyText("MaxEnergy")) / 100.0;
 	return EnergyMax / 100.0;
}

function float GetHealthMult(string Index)
{
	local float ModMult;
	
	ModMult = 1.0;
	if (ModHealthMultiplier > 0) ModMult = ModHealthMultiplier;
	
 	switch(CAPS(Index))
 	{
  		case "ALL":
   			return (float(Default.HealthHead) + float(Default.HealthTorso) + float(Default.HealthArmLeft) + float(Default.HealthArmRight) + float(Default.HealthLegLeft) + float(Default.HealthLegRight)) / 600.0 * KSHealthMult * ModMult;
  		break;
  		case "HEAD":
   			return float(Default.HealthHead) / 100.0 * KSHealthMult * ModMult;
  		break;
  		case "TORSO":
   			return float(Default.HealthTorso) / 100.0 * KSHealthMult * ModMult;
  		break;
  		case "LEFT ARM":
   			return float(Default.HealthArmLeft) / 100.0 * KSHealthMult * ModMult;
  		break;
  		case "RIGHT ARM":
   			return float(Default.HealthArmRight) / 100.0 * KSHealthMult * ModMult;
  		break;
  		case "LEFT LEG":
   			return float(Default.HealthLegLeft) / 100.0 * KSHealthMult * ModMult;
  		break;
  		case "RIGHT LEG":
   			return float(Default.HealthLegRight) / 100.0 * KSHealthMult * ModMult;
 		break;
  		default:
   			Log("WARNING! UNKNOWN HEALTH MULT INDEX:"@Index);
  		break;
 	}
 	return 0.0;
}

function RunAddictionEffects(float DT)
{
 	local int i;
	local bool bZymeActive;
 	
 	if (WaterBuildup > 0) WaterBuildup -= DT;
 	for(i=0; i<ArrayCount(AddictionTimers); i++)
 	{
		if (ForceAddictions[i] > 0)
		{
			if (AddictionStates[i] == 0)
			{
				StartAddiction(i);
			}
			AddictionKickTimers[i] = 1200;
		}
		
		if ((i == 4) && (AddictionTimers[i] > 0)) bZymeActive = true;
		
		if (AddictionKickTimers[i] > 0) AddictionKickTimers[i] -= DT;
		if (AddictionStates[i] > 0)
		{
			if (AddictionKickTimers[i] < 0)
			{
  				CureAddiction(i);
 			}
			else if ((i >= 2 && bAddictionEnabled < 1) || (i < 2 && bAddictionEnabled < 2))
			{
				CureAddiction(i);
			}
		}
		
  		if (AddictionTimers[i] > 0)
		{
			if (i == 3)
			{
				AddictionTimers[i] -= DT * 0.015; //MADDERS, 11/16/24: Alcohol addiction builds slower, is released slower.
			}
			else
			{
				AddictionTimers[i] -= DT;
			}
		}
		
		if (OverdoseTimers[i] > 0)
		{
			OverdoseTimers[i] -= DT;
		}
		
		//MADDERS: Zyme has run out. Kick us in the teeth.
		if ((i == 4) && (AddictionTimers[i] <= 0) && (bZymeActive))
		{
			TakeDamage(Max(10, HealthTorso/4), Self, Location, Vect(0,0,0), 'DrugDamage');
			bZymeActive = false;
		}
  		
  		if ((AddictionStates[i] > 0) && (AddictionTimers[i] <= 0)) //AddictionThresholds[i]
  		{
   			UpdateAddictionWrath(i, DT);
  		}
 	}
 	if (bStressEnabled) UpdateStressWrath(DT);
 	UpdateTaseWrath(DT);
}

//MADDERS: Call this when we up the mission.
function RegisterMissionUpdate()
{
 	local DeusExLevelInfo LI;
 	local int i;
 	
 	forEach AllActors(Class'DeusExLevelInfo', LI) break;
  	
 	if ((LI.MissionNumber <= LastRecMission) && (LastRecMission < 90)) return;
 	LastRecMission = LI.MissionNumber;
 	
 	WaterBuildup = 0;
 	//Clear addictions once we've kicked the damn habit.
 	for(i=0; i<ArrayCount(AddictionStates); i++)
 	{
  		if ((AddictionStates[i] > 0) && (AddictionKickTimers[i] <= 0))
  		{
   			AddictionStates[i] = 0;
			AddictionKickTimers[i] = 0;
   			CureAddiction(i);
   			ClientMessage(SprintF(MsgKickedHabit, GetSubstanceName(i)));
  		}
  		else if (AddictionStates[i] > 0)
  		{
   			//ClientMessage(SprintF(MsgCraving, GetSubstanceName(i)));
  		}
 	}
	
	VMDUpdateMayhemLevel();
}

//Return human readable names.
function string GetSubstanceName(int i)
{
 	switch(i)
 	{
  		case 0: return SugarName; break;
  		case 1: return CaffeineName; break;
  		case 2: return NicotineName; break;
  		case 3: return AlcoholName; break;
  		case 4: return CrackName; break;
 	}
 	
 	return "ERR";
}

//MADDERS: Handle our addiction system.
function VMDAddToAddiction(string AddType, float AddAmount)
{
 	local int TGroup, i, HackAddictionBalance;
 	
	HackAddictionBalance = 1;
 	TGroup = -1;
 	
 	if (bAddictionEnabled < 1) return;
 	
 	switch(CAPS(AddType))
 	{
  		case "SUGAR": TGroup = 0; break;
  		case "CAFFEINE": TGroup = 1; break;
  		case "NICOTINE": TGroup = 2; break;
  		case "ALCOHOL": TGroup = 3; break;
  		case "CRACK":
  		case "ZYME": TGroup = 4; break;
  		case "WATER": TGroup = -99; break;
  		default: TGroup = 99; break;
 	}
	
	if ((bAddictionEnabled < 2) && (TGroup == 0 || TGroup == 1)) return;
 	
 	if ((TGroup > -1) && (TGroup < ArrayCount(AddictionTimers)))
 	{
  		if ((AddictionStates[TGroup] > 0) && (AddictionTimers[TGroup] < AddictionThresholds[TGroup]))
  		{
   			//Set baseline satisfaction, making our addiction hard-hitting.
   			//AddictionTimers[TGroup] = AddictionThresholds[TGroup];
			//---------------------
			//OVERHAUL: For non-OD'ables, set our threshold to be one below the limit, for minimal withdrawal.
			if (TGroup < 3)
			{
   				AddAmount = (AddictionThresholds[TGroup]-1);
			}
			//MADDERS, 3/26/21: Alter alcoholism time cleared per drink, to make it a more manageable addiction.
			else if ((TGroup == 3) && (AddictionTimers[TGroup] < 60))
			{
				HackAddictionBalance = 3;
				AddAmount *= 2*HackAddictionBalance;
			}
			AddictionKickTimers[TGroup] = FClamp((AddictionKickTimers[TGroup]+AddAmount), 0, 1200);
  		}
  		
		OverdoseTimers[TGroup] += AddAmount;
  		AddictionTimers[TGroup] += AddAmount;
  		if ((AddictionTimers[TGroup] > AddictionThresholds[TGroup]) && (AddictionStates[TGroup] < 1))
  		{
			StartAddiction(TGroup);
			AddictionKickTimers[TGroup] += AddictionThresholds[TGroup]*16; //Give us time before withdrawal kicks in!
  		}
 	}
 	else if (TGroup == -99)
 	{
  		DrugEffectTimer = FMax(0, DrugEffectTimer - 5);
  		for(i=0; i<ArrayCount(OverdoseTimers); i++)
  		{
   			OverdoseTimers[i] = FMax(0.0, OverdoseTimers[i] - AddAmount);
  		}
 	}
}

//MADDERS: Don't let us activate certain options!
function bool IsParseException(Actor A)
{
	local int FillerStrength;
	
 	//MOD SUPPORT! Any class with "bIsFood" as a property set to true can be eaten this way. Fuck it. Why not?
 	if (A.GetPropertyText("bIsFood") ~= "True") return False;
 	
 	//If we're not activatable, save us some work!
 	if ((DeusExPickup(A) != None) && (!DeusExPickup(A).bActivatable)) return True;
 	
 	//MADDERS: Handle vanilla like this.
 	if (VMDOtherIsName(A, "DeusEx."))
 	{
  		switch(A.Class)
  		{
			case class'SuperSoyFood': //For iff-ily supported mods.
   			case class'SoyFood':
   			case class'SodaCan':
   			case class'CandyBar':
   			case class'WineBottle':
   			case class'Liquor40oz':
   			case class'LiquorBottle':
   			case class'Medkit':
   			case class'BioelectricCell':
   			case class'Cigarettes':
   			case class'VialCrack':
			case class'VMDToolbox':
			case class'VMDChemistrySet':
			case class'VMDMedigel':
			case class'VMDCombatStim':
			
			case class'VMDMeghPickup': //9/26/22: New drone stuff.
			case class'VMDSIDDPickup': //10/10/22: New turret stuff, too.
    				return False;
   			break;
   			default:
    				return True;
   			break;
  		}
 	}
 	//And handle non-vanilla like this.
 	else if (DeusExPickup(A) != None)
 	{
  		if (VMDActorIsProbablyFood(A, FillerStrength))
  		{
   			return False;
  		}
  		//Melk, zyme, crack, cigarettes.
  		else if (VMDOtherIsName(A, "Melk") || VMDOtherIsName(A, "Zyme") || VMDOtherIsName(A, "Crack"))
  		{
   			return False;
  		}
  		else if (VMDOtherIsName(A, "Bioelectric") || VMDOtherIsName(A, "Biocell") || VMDOtherIsName(A, "Medkit"))
  		{
   			return False;
  		}
 	}
 	
 	return True;
}

function bool VMDActorIsFood(Actor A)
{
	local int FillerStrength;
	
 	//MOD SUPPORT! Any class with "bIsFood" as a property set to true can be eaten this way. Fuck it. Why not?
 	if (A.GetPropertyText("bIsFood") ~= "True") return True;
 	
 	//If we're not activatable, save us some work!
 	if ((DeusExPickup(A) != None) && (!DeusExPickup(A).bActivatable)) return False;
 	
 	//MADDERS: Handle vanilla like this.
 	if (VMDOtherIsName(A, "DeusEx."))
 	{
  		switch(A.Class)
  		{
			case class'SuperSoyFood': //For iff-ily supported mods
   			case class'SoyFood':
   			case class'SodaCan':
   			case class'CandyBar':
   			case class'WineBottle':
   			case class'Liquor40oz':
   			case class'LiquorBottle':
    				return True;
   			break;
   			default:
    				return False;
   			break;
  		}
 	}
 	//And handle non-vanilla like this.
 	else if (DeusExPickup(A) != None)
 	{
  		if (VMDActorIsProbablyFood(A, FillerStrength))
  		{
   			return True;
  		}
 	}
}

function bool VMDActorIsProbablyFood(Actor A, out int FoodStrength)
{
	local int TFood;
	
 	//MOD SUPPORT! Any class with "bIsFood" as a property set to true can be eaten this way. Fuck it. Why not?
 	if (A.GetPropertyText("bIsFood") ~= "True")
	{
		TFood = int(A.GetPropertyText("HungerValue"));
		if (TFood > -1)
		{
			FoodStrength = Max(1, TFood);
		}
		else
		{
			FoodStrength = 0;
		}
		return True;
 	}
	
 	//If we're not activatable, save us some work!
 	if ((DeusExPickup(A) != None) && (!DeusExPickup(A).bActivatable)) return False;
	
 	if (!VMDOtherIsName(A, "DeusEx."))
 	{
  		//Candy, kendy, and ketchup bar.
  		if (VMDOtherIsName(A, "WafoBar") || VMDOtherIsName(A, "Cookie") || VMDOtherIsName(A, "Candy") || VMDOtherIsName(A, "Noodle") || VMDOtherIsName(A, "Kendy") || VMDOtherIsName(A, "Ketchup"))
  		{
			FoodStrength = 2;
   			return true;
  		}
  		//Soda and coffee
  		else if (VMDOtherIsName(A, "Soda") || VMDOtherIsName(A, "MountainDew") || VMDOtherIsName(A, "Zap") || VMDOtherIsName(A, "Coffee"))
  		{
			FoodStrength = 1;
   			return true;
  		}
  		//Soy food, steak, burger, beans, and meals.
  		else if (VMDOtherIsName(A, "Food") || VMDOtherIsName(A, "Meal") || VMDOtherIsName(A, "Burger") || VMDOtherIsName(A, "Steak") || VMDOtherIsName(A, "Beans"))
  		{
			FoodStrength = 3;
   			return true;
  		}
  		//Alcohol.
		//------------
		//MADDERS: Deemed too likely to trip things up.
		// || VMDOtherIsName(A, "Sake")
  		else if (VMDOtherIsName(A, "Beer") || VMDOtherIsName(A, "Scotch") || VMDOtherIsName(A, "Vodka"))
  		{
			FoodStrength = 1;
   			return true;
  		}
  		else if (VMDOtherIsName(A, "Liquor") || VMDOtherIsName(A, "Wine") || VMDOtherIsName(A, "Whiskey"))
  		{
			FoodStrength = 2;
   			return true;
  		}
		
		//MADDERS, 2/8/21: IWR food, bby.
		else if (VMDOtherIsName(A, "Endemia.whiskybottle"))
		{
			FoodStrength = 2;
   			return true;
		}
		else if (VMDOtherIsName(A, "FGRHK.Fries"))
		{
			FoodStrength = 2;
			return true;
		}
		
		//MADDERS, 9/13/21: DXO food[?], google translate says stimulant, but aight.
		else if (VMDOtherIsName(A, "DXOAufputschmittel")) //Heruntergelassesen backpfiefengesicht
		{
			FoodStrength = 2;
   			return true;
		}
 	}
}

//MADDERS: Call this for outside mod food.
function CheckForAccessoryFood(Actor A)
{
	local int FoodStrength;
	
	if (VMDActorIsProbablyFood(A, FoodStrength))
	{
		VMDRegisterFoodEaten(FoodStrength, "Soy Food");
	}
}

//MADDERS: Allow fly/ghost mode to frob and see item names. Fuck it. Why not, right?
state CheatFlying
{
	ignores SeePlayer, HearNoise, Bump, TakeDamage;
		
	function AnimEnd()
	{
		PlaySwimming();
	}
	
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		Acceleration = Normal(NewAccel);
		Velocity = Normal(NewAccel) * 300;
		AutonomousPhysics(DeltaTime);
	}
	
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		VMDRunTickHookLight(DeltaTime);
		
        	RefreshSystems(deltaTime);
		DrugEffects(deltaTime);
		HighlightCenterObject();
		UpdateDynamicMusic(deltaTime);
      		MultiplayerTick(deltaTime);
		FrobTime += deltaTime;
		CheckActiveConversationRadius();
		CheckActorDistances();
		UpdateTimePlayed(deltaTime);
		
		PlayerMove(DeltaTime);
	}
	
	function PlayerMove(float DeltaTime)
	{
		local rotator newRotation;
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;
	
		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);  

		UpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
	
	function BeginState()
	{
		EyeHeight = BaseEyeHeight;
		SetPhysics(PHYS_Flying);
		if  ( !IsAnimating() ) PlaySwimming();
		// log("cheat flying");
	}
}

//MADDERS: Synthesis function barf. These are all to increase consistency of notation, while reducing complexity.
function Vector SizeOfMe(float RM, float HM)
{
 	local Vector V;
 	
 	V.X = CollisionRadius * RM * 2;
 	V.Y = V.X;
 	V.Z = CollisionHeight * HM * 2;
 	
 	return V;
}

function Vector SizeOfMeTo(float XM, float YM, float ZM, Rotator Rel)
{
 	local Vector V;
 	
 	V.X = CollisionRadius * XM * 2;
 	V.Y = CollisionRadius * YM * 2;
 	V.Z = CollisionHeight * ZM * 2;
 	
 	V = V >> Rel;
 	
 	return V;
}

function Vector PointerFrom(float Size, Rotator Rel)
{
 	local Vector V;
 	
 	V = Vector(Rel) * Size;
 	
 	return V;
}

function float CROfMe(float F)
{
 	return CollisionRadius * 2 * F;
}

function bool IsEMPFlicker(float F)
{
 	local float TF;
 	
 	TF = F % 1.0;
 	
 	if (TF < 0.15) return true;
 	if ((TF >= 0.15) && (TF < 0.30)) return false;
 	if ((TF >= 0.30) && (TF < 0.45)) return false;
 	if ((TF >= 0.45) && (TF < 0.60)) return true;
 	if ((TF >= 0.60) && (TF < 0.75)) return false;
 	if ((TF >= 0.75) && (TF < 0.90)) return true;
 	if (TF >= 0.9) return true;
 	
 	return false;
}

//MADDERS: How many spooky animals nearby?
function int CountScaryAnimals()
{ 
 	local Animal A;
 	local int CurCount;
 	local bool bTrace;
 	
 	forEach RadiusActors(Class'Animal', A, 960)
 	{
  		if ((A != None) && (A.bInWorld))
  		{
   			bTrace = FastTrace(A.Location, Location+(vect(0,0,1)*BaseEyeHeight));
   			
   			//Note: We're using multiple counts for scarier shit.
   			if (Doberman(A) != None) CurCount += 1;
   			if ((Greasel(A) != None) && (bTrace)) CurCount += 2;
   			if ((Karkian(A) != None) && (bTrace)) CurCount += 3;
   			if ((Gray(A) != None) && (bTrace)) CurCount += 4;
  		}
 	}
 	
 	return CurCount;
}

function bool SpottedByHostiles(out int CountRobot, out int CountHostile, out int CountNeutral, out int CountEdgy)
{
 	local ScriptedPawn SP;
 	local bool bSpotted;
 	local int AType, RotDif;
 	
 	//MADDERS: We're in the dark. Nah.
 	if (AIGetLightLevel(Location) < 0.005) return false;
 	
 	forEach RadiusActors(Class'ScriptedPawn', SP, 960)
 	{
  		//NEW: Having heard them talk lowers stress. Any level of personality helps.
  		if ((SP != None) && (SP.bInWorld) && (Animal(SP) == None) && (Robot(SP) == None || Robot(SP).EMPHitPoints > 0) && (SP.GetPawnAllianceType(Self) > 0) && (FastTrace(SP.Location, Location)))
  		{
   			//MADDERS note: 0 = friendly, 1 = neutral, and 2 = hostile
   			AType = SP.GetPawnAllianceType(Self);
   			
   			if ((AType == 1) && (SP.LastConEndTime > 0)) AType = 0;
   			RotDif = (SP.Rotation.Yaw - Rotator(Location - SP.Location).Yaw) % 65536;
   			if ((Abs(RotDif) < 16384 || Abs(RotDif) > 49152) && (AType > 0))
   			{
    				if ((IsScaryRobot(SP)) && (AType == 2)) CountRobot++;
    				if (AType == 1) CountNeutral++;
    				else
    				{
     					CountHostile++;
     					if (SP.LastConEndTime > 0) CountEdgy++;
    				}
    				bSpotted = True;
   			}
  		}
 	}
 	
 	return bSpotted;
}

function bool IsScaryRobot(ScriptedPawn SP)
{
	if (Robot(SP) == None || Robot(SP).EMPHitPoints <= 0) return false;
	
	if (VMDOtherIsName(SP, "Medical")) return false;
	if (VMDOtherIsName(SP, "Repair")) return false;
	if (VMDOtherIsName(SP, "Cleaner")) return false;
	
	return true;
}

function bool LocationIsSuperDark(vector Loc)
{
	local int i, Count;
	local Vector V[5];
	
	V[0] = Loc;
	V[1] = Loc+Vect(1,0,0)*48;
	V[2] = Loc+Vect(-1,0,0)*48;
	V[3] = Loc+Vect(0,1,0)*48;
	V[4] = Loc+Vect(0,-1,0)*48;
	
	for(i=0; i<5; i++)
	{
		if (AIGETLIGHTLEVEL(V[i]) < 0.005) Count++;
	}
	
	return (Count > 4);
}

// ----------------------------------------------------------------------
// UpdateStress()
// For the new anxiety system
// ----------------------------------------------------------------------

function UpdateStress()
{ 
 	local float TMult, DarkMult, LightLevel, AddStress,
 		DrugMult, THealthMult, EnergyMult, FoodMult;
 	local bool bIndoors, bDark, bPawnProxy, LastDrugged;
 	local DeusExWeapon DXW, DWP;
 	local bool bSpotted, bSuperDark;
 	local int SpotNeutral, SpotHostile, SpotRobot, SpotAnimal, SpotEdgy, HTotal;
 	
 	if (!bStressEnabled || bCustomStress) return;
 	
 	//Setup baseline vars. This is gonna get messy.
 	DrugMult = 1.0;
 	THealthMult = 0.0;
 	HTotal = VMDGetHealthTotal();
 	
 	//Step 1: Health multiplier.
 	//--------------------
 	//1b: Broad health.
 	if (HTotal < 150*GetHealthMult("All")) THealthMult = 0.135;
 	else if (HTotal < 300*GetHealthMult("All")) THealthMult = 0.10;
 	else if (HTotal < 450*GetHealthMult("All")) THealthMult = 0.065;
 	
 	//--------------------
 	//1c: Arms are "grazes" but can add up.
 	if (HealthArmRight < 50*GetHealthMult("Right Arm") || HealthArmLeft < 50*GetHealthMult("Left Arm")) THealthMult += 0.035;
	
 	//1d: Legs are vital, and can really freak us out
 	if (HealthLegLeft < 50*GetHealthMult("Left Leg") || HealthLegRight < 50*GetHealthMult("Right Leg")) THealthMult += 0.035;
 	if ((HealthLegLeft < 15*GetHealthMult("Left Leg")) && (HealthLegRight < 15*GetHealthMult("Right Leg"))) THealthMult += 0.65;
 	
 	//1e: Vital organs fucking suck. Head especially.
 	if (HealthTorso < 35*GetHealthMult("Torso")) THealthMult += 0.065;
 	else if (HealthTorso < 65*GetHealthMult("Torso")) THealthMult += 0.035;
 	
 	if (HealthHead < 35*GetHealthMult("Head")) THealthMult += 0.10;
 	else if (HealthHead < 65*GetHealthMult("Head")) THealthMult += 0.035;
 	
	//MADDERS: Turn off this stress when in god mode. Why not?
	if (ReducedDamageType == 'All') THealthMult = 0;
	
 	//Step 2: Char- Er... Darkness
 	LightLevel = AIGETLIGHTLEVEL(Location);
 	bDark = (LightLevel <= 0.005);
 	DarkMult = FClamp(LightLevel, 0.0, 0.2) * 3;
 	
 	//Step 2b: 
 	if (LocationIsSuperDark(Location))
 	{
  		DarkMult = 2.0-DarkMult;
  		bSuperDark = true;
 	}
 	bIndoors = !VMDIsOpenSky();
 	
 	//Step 3: How many baddies have us spotted?
	if ((ReducedDamageType != 'All') && (bDetectable))
	{
 		bSpotted = SpottedByHostiles(SpotRobot, SpotHostile, SpotNeutral, SpotEdgy);
	}
	
 	//Step 4: Being drugged lowers our fucks given.
 	LastDrugged = (DrugEffectTimer > 0);
 	if (LastDrugged)
 	{
  		if (DrugEffectTimer >= 25) DrugMult = 0.0;
  		else if (DrugEffectTimer >= 20) DrugMult = 0.06125;
  		else if (DrugEffectTimer >= 15) DrugMult = 0.125;
  		else if (DrugEffectTimer >= 10) DrugMult = 0.25;
  		else if (DrugEffectTimer >= 5) DrugMult = 0.375;
  		else if (DrugEffectTimer >= 0) DrugMult = 0.75;
 	}
 	
 	//Step 5: Energy charge and hunger.
 	EnergyMult = 1.0;
 	if (Energy < EnergyMax*0.15)
	{
		EnergyMult = 1.125;
	}
 	else if (Energy > EnergyMax*0.85)
	{
		EnergyMult = 0.75;
	}
	
 	FoodMult = 1.0;
 	if (HungerTimer < HungerCap*0.45)
	{
		FoodMult = 0.75;
	}
 	else
	{
		if (HungerTimer > HungerCap*0.70) FoodMult = 1.10;
 		if (HungerTimer > HungerCap*0.85) FoodMult = 1.20;
 	}
	
 	//Step 6: Add up stress gained.
 	if (!bDark || bSuperDark)
 	{	
  		if (bIndoors) DarkMult *= 0.35;
  		AddStress = 10.0 * DrugMult * DarkMult * THealthMult;
  		VMDModPlayerStress(AddStress, true, 2, false); //HEALTH DAM
  		
  		if (bSpotted)
  		{
   			AddStress = SpotHostile *(1.0 + (SpotRobot*1.5)) * 1.0 * DrugMult * DarkMult * FoodMult * EnergyMult;
   			VMDModPlayerStress(AddStress, true, 3, true); //PROXIMITY
   			AddStress = SpotNeutral *(1.0 + (SpotRobot*0.5)) * 0.25 * DrugMult * DarkMult * FoodMult * EnergyMult;
   			VMDModPlayerStress(AddStress, true, 3, false); //PROXIMITY
  		}
 	}
 	//GOOD STATUS!
 	if ((THealthMult <= 0.1) && (!bSpotted))
	{
		VMDModPlayerStress(-8, true, 0, true); //BROAD
	}
 	else if (THealthMult <= 0.15)
	{
		VMDModPlayerStress(-4, true, 0, true); //BROAD
	}
 	else
 	{
  		if (bIndoors) VMDModPlayerStress(-2.65, true, 0, false); //BROAD
  		if (bDark) VMDModPlayerStress(-5.35, true, 0, true); //BROAD
  		if (bDuck == 1 || bCrouchOn) VMDModPlayerStress(-2.65, true, 0, false); //BROAD
  		if (DeusExWeapon(InHand) != None)
  		{
   			DXW = DeusExWeapon(InHand);
   			if (DXW.AmmoType == None || DXW.AmmoType.AmmoAmount < (DXW.ReloadCount * 0.2) || DXW.ClipCount >= DXW.ReloadCount || DXW.ClipCount >= (float(DXW.ReloadCount) * 0.8))
   			{
				DWP = DXW.DualWieldPartner;
    				if (!DXW.bHandToHand)
				{
					if (DWP == None)
 	   				{
     						VMDModPlayerStress(2, true, 4, false); //LOW AMMO
					}
					else if (DWP.AmmoType == None || DWP.AmmoType.AmmoAmount < (DWP.ReloadCount * 0.2) ||
					DWP.ClipCount >= DWP.ReloadCount || DWP.ClipCount >= (float(DWP.ReloadCount) * 0.8))
					{
						if (!DWP.bHandToHand)
						{
							VMDModPlayerStress(2, true, 4, false); //LOW AMMO
						}
					}
    				}
   			}
  		}
 	}
	
	if ((LastStressPhase < 3) && (ActiveStress >= 80))
	{
		LastStressPhase = 3;
		//ClientMessage(StressLevelDesc[5]);
	}
	else if ((LastStressPhase < 2) && (ActiveStress >= 60))
	{
		LastStressPhase = 2;
		//ClientMessage(StressLevelDesc[3]);
	}
	else if ((LastStressPhase < 1) && (ActiveStress >= 30))
	{
		LastStressPhase = 1;
		//ClientMessage(StressLevelDesc[1]);
	}
	
	if ((ActiveStress < 20) && (LastStressPhase > 0))
	{
		LastStressPhase = 0;
		//ClientMessage(StressLevelDesc[0]);
	}
	else if ((ActiveStress < 50) && (LastStressPhase > 1))
	{
		LastStressPhase = 1;
		//ClientMessage(StressLevelDesc[2]);
	}
	else if ((ActiveStress < 70) && (LastStressPhase > 2))
	{
		LastStressPhase = 2;
		//ClientMessage(StressLevelDesc[4]);
	}
}

function VMDModPlayerStress(float Mod, optional bool bUnivScale, optional int ScaleIndex, optional bool bModMomentum)
{
 	local float GetStress, Use, TScale, UseMod;
 	
	if (!ShouldAllowHungerAndStress()) return;
	
 	if (bModMomentum)
 	{
  		StressMomentum = FClamp(StressMomentum+(Mod / 2), 0.25, 25.0);
 	}
 	
 	if (ScaleIndex >= ArrayCount(UnivStressScales)) ScaleIndex = 0;
 	TScale = 1.0;
 	if (bUnivScale) TScale = UnivStressScales[ScaleIndex];
 	if ((Mod > 0.0) && (StressMomentum > 0))
 	{
  		TScale *= Sqrt(StressMomentum);
 	}
 	if ((Mod < 0.0) && (StressMomentum > 0))
 	{
  		TScale /= Sqrt(StressMomentum);
 	}
 	
 	GetStress = ActiveStress;
 	UseMod = (Mod*TScale);
 	Use = FClamp(GetStress + UseMod, GetStressFloor(), GetStressCeiling());
 	ActiveStress = Use;
}

function bool VMDUsingLadder(optional bool bIgnoreFrames)
{
	//local Actor HitAct;
	//local Vector TraceStart, TraceEnd, Extent, HL, HN;
	
	return bLastTouchingLadder;
	
	/*TraceEnd = Location - Vect(0, 0, 0.1);
	TraceStart = Location;
	Extent.X = 1.0 * CollisionRadius;
	Extent.Y = 1.0 * CollisionRadius;
	Extent.Z = 2.0 * CollisionHeight;
	
 	HitAct = Trace(HL, HN, TraceEnd, TraceStart, true, Extent);
	if (((HitAct != Base && (Base == Level || Mover(Base) != None)) || Base == None) && (Physics == PHYS_Walking) && (Acceleration.Z == 0))
	{
		if (ConsecutiveFallFrames > 1 || bIgnoreFrames)
		{
			return true;
		}
	}
	
	return false;*/
}


function bool UpdateLastTouchingLadder()
{
	local int TexFlags, i, Cycles;
	local float GrabDist;
	local name TexName, TexGroup;
	local Rotator TRot;
	local Vector EndTrace, StartTrace, HitLocation, HitNormal, TVect;
	local Actor Target;
	
	GrabDist = 24;
	
	bLastTouchingLadder = false;
	
	//MADDERS, 3/15/25: We're not touching ladders underwater. Save processing power easily.
	if (Physics == PHYS_Swimming)
	{
		return false;
	}
	
	// MADDERS, 8/4/24: Here we are again. More stupid solutions because native functionality doesn't work.
	// In this case, using even a SINGLE axis of extents in this function will cause a GPF in the game...
	// So fuck it. Do lots of mini traces, looking for ladder association.
	// Right now this is quite dense, but that's to account for a huge area required. Some ladders are quite elusive, but this seems to find them all.
	for (i=0; i<68; i++)
	{
		TVect.Z = -1.0 + (0.5 * (i%17));
		TRot.Yaw = (i / 17) * 16384;
		StartTrace = Location + (TVect * CollisionHeight);
		EndTrace = StartTrace + (Vector(TRot) * (CollisionRadius + GrabDist));
		foreach TraceTexture(class'Actor', Target, TexName, TexGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
		{
			if ((target == Level) || target.IsA('Mover'))
				break;
		}
		
		if (TexGroup == 'Ladder')
		{
			bLastTouchingLadder = true;
			break;
		}
	}
	
	return bLastTouchingLadder;
}


simulated function bool VMDIsOpenSky()
{
 	local Vector Start, End, HitLoc, HitNorm;
 	local Actor A;
 	
 	Start = Location + vect(0, 0, 1600);
 	End = Location;
 	
 	A = Trace(HitLoc, HitNorm, End, Start, False);
 	if (A != Level)
 	{
  		return True;
 	}
 	return False;
}

//====================================================
//MADDERS: Smell system rebuilt from scratch. Yeet.
//====================================================

// ----------------------------------------------------------------------
// UpdateSmells()
// For the new smell system
// ----------------------------------------------------------------------

function UpdateSmells()
{
 	local bool bFS, bSFS, bBS, bSBS, bZS, bSS, bSSS;
 	local float FoodScore, SmellMults[2];
 	local int BL, SkillLevel;
	
	if (SkillSystem != None)
	{
		SkillLevel = SkillSystem.GetSkillLevel(class'SkillLockpicking');
	}
	
	//Scale smell with our augment for it now.
	SmellMults[0] = 1.0;
	SmellMults[1] = 1.0;
	if (HasSkillAugment('LockpickScent'))
 	{
		SmellMults[0] = 1.25 + (0.25 * SkillLevel); //1.5;
		SmellMults[1] = 1.15 + (0.15 * SkillLevel); //1.34;
	}
	
	if (IsA('MadIngramPlayer'))
	{
		SmellMults[1] *= 1.65;
	}
	
 	UpdateBloodSmell();
	
 	if (BloodSmellLevel >= 90*SmellMults[0])
	{
		if (LastBloodSmellLevel < 90*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(BloodSmellDesc[3]);
				PlaySound(Sound'BloodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		BL = 2;
	}
 	else if (BloodSmellLevel >= 45*SmellMults[0])
	{
		if (LastBloodSmellLevel < 45*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(BloodSmellDesc[1]);
				PlaySound(Sound'BloodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		else if (LastBloodSmellLevel >= 90*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(BloodSmellDesc[2]);
				PlaySound(Sound'BloodSmellDecrease',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		BL = 1;
	}
	else if (LastBloodSmellLevel >= 45*SmellMults[0])
	{
		if (bSmellsEnabled)
		{
			ClientMessage(BloodSmellDesc[0]);
			PlaySound(Sound'BloodSmellDecreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
		}
	}
	
	if (ZymeSmellLevel >= 45)
	{
		if (LastZymeSmellLevel < 45)
		{
			if (bSmellsEnabled)
			{
				ClientMessage(ZymeSmellDesc[1]);
				//PlaySound(Sound'ZymeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		if (bSmellsEnabled) bZS = true;
	}
	else if (LastZymeSmellLevel >= 45)
	{
		if (bSmellsEnabled)
		{
			ClientMessage(ZymeSmellDesc[0]);
			//PlaySound(Sound'ZymeSmellDecreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
		}
	}
	
 	if (SmokeSmellLevel >= 90*SmellMults[0])
	{
		if (LastSmokeSmellLevel < 90*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(SmokeSmellDesc[3]);
				//PlaySound(Sound'SmokeSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		if (bSmellsEnabled) bSSS = true;
	}
 	else if (SmokeSmellLevel >= 45*SmellMults[0])
	{
		if (LastSmokeSmellLevel < 45*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(SmokeSmellDesc[1]);
				//PlaySound(Sound'SmokeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		else if (LastSmokeSmellLevel >= 90*SmellMults[0])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(SmokeSmellDesc[2]);
				//PlaySound(Sound'SmokeSmellDecrease',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
		if (bSmellsEnabled) bSS = true;
	}
	else if (LastSmokeSmellLevel >= 45*SmellMults[0])
	{
		if (bSmellsEnabled)
		{
			ClientMessage(SmokeSmellDesc[0]);
			//PlaySound(Sound'SmokeSmellDecreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
		}
	}
	
	if (bSmellsEnabled)
	{
 		if (BL >= 1) bBS = true;
 		if (BL >= 2) bSBS = true;
 	}
	
	//MADDERS, 4/10/21: This is horseshit, I acknowledge it.
	//However, it is extremely handy for fine-tuning the balance.
	if (bSmellsEnabled)
	{
 		FoodScore = ScoreFood();
 		if (FoodScore >= FoodSmellThresholds[1]*SmellMults[1])
		{
			if (LastFoodSmellLevel < FoodSmellThresholds[1]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[3]);
					PlaySound(Sound'FoodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			bSFS = true;
			bFS = true;
		}
 		else if (FoodScore >= FoodSmellThresholds[0]*SmellMults[1])
		{
			if (LastFoodSmellLevel < FoodSmellThresholds[0]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[1]);
					PlaySound(Sound'FoodSmellDecrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			else if (LastFoodSmellLevel >= FoodSmellThresholds[1]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[2]);
					PlaySound(Sound'FoodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			bFS = true;
		}
		else if (LastFoodSmellLevel >= FoodSmellThresholds[0]*SmellMults[1])
		{
			if (bSmellsEnabled)
			{
				ClientMessage(FoodSmellDesc[0]);
				PlaySound(Sound'FoodSmellDecreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
			}
		}
 	}
	
	//MADDERS, 11/29/21: Temporarily disable smells while in water.
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
	{
		bFS = false;
		bSFS = false;
		bBS = false;
		bSBS = false;
		bZS = false;
		bSS = false;
		bSSS = false;
	}
	
 	if (PlayerBloodSmellNode != None) PlayerBloodSmellNode.bSmellActive = bBS;
 	if (StrongPlayerBloodSmellNode != None) StrongPlayerBloodSmellNode.bSmellActive = bSBS;
	
	if (bSBS)
	{
		AISendEvent('MegaFutz', EAITYPE_Visual, 2.0, 160);
	}
	
	//--------------
	//Zyme smell
	if (PlayerZymeSmellNode != None) PlayerZymeSmellNode.bSmellActive = bZS;
	
	//--------------
	//Smoke smell
	if (PlayerSmokeSmellNode != None) PlayerSmokeSmellNode.bSmellActive = bSS;
	if (StrongPlayerSmokeSmellNode != None) StrongPlayerSmokeSmellNode.bSmellActive = bSSS;
	
 	//--------------
 	//FOOD SMELL!
 	if (PlayerFoodSmellNode != None) PlayerFoodSmellNode.bSmellActive = bFS;
 	if (StrongPlayerFoodSmellNode != None) StrongPlayerFoodSmellNode.bSmellActive = bSFS;
	
	LastBloodSmellLevel = BloodSmellLevel;
	LastFoodSmellLevel = FoodScore;
	LastZymeSmellLevel = ZymeSmellLevel;
	LastSmokeSmellLevel = SmokeSmellLevel;
}

function UpdateBloodSmell()
{
 	local ShowerFaucet Fauc;
 	local Faucet Fauc2;
 	
	if (BloodSmellLevel > 180) BloodSmellLevel = 180;
	if (SmokeSmellLevel > 180) SmokeSmellLevel = 180;
	
 	//MADDERS: Wash blood off underwater. Thank god we update this periodically as-is... A plan coming together, methinks.
	if (Region.Zone.bWaterZone)
	{
 		if (BloodSmellLevel > 0)
 		{
  			Spawn(class'BloodCloudEffectSmall',,,Location);
  			BloodSmellLevel -= 30;
		}
		if (ZymeSmellLevel > 0)
		{
			ZymeSmellLevel = FClamp(ZymeSmellLevel - 30, 0, 180);
		}
		if (SmokeSmellLevel > 0)
		{
			SmokeSmellLevel -= FClamp(SmokeSmellLevel - 30, 0, 180);
		}
 	}
 	
 	//MADDERS: Wash off some blood.
 	if (BloodSmellLevel > 0 || ZymeSmellLevel > 0 || SmokeSmellLevel > 0)
 	{
  		forEach RadiusActors(class'ShowerFaucet', Fauc, 160, Location)
  		{
			break;
		}
		if (Fauc == None) Fauc = ShowerFaucet(FrobTarget);
		
   		if ((Fauc != None) && (Fauc.bOpen))
   		{
    			AddBloodLevel(-40);
			
			if (ZymeSmellLevel > 0)
			{
				ZymeSmellLevel = FClamp(ZymeSmellLevel - 30, 0, 180);
			}
			if (SmokeSmellLevel > 0)
			{
				SmokeSmellLevel -= FClamp(SmokeSmellLevel - 30, 0, 180);
			}
   		}
 	}
 	
 	//MADDERS: We're being run twice on this if to stop running an iterator twice instead.
 	if (BloodSmellLevel > 0)
 	{
		Fauc2 = Faucet(FrobTarget);
		if ((Fauc2 != None) && (Fauc2.bOpen))
		{
			AddBloodLevel(-20);
		}
 	}
}

function float ScoreFood()
{
	local DeusExPickup DXP;
 	local Inventory Inv;
 	local float Ret;
 	
 	if (Inventory != None)
 	{
  		for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
  		{
			DXP = DeusExPickup(Inv);
			if (DXP != None)
			{
				if ((DXP.SmellType ~= "Food") && (DXP.SmellUnits > 0))
				{
					Ret += DXP.SmellUnits * DXP.NumCopies;
				}
			}
  		}
 	}
 	
 	return Ret;
}

// ----------------------------------------------------------------------
// Add the smell system
// ----------------------------------------------------------------------
function VMDPostBeginPlayHook()
{
	local int i;
	
	//MADDERS: Patch this for fan overlay mods.
	for (i=0; i<ArrayCount(VMDVisualOverlayPatches); i++)
	{
		VMDVisualOverlayPatches[i] = "";
	}
	
 	if ((bSmellsEnabled) && (PlayerSmellNode == None)) SetupSmellNodes();
 	if (VMDBufferAugmentationManager(AugmentationSystem) != None) VMDBufferAugmentationManager(AugmentationSystem).CheckAugErrors();
	
	VMDForceColorUpdate();
}

function VMDPreTravelHook()
{
	local int i;
	local Actor TAct;
	local AmmoCrate TCrate;
	local Computers TComp;
	local DeusExLevelInfo Info;
	local Inventory Inv;
	local MedicalBot TMed;
	local RepairBot TRep;
	
	FrobTarget = None;
	if (PlayerHands != None)
	{
		PlayerHands.Destroy();
	}
	VMDPackUpDrones();
	
	if (Inventory != None)
	{
		for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (DeusExPickup(Inv) != None)
			{
				DeusExPickup(Inv).VMDPreTravel();
			}
			else if (DeusExWeapon(Inv) != None)
			{
				DeusExWeapon(Inv).VMDPreTravel();
			}
			else if (DeusExAmmo(Inv) != None)
			{
				DeusExAmmo(Inv).VMDPreTravel();
			}
		}
	}
	
	//MADDERS, 8/10/25: This dumb shit needs to be handled on a faster scale to stop redundant travels.
	FlagBase.SetBool('VMDPlayerTraveling', True, True, 0);
	FlagBase.SetBool('LayDDentonDetected', True, True, 0);
	FlagBase.SetBool('LDDPJCIsFemale', True, True, 0);
	FlagBase.SetBool('PlayerIsFemale', True, True, 0);
	
	//MARKIE: Save current mission number and marks this as a normal map transition.
	info = GetLevelInfo();
	if (info != None)
	{
		LastMissionNumber = info.MissionNumber;
	}
	else
	{
		LastMissionNumber = -3;
	}
	
	//MADDERS: Engage precaching during travel, unless at the main menu.
	//For loading games, we'll trigger this during load game.
	if (LastMissionNumber != -2 || bLastWasLoad)
	{
		if (bD3DPrecachingEnabled)
		{
			ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
			ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
			ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
		}
		else
		{
			ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
			ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
			ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
		}
	}
	
	//MADDERS, 11/10/24: Make sure we had time to observe this properly.
	for (i=0; i<ArrayCount(SkillNotifierDisplayTimes); i++)
	{
		if (SkillNotifierDisplayTimes[i] > 0)
		{
			SkillNotifierDisplayTimes[i] = class'VMDHUDSkillNotifier'.Default.ShowTime;
		}
	}
	
	//MADDERS, 5/29/22: Arg. Code isn't optimal, but we're minimizing the number of checks here.
	forEach AllActors(class'Actor', TAct)
	{
		TComp = Computers(TAct);
		TCrate = AmmoCrate(TAct);
		TMed = MedicalBot(TAct);
		TRep = RepairBot(TAct);
		
		if (TComp != None)
		{
			if (TComp.LastAlarmTime > 0)
			{
				TComp.LastAlarmTime = 0;
				TComp.EndAlarm();
			}
			TComp.LockoutTime = 0;
			TComp.LastHackTime = 0;
		}
		else if (TMed != None)
		{
			TMed.LastHealTime = 0;
		}
		else if (TRep != None)
		{
			TRep.LastChargeTime = 0;
		}
		else if (TCrate != None)
		{
			TCrate.PickupCooldown = 1;
		}
	}
	
	bIsMapTravel = true;
	
 	if (PlayerSmellNode != None) WipeSmellNodes();
	
	VMDCountMayhemNodes();
}

exec function VMDNihilumDontFlushMainMenu()
{
	local DeusExRootWindow root;
	local DeusExLevelInfo info;
	local MissionEndgame Script;
	local class<MenuMain> TLoad;
	
	if (bIgnoreNextShowMenu)
	{
		bIgnoreNextShowMenu = False;
		return;
	}
	
	info = GetLevelInfo();
	
	VMDBufferPlayer(GetPlayerPawn()).VMDShowMainMenuHook();
	
	if ((info != None) && (info.MissionNumber == 68 || Info.MissionNumber == 98)) 
	{
		bIgnoreNextShowMenu = True;
		PostIntro();
	}
	else if ((info != None) && (info.MissionNumber == 68 || Info.MissionNumber == 99))
	{
		foreach AllActors(class'MissionEndgame', Script)
		{
			break;
		}
		
		if (Script != None)
		{
			Script.FinishCinematic();
		}
	}
	else
	{
		root = DeusExRootWindow(rootWindow);
		if (root != None)
		{
			TLoad = class<MenuMain>(DynamicLoadObject("FGRHK.MyMainMenu", class'Class', false));
			if (TLoad != None)
			{
				root.InvokeMenu(TLoad);
			}
		}
	}
}

function VMDShowMainMenuHook()
{
	//MADDERS: Always call this for enforcing consistency.
	if (!bD3DPrecachingEnabled)
	{
		ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
		ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
		ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
		ConsoleCommand("FLUSH");
	}
}

function VMDCloseMainMenuHook()
{
	if (bD3DPrecachingEnabled)
	{
		ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
		ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
		ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
	}
}

function int HackSpecialCost()
{
	Log("GETTING SPECIAL COST!"@Self);
	return 0;
}

function HackAddPawn()
{
}

exec function TestInstallHook()
{
	class'VMDNative.GetNextMissionNumberFixer'.Static.InstallHook();
}

function VMDApplyScriptSwaps(string CampaignName)
{
	local class<DeusExGameInfo> LoadInfo;
	local NavigationPoint TNav;
	local ScriptedPawn SP;
	
	//MADDERS, 7/20/25: Simulate game info function here with this devious cast. Fuck package order, I'M the boss.
	LoadInfo = class<DeusExGameInfo>(DynamicLoadObject("Revision.RevGameInfo", class'Class', true));
	if (LoadInfo != None)
	{
		LoadInfo.Static.SetupMusic(Self);
	}
	class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("DXOgg.DXOggMusicManager.PreBeginPlay", "DXOgg.DXOggMusicManager.Pause");
	class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("DXOgg.DXOggMusicManager.PostBeginPlay", "DXOgg.DXOggMusicManager.Unpause");
	
	class'VMDNative.GetNextMissionNumberFixer'.Static.InstallHook();
	
	switch(CampaignName)
	{
		case "":
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("HotelCarone.HCPaulDenton.ShieldDamage", "DeusEx.PaulDenton.ShieldDamage"))
			{
				Log("VMD: Applied precautionary damage fix to HC Paul Denton!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("HotelCarone.Langly.ShieldDamage", "DeusEx.WaltonSimons.ShieldDamage"))
			{
				Log("VMD: Applied precautionary damage fix to HC Mr Leiderhosen!");
			}
			
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.EthanYoon.ShieldDamage", "DeusEx.PaulDenton.ShieldDamage"))
			{
				Log("VMD: Applied precautionary damage fix to Ethan Yoon!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.EthanYoon.GoToDisabledState", "DeusEx.PaulDenton.GoToDisabledState"))
			{
				Log("VMD: Applied precautionary disabled state fix to Ethan Yoon!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.MadIngramPlayer.ShowIntro", "DeusEx.DeusExPlayer.ShowIntro"))
			{
				Log("VMD: Applied precautionary ShowIntro fix to Mad Ingram!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.MadIngramPlayer.PostIntro", "DeusEx.VMDBufferPlayer.PostIntro"))
			{
				Log("VMD: Applied precautionary PostIntro fix to Mad Ingram!");
			}
			
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("Zodiac.Hela.ModifyDamage", "DeusEx.AnnaNavarre.ModifyDamage"))
			{
				Log("VMD: Applied precautionary damage fix to Hela!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("Zodiac.Hela.GoToDisabledState", "DeusEx.AnnaNavarre.GoToDisabledState"))
			{
				Log("VMD: Applied precautionary disabled state fix to Hela!");
			}
		break;
		
		case "CARONE":
		case "HOTEL CARONE":
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("HotelCarone.HCPaulDenton.ShieldDamage", "DeusEx.PaulDenton.ShieldDamage"))
			{
				Log("VMD: Applied damage fix to HC Paul Denton!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("HotelCarone.Langly.ShieldDamage", "DeusEx.WaltonSimons.ShieldDamage"))
			{
				Log("VMD: Applied damage fix to HC Mr Leiderhosen!");
			}
		break;
		
		case "NIHILUM":
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.EthanYoon.ShieldDamage", "DeusEx.PaulDenton.ShieldDamage"))
			{
				Log("VMD: Applied damage fix to Ethan Yoon!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.EthanYoon.GoToDisabledState", "DeusEx.PaulDenton.GoToDisabledState"))
			{
				Log("VMD: Applied disabled state fix to Ethan Yoon!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.MadIngramPlayer.ShowIntro", "DeusEx.DeusExPlayer.ShowIntro"))
			{
				Log("VMD: Applied ShowIntro fix to Mad Ingram!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("FGRHK.MadIngramPlayer.PostIntro", "DeusEx.VMDBufferPlayer.PostIntro"))
			{
				Log("VMD: Applied PostIntro fix to Mad Ingram!");
			}
		break;
		
		case "ZODIAC":
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("Zodiac.Hela.ModifyDamage", "DeusEx.AnnaNavarre.ModifyDamage"))
			{
				Log("VMD: Applied damage fix to Hela!");
			}
			if (class'VMDNative.VMDGenericNativeFunctions'.Static.SwapTargetScripts("Zodiac.Hela.GoToDisabledState", "DeusEx.AnnaNavarre.GoToDisabledState"))
			{
				Log("VMD: Applied disabled state fix to Hela!");
			}
		break;
	}
}

function VMDTravelPostAcceptHook()
{
	local int i;
	local float HUP;
	local DeusExDecoration DXD;
	local DeusExLevelInfo Info;
	local DodgeRollCooldownAura DRCA;
	local FireAura FA;
	local Pawn TPawn;
	local PoisonEffectAura PEA;
	local VMDBufferPawn VMBP;
	local VMDHousingScriptedTextureManager VHSTM;
	local VMDMEGHIntentionActor IA;
	
	VMDApplyScriptSwaps(SelectedCampaign);
	
	if (DeusExRootWindow(RootWindow) != None)
	{
		DeusExRootWindow(RootWindow).UnPauseGame();
	}
	
	//MADDERS, 8/10/25: Undo this bad boy fast, so we can accurately let us touch things soon after travel completes.
	FlagBase.DeleteFlag('VMDPlayerTraveling', FLAG_Bool);
	
	/*Info = GetLevelInfo();
	
	if ((class'VMDStaticFunctions'.Static.GetIntendedMapStyle(Self) == 1) && (bAssignedFemale) && (Info != None) && (!FlagBase.GetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'))))
	{
		if (Info.ConversationPackage == "DeusExConversations")
			Info.ConversationPackage = "FRevisionConversations";
		else
			Info.ConversationPackage = "F" $ Info.ConversationPackage;
		
		foreach AllActors(class'DeusExDecoration', DXD)
		{
			DXD.ConBindEvents();
		}
		for (TPawn=Level.PawnList; TPawn!=None; TPawn=TPawn.NextPawn)
		{
			if (TPawn.BindName == "ClubMercedes")
				TPawn.BindName = "LDDPClubMercedes";
			else if (TPawn.BindName == "Mamasan")
				TPawn.BindName = "LDDPMamasan";
			else if (TPawn.BindName == "Camille")
				TPawn.BindName = "LDDPCamille";
			
			if (ScriptedPawn(TPawn) != None)
				ScriptedPawn(TPawn).ConBindEvents();
			else if (DeusExPlayer(TPawn) != None)
				DeusExPlayer(TPawn).ConBindEvents();
		}
		
		FlagBase.SetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'), True, True, 0);
	}*/
	
	//MADDERS, 5/29/23: I, uh... Think this should work? Hmm...
	Handedness = PreferredHandedness;
	
	if (PlayerHands != None)
	{
		PlayerHands.Destroy();
	}
	PlayerHands = Spawn(class'VMDPlayerHands', Self,, Location, Rotation);
	if (PlayerHands != None)
	{
		PlayerHands.GoToState('Idle2');
	}
	
	//MADDERS, 8/28/23: Configure click dodge time, so we can use melee dodge.
	if (DodgeClickTime <= 0)
	{
		ChangeDodgeClickTime(0.1);
		SaveConfig();
	}
	if (StoredPlayerMeshLeft == "") bDefabricateQueued = true;
	
	bUpdateTravelTalents = true;
	
	if ((bHadMegh) && (!VMDUnpackDrones()))
	{
		IA = Spawn(Class'VMDMEGHIntentionActor');
		if (IA != None)
		{
			IA.VMP = Self;
		}
	}
	
	forEach AllActors(class'VMDBufferPawn', VMBP)
	{
		VMBP.LastVMP = Self;
	}
	
	if (PoisonCounter > 0)
	{
		PEA = PoisonEffectAura(FindInventoryType(class'PoisonEffectAura'));
		if (PEA != None)
		{
			PEA.Charge = PoisonCounter*80;
		}
		else
		{
			PEA = Spawn(class'PoisonEffectAura');
			PEA.Frob(Self, None);
			PEA.Activate();
		}
	}
	
	if (BurnTimer > 0)
	{
		//MADDERS, 8/9/23: Keeping example due to unique update burn time.
		FA = FireAura(FindInventoryType(class'FireAura'));
		if (FA != None)
		{
			FA.Charge = 9999;
			FA.UpdateBurnTime();
		}
		else
		{
			FA = Spawn(class'FireAura');
			FA.Frob(Self, None);
			FA.Activate();
		}
	}
	
	if (DodgeRollCooldownTimer > 0)
	{
		DRCA = DodgeRollCooldownAura(FindInventoryType(class'DodgeRollCooldownAura'));
		if (DRCA == None)
		{
			DRCA = Spawn(class'DodgeRollCooldownAura');
			DRCA.Frob(Self, None);
			DRCA.Activate();
		}
		else
		{
			DRCA.Charge = int(DodgeRollCooldownTimer+0.5)*40;
			DRCA.UpdateAugmentStatus();
		}
	}
	else
	{
		//MADDERS, 12/23/23: Stop new game roll cooldown sounds, thank you.
		DodgeRollCooldownTimer = 0;
	}
	
	//MADDERS: Sound stuff can get buggy if we don't restore this as it was. Icky, I know.
	if ((Level != None) && (Level.Game != None))
	{
		//ServerSetSlomo(Level.Game.GameSpeed);
		ServerSetSlomo(1.0);
	}
	
	BarfMusicFixTimer = 2.5;
	
	if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).HUD != None) && (DeusExRootWindow(RootWindow).HUD.Hit != None))
	{
		DeusExRootWindow(RootWindow).HUD.Hit.UpdateAsFemale(bAssignedFemale);
	}
	
	//MADDERS: Patch this for fan overlay mods.
	for (i=0; i<ArrayCount(VMDVisualOverlayPatches); i++)
	{
		VMDVisualOverlayPatches[i] = "";
	}
	
	if ((bSmellsEnabled) && (PlayerSmellNode == None)) SetupSmellNodes();
	if (VMDBufferAugmentationManager(AugmentationSystem) != None) VMDBufferAugmentationManager(AugmentationSystem).CheckAugErrors();
	if (InvokedBindName != "") InvokeBindName(InvokedBindName);
	
	switch(SelectedCampaign)
	{
		case "ZODIAC":
		case "OTHERPAULNOFOOD":
		case "OTHERPAULNOFOODNOINTRO":
		case "OTHERPAULZEROFOOD":
		case "OTHERPAULZEROFOODNOINTRO":
			FamiliarName = "Paul Denton";
			UnfamiliarName = "Paul Denton";
		break;
		case "REDSUN":
		case "REDSUN2020":
			FamiliarName = "Joseph";
			UnfamiliarName = "Joseph";
		break;
		case "NIHILUM":
			FamiliarName = "Mad Ingram";
			UnfamiliarName = "Mad Ingram";
		break;
		case "COUNTERFEIT":
			FamiliarName = "Dominic Bishop";
			UnfamiliarName = "Dominic Bishop";
		break;
		case "IWR":
			FamiliarName = "Alex Denton";
			UnfamiliarName = "Alex Denton";
		break;
		case "BLOODLIKEVENOM":
			FamiliarName = "Johnny Venom";
			UnfamiliarName = "Johnny Venom";
		break;
		case "HIVEDAYS":
			FamiliarName = "Jack Ruben";
			UnfamiliarName = "Jack Ruben";
		break;
	}
	
	if (FlagBase != None)
	{
		if (NGPlusLaps > 0)
		{
			FlagBase.SetBool('bNewGamePlusStarted', True, True, 99);
		}
		if (bAssignedFemale)
		{
			//Hickity hack, what's in the sack?
			//Detect FemJC presence. If it's installed, go ahead with female voice. Otherwise block it.
			//bDisableFemaleVoice = !bool(DynamicLoadObject("FemJC.FJCJump", class'Sound', True));
			if (!bDisableFemaleVoice)
			{
				FlagBase.SetBool('LayDDentonDetected', True, True, 0);
			}
			FlagBase.SetBool('LDDPJCIsFemale', True, True, 0);
			FlagBase.SetBool('PlayerIsFemale', True, True, 0);
		}
		else
		{
			bDisableFemaleVoice = false; //Irrelevant
			FlagBase.SetBool('LayDDentonDetected', False, True, 0);
			FlagBase.SetBool('LDDPJCIsFemale', False, True, 0);
			FlagBase.SetBool('PlayerIsFemale', False, True, 0);
		}
	}
	
	if (SkillAugmentManager != None)
	{
		SkillAugmentManager.SetPlayer(Self);
	}
	if (CraftingManager != None)
	{
		CraftingManager.SetPlayer(Self);
	}
	FabricatePlayerAppearance();
	if (IsA('MadIngramPlayer'))
	{
		bFabricateQueued = true;
		if ((bNGPlusKeepInventory > 1) && (FlagBase != None) && (!FlagBase.GetBool('M60_InventoryRemoved')))
		{
			FlagBase.SetBool('M60_InventoryRemoved', True,, 70);
		}
	}
	
	//MARKIE: Travel post accept code for autosave.
	if (!bIsMapTravel)
	{
		VMDCheckLadderPoints();
		VMDCheckFastMapFixer();
		VMDCheckMapFixer();
		VMDCheckSkinUpdater();
		VMDCheckMayhemActor();
		VMDCheckNakedSolutionActor();
		
    		//Trigger an auto save.
    		bAutoSaved = false;
	}
	VMDCheckBountyHunters();
	
	bIsMapTravel = false;
	
 	for (i=0; i<ArrayCount(AddictionStates); i++)
  	{
   		if ((AddictionStates[i] > 0) && (AddictionKickTimers[i] > 0))
   		{
			ClientMessage(SprintF(MsgCraving, GetSubstanceName(i)));
   		}
  	}
	//MADDERS, 1/15/21: Give message feedback when traveling or loading our game.
	if (bKillswitchEngaged)
	{
		BigClientMessage(KillswitchStateDescs[KillswitchPhase]);
	}
	
	if (ShouldAllowHungerAndStress())
	{
		if (bHungerEnabled)
		{
			HUP = HungerTimer / HungerCap;
			if (HUP >= 1.0)
			{
				PlaySound(sound'HungerSmall', SLOT_None, 3.3,, 255, 0.95);
				ClientMessage(HungerLevelDesc[6]);
			}
			else if (HUP >= 0.75)
			{
				PlaySound(sound'HungerSmall', SLOT_None, 2.2,, 255, 1.0);
				ClientMessage(HungerLevelDesc[5]);
			}
			else if (HUP >= 0.5)
			{
				PlaySound(sound'HungerSmall', SLOT_None, 1.1,, 255, 1.0);
				ClientMessage(HungerLevelDesc[3]);
			}
			else if (HUP >= 0.25)
			{
				PlaySound(sound'HungerSmall', SLOT_None, 0.5,, 255, 1.0);
				ClientMessage(HungerLevelDesc[1]);
			}
			
			LastHungerTimer = HungerTimer;
		}
		if (bStressEnabled)
		{
			if (ActiveStress >= 80) LastStressPhase = 3;
			else if (ActiveStress >= 60) LastStressPhase = 2;
			else if (ActiveStress >= 30) LastStressPhase = 1;
			else LastStressPhase = 0;
			
			//if (LastStressPhase == 3) ClientMessage(StressLevelDesc[5]);
			//else if (LastStressPhase == 2) ClientMessage(StressLevelDesc[3]);
			//else if (LastStressPhase == 1) ClientMessage(StressLevelDesc[1]);
		}
	}
	
	//MADDERS, 5/10/22: HOUSING SHIT!
	forEach AllActors(class'VMDHousingScriptedTextureManager', VHSTM)
	{
		if (VHSTM != None)
		{
			VHSTM.InitTextureBullshit();
		}
	}
	
	VMDForceColorUpdate();
	
	ProcessMaddersChanges();
	
	ProcessHCDiff();
}

function ProcessHCDiff()
{
	local DeusExLevelInfo Info;
	
	info=GetLevelInfo();
	
	if ((info.MapName == "16_HotelCarone_Intro") && (!FlagBase.GetBool('HCIntroDiff')))
	{
		FlagBase.SetBool('HCIntroDiff', true,,17);
		HCCheckDiff();
	}
	
	if ((info.MapName == "16_HotelCarone_House") && (!FlagBase.GetBool('HCHouseDiff')))
	{
		FlagBase.SetBool('HCHouseDiff', true,,17);
		HCCheckDiff();
	}
	
	if ((info.MapName == "16_HotelCarone_Hotel") && (!FlagBase.GetBool('HCHotelDiff')))
	{
		FlagBase.SetBool('HCHotelDiff', true,,17);
		HCCheckDiff();
	}
	
	if ((info.MapName == "16_HotelCarone_DXD") && (!FlagBase.GetBool('HCDXDDiff')))
	{
		FlagBase.SetBool('HCDXDDiff', true,,17);
		HCCheckDiff();
	}
}

function HCCheckDiff()
{
	local Actor A;
	local DeusExLevelInfo Info;
	local int CamCount;
	
	local int i, CurRip, MySeed, MyAltSeed, Ceil, TGet, RandIndex, RandBarf[100];
	local float TMission;
	local class<VMDStaticFunctions> SF;
	
	info = GetLevelInfo();
	
	//BARF! Rip out a seed, let's cheat.
	SF = class'VMDStaticFunctions';
	TMission = VMDGetMissionNumber();
	
	MySeed = SF.Static.DeriveStableMayhemSeed(Self, 32, true);
	for(i=0; i<ArrayCount(RandBarf); i++)
	{
		CurRip = SF.Static.RipLongSeedChunk(MySeed, i);
		RandBarf[i] = CurRip;
	}
	Ceil = 4;
	
	foreach AllActors(class'Actor', A)
	{
		/*if ((A.IsA('HCTerrorist')) && (HCTerrorist(A).bDiffChangesHealth))
		{
			HCAddDifficultyHealth(Pawn(A), HCTerrorist(A).HCDiffChangeFactor);
		}
		else if ((A.IsA('HCTriadLumPath')) && (HCTriadLumPath(A).bDiffChangesHealth))
		{
			HCAddDifficultyHealth(Pawn(A), HCTriadLumPath(A).HCDiffChangeFactor);
		}
		else if ((A.IsA('HCPaulDenton')) && (HCPaulDenton(A).bDiffChangesHealth))
		{
			HCAddDifficultyHealth(Pawn(A), HCPaulDenton(A).HCDiffChangeFactor);
		}
		else if ((A.IsA('DXDCop')) && (DXDCop(A).bDiffChangesHealth))
		{
			HCAddDifficultyHealth(Pawn(A), DXDCop(A).HCDiffChangeFactor);
		}
		else if ((A.IsA('HCTerrorist1')) && (HCTerrorist1(A).bDiffChangesHealth))
		{
			HCAddDifficultyHealth(Pawn(A), HCTerrorist1(A).HCDiffChangeFactor);
		}*/
		
		if ((combatdifficulty > 2.0) && (!A.bDifficulty3))
		{
			HCDiffHandle(A);
		}
		else if ((combatdifficulty > 1.5) && (combatdifficulty <= 2.0) && (!A.bDifficulty2))
		{
			HCDiffHandle(A);
		}
		else if ((combatdifficulty > 1.0) && (combatdifficulty <= 1.5) && (!A.bDifficulty1))
		{
			HCDiffHandle(A);
		}	
		else if ((combatdifficulty <= 1.0) && (!A.bDifficulty0))
		{
			HCDiffHandle(A);
		}
		else if (SecurityCamera(A) != None)
		{
			if ((Info.MapName == "16_HotelCarone_Hotel" || Info.MapName == "16_HotelCarone_DXD") && (!SecurityCamera(A).bActive))
			{
				TGet = RandBarf[RandIndex] % Ceil;
				RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
				VMDPossiblyEnableCamera(SecurityCamera(A), TGet);
			}
		}
	}
}

function VMDPossiblyEnableCamera(SecurityCamera SC, int RandResult)
{
	local int TThresh;
	
	TThresh = 0;
	if (CombatDifficulty >= 1.0)
	{
		TThresh += 1;
	}
	if (CombatDifficulty >= 2.0)
	{
		TThresh += 1;
	}
	if (CombatDifficulty >= 4.0)
	{
		TThresh += 1;
	}
	if (CombatDifficulty >= 8.0)
	{
		TThresh += 1;
	}
	
	if (RandResult < TThresh)
	{
		SC.Trigger(None, None);
		SC.bNoAlarm = false;
	}
}

function HCDiffHandle(actor A)
{
	// don't want SecurityCameras or AutoTurrets to be deleted, just turn them off
	if (A.IsA('SecurityCamera'))
	{
		A.UnTrigger(none, self);
	}
	else if (A.IsA('AutoTurret'))
	{
		AutoTurret(A).bDisabled=true;
	}
	else if (!A.IsA('Containers'))
	{
		A.Destroy();
	}
}

function VMDCheckLadderPoints()
{
	local string MissionBit;
	local DeusExLevelInfo DXLI;
	local VMDLadderPointAdder VLA;
	local class<VMDLadderPointAdder> LoadType;
	
	forEach AllActors(class'VMDLadderPointAdder', VLA) break;
	if (VLA != None) return;
	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
	if (DXLI != None)
	{
		MissionBit = string(DXLI.MissionNumber);
		if (DXLI.MissionNumber < 10)
		{
			MissionBit = "0"$DXLI.MissionNumber;
		}
		
		LoadType = class<VMDLadderPointAdder>(DynamicLoadObject("DeusEx.VMDLadderPointAdderM"$MissionBit, class'Class', true));
		if (LoadType != None)
		{
			VLA = Spawn(LoadType);
		}
	}
}

function VMDCheckFastMapFixer()
{
	local VMDFastMapFixer VMF;
	
	forEach AllActors(class'VMDFastMapFixer', VMF) break;
	if (VMF != None) return;
	
	VMF = Spawn(class'VMDFastMapFixer');
}

function VMDCheckMapFixer()
{
	local string MissionBit;
	local DeusExLevelInfo DXLI;
	local VMDMapFixer VMF;
	local class<VMDMapFixer> LoadType;
	
	forEach AllActors(class'VMDMapFixer', VMF) break;
	if (VMF != None) return;
	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
	if (DXLI != None)
	{
		MissionBit = string(DXLI.MissionNumber);
		if (DXLI.MissionNumber < 10)
		{
			MissionBit = "0"$DXLI.MissionNumber;
		}
		
		LoadType = class<VMDMapFixer>(DynamicLoadObject("DeusEx.VMDMapFixerM"$MissionBit, class'Class', true));
		if (LoadType != None)
		{
			VMF = Spawn(LoadType);
		}
	}
}

function VMDCheckSkinUpdater()
{
	local VMDSkinUpdater VSU;
	
	forEach AllActors(class'VMDSkinUpdater', VSU) break;
	if (VSU != None) return;
	
	VSU = Spawn(class'VMDSkinUpdater');
}

function VMDCheckMayhemActor()
{
	local VMDMayhemActor VMA;
	
	//if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Mayhem")) return;
	
	forEach AllActors(class'VMDMayhemActor', VMA) break;
	if (VMA != None) return;
	
	VMA = Spawn(class'VMDMayhemActor', Self);
}

function VMDCheckNakedSolutionActor()
{
	local VMDNakedSolutionActor VMA;
	
	forEach AllActors(class'VMDNakedSolutionActor', VMA) break;
	if (VMA != None) return;
	
	VMA = Spawn(class'VMDNakedSolutionActor', Self);
}

function VMDCheckBountyHunters()
{
	local VMDBountyHunterDeathFlag TFlag;
	local VMDBountyHunterSpawnFlag TFlag2;
	local Pawn TPawn;
	local VMDBountyHunterSpawner BHS;
	
	forEach AllActors(class'VMDBountyHunterSpawner', BHS) break;
	if (BHS != None) return;
	
	forEach AllActors(class'VMDBountyHunterDeathFlag', TFlag)
	{
		if (!TFlag.bDeleteMe)
		{
			return;
		}
	}
	
	forEach AllActors(class'VMDBountyHunterSpawnFlag', TFlag2)
	{
		if (!TFlag2.bDeleteMe)
		{
			return;
		}
	}
	
	BHS = Spawn(class'VMDBountyHunterSpawner', Self);
}

function VMDUpdateAmbientSounds()
{
	local byte TarPitch;
	local float TSpeed;
	local AmbientSound ASound;
	local Mover TMover;
	
	if (LastGameSpeed > 1.0)
	{
		TarPitch = Min(255, 64 + (16 * (LastGameSpeed - 1.0)));
	}
	else
	{
		TarPitch = Max(1, 64 * LastGameSpeed);
	}
	SoundPitch = TarPitch;
	
	forEach AllActors(class'AmbientSound', ASound)
	{
		if (ASound.BlendTweenRate[0] ~= 0)
		{
			ASound.BlendTweenRate[0] = float(ASound.SoundPitch);
		}
		
		if (ASound.BlendTweenRate[0] > 64)
		{
			TSpeed = ((ASound.BlendTweenRate[0] - 64) / 16.0) + 1.0;
		}
		else
		{
			TSpeed = (ASound.BlendTweenRate[0] / 64.0);
		}
		TSpeed *= LastGameSpeed;
		
		if (LastGameSpeed > 1.0)
		{
			TarPitch = Min(255, 64 + (16 * (TSpeed - 1.0)));
		}
		else
		{
			TarPitch = Max(1, 64 * TSpeed);
		}
		
		ASound.SoundPitch = TarPitch;
	}
	forEach AllActors(class'Mover', TMover)
	{
		if (TMover.BlendTweenRate[2] ~= 0)
		{
			TMover.BlendTweenRate[2] = float(TMover.SoundPitch);
		}
		
		if (TMover.BlendTweenRate[0] > 64)
		{
			TSpeed = ((TMover.BlendTweenRate[2] - 64) / 16.0) + 1.0;
		}
		else
		{
			TSpeed = (TMover.BlendTweenRate[2] / 64.0);
		}
		TSpeed *= LastGameSpeed;
		
		if (LastGameSpeed > 1.0)
		{
			TarPitch = Min(255, 64 + (16 * (TSpeed - 1.0)));
		}
		else
		{
			TarPitch = Max(1, 64 * TSpeed);
		}
		
		TMover.SoundPitch = TarPitch;
	}
}

// ----------------------------------------------------------------------
// WipeSmellNodes()
// ----------------------------------------------------------------------
function WipeSmellNodes()
{
 	if (PlayerSmellNode != None) PlayerSmellNode.Destroy();
 	if (PlayerAnimalSmellNode != None) PlayerAnimalSmellNode.Destroy();
 	if (PlayerFoodSmellNode != None) PlayerFoodSmellNode.Destroy();
 	if (StrongPlayerFoodSmellNode != None) StrongPlayerFoodSmellNode.Destroy();
 	if (PlayerBloodSmellNode != None) PlayerBloodSmellNode.Destroy();
 	if (StrongPlayerBloodSmellNode != None) StrongPlayerBloodSmellNode.Destroy();
	if (PlayerZymeSmellNode != None) PlayerZymeSmellNode.Destroy();
	if (PlayerSmokeSmellNode != None) PlayerSmokeSmellNode.Destroy();
	if (StrongPlayerSmokeSmellNode != None) StrongPlayerSmokeSmellNode.Destroy();
}

// ----------------------------------------------------------------------
// SetupSmellNodes()
// ----------------------------------------------------------------------
function SetupSmellNodes()
{
 	if (!bSmellsEnabled) return;
 	
 	//PREVENT REDUNDANCY!
 	WipeSmellNodes();
 	//MADDERS: Is there a proper way to detect sewage? Sigh.
 	PlayerSmellNode = GenerateSmellNode('PlayerSmell', Texture'BeltIconDataImage', 5, 1.0, 320, false);
 	PlayerAnimalSmellNode = GenerateSmellNode('PlayerAnimalSmell', None, 7, 0.75, 120, true); //Texture'BeltIconDataImage'
	
 	PlayerFoodSmellNode = GenerateSmellNode('PlayerFoodSmell', Texture'BeltIconCandyBar', 5, 0.75, 180, false);
 	StrongPlayerFoodSmellNode = GenerateSmellNode('StrongPlayerFoodSmell', Texture'BeltIconSoyFood', 4, 0.75, 280, false);
 	
 	PlayerBloodSmellNode = GenerateSmellNode('PlayerBloodSmell', Texture'IconBloodSmellSmall', 7, 1.0, 280, false);
 	StrongPlayerBloodSmellNode = GenerateSmellNode('StrongPlayerBloodSmell', Texture'IconBloodSmellLarge', 10, 1.0, 480, false);
	
	PlayerZymeSmellNode = GenerateSmellNode('PlayerZymeSmell', Texture'BeltIconVial_Crack', 10, 1.0, 240, false);
	
 	PlayerSmokeSmellNode = GenerateSmellNode('PlayerSmokeSmell', Texture'BeltIconCigarettes', 10, 0.5, 320, false);
 	StrongPlayerSmokeSmellNode = GenerateSmellNode('StrongPlayerSmokeSmell', Texture'IconSmokeSmellLarge', 12, 0.5, 480, false);
}

function VMDSmellManager GenerateSmellNode(Name SmellType, Texture NewIcon, int ArraySize, float UpdateTime, float Radius, bool bActive)
{
 	local VMDSmellManager Ret;
 	
 	Ret = Spawn(class'VMDSmellManager', Self,,Location, Rotation);
 	if (Ret != None)
 	{
  		Ret.Icon = NewIcon;
  		Ret.InitNodes(SmellType, ArraySize, UpdateTime, Radius, bActive);
 	}
 	
 	return Ret;
}

// ----------------------------------------------------------------------
// VMDRunTickHook()
// A good way to keep things running sharp, state regardless.
// ----------------------------------------------------------------------

//MADDERS: Cheap hack for universal tick.
function VMDRunTickHook( float DT )
{
	local Actor A;
	local bool bMetTiming;
 	local int TFactor, HungerDamage, i, SkillLevel;
	local float HUP, LHUP, AppMod, BreathMod, AugLevel, TBreath1, TBreath2, TDist, SmellMults[2], FoodScore;
 	local Vector TVect, TVect2;
	local Actor TAct;
	local Computers TComp;
	local DeusExDecoration DXD;
	local DeusExLevelInfo Info;
	local MedicalBot TMed;
	local Pawn TPawn;
	local RepairBot TRep;
	local RollCooldownAura RCA;
	local ShowerFaucet Fauc;
	local VMDBountyHunter THunt, THunt2;
	local VMDLadderPoint TLadder;
	
	VMDTransientLevelTime += DT;
	
	if (bUpdateTravelTalents)
	{
		bUpdateTravelTalents = false;
		
		SwimDuration = class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(Self);
		SwimTimer = SwimDuration;
		
		if (RollCooldownTimer > 0)
		{
			RCA = RollCooldownAura(FindInventoryType(class'RollCooldownAura'));
			if (RCA == None)
			{
				RCA = Spawn(class'RollCooldownAura');
				RCA.Frob(Self, None);
				RCA.Activate();
			}
			else
			{
				RCA.Charge = int(RollCooldownTimer+0.5)*40;
				RCA.UpdateAugmentStatus();
			}
		}
		else
		{
			//MADDERS, 12/23/23: Stop new game roll cooldown sounds, thank you.
			RollCooldownTimer = 0;
		}
		
		if (bSmellsEnabled)
		{
			if (SkillSystem != None)
			{
				SkillLevel = SkillSystem.GetSkillLevel(class'SkillLockpicking');
			}
			
			//Scale smell with our augment for it now.
			SmellMults[0] = 1.0;
			SmellMults[1] = 1.0;
			if (HasSkillAugment('LockpickScent'))
	 		{
				SmellMults[0] = 1.25 + (0.25 * SkillLevel); //1.5;
				SmellMults[1] = 1.15 + (0.15 * SkillLevel); //1.34;
			}
			
			if (IsA('MagIngramPlayer'))
			{
				SmellMults[0] *= 1.65;
			}
			
			if (BloodSmellLevel >= 90*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(BloodSmellDesc[3]);
					PlaySound(Sound'BloodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
	 		else if (BloodSmellLevel >= 45*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(BloodSmellDesc[1]);
					PlaySound(Sound'BloodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastBloodSmellLevel = BloodSmellLevel;
			
 			FoodScore = ScoreFood();
			
 			if (FoodScore >= FoodSmellThresholds[1]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[3]);
					PlaySound(Sound'FoodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
 			else if (FoodScore >= FoodSmellThresholds[0]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[1]);
					PlaySound(Sound'FoodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastFoodSmellLevel = FoodScore;
			
			if (ZymeSmellLevel >= 45)
			{
				if (bSmellsEnabled)
				{
					ClientMessage(ZymeSmellDesc[1]);
					//PlaySound(Sound'ZymeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastZymeSmellLevel = ZymeSmellLevel;
			
			if (SmokeSmellLevel >= 90*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(SmokeSmellDesc[3]);
					//PlaySound(Sound'SmokeSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
 			else if (SmokeSmellLevel >= 45*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(SmokeSmellDesc[1]);
					//PlaySound(Sound'SmokeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastSmokeSmellLevel = SmokeSmellLevel;
		}
		
		Info = GetLevelInfo();
		
		if ((class'VMDStaticFunctions'.Static.GetIntendedMapStyle(Self) == 1) && (bAssignedFemale) && (Info != None) && (!FlagBase.GetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'))))
		{
			if (Info.ConversationPackage == "DeusExConversations")
				Info.ConversationPackage = "FRevisionConversations";
			else
				Info.ConversationPackage = "F" $ Info.ConversationPackage;
			
			foreach AllActors(class'DeusExDecoration', DXD)
			{
				DXD.ConBindEvents();
			}
			for (TPawn=Level.PawnList; TPawn!=None; TPawn=TPawn.NextPawn)
			{
				if (TPawn.BindName == "ClubMercedes")
					TPawn.BindName = "LDDPClubMercedes";
				else if (TPawn.BindName == "Mamasan")
					TPawn.BindName = "LDDPMamasan";
				else if (TPawn.BindName == "Camille")
					TPawn.BindName = "LDDPCamille";
				
				if (ScriptedPawn(TPawn) != None)
					ScriptedPawn(TPawn).ConBindEvents();
				else if (DeusExPlayer(TPawn) != None)
					DeusExPlayer(TPawn).ConBindEvents();
			}
			
			FlagBase.SetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'), True, True, 0);
		}
	}
	
 	//Preamble. Store last deltatime for hacky stuff.
 	VMDLastTickChunk = DT;
 	
	//MADDERS, 8/24/25: Force this bit all the time. 'Tis only a boolean.
	bNoFlash = (VMDbNoFlash || bEpilepsyReduction);
	
	if ((Level != None) && (Level.Game != None))
	{
		if (LastGameSpeed != Level.Game.GameSpeed)
		{
			LastGameSpeed = Level.Game.GameSpeed;
			VMDUpdateAmbientSounds();
		}
	}
	
	//MADDERS, 4/10/21: Let us take more damage again, thanks.
	for (i=0; i<ArrayCount(CurTickDamageTaken); i++)
	{
		CurTickDamageTaken[i] = 0;
	}
	
	if (Level.Netmode == NM_Standalone)
	{
		UpdateTranslucency(DT);
	}
	
 	//1----1----1----1----1----
 	//MADDERS: Fuck the engine. I'M the captain now.
	if (NegateDeathCooldown > 0)
	{
		NegateDeathCooldown -= DT;
		if (NegateDeathCooldown <= 0)
		{
			PlaySound(Sound'MedicalHiss',SLOT_Interact,,,96,1.2 + (FRand() * 0.3));
			ClientMessage(MsgDeathNegateCooledDown);
		}
	}
	if (DamageGateTimer > 0) DamageGateTimer -= DT;
	
 	if (BroadUpdateTimer < 1.0)
 	{
  		BroadUpdateTimer += DT;
		
		//MADDERS, 8/8/24: This is my compromise: Faster than broad update, slower than every frame.
		//Was going to be used for something, but it's useful no longer.
		/*if (int(BroadUpdateTimer * 4.0) != BroadUpdateQuarter)
		{
			BroadUpdateQuarter = int(BroadUpdateTimer * 4.0);
		}*/
 	}
 	else
 	{
		if (GallowsSaveGateTimer > 0) GallowsSaveGateTimer -= BroadUpdateTimer;
		
		if (BigMessageRetryTime > 0)
		{
			BigMessageRetryTime -= BroadUpdateTimer;
		}
		else if (BigMessageRetryTime < 0)
		{
			BigClientMessage(QueuedBigMessage);
		}
		
		//MADDERS: Mod support. Janky, but it's something.
		if (bDefabricateQueued)
		{
			bDefabricateQueued = false;
			DeFabricatePlayerAppearance();
		}
		//MADDERS, 7/20/21: Only used for DX:N.
		if (bFabricateQueued)
		{
			bFabricateQueued = false;
			FabricatePlayerAppearance();
		}
		
		//MADDERS, 5/29/22: Arg. Code isn't optimal, but we're minimizing the number of checks here.
		forEach AllActors(class'Actor', TAct)
		{
			TComp = Computers(TAct);
			TMed = MedicalBot(TAct);
			TRep = RepairBot(TAct);
			THunt = VMDBountyHunter(TAct);
			
			if (TComp != None)
			{
				if (TComp.LastAlarmTime > 0)
				{
					TComp.LastAlarmTime -= BroadUpdateTimer;
					
					if (TComp.LastAlarmTime <= 0)
					{
						TComp.EndAlarm();
					}
				}
				if (TComp.LockoutTime > 0)
				{
					TComp.LockoutTime -= BroadUpdateTimer;
				}
				if (TComp.LastHackTime > 0)
				{
					TComp.LastHackTime -= BroadUpdateTimer;
				}
			}
			else if (TMed != None)
			{
				if (TMed.LastHealTime > 0)
				{
					TMed.LastHealTime -= BroadUpdateTimer;
				}
			}
			else if (TRep != None)
			{
				if (TRep.LastChargeTime > 0)
				{
					TRep.LastChargeTime -= BroadUpdateTimer;
				}
			}
			else if ((THunt != None) && (!THunt.bSprungAmbush))
			{
				if (THunt.AICanSee(Self, THunt.ComputeActorVisibility(Self), false, true, true, true) > 0)
				{
					if (THunt.ComputeActorVisibility(Self) > 0)
					{
						ForEach AllActors(class'VMDBountyHunter', THunt2)
						{
							THunt2.SetDistressTimer();
							if (THunt2.SetEnemy(Self))
							{
								THunt2.HandleEnemy();
							}
						}
					}
				}
			}
		}
		
  		BroadUpdateTimer = 0.0;
  		//b----b----b----
  		//MADDERS: Aug manager. Alt mode. Stress checks.
  		if (VMDBufferAugmentationManager(AugmentationSystem) == None || (VMDMechAugmentationManager(AugmentationSystem) != None) != bMechAugs) ForceAugOverride();
		
		//c----c----c----
		//MADDERS, 8/8/23: Tong goal completion. Check once per second vs every frame, thank you very much.
		if ((FlagBase != None) && (FlagBase.GetBool('VMDCheckForTongGoal')) && (FlagBase.GetBool('MeetTracerTong2_Played')))
		{
			FlagBase.SetBool('VMDCheckForTongGoal', false,, 7);
			GoalCompleted('VMDMeetTongPostKS');
		}
		
  		if (bStressEnabled) UpdateStress();
  		UpdateSmells();
		BroadUpdateKillswitch();
		
 		//MADDERS: Wash off some blood.
  		forEach RadiusActors(class'ShowerFaucet', Fauc, 160, Location)
  		{
   			if ((Fauc != None) && (Fauc.bOpen))
   			{
				//MADDERS, 12/4/20: Increase wetness on guns/wash them off, too.
				AddWaterLevel(4);
   			}
  		}	
		
		if ((IsA('MadIngramPlayer')) && (VMDGetMapName() ~= "60_HongKong_MPSHelipad") && (FlagBase != None) && (!FlagBase.GetBool('VMDGaveNihilumInventory')))
		{
			FlagBase.SetBool('VMDGaveNihilumInventory', True,, 70);
			
			if (bNGPlusKeepInventory < 3)
			{
				LoadNihilumKit();
			}
		}
 	}
 	//2----2----2----2----2----
 	//Killswitch and addiction here.
 	if (BloodSmellLevel > 0) BloodSmellLevel -= DT;
	if (ZymeSmellLevel > 0) ZymeSmellLevel -= DT;
	if (SmokeSmellLevel > 0) SmokeSmellLevel -= DT;

	if (MusicFixSkipWindow > 0)
	{
		MusicFixSkipWindow -= DT;
	}
	
	if (BarfMusicFixTimer > 0)
	{
		BarfMusicFixTimer -= DT;
		if (BarfMusicFixTimer <= 0)
		{
			if ((MusicMode == MUS_Dying) && (!IsInState('Dying')))
			{
				MusicMode = MUS_Ambient;
				ClientSetMusic(ModSwappedMusic, 0, 255, MTRAN_Fade);
			}
			else if ((MusicMode == MUS_Conversation) && (!IsInState('Conversation')))
			{
				MusicMode = MUS_Ambient;
				ClientSetMusic(ModSwappedMusic, 0, 255, MTRAN_Fade);
			}
		}
	}
	
 	RunKillswitchEffects(DT);
 	RunAddictionEffects(DT);
 	RunOverdoseEffects(DT);
 	
 	//3----3----3----3----3----
 	//MADDERS: Handle a hunger system. Previously the MarkieTimer shitpost system.
	//1/05/21: Don't run hunger if we're waiting on datalinks, thank you.
	if ((bHungerEnabled) && (!VMDHasForwardPressureObjection()))
	{
		AppMod = 1.0;
		if (CigaretteAppetitePeriod > 180) AppMod = 0.5;
		else if (CigaretteAppetitePeriod > 0) AppMod = 2.0;
  		HungerTimer += DT * Sqrt(TimerDifficulty) * 0.65 * AppMod;
 		
		if (CigaretteAppetitePeriod > 0) CigaretteAppetitePeriod -= DT;
		
 		if (ShouldAllowHungerAndStress())
		{
			HUP = HungerTimer / HungerCap;
			LHUP = LastHungerTimer / HungerCap;
			if (HUP >= 1.0)
 			{
				//MADDERS, 7/25/23: Running out of hunger (with our setting on) will now consume bio energy before taking damage.
				//Neato.
				if ((bBioHungerEnabled) && (Energy > 0.4))
				{
					Energy -= DT * 0.33;
					HungerTimer = HungerCap; //Don't let hunger damage escalate from this feature.
				}
				else
				{
					HungerDamage = Max(1, ((HungerTimer - HungerCap) / 60.0));
					
  					StarvationTimer += DT;
  					if (StarvationTimer > 10.0)
  					{
   						StarvationTimer = 0.0;
   						TakeDamage(HungerDamage, Self, Location, vect(0,0,0), 'Hunger');
  					}
				}
			}
			else
			{
	 			StarvationTimer = 0.0;
			}
			
			if ((HUP >= 1.0) && (LHUP < 1.0))
			{
				PlaySound(sound'HungerSmall', SLOT_None, 3.3,, 255, 0.95);
				ClientMessage(HungerLevelDesc[6]);
			}
			else if ((HUP >= 0.75) && (LHUP < 0.75))
			{
				PlaySound(sound'HungerSmall', SLOT_None, 2.2,, 255, 1.0);
				ClientMessage(HungerLevelDesc[5]);
			}
			else if ((HUP >= 0.5) && (LHUP < 0.5))
			{
				PlaySound(sound'HungerSmall', SLOT_None, 1.1,, 255, 1.0);
				ClientMessage(HungerLevelDesc[3]);
			}
			else if ((HUP >= 0.25) && (LHUP < 0.25))
			{
				PlaySound(sound'HungerSmall', SLOT_None, 0.5,, 255, 1.0);
				ClientMessage(HungerLevelDesc[1]);
			}
			
			if ((HUP < 0.12) && (LHUP >= 0.12)) ClientMessage(HungerLevelDesc[0]);
			else if ((HUP < 0.27) && (LHUP >= 0.27)) ClientMessage(HungerLevelDesc[2]);
			else if ((HUP < 0.62) && (LHUP >= 0.62)) ClientMessage(HungerLevelDesc[4]);
		}
		
		LastHungerTimer = HungerTimer;
 	}
	else
	{
		CigaretteAppetitePeriod = 0;
	}
 	
 	//4----4----4----4----4----
 	//MADDERS: Handle acrobatics and air
 	if ((!HeadRegion.Zone.bWaterZone) && (SwimTimer < SwimDuration))
	{
		AugLevel = 1.0;
		if (VMDBufferAugmentationManager(AugmentationSystem) != None)
		{
			AugLevel = (VMDBufferAugmentationManager(AugmentationSystem).VMDConfigureLungMod(true));
		}
		else
		{
			AugLevel = AugmentationSystem.GetAugLevelValue(class'AugAqualung');
		}
		
		TBreath1 = (class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(Self)+AugLevel);
		TBreath2 = (UnderWaterTime);
		BreathMod = TBreath1 / TBreath2;
		
		if (HasSkillAugment('SwimmingBreathRegen'))
		{
			SwimTimer += DT*18*BreathMod;
		}
		else
		{
			SwimTimer += DT*4.5*BreathMod;
		}
	}
	
	//MADDERS, 2/10/25: Overhauling some old garbage, use this check instead.
	if (VMDUsingLadder() || !IsInState('PlayerWalking'))
	{
		bJumpDucked = false;
	}
	
	if (RollTimer > 0)
 	{
  		RollTimer -= DT;
 	}
	if (DodgeRollTimer > 0)
	{
		DodgeRollTimer -= DT;
	}
	
	if ((Level != None) && (Level.Game != None))
	{
		if (LastDuckTimer < (TacticalRollTime*Level.Game.GameSpeed))
		{
			bMetTiming = true;
		}
	}
	else if (LastDuckTimer < TacticalRollTime)
	{
		bMetTiming = true;
	}
	
 	if ((bMetTiming) && (bDuck == 1)) //RollTapMax
 	{
  		LastDuckTimer += DT;
 	}
 	
 	//5----5----5----5----5----
 	//HUD EMP and scrambler effect.
 	if (HUDEMPTimer > 0)
 	{
  		HUDEMPTimer -= DT;
		
		if (!VMDIsInHandZoomed())
		{
		  	ShowHUD(False);
			
			if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).AugDisplay != None))
			{
				DeusExRootWindow(RootWindow).AugDisplay.Hide();
			}
		}
		
  		if (IsEMPFlicker(HUDEMPTimer))
  		{
   			if ((FRand() < 0.65) && (!bEpilepsyReduction))
			{
				ShowHUD(True);
				if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).AugDisplay != None))
				{
					DeusExRootWindow(RootWindow).AugDisplay.Show();
				}
			}
  		}
	  	if (HUDEMPTimer <= 0)
  		{
   			ShowHUD(True);
			if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).AugDisplay != None))
			{
				DeusExRootWindow(RootWindow).AugDisplay.Show();
			}
		}
 	}
	if (HUDScramblerTimer > 0)
	{
		HUDScramblerTimer -= DT;
	}
 	
 	//6----6----6----6----6----
 	//Check for autosave BS.
	if (bAutoSaving)
	{
		if (AutoSaveTimer >= 0)
		{
			AutoSaveTimer -= DT;
		}
		else
		{
			forEach AllActors(class'DeusExLevelInfo', Info) break;
			
			if (VMDShouldSave(Info))
			{
			    	AutoSaveTimer = 0;
				//VMDAutoSave();
				VMDQueueAutoSave();
			}
		}
	}

	bAlarmInfamyAddedThisTick = False;
}

// ----------------------------------------------------------------------
// VMDRunTickHookLight()
// Always keep this guy chugging in the background.
// ----------------------------------------------------------------------

function VMDRunTickHookLight(float DT)
{
	local int THand, SkillLevel;
	local float SmellMults[2], FoodScore;
	local string TName;
	local Mesh TMesh;
	local Actor A;
	local DeusExDecoration DXD;
	local DeusExLevelInfo Info;
	local DodgeRollCooldownAura DRCA;
	local Inventory Inv;
	local Pawn TPawn;
	local RollCooldownAura RCA;
	local Window TWindow;
	
	VMDTransientLevelTime += DT;
	
	if (bUpdateTravelTalents)
	{
		bUpdateTravelTalents = false;
		
		SwimDuration = class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(Self);
		SwimTimer = SwimDuration;
		
		if (RollCooldownTimer > 0)
		{
			RCA = RollCooldownAura(FindInventoryType(class'RollCooldownAura'));
			if (RCA == None)
			{
				RCA = Spawn(class'RollCooldownAura');
				RCA.Frob(Self, None);
				RCA.Activate();
			}
			else
			{
				RCA.Charge = int(RollCooldownTimer+0.5)*40;
				RCA.UpdateAugmentStatus();
			}
		}
		else
		{
			//MADDERS, 12/23/23: Stop new game roll cooldown sounds, thank you.
			RollCooldownTimer = 0;
		}
		
		if (bSmellsEnabled)
		{
			if (SkillSystem != None)
			{
				SkillLevel = SkillSystem.GetSkillLevel(class'SkillLockpicking');
			}
			
			//Scale smell with our augment for it now.
			SmellMults[0] = 1.0;
			SmellMults[1] = 1.0;
			if (HasSkillAugment('LockpickScent'))
	 		{
				SmellMults[0] = 1.25 + (0.25 * SkillLevel); //1.5;
				SmellMults[1] = 1.15 + (0.15 * SkillLevel); //1.34;
			}
			
			if (IsA('MagIngramPlayer'))
			{
				SmellMults[0] *= 1.65;
			}
			
			if (BloodSmellLevel >= 90*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(BloodSmellDesc[3]);
					PlaySound(Sound'BloodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
	 		else if (BloodSmellLevel >= 45*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(BloodSmellDesc[1]);
					PlaySound(Sound'BloodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastBloodSmellLevel = BloodSmellLevel;
			
 			FoodScore = ScoreFood();
			
 			if (FoodScore >= FoodSmellThresholds[1]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[3]);
					PlaySound(Sound'FoodSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
 			else if (FoodScore >= FoodSmellThresholds[0]*SmellMults[1])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(FoodSmellDesc[1]);
					PlaySound(Sound'FoodSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastFoodSmellLevel = FoodScore;
			
			if (ZymeSmellLevel >= 45)
			{
				if (bSmellsEnabled)
				{
					ClientMessage(ZymeSmellDesc[1]);
					//PlaySound(Sound'ZymeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastZymeSmellLevel = ZymeSmellLevel;
			
			if (SmokeSmellLevel >= 90*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(SmokeSmellDesc[3]);
					//PlaySound(Sound'SmokeSmellIncrease',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
 			else if (SmokeSmellLevel >= 45*SmellMults[0])
			{
				if (bSmellsEnabled)
				{
					ClientMessage(SmokeSmellDesc[1]);
					//PlaySound(Sound'SmokeSmellIncreaseSmall',,1.1,,,0.95 + (FRand() * 0.1));
				}
			}
			LastSmokeSmellLevel = SmokeSmellLevel;
		}
		
		Info = GetLevelInfo();
		
		if ((class'VMDStaticFunctions'.Static.GetIntendedMapStyle(Self) == 1) && (bAssignedFemale) && (Info != None) && (!FlagBase.GetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'))))
		{
			if (Info.ConversationPackage == "DeusExConversations")
				Info.ConversationPackage = "FRevisionConversations";
			else
				Info.ConversationPackage = "F" $ Info.ConversationPackage;
			
			foreach AllActors(class'DeusExDecoration', DXD)
			{
				DXD.ConBindEvents();
			}
			for (TPawn=Level.PawnList; TPawn!=None; TPawn=TPawn.NextPawn)
			{
				if (TPawn.BindName == "ClubMercedes")
					TPawn.BindName = "LDDPClubMercedes";
				else if (TPawn.BindName == "Mamasan")
					TPawn.BindName = "LDDPMamasan";
				else if (TPawn.BindName == "Camille")
					TPawn.BindName = "LDDPCamille";
				
				if (ScriptedPawn(TPawn) != None)
					ScriptedPawn(TPawn).ConBindEvents();
				else if (DeusExPlayer(TPawn) != None)
					DeusExPlayer(TPawn).ConBindEvents();
			}
			
			FlagBase.SetBool(RootWindow.StringToName(Info.MapName $ '_ConvoPackageChanged'), True, True, 0);
		}
	}
	
	DripWater(DT);
	
	UpdateLastTouchingLadder();
	
	if ((Level != None) && (Level.bPlayersOnly))
	{
		for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{
			Inv.Tick(DT);
		}
	}
	
	THand = int(Handedness);
	TMesh = GetHandednessPlayerMesh(THand);
	if ((Mesh != TMesh) && (TMesh != None) && (DeusExWeapon(InHand) == None) && (VMDPlayerHands(InHand) == None) && (SkilledTool(InHand) == None) && (POVCorpse(InHand) == None))
	{
		Mesh = TMesh;
		LastMeshHandedness = THand;
	}
	
	if ((PlayerHandsLevel > 0.0) && (InHandPending != None))
	{
		PlayerHandsLevel = FMax(0.0, PlayerHandsLevel - DT);
	}
	else if ((bPlayerHandsEnabled) && (InHand == None) && (InHandPending == None) && (PlayerHandsLevel < PlayerHandsCap))
	{
		PlayerHandsLevel = FMin(PlayerHandsCap, PlayerHandsLevel + DT);
	}
	
	if ((UIForceDuckTimer > 0) && (DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).GetTopWindow() == None))
	{
		UIForceDuckTimer -= DT;
	}
	
	if (ForceLimpTime > 0)
	{
		ForceLimpTime -= DT;
	}
	
 	if (RollCooldownTimer > 0)
 	{
  		RollCooldownTimer -= DT;
 	}
	else if (RollCooldownTimer < 0)
	{
		if ((HeadRegion.Zone == None || !HeadRegion.Zone.bWaterZone) && (HasSkillAugment('SwimmingFallRoll')))
		{
			ClientMessage(RollCooldownDesc);
			if (bEnvironmentalSoundsEnabled)
			{
				if (!bAssignedFemale)
				{
					PlaySound(Sound'RollCooldownReset',,0.5,,,(0.95 + (FRand() * 0.1)) * LastGameSpeed);
				}
				else
				{
					PlaySound(Sound'RollCooldownResetFemale',,0.7,,,(0.95 + (FRand() * 0.1)) * LastGameSpeed);
				}
			}
		}
		RollCooldownTimer = 0;
		RCA = RollCooldownAura(FindInventoryType(class'RollCooldownAura'));
		if (RCA != None)
		{
			RCA.UsedUp();
		}
	}
	
 	if (DodgeRollCooldownTimer > 0)
 	{
  		DodgeRollCooldownTimer -= DT;
 	}
	else if (DodgeRollCooldownTimer < 0)
	{
		if ((HeadRegion.Zone == None || !HeadRegion.Zone.bWaterZone) && (HasSkillAugment('TagTeamDodgeRoll')))
		{
			ClientMessage(DodgeRollCooldownDesc);
			if (bEnvironmentalSoundsEnabled)
			{
				if (!bAssignedFemale)
				{
					PlaySound(Sound'RollCooldownReset',,0.5,,,(0.80 + (FRand() * 0.1)) * LastGameSpeed);
				}
				else
				{
					PlaySound(Sound'RollCooldownResetFemale',,0.7,,,(0.80 + (FRand() * 0.1)) * LastGameSpeed);
				}
			}
		}
		
		DodgeRollCooldownTimer = 0;
		DRCA = DodgeRollCooldownAura(FindInventoryType(class'DodgeRollCooldownAura'));
		if (DRCA != None)
		{
			DRCA.UsedUp();
		}
	}
	
	//MADDERS, 4/18/24: Hey guys, WCCC here again to mention the importance of not referencing things cleared from memory.
	//In this case, endgame 4 in nihilum calls for the quote text to be destroyed, except the quote text was never displayed...
	//However, a former piece of quote text WAS created and has since died, meaning this null pointer in memory is being referenced again.
	//And for those wondering, no, the pointer has not been cleared from memory, because objects don't clear their pointers in actors
	//in the way that actors clear references from other actors... For fuck's sake, Nihilum, why do you have all the problems?
	if (!HackPatchedNihilumEnding)
	{
		TName = class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
		
		switch(TName)
		{
			case "68_ENDING_4":
				if (Level.TimeSeconds > 10)
				{
					forEach AllActors(class'Actor', A)
					{
						if (A.IsA('DXNMission68Script'))
						{
							A.SetPropertyText("QuoteDisplay", "None");
							HackPatchedNihilumEnding = true;
						}
						break;
					}
				}
			break;
			default:
				HackPatchedNihilumEnding = true;
			break;
		}
	}
	
	bAlarmInfamyAddedThisTick = False;
}

event PainTimer()
{
	local float depth;

	//log("Pain Timer");
	if ( (Health < 0) || (Level.NetMode == NM_Client) )
		return;
		
	if ( FootRegion.Zone.bPainZone )
	{
		depth = 0.4;
		if (Region.Zone.bPainZone)
			depth += 0.4;
		if (HeadRegion.Zone.bPainZone)
			depth += 0.2;

		if (FootRegion.Zone.DamagePerSec > 0)
		{
			if ( IsA('PlayerPawn') )
				Level.Game.SpecialDamageString = FootRegion.Zone.DamageString;
			TakeDamage(int(float(FootRegion.Zone.DamagePerSec) * depth), None, Location, vect(0,0,0), FootRegion.Zone.DamageType); 
		}
		else if ( Health < Default.Health )
			Health = Min(Default.Health, Health - depth * FootRegion.Zone.DamagePerSec);

		if (Health > 0)
			PainTime = 1.0;
	}
	else if ( HeadRegion.Zone.bWaterZone )
	{
		// DEUS_EX CNN - make drowning damage happen from center
		//--------------------
		//MADDERS, 1/20/21: Scale damage with skill augment now as well. Overhaul, bby.
		if (HasSkillAugment('SwimmingBreathRegen')) //SwimmingDrowningRate
		{
			TakeDamage(3, None, Location, vect(0,0,0), 'Drowned'); 
		}
		else
		{
			TakeDamage(5, None, Location, vect(0,0,0), 'Drowned'); 
		}
		
		if (Health > 0)
		{
			//MADDERS: Halve damage suffer rate when drowning, if we have the proper augment.
			if (HasSkillAugment('SwimmingDrowningRate'))
			{
				PainTime = 4.0;
			}
			else
			{
				PainTime = 2.0;
			}
		}
	}
}

function VMDRequestAutoSave(optional float delay)
{
	if (Delay == 0) Delay = 2.5;
	
	bAutoSaving = true;
	AutoSaveTimer = Delay;
}

function VMDQueueAutoSave()
{
	local DeusExRootWindow DXRW;
	
	DXRW = DeusExRootWindow(RootWindow);
	if (DXRW == None)
	{
		VMDAutoSave();
	}
	else
	{
		DXRW.UIPauseGame();
		DXRW.AddTimer(0.01, False,, 'VMDInvokeAutoSave');
	}
}

// Handle auto save.
function VMDAutoSave()
{
	local DeusExLevelInfo info;
	local string TClass, TDiff, TGender, TNGPlus;
	
	VMDCheckLadderPoints();
	VMDCheckFastMapFixer();
	VMDCheckMapFixer();
	VMDCheckSkinUpdater();
	VMDCheckMayhemActor();
	VMDCheckNakedSolutionActor();
	
	//MADDERS: 5/25/20: This is now toggleable.
	if (!bPendingNGPlusSave)
	{
		if (!bAutosaveEnabled && (GallowsSaveGateTime <= 1000 || !class'VMDStaticFunctions'.Static.UseGallowsSaveGate(Self)))
		{
			bAutosaving = False;
			AutoSaveTimer = 0;
			LastAutoSaveLoc = GetMissionLocation();
			return;
		}
	}
	
	info = GetLevelInfo();
	if (!VMDShouldSave(info, bPendingNGPlusSave))
	{
		//MADDERS, 4/21/25: For these save fail conditions (we should be waiting), queue things again. Particularly, if we open a menu during our 0.1 second pause time.
		if (DataLinkPlay != none || (DeusExRootWindow(RootWindow) != None && DeusExRootWindow(RootWindow).GetTopWindow() != None))
		{
			VMDQueueAutosave();
			if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).GetTopWindow() == None))
			{
				DeusExRootWindow(RootWindow).UnpauseGame(); //Force this through, to not lock up the game.
			}     
 		}
	  	return;
	}
	
    	bAutoSaving = false;
    	AutoSaveTimer = 0;
	LastAutoSaveLoc = GetMissionLocation();
	
	TClass = AssignedClass;
	if (TClass ~= "") TClass = "Custom";
	
	TDiff = AssignedSimpleDifficulty;
	if (TDiff ~= "") TDiff = StrDifficultyNames[1];
	
	if (bAssignedFemale) TGender = SaveGameGenders[1];
	else TGender = SaveGameGenders[0];
	
	if (bNGPlusTravel) TNGPlus = SaveGameNGPlus;
	
	//MADDERS, 3/23/21: Autosave refreshes manual save, as a point of generosity.
	//Forseeably, players may not feel satisfied with autosave points, and autosaves occur on map travel.
	//We can very much afford to be nice here.
	GallowsSaveGateTimer = 0.0;
	
	//MADDERS: 6/19/24: Creating the theoretical "ultimate run"... Each playthrough cleared is a condemned save point, when normally this is not possible.
	if (bPendingNGPlusSave)
	{
		bPendingNGPlusSave = false;
		SaveGame(0, "NG+ WARP:"@TruePlayerName@"("$TGender$","@TClass$","@TDiff$")"$TNGPlus$" -"@GetMissionLocation());
	}
	else
	{
		//MADDERS, 9/19/22: Condemned save setting blocks all saving. Even autosave.
		if ((GallowsSaveGateTime > 1000) && (class'VMDStaticFunctions'.Static.UseGallowsSaveGate(Self)))
		{
  			SaveGame(9999, "RESUME CONDEMNED:"@TruePlayerName@"("$TGender$","@TClass$")"$TNGPlus$" -"@GetMissionLocation());
		}
		else
		{
   			SaveGame(-3, "AUTO:"@TruePlayerName@"("$TGender$","@TClass$","@TDiff$")"$TNGPlus$" -"@GetMissionLocation());
		}
	}
	GallowsSaveGateTimer = 0.0;
}

function bool VMDShouldSave(DeusExLevelInfo info, optional bool bNGPlus)
{
	local string MN;
	
	if ((info != none) && (info.MissionNumber < 0 || info.MissionLocation == ""))
	{
		return false;
	}
	
    	//if (!bNGPlus)
	//{
        	if (IsInState('Dying') || IsInState('Paralyzed') || IsInState('TrulyParalyzed') || IsInState('Interpolating') || IsInState('CheatFlying') || bIsTyping
        		|| dataLinkPlay != none
        		|| Level.NetMode != NM_Standalone
			|| LastAutoSaveLoc ~= GetMissionLocation() //MADDERS: Don't save on the same map 2x in a row.
			|| (DeusExRootWindow(RootWindow) != None && DeusExRootWindow(RootWindow).GetTopWindow() != None)) //MADDERS, 11/16/24: Sneaky cunt saving during repair bots.
		{
	        	return false;
		}
    	//}
	
	MN = class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
	switch(MN)
	{
		case "66_WHITEHOUSE_EXTERIOR":
		case "66_WHITEHOUSE_STREETS":
			if (Level.TimeSeconds < 30 || Mover(Base) != None)
			{
				return false;
			}
		break;
	}
	
        return true;
}

function String GetMissionLocation()
{
 	local DeusExLevelInfo LI;
 	
 	forEach AllActors(class'DeusExLevelInfo', LI) break;
 	
 	if (LI != None)
 	{
  		return LI.MissionLocation;
 	}
 	
 	return "Uknown Location";
}

function BigClientMessage(string S)
{
  	local HUDMissionStartTextDisplay HUDStart;
	
	QueuedBigMessage = "";
	BigMessageRetryTime = 0.0;
	
  	if ((DeusExRootWindow(RootWindow) != None) && (DeusExRootWindow(RootWindow).HUD != None))
  	{
   		HUDStart = DeusExRootWindow(RootWindow).HUD.startDisplay;
   		if (HUDStart != None)
   		{
			if ((HUDStart.DisplayTime <= 0) && (!HUDStart.bSpewingText))
			{
    				HUDStart.shadowDist = 0;
    				HUDStart.Message = "";
    				HUDStart.charIndex = 0;
    				HUDStart.winText.SetText("");
    				HUDStart.winTextShadow.SetText("");
    				HUDStart.displayTime = 5.50;
    				HUDStart.perCharDelay = 0.30;
    				HUDStart.AddMessage(S);
    				HUDStart.StartMessage();
			}
			else
			{
				QueuedBigMessage = S;
				BigMessageRetryTime = 5.0;
			}
   		}
  	}
}

function VMDRegisterFoodEaten( int FoodPoints, string FoodType )
{
	local bool bWaterNotify;
	
	if (FoodType ~= "WaterPoison" || FoodType ~= "WaterPoisonFluff")
	{
		if ((WaterBuildup < 200) && (WaterBuildup + (FoodPoints*10) >= 200))
		{
			bWaterNotify = true;
			ClientMessage(WaterWoozyDesc);
		}
		else if ((FoodType ~= "WaterPoisonFluff") && (WaterBuildup + (FoodPoints*10) >= 200))
		{
			bWaterNotify = true;
			ClientMessage(WaterWoozyDesc);
		}
	}
	
  	switch(CAPS(FoodType))
  	{
		//MADDERS, 12/26/20: Soy food group.
		case "LITERAL SOY FOOD":
			ClientMessage(SoyEatenDesc);
   		case "SOY FOOD":
    			if ((bStressEnabled) && (FoodPoints > 0)) VMDModPlayerStress(-50,,,true);
   		break;
		case "FISH":
			ClientMessage(FishEatenDesc);
			if (bStressEnabled) VMDModPlayerStress(-50,,,true);
		break;
		
		//MADDERS, 12/26/20: Water group.
   		case "WATER":
   		break;
   		//VMD: We only use this to add to our poison level for water intake. YOINK!
   		case "WATERPOISONFLUFF":
			if (!bWaterNotify)
			{
				ClientMessage(WaterDrankDesc);
			}
		case "WATERPOISON":
			if (bStressEnabled) VMDModPlayerStress(-50,,,true);
    			WaterBuildup += FoodPoints*10;
    			return;
   		break;
		
		//MADDERS, 12/26/20: Candy group.
   		case "CANDYBAR":
    			if (bStressEnabled) VMDModPlayerStress(-35,,,true);
   		break;
		case "CANDYBAR1":
			if (bStressEnabled) VMDModPlayerStress(-35,,,true);
			ClientMessage(CandyEatenDescs[0]);
		break;
		case "CANDYBAR2":
			if (bStressEnabled) VMDModPlayerStress(-35,,,true);
			ClientMessage(CandyEatenDescs[1]);
		break;
		
		//MADDERS, 12/26/20: Soda group.
		case "SODA":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
   		break;
		case "SODA1":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
			ClientMessage(SodaDrankDescs[0]);
   		break;
		case "SODA2":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
			ClientMessage(SodaDrankDescs[1]);
   		break;
		case "SODA3":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
			ClientMessage(SodaDrankDescs[2]);
   		break;
		case "SODA4":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
			ClientMessage(SodaDrankDescs[3]);
   		break;
		case "SODA5":
    			if (bStressEnabled) VMDModPlayerStress(-15,,,true);
			ClientMessage(SodaDrankDescs[4]);
   		break;
		
		//MADDERS, 12/26/20: Addictive stuff group.
		case "CIGARETTESFLUFF":
			ClientMessage(CigarettesSmokedDesc);
   		case "CIGARETTES":
    			if (bStressEnabled) VMDModPlayerStress(-200,,,true);
		break;
   		case "BEERFLUFF":
			ClientMessage(BeerDrankDesc);			
   		case "BEER":
    			if (bStressEnabled) VMDModPlayerStress(-75,,,true);
   		break;
		case "WHISKEYFLUFF":
 			ClientMessage(WhiskeyDrankDesc);			
   		case "WHISKEY":
    			if (bStressEnabled) VMDModPlayerStress(-90,,,true);
  		break;
		case "WINEFLUFF":
			ClientMessage(WineDrankDesc);
   		case "WINE":
    			if (bStressEnabled) VMDModPlayerStress(-90,,,true);
		break;
		case "ZYMEFLUFF":
			ClientMessage(ZymeTakenDesc);
   		case "ZYME":
    			if (bStressEnabled) VMDModPlayerStress(-400,,,true);
   		break;
		case "BIOCELL":
		break;
   		case "MEDKIT":
			//MADDERS: Using medkits negates drug overdoses. This one's a freebie.
 			OverdoseTimers[4] = Clamp(OverdoseTimers[4], 0, AddictionThresholds[4]*2.5);
			OverdoseTimers[3] = Clamp(OverdoseTimers[3], 0, AddictionThresholds[3]*0.3);
   		break;
   		case "MEDBOT":
    			if (bStressEnabled) VMDModPlayerStress(-1000,,,true);
			ClientMessage(MedbotVisitedDesc);
   		break;
   		//MADDERS: Eating this is sometimes toxic. CON-SE-QUEN-CES!
   		//Also, nobody likes dead rats, so handle stress, as well.
   		case "DEAD ANIMAL":
     			if (bStressEnabled) VMDModPlayerStress(25,,,true);
			ClientMessage(AnimalEatenDesc);
   		break;
   		//MADDERS: Why would you do this to yourself?
   		case "GRAY":
    			if (bStressEnabled) VMDModPlayerStress(100,,,true);
			ClientMessage(GrayEatenDesc);
   		break;
  	}
 	
	if (FoodType ~= "Regen")
	{
 		HungerTimer = HungerTimer - ((HungerCap / 13.333) * -FoodPoints * 0.175);
	}
	else
	{
 		HungerTimer = FClamp(HungerTimer - ((HungerCap / 13.333) * FoodPoints), 0, HungerCap*1.1);
		
 		if (FoodPoints > 0)
 		{
  			ClientMessage(SprintF(MsgHungerReduced, FoodPoints));
 		}
 	}
 	if (FoodType != "")
 	{
  		ConsoleCommand("Mutate MutFood"@FoodType);
 	}
}

//Smoke39: I swear to god. If anyone takes my idea for Vanilla Madders... 8/19/09 
function ProcessMaddersChanges()
{
 	local Inventory Inv;
 	local int i;
 	local DeusExLevelInfo LI;
 	
 	//WE IN DIS.
 	if (bLastWasLoad || bAutosaved)
 	{
  		AutoSaveTimer = -2.0; //Disable auto save timer until travel.
  		bLastWasLoad = False;
  		//return;
 	}
  	
 	LI = GetLevelInfo();
	
  	//NEW: Engage our killswitch!
 	if ((bImmersiveKillswitch) && (!bKillswitchEngaged))
 	{
  		if ((LI != None) && (LI.MissionNumber == 5))
  		{
   			Energy = 0;
   			bKillswitchEngaged = True;
			KillswitchPhase = 0;
			BigClientMessage(KillswitchStateDescs[0]);
 		}
 	}
	else if (bKillswitchEngaged)
	{
 		//48*60 = 2880
 		if (KillswitchTime < (2880))
 		{
  			//12 hours old, supposedly, so force this in hong kong.
  			if ((LI != None) && (LI.MissionNumber == 6))
  			{
  				KillswitchTime = (48*60)+1;
  			}
 		}
	}
	
	//MADDERS: This is hacky, but execution order is super important here, so don't fuck up.
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (DeusExPickup(Inv) != None)
		{
				DeusExPickup(Inv).VMDUpdatePropertiesHook();
		}
	}
 	//Check for mission updates. Easy.
 	RegisterMissionUpdate();
}

// ----------------------------------------------------------------------
// VMDResetPlayerNewGamePlus()
//
// Resets all travel variables to their defaults
// ----------------------------------------------------------------------

function VMDResetPlayerNewGamePlus()
{
	local int i;
	local Augmentation TAug;
	local DeusExRootWindow DXRW;
	local DeusExWeapon DXW;
	local inventory TItem, LastItem, NextItem;
	
	//MADDERS additions.
	//VMDResetPlayerToDefaultsHook();
	
   	// reset the image linked list
	FirstImage = None;
	
	DXRW = DeusExRootWindow(RootWindow);
	if (DXRW != None)
	{
		DXRW.ResetFlags();
	}
	
	bNGPlusTravel = True;
	//FlagBase.SetBool('VMDDoingNGPlus', True,, -1);
	
	for(i=0; i<ArrayCount(StoredDroneAlliances); i++)
	{
		StoredDroneAlliances[i] = '';
		StoredDroneHostilities[i] = '';
	}
	
	switch(bNGPlusKeepInventory)
	{
		case 0: //Wipe everything.
			DeleteNGItem('DatavaultImage');
			
			//MADDERS, 3/25/24: Keep our shit in Nihilum, thank you very much.
			if (FlagBase != None)
			{
				FlagBase.SetBool('M60_InventoryRemoved', False,, 70);
			}
			
			// Remove all the keys from the keyring before
			// it gets destroyed
			if (KeyRing != None)
			{
				KeyRing.RemoveAllKeys();
      				if ((Role == ROLE_Authority) && (Level.NetMode != NM_Standalone))
      				{
      		  	 		KeyRing.ClientRemoveAllKeys();
      				}
				KeyRing = None;
			}
			
			while(Inventory != None)
			{
				TItem = Inventory;
				DeleteInventory(TItem);
				TItem.Destroy();
			}
			
			SetupCraftingManager(true);
			
			// Clear object belt
			if ((DXRW != None) && (DXRW.HUD != None) && (DXRW.HUD.Belt != None))
			{
				DXRW.HUD.Belt.ClearBelt();
			}
		break;
		case 1: //Keep keys.
			DeleteNGItem('DatavaultImage');
			
			//MADDERS, 3/25/24: Keep our shit in Nihilum, thank you very much.
			if (FlagBase != None)
			{
				FlagBase.SetBool('M60_InventoryRemoved', False,, 70);
			}
			
			while(Inventory != None)
			{
				TItem = Inventory;
				DeleteInventory(TItem);
				TItem.Destroy();
			}
			
			SetupCraftingManager(true);
			
			// Clear object belt
			if ((DXRW != None) && (DXRW.HUD != None) && (DXRW.HUD.Belt != None))
			{
				DXRW.HUD.Belt.ClearBelt();
			}
		break;
		case 2: //No weapons.
			DeleteNGItem('DatavaultImage');
			DeleteNGItem('DeusExWeapon');
			
			SetupCraftingManager(true);
		break;
		case 3: //No weapon mods.
			DeleteNGItem('DatavaultImage');
			for(TItem = Inventory; TItem != None; TItem = NextItem)
			{
				NextItem = TItem.Inventory;
				
				DXW = DeusExWeapon(TItem);
				if (DXW != None)
				{
					DXW.bHasLaser = DXW.Default.bHasLaser;
					DXW.bHasScope = DXW.Default.bHasScope;
					DXW.bHasSilencer = DXW.Default.bHasSilencer;
					DXW.ModAccurateRange = DXW.Default.ModAccurateRange;
					DXW.ModBaseAccuracy = DXW.Default.ModBaseAccuracy;
					DXW.ModRecoilStrength = DXW.Default.ModRecoilStrength;
					DXW.ModReloadCount = DXW.Default.ModReloadCount;
					DXW.ModReloadTime = DXW.Default.ModReloadTime;
					
					DXW.VMDUpdateWeaponModStats();
				}
				
				LastItem = TItem;
			}
			
			SetupCraftingManager(true);
			
			switch(Caps(SelectedCampaign))
			{
				case "CARONE":
					ReplaceNGItem('WeaponLAM', "HotelCarone.WeaponHCLAM");
					ReplaceNGItem('WeaponEMPGrenade', "HotelCarone.WeaponHCEMPGrenade");
					ReplaceNGItem('WeaponGasGrenade', "HotelCarone.WeaponHCGasGrenade");
					ReplaceNGItem('WeaponNanoVirusGrenade', "HotelCarone.WeaponHCNanoVirusGrenade");
				break;
				default:
					ReplaceNGItem('WeaponHCLAM', "DeusEx.WeaponLAM");
					ReplaceNGItem('WeaponHCEMPGrenade', "DeusEx.WeaponEMPGrenade");
					ReplaceNGItem('WeaponHCGasGrenade', "DeusEx.WeaponGasGrenade");
					ReplaceNGItem('WeaponHCNanoVirusGrenade', "DeusEx.WeaponNanoVirusGrenade");
				break;
			}
		break;
		case 4: //Keep everything.
			DeleteNGItem('DatavaultImage');
			
			SetupCraftingManager(true);
			
			switch(Caps(SelectedCampaign))
			{
				case "CARONE":
					ReplaceNGItem('WeaponLAM', "HotelCarone.WeaponHCLAM");
					ReplaceNGItem('WeaponEMPGrenade', "HotelCarone.WeaponHCEMPGrenade");
					ReplaceNGItem('WeaponGasGrenade', "HotelCarone.WeaponHCGasGrenade");
					ReplaceNGItem('WeaponNanoVirusGrenade', "HotelCarone.WeaponHCNanoVirusGrenade");
				break;
				default:
					ReplaceNGItem('WeaponHCLAM', "DeusEx.WeaponLAM");
					ReplaceNGItem('WeaponHCEMPGrenade', "DeusEx.WeaponEMPGrenade");
					ReplaceNGItem('WeaponHCGasGrenade', "DeusEx.WeaponGasGrenade");
					ReplaceNGItem('WeaponHCNanoVirusGrenade', "DeusEx.WeaponNanoVirusGrenade");
				break;
			}
		break;
	}
	
	if (!bNGPlusKeepInfamy)
	{
		bCheckedFirstMayhem = false;
		MayhemFactor = 0;
		OwedMayhemFactor = 0;
		AllureFactor = 0;
	}
	
	switch(bNGPlusKeepAugs)
	{
		case 0: //No augs.
			if (AugmentationSystem != None)
			{
				AugmentationSystem.ResetAugmentations();
				AugmentationSystem.Destroy();
				AugmentationSystem = None;
			}
		break;
		case 1: //No upgrades.
			for (TAug = AugmentationSystem.FirstAug; TAug != None; TAug = TAug.Next)
			{
				TAug.CurrentLevel = 0;
			}
		break;
	}
	
	// clear the notes and the goals
	DeleteAllNotes();
	DeleteAllGoals();
	
	// Nuke the history
	ResetConversationHistory();
	
	// Other defaults
	Credits = Default.Credits + int(float(Credits) * float(bNGPlusKeepMoney) * 0.25);
	
	Energy = Default.Energy;
	
	if (bNGPlusKeepSkills < 4)
	{
		//ResetSkillSpecializations();
		if (SkillSystem != None)
		{
			SkillSystem.ResetSkills();
		}
		ResetSkillAugments();
		FormatSkillAugmentPointsLeft();
		SkillPointsTotal = Default.SkillPointsTotal + int(float(SkillPointsTotal) * float(bNGPlusKeepSkills) * 0.25);
		SkillPointsAvail = Default.SkillPointsAvail + int(float(SkillPointsAvail) * float(bNGPlusKeepSkills) * 0.25);
		SkillPointsSpent = 0;
	}
	else
	{
		ResetSkillAugments();
		FormatSkillAugmentPointsLeft();
	}
	
	VMDResetPlayerHook(false);
	
	SetInHandPending(None);
	SetInHand(None);
	
	bInHandTransition = False;
	
	RestoreAllHealth();
	ClearLog();
	
	// Reset save count/time
	saveCount = 0;
	saveTime = 0.0;
	
	// Reinitialize all subsystems we've just nuked
	InitializeSubSystems();
	
   	// Give starting inventory.
   	if (Level.Netmode != NM_Standalone)
	{
		NintendoImmunityEffect( True );
      		GiveInitialInventory();
	}
	
	if (MayhemFactor < 0) MayhemFactor = 0;
	if (AllureFactor < 0) AllureFactor = 0;
}

exec function StartNewGamePlus(optional MapExit Reroute)
{
	local DeusExRootWindow root;
	local VMDMenuSelectNGPlusOptions NGOptions;
	
	root = DeusExRootWindow(rootWindow);
	if (root != None)
	{
		NGOptions = VMDMenuSelectNGPlusOptions(root.InvokeMenuScreen(class'VMDMenuSelectNGPlusOptions', false));
		NGOptions.Reroute = Reroute;
	}
}

exec function AllWeaponMods()
{
	if (!bCheatsEnabled) return;
	
	ConsoleCommand("Spawnmass WeaponModMajor 20");
	ConsoleCommand("Spawnmass WeaponModMinor 20");
}

exec function AllBits()
{
	if (!bCheatsEnabled) return;
	
	ConsoleCommand("AllPickups");
	ConsoleCommand("AllAmmo");
	ConsoleCommand("AllHealth");
	ConsoleCommand("AllEnergy");
	ConsoleCommand("AllScrap");
	ConsoleCommand("AllChemicals");
	ConsoleCommand("AllRecipes");
}

exec function AllScrap()
{
	if (!bCheatsEnabled) return;
	
	CurScrap = MaxScrap;
	
	ClientMessage("Scrap set to "$MaxScrap);
}

exec function AllChemicals()
{
	if (!bCheatsEnabled) return;
	
	CurChemicals = MaxChemicals;
	
	ClientMessage("Chemicals set to "$MaxChemicals);
}

exec function AllRecipes()
{
	if (!bCheatsEnabled) return;
	
	if (CraftingManager != None)
	{
		CraftingManager.DiscoverAllItems();
		
		ClientMessage("All recipes unlocked!");
	}
}

function int VMDCountNumPickups(class<DeusExPickup> CheckClass, optional bool bCountStacksOnly)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = Inventory; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			if ((!bCountStacksOnly) && (DeusExPickup(CurInv).bCanHaveMultipleCopies))
			{
				Ret += DeusExPickup(CurInv).NumCopies;
			}
			else
			{
				Ret++;
			}
		}
	}
	return Ret;
}

function int VMDCountNumWeapons(class<DeusExWeapon> CheckClass)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = Inventory; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			Ret++;
		}
	}
	return Ret;
}

//MADDERS, 1/28/21: Max our pickup copies, thanks.
exec function AllPickups()
{
	local int i;
	local Inventory Inv;
	local DeusExPickup DXP;
	local ChargedPickup ChP;
	
	if (!bCheatsEnabled) return;
	
	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		DXP = DeusExPickup(Inv);
		if (DXP != None)
		{
			ChP = ChargedPickup(DXP);
			if (DXP.bCanHaveMultipleCopies)
			{
				DXP.NumCopies = DXP.VMDConfigureMaxCopies();
			}
			if (ChP != None)
			{
				ChP.Charge = ChP.Default.Charge;
				for (i=0; i<ChP.VMDConfigureMaxCopies(); i++)
				{
					ChP.ChargeStacks[i] = ChP.Default.Charge;
				}
			}
			DXP.UpdateBeltText();
		}
	}
}

exec function AllAmmo()
{
	local Inventory Inv, item, nextItem;
	local Ammo foundAmmos[32], newAmmo;
	local int i, j;
	local bool bAmmoFound;
	
	if(!bCheatsEnabled)
		return;
	
	if ((!bAdmin) && (Level.Netmode != NM_Standalone))
		return;
	
	if (bCheatsEnabled)
	{
		// DEUS_EX CNN - make this be limited by the MaxAmmo per ammo instead of 999
		for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory ) 
			if (Ammo(Inv)!=None) 
			{
				if (DeusExAmmo(Inv) != None)
				{
					DeusExAmmo(Inv).AmmoAmount = DeusExAmmo(Inv).VMDConfigureMaxAmmo();
				}
				else
				{
					Ammo(Inv).AmmoAmount = Ammo(Inv).MaxAmmo;
				}
			}

		for(item = Inventory; item != None; item = nextItem)
		{
			nextItem = item.Inventory;
			
			// To make AllAmmo respect Biomod's max grenades change
			if (Ammo(item) != None && !item.bDeleteMe)
			{
				Ammo(item).AddAmmo(999999);
				foundAmmos[i] = Ammo(item);
				i++;
			}
			
			if (!item.IsA('Ammo') && !item.IsA('NanoKeyRing') && !item.IsA('Nanokey') && !item.IsA('DataVaultImage'))
			{
				nextItem = item.Inventory;
				UpdateBeltText(item);
			}
		}
		
		for(item = Inventory; item != None; item = nextItem)
		{
			nextItem = item.Inventory;

			if (DeusExWeapon(item) != None)
			{
				for (j=0;j < ArrayCount(DeusExWeapon(item).AmmoNames);j++)
				{
					if (DeusExWeapon(item).AmmoNames[j] != None)
					{
						bAmmoFound = False;
						for(i=0;i < ArrayCount(foundAmmos);i++)
						{
							if (foundAmmos[i] == None)
								break;

							if (foundAmmos[i].Class == DeusExWeapon(item).AmmoNames[j])
								bAmmoFound = True;
						}
						if (!bAmmoFound)
						{
							NewAmmo = Spawn(DeusExWeapon(item).AmmoNames[j],,, Location);
							NewAmmo.Frob(Self, None);
							NewAmmo.AddAmmo(999999);
						}
					}
				}
			}

			if (!item.IsA('Ammo') && !item.IsA('NanoKeyRing') && !item.IsA('Nanokey') && !item.IsA('DataVaultImage'))
			{
				nextItem = item.Inventory;
				UpdateBeltText(item);
			}
		}
	}
}

//MADDERS: Misc testing function
exec function SemiGhost(bool bOn)
{
	if(!bCheatsEnabled)
		return;
	
	if ((!bAdmin) && (Level.Netmode != NM_Standalone))
		return;
	
	SetCollision(!bOn, True, True);
	
	if (!bCollideActors) ClientMessage("Semi-Ghost Mode On");
	else ClientMessage("Semi-Ghost Mode Off");
}


state FeigningDeath
{
ignores SeePlayer, HearNoise, Bump;

	function Rise()
	{
		if ( !bRising )
		{
			Enable('AnimEnd');
			
			//MADDERS, 10/26/21: Yeah, this is on its way out. Thanks.
			//BaseEyeHeight = Default.BaseEyeHeight;
			
			//MADDERS: Update female size a bit here.
			VMDUpdateBaseEyeHeight();
			
			bRising = true;
			PlayRising();
		}
	}
	
	function AnimEnd()
	{
		if ( (Role == ROLE_Authority) && (Health > 0) )
		{
			GotoState('PlayerWalking');
			if (PendingWeapon != None)
			{
				PendingWeapon.SetDefaultDisplayProperties();
				ChangedWeapon();
			}
		}
	}
}

function ClientReStart()
{
	Super.ClientRestart();
	
	//MADDERS: Update female size a bit here.
	VMDUpdateBaseEyeHeight();
}

//MADDERS, 11/6/22: Overriding some bullshit for better dynamic water height.
event FootZoneChange(ZoneInfo newFootZone)
{
	local actor HitActor;
	local vector HitNormal, HitLocation, TLoc;
	local float splashSize;
	local actor splash;
	local VMDWaterLevelActor TAct;
	
	if ((WaterZone(NewFootZone) != None) && (WaterZone(NewFootZone).OwningTrigger != None))
	{
		TAct = WaterZone(NewFootZone).OwningTrigger.WaterLevelActor;
	}
	
	if ( Level.NetMode == NM_Client )
		return;
	if ( Level.TimeSeconds - SplashTime > 0.25 ) 
	{
		SplashTime = Level.TimeSeconds;
		if (Physics == PHYS_Falling)
			MakeNoise(1.0);
		else
			MakeNoise(0.3);
		if (FootRegion.Zone.bWaterZone)
		{
			if ((!newFootZone.bWaterZone) && (Role == ROLE_Authority))
			{
				if ( FootRegion.Zone.ExitSound != None )
					PlaySound(FootRegion.Zone.ExitSound, SLOT_Interact, 1,,, LastGameSpeed); 
				if ( FootRegion.Zone.ExitActor != None )
				{
					TLoc = Location - CollisionHeight * vect(0,0,1);
					if (TAct != None)
					{
						TLoc.Z = TAct.Location.Z;
					}
					Splash = Spawn(FootRegion.Zone.ExitActor,,, TLoc);
					if (Splash != None)
					{
						if (TAct != None)
						{
							Splash.SetBase(TAct);
						}
					}
				}
			}
		}
		else if ((newFootZone.bWaterZone) && (Role == ROLE_Authority))
		{
			splashSize = FClamp(0.000025 * Mass * (300 - 0.5 * FMax(-500, Velocity.Z)), 1.0, 4.0 );
			if ( newFootZone.EntrySound != None )
			{
				HitActor = Trace(HitLocation, HitNormal, 
						Location - (CollisionHeight + 40) * vect(0,0,0.8), Location - CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize,,, LastGameSpeed);
				else 
					PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize,,, LastGameSpeed);
			}
			if(newFootZone.EntryActor != None)
			{
				TLoc = Location - CollisionHeight * vect(0,0,1);
				if (TAct != None)
				{
					TLoc.Z = TAct.Location.Z;
				}
				splash = Spawn(newFootZone.EntryActor,,, TLoc);
				
				if (Splash != None)
				{
					Splash.DrawScale = splashSize;
					if (TAct != None)
					{
						Splash.SetBase(TAct);
					}
				}
			}
			//log("Feet entering water");
		}
	}
	
	if (FootRegion.Zone.bPainZone)
	{
		if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
			PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
		PainTime = 0.01;
}

exec function ParalyzeMe(bool AnyPhysics)
{
	if (IsInState('TrulyParalyzed'))
	{
		if (PreParalyzedPhysics == PHYS_Falling || PreParalyzedPhysics == PHYS_Walking)
		{
			SetPhysics(PreParalyzedPhysics);
			GoToState('PlayerWalking');
			Velocity = PreParalyzedVelocity;
			Acceleration = PreParalyzedAcceleration;
		}
		else if (PreParalyzedPhysics == PHYS_Swimming)
		{
			SetPhysics(PreParalyzedPhysics);
			GoToState('PlayerSwimming');
			Velocity = PreParalyzedVelocity;
			Acceleration = PreParalyzedAcceleration;
		}
	}
	else
	{
		PreParalyzedVelocity = Velocity;
		if (AnyPhysics)
		{
			GoToState('TrulyParalyzed', 'BeginAnyPhysics');
		}
		else
		{
			PreParalyzedAcceleration = Acceleration;
			PreParalyzedPhysics = Physics;
			GoToState('TrulyParalyzed', 'Begin');
		}
	}
}

//MADDERS, 5/9/24: As a way to disable player inputs in a mod? Aight.
state TrulyParalyzed
{
	ignores all;
	
Begin:
	SetPhysics(PHYS_None);
BeginAnyPhysics:
	Stop;
}

//MADDERS, 11/3/24: Weird change for SIDD here. Engine, you sneaky bastard.
singular event BaseChange()
{
	local float decorMass;
	
	if ((base == None) && (Physics == PHYS_None))
	{
		SetPhysics(PHYS_Falling);
	}
	else if ((Pawn(Base) != None) && (VMDSIDD(Base) == None))
	{
		Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , 'stomped');
		JumpOffPawn();
	}
	else if ((Decoration(Base) != None) && (Velocity.Z < -400))
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, 'stomped');
	}
}

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function FindGoodView();
function PlayerMove(Float DeltaTime);
function Rise();
function Dodge(eDodgeDir DodgeMove);

defaultproperties
{
     CandyEatenDescs(0)="The gooey, honey ribbons of the bar prove quite fantastic and nourishing"
     CandyEatenDescs(1)="The bar's ridges of nuts and crisps produce a satisfying, salty, earthy flavor"
     SoyEatenDesc="The packet's marketing is a far cry from the bland trash actually contained within its bounds"
     FishEatenDesc="While certainly not prepared, the rich and brine-like taste of your improvised meal proves to be quite the treat."
     SodaDrankDescs(0)="The tangy, orange flavor of the soda is generic, but always proves satisfying regardless"
     SodaDrankDescs(1)="The resulting 'zap' of sharp, grape flavor certainly has accents of both synthetic and natural, yet is quite nostalgic"
     SodaDrankDescs(2)="The blitz of purely artificial, tart, berry flavor is unrelenting, but exceedingly effective at satisfying one's sweet tooth"
     SodaDrankDescs(3)="The outlandish and tropical flavor is something of an oddity, but is exceedingly refreshing and flavorful"
     SodaDrankDescs(4)="The strong and vibrant lemon-lime flavor is very nice. It's fresh and cool, quenching your thirst quite well"
     WaterDrankDesc="The rushing cool of the water soothes you explicitly"
     WaterWoozyDesc="You're starting to feel unwell. That should be enough water"
     CigarettesSmokedDesc="You find your nerves steady somewhat as the warmth of the bitter element passes into you"
     BeerDrankDesc="It tastes how it smells: like dry, washed out piss... You shouldn't have had your hopes up. However, it proves calming to the nerves"
     WhiskeyDrankDesc="The hard, characteristic profile of the liquor beats your nerves well past submission, and clear into sedation"
     WineDrankDesc="Flavorful and ever so slightly tart, the red wine in question does a fine job bringing some class to an otherwise classless world"
     ZymeTakenDesc="You can feel yourself falling out of your body as reality and as your perception breaks from its standard ranges"
     MedkitUsedDescs(0)="Your supreme cool and confidence applying your practiced art feeds back into itself, letting your nerves hold steady once more"
     MedkitUsedDescs(1)="Your hands shake, doing what needs to be done. You've done your part, but the process hasn't brought you much joy"
     MedbotVisitedDesc="The precision and unyielding confidence of the bot is nothing short of amazing. You watch as it mends your wounds with extreme ease"
     AnimalEatenDesc="You gag on the ill-prepared meat... But what needs to be done is done... It will sustain you until further notice"
     GrayEatenDesc="As you attempt to choke down the gray's meat, you feel ill... Why did this seem like a good idea?"
     EnergyBackfireDesc="You feel your skin writhe and your heart race... The last thing you needed was to feed your nanites"
     KillswitchStateDescs(0)="You feel empty and weak, and your augs seem deaf to your requests... It's got to be the killswitch"
     KillswitchStateDescs(1)="Your body feels increasingly withered with time... Now is not the time to take a bullet"
     KillswitchStateDescs(2)="You feel woozy and disconnected from your body... Damned nanites..."
     KillswitchStateDescs(3)="Your head pounds and crushes, challenging your ability to even stay conscious..."
     KillswitchStateDescs(4)="Your vision fades away beneath a dark haze, the world slipping away... You're running out of time"
     KillswitchStateDescs(5)="Your legs begin to misfire and tangle up on themselves, as if you were a machine with its wires crossed"
     KillswitchStateDescs(6)="Your time is up. You can feel chunks of your body tearing away and failing in short order... This is it"
     KillswitchStateDescs(7)="A relief unlike anything you've ever felt, your systems return to normal... Talk about a close call"
     FoodSmellDesc(0)="The aroma of excess food clears from your person"
     FoodSmellDesc(1)="Your person begins to vaguely smell of food..."
     FoodSmellDesc(2)="While still present, your savory smell is now diminished and less obvious"
     FoodSmellDesc(3)="The food smell coming off of your body has become strong and unmistakable"
     BloodSmellDesc(0)="The stench of carnage clears from your person"
     BloodSmellDesc(1)="Your person has become ensnared with the stench of blood..."
     BloodSmellDesc(2)="While still obvious, your murderous stench has become diminished"
     BloodSmellDesc(3)="Far from improving, the fog of murder surrounding your person has become impossible to miss"
     ZymeSmellDesc(0)="The stench of illicit drugs fades from your person"
     ZymeSmellDesc(1)="You've gained the scent of a zyme addict..."
     SmokeSmellDesc(0)="The scent of incineration has cleared from your person"
     SmokeSmellDesc(1)="Your form begins to smell of cinders..."
     SmokeSmellDesc(2)="While still distinct, your ashen profile has become reduced"
     SmokeSmellDesc(3)="At this point, the intensity of your smokey odor is simply unmistakeable"
     HungerLevelDesc(0)="That really hit the spot. You're quite full now"
     HungerLevelDesc(1)="You find yourself growing peckish..."
     HungerLevelDesc(2)="Much better. Now you're only mildly hungry"
     HungerLevelDesc(3)="Your level of hunger is growing by the minute..."
     HungerLevelDesc(4)="Close one. That'll keep you going... For now"
     HungerLevelDesc(5)="You're outright famished. You're not sure how much longer you can go without food..."
     HungerLevelDesc(6)="Your stomach rips and tears... You're officially starving"
     StressLevelDesc(0)="Your nerves calm back down to a state of pure serenity"
     StressLevelDesc(1)="Your nerves bind and bunch, your stress growing by the minute..."
     StressLevelDesc(2)="Your nerves recede back to a state of only moderate stress... You're not complaining"
     StressLevelDesc(3)="You find yourself bordering on paranoid, afraid of a strike at any time..."
     StressLevelDesc(4)="Your heart has calmed down, but your mind is still racing nonstop"
     StressLevelDesc(5)="You feel your heart leap out of your chest and your mind tie itself in knots... You've depleted all sense of calm"
     RollCooldownDesc="Having regained your footing, you think you're ready for another swift maneuver."
     DodgeRollCooldownDesc="Your dizziness has subsided. You're feeling up for another slick move."
     OverdoseDescs(0)="Your heart beats erratically and your breathing constrincts... You've probably had too much Zyme..."
     OverdoseDescs(1)="You feel queasy, as your nerves flail and your breathing pauses... You've definitely had too much alcohol..."
     OverdoseDescs(2)="You feel light headed and weak, as your chest constricts slightly... You've officially had too much water..."
     MsgNoHardwareSkill="To be honest, you have no idea what you're doing with all this HARDWARE"
     MsgNoHardwareRecipes="You don't actually know any hardware recipes, now that you think about it"
     MsgNoMedicineSkill="This is of no use to you. It's not like you practice MEDICINE or anything..."
     MsgNoMedicineRecipes="You don't actually know any medical recipes, now that you think about it"
     MsgCantCraftUnderwater="You cannot craft underwater"
     MsgAlreadyCrafting="You are already crafting"
     FoodSmellThresholds(0)=1000
     FoodSmellThresholds(1)=2000
     
     MsgScrapAdded="%d scrap added"
     MsgScrapFull="You can't hold any more scrap"
     MsgChemicalsAdded="%d chemical(s) added"
     MsgChemicalsFull="You can't hold any more chemicals"
     MsgSkillUpgradeAvailable="Upgrade now available for %d!"
     
     KillswitchThresholds(0)=0.000000
     KillswitchThresholds(1)=1920.000000
     KillswitchThresholds(2)=3360.000000
     KillswitchThresholds(3)=4320.000000
     KillswitchThresholds(4)=5280.000000
     KillswitchThresholds(5)=5520.000000
     KillswitchThresholds(6)=5760.000000
     KillswitchThresholds(7)=12000.000000
     ModGroundSpeedMultiplier=-1.000000
     ModOrganicVisibilityMultiplier=-1.000000
     ModRobotVisibilityMultiplier=-1.000000
     ModWaterSpeedMultiplier=-1.000000
     ModHealthMultiplier=-1.000000
     ModHealingMultiplier=-1.000000
     AddictionThresholds(0)=135
     AddictionThresholds(1)=270
     AddictionThresholds(2)=300
     AddictionThresholds(3)=240
     AddictionThresholds(4)=300
     AddictionKickTimers(0)=-1.000000
     AddictionKickTimers(1)=-1.000000
     AddictionKickTimers(2)=-1.000000
     AddictionKickTimers(3)=-1.000000
     AddictionKickTimers(4)=-1.000000
     UnivStressScales(0)=0.5 //Updates relative to dark and surroundings
     UnivStressScales(1)=0.25 //Scale for damage scaling
     UnivStressScales(2)=0.8 //Wounded Anxiety
     UnivStressScales(3)=1.25 //Proximity Anxiety
     UnivStressScales(4)=1.0 //Low ammo
     BloodSmellLevel=-1.000000
     ZymeSmellLevel=-1.000000
     SmokeSmellLevel=-1.000000
     TaseDuration=-1.00000
     HUDEMPTimer=-1.000000
     HUDScramblerTimer=-1.000000
     ActiveStress=-0.100000
     StressMomentum=-0.100000
     
     SugarName="Sugar"
     CaffeineName="Caffeine"
     NicotineName="Nicotine"
     AlcoholName="Alcohol"
     CrackName="Zyme"
     MsgCraving="You find yourself craving %s..."
     MsgHungerReduced="Hunger diminished by %d"
     MsgNewHabit="You find yourself growing fond of %s..."
     MsgKickedHabit="You feel a newfound sense of independence from %s..."
     MsgDeathNegated="While somehow still alive, you feel cold and ghastly... There's no way you can take a second hit like that"
     MsgDeathNegateCooledDown="A feeling of warmth and steadiness has returned to your form. Cheating death again feels attainable"
     MsgNoArmsToCarry="Both of your arms are broken"
     MsgNeedMoreTools="You need %d more multitool(s)"
     MsgNoTools="You don't have any multitools"
     MsgNeedMorePicks="You need %d more lockpick(s)"
     MsgNoPicks="You don't have any lockpicks"
     MsgDontHaveKey="You don't have the right key"
     
     bAddictionEnabled=1
     bGrimeEnabled=True
     bHungerEnabled=True
     bBioHungerEnabled=True
     bStressEnabled=True
     bSmellsEnabled=True
     bSkillAugmentsEnabled=True
     bAutosaveEnabled=True
     bRefireSemiauto=False
     bImmersiveKillswitch=True
     bD3DPrecachingEnabled=False
     bHitIndicatorHasVisual=True
     bHitIndicatorHasAudio=True
     bAllowFemJC=True
     bCodebreakerPreference=False
     bEnvironmentalSoundsEnabled=True
     bModdedCharacterSetupMusic=True
     bAllowTiltEffects=True
     bAdvancedLimbDamage=False //12/14/21: Disabled by default, but forced on in nightmare and gallows.
     bUseDynamicCamera=True
     bUseInstantCrafting=False
     bCraftingSystemEnabled=True
     bBoostAugNoise=True
     bAllowAnyNGPlus=False
     bAutoloadAppearanceSlots=False
     bRealtimeUI=False
     bRealTimeControllerAugs=False
     bRealisticRollCamera=0
     bMEGHRadarPing=True
     bAllowPickupTiltEffects=True
     bPlayerHandsEnabled=True
     bAllowPlayerHandsTiltEffects=True
     bDecorationFrobHolster=True
     bDoorFrobKeyring=True
     DoorFrobLockpick=1
     bElectronicsDrawMultitool=True
     bUpdateVanillaSkins=True
     bJumpDuckFeedbackNoise=True
     bDamageGateBreakNoise=True
     bUseGunplayVersionTwo=False
     bFrobEmptyLowersWeapon=True
     bDisplayUncraftableItems=False
     VMDbNoFlash=True
     CustomUIScale=2
     
     PreferredHandedness=-1
     PlayerHandsCap=0.300000
     
     //8/25/23: New HUD element control. Default is to keep them on, though, of course.
     bAimFocuserVisible=True
     bDroneAllianceVisible=True
     bHUDVisible=True
     bFrobDisplayBordersVisible=True
     bLogVisible=True
     bSmellIndicatorVisible=True
     bLightGemVisible=True
     bSkillNotifierVisible=True
     
     bAllowFemaleVoice=true
     
     bGaveNewGameTips=False
     ScreenEffectScalar=0.340000
     NegateDeathGateTime=1.500000
     
     StrPostKillswitchFudge="Meet Tong in the control room of his lab"
     MsgDroneCollision="ERROR: Flight cycle interrupted"
     MsgNoDroneGrid="ERROR: No grid available for Autopath v2.7c"
     StrDroneNameTerrain="Terrain"
     DroneHealth=-1
     DroneEMPHitPoints=-1
     DroneAmmoLeft=-1
     DroneWeaponModSilencer=-1
     DroneWeaponModScope=-1
     DroneWeaponModLaser=-1
     DroneWeaponModEvolution=-1
     DroneWeaponModBaseAccuracy=-1.000000
     DroneWeaponModReloadCount=-1.000000
     DroneWeaponModAccurateRange=-1.000000
     DroneWeaponModReloadTime=-1.000000
     DroneWeaponModRecoilStrength=-1.000000
     DroneGunClass="NULL"
     
     LastGenerousWeaponModSilencer=-1
     LastGenerousWeaponModScope=-1
     LastGenerousWeaponModLaser=-1
     LastGenerousWeaponModEvolution=-1
     LastGenerousWeaponModAccuracy=-1.000000
     LastGenerousWeaponModReloadCount=-1.000000
     LastGenerousWeaponModAccurateRange=-1.000000
     LastGenerousWeaponModReloadTime=-1.000000
     LastGenerousWeaponModRecoilStrength=-1.000000
     LastGenerousWeaponClass="NULL"
     
     LastBrowsedAug=-1
     LastBrowsedAugPage=-1
     
     bRefuseWeaponAssaultGun=0
     bRefuseWeaponAssaultShotgun=0
     bRefuseWeaponBaton=0
     bRefuseWeaponCombatKnife=0
     bRefuseWeaponCrowbar=0
     bRefuseWeaponEMPGrenade=0
     bRefuseWeaponFlamethrower=0
     bRefuseWeaponGasGrenade=0
     bRefuseWeaponGEPGun=0
     bRefuseWeaponHideAGun=0
     bRefuseWeaponLAM=0
     bRefuseWeaponLAW=0
     bRefuseWeaponMiniCrossbow=0
     bRefuseWeaponNanoSword=0
     bRefuseWeaponNanoVirusGrenade=0
     bRefuseWeaponPepperGun=0
     bRefuseWeaponPistol=0
     bRefuseWeaponPlasmaRifle=0
     bRefuseWeaponProd=0
     bRefuseWeaponRifle=0
     bRefuseWeaponSawedOffShotgun=0
     bRefuseWeaponShuriken=0
     bRefuseWeaponStealthPistol=0
     bRefuseWeaponSword=0
     
     bRefuseWeaponMod=1
     bRefuseAugmentationCannister=1
     bRefuseAugmentationUpgradeCannister=1
     bRefuseBinoculars=1
     bRefuseBioelectricCell=0
     bRefuseCandybar=1
     bRefuseCigarettes=1
     bRefuseFireExtinguisher=0
     bRefuseFlare=1
     bRefuseLiquor40oz=1
     bRefuseLiquorBottle=1
     bRefuseMedKit=0
     bRefuseSodacan=1
     bRefuseSoyFood=1
     bRefuseVialAmbrosia=1
     bRefuseVialCrack=1
     bRefuseWineBottle=1
     
     bRefuseMultitool=0
     bRefuseLockpick=0
     bRefuseVMDChemistrySet=1
     bRefuseVMDToolbox=1
     
     bRefuseAdaptiveArmor=1
     bRefuseBallisticArmor=1
     bRefuseHazMatSuit=1
     bRefuseRebreather=1
     bRefuseTechGoggles=1
     
     MayhemFactor=-1
     AllureFactor=-1
     
     LastWeaponDamageSkillMult=-1.000000
     TimerDifficulty=1.000000
     EnemyHPScale=1.000000
     NegateDeathCooldown=-1.000000
     RollCooldownTimer=-1.000000
     DodgeRollCooldownTimer=-1.000000
     GallowsSaveGateTimer=-1.00000
     GallowsSaveGateTime=-1.000000
     SaveGateCombatThreshold=2
     BarfHunterThreshold=5
     SavedHunterQuantity=1
     SavedHunterThreshold=125
     SavedMayhemForgiveness=-25
     SavedGateBreakThreshold=-50
     SavedLootSwapSeverity=1
     
     EnemySurprisePeriodMax=99.000000
     EnemyROFWeight=0.000000
     EnemyReactionSpeedMult=1.000000
     EnemyVisionRangeMult=1.000000
     EnemyVisionStrengthMult=1.000000
     EnemyHearingRangeMult=1.000000
     EnemyGuessingFudge=0.000000
     EnemyAccuracyMod=0.000000
     
     KSHealMult=1.000000
     HungerCap=2400.000000
     RollCooldown=10.000000
     RollDuration=0.700000
     RollTapMax=0.150000
     DodgeRollCooldown=10.000000
     DodgeRollDuration=1.2000000
     StressMomentum=1.000000
     DodgeClickTime=0.100000
     TacticalRollTime=0.150000
     UIForceDuckTime=0.350000
     InventoryFullNull="You cannot remove the %s"
     InventoryFullFeedback="You don't have enough room in your inventory to pick up the %s. You require %dx%d in space"
     
     ItemRefusedString="You cannot pickup the %s due to your item-refusal settings. To change this, go to Settings > VMD Options > Item Refusal, or try to pick it up again."
     TooHotToLift="It's too hot to handle"
     bAltSpyDroneView=False // Transcended - Added
     bInformationDevices=True
     bShowHealthStatuses=True
     
     bAISmartWeaponSwap=True
     bAIRecogniseMovedObjects=True
     bAILookAtPlayer=True
     bAIReactToLaser=True
     bAIReactToWeapon=True
     bAIGEPGunLocking=True
     bCamerasSeeBodies=True
     bAIDropArmedGrenades=False	// Maybe too silly.
     bAISmartAiming=True
     bComputerNoInvisibility=True
     bUseAutosave=True
     bEmailSavingOption=True
     bAIDogJumping=True
     bNoisyObjectUsage=True
     bAIReactUnconscious=True
     bAINonStandardAmmo=True
     bRegenStayOn=True
     bSmartEnemyWeaponSwapEnabled=true
     bDrawMeleeEnabled=true
     bEnemyGEPLockEnabled=true
     
     QuickSaveNumber=-1
     CountRemainingString="amount remaining:"
     CurScrap=100
     CurChemicals=100
     MaxScrap=1000
     MaxChemicals=1000
     
     MutationsMapTip="TIP: Make sure you have a keybind set for using the 'show map' feature seen in Mutations."
     SaveGameGenders(0)="Male"
     SaveGameGenders(1)="Female"
     StrDifficultyNames(0)="Cakewalk"
     StrDifficultyNames(1)="Easy"
     StrDifficultyNames(2)="Medium"
     StrDifficultyNames(3)="Hard"
     StrDifficultyNames(4)="Realistic"
     StrDifficultyNames(5)="Nightmare"
     StrDifficultyNames(6)="Gallows"
     StrDifficultyNames(7)="Condemned"
     StrCustomDifficulty="Custom"
     SaveGameNGPlus=" [NewGame+] "
     
     MapStylePlaces(0)="Intro"
     MapStylePlaces(1)="Liberty Island"
     MapStylePlaces(2)="UNATCO"
     MapStylePlaces(3)="Battery Park"
     MapStylePlaces(4)="New York City"
     MapStylePlaces(5)="Mole People"
     MapStylePlaces(6)="Airfield"
     MapStylePlaces(7)="UNATCO Sublevel"
     MapStylePlaces(8)="Hong Kong"
     MapStylePlaces(9)="Versalife"
     MapStylePlaces(10)="Shipyard"
     MapStylePlaces(11)="Graveyard"
     MapStylePlaces(12)="Paris"
     MapStylePlaces(13)="Catacombs"
     MapStylePlaces(14)="Chateau"
     MapStylePlaces(15)="Cathedral"
     MapStylePlaces(16)="Everett"
     MapStylePlaces(17)="Vandenberg"
     MapStylePlaces(18)="Gas Station"
     MapStylePlaces(19)="Oceanlab"
     MapStylePlaces(20)="Missile Silo"
     MapStylePlaces(21)="Endgame"
     MapStylePlaces(22)="Outro"
     MapStylePlaceNames(0)="Intro"
     MapStylePlaceNames(1)="Liberty Island"
     MapStylePlaceNames(2)="UNATCO"
     MapStylePlaceNames(3)="Battery Park"
     MapStylePlaceNames(4)="New York City"
     MapStylePlaceNames(5)="Mole People"
     MapStylePlaceNames(6)="Airfield"
     MapStylePlaceNames(7)="UNATCO Sublevel"
     MapStylePlaceNames(8)="Hong Kong"
     MapStylePlaceNames(9)="Versalife"
     MapStylePlaceNames(10)="Shipyard"
     MapStylePlaceNames(11)="Graveyard"
     MapStylePlaceNames(12)="Paris"
     MapStylePlaceNames(13)="Catacombs"
     MapStylePlaceNames(14)="Chateau"
     MapStylePlaceNames(15)="Cathedral"
     MapStylePlaceNames(16)="Everett"
     MapStylePlaceNames(17)="Vandenberg"
     MapStylePlaceNames(18)="Gas Station"
     MapStylePlaceNames(19)="Oceanlab"
     MapStylePlaceNames(20)="Missile Silo"
     MapStylePlaceNames(21)="Endgame"
     MapStylePlaceNames(22)="Outro"
     
     OwedMayhemFactor=-1
     MayhemFactor=-1
     MayhemGibbingValue=3
     MayhemLivingValue=1
     MayhemDarknessValue=1
     MayhemKilledValue=1
     MayhemKOValue=1
     OwedMayhemFloor=-50
     OwedMayhemCap=175
     MayhemCap=125
}