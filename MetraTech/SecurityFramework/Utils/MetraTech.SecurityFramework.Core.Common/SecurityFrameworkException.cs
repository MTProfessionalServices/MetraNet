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
using System.Runtime.Serialization;
using System.Text;


namespace MetraTech.SecurityFramework
{
	[Serializable]
    public class SecurityFrameworkException : Exception
    {
		public SecurityFrameworkException()
			: base()
		{
		}

		public SecurityFrameworkException(string message)
			: base(message)
		{
		}
		
		public SecurityFrameworkException(string message, Exception inner)
			: base(message, inner)
		{
		}
		
		protected SecurityFrameworkException(SerializationInfo info, StreamingContext context)
			: base(info, context)
		{
		}
    }
}
