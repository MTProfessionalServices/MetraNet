#ifndef _STANDARDLIBRARY_H_
#define _STANDARDLIBRARY_H_

#include "MTSQLConfig.h"
#include "PrimitiveFunctionLibrary.h"


class StandardLibrary : public PrimitiveFunctionLibrary
{
private:
	std::vector<PrimitiveFunction*> mFunctions;
public:
	MTSQL_DECL StandardLibrary();

	MTSQL_DECL ~StandardLibrary();

	MTSQL_DECL std::vector<PrimitiveFunction*> getFunctions() const; 

	MTSQL_DECL void load();
};

#endif
