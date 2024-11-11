//=============================================================================
// VMDLadderPointAdder.
// We're just here to cram some ladder points into levels.
// Not all ladders are covered, as not all are good candidates.
//=============================================================================
class VMDLadderPointAdder extends VMDFillerActors;

var float FixTimer;
var bool bRanFixes;

//MADDERS: Using this for not updating our map fixes if we're in revision maps.
//Yeah, I thought of it. Not sure if it'll ever be relevant, though.
var travel bool bRevisionMapSet;

//MADDERS, 11/10/24: Dynamic path rebuilding. Thanks, Aizome.
var bool bRebuilding;
var int RebuildProgress;
var Pawn TScout;
var VMDPathRebuilder VMDPR;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	AddLadderPoints();
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (bRebuilding)
	{
		if (RebuildProgress < 1)
		{
			RebuildProgress += 1;
		}
		else
		{
			FinishRebuild();
		}
	}
}

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	local bool bRebuildRequired;
	local int GM, i;
	local string MN;
	local Vector TSpacing;
	
	local Actor A;
 	local DeusExLevelInfo LI;
	local VMDBufferPawn VMBP;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	
 	forEach AllActors(Class'DeusExLevelInfo', LI) break;
	if (LI == None)
	{
		return;
	}
	
	GM = LI.MissionNumber;
	if (GM > 98)
	{
		Lifespan = 1;
		return;
	}
	MN = CAPS(LI.MapName);
	
	switch(GM)
	{
		case 1:
			switch(MN)
			{
				case "01_NYC_UNATCOISLAND":
					if (!bRevisionMapSet)
					{
						//#01: SATCOM Ladder. Beats the player hiding inside indefinitely?
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(-1, -1, 0), Vect(-6384,1469,-240)+TSpacing, Vect(-6384,1469,-80)+TSpacing, Vect(-6280,1469,-92),, 4+8);
						
						//#02: Rear of statue up to its first ladder point.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1,0,0), Vect(6120, -2504, -61)+TSpacing, Vect(6120,-2504,72)+TSpacing, Vect(6038,-2505,64),, 4+8);
					}
				break;
			}
		break;
		case 2:
			switch(MN)
			{
				case "02_NYC_WAREHOUSE":
					if (!bRevisionMapSet)
					{
						//#01: Ladder from elevator start up to the double 3006 and ballistic guy.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-573,2945,1584)+TSpacing, Vect(-573,2945,1824)+TSpacing, Vect(-573,2852,1776),, 4+8);
						
						//#02: Ladder from double 3006 and ballistic guy to the roof above him.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-1346,2211,1768)+TSpacing, Vect(-1376,2211,1822)+TSpacing, Vect(-1376,2211,2057)+TSpacing, Vect(-1462,2211,2008), 1+4+8);
						
						//#03: Ladder from #2's rooftop, going down to abandoned building with glass window.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1724,1777,1795)+(TSpacing*0.2), Vect(-1724,1777,2064)+TSpacing, Vect(-1724,1876,2012),, 4+8);
						
						//MADDERS, 8/10/24: These are too fringe to be useful, and the long space of #4 makes going down the ladder clumsy.
						//Offsetting it to de-clumsy it ruins the ability to climb up. The annotated values are the best middleground, but it still sucks and is niche.
						//#04: Ladder from #2's rooftop, going down to the alleyway with the LAM.
						/*TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-2077,2239,355)+(TSpacing*0.0), Vect(-2077,2239,2064)+(TSpacing*0.3), Vect(-2002,2237,2008),, 4+8);
						
						//#05: Ladder from alleyway up to catwalk of #4.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-2178,2082,48)+TSpacing, Vect(-2178,2094,53)+TSpacing, Vect(-2178,2094,352)+TSpacing, Vect(-2178,2160,352), 1+2+4+8);
						*/
						
						//#06: Ladder from area near the jumpable window up to the sniper outlook. This one's the prettier one.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1627,680,1187)+TSpacing, Vect(-1627,680,1504)+TSpacing, Vect(-1627,766,1456),, 4+8);
						
						//#07: Ladder from area near the jumpable window up to the sniper outlook. This one's the ugly one with the billboard.
						TSpacing = Vect(0,16,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-1245,1127,1184)+TSpacing, Vect(-1245,1092,1201)+TSpacing, Vect(-1245,1040,1480), Vect(-1336,1040,1456), 1+2+4+8);
						
						//#08: Ladder from #6 up to this weird little square that's just vibin'.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1835,1120,1459)+TSpacing, Vect(-1835,1120,1664)+TSpacing, Vect(-1835,1192,1616),, 4+8);
						
						//#09: Ladder from isolated dude down to chimneys.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-7,529,784)+TSpacing, Vect(-28,529,831)+TSpacing, Vect(-28,529,1176)+TSpacing, Vect(-109,529,1104), 1+2+4+8,,, 1.3);
						
						//#10: Ladder from chimneys to the collapsed catwalk adjacent area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(349,532,624)+TSpacing, Vect(279,532,693)+TSpacing, Vect(279,532,856)+TSpacing, Vect(159,532,784), 1+2+4+8,,, 1.3);
						
						//#11: Ladder from catwalk adjacent area to the little squat at bottom.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(632,532,464)+TSpacing, Vect(615,532,498)+TSpacing, Vect(615,532,688)+TSpacing, Vect(532,532,624), 1+2+4+8,,, 1.3);
						
						//#12: Ladder from concrete top of garage to the dishes.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(752,-97,480)+TSpacing, Vect(752,-136,491)+TSpacing, Vect(752,-135,1096)+TSpacing, Vect(752,-254,1024), 1+2+4+8);
						
						//#13: Ladder from dishes to top of computer room.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(1285,-648,752)+TSpacing, Vect(1240,-648,770)+TSpacing, Vect(1240,-648,1096)+TSpacing, Vect(1113,-648,1024), 1+2+4+8);
						
						//#14: Ladder from concrete top of garage to the dishes.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(1452,-1229,256)+TSpacing, Vect(1452,-1177,280)+TSpacing, Vect(1452,-1177,760)+TSpacing, Vect(1454,-1114,752), 1+2+4+8);
						
						
						
						//TSpacing = Vect(0,0,0);
						//AddLadderGroup(Vect(0, 0, 0), Vect(0,0,0)+TSpacing, Vect(0,0,0)+TSpacing, Vect(0,0,0),, 4+8);
					}
				break;
				case "02_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up to main room from the laser area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(627,-342,-557)+TSpacing, Vect(627,-342,-328)+TSpacing, Vect(627,-204,-336),, 4+8);
						
						//#2: ONE WAY ladder from water up to the side with lasers.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(550,19,-1296)+TSpacing, Vect(550,19,-328)+TSpacing, Vect(642,19,-336),, 4+8+64);
						
						//#3: ONE WAY ladder from water up to the side with schick.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-678,-261,-1296)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-668,-190,-784),, 4+8+64);
						
						//#4: Ladder up to top from schick area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-668,-190,-784)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-678,-261,-328),Vect(-749,-260,-336), 1+2+4+8);
					}
				break;
			}
		break;
		case 3:
			switch(MN)
			{
				case "03_NYC_AIRFIELDHELIBASE":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up from glass roof to sniper catwalk.
						TSpacing = Vect(0,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-1380,1223,416)+TSpacing, Vect(-1380,1223,822)+TSpacing, Vect(-1394,1141,808),, 4+8);
						
						//Keep sniper guy up here, thanks.
						VMBP = VMDBufferPawn(FindActorBySeed(class'Terrorist', 37));
						if (VMBP != None)
						{
							VMBP.bCanClimbLadders = false;
						}
						
						//#2: Ladder from sewer grate up to the previously very cursed catwalk.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1344,-463,48)+TSpacing, Vect(-1344,-463,216)+TSpacing, Vect(-1344,-363,200),, 4+8);
						
						//#3: Ladder from the cursed area up to the glass skylight area.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1344,-27,213)+TSpacing, Vect(-1344,-27,456)+TSpacing, Vect(-1344,72,416),, 4+8);
						
						//#4: Ladder from skylight area up to the previously unused catwalk. Cool.
						TSpacing = Vect(0,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(1380,1224,419)+TSpacing, Vect(1380,1224,810)+TSpacing, Vect(1381,1146,808),, 4+8);
						
					}
				break;
				case "03_NYC_AIRFIELD":
					if (!bRevisionMapSet)
					{
						//#1: First isolated crate, closer to water, from ground to mid.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-792,-293,51)+TSpacing, Vect(-792,-293,217)+TSpacing, Vect(-792,-403,209),, 4+8);
						
						//#2: First isolated crate, from mid to high.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-847,-560,212)+TSpacing, Vect(-847,-560,377)+TSpacing, Vect(-936,-560,369),, 4+8);
						
						//#3: Second isolated crate, further from water, from ground to mid.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-475,-144,51)+TSpacing, Vect(-475,-144,217)+TSpacing, Vect(-371,-144,209),, 4+8);
						
						//#4: Second isolated crate, from mid to high.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-314,-304,212)+TSpacing, Vect(-314,-304,377)+TSpacing, Vect(-236,-304,369),, 4+8);
						
						//#5: The most interesting double ladder crate, this one goes somewhere. Low to mid.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-720,3387,51)+TSpacing, Vect(-720,3387,216)+TSpacing, Vect(-720,3279,208),, 4+8);
						
						//#6: Same double crate, mid to high.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-945,3227,211)+TSpacing, Vect(-945,3227,376)+TSpacing, Vect(-945,3129,368),, 4+8);
						
						//MADDERS, 8/10/24: Yeah, these jumps need more horizontal power, not vertical power. For this reason, this won't work.
						//Maybe in the future with upgraded ladder framework? Maybe.
						//#7: Jump #1 towards cool place.
						/*AddLadderGroup(Vect(0, 0, 0), Vect(-711,3077,368), Vect(-479,2961,372),,, 1+2+4+8,, 1.4, 1.4);
						
						//#8: Jump #2 towards cool place.
						AddLadderGroup(Vect(0, 0, 0), Vect(-274,2749,372), Vect(-258,2521,368),,, 1+2+4+8,, 1.4, 1.4);
						
						//#9: Jump #3... Don't expect a #4.
						AddLadderGroup(Vect(0, 0, 0), Vect(-54,2534,368), Vect(160,2586,368),,, 1+2+4+8,, 1.4, 1.4);
						*/
					}
				break;
			}
		break;
		case 4:
			switch(MN)
			{
				case "04_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up to main room from the laser area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(627,-342,-557)+TSpacing, Vect(627,-342,-328)+TSpacing, Vect(627,-204,-336),, 4+8);
						
						//#2: ONE WAY ladder from water up to the side with lasers.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(550,19,-1296)+TSpacing, Vect(550,19,-328)+TSpacing, Vect(642,19,-336),, 4+8+64);
						
						//#3: ONE WAY ladder from water up to the side with schick.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-678,-261,-1296)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-668,-190,-784),, 4+8+64);
						
						//#4: Ladder up to top from schick area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-668,-190,-784)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-678,-261,-328),Vect(-749,-260,-336), 1+2+4+8);
					}
				break;
			}
		break;
		case 6:
			switch(MN)
			{
				case "06_HONGKONG_HELIBASE":
					if (!bRevisionMapSet)
					{
						//#1: Ladder from ground to roof.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(590,-832,440)+TSpacing, Vect(590,-832,840)+TSpacing, Vect(676,-832,816),, 4+8);
					}
				break;
				case "06_HONGKONG_WANCHAI_MARKET":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up/down from police watch area
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-721,-624,48)+TSpacing, Vect(-721,-624,183)+TSpacing, Vect(-721,-684,176),, 4+8);
						
						//#2: Ladder up/down from police armory
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-200,-719,-109)+TSpacing, Vect(-200,-719,56)+TSpacing, Vect(-207,-640,48),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 8)));
					}
				break;
				case "06_HONGKONG_WANCHAI_CANAL":
					if (!bRevisionMapSet)
					{
						//#1: Water to china hand freezer, recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(-703,1705,-528), Vect(-703,1803,-432),,, 1+2+4+8+64,, 1.5);
						
						//#2: Water to china hand side door, recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(-2212,2672,-531), Vect(-2149,2673,-432),,, 1+2+4+8+64,, 2.0);
						
						//#3: Water to path near boat guy, but no to him. Recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(-1939,1184,-532), Vect(-1867,1186,-409),,, 1+2+4+8+64,, 1.5);
						
						//#4: Water to stairway near dead worker location. Recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(-2126,-618,-537), Vect(-2197,-618,-464),,, 1+2+4+8+64,, 1.5);
						
						//#5: Water to last area nearest boat guy's place. Recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(445,1264,-530), Vect(445,1194,-448),,, 1+2+4+8+64,, 1.75);
						
						//#6: Water to boat guy's place, finally. Recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(1633,1299,-533), Vect(1633,1369,-448),,, 1+2+4+8+64,, 1.75);
						
						//#7: Water to giant ship area. Recovery area.
						AddLadderGroup(Vect(0, 0, 0), Vect(2655,1749,-526), Vect(2655,1827,-448),,, 1+2+4+8+64,, 2.0);
						
						//#8: Ladder from lower area without door to main walk area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-224,904,-333)+TSpacing, Vect(-224,904,52)+TSpacing, Vect(-299,913,48),, 4+8);
					}
				break;
				//MADDERS, 8/11/24: Some fucky shit stops ms chow from using the ladder. Fuck it. Don't bother.
				case "06_HONGKONG_STORAGE":
					/*if (!bRevisionMapSet)
					{
						//#1: Ladder up/down from police watch area
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(958,-10,-992)+TSpacing, Vect(958,-24,-77)+TSpacing, Vect(864,-3,-80),, 4+8);
					}*/
				break;
			}
		break;
		case 8:
			switch(MN)
			{
				case "08_NYC_UNDERGROUND":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up to main room from the laser area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(627,-342,-557)+TSpacing, Vect(627,-342,-328)+TSpacing, Vect(627,-204,-336),, 4+8);
						
						//#2: ONE WAY ladder from water up to the side with lasers.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(550,19,-1296)+TSpacing, Vect(550,19,-328)+TSpacing, Vect(642,19,-336),, 4+8+64);
						
						//#3: ONE WAY ladder from water up to the side with schick.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-678,-261,-1296)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-668,-190,-784),, 4+8+64);
						
						//#4: Ladder up to top from schick area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-668,-190,-784)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-678,-261,-328),Vect(-749,-260,-336), 1+2+4+8);
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
						//#1: Ladder to LAW area near robot cages.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(3898,3190,96)+TSpacing, Vect(3898,3190,336)+TSpacing, Vect(3964,3191,296),, 4+8);
					}
				break;
				case "09_NYC_SHIP":
					if (!bRevisionMapSet)
					{
						//#1: Rightmost ladder from water back up to docks. Recovery area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(3565,-909,-709)+TSpacing, Vect(3565,-953,-653)+TSpacing, Vect(3565,-953,-424), Vect(3565,-1039,-444), 4+8+64);
						
						//#2: Middle ladder from water back up to docks. Recovery area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(2686,-909,-709)+TSpacing, Vect(2686,-953,-653)+TSpacing, Vect(2686,-953,-424), Vect(2686,-1039,-444), 4+8+64);
						
						//#3: Leftmost ladder from water back up to docks. Recovery area.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-874,-909,-709)+TSpacing, Vect(-874,-953,-653)+TSpacing, Vect(-874,-953,-424), Vect(-874,-1039,-444), 4+8+64);
					}
				break;
				case "09_NYC_SHIPBELOW":
					if (!bRevisionMapSet)
					{
						//#1: Ladder towards the security room, requiring catwalk.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-233,301,-333)+TSpacing, Vect(-233,301,-181)+TSpacing, Vect(-308,301,-185),, 4+8);
						
						//#2: Ladder up to the security room at last.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-491,-604,-181)+TSpacing, Vect(-491,-604,0)+TSpacing, Vect(-491,-537,-16),, 4+8);
						
						//#3: Ladder up to the shocky cat walky thing.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-3034,1213,-432)+TSpacing, Vect(-2961,1241,-397)+TSpacing, Vect(-2961,1241,-200), Vect(-2961,1312,-209), 1+2+4+8);
						
						//#4: Ladder up to control room near copter.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-5088,1502,-464)+TSpacing, Vect(-5088,1502,-208)+TSpacing, Vect(-5088,1422,-208),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 38)));
					}
				break;
				case "09_NYC_GRAVEYARD":
					if (!bRevisionMapSet)
					{
						//#1: Ladder to/from dowd's below tunnel.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-124,-415,-173)+TSpacing, Vect(-111,-412,-61)+TSpacing, Vect(-57,-415,54)+TSpacing, Vect(-54,-499,48),, 4+8);
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
						//#1: Ladder from greasel area to the street. First is most likely to be relevant.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(0,-63,-445)+TSpacing, Vect(0,-63,-216)+TSpacing, Vect(-22,32,-224),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 3)));
						
						//#2: Ladder from greasel room up to repair bot and radiation.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-33,3895,-461)+TSpacing, Vect(-33,3895,-8)+TSpacing, Vect(-113,3870,-16),, 4+8);
					}
				break;
				case "10_PARIS_CATACOMBS_TUNNELS":
					if (!bRevisionMapSet)
					{
						//#1: Ladder to electricity and repair bot.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1201,-856,-381)+TSpacing, Vect(-1201,856,124)+TSpacing, Vect(-1121,856,112),, 4+8);
						
						//#2: Ladder from hela's area to upper section. Misc.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(829,-2495,-285)+TSpacing, Vect(829,-2495,-24)+TSpacing, Vect(893,-2495,-32),, 4+8);
					}
				break;
			}
		case 11:
			switch(MN)
			{
				case "11_PARIS_CATHEDRAL":
					if (!bRevisionMapSet)
					{
						//#1: This one ladder is the focus. No sane person would chase after someone on a trelis.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(3773,-872,-301)+TSpacing, Vect(3773,-872,-8)+TSpacing, Vect(3692,-872,-16),, 4+8);
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
						//#1: Comsat building back room up to its roof. Mercenary related?
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-1669,4570,-2112)+TSpacing, Vect(-1669,4570,-1895)+TSpacing, Vect(-1745,4570,-1903),, 4+8);
						
						//#2: Ladder out of water, near the tower thing with LAWs. Recovery area.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-2850,2075,-2146)+TSpacing, Vect(-2850,2080,-1986)+TSpacing,Vect(-2797,2080,-2000),, 4+8+64);
						
						//#3: Small ditch ladder player can hide in, near tower.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-2080,350,-2146)+TSpacing, Vect(-2080,350,-1992)+TSpacing, Vect(-2080,429,-2000),, 4+8);
						
						//#4: Ground level to F2 of water tower.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-1159,214,-1997)+TSpacing, Vect(-1159,214,-1798)+TSpacing, Vect(-1159,265,-1806),, 4+8,, 0.5, 0.5);
						
						//#5: F2 to F3 of water tower. We were built this way to work better with pathfinding.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-1159,265,-1806), Vect(-1159,214,-1798)+TSpacing, Vect(-1159,214,-1572)+TSpacing, Vect(-1159,266,-1580), 1+2+4+8,, 0.5, 0.5);
						
						//Keep sniper guy up here, thanks.
						VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 7));
						if (VMBP != None)
						{
							VMBP.bCanClimbLadders = false;
						}
						
						//#6: From interior room near vent up to the midsection.
						TSpacing = Vect(0,16,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-396,1059,-2061)+TSpacing, Vect(-396,1059,-1652)+TSpacing, Vect(-396,1014,-1652),, 4+8+512);
						
						//#7: From midsection in interior room to top.
						TSpacing = Vect(0,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-61,767,-1656)+TSpacing, Vect(-61,767,-1286)+TSpacing, Vect(-61,825,-1324),, 4+8);
					}
				break;
				//MADDERS, 8/12/24: For some reason, even well centered, the AI gets stuck coming up. It was misc anyways, axe it.
				/*case "12_VANDENBERG_TUNNELS":
					if (!bRevisionMapSet)
					{
						//#1: Ladder that requires the door to be open.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-1633,2425,-2558)+TSpacing, Vect(-1633,2425,-2311)+TSpacing, Vect(-1633,2350,-2320),, 4+8,,,,DeusExMover(FindActorBySeed(class'DeusExMover', 4)));
					}
				break;*/
				case "12_VANDENBERG_GAS":
					if (!bRevisionMapSet)
					{
						//#1: Sewers to enclosed trash area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(1636,-620,-1336)+TSpacing, Vect(1636,-620,-940)+TSpacing, Vect(1650,-544,-948),, 4+8);
						
						//#2: Rear gas station to roof
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(628,865,-945)+TSpacing, Vect(628,865,-576)+TSpacing, Vect(628,799,-584),, 4+8,,,,DeusExMover(FindActorBySeed(class'DeusExMover', 16)));
					}
				break;
			}
		break;
		case 14:
			switch(MN)
			{
				case "14_VANDENBERG_SUB":
					if (!bRevisionMapSet)
					{
						//#1: From water to module near elevator to subs. Recovery zone.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(1448,204,-664)+TSpacing, Vect(1448,204,-456)+TSpacing, Vect(1380,204,-464),, 4+8+64);
						
						//#2: Ladder from module near elevator to the weird bridge piece.
						TSpacing = Vect(0,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(2124,1509,-309)+TSpacing, Vect(2124,1509,-40)+TSpacing, Vect(2119,1608,-48),, 4);
						
						//#3: Ladder from bridge thing to F1 of labs.
						TSpacing = Vect(0,-4,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(2052,3028,-45)+TSpacing, Vect(2052,3028,404)+TSpacing, Vect(2052,2981,396),, 4+8+512+1024);
						
						//#4: Ladder from F1 of labs to F2 of labs.
						TSpacing = Vect(0,-4,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(2052,2981,396), Vect(2052,3028,404)+TSpacing, Vect(2052,3028,586)+TSpacing, Vect(2052,2976,577), 4+8+512+1024);
						
						//#5: Ladder from F2 labs to roof.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(1735,2829,580)+TSpacing, Vect(1735,2829,784)+TSpacing, Vect(1818,2834,776),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 9)));
					}
				break;
				case "14_OCEANLAB_LAB":
					if (!bRevisionMapSet)
					{
						//#1: From water region up to labs with greasels. Recovery area.
						TSpacing = Vect(-4,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(3026,56,-1781)+TSpacing, Vect(3026,56,-1488)+TSpacing, Vect(2947,56,-1496),, 4+8+64);
					}
				break;
				case "14_OCEANLAB_SILO":
					if (!bRevisionMapSet)
					{
						//#1: From ground level to watch tower.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-1389,-3401,1471)+TSpacing, Vect(-1389,-3400,2008)+TSpacing, Vect(-1389,-3331,2000),, 4+8);
						
						//Keep sniper guy up here, thanks.
						VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 0));
						if (VMBP != None)
						{
							VMBP.bCanClimbLadders = false;
						}
						
						//#2: From repair bot room to upper walkway.
						TSpacing = Vect(-4,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(667,-4240,1477)+TSpacing, Vect(667,-4240,1667)+TSpacing, Vect(605,-4240,1660),, 4+8);
						
						//#3: From silo up to chopper area.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-375,-6806,776), Vect(-459,-6806,825)+TSpacing, Vect(-459,-6806,1468)+TSpacing, Vect(-548,-6806,1482), 1+2+4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 12)));
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
						//#1: Ladder from bottom of tower up to ground level.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-1232,29,-452)+TSpacing, Vect(-1232,29,-168)+TSpacing, Vect(-1232,125,-176),, 4+8);
						
						//#2: Ladder from ground level of tower up to F2.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-1380,29,-168)+TSpacing, Vect(-1380,29,111)+TSpacing, Vect(-1391,111,103),, 4+8);
						
						//#3: Ladder from F2 of tower to F3.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-1232,29,106)+TSpacing, Vect(-1232,29,390)+TSpacing, Vect(-1308,30,425),, 4+8);
						
						//Keep sniper guy up here, thanks.
						VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 0));
						if (VMBP != None)
						{
							VMBP.bCanClimbLadders = false;
						}
						
						//#4: Barracks ground level to roof.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(978,2885,-461)+TSpacing, Vect(978,2885,-229)+TSpacing, Vect(935,2879,-237),, 4+8);
						
						//#5: Barracks to basement.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(982,2824,-744)+TSpacing, Vect(982,2824,-456)+TSpacing, Vect(1048,2791,-461),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 26)));
						
						//#6: Not truly a ladder, but these stair things that are collapsed that the player can climb. Sure.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(1311,-1654,-472)+TSpacing, Vect(1313,-1729,-288)+TSpacing, Vect(1313,-1798,-288),, 4+8);
						
						//#7: Ladder #1 on elevator power area going to the top with spiderbots.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(2881,3632,-909)+TSpacing, Vect(2881,3632,-728)+TSpacing, Vect(2881,3577,-736),, 4+8+256+512);
						
						//#8: Ladder #2 on elevator power area going to the top with spiderbots.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(4542,3616,-909)+TSpacing, Vect(4542,3616,-728)+TSpacing, Vect(4542,3561,-736),, 4+8+256+512);
					}
				break;
				case "15_AREA51_FINAL":
					if (!bRevisionMapSet)
					{
						//#1: Ladder up to catwalk at very start.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(-5560,-4640,-1389)+TSpacing, Vect(-5560,-4640,-1032)+TSpacing, Vect(-5492,-4640,-1040),, 4+8);
						
						//#2: Ladder to and from sniper's nest.
						TSpacing = Vect(-8,0,0);
						AddLadderGroup(Vect(1, 0, 0), Vect(-5044,-2838,-841)+TSpacing, Vect(-5044,-2838,-707)+TSpacing, Vect(-4984,-2838,-715),, 4+8);
						
						//Keep sniper guy up here, thanks.
						VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 8));
						if (VMBP != None)
						{
							VMBP.bCanClimbLadders = false;
						}
						
						//#3: Ladder up to dead maintenance guy on roof.
						TSpacing = Vect(8,0,0);
						AddLadderGroup(Vect(-1, 0, 0), Vect(-4865,-3659,-712)+TSpacing, Vect(-4865,-3659,-544)+TSpacing, Vect(-4936,-3659,-560),, 4+8);
						
						//#4: Ladder from grays up to random PC office area. Weird.
						TSpacing = Vect(0,8,0);
						AddLadderGroup(Vect(0, -1, 0), Vect(-5308,-1740,-1179)+TSpacing, Vect(-5308,-1740,-837)+TSpacing, Vect(-5308,-1646,-875),, 4+8+256+512);
					}
				break;
				case "15_AREA51_PAGE":
					if (!bRevisionMapSet)
					{
						//#1: Ladder at start of tong section up to catwalk.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(7318,-8764,-5968)+TSpacing, Vect(7318,-8764,-5662)+TSpacing, Vect(7318,-8703,-5670),, 4+8);
						
						//#2: Ladder towards back of ton section up to hallway towards catwalk.
						TSpacing = Vect(0,-8,0);
						AddLadderGroup(Vect(0, 1, 0), Vect(7806,-9950,-6160)+TSpacing, Vect(7806,-9950,-5642)+TSpacing, Vect(7891,-9949,-5650),, 4+8);
					}
				break;
			}
		break;
	}
	
	if (bRebuildRequired)
	{
		InitiateRebuild();
	}
	
	bRanFixes = true;
}

