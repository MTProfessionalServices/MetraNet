
#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <UsageInterval.h>
#include <DBConstants.h>
#include <mtprogids.h>
#import <MTProductView.tlb> rename ("EOF", "EOFX")

extern MTAutoInstance<InstallLogger> g_Logger;

LONG InstCallConvention CreateBuckets()
{
	// create all the product views
	try {
		MTPRODUCTVIEWLib::IMTProductViewOpsPtr pvops(MTPROGID_MTPRODUCTVIEWOPS);
		pvops->AddAllProductViews();
	}
	catch(...) {
		return FALSE;
	}

  return TRUE;
}
