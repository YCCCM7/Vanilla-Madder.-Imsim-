//=============================================================================
// VMDLadderPointAdderM72.
//=============================================================================
class VMDLadderPointAdderM72 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
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
			
			bRebuildRequired = true;
			
			//#1-2: Escalating series of ladders to the apartment. Third one has geometry that breaks ladder usage. Sigh.
			TSpacing = Vect(8,-8,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(265,-255,-3805), Vect(224,-255,-3748)+TSpacing, Vect(224,-255,-3151)+TSpacing, Vect(238,-210,-3201),, 1+2+4+8);
			
			TSpacing = Vect(8,8,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(224,43,-3149)+TSpacing, Vect(224,43,-2878)+TSpacing, Vect(240,-20,-2927),, 4+8);
			
			//TSpacing = Vect(8,-8,0);
			//AddLadderGroup(Vect(-1, 0, 0), Vect(224,-259,-2879)+TSpacing, Vect(154,-259,-2513)+TSpacing, Vect(224,-259,-2530),, 4+8);
		break;
	}
}

defaultproperties
{
}
