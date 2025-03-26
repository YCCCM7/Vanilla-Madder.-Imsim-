class VMDFileFinder extends Actor native;

//native(2209) final static function FindMapFiles(string CheckDir);
//native(2209) final static function GenerateModDirectories();
native(2209) final static function bool FindFileAt(string CheckDir);
native(2198) final static function int GetLatestSaveDir(string CheckLoc);