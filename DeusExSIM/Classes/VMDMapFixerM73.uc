//=============================================================================
// VMDMapFixerM73.
//=============================================================================
class VMDMapFixerM73 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
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
			VMP.VMDRebuildPaths();
		break;
		//73_ZODIAC_NEWMEXICO_PAGEBIO: Lights here do not work with non-classic d3d10, and barely work with a normal renderer.
		//Fuck with all the values and then call flush to fix this.
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
			VMP.VMDRebuildPaths();
			
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
			VMP.ConsoleCommand("FLUSH");
		break;
		//73_ZODIAC_NEWMEXICO_UGROUNDA: Defaults to 1234. Not sure why. Randomize it.
		case "73_ZODIAC_NEWMEXICO_UGROUNDA":
			Spawn(class'PathNodeMobile',,, Vect(5042,-1900,-505));
			VMP.VMDRebuildPaths();
			
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
			VMP.VMDRebuildPaths();
			
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
		//73_ZODIAC_NEWMEXICO_UGROUNDC: More pathing.
		case "73_ZODIAC_NEWMEXICO_UGROUNDC":
			Spawn(class'PathNodeMobile',,, Vect(-1840,999,123));
			VMP.VMDRebuildPaths();
		break;
	}
}

defaultproperties
{
}
