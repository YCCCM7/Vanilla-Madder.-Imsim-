class VMDPathRebuilder extends Actor native;

native final function AllowScoutToSpawn();
native final function ScoutSetup(Pawn Scout);
native final function RedefinePaths();

//Hacky debugging.
native final static function int BeginShakedown(Object TestObject);
native final static function int EndShakedown(Object TestObject, int LastState);

function FuckPreBeginPlay()
{
	bHidden = true;
	DrawType = DT_None;
}