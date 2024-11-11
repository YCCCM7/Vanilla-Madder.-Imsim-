//=============================================================================
// VMDStaticHousingFunctions.
// Store all the bullshit we don't want to deal with in housing.
//=============================================================================
class VMDStaticHousingFunctions extends VMDFillerActors abstract;

var name FoodNames[64];
var int FoodPrices[64], FoodVarieties[64];

static function int GetFoodPrice(name CheckName)
{
	local int i, Ret;
	
	if (CheckName == '') return 0;
	
	for(i=0; i<64; i++)
	{
		if (Default.FoodNames[i] == CheckName)
		{
			Ret = Default.FoodPrices[i];
			break;
		}
	}
	
	return Ret;
}

//Varieties: What does IE sound like? I dunno, just fuckin' wing it.
static function int GetFoodVarieties(name CheckName)
{
	local int i, Ret;
	
	if (CheckName == '') return 0;
	
	for(i=0; i<64; i++)
	{
		if (Default.FoodNames[i] == CheckName)
		{
			Ret = Default.FoodVarieties[i];
			break;
		}
	}
	
	return Ret;
}

defaultproperties
{
     FoodNames(0)=SodaCan
     FoodPrices(0)=100
     FoodVarieties(0)=4
     FoodNames(1)=SoyFood
     FoodPrices(1)=400
     FoodVarieties(1)=1
     FoodNames(2)=CandyBar
     FoodPrices(2)=200
     FoodVarieties(2)=2
     FoodNames(3)=Liquor40oz
     FoodPrices(3)=100
     FoodVarieties(3)=4
     FoodNames(4)=LiquorBottle
     FoodPrices(4)=200
     FoodVarieties(4)=1
     FoodNames(5)=WineBottle
     FoodPrices(5)=200
     FoodVarieties(5)=1
     FoodNames(6)=Cigarettes
     FoodPrices(6)=75
     FoodVarieties(6)=1
     FoodNames(7)=VialCrack
     FoodPrices(7)=750
     FoodVarieties(7)=1
     FoodNames(8)=VialAmbrosia
     FoodPrices(8)=7500
     FoodVarieties(8)=1
     
     FoodNames(57)=NoodleCup
     FoodPrices(57)=200
     FoodVarieties(57)=1
     FoodNames(58)=Fries
     FoodPrices(58)=200
     FoodVarieties(58)=1
     FoodNames(59)=CoffeeCup
     FoodPrices(59)=100
     FoodVarieties(59)=1
     FoodNames(60)=BurgerSodaCan
     FoodPrices(60)=100
     FoodVarieties(60)=1
     FoodNames(61)=Burger
     FoodPrices(61)=300
     FoodVarieties(61)=1
     FoodNames(62)=Beans
     FoodPrices(62)=200
     FoodVarieties(62)=1
     FoodNames(63)=KetchupBar
     FoodPrices(63)=200
     FoodVarieties(63)=1
}
