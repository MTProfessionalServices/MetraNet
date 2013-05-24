#ifndef _LEXICALADDRESS_H_
#define _LEXICALADDRESS_H_

#include <boost/shared_ptr.hpp>
#include "MTSQLInterpreter.h"

class LexicalAddress;

typedef boost::shared_ptr<LexicalAddress> LexicalAddressPtr;

class LexicalAddress : public Access
{
private:
	AccessPtr mFrameAccess;
	int mOffset;
	LexicalAddress(int offset, AccessPtr access);

public:
	AccessPtr getFrameAccess() const
	{
		return mFrameAccess;
	}

	int getOffset() const
	{
		return mOffset;
	}

	static LexicalAddressPtr create(int offset, AccessPtr access);
};

extern LexicalAddressPtr nullLexicalAddress;

#endif
