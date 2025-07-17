//=============================================================================
// VMDLadderPointAdderM73.
//=============================================================================
class VMDLadderPointAdderM73 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		//73_ZODIAC_NEWMEXICO_ENTRANCE: More path nodes.
		case "73_ZODIAC_NEWMEXICO_ENTRANCE":
			Spawn(class'PathNodeMobile',,, Vect(-1106,-3300,-353));
			Spawn(class'PathNodeMobile',,, Vect(-654,-3300,-353));
			Spawn(class'PathNodeMobile',,, Vect(-667,-3042,-353));
			Spawn(class'PathNodeMobile',,, Vect(-1150,-3034,-353));
			Spawn(class'PathNodeMobile',,, Vect(-1143,-2344,-353));
			Spawn(class'PathNodeMobile',,, Vect(-681,-2363,-353));
			Spawn(class'PathNodeMobile',,, Vect(1393,-2769,-1025));
			Spawn(class'PathNodeMobile',,, Vect(1461,-2826,-1025));
			Spawn(class'PathNodeMobile',,, Vect(1798,-2765,-1025));
			Spawn(class'PathNodeMobile',,, Vect(2020,-2769,-1057));
			Spawn(class'PathNodeMobile',,, Vect(2076,-2512,-1025));
			Spawn(class'PathNodeMobile',,, Vect(2075,-2743,-1057));
			Spawn(class'PathNodeMobile',,, Vect(2074,-2631,-1025));
			Spawn(class'PathNodeMobile',,, Vect(1931,-2783,-1025));
			Spawn(class'PathNodeMobile',,, Vect(1073,-1502,-1817));
			Spawn(class'PathNodeMobile',,, Vect(1090,-1493,-1417));
			Spawn(class'PathNodeMobile',,, Vect(716,-1499,-1641));
			Spawn(class'PathNodeMobile',,, Vect(682,-1390,-1641));
			Spawn(class'PathNodeMobile',,, Vect(1077,-1379,-1817));
			Spawn(class'PathNodeMobile',,, Vect(882,-1420,-1674));
			Spawn(class'PathNodeMobile',,, Vect(2254,-2069,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1909,-2086,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1625,-2094,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1468,-2047,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1178,-2037,-1425));
			Spawn(class'PathNodeMobile',,, Vect(842,-2038,-1425));
			Spawn(class'PathNodeMobile',,, Vect(567,-2063,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1179,-1518,-1417));
			Spawn(class'PathNodeMobile',,, Vect(1090,-1493,-1417));
			Spawn(class'PathNodeMobile',,, Vect(716,-1499,-1641));
			Spawn(class'PathNodeMobile',,, Vect(1180,-1697,-1425));
			Spawn(class'PathNodeMobile',,, Vect(1186,-1573,-1417));
			bRebuildRequired = true;
		break;
		case "73_ZODIAC_NEWMEXICO_PAGEBIO":
			Spawn(class'PathNodeMobile',,, Vect(-573,-3109,15));
			Spawn(class'PathNodeMobile',,, Vect(-456,-3104,15));
			Spawn(class'PathNodeMobile',,, Vect(-1262,-3272,15));
			Spawn(class'PathNodeMobile',,, Vect(-1263,-2959,255));
			Spawn(class'PathNodeMobile',,, Vect(-1259,-4044,255));
			Spawn(class'PathNodeMobile',,, Vect(1152,-5233,-49));
			Spawn(class'PathNodeMobile',,, Vect(1138,-5115,-49));
			Spawn(class'PathNodeMobile',,, Vect(1534,-3390,15));
			Spawn(class'PathNodeMobile',,, Vect(1410,-3391,15));
			Spawn(class'PathNodeMobile',,, Vect(1534,-3092,-161));
			Spawn(class'PathNodeMobile',,, Vect(1636,-3093,-161));
			Spawn(class'PathNodeMobile',,, Vect(1633,-3424,-369));
			Spawn(class'PathNodeMobile',,, Vect(1440,-3464,-369));
			Spawn(class'PathNodeMobile',,, Vect(1380,-3134,-369));
			Spawn(class'PathNodeMobile',,, Vect(983,-3106,-369));
			Spawn(class'PathNodeMobile',,, Vect(1632,-3248,-218));
			Spawn(class'PathNodeMobile',,, Vect(1631,-3176,-147));
			Spawn(class'PathNodeMobile',,, Vect(1533,-3139,-161));
			Spawn(class'PathNodeMobile',,, Vect(1516,-3228,-63));
			Spawn(class'PathNodeMobile',,, Vect(1556,-3283,13));
			bRebuildRequired = true;
		break;
		//73_ZODIAC_NEWMEXICO_UGROUNDA: Defaults to 1234. Not sure why. Randomize it.
		case "73_ZODIAC_NEWMEXICO_UGROUNDA":
			Spawn(class'PathNodeMobile',,, Vect(5042,-1900,-505));
			bRebuildRequired = true;
		break;
		//73_ZODIAC_NEWMEXICO_UGROUNDB: Sequence break from panicking scientists. Sigh.
		case "73_ZODIAC_NEWMEXICO_UGROUNDB":
			Spawn(class'PathNodeMobile',,, Vect(-186,645,15));
			Spawn(class'PathNodeMobile',,, Vect(3,-1252,15));
			Spawn(class'PathNodeMobile',,, Vect(271,-1290,15));
			Spawn(class'PathNodeMobile',,, Vect(342,-941,15));
			Spawn(class'PathNodeMobile',,, Vect(399,-1563,15));
			Spawn(class'PathNodeMobile',,, Vect(583,-1648,15));
			Spawn(class'PathNodeMobile',,, Vect(871,-1627,15));
			Spawn(class'PathNodeMobile',,, Vect(1045,-1429,15));
			Spawn(class'PathNodeMobile',,, Vect(1078,-1138,15));
			Spawn(class'PathNodeMobile',,, Vect(875,-907,15));
			Spawn(class'PathNodeMobile',,, Vect(662,-602,15));
			Spawn(class'PathNodeMobile',,, Vect(652,-840,15));
			Spawn(class'PathNodeMobile',,, Vect(988,-991,15));
			Spawn(class'PathNodeMobile',,, Vect(953,-926,15));
			Spawn(class'PathNodeMobile',,, Vect(932,-972,15));
			Spawn(class'PathNodeMobile',,, Vect(962,-1012,15));
			Spawn(class'PathNodeMobile',,, Vect(917,-983,15));
			Spawn(class'PathNodeMobile',,, Vect(884,-1017,15));
			Spawn(class'PathNodeMobile',,, Vect(1045,-924,15));
			Spawn(class'PathNodeMobile',,, Vect(1072,-3004,15));
			Spawn(class'PathNodeMobile',,, Vect(1315,-3003,15));
			Spawn(class'PathNodeMobile',,, Vect(1725,-2382,15));
			Spawn(class'PathNodeMobile',,, Vect(1722,-2190,15));
			Spawn(class'PathNodeMobile',,, Vect(1706,-1838,15));
			bRebuildRequired = true;
		break;
		//73_ZODIAC_NEWMEXICO_UGROUNDC: More pathing.
		case "73_ZODIAC_NEWMEXICO_UGROUNDC":
			Spawn(class'PathNodeMobile',,, Vect(-1840,999,123));
			bRebuildRequired = true;
		break;
	}
}

defaultproperties
{
}
