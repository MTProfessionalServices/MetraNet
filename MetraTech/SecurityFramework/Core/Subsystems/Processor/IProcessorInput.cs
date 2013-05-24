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

namespace MetraTech.SecurityFramework
{
    public interface IProcessorInput
    {
        /// <summary>
        /// SessionId is used to uniquely identify a set of related input
        /// that are part of a bigger data object composed of multiple parts.
        /// These individual parts are processed as one input object across
        /// multiple processor engine invokations
        /// </summary>
        string SessionId { get; set; }

        void AddParam(string id, object value);
        void AddBytesParam(string id, byte[] value);
        void AddStringParam(string id, string value);
        void AddIntParam(string id, int value);
        void AddBoolParam(string id, bool value);
    }
}
