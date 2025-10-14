//=============================================================================
// FrobDisplayWindow.
//=============================================================================
class FrobDisplayWindow extends Window;

var float margin;
var float barLength;

var DeusExPlayer player;

var localized string msgLocked;
var localized string msgUnlocked;
var localized string msgLockStr;
var localized string msgDoorStr;
var localized string msgHackStr;
var localized string msgInf;
var localized string msgHacked;
var localized string msgPick;
var localized string msgPicks;
var localized string msgTool;
var localized string msgTools;
var localized string msgOn;
var localized string msgOff;

// Default Colors
var Color colBackground;
var Color colBorder;
var Color colText;

//MADDERS: New labels. Yeet.
var localized string msgUnusable, msgBreakableOnly, msgBarrierOnly, msgMinDamageLabel, msgCharacters, msgMysteryLock, MsgNoKey, MsgLackingKey, MsgHasKey;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

function InitWindow()
{
	Super.InitWindow();

	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);

	StyleChanged();
}

// ----------------------------------------------------------------------
// FormatString()
// ----------------------------------------------------------------------

function string FormatString(float num)
{
	local string tempstr;

	// round up
	num += 0.5;

	tempstr = Left(String(num), 3);

	if (num < 100.0)
		tempstr = Left(String(num), 2);
	if (num < 10.0)
		tempstr = Left(String(num), 1);

	return tempstr;
}



// ----------------------------------------------------------------------
// MADDERS: Bypass estimation functions.
// ----------------------------------------------------------------------

function string GetHackReading(HackableDevices HD)
{
	local float HackStr, HackAvg, HackSkill, FRet;
	local Multitool Tool;
	local string Ret;
	
	Tool = Multitool(Player.FindInventoryType(class'Multitool'));
	
	HackStr = HD.HackStrength;
	HackSkill = Player.SkillSystem.GetSkillLevelValue(class'SkillTech');
	
	if ((Keypad(HD) != None) && (VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).HasSkillAugment('ElectronicsKeypads')))
	{
		HackSkill *= 1.35;
	}
	
	HackAvg = 100.0;
	
	FRet = HackStr / HackSkill;
	Ret = string(Int(FRet+0.9999));
	
	if (!(Ret ~= "1")) Ret = ""$Ret@MsgTools;
	else Ret = ""$Ret@MsgTool;
	
	return Ret;
}

function string GetLockReading(DeusExMover DM)
{
	local float PickStr, PickAvg, PickSkill, FRet;
	local Lockpick Pick;
	local string Ret;
	
	Pick = Lockpick(Player.FindInventoryType(class'Lockpick'));
	PickStr = DM.LockStrength;
	PickSkill = Player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking');
	PickAvg = 100.0;
	
	FRet = PickStr / PickSkill;
	Ret = string(Int(FRet+0.9999));
	
	if (!(Ret ~= "1")) Ret = ""$Ret@MsgPicks;
	else Ret = ""$Ret@MsgPick;
	
	return Ret;
}

