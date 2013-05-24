#include "metra.h"
#include "SEHException.h"

void SEHException::TranslateStructuredExceptionHandlingException(unsigned int id, struct _EXCEPTION_POINTERS* ep)
{
  CallStack cs(*(ep->ContextRecord));
  switch( id ) {
    // cases classified as fatal_system_error
    case EXCEPTION_ACCESS_VIOLATION:
        throw FatalSystemErrorException(id, "memory access violation", cs);
        break;

    case EXCEPTION_ILLEGAL_INSTRUCTION:
        throw FatalSystemErrorException(id, "illegal instruction", cs);
        break;

    case EXCEPTION_PRIV_INSTRUCTION:
        throw FatalSystemErrorException(id, "privileged instruction", cs );
        break;

    case EXCEPTION_IN_PAGE_ERROR:
        throw FatalSystemErrorException(id, "memory page error", cs );
        break;

    case EXCEPTION_STACK_OVERFLOW:
        throw FatalSystemErrorException(id, "stack overflow", cs );
        break;

        // cases classified as (non-fatal) system_trap
    case EXCEPTION_DATATYPE_MISALIGNMENT:
        throw NonFatalSystemErrorException(id, "data misalignment", cs );
        break;

    case EXCEPTION_INT_DIVIDE_BY_ZERO:
        throw IntegerOperationException(id, "integer divide by zero", cs );
        break;

    case EXCEPTION_INT_OVERFLOW:
        throw IntegerOperationException(id, "integer overflow", cs );
        break;

    case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:
        throw NonFatalSystemErrorException(id, "array bounds exceeded", cs );
        break;

    case EXCEPTION_FLT_DIVIDE_BY_ZERO:
        throw FloatingPointOperationException(id, "floating point divide by zero", cs );
        break;

    case EXCEPTION_FLT_STACK_CHECK:
        throw FloatingPointOperationException(id, "floating point stack check", cs );
        break;

    case EXCEPTION_FLT_DENORMAL_OPERAND:
    case EXCEPTION_FLT_INEXACT_RESULT:
    case EXCEPTION_FLT_INVALID_OPERATION:
    case EXCEPTION_FLT_OVERFLOW:
    case EXCEPTION_FLT_UNDERFLOW:
        throw FloatingPointOperationException(id, "floating point underflow", cs );
        break;

    default:
        throw NonFatalSystemErrorException(id, "unrecognized exception or signal", cs );
        break;
    }  // switch
}

