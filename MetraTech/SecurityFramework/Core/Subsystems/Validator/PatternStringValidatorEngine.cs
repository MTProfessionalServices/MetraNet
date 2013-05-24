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
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Validator;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides a validation against a set of regular expressions.
	/// </summary>
	internal sealed class PatternStringValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string InputBlocked = "Input string is blocked.";

		#endregion

		#region Private fields

		private List<Regex> _allowPatterns = new List<Regex>();
		private List<Regex> _blockPatterns = new List<Regex>();
		private StringPattern[] patternParams;

		#endregion

		#region Properties

		/// <summary>
		/// Gets or sets if the patterns are treated as black list characters.
		/// </summary>
		[SerializeProperty]
		public bool BlackList
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets if the patterns are treated as white list characters.
		/// </summary>
		[SerializeProperty]
		public bool WhiteList
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a list of patterns to validates input values against.
		/// </summary>
		[SerializeCollectionAttribute]
		public StringPattern[] PatternParams
		{
			get
			{
				return patternParams;
			}
			set
			{
				patternParams = value;
				_allowPatterns.Clear();
				_blockPatterns.Clear();

				if (patternParams != null)
				{
					foreach (StringPattern pattern in patternParams)
					{
						if (string.IsNullOrEmpty(pattern.Pattern) == false)
						{
							Regex regex;
							try
							{
								regex = new Regex(pattern.Pattern, RegexOptions.Compiled);
							}
							catch (ArgumentException ex)
							{
								throw new ArgumentException(pattern.Pattern, ex);
							}

							if (pattern.Exclude)
							{
								_allowPatterns.Add(regex);
							}
							else
							{
								_blockPatterns.Add(regex);
							}
						}
					}
				}
			}
		}

		/// <summary>
		/// Gets a type of output value.
		/// </summary>
		/// <remarks>Always returns <see cref="String"/>.</remarks>
		public Type ResultType
		{
			get
			{
				return typeof(string);
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="PatternStringValidatorEngine"/> class.
		/// </summary>
		public PatternStringValidatorEngine()
			: base(ValidatorEngineCategory.PatternString)
		{
			WhiteList = true;
		}

		#endregion

		#region Public methods

		/// <summary>
		/// Performs engine initialization.
		/// </summary>
		public override void Initialize()
		{
			base.Initialize();

			if (BlackList)
			{
				WhiteList = false;
			}
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Validates an <paramref name="input"/>'s data.
		/// </summary>
		/// <param name="input">The data to be validated.</param>
		/// <returns>A validation result.</returns>
		/// <exception cref="ValidatorInputDataException">When any validation problem found.</exception>
		protected override ApiOutput ValidateInternal(ApiInput input)
		{
			// An input value passed the validation for null to this point.
			string inputStr = input.ToString();

			if (_allowPatterns.Count > 0)
			{
				foreach (Regex matcher in _allowPatterns)
				{
					if (matcher.IsMatch(inputStr))
					{
						if (WhiteList)
						{
							throw new ValidatorInputDataException(
								ExceptionId.Validator.BlockedInputString, Category, InputBlocked, input.ToString(), matcher.ToString());
						}
						else
						{
							return new ApiOutput(inputStr);
						}
					}
				}
			}

			if (_blockPatterns.Count > 0)
			{
				foreach (Regex matcher in _blockPatterns)
				{
					if (matcher.IsMatch(inputStr))
					{
						if (!WhiteList)
						{
							throw new ValidatorInputDataException(
								ExceptionId.Validator.BlockedInputString, Category, InputBlocked, input.ToString(), matcher.ToString());
						}
						else
						{
							return new ApiOutput(inputStr);
						}
					}
				}

				if (WhiteList)
				{
					throw new ValidatorInputDataException(
						ExceptionId.Validator.BlockedInputString, Category, InputBlocked, input.ToString(), "Input value does not pass the white list.");
				}
			}

			return new ApiOutput(inputStr);
		}

		#endregion
	}
}
