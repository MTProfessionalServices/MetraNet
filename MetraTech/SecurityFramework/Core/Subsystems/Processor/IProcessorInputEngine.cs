/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;

namespace MetraTech.SecurityFramework
{
    public interface IProcessorInputEngine
    {
        void RequireParam(string id, Type paramType);
        void RequireBytesParam(string id);
        void RequireStringParam(string id);
        void RequireIntParam(string id);
        void RequireBoolParam(string id);

        bool ReportSecurityEvents { get; set; }

        void ActivateDecodeAction(string engineId);
        void ActivateDecryptAction(Dictionary<string,object> cryptoParams);

        void AddValidateAction(string id,bool idIsCategory,Dictionary<string,object> validatorParams);

        void AddDetectAction(string engineId);

        IProcessorResult Process(IProcessorInput input);
        //KCQ NEW NOTE: (don't have shortcut support in engines)
        //IF THE API USES WANT SHORTCUTS THEN THEY WILL HAVE
        //TO USE EXTENSION APIs
        //bool ProcessString(string input, out string result);
        //bool ProcessInt(string input, out int result);
    }
}
