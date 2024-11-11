//=============================================================================
// Speech Bubble. We give sweet tips during training.
//=============================================================================
class VMDSpeechBubble extends VMDInformationDevices;

var bool bBobDown;
var float SpinRate, BobRate, BobHeight, CurBobHeight;

var localized string TipsHeaders[32], Tips[32];
var() int TipIndex; //MADDERS: So we can both localize and diversify from one class.

//MADDERS: Put some dressing on our shameless nature by which we spawn inside
//the player's view on a couple of occasions.
function SpawnExplosionEffect()
{
	local ExplosionLight light;
	local int i;
	local Rotator rot;
	local SphereEffect sphere;
   	local ExplosionSmall expeffect;
	
	PlaySound(Sound'EMPGrenadeExplode');
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
	{
         	light.RemoteRole = ROLE_None;
		light.size = 8;
		light.LightHue = 128;
		light.LightSaturation = 96;
		light.LightEffect = LE_Shell;
	}

	expeffect = Spawn(class'ExplosionSmall',,, Location);
   	if (expeffect != None)
      		expeffect.RemoteRole = ROLE_None;
	
	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
   	{
         	sphere.RemoteRole = ROLE_None;
		sphere.size = 256 / 32.0;
   	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	UpdateWrittenData();
}

function UpdateWrittenData()
{
	TipIndex = Clamp(TipIndex, 0, ArrayCount(Tips)-1);
	
	TextHeader = TipsHeaders[TipIndex];
	Text = Tips[TipIndex];
}

function Tick(float DT)
{
	local Rotator R;
	local Vector V;
	local float UseRate;
	
	R.Yaw = SpinRate*DT;
	SetRotation(Rotation + R);
	
	if (AReader != None)
	{
		ScaleGlow = Default.ScaleGlow * 0.125;
	}
	else
	{
		ScaleGlow = Default.ScaleGlow;
	}
	
	UseRate = BobHeight*DT;
	if (BobHeight - CurBobHeight < BobHeight / 6 || CurBobHeight < BobHeight / 6) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 12 || CurBobHeight < BobHeight / 12) UseRate /= 2;
	if (BobHeight - CurBobHeight < BobHeight / 24 || CurBobHeight < BobHeight / 24) UseRate /= 2;
	
	if (!bBobDown)
	{
		if (CurBobHeight < BobHeight)
		{
			CurBobHeight += UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight > BobHeight)
			{
				V.Z -= (CurBobHeight - BobHeight);
				CurBobHeight = BobHeight;
				bBobDown = true;
			}
			SetLocation(Location + V);
 		}
 	}
	else
	{
		if (CurBobHeight > 0)
		{
			CurBobHeight -= UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight < 0)
			{
				V.Z -= (CurBobHeight);
				CurBobHeight = 0;
				bBobDown = false;
			}
			SetLocation(Location - V);
		}
	}
	
	Super.Tick(DT);
}

