/**************************************************************************
* @doc MTSQLINTEROP
*
* @module |
*
*
* Copyright 2002 by MetraTech Corporation
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech Corporation MAKES NO
* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech Corporation,
* and USER agrees to preserve the same.
*
* Created by: Boris Partensky
*
* $Date$
* $Author$
* $Revision$
*
* @index | MTSQLINTEROP
***************************************************************************/

#ifndef _MTSQLADJUSTMENTLOGGER_H
#define _MTSQLADJUSTMENTLOGGER_H

//#ifdef WIN32
// only include this header one time
#pragma once
//#endif

#pragma unmanaged
  #include <metralite.h>
  #include <autologger.h>

#pragma managed
  #include <vcclr.h>

namespace MetraTech
{
    namespace MTSQL
    {
      
      namespace AdjustmentLog {
	      char pAdjustmentLog[] = "[MTSQL]";
      };

      MTAutoInstance<MTAutoLoggerImpl<MetraTech::MTSQL::AdjustmentLog::pAdjustmentLog> > Logger;

      System::String^ FormatArg(System::String^ format, System::String^ arg)
      {
        return System::String::Format(format, arg);
      }

      void LogAdjustmentFatal(System::String^ what)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(what);
        Logger->LogThis(LOG_FATAL, chars);
      }

      void LogAdjustmentError(System::String^ what)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(what);
        Logger->LogThis(LOG_ERROR, chars);
      }
      void LogAdjustmentWarning(System::String^ what)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(what);
        Logger->LogThis(LOG_WARNING, chars);
      }
      void LogAdjustmentDebug(System::String^ what)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(what);
        Logger->LogThis(LOG_DEBUG, chars);
      }
      void LogAdjustmentInfo(System::String^ what)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(what);
        Logger->LogThis(LOG_INFO, chars);
      }

      void LogAdjustmentFatal(const std::string& what)
      {
        Logger->LogThis(LOG_FATAL, what.c_str());
      }

      void LogAdjustmentError(const std::string& what)
      {
        Logger->LogThis(LOG_ERROR, what.c_str());
      }
      void LogAdjustmentWarning(const std::string& what)
      {
        Logger->LogThis(LOG_WARNING, what.c_str());
      }
      void LogAdjustmentDebug(const std::string& what)
      {
        Logger->LogThis(LOG_DEBUG, what.c_str());
      }
      void LogAdjustmentInfo(const std::string& what)
      {
        Logger->LogThis(LOG_INFO, what.c_str());
      }
    }  
}

#endif /* _MTSQLADJUSTMENTLOGGER_H */
