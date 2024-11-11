
// UObject interface.	
void PostLoad();

// UTexture interface.
void Init( INT InUSize, INT InVSize );
void Tick( FLOAT DeltaSeconds );
void Clear( DWORD ClearFlags );

// UScriptedMonochromeTexture interface.
void UpdatePalette();
