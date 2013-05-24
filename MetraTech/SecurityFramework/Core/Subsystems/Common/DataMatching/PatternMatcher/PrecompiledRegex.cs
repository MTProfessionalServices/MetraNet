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
using System.Linq;
using System.Text;
using System.Reflection;
using System.Text.RegularExpressions;

namespace MetraTech.SecurityFramework
{
    public class PrecompiledRegex
    {
        public PrecompiledRegex(Type type)
        {
            mType = type;
            mImpl = Activator.CreateInstance(mType);
        }

        public bool IsMatch(string input, int position)
        {
            Object[] args = { input, position };

            object result = mType.InvokeMember("IsMatch",
                          BindingFlags.Default | BindingFlags.InvokeMethod,
                               null,
                               mImpl,
                               args);

            return (bool)result;
        }

        public Match Match(string input, int position)
        {
            Object[] args = { input, position };

            object result = mType.InvokeMember("Match",
                          BindingFlags.Default | BindingFlags.InvokeMethod,
                               null,
                               mImpl,
                               args);

            return (Match)result;
        }

        public MatchCollection Matches(string input, int position)
        {
            Object[] args = { input, position };

            object result = mType.InvokeMember("Matches",
                          BindingFlags.Default | BindingFlags.InvokeMethod,
                               null,
                               mImpl,
                               args);

            return (MatchCollection)result;
        }

        private object mImpl = null;
        private Type mType = null;
    }
}