//MADDERS: Wicked hack. Don't display these actors until frobbed. This bool is fuckin' dirty AF.
function bool ActorIsLit(Actor A)
{
	local bool FrobCheck, VisionCheck, LightCheck;
	local VMDBufferPlayer VMP;
	local int LightCount;
	local Inventory Inv;
	local DeusExRootWindow DXRW;
	
	if (A == None) return false;
	
	//MADDERS: If no VMD player is seen, hand this shit out for free.
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP == None) return true;
	
	DXRW = DeusExRootWindow(VMP.RootWindow);
	if (DXRW == None) return false;
	if (DXRW.AugDisplay == None) return false;
	
	FrobCheck = false;
	if (Mover(A) == None)
	{
		FrobCheck = !bool(A.GetPropertyText("bEverNotFrobbed"));
	}
	else if (DeusExMover(A) != None)
	{
		FrobCheck = ((DeusExMover(A).bDamageRevealed) || (DeusExMover(A).bLockRevealed));
	}
	//MADDERS, 4/15/21: Hack for 3rd party mover revealing.
	else if (Mover(A) != None)
	{
		FrobCheck = Mover(A).bIsSecretGoal;
		if (!Mover(A).bIsSecretGoal) return false;
	}
	else
	{
		//MADDERS: Not sure why movers would need revealing, but assume "yes" since we can't have our bools flicked on.
		FrobCheck = true;
	}
	
	VisionCheck = false;
	if (!FrobCheck)
	{
		if (DXRW.AugDisplay.bVisionActive)
		{
			VisionCheck = true;
		}
	}
	
	LightCheck = (A.ScaleGlow < 0.02 || A.AIGETLIGHTLEVEL(A.Location)*A.ScaleGlow > 0.005);
	if ((!LightCheck) && (!FrobCheck) && (!VisionCheck) && (DeusExMover(A) != None))
	{
		LightCheck = (A.AIGETLIGHTLEVEL(A.Location + (vect(-16, 0, 0) >> VMP.ViewRotation)) > 0.005);
		/*LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(5,0,0) > 0.005)));
		LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(-5,0,0) > 0.005)));
		LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(0,5,0) > 0.005)));
		LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(0,-5,0) > 0.005)));
		LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(0,0,5) > 0.005)));
		LightCount += (int(A.AIGETLIGHTLEVEL(A.Location+vect(0,0,-5) > 0.005)));
		
		if (LightCount > 1) LightCheck = true;*/
	}
	
	if (VisionCheck || FrobCheck || LightCheck)
	{
		return true;
	}
	
	return false;
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

