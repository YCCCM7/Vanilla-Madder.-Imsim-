class VMDFileFinder extends Actor native;

//native final static function FindMapFiles(string CheckDir);
//native final static function GenerateModDirectories();
native final static function bool FindFileAt(string CheckDir);
native final static iterator function FindNextFileAt(string SearchedDir, out string CurFile);
native final static function int GetLatestSaveDir(string CheckLoc);
native final static function bool CopyFileFrom(string CopyFrom, string CopyTo);
native final static function bool CreateFolderAt(string GenerateLocation);
native final static function string GetFileLocation(string CheckFile);