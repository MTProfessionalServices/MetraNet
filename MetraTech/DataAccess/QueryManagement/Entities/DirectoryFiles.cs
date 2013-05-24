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
// MODULE: DirectoryFiles.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;

    using Constants;
    using EnumeratedTypes;
    using Helpers;
    
    /// <summary>
    /// Class with the directory name and the files within the directory.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("5C8355A4-41EF-4790-86B2-E170FEB6D3ED")]
    public class DirectoryFiles
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "DirectoryFiles";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, DirectoryFiles.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// The folder the files were looked for from.
        /// </summary>
        public string BaseFolder
        {
            get;
            private set;
        }

        /// <summary>
        /// Array of files within this directory.
        /// </summary>
        public string [] Files
        {
            get;
            private set;
        }

        /// <summary>
        /// Prevents a default instance of the DirectoryFiles class from being instantiated.
        /// </summary>
        private DirectoryFiles()
        {
        }

        /// <summary>
        /// Initializes a new instance of the DirectoryFiles class.
        /// </summary>
        /// <param name="searchPath">The folder the files were searched for within.</param>
        /// <param name="files">The array of files within the directory.</param>
        public static DirectoryFiles CreateInstance(string searchPath, string[] files)
        {
            const string methodName = "[CreateInstance]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DirectoryFiles.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DirectoryFiles.Logger, null);
            }

            try
            {
                if (string.IsNullOrEmpty(searchPath))
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, ParameterNameConstants.SearchPath));

                    if (DirectoryFiles.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, DirectoryFiles.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                if (files == null)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, ParameterNameConstants.Files));

                    if (DirectoryFiles.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, DirectoryFiles.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                // empty array check ?

                // Log parameter values
                if (DirectoryFiles.Logger.WillLogDebug)
                {
                    message = string.Concat(
                        methodName,
                        MessageConstants.DoubleQuotes,
                        searchPath,
                        MessageConstants.DoubleQuotes);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, DirectoryFiles.Logger, null);
                }

                var directoryFiles = new DirectoryFiles();
                directoryFiles.BaseFolder = searchPath;
                directoryFiles.Files = files;
                
                return directoryFiles;
            }
            finally
            {
                // Trace Logging
                if (DirectoryFiles.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DirectoryFiles.Logger, null);
                }
            }
        }
    }
}
