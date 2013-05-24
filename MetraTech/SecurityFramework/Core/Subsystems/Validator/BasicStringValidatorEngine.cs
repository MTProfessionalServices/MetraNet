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
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Validator;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides validation for plain text.
	/// </summary>
	internal sealed class BasicStringValidatorEngine : ValidatorEngineBase
	{
		#region Private fields

		private HashSet<char> _charSet = new HashSet<char>();

		#endregion

		#region Properties

		/// <summary>
		/// Gets or sets a min allowed text length.
		/// </summary>
		[SerializeProperty]
		public uint MinLength
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a max allowed text length.
		/// </summary>
		[SerializeProperty]
		public uint MaxLength
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a sharacters set to use for filtering.
		/// </summary>
		[SerializeProperty]
		public string CharSet
		{
			get
			{
				return _charSet != null ? new string(_charSet.ToArray()) : null;
			}
			private set
			{
				_charSet = value != null ? new HashSet<char>(value.ToCharArray()) : null;
			}
		}

		/// <summary>
		/// Gets or sets if the CharSet property's value is treated as black list characters.
		/// </summary>
		[SerializeProperty]
		public bool BlackList
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets if the CharSet property's value is treated as white list characters.
		/// </summary>
		[SerializeProperty]
		public bool WhiteList
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a value indicating to remove leading and trailing spaces.
		/// </summary>
		[SerializeProperty(DefaultValue = false)]
		public bool TrimInput
		{
			get;
			private set;
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
		/// Creates an instance of the <see cref="BasicStringValidatorEngine"/> class.
		/// </summary>
		public BasicStringValidatorEngine()
			: base(ValidatorEngineCategory.BasicString)
		{
			MaxLength = uint.MaxValue;
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

		#region Protected metehods

		/// <summary>
		/// Performs the validation of input value.
		/// </summary>
		/// <param name="input">A data to be validated.</param>
		/// <returns>Validation result.</returns>
		/// <exception cref="ValidatorInputDataException">When any validation problem found.</exception>
		/// <exception cref="NullInputDataException">When input contains null.</exception>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null || input.Value == null)
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			return ValidateInternal(input);
		}

		/// <summary>
		/// Performs the validation of input value.
		/// </summary>
		/// <param name="input">A data to be validated.</param>
		/// <returns>Validation result.</returns>
		/// <exception cref="ValidatorInputDataException">When any validation problem found.</exception>
		protected override ApiOutput ValidateInternal(ApiInput input)
		{
			// An input value passed the validation for null to this point.
			string inputStr = TrimInput ? input.ToString().Trim() : input.ToString();

			int inputLen = inputStr.Length;
			if (inputLen == 0 && MinLength != 0)
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.EmptyStringNotAllowed,
					Category,
					"Empty string is not allowed.",
					inputStr,
					String.Format("minLenght of input string is {0}", MinLength));
			}

			if (inputLen < MinLength || inputLen > MaxLength)
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.InputStringNotRange,
					Category,
					"Input string is not in range.",
					inputStr,
					String.Format("minLenght = {0}, maxLenght = {1}; {0} < inputString < {1}", MinLength, MaxLength));
			}

			if (_charSet != null && _charSet.Count > 0)
			{
				if (WhiteList)
				{
					for (int i = 0; i < inputLen; i++)
					{
						if (!_charSet.Contains(inputStr[i]))
							throw new ValidatorInputDataException(
								ExceptionId.Validator.BlockedInputString,
								Category,
								"Input string is blocked.",
								inputStr,
								string.Format("White list violation. Invalid character: {0}", inputStr[i]));
					}
				}
				else
				{
					for (int i = 0; i < inputLen; i++)
					{
						if (_charSet.Contains(inputStr[i]))
							throw new ValidatorInputDataException(
								ExceptionId.Validator.BlockedInputString,
								Category,
								"Input string is blocked.",
								inputStr,
								string.Format("Black list violation. Invalid character: {0}", inputStr[i]));
					}
				}
			}

			ApiOutput result = new ApiOutput(inputStr);

			return result;
		}

		#endregion
	}
}