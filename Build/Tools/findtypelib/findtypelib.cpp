// findtypelib.cpp : Defines the entry point for the console application.
//

#include "StdAfx.h"

int main(int argc, char* argv[])
{
	if (argc < 4)
	{
		cout << "usage: findtypelib guid majorversion minorversion" << endl;
		cout << "example: findtypelib {85F994DD-986B-11D4-8754-00B0D027F749} 2b 0" << endl;
		return 1;
	}

	::CoInitialize(NULL);

	const char * asciiGuid = argv[1];

	int len = MultiByteToWideChar(
		CP_ACP,											// ANSI code page
		0,													// character-type options
		asciiGuid,									// address of string to map
		strlen(asciiGuid),					// number of bytes in string
		NULL,												// address of wide-character buffer
		0);													// size of buffer

	wchar_t * guidString = new wchar_t[len + 1];
	(void) MultiByteToWideChar(
		CP_ACP,											// ANSI code page
		0,													// character-type options
		asciiGuid,									// address of string to map
		strlen(asciiGuid),					// number of bytes in string
		guidString,									// address of wide-character buffer
		len);												// size of buffer


	guidString[strlen(asciiGuid)] = L'\0';

	GUID guid;


	HRESULT hr = CLSIDFromString(guidString,  //Pointer to the string representation of the CLSID
			&guid);  //Pointer to the CLSID

	if (FAILED(hr))
	{
		cout << "Failed: " << hex << hr << dec << endl;
		return -1;
	}

	delete [] guidString;

	const char * majorStr = argv[2];
	const char * minorStr = argv[3];
	char * end;

	unsigned short major = (unsigned short) strtol(majorStr, &end, 16);
	unsigned short minor = (unsigned short) strtol(minorStr, &end, 16);

	BSTR path;

	hr = QueryPathOfRegTypeLib( 
		guid,          
		major,  
		minor,  
		-1,             
		&path);

	if (hr == TYPE_E_LIBNOTREGISTERED)
	{
		cout << "Failed: Library not registered" << endl;
		return -1;
	}

	if (FAILED(hr))
	{
		cout << "Failed: " << hex << hr << dec << endl;
		return -1;
	}

	char asciiPath[MAX_PATH];

	BOOL usedDefault;
	char def = '?';
	int ret = WideCharToMultiByte(
		CP_ACP,            // code page
    0,            // performance and mapping flags
    path,    // wide-character string
    wcslen(path),          // number of chars in string
    asciiPath,     // buffer for new string
    sizeof(asciiPath),          // size of buffer
    &def,     // default for unmappable chars
		&usedDefault);  // set when default char used

	if (ret == 0)
	{
			cout << "Failed: " << hex << ::GetLastError() << dec << endl;
			return -1;
	}

	asciiPath[ret] = '\0';

#if 0
	// verify that the file exists
	WIN32_FIND_DATA findData;
  HANDLE findHandle = FindFirstFile(
		asciiPath,               // file name
		&findData);  // data buffer

	if (findHandle == INVALID_HANDLE_VALUE)
	{
		cout << "Failed: " << asciiPath << " does not exist" << endl;
		return -1;
	}
	FindClose(findHandle);
#endif

	ITypeLib * typeLib;
	hr = LoadTypeLib(path, &typeLib);
	if (FAILED(hr))
	{
			cout << "Failed: Unable to load type lib: (possible bad version): " << hex << hr << dec << endl;
			return -1;
	}

	TLIBATTR *libAttr;
	hr = typeLib->GetLibAttr(&libAttr);
	if (FAILED(hr))
	{
			cout << "Failed: " << hex << hr << dec << endl;
			return -1;
	}

	long libMajor = libAttr->wMajorVerNum;
	long libMinor = libAttr->wMinorVerNum;

	typeLib->ReleaseTLibAttr(libAttr);
	typeLib->Release();
	typeLib = NULL;
	
	if (libMajor != major || libMinor != minor)
	{
		cout << "Failed: version mismatch: "
				<< libMajor << "." << libMinor
				<< " != " << major << "." << minor << endl;
		return -1;
	}


	cout << asciiPath << endl;

	::CoUninitialize();
	return 0;
}
