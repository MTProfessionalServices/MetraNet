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
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
	public class ValidatorInputDataException : BadInputDataException
	{
		/// <summary>
		/// Creates an instance of the <see cref="ValidatorInputDataException"/> class specifying problem ID, source category name, error message and initial exception.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source category name.</param>
		/// <param name="message">An error message.</param>
		/// <param name="inner">An initional exception.</param>
		public ValidatorInputDataException(ExceptionId.Validator id, ValidatorEngineCategory category, string message, Exception inner)
			: base(id.ToInt(), typeof(SecurityFramework.Validator).Name, Convert.ToString(category), message, SecurityEventType.InputDataProcessingEventType, inner)
		{
		}

		/// <summary>
		/// Creates an instance of the <see cref="ValidatorInputDataException"/> class specifying problem ID, source category name, error message,
		/// input data and problem reason.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source category name.</param>
		/// <param name="message">An error message.</param>
		/// <param name="inputData">An input data.</param>
		/// <param name="reason">A problem reason.</param>
		public ValidatorInputDataException(ExceptionId.Validator id, ValidatorEngineCategory category, string message, string inputData, string reason)
			: base(
				id.ToInt(),
				typeof(SecurityFramework.Validator).Name,
				Convert.ToString(category),
				message,
				SecurityEventType.InputDataProcessingEventType,
				inputData,
				reason)
		{
		}

		/// <summary>
		/// Creates an instance of the <see cref="ValidatorInputDataException"/> class specifying problem ID, source category name, error message,
		/// input data, problem reason and initial exception.
		/// </summary>
		/// <param name="id">A problem ID.</param>
		/// <param name="category">A source category name.</param>
		/// <param name="message">An error message.</param>
		/// <param name="inputData">An input data.</param>
		/// <param name="reason">A problem reason.</param>
		/// <param name="inner">An initial exception.</param>
		public ValidatorInputDataException(
			ExceptionId.Validator id,
			ValidatorEngineCategory category,
			string message,
			string inputData,
			string reason,
			Exception inner)
			: base(
				id.ToInt(),
				typeof(SecurityFramework.Validator).Name,
				Convert.ToString(category),
				message,
				SecurityEventType.InputDataProcessingEventType,
				inputData,
				reason,
				inner)
		{
		}
	}
}