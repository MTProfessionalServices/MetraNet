#include <lcheck.h>

MTLocalizationCheck::MTLocalizationCheck(const char *charLangCode, const char *charPVFName, const char *charLFName)
{
	if (charLangCode == NULL)
		lang_code = _bstr_t("");
	else
		lang_code = _bstr_t(charLangCode);
	productview_fname = _bstr_t(charPVFName);
	locale_fname = _bstr_t(charLFName);
	host_name = _bstr_t("");
	
	// Find relative path for product view config directory.
	mRelativePath = _bstr_t("");
	wchar_t *aPath = (wchar_t*)(productview_fname.copy());
	wchar_t *token = wcstok(aPath, L"\\");
	while (token != NULL) {
		if (wcsstr(token, L".xml") == NULL)
			mRelativePath += _bstr_t(token) + _bstr_t("\\");
		token = wcstok(NULL, L"\\");
	}
}

// Similar to IsLeaf as defined for LocaleConfigLib but works
// on a product view xml tree.
bool MTLocalizationCheck::IsLeaf(MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
	ASSERT(aPropSet != NULL);
	
	bool bResult = (aPropSet->NextWithName("filename") == NULL) ? true : false;
	if (bResult) {
		aPropSet->Reset();
		bResult = (aPropSet->NextWithName("msixdef") == NULL) ? bResult : false;
	}
	aPropSet->Reset();
	return bResult;
}

bool MTLocalizationCheck::RecurseAndPopulate(_bstr_t& aPath, FQNCollection& FQNList)
{
	MTConfigLib::IMTConfigPropSetPtr aPropSet;
	MTConfigLib::IMTConfigPropPtr file = NULL;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	MTConfigLib::IMTConfigPropSetPtr iterPropSet;
	VARIANT_BOOL checksumMatch;
	
	// Read the XML file at aPath to get the propset for it.
	try
	{
		aPropSet = config->ReadConfiguration(aPath, &checksumMatch);
	}
	catch(_com_error err)
	{
		cerr << "lcheck: Error with COM, " << err.ErrorMessage() << "\n";
		return false;
	}
	
	// Detect if we are a leaf or not.
	if(MTLocalizationCheck::IsLeaf(aPropSet)) {
		ASSERT(aPath != _bstr_t(""));
		
		// Iterate across all of the ptype property sets,
		// constructing a FQN from the dn tag.
		_bstr_t localeName;
		_bstr_t nameStr;
		try
		{
			localeName = (aPropSet->NextWithName("name"))->GetValueAsString();
		}
		catch(_com_error err)
		{
			cerr << "lcheck: Malformed XML input file, 1.\n";
			return false;
		}
		try
		{
			while ((iterPropSet = aPropSet->NextSetWithName("ptype")) != NULL)
			{
				nameStr = _bstr_t(localeName.copy()) +
					_bstr_t("/") +
					(iterPropSet->NextWithName("dn"))->GetValueAsString();
				FQNList.push_back(nameStr);
			}
		}
		catch(_com_error err)
		{
			cerr << "lcheck: Malformed XML input file, 2.\n";
			return false;
		}
	}
	else {

		// Iterate through the files and call RecurseAndPopulate
		while ((file = aPropSet->NextWithName("filename")) != NULL)
		{
			_bstr_t fileName = mRelativePath + file->GetValueAsString();

			if (!MTLocalizationCheck::RecurseAndPopulate(fileName, FQNList))
				return false;
		}
		aPropSet->Reset();
		while ((file = aPropSet->NextWithName("msixdef")) != NULL)
		{
			_bstr_t fileName = mRelativePath + file->GetValueAsString();

			if (!MTLocalizationCheck::RecurseAndPopulate(fileName, FQNList))
				return false;
		}
	}

	return true;
}

bool MTLocalizationCheck::Check()
{
	FQNCollection productviewFQNs;
	MTLOCALECONFIGLib::ILocaleConfigPtr localeConfig;
	MTLOCALECONFIGLib::IMTLocalizedCollectionPtr collection;
	if (FAILED(localeConfig.CreateInstance(MTPROGID_LOCALE_CONFIG)))
	{
		cerr << "lcheck: Allocation of memory failed.\n";
		return false;
	}

	if (!MTLocalizationCheck::RecurseAndPopulate(productview_fname, productviewFQNs))
		return false;

  // Initialize w/ location of localization masterfile.
	if (FAILED(localeConfig->InitializeWithFileName(locale_fname, host_name))) {
		cerr << "lcheck: If at first you don't succeed, try, try again.\n";
		return false;
	}
	try
	{
		// Read configuration from file.
		if (FAILED(localeConfig->LoadLanguage(lang_code)))
		{
			cerr << "lcheck: Failed to read configuration file.\n";
			return false;
		}
	}
	catch (_com_error err)
	{
		cerr << "lcheck: Failed to read configuration file.\n";
		return false;
	}

	// Get localized collection from configuration
	collection = localeConfig->GetLocalizedCollection();
	
	try
	{
		FQNCollection::iterator iterFQNcoll = productviewFQNs.begin();
		while(iterFQNcoll != productviewFQNs.end())
		{
			if (FAILED(collection->Begin())) {
				cerr << "lcheck: Failed to reset collection.\n";
				return false;
			}
			while(!collection->End())
			{
				if (_stricmp((char*)(collection->GetFQN()), (char*)(*iterFQNcoll)) == 0)
				break;
				collection->Next();
			}
			// If you get this far and they aren't equal, there is
			// a missing locale entry.
			if (_stricmp((char*)(collection->GetFQN()), (char*)(*iterFQNcoll)) != 0) {
				mMissingEntries.push_back(lang_code + _bstr_t("\t\t") + *iterFQNcoll);
			}
			iterFQNcoll++;
		}
	}
	catch(_com_error& err)
	{
		cerr << "lcheck: Language not supported. Error:<" << (const char*)err.Description() << ">" << endl;
		return false;
	}
	return true;
}

bool MTLocalizationCheck::Output()
{
  // Print instruction blurb
	FQNCollection::iterator iterMissingEntries = mMissingEntries.begin();
	if (iterMissingEntries == mMissingEntries.end()) {
		cout << "No missing entries found.\n";
		return true;
	}
	
	// Iterate through localized entries in missingEntries
	cout << "Language\tFQN\n--------\t---\n";
	while (iterMissingEntries != mMissingEntries.end()) {
		// Print FQN to stdout
		cout << (char*)(*iterMissingEntries) << "\n";		
		iterMissingEntries++;
	}
	
	return true;
}

int main(int argc, char **argv)
{
	// Check parameters.

	char *lang = NULL;
	char *pvfname = NULL;
	char *lfname = NULL;
	if (argc == 4) {
		lang = argv[1];
		pvfname = argv[2];
		lfname = argv[3];
	} else {
		cerr << "lcheck: Incorrect parameters.\n";
		cerr << "Type 'lcheck language-code product-view-file localization-file-name'\n";
		return -1;
	}
	
	cout << "lcheck:\nChecking localization entries for: ";
	cout << lang << " LANGUAGE\n";
	cout << "In product view: " << pvfname << "\n";
	cout << "In localization file: " << lfname << "\n";
	
	// Initialize MTLocalizationCheck object.
	::MTLocalizationCheck *localizationCheck = new ::MTLocalizationCheck(lang, pvfname, lfname);
	
	// Run Check.
	if (!localizationCheck->Check())
		return -1;
	
	// Output.
	localizationCheck->Output();
	delete localizationCheck;
	
	return 0;
}
