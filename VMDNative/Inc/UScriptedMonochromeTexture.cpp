
#include "VMDNative.h"

IMPLEMENT_CLASS(UScriptedMonochromeTexture);

// UObject interface.	
void UScriptedMonochromeTexture::PostLoad()
{
	guard(UScriptedMonochromeTexture::PostLoad);
	UpdatePalette();
	
	Super::PostLoad();
	unguard;
}

//
// UTexture interface.
//
void UScriptedMonochromeTexture::Init( INT InUSize, INT InVSize )
{
	guard(UScriptedMonochromeTexture::Init);
	check(InUSize>0);
	check(InVSize>0);
	
	// This is sadl the only widely supported format.
	Format = TEXF_P8;
	
	UTexture::Init( InUSize, InVSize );
	
	Clear( TCLEAR_Bitmap );
	unguard;
}

void UScriptedMonochromeTexture::Tick( FLOAT DeltaSeconds )
{
	guard(UScriptedMonochromeTexture::Tick);
	UpdatePalette();
	unguard;
}

void UScriptedMonochromeTexture::Clear( DWORD ClearFlags )
{
	guard(UScriptedMonochromeTexture::Clear);
	if( ClearFlags & TCLEAR_Bitmap )
	{
		for ( TLazyArray<FMipmap>::TIterator MipsIt(Mips); MipsIt; ++MipsIt )
		{
			if ( MipsIt->DataArray.Num() )
			{
				appMemset( MipsIt->DataArray.GetData(), 255, MipsIt->DataArray.Num() );;
			}
		}
	}
	unguard;
}

// UScriptedMonochromeTexture interface.
void UScriptedMonochromeTexture::UpdatePalette()
{
	guard(UScriptedMonochromeTexture::UpdatePalette);

	if ( !Palette || MonochromeColor!=Palette->Colors(255) )
	{
		// We always recreate Palette to not interfere with Palette caching of RenDevs.
		Palette = (UPalette*)StaticConstructObject( UPalette::StaticClass(), GetTransientPackage(), NAME_None, 0 );
		
		Palette->Colors.Empty( NUM_PAL_COLORS );
		Palette->Colors.Add( NUM_PAL_COLORS );
		
		for ( TArray<FColor>::TIterator ColorsIt(Palette->Colors); ColorsIt; ++ColorsIt )
		{
			*ColorsIt = MonochromeColor;
		}
		
		bRealtimeChanged = 1;
	}
	
	unguard;
}

// Natives.
void UScriptedMonochromeTexture::execInit( FFrame& Stack, RESULT_DECL )
{
	guard(UScriptedMonochromeTexture::execInit);
	P_GET_INT(InUSize);
	P_GET_INT(InVSize);
	P_FINISH;
	
	Init( InUSize, InVSize );
	unguardexec;
}

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) VMDNATIVE_API FName VMDNATIVE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

// Not needed for now.
void RegisterScrExtNames()
{
	static INT Registered=0;
	if(!Registered++)
	{
		#define NAMES_ONLY
		#define AUTOGENERATE_NAME(name) extern VMDNATIVE_API FName VMDNATIVE_##name; VMDNATIVE_##name=FName(TEXT(#name),FNAME_Intrinsic);
		#define AUTOGENERATE_FUNCTION(cls,idx,name)
		//#include "VMDNativeClasses.h"
		#undef DECLARE_NAME
		#undef NAMES_ONLY
	}
}