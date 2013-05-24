/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
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
* Viktor Grytsay <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Serialization.Attributes;


namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// This class is a wrapper for engines.
	/// </summary>
	public class SwitchRule : RuleBase
	{
		/// <summary>
		/// Gets or sets patterns and conditions collection.
		/// </summary>
		[SerializeCollection(IsRequired = true, DefaultType = typeof(CaseCollection), ElementType = typeof(Case), ElementName = "Case")]
		internal CaseCollection Cases
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets id next rule in chain of processor.
		/// </summary>
		protected string DefaultIdRule
		{
			get;
			private set;
		}

		/// <summary>
		/// Initialize rule-members.
		/// </summary>
		/// <param name="props"></param>
		public override void Initialize()
		{
			base.Initialize();

			if (string.IsNullOrEmpty(Cases.DefaultIdRule))
			{
				string mes = string.Format("DefaultIdRule for rule {0} is null or empty. Check configuration for processor subsystem.", Id);
				throw new ConfigurationException(mes);
			}

			DefaultIdRule = Cases.DefaultIdRule;

			if (Cases == null || Cases.Count < 1)
			{
				throw new ConfigurationException(string.Format("Case collection for rule {0} is not declared", Id));
			}

			IsInitialize = true;
		}

		/// <summary>
		/// Inhereted from <see cref="ApiInput"/> Contain original input valuu
		/// </summary>
		protected class ApiInputCase : ApiInput
		{
			public ApiInputCase(ApiInput originalInputValue, object value)
				: base(value)
			{
				OriginalInput = originalInputValue;
			}

			public ApiInputCase(ApiInput originalInputValue, object value, string format)
				: base(value, format)
			{
				OriginalInput = originalInputValue;
			}

			public ApiInput OriginalInput
			{
				get;
				protected set;
			}
		}

		/// <summary>
		/// Compares the result of the input data processing with a pattern.
		/// </summary>
		/// <param name="leftValue"></param>
		/// <param name="rightValue"></param>
		/// <param name="operationType"></param>
		/// <returns></returns>
		protected static bool Operate(string leftValue, string rightValue, OperationType operationType, ApiInputCase inputData)
		{
			bool result = false;

			switch (operationType)
			{
				case OperationType.Equal:
					result = leftValue.Equals(rightValue);
					break;
				case OperationType.NotEqual:
					result = !leftValue.Equals(rightValue);
					break;
				case OperationType.Contain:
					result = leftValue.Contains(rightValue);
					break;
				case OperationType.NotContain:
					result = !leftValue.Contains(rightValue);
					break;
				case OperationType.RegexIsMatch:
					result = Regex.IsMatch(leftValue, rightValue);
					break;
				case OperationType.RegexIsNotMatch:
					result = !Regex.IsMatch(leftValue, rightValue);
					break;
				case OperationType.IsInputOutputEqual:
					result = inputData.OriginalInput.ToString().Equals(leftValue);
					break;
				case OperationType.IsInputOutputNotEqual:
					result = !inputData.OriginalInput.ToString().Equals(leftValue);
					break;
			}

			return result;
		}

		/// <summary>
		/// Cheking input data by current engine.
		/// </summary>
		/// <param name="MetraTech.SecurityFramework.ApiInputCase">Input data</param>
		/// <param name="output">Get engine response</param>
		/// <returns>Get next rule</returns>
		protected string ExecuteCases(ApiInputCase inputData, ref ApiOutput output)
		{
			string idNextRule = DefaultIdRule;
			if (output == null)
			{
				output = new ApiOutput(inputData.OriginalInput);
			}

			for (int i = 0; i < Cases.Count; i++)
			{
				Case ruleCase = Cases[i];
				bool rez = Operate(output.ToString(), ruleCase.CompareValue, ruleCase.OperationType, inputData);
				if (rez == true)
				{
					if (ruleCase.ResultHandler != null)
					{
						output = ruleCase.ResultHandler.Execute(inputData);
					}

					idNextRule = ruleCase.IdNextRule;
					break;
				}
			}

			return idNextRule;
		}

		/// <summary>
		/// Cheking input data by current engine.
		/// </summary>
		/// <param name="input">Input data</param>
		/// <param name="output">Get engine response</param>
		/// <returns>Get next rule</returns>
		public override string Execute(ApiInput input, ref ApiOutput output)
		{
			return ExecuteCases(new ApiInputCase(input, input), ref output);
		}
	}
}
