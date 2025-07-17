class VMDGenericNativeFunctions extends Actor native;

//Proptype should be Package.Class.Object that declared the property. Such as Engine.Actor.Multiskins when checking a DeusExPlayer's skins.
native final static function string GetArrayPropertyText(Object RelevantObject, string PropType, int TarIndex);
native final static function bool SetArrayPropertyText(Object RelevantObject, string PropType, int TarIndex, string PropValue);
native final static function bool SwapTargetScripts(string OriginalClassAndFunction, string TargetClassAndFunction);
native final static function bool TargetScriptsAreEqual(string ClassFunctionA, string ClassFunctionB);
native final static function HexDumpScript(string ClassScript);
//native final static function ClonePawn(Pawn OriginalPawn, Pawn DuplicatePawn);
//native final static function ForceConBindEvents(Actor Binder);
native final static function SwapGNative(int TarNative, string FunctionType);

native function GNativeSwap0();