#if defined(_MSC_VER)
#pragma warning( disable : 4786 ) 
#endif

#include "LexicalAddress.h"

LexicalAddressPtr nullLexicalAddress;

LexicalAddress::LexicalAddress(int offset, AccessPtr access)
{
	mOffset = offset;
	mFrameAccess = access;
}

LexicalAddressPtr LexicalAddress::create(int offset, AccessPtr access)
{
	return LexicalAddressPtr(new LexicalAddress(offset, access));
}
