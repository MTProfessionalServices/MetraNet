//=============================================================================
// Copyright 2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
//
// MODULE: ObjectReader.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement
{
    using System;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Xml.Serialization;

    using Constants;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// Generic XML serialization
    /// </summary>
    /// <typeparam name="T"></typeparam>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "XML"), ComVisible(false)]
    public class XMLFileSerializerHelper<T>
    {
        /// <summary>
        /// Type of object for serialization
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1051:DoNotDeclareVisibleInstanceFields")]
        public Type _type;

        /// <summary>
        /// Name of this class
        /// </summary>
        private static readonly string ClassName = "XMLFileSerializerHelper";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(string.Concat("[", ClassName, "]"));

        /// <summary>
        /// Default constructor for a T type serializer
        /// </summary>
        public XMLFileSerializerHelper()
        {
            const string methodName = "[XMLFileSerializerHelper]";
            string message;

            if (Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
            }
            try
            {
                _type = typeof (T);
            }
            finally
            {
                if (Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
                }
            }
        }

        /// <summary>
        /// Saves the object to file pointed to by path. May throw exception if unable to write file.
        /// </summary>
        /// <param name="path">path to the XML file</param>
        /// <param name="value">Object to serialize</param>
        public void Save(string path, object value)
        {
            const string methodName = "[Save]";
            string message;

            if (Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
            }
            try
            {
                using (TextWriter textWriter = new StreamWriter(path))
                {
                    var serializer = new XmlSerializer(_type);
                    serializer.Serialize(textWriter, value);
                }
            }
            finally
            {
                if (Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
                }
            }
        }

        /// <summary>
        /// Reads the file pointed to by path. Will throw exception if path does not exist, or is null
        /// </summary>
        /// <param name="path">path to the XML file</param>
        /// <returns>Deserialized object of type T</returns>
        public T Read(string path)
        {
            const string methodName = "[Read]";
            string message;
            T result;
            if (Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
            }
            try
            {
                using (TextReader textReader = new StreamReader(path))
                {
                    var deserializer = new XmlSerializer(_type);
                    // If the XML document has been altered with unknown nodes or attributes, handles them with the 
                    // UnknownNode and UnknownAttribute events.
                    deserializer.UnknownNode += new XmlNodeEventHandler(serializer_UnknownNode);
                    deserializer.UnknownAttribute += new XmlAttributeEventHandler(serializer_UnknownAttribute);

                    result = (T) deserializer.Deserialize(textReader);

                    deserializer.UnknownNode -= new XmlNodeEventHandler(serializer_UnknownNode);
                    deserializer.UnknownAttribute -= new XmlAttributeEventHandler(serializer_UnknownAttribute);
                }
            }
            finally
            {
                if (Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
                }
            }
            return result;
        }

        /// <summary>
        /// Delegate for handling unknown node types.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "serializer"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", MessageId = "1")]
        protected void serializer_UnknownNode (object sender, XmlNodeEventArgs e)
        {
            var msg = String.Concat("Unknown Node:", e.Name, "\t", e.Text);
            Logger.LogError(msg);
            throw new InvalidOperationException(msg);
        }

        /// <summary>
        /// Delegate for handling unknown attributes types.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "serializer"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", MessageId = "1")]
        protected void serializer_UnknownAttribute(object sender, XmlAttributeEventArgs e)
        {
            System.Xml.XmlAttribute attr = e.Attr;
            var msg = String.Concat("Unknown attribute ", attr.Name, "='", attr.Value, "'");
            Logger.LogError(msg);
            throw new InvalidOperationException(msg);
        }
    } 
}