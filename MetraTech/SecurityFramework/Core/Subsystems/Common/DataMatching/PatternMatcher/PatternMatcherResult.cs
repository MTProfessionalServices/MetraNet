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

namespace MetraTech.SecurityFramework
{
    public class PatternMatchResult
    {
        #region Public Methods

        public PatternMatchResult(int index, int length, string data)
        {
            mIndex = index;
            mLength = length;
            mData = data;
        }

        public int Index
        {
            get { return mIndex; }
        }
        public int Length
        {
            get { return mLength; }
        }
        public string Data
        {
            get { return mData; }
        }

        #endregion

        #region Private Data

        private int mIndex = -1;
        private int mLength = -1;
        private string mData = null;

        #endregion
    }
}
