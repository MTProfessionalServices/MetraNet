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
using System.Collections.Generic;

namespace MetraTech.SecurityFramework.Serialization
{
    /// <summary>
    /// Common interface for all drivers serialization
    /// </summary>
    public interface ISerializer
    {
        /// <summary>
        /// Gets path to within a directory with configuration file
        /// </summary>
		string PathToSource { get; }

        /// <summary>
        /// Deserializes an XML-document to an object of a T-type
        /// </summary>
		T Deserialize<T>(ICollection<ISerializationError> exceptions, string pathToSource) where T : new();

		/// <summary>
		/// Deserializes an XML-document to an object of baseType. This method records serialize exception to collection 
		/// </summary>
		object Deserialize(Type type, ICollection<ISerializationError> exceptions, string pathToSource);

		/// <summary>
		/// 
		/// </summary>
		/// <param name="type"></param>
		/// <param name="exceptions"></param>
		/// <param name="deserializeObject"></param>
		void Deserialize(object deserializeObject, ICollection<ISerializationError> exceptions, string pathToSource);

        /// <summary>
        /// Serializes the XML-ducument of object type T
        /// </summary>
		void Serialize(object serializeObject, string pathToSource);
    }
}
