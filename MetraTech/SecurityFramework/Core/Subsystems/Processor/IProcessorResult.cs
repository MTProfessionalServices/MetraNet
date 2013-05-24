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

using System.Collections.Generic;

namespace MetraTech.SecurityFramework
{
    public interface IProcessorResult
    {
        void GetReport();

        object GetParam(string id);
        byte[] GetBytesParam(string id);
        string GetStringParam(string id);
        int GetIntParam(string id);
        bool GetBoolParam(string id);
        string GetParamAsString(string id);
        byte[] GetParamAsBytes(string id);

        IDictionary<string, object> Params { get; }
    }
}
