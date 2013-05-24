#ifndef __RUNTIMEVALUECAST_H__
#define __RUNTIMEVALUECAST_H__

// This is a bit of a hack, since I didn't want the 
// use of COM in main RuntimeValue.h header (this is included
// in several places).
#include "MTSQLConfig.h"
#include "RuntimeValue.h"

// This actually has a COM smart pointer member so 
// I can't include it here (because I don't how to 
// forward decl a COM smart pointer).
class NameIDImpl;
class EnumConfigImpl;

// I am going to extraordinary lengths of indirection to
// keep COM out of these headers!  Some of this is "necessitated"
// by the template register machine.  Some of it is necessitated by
// the fact that I don't know how to properly forward decl a COM
// smart pointer.
class NameIDProxy
{
private:
  NameIDImpl * mImpl;
  EnumConfigImpl * mEnumConfigImpl;
  NameIDProxy(const NameIDProxy& );
  NameIDProxy& operator=(const NameIDProxy& );
public:
  MTSQL_DECL NameIDProxy();
  MTSQL_DECL ~NameIDProxy();
  MTSQL_DECL NameIDImpl* GetNameID();
  MTSQL_DECL EnumConfigImpl* GetEnumConfig();
};

class RuntimeValueCast
{
public:
  MTSQL_DECL static void ToEnum(RuntimeValue * target, const RuntimeValue * source, NameIDImpl * nameID);
  MTSQL_DECL static void ToString(RuntimeValue * target, const RuntimeValue * source, EnumConfigImpl * enumConfig);
  MTSQL_DECL static void ToWString(RuntimeValue * target, const RuntimeValue * source, EnumConfigImpl * enumConfig);
};

#endif
