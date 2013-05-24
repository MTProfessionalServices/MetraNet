/**************************************************************************
* Copyright 1997-2011 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Linq;
using System.Collections.Generic;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Provides a class for all url checking engines.
	/// </summary>
	public class UrlAccessControllerEngine : AccessControllerEngineBase
	{
		private List<AccessItemUrl> _allowedUrlControllers;

		/// <summary>
		/// Gets or sets controllers collection
		/// </summary>
		[SerializeCollection(ElementName = "Item", ElementType = typeof(AccessItemUrl))]
		protected List<AccessItemUrl> Items
		{
			get;
			set;
		}

		public UrlAccessControllerEngine()
			: base(AccessControllerEngineCategory.UrlController)
		{ }

		/// <summary>
		/// Initializing members in current object.
		/// </summary>
		public override void Initialize()
		{
			if (Items == null)
			{
				throw new ConfigurationException(string.Format("Controllers collection for engine {0} in AccessController subsystem is null", Id));
			}

			_allowedUrlControllers = new List<AccessItemUrl>();
			foreach (AccessItemUrl item in Items)
			{
				if (item.AccessType == AccessType.Allowed)
				{
					_allowedUrlControllers.Add(item);
				}
			}

			base.Initialize();
		}

		/// <summary>
		/// Validates input data.
		/// </summary>
		/// <param name="inputA data to be validated."></param>
		/// <returns>A access  description to url.</returns>
		protected override ApiOutput AccesControllerExecuteInternal(ApiInput input)
		{
			string original;
			ApiOutput output = null;

			try
			{
				// Escaping the original value to check relative paths properly.
				original = Uri.EscapeUriString(input.ToString());

				Uri uri = null;

                if (Uri.IsWellFormedUriString(original, UriKind.Relative) && !Uri.IsWellFormedUriString(original, UriKind.Absolute))
				{
					output = new ApiOutput("Access is allowed");
				}
				else
				{
					uri = new Uri(original, UriKind.Absolute);
					AccessItemUrl item = null;

					foreach (AccessItemUrl controller in _allowedUrlControllers)
					{
						if (string.Compare(uri.Host, controller.Url, true, System.Globalization.CultureInfo.InvariantCulture) == 0)
						{
							item = controller;
							break;
						}
					}

					if (item == null)
					{
						throw new AccessControllerException(string.Format("Access to url {0} is denied!", uri.Host));
					}

					output = new ApiOutput(item.Description);
				}
			}
			catch (UriFormatException)
			{
				throw new AccessControllerException("Invalid url. Access is denied!");
			}

			return output;
		}
	}
}