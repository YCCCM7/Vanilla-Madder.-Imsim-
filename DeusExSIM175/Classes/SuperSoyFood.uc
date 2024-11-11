//=============================================================================
// SuperSoyFood.
//=============================================================================
class SuperSoyFood extends SoyFood;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;
		
		Super(DeusExPickup).BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
		{
			//There is literally nothing addicting about soyfood.
			if (VMDBufferPlayer(Player) != None) VMDBufferPlayer(Player).VMDRegisterFoodEaten(4, "Soy Food");
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType=""
     SmellUnits=0
     
     maxCopies=50
     ItemName="Super Soy Food"
     Description="No smell profile. This is a 'sorry' for making you deal with a mod that was not prepared for food."
     beltDescription="SUPER SOY"
}
