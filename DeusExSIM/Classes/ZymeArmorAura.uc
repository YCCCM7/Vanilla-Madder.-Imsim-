//=============================================================================
// ZymeArmorAura.
//=============================================================================
class ZymeArmorAura extends VMDFakeBuffAura;

#exec OBJ LOAD FILE=Ambient

var int PassiveLaps;

var sound HalliSounds[24];

//--------------------
//MADDERS, 1/30/21: We reduce damage as a very hacky "aura" of sorts.
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	local float Ret;
	
	//Emergency mega failsafe.
	if (Charge <= 0)
	{
		Destroy();
		return 1.0;
	}
	
	Ret = 1.0;
	switch(DT)
	{
		//Eliminate these entirely.
		case 'HalonGas':
		case 'TearGas':
		case 'Stunned':
		case 'Hunger':
			Ret = 0.0;
		break;
		
		//Simply reduce these.
		case 'Shot':
		case 'AutoShot':
		case 'Sabot':
		case 'KnockedOut':
		case 'Burned':
		case 'Radiation':
		 	Ret = 0.35;
		break;
		//We are chemically unstable. Poison wrecks us.
		case 'Poison':
		case 'PoisonEffect':
		case 'PoisonGas':
		case 'DrugDamage':
			Ret = 2.0;
		break;
		//Everything else? Nah brah.
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole)
{
	local int TLap;
	local CombatStimAura CSA;
	
	if ((bWhole) && (Charge > 400) && (MyVMP != None))
	{
		CSA = CombatStimAura(MyVMP.FindInventoryType(class'CombatStimAura'));
		
		if (CSA == None || CSA.Charge < 320)
		{
			MyVMP.DrugEffectTimer = float(Charge) / 40.0;
			MyVMP.bZymeAffected = True;
		}
		
		PassiveLaps = ((PassiveLaps+1) % 29);
		TLap = ((PassiveLaps + class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 7)) % 29);
		switch(TLap)
		{
			case 1:
			case 6:
			case 9:
			case 11:
			case 14:
			case 18:
			case 21:
			case 26:
			case 29:
				PlayRandomHalliSound();
			break;
			default:
			break;
		}
	}
}

//MADDERS, 1/31/21: Obvious throwback to shifter, who did something to this effect.
function PlayRandomHalliSound()
{
	Owner.PlaySound(HalliSounds[Rand(ArrayCount(HalliSounds))], SLOT_Misc,,,,0.85+(Frand() * 0.3));
}

defaultproperties
{
     HalliSounds(0)=sound'CatHiss'
     HalliSounds(1)=sound'DogLargeBark3'
     HalliSounds(2)=sound'GrayIdle'
     HalliSounds(3)=sound'GrayIdle2'
     HalliSounds(4)=sound'GreaselIdle'
     HalliSounds(5)=sound'KarkianIdle2'
     HalliSounds(6)=sound'RatSqueak1'
     HalliSounds(7)=sound'Beep4'
     HalliSounds(8)=sound'DropSmallWeapon'
     HalliSounds(9)=sound'GlassBreakLarge'
     HalliSounds(10)=sound'GlassBreakSmall'
     HalliSounds(11)=sound'MediumExplosion2'
     HalliSounds(12)=sound'Ricochet2'
     HalliSounds(13)=sound'SplashMedium'
     HalliSounds(14)=sound'VendingCan'
     HalliSounds(15)=sound'WoodBreakLarge'
     HalliSounds(16)=sound'AssaultGunFire'
     HalliSounds(17)=sound'PistolFire'
     HalliSounds(18)=sound'SwordFire'
     HalliSounds(19)=sound'CarpetStep3'
     HalliSounds(20)=sound'WoodStep3'
     HalliSounds(21)=sound'StoneStep3'
     HalliSounds(22)=sound'MaleDeath'
     HalliSounds(23)=sound'FemalePainLarge'
     
     Charge=2400
     PickupMessage="Your senses numb, as you lose connection to the idea of 'pain'..."
     ExpireMessage="You regain familiarity with your senses... What a trip..."
     
     //MADDERS, 1/30/21: Patch this in for audio feedback sake.
     LoopSound=TreesRustling
     ChargedIcon=Texture'ChargedIconVialCrack'
}