function DrawWindow(GC gc)
{
	local actor				frobTarget;
	local float				infoX, infoY, infoW, infoH;
	local string			strInfo;
	local DeusExMover		dxMover;
	local Mover				M;
	local HackableDevices	device;
	local Vector			centerLoc, v1, v2;
	local float				boxCX, boxCY, boxTLX, boxTLY, boxBRX, boxBRY, boxW, boxH;
	local float				corner, x, y;
	local int				i, j, k, offset;
	local Color				col;
	local int				numTools;
	local Augmentation 		aug1, aug2;
	
	local bool ExpandHackable, ExpandDoor, ExpandKeyInfo, FrobCheck; //MADDERS: Draw several rows?
	local int WidthHack, WidthHack2, KeyInfoWidthHack;
	local AugmentationCannister AugCan;
	local ChargedPickup Charge;
	local DeusExAmmo DXAmmo;
	local DeusExWeapon DXWeapon;
	local DeusExPickup DXPick;
	local NanokeyRing TRing;
	local VMDBufferPlayer VPlayer;
	
	local bool BarfRevealed, BarfDamRevealed, BarfDamaged, BarfBreakable;
	local int BarfThreshold;
	local float BarfStrength, BarfOrigStrength;
	
	VPlayer = VMDBufferPlayer(GetPlayerPawn());
	
	if (player != None)
	{
		frobTarget = player.FrobTarget;
		if (frobTarget != None)
			if (!player.IsHighlighted(frobTarget))
				frobTarget = None;
		
		if (FrobTarget != None)
		{
			BarfBreakable = bool(FrobTarget.GetPropertyText("bBreakable"));
			BarfRevealed = FrobTarget.bIsSecretGoal;
			BarfOrigStrength = FrobTarget.BlendTweenRate[0];
			BarfStrength = float(FrobTarget.GetPropertyText("DoorStrength"));
			BarfThreshold = Max(1, FrobTarget.BlendTweenRate[1]+1);
			
			if ((BarfRevealed) && (BarfStrength < BarfOrigStrength))
			{
				BarfThreshold = int(FrobTarget.GetPropertyText("MinDamageThreshold"));
				BarfDamaged = true;
			}
			
			if (BarfDamaged) BarfDamRevealed = true;
			if ((VPlayer != None) && (VPlayer.HasSkillAugment('LockpickStartStealth'))) BarfDamRevealed = true;
			if (BarfThreshold > 1) BarfDamRevealed = true;
		}
		
		//MADDERS: Check for the lighting stuff. See function for my rant.
		if ((frobTarget != None) && (ActorIsLit(FrobTarget)))
		{
			//MADDERS: Mark this object as having been viewed at least once. Dirty, but reliable.
			if (!FrobCheck) FrobTarget.SetPropertyText("bEverNotFrobbed", "false");
			
			// move the box in and out based on time
			offset = (24.0 * (frobTarget.Level.TimeSeconds % 0.3));
			
			// draw a cornered targetting box
			// get the center of the object
			M = Mover(frobTarget);
			if (M != None)
			{
				M.GetBoundingBox(v1, v2, False, M.KeyPos[M.KeyNum]+M.BasePos, M.KeyRot[M.KeyNum]+M.BaseRot);
				centerLoc = v1 + (v2 - v1) * 0.5;
				v1.X = 16;
				v1.Y = 16;
				v1.Z = 16;
			}
			else
			{
				centerLoc = frobTarget.Location;
				v1.X = frobTarget.CollisionRadius;
				v1.Y = frobTarget.CollisionRadius;
				v1.Z = frobTarget.CollisionHeight;
			}
			
			ConvertVectorToCoordinates(centerLoc, boxCX, boxCY);
			
			boxTLX = boxCX;
			boxTLY = boxCY;
			boxBRX = boxCX;
			boxBRY = boxCY;
			
			// get the smallest box to enclose actor
			// modified from Scott's ActorDisplayWindow
			for (i=-1; i<=1; i+=2)
			{
				for (j=-1; j<=1; j+=2)
				{
					for (k=-1; k<=1; k+=2)
					{
						v2 = v1;
						v2.X *= i;
						v2.Y *= j;
						v2.Z *= k;
						v2.X += centerLoc.X;
						v2.Y += centerLoc.Y;
						v2.Z += centerLoc.Z;

						if (ConvertVectorToCoordinates(v2, x, y))
						{
							boxTLX = FMin(boxTLX, x);
							boxTLY = FMin(boxTLY, y);
							boxBRX = FMax(boxBRX, x);
							boxBRY = FMax(boxBRY, y);
						}
					}
				}
			}
			
			if (!frobTarget.IsA('Mover'))
			{
				boxTLX += frobTarget.CollisionRadius / 4.0;
				boxTLY += frobTarget.CollisionHeight / 4.0;
				boxBRX -= frobTarget.CollisionRadius / 4.0;
				boxBRY -= frobTarget.CollisionHeight / 4.0;
			}
			
			boxTLX = FClamp(boxTLX, margin, width-margin);
			boxTLY = FClamp(boxTLY, margin, height-margin);
			boxBRX = FClamp(boxBRX, margin, width-margin);
			boxBRY = FClamp(boxBRY, margin, height-margin);
			
			boxW = boxBRX - boxTLX;
			boxH = boxBRY - boxTLY;
			
			// scale the corner based on the size of the box
			corner = FClamp((boxW + boxH) * 0.1, 4.0, 40.0);
			
			// make sure the box doesn't invert itself
			if (boxBRX - boxTLX < corner)
			{
				boxTLX -= (corner+4);
				boxBRX += (corner+4);
			}
			if (boxBRY - boxTLY < corner)
			{
				boxTLY -= (corner+4);
				boxBRY += (corner+4);
			}
			
			// draw the drop shadow first, then normal
			gc.SetTileColorRGB(0,0,0);
			
			// Transcended - Because I didn't like it
			//-----------------------------------------------
			//MADDERS, 8/25/23: Proprietary setting, now.
			if (VMDBufferPlayer(Player) == None || VMDBufferPlayer(Player).bFrobDisplayBordersVisible)
			{
				for (i=1; i>=0; i--)
				{
					gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxTLX+i+offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxBRX+i-corner-offset, boxTLY+i+offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxBRX+i-offset, boxTLY+i+offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxTLX+i+offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxTLX+i+offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.DrawBox(boxBRX+i-corner+1-offset, boxBRY+i-offset, corner, 1, 0, 0, 1, Texture'Solid');
					gc.DrawBox(boxBRX+i-offset, boxBRY+i-corner-offset, 1, corner, 0, 0, 1, Texture'Solid');

					gc.SetTileColor(colText);
				}
			}
			
			// draw object-specific info
			if (frobTarget.IsA('Mover'))
			{
				// get the door's lock and strength info
				dxMover = DeusExMover(frobTarget);
				if (dxMover != None)
				{
					ExpandDoor = true;
					if (!dxMover.bFrobbable)
					{
						//MADDERS: Detect fake doors.
						if ((BreakableWall(DXMover) != None) || (BreakableGlass(DXMover) != None) || (DXMover.NumKeys <= 1) || ((DXMover.KeyPos[DXMover.NumKeys-1] == DXMover.KeyPos[0]) && (DXMover.KeyRot[DXMover.NumKeys-1] == DXMover.KeyRot[0])))
						{
							if ((DXMover.bBreakable) && (DXMover.bDamageRevealed))
							{
								strInfo = MsgBreakableOnly$CR();
								strInfo = StrInfo$CR()$msgDoorStr;
								if (DXMover.bBreakable)
								{
									strInfo = StrInfo$FormatString(dxMover.doorStrength * 100.0)$"%";
								}
								else
								{
									strInfo = strInfo $ msgInf;
								}
							}
							else
							{
								strInfo = MsgBarrierOnly$CR();
								strInfo = StrInfo$CR()$msgDoorStr;
								if (DXMover.bBreakable)
								{
									strInfo = StrInfo$FormatString(dxMover.doorStrength * 100.0)$"%";
								}
								else
								{
									strInfo = strInfo $ msgInf;
								}
							}
						}
						else
						{
							strInfo = msgUnusable$CR();
							if (!DXMover.bDamageRevealed)
							{
								strInfo = strInfo$CR()$"-";
							}
							else
							{
								strInfo = StrInfo$CR()$msgDoorStr;
								if (DXMover.bBreakable)
								{
									strInfo = StrInfo$FormatString(dxMover.doorStrength * 100.0)$"%";
								}
								else
								{
									strInfo = strInfo $ msgInf;
								}
							}
						}
					}
					else if ((dxMover.bLocked) && (dxMover.bFrobbable) && (dxMover.bLockRevealed))
					{
						ExpandKeyInfo = True;
						if (DXMover.KeyIDNeeded == '')
						{
							StrInfo = msgLocked @ "(" $ MsgNoKey $ ")" $ CR() $ MsgLockStr;
							KeyInfoWidthHack = -29;
						}
						else
						{
							TRing = NanoKeyRing(Player.FindInventoryType(class'Nanokeyring'));
							if ((TRing != None) && (TRing.HasKey(DXMover.KeyIDNeeded)))
							{
								StrInfo = msgLocked @ "(" $ MsgHasKey $ ")" $ CR() $ MsgLockStr;
								KeyInfoWidthHack = -26;
							}
							else
							{
								StrInfo = msgLocked @ "(" $ MsgLackingKey $ ")" $ CR() $ MsgLockStr;
								KeyInfoWidthHack = -46;
							}
						}
						
						//strInfo = msgLocked $ CR() $ msgLockStr;
						if ((dxMover.bPickable) && (DXMover.bFrobbable))
						{
							strInfo = strInfo $ FormatString(dxMover.lockStrength * 100.0) $ "%";
						}
						else
						{
							strInfo = strInfo $ msgInf;
						}
						
						if (dxMover.bDamageRevealed)
						{
							strInfo = strInfo $ CR() $ msgDoorStr;
							if (dxMover.bBreakable)
							{
								strInfo = strInfo $ FormatString(dxMover.doorStrength * 100.0) $ "%";
							}
							else
							{
								strInfo = strInfo $ msgInf;
							}
						}
						else
						{
							strInfo = strInfo$CR()$"-";
						}
					}
					else
					{
						if (DXMover.bLockRevealed) strInfo = msgUnlocked $ CR() $ "-";
						else strInfo = msgMysteryLock $ CR() $ "-";
						
						if (dxMover.bDamageRevealed)
						{
							strInfo = strInfo $ CR() $ msgDoorStr;
							if (dxMover.bBreakable)
							{
								strInfo = strInfo $ FormatString(dxMover.doorStrength * 100.0) $ "%";
							}
							else
							{
								strInfo = strInfo $ msgInf;
							}
						}
						else
						{
							strInfo = strInfo$CR()$"-";
						}
					}
				}
				else if (BarfRevealed)
				{
					ExpandDoor = false;
					
					//MADDERS: Detect fake doors.
					if (FrobTarget.IsA('CBreakableGlass'))
					{
						ExpandDoor = true;
						
						strInfo = msgMysteryLock $ CR() $ "-";
						
						strInfo = strInfo $ CR() $ msgDoorStr;
						
						//MADDERS, 4/15/21: Force 1% minimum, as 5x range is quite weird.
						//8/28/21: Also: Don't exceed 100%, because apparently HC do be like that.
						//UPDATE: Actually, don't clamp top range, because otherwise it seems like we're doing nothing.
						if (BarfBreakable)
						{
							strInfo = strInfo $ FormatString(FClamp(BarfStrength * 20.0, 1.0, 1000.0)) $ "%";
						}
						else
						{
							strInfo = strInfo $ msgInf;
						}
					}
					else if ((Mover(FrobTarget).NumKeys <= 1) || ((Mover(FrobTarget).KeyPos[Mover(FrobTarget).NumKeys-1] == Mover(FrobTarget).KeyPos[0]) && (Mover(FrobTarget).KeyRot[Mover(FrobTarget).NumKeys-1] == Mover(FrobTarget).KeyRot[0])))
					{
						strInfo = MsgBarrierOnly;
					}
					else
					{
						strInfo = msgUnusable;
					}
				}
				infoX = boxTLX + 10;
				infoY = boxTLY + 10;
				
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.GetTextExtent(0, infoW, infoH, strInfo);
				infoW += 8;
				
				//MADDERS, 12/22/20: Extend bar size.
				WidthHack = 0; //Used to be 8, but we're being smart about things now.
				WidthHack2 = WidthHack;
				infoW += WidthHack;
				
				if (ExpandDoor)
					infoW += barLength + 2;
					if (ExpandKeyInfo)
					{
						InfoW += KeyInfoWidthHack;
					}
				
				infoH += 8;
				infoX = FClamp(infoX, infoW/2+10, width-10-infoW/2);
				infoY = FClamp(infoY, infoH/2+10, height-10-infoH/2);
				
				// draw a dark background
				gc.SetStyle(DSTY_Modulated);
				gc.SetTileColorRGB(0, 0, 0);
				gc.DrawPattern(infoX, infoY, infoW, infoH, 0, 0, Texture'ConWindowBackground');
				
				// draw colored bars for each value
				if (ExpandDoor)
				{
					gc.SetStyle(DSTY_Translucent);
					if (DXMover != None)
					{
						if (DXMover.bFrobbable)
						{
							if ((DXMover.bLocked) && (DXMover.bLockRevealed))
							{
								col = GetColorScaled(dxMover.lockStrength);
								if (!DXMover.bPickable) Col = GetColorScaled(1.0);
								
								gc.SetTileColor(col);
								if ((DXMover.bPickable) && (DXMover.bFrobbable)) gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*dxMover.lockStrength, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
								else gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*1.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
							}
							else
							{
								col = GetColorScaled(0.0);
								gc.SetTileColor(col);
								gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*0.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
							}
						}
						else
						{
							col = GetColorScaled(1.0);
							gc.SetTileColor(col);
							if ((DXMover.bPickable) && (DXMover.bFrobbable))
							{
								gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*dxMover.lockStrength, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
							}
							else
							{
								gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*0.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
							}
						}
						if (DXMover.bDamageRevealed)
						{
							col = GetColorScaled(dxMover.doorStrength);
							if (!DXMover.bBreakable) Col = GetColorScaled(1.0);
							gc.SetTileColor(col);
							if (DXMover.bBreakable) gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+2*(infoH-8)/3, barLength*dxMover.doorStrength, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
							else gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+2*(infoH-8)/3, barLength*1.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
						}
						else
						{
							col = GetColorScaled(1.0);
							gc.SetTileColor(col);
							gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+2*(infoH-8)/3, barLength*0.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
						}
					}
					else
					{
						col = GetColorScaled(1.0);
						gc.SetTileColor(col);
						gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+(infoH-8)/3, barLength*1.0, ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
						
						col = GetColorScaled(FClamp(BarfStrength, 0.01, 1.0));
						if (!BarfBreakable) Col = GetColorScaled(1.0);
						gc.SetTileColor(col);
						gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+4+2*(infoH-8)/3, barLength*FClamp(BarfStrength, 0.01, 1.0), ((infoH-8)/3)-2, 0, 0, Texture'ConWindowBackground');
					}
				}
				
				// draw the text
				gc.SetTextColor(colText);
				gc.DrawText(infoX+4, infoY+4, infoW-8, infoH-8, strInfo);
				
				// draw the two highlight boxes
				gc.SetStyle(DSTY_Translucent);
				gc.SetTileColor(colBorder);
				gc.DrawBox(infoX, infoY, infoW, infoH, 0, 0, 1, Texture'Solid');
				gc.SetTileColor(colBackground);
				gc.DrawBox(infoX+1, infoY+1, infoW-2, infoH-2, 0, 0, 1, Texture'Solid');
				
				// draw the absolute number of lockpicks on top of the colored bar
				if ((dxMover != None) && (ExpandDoor) && (DXMover.bPickable) && (DXMover.bLocked))
				{
					/*numTools = int((dxMover.lockStrength / player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking')) + 0.99);
					if (numTools == 1)
						strInfo = numTools @ msgPick;
					else
						strInfo = numTools @ msgPicks;*/
					
					if (DXMover.bLockRevealed)
					{
						strInfo = GetLockReading(DXMover);
					}
					else
					{
						strInfo = "";
					}
					gc.DrawText(infoX+(infoW-barLength-2), infoY+4+(infoH-8)/3, barLength, ((infoH-8)/3)-2, strInfo);
				}
				//MADDERS: Show us what we know about a door's breakability!
				if (ExpandDoor)
				{
					if ((dxMover != None) && (DXMover.bBreakable))
					{
						if (DXMover.RevealedDamageThreshold > 0 || ((VPlayer != None) && (VPlayer.HasSkillAugment('LockpickStartStealth'))))
						{
							if (DXMover.RevealedDamageThreshold > 0)
							{
								strInfo = (DXMover.RevealedDamageThreshold*2)@msgMinDamageLabel;
							}
							else
							{
								strInfo = "?"@msgMinDamageLabel;
							}
						}
						else StrInfo = "";
						gc.DrawText(infoX+(infoW-barLength-2), infoY+4+2*(infoH-8)/3, barLength, ((infoH-8)/3)-2, strInfo);
					}
					else if (BarfBreakable)
					{
						if (BarfDamRevealed)
						{
							strInfo = BarfThreshold*2@msgMinDamageLabel;
						}
						else StrInfo = "";
						gc.DrawText(infoX+(infoW-barLength-2), infoY+4+2*(infoH-8)/3, barLength, ((infoH-8)/3)-2, strInfo);
					}
				}
			}
			else if (frobTarget.IsA('HackableDevices'))
			{
				// get the devices hack strength info
				device = HackableDevices(frobTarget);
				strInfo = player.GetDisplayName(frobTarget) $ CR() $ msgHackStr;
				
				if (device.bHackable)
				{
					if (device.hackStrength != 0.0)
					{
						strInfo = strInfo $ FormatString(device.hackStrength * 100.0) $ "%";
					}
					else
					{
						if (device.IsA('SecurityCamera') || device.IsA('AlarmUnit') || (device.IsA('AutoTurretGun')))
						{
							// If the player forced it on, tell them.
							if ((device.IsA('SecurityCamera') && SecurityCamera(device).bActive) || (device.IsA('AlarmUnit') && AlarmUnit(device).bActive) || (device.IsA('AutoTurretGun') && AutoTurret(device.Owner).bActive))
								strInfo = player.GetDisplayName(frobTarget) $ ": " $ msgHacked @ msgOn;
							else
								strInfo = player.GetDisplayName(frobTarget) $ ": " $ msgHacked @ msgOff;
						}
						else if (device.IsA('RetinalScanner'))
							strInfo = player.GetDisplayName(frobTarget);
						else
							strInfo = player.GetDisplayName(frobTarget) $ ": " $ msgHacked;
					}
				}
				else
					strInfo = strInfo $ msgInf;
				
				infoX = boxTLX + 10;
				infoY = boxTLY + 10;
				
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.GetTextExtent(0, infoW, infoH, strInfo);
				infoW += 8;
				
				//MADDERS, 12/22/20: Extend bar size.
				WidthHack = 0; //Used to be 8, but we're being smarter about this now.
				WidthHack2 = WidthHack;
				infoW += WidthHack;
				
				if (device.hackStrength != 0.0)
					infoW += barLength + 2;
				
				infoH += 8;
				infoX = FClamp(infoX, infoW/2+10, width-10-infoW/2);
				infoY = FClamp(infoY, infoH/2+10, height-10-infoH/2);
				
				// draw a dark background
				gc.SetStyle(DSTY_Modulated);
				gc.SetTileColorRGB(0, 0, 0);
				gc.DrawPattern(infoX, infoY, infoW, infoH, 0, 0, Texture'ConWindowBackground');
				
				// draw a colored bar
				if (device.hackStrength != 0.0)
				{
					gc.SetStyle(DSTY_Translucent);
					col = GetColorScaled(device.hackStrength); //if (Keypad(Device) == None) 
					if (!Device.bHackable) Col = GetColorScaled(1.0);
					//else col = GetColorScaled(1.0); 
					gc.SetTileColor(col);
					gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+infoH/2, barLength*device.hackStrength, infoH/2-6, 0, 0, Texture'ConWindowBackground'); //if (Keypad(Device) == None) 
					//else gc.DrawPattern(infoX+(infoW-barLength-4)-WidthHack2, infoY+infoH/2, barLength*1.0, infoH/2-6, 0, 0, Texture'ConWindowBackground');
				}
				
				// draw the text
				gc.SetTextColor(colText);
				gc.DrawText(infoX+4, infoY+4, infoW-8, infoH-8, strInfo);
				
				// draw the two highlight boxes
				gc.SetStyle(DSTY_Translucent);
				gc.SetTileColor(colBorder);
				gc.DrawBox(infoX, infoY, infoW, infoH, 0, 0, 1, Texture'Solid');
				gc.SetTileColor(colBackground);
				gc.DrawBox(infoX+1, infoY+1, infoW-2, infoH-2, 0, 0, 1, Texture'Solid');
				
				// draw the absolute number of multitools on top of the colored bar
				if ((device.bHackable) && (device.hackStrength != 0.0))
				{
					/*numTools = int((device.hackStrength / player.SkillSystem.GetSkillLevelValue(class'SkillTech')) + 0.99);
					if (numTools == 1)
						strInfo = numTools @ msgTool;
					else
						strInfo = numTools @ msgTools;*/
					strInfo = GetHackReading(Device);
					gc.DrawText(infoX+(infoW-barLength-2), infoY+infoH/2, barLength, infoH/2-6, strInfo);
				}
			}
			else if ((!frobTarget.bStatic) && (player.bObjectNames) && !(frobTarget.AIGETLIGHTLEVEL(frobTarget.Location) < 0.005))
			{
				// TODO: Check familiar vs. unfamiliar flags
				if (frobTarget.IsA('Pawn'))
				{
					strInfo = player.GetDisplayName(frobTarget);
				}
				else if (frobTarget.IsA('DeusExCarcass'))
				{
					strInfo = DeusExCarcass(frobTarget).VMDGetItemName();
				}
				else if (frobTarget.IsA('Inventory'))
				{
					StrInfo = Player.GetDisplayName(FrobTarget);
				}
				else if (frobTarget.IsA('DeusExDecoration'))
					strInfo = player.GetDisplayName(frobTarget);
				else if (frobTarget.IsA('DeusExProjectile'))
					strInfo = DeusExProjectile(frobTarget).itemName;
				else
					strInfo = "DEFAULT ACTOR NAME - REPORT THIS AS A BUG - " $ frobTarget.GetItemName(String(frobTarget.Class));
				
				infoX = boxTLX + 10;
				infoY = boxTLY + 10;
				
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.GetTextExtent(0, infoW, infoH, strInfo);
				infoW += 8;
				infoH += 8;
				infoX = FClamp(infoX, infoW/2+10, width-10-infoW/2);
				infoY = FClamp(infoY, infoH/2+10, height-10-infoH/2);
				
				// draw a dark background
				gc.SetStyle(DSTY_Modulated);
				gc.SetTileColorRGB(0, 0, 0);
				gc.DrawPattern(infoX, infoY, infoW, infoH, 0, 0, Texture'ConWindowBackground');
				
				// draw the text
				gc.SetTextColor(colText);
				gc.DrawText(infoX+4, infoY+4, infoW-8, infoH-8, strInfo);
				
				// draw the two highlight boxes
				gc.SetStyle(DSTY_Translucent);
				gc.SetTileColor(colBorder);
				gc.DrawBox(infoX, infoY, infoW, infoH, 0, 0, 1, Texture'Solid');
				gc.SetTileColor(colBackground);
				gc.DrawBox(infoX+1, infoY+1, infoW-2, infoH-2, 0, 0, 1, Texture'Solid');
			}
		}
	}
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;

	theme = player.ThemeManager.GetCurrentHUDColorTheme();

	colBackground = theme.GetColorFromName('HUDColor_Background');
	colBorder     = theme.GetColorFromName('HUDColor_Borders');
	colText       = theme.GetColorFromName('HUDColor_HeaderText');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     margin=70.000000
     barLength=82.000000 //MADDERS: Used to be 50, then 62, then 72, but then we cheated like a sumbitch.
     msgLocked="Locked"
     msgUnlocked="Unlocked"
     msgLockStr="Lock Str: "
     msgDoorStr="Door Str: "
     msgHackStr="Bypass Str: "
     msgInf="INF"
     msgHacked="Bypassed"
     msgPick="pick"
     msgPicks="picks"
     msgTool="tool"
     msgTools="tools"
     
     msgOn="(On)"
     msgOff="(Off)"
     msgMysteryLock="???"
     msgUnusable="Unknown"
     msgBreakableOnly="Breakable"
     msgBarrierOnly="Barrier"
     msgMinDamageLabel="damage min.?"
     msgCharacters="chars"
     
     MsgNoKey="Has No Key"
     MsgLackingKey="Key Not Owned"
     MsgHasKey="Key Owned"
}
