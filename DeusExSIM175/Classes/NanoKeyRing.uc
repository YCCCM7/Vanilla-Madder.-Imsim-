//=============================================================================
// NanoKeyRing
//
// NanoKeyRing object.  In order to make things easier
// on the player, when the player picks up a key it's added 
// to the list of keys stored in the keyring
//=============================================================================

class NanoKeyRing extends SkilledTool;

var localized string NoKeys;
var localized string KeysAvailableLabel;

var int HandSkinIndex;

//MADDERS: Use render of overlays to show JC hands. Easy, :) Ded 4/1/07
simulated event RenderOverlays( Canvas Can )
{
	local Texture TTex;
	local bool bFemale;
	local VMDBufferPlayer VMBP;
	
 	//Object load annoying. Do this instead.
 	VMBP = VMDBufferPlayer(Owner);
	if (VMBP != None)
 	{
		bFemale = VMBP.bAssignedFemale;
	}
	
 	//Object load annoying. Do this instead.
 	if ((HandSkinIndex > -1) && (DeusExPlayer(Owner) != None) && (!VMDOwnerIsCloaked()))
 	{
  		switch (DeusExPlayer(Owner).PlayerSkin)
  		{
   			case 0: //White
				if (bFemale)
				{
					TTex = Texture'NewHand01Female';
				}
				else
				{
    					TTex = Texture'NewHand01';
				}
   			break;
   			case 1: //Black
				if (bFemale)
				{
					TTex = Texture'NewHand02Female';
				}
				else
				{
    					TTex = Texture'NewHand02';
				}
   			break;
   			case 2: //Brown
				if (bFemale)
				{
					TTex = Texture'NewHand03Female';
				}
				else
				{
    					TTex = Texture'NewHand03';
				}
   			break;
   			case 3: //Redhead
				if (bFemale)
				{
					TTex = Texture'NewHand04Female';
				}
				else
				{
    					TTex = Texture'NewHand04';
				}
   			break;
   			case 4: //Pale
				if (bFemale)
				{
					TTex = Texture'NewHand05Female';
				}
				else
				{
    					TTex = Texture'NewHand05';
				}
   			break;
  		}
  		
  		MultiSkins[HandSkinIndex] = TTex;
  		Super.RenderOverlays(Can);
  		
  		MultiSkins[HandSkinIndex] = Default.Multiskins[HandSkinIndex];
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

// ----------------------------------------------------------------------
// Networking Replication
// ----------------------------------------------------------------------

replication
{
   	//server to client function calls
   	reliable if (Role == ROLE_Authority)
      		GiveClientKey, RemoveClientKey, ClientRemoveAllKeys;
}

// ----------------------------------------------------------------------
// HasKey()
//
// Checks to see if we have the keyname passed in
// ----------------------------------------------------------------------

simulated function bool HasKey(Name KeyToLookFor)
{
	local NanoKeyInfo aKey;
	local Bool bHasKey;
	
	bHasKey = False;
	
	if (GetPlayer() != None)
	{
		aKey = GetPlayer().KeyList;
		
		// Loop through all the keys and see if one exists
		while(aKey != None)
		{
			if (aKey.KeyID == KeyToLookFor)
			{
				bHasKey = True;
				break;
			}

			aKey = aKey.NextKey;
		}
	}
	return bHasKey;
}

// ----------------------------------------------------------------------
// GiveKey()
//
// Adds a key to our array
// ----------------------------------------------------------------------

simulated function GiveKey(Name newKeyID, String newDescription)
{
	local NanoKeyInfo aKey;
	
	if (GetPlayer() != None)
	{
		// First check to see if the player already has this key
		if (HasKey(newKeyID))
			return;
		
		// Spawn a key
		aKey = GetPlayer().CreateNanoKeyInfo();
		
		// Set the appropriate fields and 
		// add to the beginning of our list
		aKey.KeyID       = newKeyID;
		aKey.Description = newDescription;
		aKey.NextKey     = GetPlayer().KeyList;
		GetPlayer().KeyList   = aKey;

	}
}

// ----------------------------------------------------------------------
// function GiveClientKey()
// ----------------------------------------------------------------------

simulated function GiveClientKey(Name newKeyID, String newDescription)
{
   	GiveKey(newKeyID, newDescription);
}

// ----------------------------------------------------------------------
// RemoveKey()
// ----------------------------------------------------------------------

simulated function RemoveKey(Name KeyToRemove)
{
	local NanoKeyInfo aKey;
	local NanoKeyInfo lastKey;

	if (GetPlayer() != None)
	{
		aKey = GetPlayer().KeyList;
			
		// Loop through all the keys and see if one exists
		while(aKey != None)
		{
			if (aKey.KeyID == KeyToRemove)
			{
				if (lastKey != None)
					lastKey.NextKey = aKey.NextKey;

				if (GetPlayer().KeyList == aKey)
					GetPlayer().KeyList = aKey.NextKey;

				CriticalDelete(aKey);
				aKey = None;

				break;
			}
			
			lastKey = aKey;
			aKey    = aKey.NextKey;
		}
	}
}

// ----------------------------------------------------------------------
// function RemoveClientKey()
// ----------------------------------------------------------------------

simulated function RemoveClientKey(Name KeyToRemove)
{
   	RemoveKey(KeyToRemove);
}

// ----------------------------------------------------------------------
// RemoveAllKeys()
// ----------------------------------------------------------------------

simulated function RemoveAllKeys()
{
	local NanoKeyInfo aKey;
	local NanoKeyInfo deadKey;
	
	if (GetPlayer() != None)
	{
		aKey = GetPlayer().KeyList;

		// Loop through all the keys and see if one exists
		while(aKey != None)
		{
			deadKey = aKey;

			CriticalDelete(aKey);
			aKey = None;

			aKey = deadKey.NextKey;
		}

		GetPlayer().KeyList = None;
	}
}

// ----------------------------------------------------------------------
// ClientRemoveAllKeys()
// ----------------------------------------------------------------------

simulated function ClientRemoveAllKeys()
{ 
   	RemoveAllKeys();
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local NanoKeyInfo keyInfo;
	local int keyCount;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName);
	winInfo.SetText(KeysAvailableLabel);
	winInfo.AddLine();

	if (GetPlayer() != None)
	{
		keyInfo = GetPlayer().KeyList;

		if (keyInfo != None)
		{
			while(keyInfo != None)
			{
				winInfo.SetText("  " $ keyInfo.Description);
				keyInfo = keyInfo.NextKey;
				keyCount++;
			}
		}
	}

	if (keyCount > 0)
	{
		winInfo.AddLine();
		winInfo.SetText(Description);
	}
	else
	{
		winInfo.Clear();
		winInfo.SetTitle(itemName);
		winInfo.SetText(NoKeys);
	}

	return True;
}

// ----------------------------------------------------------------------
// GetPlayer()
// ----------------------------------------------------------------------

simulated function DeusExPlayer GetPlayer()
{
	return DeusExPlayer(Owner);
}

// ----------------------------------------------------------------------
// GetKeyCount()
// ----------------------------------------------------------------------

simulated function int GetKeyCount()
{
	local int keyCount;
	local NanoKeyInfo aKey;

	if (GetPlayer() != None)
	{
		aKey = GetPlayer().KeyList;

		// Loop through all the keys and see if one exists
		while(aKey != None)
		{
			keyCount++;
			aKey = aKey.NextKey;
		}
	}

	return keyCount;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state UseIt
{
	function PutDown()
	{
		
	}

Begin:
	PlaySound(useSound, SLOT_None);
	PlayAnim('UseBegin',, 0.1);
	FinishAnim();
	LoopAnim('UseLoop',, 0.1);
	GotoState('StopIt');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------
state StopIt
{
	function PutDown()
	{
		
	}

Begin:
	PlayAnim('UseEnd',, 0.1);
	GotoState('Idle', 'DontPlaySelect');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     //MADDERS additions
     HandSkinIndex=0
     
     NoKeys="No Nano Keys Available!"
     KeysAvailableLabel="Nano Keys Available:"
     UseSound=Sound'DeusExSounds.Generic.KeysRattling'
     bDisplayableInv=False
     ItemName="Nanokey Ring"
     ItemArticle="the"
     PlayerViewOffset=(X=16.000000,Y=15.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.NanoKeyRingPOV'
     PickupViewMesh=LodMesh'DeusExItems.NanoKeyRing'
     ThirdPersonMesh=LodMesh'DeusExItems.NanoKeyRing'
     Icon=Texture'DeusExUI.Icons.BeltIconNanoKeyRing'
     largeIcon=Texture'DeusExUI.Icons.LargeIconNanoKeyRing'
     largeIconWidth=47
     largeIconHeight=44
     Description="A nanokey ring can read and store the two-dimensional molecular patterns from different nanokeys, and then recreate those patterns on demand."
     beltDescription="KEY RING"
     bHidden=True
     Mesh=LodMesh'DeusExItems.NanoKeyRing'
     CollisionRadius=5.510000
     CollisionHeight=4.690000
     Mass=1.000000
     Buoyancy=0.500000
}
