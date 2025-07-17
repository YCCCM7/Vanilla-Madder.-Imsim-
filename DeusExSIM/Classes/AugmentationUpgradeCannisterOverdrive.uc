//=============================================================================
// AugmentationUpgradeCannisterOverdrive.
//
// Hey gang, WCCC here again. Confix and LDDPConfix use an illegally (forced) imported actor class that only exists in GMDX.
// Playing any mod other than GMDX causes confix to spam an error about not finding this object ALL. THE. GOD. DAMNED. TIME.
// To mitigate this, we're including this class purely as filler, so now it should shut the fuck up.
//=============================================================================
class AugmentationUpgradeCannisterOverdrive extends AugmentationUpgradeCannister;

defaultproperties
{
}
