#ifndef _INCLUDE_MS_DATA_PROTECTOR_H_
#define _INCLUDE_MS_DATA_PROTECTOR_H_

#include "AppObject.h"

class CMsDataProtector : public CAppObject
{
public:
	CMsDataProtector();
	~CMsDataProtector();

    static string Encrypt(const string& data);
	static string Decrypt(const string& data);
};

#endif
