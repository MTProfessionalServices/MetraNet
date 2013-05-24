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
    public interface IProcessorControlApi
    {
        void AddInputEngine(string id, IProcessorInputEngine engine);
        void RemoveInputEngine(string id);
        void RemoveAllInputEngines();

        void AddOutputEngine(string id, IProcessorOutputEngine engine);
        void RemoveOutputEngine(string id);
        void RemoveAllOutputEngines();

        bool HasInputEngineId(string id);
        string CreateInputEngineId(string prefix);
        IProcessorInputEngine CreateInputEngine();

        bool HasOutputEngineId(string id);
        string CreateOutputEngineId(string prefix);
        IProcessorOutputEngine CreateOutputEngine();

        bool HasInputSelectorId(string id);
        string CreateInputSelectorId(string prefix);
        void AddInputSelector(string id, List<string> engineIdList);
        void RemoveInputSelector(string id);
        void RemoveAllInputSelectors();

        bool HasOutputSelectorId(string id);
        string CreateOutputSelectorId(string prefix);
        void AddOutputSelector(string id, List<string> engineIdList);
        void RemoveOutputSelector(string id);
        void RemoveAllOutputSelectors();
    }
}
