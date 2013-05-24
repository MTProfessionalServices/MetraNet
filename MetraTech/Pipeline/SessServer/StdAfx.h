// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently,
// but are changed infrequently

#pragma once
//#using <mscorlib.dll>
#include <windows.h>
#include <metra.h>

//----- UID char array size
#define UID_SIZE 16

//----- Helper functions.
const wchar_t* MTGetUnmanagedString(System::String ^ s);
System::Object^ VariantToObject(const VARIANT & v);

//-- EOF --