defaultproperties
{
     TipsHeaders(0)="EXISTING AND YOU:"
     Tips(0)="In VMD, you will (by default) consume hunger over time. This is disabled in training, but observe the 'HU' meter on your HUD, near energy. Without food, you will slowly perish. Some foods replenish more than others, and some have potential side effects."
     TipsHeaders(1)="WOW A 2ND BUBBLE:"
     Tips(1)="Whoops. I almost forgot to mention, but you can configure many of the features mentioned in your little reality breaks you're having. Find them in the Main Menu > Settings > VMD Options window. Cheers."
     TipsHeaders(2)="MELEE WEAPONS: YOUR NEW FRIEND"
     Tips(2)="Melee weapons can be used underwater, without exception. The knife can be used to eat dead animals should you run low on food, and works well underwater. Touching or whacking mobile pieces of terrain will give more intel on them."
     TipsHeaders(3)="LOCKS AND PICKING:"
     Tips(3)="Notice how you have to 'scout' this door during your first encounter. Multitool and lockpick usage can both be rushed by double-clicking the object when bypassing. However, this will generate noise if the item is not bypassed by the tool's destruction."
     TipsHeaders(4)="KEYPADS THO:"
     Tips(4)="Multitools work the same way as lockpicks. However, (by default) using a tool on a keypad will reveal characters you can recombine to crack a combination. If you get tired of this, just double click with a tool to hack it."
     TipsHeaders(5)="THIS GUY:"
     Tips(5)="What a buzzkill, right friend-of-mine?"
     TipsHeaders(6)="THIS OTHER GUY:"
     Tips(6)="Totally KO'd. Carrying bodies can act as a slight piece of cover when under fire... But KO'd people will die from being bullet sponges. Carrying dead bodies (by default) generates a blood smell your enemies can detect. Murder is bad, you know."
     TipsHeaders(7)="BOO!"
     Tips(7)="Objects hidden in the dark will not unveil their selection box, unless otherwise poked or bumped into. The dark is not your friend, friend."
     TipsHeaders(8)="ROBOTS: YOUR OTHER FRIEND"
     Tips(8)="Repair and medical bots have limited charges with which to distribute resupplying. However, this is not the case in hub areas or otherwise peaceful zones, so don't be too afraid to use them."
     TipsHeaders(9)="NEW AMMOS:"
     Tips(9)="Some sources of ammunition will be swapped out when visiting otherwise normal maps. These gas cap rounds are such an example of a new, hidden ammo type."
     TipsHeaders(10)="BOXES: LOVE 'EM OR HATE EM."
     Tips(10)="I know stacking boxes is sometimes tiring, friend. When configuring skill talents on a character, you can find 'fit as a fiddle' in the fitness tree to acquire a mean jump duck. If you really hate stacking boxes, it's not a bad investment."
     TipsHeaders(11)="FOOD: BE ON THE LOOKOUT"
     Tips(11)="You might be getting just a hair hungry by now. Check the righthand meter labeled 'HU'. A quick bite of a candybar can cover about a quarter of your hunger bar."
     TipsHeaders(12)="OOF:"
     Tips(12)="Taking damage (by default) is one of the factors that feed into stress. The 'AX' bar represents anxiety levels. Charged pickups that reduce damage now only corrode very little when not taking damage. Taking damage underwater makes you lose air. Chin up!"
     TipsHeaders(13)="GAS CAPS THO:"
     Tips(13)="I mentioned these earlier. Dunno if you were paying attention. In VMD, bullets ricochet at shallow angles but penetrate at steep angles. Gas caps disperse gas, as just one example, when ricocheting about. Try it out by switching ammos! (Apostrophe key, by default)"
     TipsHeaders(14)="GUN BASICS:"
     Tips(14)="Aim focus rates are more generous at higher skill levels, adding quality of life to using guns. Aim bloom, however, removes aim focus when firing. In VMD, strengths are buffed, but weaknesses are amplified all the same."
     TipsHeaders(15)="GUN PARTICULARS:"
     Tips(15)="Ducking gives an additive bonus to your current accuracy. Accuracy caps off at a certain point, however. Guns will also dirty after being fired extensively. Press your reload key after a jam or when your mag is full to begin cleaning. Click to interrupt."
     TipsHeaders(16)="HVAP THO:"
     Tips(16)="HVAP is another new ammo type you can find. For contrast, these rounds specialize in bullet penetration and anti-armor effect, but negate silencers, to put it mildly. Try shooting a deployed target through the concrete divider, if you want."
     TipsHeaders(17)="LAND MINES THO:"
     Tips(17)="Remember that thing about strengths and weaknesses? Sorry, friend. While throwing grenades is free, placing grenades as mines requires a talent. This time it's free, but check your skills screen later. We're in this (and your head, LOL) together!"
     TipsHeaders(18)="SO ABOUT DEFUSING..."
     Tips(18)="Defusing grenades is punished more at lower skill levels. You don't have any skills, so just try to get out of this one in one piece, friendo!"
     TipsHeaders(19)="TECH GOGGLES: THEY DON'T SUCK ANYMORE"
     Tips(19)="While often blinding to the eyes, tech goggles have been overhauled in VMD. Now they act as short range infrared sensors. Use them during stealth to find enemy positions from safe cover."
     TipsHeaders(20)="SMELLS AND YOU:"
     Tips(20)="Blood and food can both generate smells if exposed to in excess. A talent from lockpicking (infiltration) can push this threshold back, but washing off (or not killing) and bringing the right configuration of food can eliminate the problem entirely."
     TipsHeaders(21)="EXPECTING SOMETHING?"
     Tips(21)="Locate the nearby multitool, and try codebreaking out for real this time. Or just double-click it if you get impatient."
     TipsHeaders(22)="EASY PICKINGS? NAH."
     Tips(22)="A knife should be nearby. This brick is no longer revealed by default, but you can try poking it, or stabbing it to reveal its position. Same with the wall it opens."
     TipsHeaders(23)="UNKNOWN!?!"
     Tips(23)="'Barrier', 'Unknown', 'Locked'... There are many labels you may find doors reveal themselves as. Don't bother poking anything that isn't locked or unlocked when revealed. That means they can't be opened by hand. Look for other means nearby."
     TipsHeaders(24)="ADVANCED BYPASSING"
     Tips(24)="All bypassing is slightly random, but is randomized on new game start. Using an entire tool generates noise, but steering off of your target will negate this effect, at the cost of less potency, and a small cooldown. Speed or stealth? You can't have both."
     SpinRate=24576
     BobRate=18.000000
     BobHeight=6.000000
     DrawScale=1.000000
     Physics=PHYS_None
     bAddToDataVault=True
     bInvincible=True
     bCanBeBase=False
     ItemName="Hallucination[?]"
     Mesh=LodMesh'VMDSpeechBubble'
     CollisionRadius=12.000000
     CollisionHeight=10.000000
     Mass=2.000000
     Buoyancy=3.000000
     ScaleGlow=1.500000
     bUnlit=True
}
