//=============================================================================
// GraftedComputerSecurity.
//=============================================================================
class GraftedComputerSecurity extends Computers;

var() string nodeAddress;

struct sViewInfo
{
	var() localized string	titleString;
	var() name				cameraTag;
	var() name				turretTag;
	var() name				doorTag;
};

var() sViewInfo Views[3];