function InitiateRebuild()
{
	local NavigationPoint TPoint;
	local VMDConsole VC;
	
	VMDPR = Spawn(class'VMDPathRebuilder');
	if (VMDPR == None) return;
	
	VMDPR.AllowScoutToSpawn();
	
	forEach AllActors(class'NavigationPoint', TPoint)
	{
		TScout = Spawn(class'Scout',,, TPoint.Location);
		if (TScout != None)
		{
			break;
		}
	}
	
	if (TScout == None)
	{
		VMDPR.Destroy();
		return;
	}
	
	forEach AllObjects(class'VMDConsole', VC)
	{
		VC.bExpandingLadders = true;
		break;
	}
	
	bRebuilding = true;
	RebuildProgress = 0;
}

function FinishRebuild()
{
	local VMDConsole VC;
	
	VMDPR.ScoutSetup(TScout);
	VMDPR.RedefinePaths();
	
	TScout.Destroy();
	VMDPR.Destroy();
	
	forEach AllObjects(class'VMDConsole', VC)
	{
		VC.bExpandingLadders = false;
		break;
	}
	
	bRebuilding = false;
	RebuildProgress = 0;
}

function AddLadderGroup(Vector LadderNormal, Vector Point1, Vector Point2, optional Vector Point3, optional Vector Point4, optional int JumpFlags, optional float JumpZMult, optional float StartJumpZMult, optional float EndJumpZMult, optional DeusExMover OpenMoverRequired)
{
	local bool bStartNextJump, bStartPreviousJump, bEndNextJump, bEndPreviousJump, bAllNextJump, bAllPreviousJump, bStartOnly, bEndOnly;
	local int i, ListSize, PointMash[4];
	local Vector BlankVect, Points[4];
	local VMDLadderPoint LP[4], Last;
	
	bStartNextJump = bool(JumpFlags & 1);
	bStartPreviousJump = bool(JumpFlags & 2);
	bEndNextJump = bool(JumpFlags & 4);
	bEndPreviousJump = bool(JumpFlags & 8);
	bAllNextJump = bool(JumpFlags & 16);
	bAllPreviousJump = bool(JumpFlags & 32);
	
	bStartOnly = bool(JumpFlags & 64);
	bEndOnly = bool(JumpFlags & 128);
	
	PointMash[0] = (JumpFlags & 256);
	PointMash[1] = (JumpFlags & 512);
	PointMash[2] = (JumpFlags & 1024);
	PointMash[3] = (JumpFlags & 2048);
	
	if (JumpZMult < 0.05)
	{
		JumpZMult = 1.0;
	}
	if (StartJumpZMult < 0.05)
	{
		StartJumpZMult = 1.0;
	}
	if (EndJumpZMult < 0.05)
	{
		EndJumpZMult = 1.0;
	}
	
	Points[0] = Point1;
	Points[1] = Point2;
	Points[2] = Point3;
	Points[3] = Point4;
	if (Point4 != BlankVect)
	{
		ListSize = 4;
	}
	else if (Point3 != BlankVect)
	{
		ListSize = 3;
	}
	else
	{
		ListSize = 2;
	}
	
	for(i=0; i<ListSize; i++)
	{
		LP[i] = Spawn(class'VMDLadderPoint',,, Points[i]);
		if (LP[i] != None)
		{
			//MADDERS, 8/12/24: Point mashing is a wicked hack. Decrease our size, and cram us into the wall.
			//In rare cases, this is required to squeeze into tight spaces elegantly.
			if (PointMash[i] > 0)
			{
				LP[i].SetCollisionSize(LP[i].Default.CollisionRadius * 0.25, LP[i].Default.CollisionHeight);
				LP[i].SetLocation(LP[i].Location + (LadderNormal*12));
			}
			
			if (Last != None)
			{
				Last.NextPoint = LP[i];
				LP[i].PreviousPoint = Last;
			}
			LP[i].JumpZMult = JumpZMult;
			LP[i].LadderNormal = LadderNormal;
			LP[i].bNextJump = bAllNextJump;
			LP[i].bPreviousJump = bAllPreviousJump;
			Last = LP[i];
		}
	}
	
	if (LP[0] != None)
	{
		LP[0].bForward = true;
		if (!bStartOnly)
		{
			LP[0].OppositePoint = LP[ListSize-1];
		}
		LP[0].bNextJump = (bStartNextJump || bAllNextJump);
		LP[0].bPreviousJump = (bStartPreviousJump || bAllPreviousJump);
		LP[0].JumpZMult = StartJumpZMult;
		LP[0].OpenMoverRequired = OpenMoverRequired;
	}
	if (LP[ListSize-1] != None)
	{
		LP[ListSize-1].bBackward = true;
		if (!bEndOnly)
		{
			LP[ListSize-1].OppositePoint = LP[0];
		}
		LP[ListSize-1].bNextJump = (bEndNextJump || bAllNextJump);
		LP[ListSize-1].bPreviousJump = (bEndPreviousJump || bAllPreviousJump);
		LP[ListSize-1].JumpZMult = EndJumpZMult;
		LP[ListSize-1].OpenMoverRequired = OpenMoverRequired;
	}
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
