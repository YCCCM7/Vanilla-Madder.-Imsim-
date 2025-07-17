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
		//73_ZODIAC_NEWMEXICO_PAGEBIO: Lights here do not work with non-classic d3d10, and barely work with a normal renderer.
		//Fuck with all the values and then call flush to fix this.
		case "73_ZODIAC_NEWMEXICO_PAGEBIO":
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
	}
}

defaultproperties
{
}
