class VMDGenericNativeFunctions extends Actor native;

//Proptype should be Package.Class.Object that declared the property. Such as Engine.Actor.Multiskins when checking a DeusExPlayer's skins.
native(2197) final static function string GetArrayPropertyText(Object RelevantObject, string PropType, int TarIndex);
native(2196) final static function bool SetArrayPropertyText(Object RelevantObject, string PropType, int TarIndex, string PropValue);
native(2195) final static function bool SwapTargetScripts(string OriginalClassAndFunction, string TargetClassAndFunction);