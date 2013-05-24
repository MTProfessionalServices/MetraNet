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
// MODULE: DirectorySearchTypeValue.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;

    using Constants;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// Indicates the type and value of directory search that was performed.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("5341B6A8-2E1E-417C-8E09-2BD48BD6E963")]
    public class DirectorySearchTypeValue
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "DirectorySearchTypeValue";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, DirectorySearchTypeValue.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// The Type enumeration corresponding to the directory the search was performed for.
        /// </summary>
        public Type EnumType
        {
            get;
            private set;
        }

        /// <summary>
        /// The value corresponding to the enumerated type the directory the search was performed for.
        /// </summary>
        public int TypeValue
        {
            get;
            private set;
        }

        /// <summary>
        /// Prevents a default instance of the DirectorySearchTypeValue class from being instantiated.
        /// </summary>
        private DirectorySearchTypeValue()
        {
        }

        /// <summary>
        /// Creates and initializes and instance of the DirectorySearchTypeValue class
        /// </summary>
        /// <param name="type">The enumerated directory type searched for.</param>
        /// <param name="typeValue">The value of the enumerated directory type searched for.</param>
        /// <returns>An initialized instance of the DirectorySearchTypeValue class</returns>
        public static DirectorySearchTypeValue CreateInstance(Type type, int typeValue)
        {
            const string methodName = "[CreateInstance]";
            string message = null;
            Stopwatch stopwatch = null;

            if (Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
            }

            try
            {
                if (type == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(
                            CultureInfo.CurrentCulture,
                            MessageConstants.ParameterIsNull,
                            ParameterNameConstants.Type));

                    if (Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                string typeName = type.ToString();

                switch (typeName)
                {
                    case "MetraTech.DataAccess.QueryManagement.EnumeratedTypes.DatabaseModelingTypeEnum":
                        {
                            QueryFolderEnum value = (QueryFolderEnum)typeValue;
                        }
                        break;
                    case "MetraTech.DataAccess.QueryManagement.EnumeratedTypes.DatabaseDefinitionTypeEnum":
                        {
                            DatabaseDefinitionTypeEnum value = (DatabaseDefinitionTypeEnum)typeValue;
                        }
                        break;
                    default:
                        {
                            message = string.Concat(
                                methodName,
                                string.Format(
                                    CultureInfo.CurrentCulture,
                                    MessageConstants.ParameterIsNull,
                                    ParameterNameConstants.TypeName));

                            if (Logger.WillLogFatal)
                            {
                                LogHelper.WriteLog(message, LogLevelEnum.Fatal, Logger, null);
                            }
                            throw new ArgumentException(message);
                        }
                }

                var directorySearchTypeValue = new DirectorySearchTypeValue();

                directorySearchTypeValue.EnumType = type;
                directorySearchTypeValue.TypeValue = typeValue;

                return directorySearchTypeValue;
            }
            catch (InvalidCastException invalidCastException)
            {
                message = string.Concat(
                    methodName,
                    string.Format(
                        CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNotValid,
                        ParameterNameConstants.TypeName));
                
                if (Logger.WillLogFatal)
                {
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, Logger, null);
                }
                throw new ArgumentException(message, invalidCastException);
            }
            finally
            {
                if (Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
                }
            }
        }
    }
}
