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
using System.Runtime.InteropServices;

namespace MetraTech.SecurityFramework
{
    [StructLayout(LayoutKind.Sequential)]
    public struct StringMatchResult
    {
        #region Public Methods

        public StringMatchResult(int index, string keyword)
        {
            mIndex = index;
            mKeyword = keyword;
        }

        public int Index
        {
            get { return mIndex; }
        }
        public string Keyword
        {
            get { return mKeyword; }
        }
        public static StringMatchResult Empty
        {
            get { return new StringMatchResult(-1, ""); }
        }

        #endregion

        #region Private Data

        private int mIndex;
        private string mKeyword;

        #endregion
    }
}
