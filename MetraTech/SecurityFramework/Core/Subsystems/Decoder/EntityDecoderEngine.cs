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
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides entities translation from HTML and XML encodings.
	/// </summary>
	public class EntityDecoderEngine : DecoderTranslatorEngineBase
	{
		#region Constants

		private const string HtmlRegex = "&(?<namedEntity>({0}));{1}|&#[0]*(?<decimalCode>\\d{{1,8}});{1}|&#(x{2})[0]*(?<hexCode>[0-9a-fA-F]{{1,6}});{1}";

		#endregion

		#region Private fields

		private Dictionary<string, string> _namedEntities = new Dictionary<string, string>();
		MetraTech_KeyValuePair<string, string>[] _namedEntitiesArray;
		private string _expression;

		#endregion

		#region Properties

		/// <summary>
		/// Gets or internally sets a list of HTML named entities.
		/// </summary>
		[SerializeCollectionAttribute(ElementType = typeof(MetraTech_KeyValuePair<string, string>), ElementName = "Entity", IsRequired = true)]
		public MetraTech_KeyValuePair<string, string>[] NamedEntities
		{
			get
			{
				return _namedEntitiesArray;
			}
			private set
			{
				_namedEntities.Clear();
				_namedEntitiesArray = value;
				if (_namedEntitiesArray != null)
				{
					foreach (MetraTech_KeyValuePair<string, string> pair in _namedEntitiesArray)
					{
						_namedEntities.Add(pair.Pair.Key, pair.Pair.Value);
					}
				}
			}
		}

		/// <summary>
		/// Gets or internally sets whether a trailing semicolon is required for entities.
		/// </summary>
		[SerializePropertyAttribute]
		public bool RequireTrailingSemicolon
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or internally sets a value indicating the unicode prefixes (&#x) can be used in upper-case, i.e. &#X.
		/// </summary>
		[SerializePropertyAttribute]
		public bool EnableUnicodePrefixUppercase
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets a regular expression finding characters to translate.
		/// </summary>
		protected override string Expression
		{
			get
			{
				if (string.IsNullOrEmpty(_expression))
				{
					// Building regular expression
					StringBuilder sb = new StringBuilder();

					// Descendant sorting is used because some entity names start with other entity names.
					// Regular expressions engines checks for coincidences in the order the desired values are enlisted in the expression.
					// So, more specific values must be checked before.
					foreach (string entity in _namedEntities.Keys.OrderByDescending(p => p))
					{
						if (sb.Length > 0)
						{
							sb.Append(Constants.RegEx.Or);
						}

						sb.Append(entity);
					}

					_expression = string.Format(HtmlRegex, sb, RequireTrailingSemicolon ? string.Empty : "?", EnableUnicodePrefixUppercase ? "|X" : string.Empty);
				}

				return _expression;
			}
		}

		/// <summary>
		/// Gets or sets an engine's category.
		/// </summary>
		/// <remarks>
		/// Allowed categories are:
		/// <see cref="DecoderEngineCategory"/>.Html, <see cref="DecoderEngineCategory"/>.HtmlAttribute,
		/// <see cref="DecoderEngineCategory"/>.Xml and , <see cref="DecoderEngineCategory"/>.XmlAttribute.
		/// Defaule value is <see cref="DecoderEngineCategory"/>.Html
		/// </remarks>
		[SerializePropertyAttribute]
		protected override DecoderEngineCategory Category
		{
			[DebuggerStepThrough]
			get
			{
				return base.Category;
			}
			set
			{
				if (value != DecoderEngineCategory.Html &&
					value != DecoderEngineCategory.HtmlAttribute &&
					value != DecoderEngineCategory.Xml &&
					value != DecoderEngineCategory.XmlAttribute)
				{
					throw new SubsystemInputParamException(string.Format("Illegal category \"{0}\" is set for the engine", value));
				}
				base.Category = value;
				this.CategoryName = Convert.ToString(Category);
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the <see cref="EntityDecoderEngine"/> class.
		/// Sets an engine category to <see cref="DecoderEngineCategory"/>.Html.
		/// </summary>
		public EntityDecoderEngine()
			: base(DecoderEngineCategory.Xml)
		{
		}

		#endregion

		#region Public methods

		/// <summary>
		/// TODO: remove this method after new configuration loader implementing.
		/// </summary>
		/// <param name="engineProps"></param>
		public override void Initialize()
		{
			base.Initialize();
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Translates a found HTML entity to a corresponding character.
		/// </summary>
		/// <param name="token">A found entity.</param>
		/// <returns>A translated character.</returns>
		protected override string TranslateToken(Match token)
		{
			string result;

			try
			{
				Group g = token.Groups[Constants.RegEx.NamedEntityGroupName];
				if (g.Success)
				{
					// Named entities.
					result = _namedEntities[g.Value];
				}
				else if ((g = token.Groups[Constants.RegEx.DecimalCodeGroupName]).Success)
				{
					// Decimal entities.
					result = ParseDecimalChar(g.Value);
				}
				else // token.Groups[HexCodeGroupName].Success - it's a last available group
				{
					// Hexadecimal entities.
					g = token.Groups[Constants.RegEx.HexCodeGroupName];
					result = ParseHexChar(g.Value);
				}
			}
			catch (OverflowException)
			{
				// Some codes don't correspond to any characters.
				result = token.Value;
			}

			return result;
		}

		#endregion
	}
}
