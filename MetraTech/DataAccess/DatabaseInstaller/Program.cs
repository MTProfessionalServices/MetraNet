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
// MODULE: Program.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;

    using Business.Logic;
    using Constants;
    using Entities;

    using MetraTech;
    using MetraTech.DataAccess.QueryManagement;
    using MetraTech.DataAccess.QueryManagement.Helpers;
    using MetraTech.DataAccess.QueryManagement.EnumeratedTypes;

    /// <summary>
    /// The Program Class Of This Console Application
    /// </summary>
    internal class Program
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "Program";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger mtLogLogger =
            new Logger(
                string.Concat(
                    MessageConstants.BracketOpen,
                    Program.ClassName,
                    MessageConstants.BracketClose));

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, Program.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// Local instance of the parsed arguments passed to this instance of the program
        /// </summary>
        private static ProgramArguments Arguments = new ProgramArguments();

        /// <summary>
        /// Dictionary of Query Install Parameters
        /// </summary>
        private static QueryInstallParameters QueryInstallParameters;

        /// <summary>
        /// Handles any unhandled exceptions and 
        /// </summary>
        /// <param name="sender">The sender of the event</param>
        /// <param name="e">The evnet arguments</param>
        internal static void AppDomainUnhandledExceptionHandler(object sender, UnhandledExceptionEventArgs e)
        {
            const string methodName = "[AppDomainUnhandledExceptionHandler]";
            Program.mtLogLogger.LogDebug(string.Concat(methodName, " - Enter"));

            try
            {
                Program.mtLogLogger.LogFatal(string.Concat(methodName, " Domain Level Unhandled Exception Handler Triggered [IsTerminating=", (e.IsTerminating == true ? "true" : "false"), "]"));

                var exception = e.ExceptionObject as Exception;
                if (exception != null)
                {
                    Program.mtLogLogger.LogFatal(
                        string.Concat(
                            methodName, 
                            "  Exception:  ",
                            string.IsNullOrEmpty(exception.Message) ? " Exception is null or empty." : exception.Message, 
                            "  StackTrace:  ",
                            string.IsNullOrEmpty(exception.StackTrace) ? " Exception is null or empty." : exception.StackTrace));

                    if (exception.InnerException != null)
                    {
                        Program.mtLogLogger.LogFatal(
                            string.Concat(
                                methodName,
                                "  Exception:  ",
                                string.IsNullOrEmpty(exception.InnerException.Message) ? " InnerException is null or empty." : exception.InnerException.Message,
                                "  StackTrace:  ",
                                string.IsNullOrEmpty(exception.InnerException.StackTrace) ? " InnerException is null or empty." : exception.InnerException.StackTrace));
                    }
                }
                else
                {
                    Program.mtLogLogger.LogFatal(string.Concat(methodName, "Domain Level Unhandled Exception Handler Exception Is Null."));
                }
            }
            catch(Exception exception)
            {
                var msg = string.Concat(methodName, "Exception occurred:  ", exception.Message);
                Program.mtLogLogger.LogFatal(msg);
                Console.WriteLine(msg);
            }
            finally
            {
                Program.mtLogLogger.LogDebug(string.Concat(methodName, " - Exit"));
            }
        }

        /// <summary>
        /// The main function
        /// </summary>
        /// <param name="args">The arguments passed to the program by the caller.</param>
        /// <returns>Zero for success or One for failure.</returns>
        private static int Main(string[] args)
        {
            const string methodName = "[Main]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(Program.AppDomainUnhandledExceptionHandler);

            // Trace Logging
            if (Program.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
            }

            try
            {
                //// Parse program arguments
                //// Execute based on program arguments
                if (args.Length == 0)
                {
                    message = "No arguments passed to this program.  Exiting this program.";
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, Program.Logger, null);
                    Console.WriteLine(string.Concat("\n", message));
                    Program.PrintUsage();
                    return 1;
                }

                Program.ParseArguments(args);
                Program.QueryInstallParameters = new QueryInstallParameters(Program.Arguments);
                var databaseInstaller = DatabaseInstaller.CreateInstance(Program.Arguments, Program.QueryInstallParameters);

                if (Program.Arguments.InstallTime == InstallTime.OnDemand && !string.IsNullOrEmpty(Program.Arguments.QueryTag))
                {
                    databaseInstaller.ExecuteQuery();
                }
                else
                {
                  if (Program.Arguments.UnInstallOnly)
                  {
                    message = "Database Installer called with UnInstallOnly option.";
                    LogHelper.WriteLog(message, LogLevelEnum.Info, Program.mtLogLogger, null);
                    Console.WriteLine(string.Concat("\n", message));
                    databaseInstaller.Execute();
                  }
                  else
                  {
                    databaseInstaller.Execute();
                  }

                  
                }
                Console.WriteLine("\nEnd without error.\n");
                return 0;
            }
            catch (Exception exception)
            {
                message = string.Concat(
                    methodName,
                    "Exception caught:  ",
                    exception.Message,
                    "  Stack Trace:  ",
                    exception.StackTrace);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, Program.mtLogLogger, null);
                Console.WriteLine(message);
                return 1;
            }
            finally
            {
                // Trace Logging
                if (Program.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
                }
            }
        }
        /// <summary>
        /// Will parse the string and return a boolean value will be returned if it was possible to parse.
        /// Valid values are the following (note all are case insensative):
        /// Y = True
        /// N = False
        /// Yes = True
        /// No = False
        /// 1 = True
        /// 0 = False
        /// True = True
        /// False = False
        /// T = True
        /// F = False
        /// </summary>
        /// <param name="possibleBoolean">String to parse for boolean value</param>
        /// <param name="booleanValue">output boolean</param>
        /// <returns>true on successful conversion, false if conversion failed</returns>
        private static bool TryParseBoolean(string possibleBoolean, out bool booleanValue)
        {
            booleanValue = false;
            if (String.IsNullOrEmpty(possibleBoolean) || String.IsNullOrWhiteSpace(possibleBoolean))
                return false;
            switch (possibleBoolean.ToUpperInvariant())
            {
                case "Y":
                case "YES":
                case "T":
                case "TRUE":
                case "1":
                    booleanValue = true;
                    return true;
                case "N":
                case "NO":
                case "F":
                case "FALSE":
                case "0":
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Parses the arguments passed to this program
        /// </summary>
        private static void ParseArguments(string[] args)
        {
            const string methodName = "[PrintUsage]";
            string message = string.Empty;

            //// Trace Logging
            if (Program.Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
            }

            try
            {
                if (args.Length == 1)
                {
                    throw new ArgumentException("The program argument list is empty.");
                }

                //// Parse The Arguments
                for (int i = 0; i < args.Length; i++)
                {
                    switch (args[i].ToLower())
                    {
                        case ProgramArgumentConstants.Action:
                            {
                                Program.Arguments.Action = Program.ParseNextArgument(ProgramArgumentConstants.Action, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseDeviceName:
                            {
                                Program.Arguments.DataDeviceName = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseDeviceName, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseDeviceLocation:
                            {
                                Program.Arguments.DataDeviceLocation = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseDeviceLocation, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseDeviceSize:
                            {
                                Program.Arguments.DataDeviceSize = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseDeviceSize, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseDumpFile:
                            {
                                Program.Arguments.DataDumpDeviceFile = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseDumpFile, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseName:
                            {
                                Program.Arguments.DatabaseName = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseName, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DataSource:
                            {
                                Program.Arguments.DataSource = Program.ParseNextArgument(ProgramArgumentConstants.DataSource, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DatabaseType:
                            {
                                Program.Arguments.DatabaseType = Program.ParseNextArgument(ProgramArgumentConstants.DatabaseType, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DboLogon:
                            {
                                Program.Arguments.DboLogon = Program.ParseNextArgument(ProgramArgumentConstants.DboLogon, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.DboPassword:
                            {
                                Program.Arguments.DboPassword = Program.ParseNextArgument(ProgramArgumentConstants.DboPassword, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.InstallTime:
                            {
                                var argument = Program.ParseNextArgument(ProgramArgumentConstants.InstallTime, args, ref i);
                                var enumNames = Enum.GetNames(typeof(InstallTime));
                                bool bFound = false;
                                for (int x = 0; x < enumNames.Length; x++)
                                {
                                    if (argument.Equals(enumNames[x]))
                                    {
                                        Program.Arguments.InstallTime = (InstallTime)x;
                                        bFound = true;
                                    }
                                }

                                if (bFound == false)
                                {
                                    Console.WriteLine("An invalid arguement was passed for -InstallTime.");
                                    Program.PrintUsage();
                                }
                            }
                            break;

                        case ProgramArgumentConstants.InstallWithoutDroppingDatabase: //// required for oracle
                            {
                                Program.Arguments.InstallWithoutDroppingDatabase = true;
                            }
                            break;

                        case ProgramArgumentConstants.IsStagingDatabase:
                            {
                                var isStage = Program.ParseNextArgument(ProgramArgumentConstants.IsStagingDatabase, args, ref i);
                                var isStateEnum = false;
                                if (!TryParseBoolean(isStage, out isStateEnum))
                                {
                                    Console.WriteLine("An invalid boolean argument was passed for -IsStaging.");
                                    Program.PrintUsage();
                                }
                                else
                                {
                                    Program.Arguments.IsStaging = isStateEnum;
                                }
                            }
                            break;

                        case ProgramArgumentConstants.LogDeviceLocation:
                            {
                                Program.Arguments.LogDeviceLocation = Program.ParseNextArgument(ProgramArgumentConstants.LogDeviceLocation, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.LogDeviceName:
                            {
                                Program.Arguments.LogDeviceName = Program.ParseNextArgument(ProgramArgumentConstants.LogDeviceName, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.LogDeviceSize:
                            {
                                Program.Arguments.LogDeviceSize = Program.ParseNextArgument(ProgramArgumentConstants.LogDeviceSize, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.LogDumpDeviceFile:
                            {
                                Program.Arguments.LogDumpDeviceFile = Program.ParseNextArgument(ProgramArgumentConstants.LogDumpDeviceFile, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.QueryTag:
                            {
                                Program.Arguments.QueryTag = Program.ParseNextArgument(ProgramArgumentConstants.QueryTag, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.ServerAdminLogon:
                            {
                                Program.Arguments.SeverAdminLogon = Program.ParseNextArgument(ProgramArgumentConstants.ServerAdminLogon, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.ServerAdminPassword:
                            {
                                Program.Arguments.SeverAdminPassword = Program.ParseNextArgument(ProgramArgumentConstants.ServerAdminPassword, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.ServerName:
                            {
                                Program.Arguments.ServerName = Program.ParseNextArgument(ProgramArgumentConstants.ServerName, args, ref i);
                            }
                            break;

                        case ProgramArgumentConstants.TimeoutValue:
                            {
                                var value = Program.ParseNextArgument(ProgramArgumentConstants.TimeoutValue, args, ref i);

                                UInt32 timeOutValue;

                                if (!UInt32.TryParse(value, out timeOutValue))
                                {
                                    message = string.Concat("The value of the ", "-timeout", "argument must be a number that is greater than zero.");
                                    Console.WriteLine(message);
                                    Program.PrintUsage();
                                }

                                Program.Arguments.TimeoutValue = timeOutValue;
                            }
                            break;

                        case ProgramArgumentConstants.UnInstall: //// required for oracle
                            {
                                Program.Arguments.UnInstalling = true;
                            }
                            break;
                        
                        case ProgramArgumentConstants.UnInstallOnly:
                            {
                              Program.Arguments.UnInstallOnly = true;
                            }
                            break;

                        case ProgramArgumentConstants.MinInstallSet:
                            {
                                var value = Program.ParseNextArgument(ProgramArgumentConstants.MinInstallSet, args, ref i);
                                try
                                {
                                    Program.Arguments.MinInstallSet = (DatabaseDefinitionTypeEnum)Enum.Parse(typeof(DatabaseDefinitionTypeEnum), value, true);
                                }
                                catch
                                {
                                    message = string.Concat("The value of the ", "-mininstallset", " argument must be a valid DatabaseDefinitionTypeEnum.");
                                    Console.WriteLine(message);
                                    Program.PrintUsage();
                                }
                            }
                            break;

                        case ProgramArgumentConstants.MaxInstallSet:
                            {
                                var value = Program.ParseNextArgument(ProgramArgumentConstants.MaxInstallSet, args, ref i);
                                try
                                {
                                    Program.Arguments.MaxInstallSet = (DatabaseDefinitionTypeEnum)Enum.Parse(typeof(DatabaseDefinitionTypeEnum), value, true);
                                }
                                catch
                                {
                                    message = string.Concat("The value of the ", "-maxinstallset", " argument must be a valid DatabaseDefinitionTypeEnum.");
                                    Console.WriteLine(message);
                                    Program.PrintUsage();
                                }
                            }
                            break;

                        default:
                            {
                                message = string.Concat("Unknown argument \"", args[i], "\" passed to this program.");
                                Console.WriteLine(message);
                                Program.PrintUsage();
                            }
                            break;
                    }
                }
            }
            finally
            {
                // Trace Logging  
                if (Program.Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
                }
            }
        }

        /// <summary>
        /// Parses the nex argument in the array of arguments passed to the program if the argument exists.
        /// </summary>
        /// <param name="previousArgument"></param>
        /// <param name="args">The array of arguments passed to the program.</param>
        /// <param name="index">The current index into the array of arguments passt to the program.</param>
        /// <returns>The next argument parsed.</returns>
        private static string ParseNextArgument(string previousArgument, string[] args, ref int index)
        {
            const string methodName = "[PrintUsage]";
            string message = string.Empty;

            // Trace Logging
            if (Program.Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
            }
            try
            {
                if (!(index + 1 < args.Length))
                {
                    message = string.Concat(methodName, "The ", previousArgument, " was not found after the ", previousArgument, " option.");
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, Program.Logger, null);
                    PrintUsage();
                }
                return args[++index];
            }
            finally
            {
                // Trace Logging  
                if (Program.Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
                }
            }
        }

        /// <summary>
        /// Prints how to use this program
        /// </summary>
        private static void PrintUsage()
        {
            const string methodName = "[PrintUsage]";
            string message = string.Empty;

            // Trace Logging
            if (Program.Logger.WillLogTrace)
            {
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
            }
            try
            {
                Console.WriteLine("\nUsage: DatabaseInstall [options]");
                Console.WriteLine("\tOptions: ");
                Console.WriteLine("\t\t-installtime [Pre/Post Synchronization Hook]");
                Console.WriteLine("\t\t-salogon [SA Logon] ");
                Console.WriteLine("\t\t-sapassword [SA Password] ");
                Console.WriteLine("\t\t-dbname [Database Name] ");
                Console.WriteLine("\t\t-servername [Server Name] ");
                Console.WriteLine("\t\t-dbologon [DBO Logon] ");
                Console.WriteLine("\t\t-dbopassword [DBO Password] ");
                Console.WriteLine("\t\t-datadevname [Data Device Name] ");
                Console.WriteLine("\t\t-datadevloc [Data Device Location] ");
                Console.WriteLine("\t\t-datadevsize [Data Device Size] ");
                Console.WriteLine("\t\t-logdevname [Log Device Name] ");
                Console.WriteLine("\t\t-logdevloc [Log Device Location] ");
                Console.WriteLine("\t\t-logdevsize [Log Device Size] ");
                Console.WriteLine("\t\t-datadumpdevfile [Data Dump Device File] ");
                Console.WriteLine("\t\t-logdumpdevfile [Log Dump Device File] ");
                Console.WriteLine("\t\t-timeoutvalue [Execution time out value] ");
                Console.WriteLine("\t\t-uninstall	[Uninstall the database only (optional)]");
                Console.WriteLine("\t\t-installwithoutdropdb [Install just the objects]");
                Console.WriteLine("\t\t-mininstallset [Minimum DatabaseDefinitionTypeEnum value to install]");
                Console.WriteLine("\t\t-maxinstallset [Maximum DatabaseDefinitionTypeEnum value to install]");
                Console.WriteLine("\tExample: ");
                Console.WriteLine("\t\t-installtime PreSync ");
                Console.WriteLine("\t\t-salogon sa ");
                Console.WriteLine("\t\t-sapassword ");
                Console.WriteLine("\t\t-dbname NetMeter ");
                Console.WriteLine("\t\t-servername localhost ");
                Console.WriteLine("\t\t-dbologon nmdbo ");
                Console.WriteLine("\t\t-dbopassword nmdbo ");
                Console.WriteLine("\t\t-datadevname NMDBData ");
                Console.WriteLine("\t\t-datadevloc C:\\mssql\\data\\NMDBData.dat ");
                Console.WriteLine("\t\t-datadevsize 100 ");
                Console.WriteLine("\t\t-logdevname NMDBLog ");
                Console.WriteLine("\t\t-logdevloc C:\\mssql\\data\\NMDBLog.dat ");
                Console.WriteLine("\t\t-logdevsize 20 ");
                Console.WriteLine("\t\t-datadumpdevfile C:\\mssql\\backup\\NMDBData.dat ");
                Console.WriteLine("\t\t-logdumpdevfile C:\\mssql\\backup\\NMDBLog.dat ");
                Console.WriteLine("\t\t-timeoutvalue 1000");
                Console.WriteLine("\t\t-IsStaging 0");
            }
            finally
            {
                // Trace Logging  
                if (Program.Logger.WillLogTrace)
                {
                    message = string.Concat(methodName, MessageConstants.MethodExit);
                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Program.Logger, null);
                }

                System.Environment.Exit(1);
            }
        }
    }
}