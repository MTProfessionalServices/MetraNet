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
using System.Text;

namespace MetraTech.SecurityFramework.WebInspector
{
    public class WinActionableResult
    {
        private string _ruleId = string.Empty;
        private string _fieldSource = string.Empty;
        private string _fieldName = string.Empty;
        private string _fieldValue = string.Empty;
        private string _subsystem = string.Empty;
        private string _engine = string.Empty;

        private List<string> _details = new List<string>();

        public string RuleId
        { get { return _ruleId; } }

        public string FieldSource
        { get { return _fieldSource; } }

        public string FieldName
        { get { return _fieldName; } }

        public string FieldValue
        { get { return _fieldValue; } }

        public string Subsystem
        { get { return _subsystem; } }

        public string Engine
        { get { return _engine; } }

        public List<string> Details
        { 
            get { return _details; }
            set { _details = value; }
        }

        public void AddDetail(string value)
        {
            _details.Add(value);
        }

        public bool HasDetails()
        { return (_details.Count > 0); }

        public WinActionableResult(string ruleId, string fieldSource, string fieldName, string fieldValue,string subsystem, string engine)
        {
            _ruleId = ruleId;
            _fieldSource = fieldSource;
            _fieldName = fieldName;
            _fieldValue = fieldValue;
            _subsystem = subsystem;
            _engine = engine;
        }

    }
}
