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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Represents a problem heppened in the Decoder subsystem.
	/// </summary>
	public class DecoderInputDataException : BadInputDataException
	{
		/// <summary>
		/// Creates an instance of the <see cref="DecoderInputDataException"/> class specifying a problem ID, source engine category and error description.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source engine category.</param>
		/// <param name="message">A error description.</param>
		public DecoderInputDataException(ExceptionId.Decoder id, DecoderEngineCategory category, string message)
			: base(id.ToInt(), typeof(SecurityFramework.Decoder).Name, Convert.ToString(category)
					, message, SecurityEventType.InputDataProcessingEventType)
		{
		}

		/// <summary>
		/// Creates an instance of the <see cref="DecoderInputDataException"/> class specifying a problem ID, source engine category, error description and
		/// an initial exception.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source engine category.</param>
		/// <param name="message">A error description.</param>
		/// <param name="inner">An initial exception.</param>
		public DecoderInputDataException(ExceptionId.Decoder id, DecoderEngineCategory category, string message, Exception inner)
			: base(id.ToInt(), typeof(SecurityFramework.Decoder).Name, Convert.ToString(category)
					, message, SecurityEventType.InputDataProcessingEventType, inner)
		{
		}

		/// <summary>
		/// Creates an instance of the <see cref="DecoderInputDataException"/> class specifying a problem ID, source engine category, error description,
		/// data causing the problem and a problem reason.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source engine category.</param>
		/// <param name="message">A error description.</param>
		/// <param name="inputData">A data causing the problem.</param>
		/// <param name="reason">A problem reason.</param>
		public DecoderInputDataException(ExceptionId.Decoder id, DecoderEngineCategory category, string message, string inputData, string reason)
			: base(id.ToInt(), typeof(SecurityFramework.Decoder).Name, Convert.ToString(category)
					, message, SecurityEventType.InputDataProcessingEventType, inputData, reason)
		{
		}

		/// <summary>
		/// Creates an instance of the <see cref="DecoderInputDataException"/> class specifying a problem ID, source engine category, error description,
		/// initial exception, data causing the problem and a problem reason.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source engine category.</param>
		/// <param name="message">A error description.</param>
		/// <param name="inner">An initial exception.</param>
		/// <param name="inputData">A data causing the problem.</param>
		/// <param name="reason">A problem reason.</param>
		public DecoderInputDataException(ExceptionId.Decoder id, DecoderEngineCategory category, string message, string inputData, string reason, Exception inner)
			: base(id.ToInt(), typeof(SecurityFramework.Decoder).Name, Convert.ToString(category)
					, message, SecurityEventType.InputDataProcessingEventType, inputData, reason, inner)
		{
		}
	}
}
