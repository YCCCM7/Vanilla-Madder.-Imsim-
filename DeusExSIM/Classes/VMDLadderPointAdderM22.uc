//=============================================================================
// VMDLadderPointAdderM22.
//=============================================================================
class VMDLadderPointAdderM22 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "22_TOKYO_AQUA":
			Spawn(class'PathNodeMobile',,, Vect(-3177,-46,-810));
			Spawn(class'PathNodeMobile',,, Vect(-3172,-313,-810));
			Spawn(class'PathNodeMobile',,, Vect(-3292,-55,-810));
			Spawn(class'PathNodeMobile',,, Vect(-3266,-318,-810));
			
			bRebuildRequired = true;
			
			//Ladder to lower storage area. A good place to hide?
			//Aaaaand hanging shop lights totally break the fucking ladder's spacing. Nevermind.
			/*
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-3206,-180,-759)+TSpacing, Vect(-3224,-182,-439)+TSpacing, Vect(-3184,-83,-486),, 4+8+256+512,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 51)));
			*/
		break;
		
		case "22_KUROKUMA_BASE1":
			//Ladder in and out of moat with karkian
			//UPDATE: Geometry too buggy it seems to let them climb out. Space is very tight, too.
			//TSpacing = Vect(8,0,0);
			//AddLadderGroup(Vect(-1, 0, 0), Vect(-1089,3610,-5989)+TSpacing, Vect(-1089,3610,-5859)+TSpacing, Vect(-1163,3610,-5859), Vect(-1049,3610,-6042), 1+2);
			
			//Ladder in and out sewers connected to moat.
			TSpacing = Vect(20,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-1328,5057,-6005)+TSpacing, Vect(-1328,5057,-5825)+TSpacing, Vect(-1371,5111,-5825),, 4+8+256+512);
		break;
		
		case "22_KUROKUMA_HIDEOUT":
			Spawn(class'PathNodeMobile',,, Vect(-5188,-4559,-8142));
			Spawn(class'PathNodeMobile',,, Vect(-5077,-4559,-8126));
			Spawn(class'PathNodeMobile',,, Vect(-4964,-4563,-8126));
			Spawn(class'PathNodeMobile',,, Vect(-4976,-4435,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-4980,-4104,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-4758,-4091,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-4592,-4100,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-4255,-4105,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3887,-4094,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3797,-3942,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3647,-3895,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3658,-3729,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3669,-3522,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3668,-3257,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3666,-3082,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3797,-4241,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3660,-4323,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3662,-4551,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3659,-4829,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3662,-5114,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3528,-3963,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3512,-4234,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3273,-4091,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3018,-4089,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-2797,-4089,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-2578,-4081,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-2332,-4098,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-2108,-4104,-7226));
			Spawn(class'PathNodeMobile',,, Vect(-1743,-4110,-7358));
			Spawn(class'PathNodeMobile',,, Vect(-1450,-4097,-7357));
			Spawn(class'PathNodeMobile',,, Vect(-1116,-4080,-7358));
			Spawn(class'PathNodeMobile',,, Vect(-1116,-4410,-7358));
			Spawn(class'PathNodeMobile',,, Vect(-1107,-3793,-7358));
			Spawn(class'PathNodeMobile',,, Vect(-1106,-3481,-7358));
			Spawn(class'PathNodeMobile',,, Vect(-1113,-3163,-7357));
			Spawn(class'PathNodeMobile',,, Vect(-2171,-4097,-7194));
			Spawn(class'PathNodeMobile',,, Vect(-2237,-4094,-7162));
			Spawn(class'PathNodeMobile',,, Vect(-3480,-4028,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3576,-3913,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3857,-4187,-7137));
			Spawn(class'PathNodeMobile',,, Vect(-3460,-4161,-7137));
			
			bRebuildRequired = true;
			
			//Ladder in and out from underbelly with the spiderbots.
			//UPDATE: This ladder fucking sucks and only reliably works one way. For that reason, it's being axed. Some sort of BSP error stopping proper ladder spawns.
			//Makes sense, given the map region it's in.
			//TSpacing = Vect(8,0,0);
			//AddLadderGroup(Vect(-1, 0, 0), Vect(-4945,-4563,-8086)+TSpacing, Vect(-4945,-4563,-7131)+TSpacing+Vect(-4,0,0), Vect(-4972,-4477,-7162),, 4+8);
		break;
		
		case "22_LOSTCITY":
			Spawn(class'PathNodeMobile',,, Vect(-155,-71,151));
			Spawn(class'PathNodeMobile',,, Vect(-157,-339,151));
			Spawn(class'PathNodeMobile',,, Vect(-311,-439,143));
			Spawn(class'PathNodeMobile',,, Vect(-233,-636,143));
			Spawn(class'PathNodeMobile',,, Vect(-197,-768,143));
			Spawn(class'PathNodeMobile',,, Vect(-414,-923,143));
			Spawn(class'PathNodeMobile',,, Vect(-652,-837,143));
			Spawn(class'PathNodeMobile',,, Vect(-671,-563,143));
			
			bRebuildRequired = true;
			
			//Ladder to and from upper roof area.
			//Note: They suck at using this one, but it IS possible in both directions. Geometry complicates it being done any other way.
			//There's another one near the VIP, but he's a dumbass and his guards can't use the ladder (MIB), so it would ruin the mission.
			AddLadderGroup(Vect(0.8, 0.2, 0), Vect(-349,-573,-56)+TSpacing, Vect(-349,-573,143)+TSpacing, Vect(-274,-546,143),, 4+8);
		break;
		
		case "22_OTEMACHIRETURN":
			Spawn(class'PathNodeMobile',,, Vect(3813,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4093,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4446,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4547,-2352,15));
			Spawn(class'PathNodeMobile',,, Vect(4554,-2749,15));
			Spawn(class'PathNodeMobile',,, Vect(4549,-3001,15));
			Spawn(class'PathNodeMobile',,, Vect(4186,-3011,15));
			Spawn(class'PathNodeMobile',,, Vect(3747,-3009,15));
			Spawn(class'PathNodeMobile',,, Vect(3332,-3008,15));
			Spawn(class'PathNodeMobile',,, Vect(2982,-3010,15));
			Spawn(class'PathNodeMobile',,, Vect(2727,-3004,15));
			Spawn(class'PathNodeMobile',,, Vect(2340,-2998,15));
			Spawn(class'PathNodeMobile',,, Vect(2331,-2870,15));
			Spawn(class'PathNodeMobile',,, Vect(2726,-2884,15));
			Spawn(class'PathNodeMobile',,, Vect(2148,-3004,15));
			Spawn(class'PathNodeMobile',,, Vect(2156,-2903,15));
			Spawn(class'PathNodeMobile',,, Vect(1881,-3018,15));
			Spawn(class'PathNodeMobile',,, Vect(1866,-2900,15));
			
			bRebuildRequired = true;
			
			//Ladder to upper rooftop with loot.
			TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(4594,-2241,-425)+TSpacing, Vect(4594,-2241,39)+TSpacing, Vect(4548,-2383,15),, 4+8+256+512);
		break;
		
		case "22_TMG_MILITARY_2":
			Spawn(class'PathNodeMobile',,, Vect(4274,-2820,-641));
			Spawn(class'PathNodeMobile',,, Vect(4033,-2813,-641));
			Spawn(class'PathNodeMobile',,, Vect(3792,-2643,-641));
			Spawn(class'PathNodeMobile',,, Vect(3800,-2962,-641));
			Spawn(class'PathNodeMobile',,, Vect(3616,-2805,-641));
			Spawn(class'PathNodeMobile',,, Vect(3406,-2795,-641));
			Spawn(class'PathNodeMobile',,, Vect(3246,-2958,-641));
			Spawn(class'PathNodeMobile',,, Vect(3289,-2656,-641));
			
			bRebuildRequired = true;

			//Ladder to armory from upper helipad region.
			TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(4386,-2816,-624)+TSpacing, Vect(4386,-2816,-239)+TSpacing, Vect(4296,-2814,-257),, 4+8);
			
			//Arg. Both of these ladders don't work due to helicopter cockblocking us.
			//Ladder to helipad 1
			/*TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(2907,-2877,-338)+TSpacing, Vect(2907,-2877,-97)+TSpacing, Vect(2968,-2879,-97),, 4+8);
			
			//Ladder to helipad 2
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(3461,-2879,-338)+TSpacing, Vect(3461,-2879,-97)+TSpacing, Vect(3403,-2878,-97),, 4+8);*/
		break;
	}
}

defaultproperties
{
}
