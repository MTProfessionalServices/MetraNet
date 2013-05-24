/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
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
* Your Name <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Serialization
{
	/// <summary>
	/// A class for working with XML-serialization
	/// </summary>
	public sealed class XmlSerializer : SerializeSelector
	{
		#region Private fields

		private XDocument _document;

		#endregion

		#region Constructors

		public XmlSerializer() : base() { }

		#endregion

		#region Protected methods

		protected override void Load()
		{
			if (!File.Exists(PathToSource))
			{
				throw new SerializationException(string.Format("File {0} does not exist!", PathToSource));
			}

			using (Stream baseStream = File.Open(PathToSource, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				_document = XDocument.Load(baseStream, LoadOptions.None);
			}
		}

		protected override void Save(ObjectReflector reflector)
		{
			XDocument doc = new XDocument();
			doc.Add(CreateElement(reflector));

			if (!File.Exists(PathToSource))
			{
				File.Create(PathToSource);
			}

			using (FileStream str = File.Open(PathToSource, FileMode.Truncate, FileAccess.ReadWrite, FileShare.ReadWrite))
			{
				doc.Save(str);
			}
		}

		protected override ObjectReflector GetReflector(string elementName)
		{
			if (string.IsNullOrEmpty(elementName))
			{
				throw new SerializationException("Element name in xml document is null or empty!");
			}

			XElement parentElement = _document.Element(elementName);
			if (parentElement == null)
			{
				throw new SerializationException(string.Format("Element name {0} in xml document does not exist!", elementName));
			}

			return CreateReflector(parentElement);
		}

		#endregion

		#region Private methods

		private XElement CreateElement(ObjectReflector reflector)
		{
			XElement element = new XElement(reflector.Name);

			foreach (KeyValuePair<string, string> pair in reflector.ValueProps)
			{
				XAttribute attribute = new XAttribute(pair.Key, pair.Value);
				element.Add(attribute);
			}

			foreach (ObjectReflector childReflector in reflector.CompositeProps)
			{
				XElement childElement = CreateElement(childReflector);
				element.Add(childElement);
			}

			return element;
		}

		private ObjectReflector CreateReflector(XElement parentElement)
		{
			ObjectReflector reflector = new ObjectReflector();
			try
			{
				reflector.Name = parentElement.Name.ToString();
				IEnumerable<XAttribute> attributes = parentElement.Attributes();
				foreach (XAttribute attribute in attributes)
				{
					reflector.ValueProps.Add(attribute.Name.ToString(), attribute.Value);
				}
				foreach (XElement element in parentElement.Elements())
				{
					if (element.Elements().Count() != 0)
					{
						
					}

					if (!string.IsNullOrEmpty(element.Value) && element.Elements().Count() == 0)
					{
						reflector.ValueProps.Add(element.Name.ToString(), element.Value.ToString());
					}
					else
					{
						ObjectReflector childReflector = CreateReflector(element);
						reflector.CompositeProps.Add(childReflector);
					}
				}
			}
			catch (Exception e)
			{
				throw new SerializationException("Xml document contains error or corrupted!", e);
			}

			return reflector;
		}

		#endregion
	}
}
