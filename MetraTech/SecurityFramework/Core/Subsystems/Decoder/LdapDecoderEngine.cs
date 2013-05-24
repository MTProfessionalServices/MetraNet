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
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using MetraTech.SecurityFramework.Common;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides transalation from LDAP query escaping.
	/// </summary>
	public class LdapDecoderEngine : DecoderTranslatorEngineBase
	{
		#region Constants

		private const string RegexLdap =
			"(?i)(?<hexCode>(\\\\c[2-9a-f]|\\\\d[0-9a-f])\\\\[89ab][0-9a-f])|(?<hexCode>\\\\e[0-9a-f]\\\\[89ab][0-9a-f]\\\\[89ab][0-9a-f])|(?<hexCode>\\\\f[0-4]\\\\[89ab][0-9a-f]\\\\[89ab][0-9a-f]\\\\[89ab][0-9a-f])|(?<hexCode>\\\\[0-7][0-9a-f])";
		
		#endregion

		#region Properties

		/// <summary>
		/// Gets a regular expression finding characters to translate.
		/// </summary>
		protected override string Expression
		{
			get
			{
				return RegexLdap;
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="LdapDecoderEngine"/> class.
		/// </summary>
		public LdapDecoderEngine()
			: base(DecoderEngineCategory.Ldap)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Translates a found token to a corresponding character.
		/// </summary>
		/// <param name="token">A found token.</param>
		/// <returns>A translated character.</returns>
		protected override string TranslateToken(Match token)
		{
			Group g = token.Groups[Constants.RegEx.HexCodeGroupName];

			string result = HttpUtility.UrlDecode(g.Value.Replace('\\', '%'));

			return result;
		}

		#endregion
	}
}
