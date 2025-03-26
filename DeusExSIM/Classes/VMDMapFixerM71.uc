//=============================================================================
// VMDMapFixerM71.
//=============================================================================
class VMDMapFixerM71 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//71_MUTATIONS: Turrets are intended to be active, but are not. Fix this.
		case "71_MUTATIONS":
			forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = true;
				}
			}
		break;
		//71_ZODIAC_LANGLEY_CIAHQ: Hiding portrait, in-line with prior changes.
		//2/18/25: Also, add more paths for MEGH.
		case "71_ZODIAC_LANGLEY_CIAHQ":
			Spawn(class'PathNodeMobile',,, Vect(-3185,-2564,1320));
			Spawn(class'PathNodeMobile',,, Vect(-3252,-2745,1250));
			Spawn(class'PathNodeMobile',,, Vect(-3020,-2585,1332));
			Spawn(class'PathNodeMobile',,, Vect(-2786,-4022,655));
			Spawn(class'PathNodeMobile',,, Vect(-2430,-2019,655));
			Spawn(class'PathNodeMobile',,, Vect(-2665,-4024,655));
			Spawn(class'PathNodeMobile',,, Vect(-2323,-4046,655));
			Spawn(class'PathNodeMobile',,, Vect(-2266,-4150,655));
			Spawn(class'PathNodeMobile',,, Vect(-2270,-4457,655));
			Spawn(class'PathNodeMobile',,, Vect(-2313,-4466,655));
			Spawn(class'PathNodeMobile',,, Vect(-2316,-4810,655));
			Spawn(class'PathNodeMobile',,, Vect(-2305,-4635,655));
			Spawn(class'PathNodeMobile',,, Vect(-2211,-4646,655));
			Spawn(class'PathNodeMobile',,, Vect(-2199,-4831,655));
			Spawn(class'PathNodeMobile',,, Vect(-2209,-5231,655));
			Spawn(class'PathNodeMobile',,, Vect(-2367,-5231,655));
			Spawn(class'PathNodeMobile',,, Vect(-2270,-4087,655));
			Spawn(class'PathNodeMobile',,, Vect(114,2245,23));
			Spawn(class'PathNodeMobile',,, Vect(143,1818,23));
			Spawn(class'PathNodeMobile',,, Vect(921,1873,23));
			Spawn(class'PathNodeMobile',,, Vect(97,498,23));
			Spawn(class'PathNodeMobile',,, Vect(933,544,23));
			Spawn(class'PathNodeMobile',,, Vect(992,7,23));
			Spawn(class'PathNodeMobile',,, Vect(1252,-22,31));
			Spawn(class'PathNodeMobile',,, Vect(1165,-600,31));
			Spawn(class'PathNodeMobile',,, Vect(1181,-1155,31));
			Spawn(class'PathNodeMobile',,, Vect(1191,-1306,31));
			Spawn(class'PathNodeMobile',,, Vect(1490,-1562,31));
			Spawn(class'PathNodeMobile',,, Vect(1515,-1721,31));
			Spawn(class'PathNodeMobile',,, Vect(1696,-1796,37));
			Spawn(class'PathNodeMobile',,, Vect(2092,-1749,-353));
			Spawn(class'PathNodeMobile',,, Vect(2196,-1735,-353));
			Spawn(class'PathNodeMobile',,, Vect(2213,-1397,-353));
			Spawn(class'PathNodeMobile',,, Vect(1924,-1408,-353));
			Spawn(class'PathNodeMobile',,, Vect(1039,615,23));
			Spawn(class'PathNodeMobile',,, Vect(1144,603,29));
			Spawn(class'PathNodeMobile',,, Vect(1392,602,143));
			Spawn(class'PathNodeMobile',,, Vect(1367,355,271));
			Spawn(class'PathNodeMobile',,, Vect(1438,66,271));
			Spawn(class'PathNodeMobile',,, Vect(1483,-329,271));
			Spawn(class'PathNodeMobile',,, Vect(1495,-712,271));
			Spawn(class'PathNodeMobile',,, Vect(1257,644,130));
			Spawn(class'PathNodeMobile',,, Vect(301,1143,23));
			Spawn(class'PathNodeMobile',,, Vect(1006,1196,23));
			Spawn(class'PathNodeMobile',,, Vect(975,-479,23));
			Spawn(class'PathNodeMobile',,, Vect(943,-1026,23));
			Spawn(class'PathNodeMobile',,, Vect(512,-1094,23));
			Spawn(class'PathNodeMobile',,, Vect(160,-1489,23));
			Spawn(class'PathNodeMobile',,, Vect(919,-1462,23));
			Spawn(class'PathNodeMobile',,, Vect(616,-1876,23));
			Spawn(class'PathNodeMobile',,, Vect(655,1880,23));
			Spawn(class'PathNodeMobile',,, Vect(661,2126,23));
			Spawn(class'PathNodeMobile',,, Vect(471,2096,23));
			Spawn(class'PathNodeMobile',,, Vect(663,2392,-97));
			Spawn(class'PathNodeMobile',,, Vect(188,2379,-289));
			Spawn(class'PathNodeMobile',,, Vect(-57,2358,-289));
			Spawn(class'PathNodeMobile',,, Vect(-59,2820,-289));
			Spawn(class'PathNodeMobile',,, Vect(290,2836,-289));
			Spawn(class'PathNodeMobile',,, Vect(838,2828,-289));
			Spawn(class'PathNodeMobile',,, Vect(1292,2819,-289));
			Spawn(class'PathNodeMobile',,, Vect(1630,2818,-289));
			Spawn(class'PathNodeMobile',,, Vect(1940,2832,-289));
			Spawn(class'PathNodeMobile',,, Vect(2252,2833,-289));
			Spawn(class'PathNodeMobile',,, Vect(2713,2834,-289));
			Spawn(class'PathNodeMobile',,, Vect(2970,2826,-289));
			Spawn(class'PathNodeMobile',,, Vect(3244,2820,-289));
			Spawn(class'PathNodeMobile',,, Vect(3583,2824,-289));
			Spawn(class'PathNodeMobile',,, Vect(3906,2831,-289));
			Spawn(class'PathNodeMobile',,, Vect(4211,2825,-289));
			Spawn(class'PathNodeMobile',,, Vect(4587,2827,-289));
			Spawn(class'PathNodeMobile',,, Vect(4943,2833,-289));
			Spawn(class'PathNodeMobile',,, Vect(5279,2833,-289));
			Spawn(class'PathNodeMobile',,, Vect(5601,2829,-289));
			Spawn(class'PathNodeMobile',,, Vect(5858,2826,-289));
			Spawn(class'PathNodeMobile',,, Vect(6125,2817,-289));
			Spawn(class'PathNodeMobile',,, Vect(6491,2830,-289));
			Spawn(class'PathNodeMobile',,, Vect(6889,2838,-289));
			Spawn(class'PathNodeMobile',,, Vect(7316,2840,-289));
			Spawn(class'PathNodeMobile',,, Vect(7680,2829,-289));
			Spawn(class'PathNodeMobile',,, Vect(8064,2832,-289));
			Spawn(class'PathNodeMobile',,, Vect(8489,2829,-289));
			Spawn(class'PathNodeMobile',,, Vect(723,2281,17));
			Spawn(class'PathNodeMobile',,, Vect(8569,-1882,111));
			Spawn(class'PathNodeMobile',,, Vect(8701,-1883,111));
			Spawn(class'PathNodeMobile',,, Vect(7939,-958,111));
			Spawn(class'PathNodeMobile',,, Vect(8025,-959,111));
			Spawn(class'PathNodeMobile',,, Vect(8186,-960,191));
			Spawn(class'PathNodeMobile',,, Vect(8346,-961,271));
			Spawn(class'PathNodeMobile',,, Vect(8351,-1147,351));
			Spawn(class'PathNodeMobile',,, Vect(2346,-1317,351));
			Spawn(class'PathNodeMobile',,, Vect(8355,-1511,223));
			Spawn(class'PathNodeMobile',,, Vect(8282,-1630,223));
			Spawn(class'PathNodeMobile',,, Vect(8042,-1251,351));
			Spawn(class'PathNodeMobile',,, Vect(8657,-1257,351));
			Spawn(class'PathNodeMobile',,, Vect(8566,-1805,351));
			Spawn(class'PathNodeMobile',,, Vect(8484,4047,1071));
			Spawn(class'PathNodeMobile',,, Vect(8688,4048,1071));
			Spawn(class'PathNodeMobile',,, Vect(8676,4446,1071));
			Spawn(class'PathNodeMobile',,, Vect(8969,4448,1167));
			Spawn(class'PathNodeMobile',,, Vect(8953,4020,1167));
			Spawn(class'PathNodeMobile',,, Vect(9112,4439,1167));
			Spawn(class'PathNodeMobile',,, Vect(9124,4043,1167));
			Spawn(class'PathNodeMobile',,, Vect(9124,4043,1167));
			Spawn(class'PathNodeMobile',,, Vect(8793,4476,1137));
			Spawn(class'PathNodeMobile',,, Vect(7458,2973,1359));
			Spawn(class'PathNodeMobile',,, Vect(7433,3200,1359));
			Spawn(class'PathNodeMobile',,, Vect(7937,2978,1359));
			Spawn(class'PathNodeMobile',,, Vect(7939,2786,1359));
			Spawn(class'PathNodeMobile',,, Vect(8209,2787,1359));
			Spawn(class'PathNodeMobile',,, Vect(8906,2826,1359));
			Spawn(class'PathNodeMobile',,, Vect(8926,2157,1359));
			Spawn(class'PathNodeMobile',,, Vect(8237,2139,1359));
			Spawn(class'PathNodeMobile',,, Vect(8530,2440,1359));
			Spawn(class'PathNodeMobile',,, Vect(-2835,-3986,1167));
			Spawn(class'PathNodeMobile',,, Vect(-11413,11,289));
			Spawn(class'PathNodeMobile',,, Vect(-11825,32,226));
			Spawn(class'PathNodeMobile',,, Vect(-12335,3,147));
			Spawn(class'PathNodeMobile',,, Vect(-6332,1775,659));
			Spawn(class'PathNodeMobile',,, Vect(-6566,1752,655));
			Spawn(class'PathNodeMobile',,, Vect(-6584,2051,655));
			Spawn(class'PathNodeMobile',,, Vect(-6630,2584,559));
			Spawn(class'PathNodeMobile',,, Vect(-6692,3361,408));
			Spawn(class'PathNodeMobile',,, Vect(-6722,3841,315));
			Spawn(class'PathNodeMobile',,, Vect(-6738,4289,237));
			Spawn(class'PathNodeMobile',,, Vect(-6585,4843,175));
			Spawn(class'PathNodeMobile',,, Vect(-6276,5437,108));
			Spawn(class'PathNodeMobile',,, Vect(-5825,6015,42));
			Spawn(class'PathNodeMobile',,, Vect(-5369,6464,15));
			Spawn(class'PathNodeMobile',,, Vect(-4804,6488,15));
			Spawn(class'PathNodeMobile',,, Vect(-4114,6534,15));
			Spawn(class'PathNodeMobile',,, Vect(-3741,6532,15));
			Spawn(class'PathNodeMobile',,, Vect(-3445,6454,15));
			Spawn(class'PathNodeMobile',,, Vect(-3344,6546,15));
			Spawn(class'PathNodeMobile',,, Vect(-3045,6548,15));
			Spawn(class'PathNodeMobile',,, Vect(-2744,6540,15));
			Spawn(class'PathNodeMobile',,, Vect(-2346,6556,15));
			Spawn(class'PathNodeMobile',,, Vect(-1490,6532,15));
			VMP.VMDRebuildPaths();
			
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 1:
							DXM.bHighlight = false;
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
		//71_ZODIAC_LANGLEY_MJ12: Add more MEGH paths.
		case "71_ZODIAC_LANGLEY_MJ12":
			Spawn(class'PathNodeMobile',,, Vect(-559,1615,47));
			Spawn(class'PathNodeMobile',,, Vect(-336,1534,47));
			Spawn(class'PathNodeMobile',,, Vect(-295,1681,47));
			Spawn(class'PathNodeMobile',,, Vect(-418,1314,47));
			Spawn(class'PathNodeMobile',,, Vect(-43,1321,47));
			Spawn(class'PathNodeMobile',,, Vect(-171,1191,47));
			Spawn(class'PathNodeMobile',,, Vect(-646,1647,47));
			Spawn(class'PathNodeMobile',,, Vect(-607,1653,47));
			Spawn(class'PathNodeMobile',,, Vect(-571,1636,47));
			Spawn(class'PathNodeMobile',,, Vect(-603,1639,47));
			Spawn(class'PathNodeMobile',,, Vect(-599,1638,47));
			Spawn(class'PathNodeMobile',,, Vect(-1081,-303,831));
			Spawn(class'PathNodeMobile',,, Vect(-1081,-246,831));
			Spawn(class'PathNodeMobile',,, Vect(-1085,-23,1023));
			Spawn(class'PathNodeMobile',,, Vect(-1088,103,1023));
			Spawn(class'PathNodeMobile',,, Vect(-1438,99,1023));
			Spawn(class'PathNodeMobile',,, Vect(-1118,443,1023));
			Spawn(class'PathNodeMobile',,, Vect(-1236,273,1023));
			Spawn(class'PathNodeMobile',,, Vect(-1108,-127,995));
			Spawn(class'PathNodeMobile',,, Vect(-1108,-213,908));
			Spawn(class'PathNodeMobile',,, Vect(-1472,-168,639));
			Spawn(class'PathNodeMobile',,, Vect(-1473,315,639));
			Spawn(class'PathNodeMobile',,, Vect(-1219,-284,788));
			VMP.VMDRebuildPaths();
		break;
		
		//71_WHITEHOUSE: 10mm ammo inside the floor.
		case "71_WHITEHOUSE":
			forEach AllActors(class'Actor', A)
			{
				if (Ammo10mm(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 2:
							A.SetLocation(Vect(3507, 5598, 268));
						break;
					}
				}
				else if (Ammo10mmGasCap(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 0:
							A.SetLocation(Vect(3507, 5598, 268));
						break;
					}
				}
			}
		break;
		//71_CANYON: Horrendously fucked up doors.
		case "71_CANYON":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 0:
							//Base of -897, -712, -1492
							//BEST FIT IS -899, -712, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of -16384, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-897,-712,-1492)))
							{
								LocAdd = vect(-4, 0, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(-4, 0, 128);
								FrameAdd[1] = vect(-4, 0, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 2:
							//Base of -1440, -24, -1492
							//BEST FIT IS -1440, -22, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 32768, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1440,-24,-1492)))
							{
								LocAdd = vect(0, 4, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(0, 4, 128);
								FrameAdd[1] = vect(0, 4, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 20:
							//Base of -627, -1520, -1364
							//BEST FIT IS -625, -1520, -1236
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-627,-1520,-1364)))
							{
								LocAdd = vect(4, 0, -128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(4, 0, -128);
								FrameAdd[1] = vect(4, 0, -128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 23:
							//Base of -1203, -1632, -1364
							//BEST FIT IS -1205, -1632, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1203,-1632,-1364)))
							{
								LocAdd = vect(-4, 0, -128);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(-4, 0, -128);
								FrameAdd[1] = vect(-4, 0, -128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 32:
							//Base of -1312, -24, -1496
							//BEST FIT IS -1312, -22, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1312,-24,-1496)))
							{
								LocAdd = vect(0, 4, 136);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(0, 4, 136);
								FrameAdd[1] = vect(0, 4, 136);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 36:
							//Base of -743, -752, -1492
							//BEST FIT IS -743, -750, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-743,-752,-1492)))
							{
								LocAdd = vect(0, 4, 128);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(0, 4, 128);
								FrameAdd[1] = vect(0, 4, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 39:
							//Base of -627, -1648, -1492
							//BEST FIT IS -625, -1648, -1492
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-627,-1648,-1492)))
							{
								LocAdd = vect(4, 0, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(4, 0, 128);
								FrameAdd[1] = vect(4, 0, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
			
			class'VMDLightRebuilder'.Static.RebuildLighting();
		break;
	}
}

defaultproperties
{
}
