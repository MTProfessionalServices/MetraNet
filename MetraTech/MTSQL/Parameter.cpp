#pragma unmanaged
#include <MTSQLInterpreter.h>
#include <MTSQLException.h>
#include <stdutils.h>
#pragma managed
#include "Parameter.h"


namespace MetraTech
{
    namespace MTSQL
    {
      Parameter::~Parameter(void)
      {
		  delete mParam;
      }
    }
}
