//=============================================================================
// MapExit.
//=============================================================================
class MapExit extends NavigationPoint;

//
// MapExit transports you to the next map
// change bCollideActors to False to make it triggered instead of touched
//

var() string DestMap;
var() bool bPlayTransition;
var() name cameraPathTag;

var DeusExPlayer Player;

function LoadMap(Actor Other)
{
	local bool bDoNGPlus;
	local string CurMap;
	local VMDBufferPlayer VMP;
	
	// use GetPlayerPawn() because convos trigger by who's having the convo
	Player = DeusExPlayer(GetPlayerPawn());
	VMP = VMDBufferPlayer(Player);
	
	if (Player != None)
	{
		CurMap = class'VMDStaticFunctions'.Static.VMDGetMapName(Player);
		
		// Make sure we destroy all windows before sending the 
		// player on his merry way.
		DeusExRootWindow(Player.rootWindow).ClearWindowStack();
		
		//MADDERS, 4/18/24: Hacky stuff to get NG+ in nihilum.
		switch(CAPS(DestMap))
		{
			case "22_CREDITS":
			case "22_CREDITS.DX":
			case "68_ENDING_CREDITS":
			case "68_ENDING_CREDITS.DX":
			//case "70_NORTHMONROE_ENTRY":
			//case "70_NORTHMONROE_ENTRY.DX":
				bDoNGPlus = true;
			break;
			case "BEDROOM":
			case "BEDROOM.DX":
			case "BEDROOM_REMAKE":
			case "BEDROOM_REMAKE.DX":
				if (CurMap == "WAREHOUSE" || CurMap == "WAREHOUSE_REMAKE")
				{
					bDoNGPlus = true;
				}
			break;
			case "DX":
			case "DX.DX":
			case "DXONLY":
			case "DXONLY.DX":
				if (CurMap == "01_DOWNTOWNMIAMI" || CurMap == "JH1_RITTERPARK" || CurMap == "CORRUPTION2" || CurMap == "16_FATAL_WEAPON" || CurMap == "17_RESCUEEND" || CurMap == "44OUT" || CurMap == "71_CANYON")
				{
					bDoNGPlus = true;
				}
			break;
			case "HCMENU":
			case "HCMENU.DX":
				if (CurMap == "16_HOTELCARONE_INTRO")
				{
					bDoNGPlus = true;
				}
			break;
			case "21_BC_HELLSGATE_20":
			case "21_BC_HELLSGATE_20.DX":
				bDoNGPlus = true;
			break;
		}
		
		if ((bDoNGPlus) && (VMP != None))
		{
			VMP.StartNewGamePlus(Self);
		}
		else
		{
			if (bPlayTransition)
			{
				PlayTransitionPath();
				Player.NextMap = DestMap;
			}
			else
			{
				Level.Game.SendPlayer(Player, DestMap);
			}
		}
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	Super.Trigger(Other, Instigator);
	LoadMap(Other);
}

function Touch(Actor Other)
{
	//MADDERS, 4/29/25: Stupid bullshit, but turn this crap off so scouts stop triggering map exits...
	//After all, map exits are navigation points, and get touched.
	if (Scout(Other) != None)
	{
		return;
	}
	
	Super.Touch(Other);
	LoadMap(Other);
}

function PlayTransitionPath()
{
	local InterpolationPoint I;

	if (Player != None)
	{
		foreach AllActors(class 'InterpolationPoint', I, cameraPathTag)
		{
			if (I.Position == 1)
			{
				Player.SetCollision(False, False, False);
				Player.bCollideWorld = False;
				Player.Target = I;
				Player.SetPhysics(PHYS_Interpolating);
				Player.PhysRate = 1.0;
				Player.PhysAlpha = 0.0;
				Player.bInterpolating = True;
				Player.bStasis = False;
				Player.ShowHud(False);
				if ((DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).AugDisplay != None))
				{
					DeusExRootWindow(Player.RootWindow).AugDisplay.Hide();
				}
				Player.PutInHand(None);

				// if we're in a conversation, set the NextState
				// otherwise, goto the correct state
				if (Player.conPlay != None)
					Player.NextState = 'Interpolating';
				else
					Player.GotoState('Interpolating');

				break;
			}
		}
	}
}

defaultproperties
{
     Texture=Texture'Engine.S_Teleport'
     bCollideActors=True
}
