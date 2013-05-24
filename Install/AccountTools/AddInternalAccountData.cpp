

// import the query adapter tlb ...

#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <AccountTools.h>
#include <stdio.h>
#include <mtprogids.h>

// import the vendor kiosk tlb...
#import <MTAccount.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
using namespace MTACCOUNTLib ;

BOOL 
MTAccountTools::CreateInternalAccountSchemaAndData(const std::string& aAdapterName)
{ 
    HRESULT hr (S_OK);

	try
	{
	    // create instance
		MTACCOUNTLib::IMTAccountAdapterPtr mtptr;
		hr = mtptr.CreateInstance(MTPROGID_MTACCOUNTSERVER);
		if (!SUCCEEDED(hr))
		{
		    sprintf (mErrorString, "ERROR <%X>: unable to create instance of MTInternalAdapter object", hr);
			return (FALSE);
		}
	
		// initialize
		hr = mtptr->Initialize(_bstr_t(aAdapterName.c_str()));
		if (!SUCCEEDED(hr))
		{
		    sprintf (mErrorString, "ERROR <%X>: unable to initialize object", hr);
			return (FALSE);
		}
	
    	// create instance of mt account property collection
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr propcollptr;
		hr = propcollptr.CreateInstance(MTPROGID_MTACCOUNTPROPERTYCOLLECTION);
		if (!SUCCEEDED(hr))
		{
    		sprintf (mErrorString, "ERROR <%X>: unable to create MTAccountPropertyCollection object", hr);
			return (FALSE);
		}
	
		// set name and value
		_bstr_t name1, name2, name3, name4, name5, name6, name7;
		name1 = "id_acc";
		name2 = "tariffID";
		name3 = "accounttype";
		name4 = "taxexempt";
		name5 = "geocode";
		name6 = "timezoneID";
		name7 = "paymentmethodID";
	
		_variant_t value1, value2, value3, value4, value5, value6, value7;
		value1 = (long)123; 
		value2 = (long)1000; 
		value3 = (long)1; 
		value4 = L"Y"; 
		value5 = (long)220171040; 
		value6 = (long)18; 
		value7 = (long)1; 
	
		// add
		propcollptr->Add(name1,value1);
		propcollptr->Add(name2,value2);
		propcollptr->Add(name3,value3);
		propcollptr->Add(name4,value4);
		propcollptr->Add(name5,value5);
		propcollptr->Add(name6,value6);
		propcollptr->Add(name7,value7);
	
		// add
		hr = mtptr->AddData(_bstr_t(aAdapterName.c_str()), propcollptr);
		if (!SUCCEEDED(hr))
		{
    		sprintf (mErrorString, "ERROR <%X>: unable to do add ", hr);
			return (FALSE);
		}
	}
    catch (_com_error& e)
    {
        hr = e.Error() ;
		sprintf(mErrorString, "ERROR <%X>: caught _com_error", hr);
		return (FALSE);
    }
	
	return (TRUE);
}
