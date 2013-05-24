using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Xml.Serialization;
using System.Runtime.Serialization;
using MetraTech;
using MetraTech.DataAccess;
using MetraTech.DomainModel;
using MetraTech.Performance;
using MetraTech.Interop.MTServerAccess;
using System.Reflection;
using System.IO;

namespace MetraTech.Accounts.AccountImportTool
{
    class Program
    {
        /// <summary>
        /// The main program.
        /// </summary>
        /// <param name="args">the command line arguments.</param>
        /// 
        public static int Main(string[] args)
        {
            AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(AssemblyResolver);

            Program usm = new Program(args);
            int status = usm.Execute();
            return status;
        }

        /// <summary>
        /// Constructor for the program.
        /// </summary>
        /// <param name="args">the command line arguments.</param>
        private Program(string[] args)
        {
            mArgs = args;
        }

        /// <summary>
        /// Execute the program, creating the accounts based
        /// on the command line arguments.
        /// </summary>
        /// <returns></returns>
        private int Execute()
        {
            int startTime = Environment.TickCount;

            string filename = "";
            string username;
            string password;

            // Set the defaults for the command line options
            string xsltFilename = null;
            string createEndpointName = "WSHttpBinding_IAccountCreation";
            bool applyTemplates = true;
            int concurrentLimit = 10;
            int timeout = 30 * 1000;
            int errorWaitLimit = 2 * 60 * 1000;
            int fatalWaitLimit = 5 * 60 * 1000;
            int sampleAccountID = -1;
            bool create = true;
            bool wasCreateOrUpdateOnlySpecified = false;
            string outputDirectory = @"D:\MetraTech\Reports\AccountImport\";

            // Retrive credentials
            try
            {
                MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
                sa.Initialize();
                MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
                accessData = sa.FindAndReturnObject("SuperUser");
                username = accessData.UserName;
                password = accessData.Password;
            }
            catch (Exception e)
            {
                Console.WriteLine("Unable to retrieve credentials. Is the file servers.xml missing? " + e.Message);
                return 1;
            }


            // Get the input file name.
            if (mArgs.Length < 1)
            {
                Console.WriteLine("Too few arguments.");
                DisplayUsage();
                return 1;
            }

            filename = mArgs[mArgs.Length - 1];

            if (filename.Contains('='))
            {
                Console.WriteLine("Filename name invalid: " + filename);
                DisplayUsage();
                return 1;
            }

            // Parse the other command line arguments.
            CommandLineParser parser = new CommandLineParser(mArgs, 0, mArgs.Length - 1);

            try
            {
                parser.Parse();

                applyTemplates = parser.GetBooleanOption("applyTemplates", applyTemplates);
                concurrentLimit = parser.GetIntegerOption("concurrentLimit", concurrentLimit);
                timeout = parser.GetIntegerOption("timeout", timeout);
                errorWaitLimit = parser.GetIntegerOption("errorTimeout", errorWaitLimit);
                fatalWaitLimit = parser.GetIntegerOption("fatalTimeout", fatalWaitLimit);
                createEndpointName = parser.GetStringOption("endpointName", createEndpointName);
                xsltFilename = parser.GetStringOption("xslt", xsltFilename);
                outputDirectory = parser.GetStringOption("output", outputDirectory);
                sampleAccountID = parser.GetIntegerOption("makeSample", -1);

                // Do we just want to build a sample xml file based on a given account?
                if (sampleAccountID > 0)
                {
                    SampleBuilder.MakeSample(username, password, sampleAccountID, filename);
                    return 0;
                }

                if (parser.OptionExists("createOnly"))
                {
                    wasCreateOrUpdateOnlySpecified = true;
                    create = parser.GetBooleanOption("createOnly");
                }

                if (parser.OptionExists("updateOnly"))
                {
                    wasCreateOrUpdateOnlySpecified = true;
                    create = !parser.GetBooleanOption("updateOnly");
                }

                parser.CheckForUnusedOptions(true);
            }
            catch (CommandLineParserException e)
            {
                Console.WriteLine("An error occurred parsing the command line arguments.");
                Console.WriteLine("{0}", e.Message);
                DisplayUsage();
                return 1;
            }

            // Check if the specified concurrent limit is reasonable
            if (concurrentLimit < 1)
            {
                Console.Error.WriteLine("ERROR: Concurrent Limit must be at least 1");
                Environment.Exit(1);
            }
            if (concurrentLimit > 64)
            {
                Console.Error.WriteLine("ERROR: Concurrent Limit must be no greater than 64");
                Environment.Exit(1);
            }

            // Create the output directory
            if (!System.IO.Directory.Exists(outputDirectory))
            {
                try
                {
                    System.IO.Directory.CreateDirectory(outputDirectory);
                }
                catch (Exception)
                {
                    Console.Error.WriteLine("ERROR: Unable to create directory: " + outputDirectory);
                    Environment.Exit(1);
                }
            }

            // Begin processing
            string outputFilename = System.IO.Path.Combine(outputDirectory, System.IO.Path.GetFileNameWithoutExtension(filename) + ".txt");

            logger.LogInfo("Importing accounts from {0}, generating control report in {1}", filename, outputFilename);

            using (var outputFile = System.IO.File.CreateText(outputFilename))
            {
                outputFile.WriteLine("Processing file: {0} at: {1}", filename, DateTime.UtcNow);
                bool fail = false;
                int concurrent = 0;
                int currentWait;
                int counter = 0;
                List<System.Threading.WaitHandle> waitHandles = new List<System.Threading.WaitHandle>();
                List<AccountRequestStatus> requests = new List<AccountRequestStatus>();
                Dictionary<System.Threading.WaitHandle, int> handleToRequestMap = new Dictionary<System.Threading.WaitHandle, int>();

                try
                {
                    using (MetraTech.Account.ClientProxies.AccountCreationClient accountCreationClient
                               = new MetraTech.Account.ClientProxies.AccountCreationClient(createEndpointName))
                    {
                        accountCreationClient.ClientCredentials.UserName.UserName = username;
                        accountCreationClient.ClientCredentials.UserName.Password = password;
                        System.Xml.Xsl.XslCompiledTransform transformer = GetTransform(xsltFilename);

                        // Open the input file
                        using (System.IO.FileStream inputStream = new System.IO.FileStream(filename, System.IO.FileMode.Open))
                        {
                            // Prepare to read the xml
                            using (System.Xml.XmlReader reader = System.Xml.XmlReader.Create(inputStream))
                            {
                                // Apply the xslt transformation (if specified)
                                using (System.Xml.XmlReader transformed = Transform(transformer, reader))
                                {
                                    logger.LogDebug("Loading accounts from {0}", filename);

                                    while (!reader.EOF)
                                    {
                                        List<MetraTech.DomainModel.BaseTypes.Account> accounts = deserialize(transformed);
                                        MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.BaseTypes.Account> filter = new MetraTech.ActivityServices.Common.MTList<MetraTech.DomainModel.BaseTypes.Account>();
                                        logger.LogInfo("Loaded {0} accounts", accounts.Count);
                                        outputFile.WriteLine("{0} accounts in file", accounts.Count);
                                        StringBuilder builder = new StringBuilder();

                                        // Iterate through the accounts in the xml.
                                        // Add a request for each account.
                                        foreach (var account in accounts)
                                        {
                                            AccountRequestStatus request = new AccountRequestStatus(account);

                                            // Did the command line specify that all the accounts must already exist?
                                            if (wasCreateOrUpdateOnlySpecified && !create)
                                            {
                                                // The specified account must already exist.
                                                request.Exists = true;
                                            }

                                            // Add to the list of our requests.
                                            requests.Add(request);

                                            // If the command line didn't specify if the account already existed or not.
                                            // That means we need to figure out whether it exists or not .
                                            if (!wasCreateOrUpdateOnlySpecified)
                                            {
                                                if (!string.IsNullOrEmpty(account.UserName) && !string.IsNullOrEmpty(account.Name_Space))
                                                {
                                                    // We are building up SQL restricting look up to all the accounts
                                                    // that were specified.
                                                    builder.Append(" OR (LOWER(T_ACCOUNT_MAPPER.nm_login) = '" +
                                                                    account.UserName.ToLower().Replace("'", "''") +
                                                                    "' AND LOWER(T_ACCOUNT_MAPPER.nm_space) = '" +
                                                                    account.Name_Space.ToLower().Replace("'", "''") + "')");
                                                }
                                            }
                                        }

                                        // We've add a request for each account.
                                        // If the command line didn't specify if the account already existed or not,
                                        // then we have to run some SQL to figure it out.

                                        if (builder.Length > 0 && !wasCreateOrUpdateOnlySpecified)
                                        {
                                            using (var conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
                                            {
                                                using (var stmt = conn.CreateAdapterStatement("SELECT T_ACCOUNT_MAPPER.id_acc AS id_acc, T_ACCOUNT_MAPPER.nm_login AS nm_login, T_ACCOUNT_MAPPER.nm_space AS nm_space FROM T_ACCOUNT_MAPPER WHERE 1=0" + builder.ToString()))
                                                {
                                                    MetraTech.DataAccess.DatabaseUtils.ExecuteQuery(logger, "__ACCOUNT_EXISTS_ALREADY_GEN__", stmt, null, delegate(IMTDataReader dbreader)
                                                    {
                                                        int id_acc = dbreader.GetInt32(0);
                                                        string nm_login = dbreader.GetString(1);
                                                        string nm_space = dbreader.GetString(2);

                                                        // An alternative is to create a hash rather the iterate looking for the account ID.
                                                        foreach (var request in requests)
                                                        {
                                                            if (request.Account._AccountID.HasValue && request.Account._AccountID.Value != id_acc)
                                                            {
                                                                continue;
                                                            }

                                                            if (nm_login.Equals(request.Account.UserName) && nm_space.Equals(request.Account.Name_Space))
                                                            {
                                                                // Mark the account as existing.
                                                                request.Exists = true;
                                                                break;
                                                            }
                                                        }
                                                        return true;
                                                    });
                                                }
                                            }
                                        }

                                        // Now we are ready to process the requests.

                                        for (int i = 0; i < accounts.Count; i++, counter++)
                                        {
                                            MetraTech.DomainModel.BaseTypes.Account account = accounts[i];
                                            AccountRequestStatus request = requests[counter];

                                            // Sanity check -- the new request should be pending.
                                            if (request.Status != 0)
                                            {
                                                throw new Exception("Request is not in pending state!");
                                            }

                                            bool errored = false;
                                            var performanceStopWatch = new PerformanceStopWatch();
                                            performanceStopWatch.Start();

                                            try
                                            {
                                                request.Status = 1;

                                                // If we expect the account to exist already, then update the account
                                                if (request.Exists)
                                                {
                                                    logger.LogTrace("BeginUpdateAccount entry");
                                                    IAsyncResult result = accountCreationClient.BeginUpdateAccount(account, applyTemplates, null, null, null);
                                                    request.AsyncResult = result;
                                                    logger.LogTrace("BeginUpdateAccount exit");
                                                }
                                                else // else create the account
                                                {
                                                    logger.LogTrace("BeginAddAccount entry");
                                                    IAsyncResult result = accountCreationClient.BeginAddAccount(ref account, applyTemplates, null, null);
                                                    request.AsyncResult = result;
                                                    logger.LogTrace("BeginAddAccount exit");
                                                }

                                                // Store the wait handle for this request.
                                                waitHandles.Add(request.AsyncResult.AsyncWaitHandle);

                                                // Set up the mapping of wait handle to index into the account array
                                                handleToRequestMap[request.AsyncResult.AsyncWaitHandle] = counter;
                                            }
                                            catch (Exception ex)
                                            {
                                                request.Exception = ex;
                                                request.Status = 3;
                                                errored = true;
                                                logger.LogWarning("Failed to send account request: " + ex.Message);
                                            }
                                            finally
                                            {
                                                performanceStopWatch.Stop("BeginAsyncAccount");
                                            }

                                            // If no exception occurred kicking of the request...
                                            if (!errored)
                                            {
                                                concurrent++;
                                                logger.LogDebug("Currently {0}/{1} connections concurrently processing...", concurrent, concurrentLimit);
                                                currentWait = Environment.TickCount;

                                                try
                                                {
                                                    // See if the number of requests that are currently being processed
                                                    // have reached the limit or not.
                                                    if (concurrent >= concurrentLimit)
                                                    {
                                                        logger.LogDebug("Waiting for available connections...");
                                                    }

                                                    // If we've reached the limit, then we have to wait for a request to
                                                    // finished before processing any more.
                                                    while (concurrent >= concurrentLimit)
                                                    {
                                                        // Block, waiting for a request to finish.
                                                        int doneHandle = System.Threading.WaitHandle.WaitAny(waitHandles.ToArray(), timeout);

                                                        // If we got through the block because a request finished (hurray!)
                                                        if (doneHandle != System.Threading.WaitHandle.WaitTimeout)
                                                        {
                                                            // Figure out which request finished.
                                                            request = requests[handleToRequestMap[waitHandles[doneHandle]]];
                                                            waitHandles.RemoveAt(doneHandle);
                                                            account = request.Account;

                                                            // We have to do some bookkeeping to wrap up the request that finished.
                                                            var performanceStopWatch2 = new PerformanceStopWatch();
                                                            performanceStopWatch2.Start();

                                                            try
                                                            {
                                                                // Complete either the update or acreate of the account.
                                                                if (request.Exists)
                                                                {
                                                                    accountCreationClient.EndUpdateAccount(request.AsyncResult);
                                                                }
                                                                else
                                                                {
                                                                    accountCreationClient.EndAddAccount(ref account, request.AsyncResult);
                                                                }
                                                                request.Status = 2;
                                                            }
                                                            catch (Exception ex)
                                                            {
                                                                request.Exception = ex;
                                                                request.Status = 4;
                                                                logger.LogWarning("Account request failed..." + ex.Message);
                                                            }
                                                            finally
                                                            {
                                                                performanceStopWatch.Stop("Execute2");
                                                            }

                                                            concurrent--;
                                                            logger.LogDebug("A connection has been released, resuming processing...");
                                                        }
                                                        else  // Rats! Nothing finished!
                                                        {
                                                            // Check how long we've been waiting for a request to finish.  

                                                            // If the wait is greater than a high maximum then we are going to abandon ship.
                                                            if ((Environment.TickCount - currentWait) > fatalWaitLimit)
                                                            {
                                                                Console.WriteLine("All concurrent connections in use ({0}/{1}), have been waiting over {3} ms for async responses...  Halting processing", concurrent, concurrentLimit, fatalWaitLimit);
                                                                logger.LogFatal("All concurrent connections in use ({0}/{1}), have been waiting over {3} ms for async responses...  Halting processing", concurrent, concurrentLimit, fatalWaitLimit);
                                                                throw new Exception("Wait time exceeded");
                                                            }
                                                            // If the wait is not fatal but large, then log an error.
                                                            else if ((Environment.TickCount - currentWait) > errorWaitLimit)
                                                            {
                                                                logger.LogError("All concurrent connections in use ({0}/{1}), have been waiting over {3} ms for async responses...", concurrent, concurrentLimit, errorWaitLimit);
                                                                Console.WriteLine("All concurrent connections in use ({0}/{1}), have been waiting over {3} ms for async responses...", concurrent, concurrentLimit, errorWaitLimit);
                                                            }
                                                            else
                                                            {
                                                                logger.LogDebug("All concurrent connections in use ({0}/{1}), still waiting for async responses...", concurrent, concurrentLimit);
                                                            }
                                                        }
                                                    }
                                                }
                                                catch (Exception ex)
                                                {
                                                    Console.WriteLine("Failed to wait for an account to finish processing...  Halting processing..." + ex.Message);
                                                    logger.LogError("Failed to wait for an account to finish processing...  Halting processing..." + ex.Message);
                                                    throw;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Finally we have all the requests either in progress or completed.
                        logger.LogInfo("All {0} accounts have been sent for processing...", requests.Count);

                        currentWait = Environment.TickCount;
                        try
                        {
                            if (concurrent > 0)
                            {
                                logger.LogDebug("Waiting for all connections to finish processing...");
                            }

                            // While some requests are still being processed...
                            while (concurrent > 0)
                            {
                                bool allDone = System.Threading.WaitHandle.WaitAll(waitHandles.ToArray(), timeout);
                                if (allDone)
                                {
                                    concurrent = 0;
                                    logger.LogDebug("All connections have finished processing...");
                                    foreach (var request in requests)
                                    {
                                        if (request.Status == 1)
                                        {
                                            var performanceStopWatch = new PerformanceStopWatch();
                                            performanceStopWatch.Start();
                                            
                                            MetraTech.DomainModel.BaseTypes.Account account = request.Account;
                                            try
                                            {
                                                if (request.Exists)
                                                {
                                                    accountCreationClient.EndUpdateAccount(request.AsyncResult);
                                                }
                                                else
                                                {
                                                    accountCreationClient.EndAddAccount(ref account, request.AsyncResult);
                                                }
                                                request.Status = 2;
                                            }
                                            catch (Exception ex)
                                            {
                                                request.Exception = ex;
                                                request.Status = 4;
                                                logger.LogWarning("Account request failed..." + ex.Message);
                                            }
                                            finally
                                            {
                                                performanceStopWatch.Stop("EndAsyncAccount");
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if ((Environment.TickCount - currentWait) > fatalWaitLimit)
                                    {
                                        logger.LogFatal("Connections are still open, have been waiting over {3} ms for async responses...", fatalWaitLimit);
                                        Console.WriteLine("Connections are still open, have been waiting over {3} ms for async responses...", fatalWaitLimit);
                                    }
                                    else if ((Environment.TickCount - currentWait) > errorWaitLimit)
                                    {
                                        logger.LogError("Connections are still open, have been waiting over {3} ms for async responses...", errorWaitLimit);
                                        Console.WriteLine("Connections are still open, have been waiting over {3} ms for async responses...", errorWaitLimit);
                                    }
                                    else
                                    {
                                        logger.LogDebug("Connections are still open, still waiting for async responses...");
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            logger.LogError("Failed to wait for accounts to finish processing" + ex.Message);
                            Console.WriteLine("Failed to wait for accounts to finish processing" + ex.Message);
                        }
                    }

                }
                catch (Exception ex)
                {
                    logger.LogFatal("Failed to import accounts." + ex.Message);
                    Console.WriteLine("Failed to import accounts." + ex.Message);
                    fail = true;
                }

                // Hurray!  All the requests have at last finished!
                // Let's write out the result statistics.

                int unprocessedCount = 0;
                int openCount = 0;
                int closedCount = 0;
                int localErrorCount = 0;
                int remoteErrorCount = 0;
                int index = 0;

                foreach (var request in requests)
                {
                    index++;
                    if (request.Status == 0)
                    {
                        unprocessedCount++;
                        if (request.Exception != null)
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} was not processed: {5}", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"), request.Exception.Message);
                        }
                        else
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} was not processed ", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                        }
                    }
                    else if (request.Status == 1)
                    {
                        openCount++;
                        if (request.Exception != null)
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed while preparing request: {5}", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"), request.Exception.Message);
                        }
                        else
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed while preparing request ", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                        }
                    }
                    else if (request.Status == 2)
                    {
                        closedCount++;
                        outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} succeeded", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                    }
                    else if (request.Status == 3)
                    {
                        localErrorCount++;
                        if (request.Exception != null)
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed while sending request: {5}", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"), request.Exception.Message);
                        }
                        else
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed while sending request ", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                        }
                    }
                    else if (request.Status == 4)
                    {
                        remoteErrorCount++;
                        if (request.Exception != null)
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed during processing: {5}", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"), request.Exception.Message);
                        }
                        else
                        {
                            outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed during processing", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                        }
                    }
                    else if (request.Exception != null)
                    {
                        outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed: {5}", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"), request.Exception.Message);
                    }
                    else
                    {
                        outputFile.WriteLine("{0} ({1}/{2}/{3}): {4} failed: unknown cause", index, request.Account.Name_Space, request.Account.UserName, request.Account._AccountID, (request.Exists ? "Update" : "Creation"));
                    }
                }

                outputFile.WriteLine("{0}/{1} accounts were successfully processed at {2}", closedCount, requests.Count, DateTime.UtcNow);

                logger.LogInfo("Processed {0}/{1} accounts in file {2} in {3} ms", closedCount, requests.Count, filename, Environment.TickCount - startTime);
                Console.Out.WriteLine("Processed {0}/{1} accounts in file {2} in {3} ms", closedCount, requests.Count, filename, Environment.TickCount - startTime);
                logger.LogDebug("Total: {0} Unprocessed: {1} ClientError: {2} ServerError: {3} Unknown: {4}", requests.Count, unprocessedCount, localErrorCount, remoteErrorCount, openCount);
                Console.Out.WriteLine("Total: {0} Unprocessed: {1} ClientError: {2} ServerError: {3} Unknown: {4}", requests.Count, unprocessedCount, localErrorCount, remoteErrorCount, openCount);

                if (fail)
                {
                    Environment.Exit(2);
                }
            }


            return 0;
        }


        /// <summary>
        /// deserializes a list of accounts from xml
        /// </summary>
        /// <param name="reader"></param>
        /// <returns></returns>
        private static List<MetraTech.DomainModel.BaseTypes.Account> deserialize(System.Xml.XmlReader reader)
        {
            DataContractSerializer serializer = new DataContractSerializer(typeof(List<MetraTech.DomainModel.BaseTypes.Account>));
            return serializer.ReadObject(reader) as List<MetraTech.DomainModel.BaseTypes.Account>;
        }

        /// <summary>
        /// optional transformation of xml before it is deserialized
        /// </summary>
        /// <param name="transformer">the transformer</param>
        /// <param name="inputReader">the input stream</param>
        /// <returns>the transformed output</returns>
        private static System.Xml.XmlReader Transform(System.Xml.Xsl.XslCompiledTransform transformer, System.Xml.XmlReader inputReader)
        {
            if (transformer != null)
            {
                logger.LogDebug("Transforming XML...");
                System.IO.MemoryStream outputStream = new System.IO.MemoryStream();
                using (System.Xml.XmlWriter writer = System.Xml.XmlWriter.Create(outputStream))
                {
                    // Execute the transformation.
                    transformer.Transform(inputReader, writer);
                }
                return System.Xml.XmlReader.Create(outputStream);
            }
            else
            {
                return inputReader;
            }
        }

        /// <summary>
        /// load a compiled xslt transformer
        /// </summary>
        /// <param name="xsltFilename">the xslt filename</param>
        /// <returns>the compiled xslt transformer</returns>
        private static System.Xml.Xsl.XslCompiledTransform GetTransform(string xsltFilename)
        {
            if (!string.IsNullOrEmpty(xsltFilename))
            {
                using (var fileReader = System.IO.File.OpenRead(xsltFilename))
                {
                    using (var invoiceXsltReader = new System.Xml.XmlTextReader(fileReader))
                    {
                        System.Xml.Xsl.XslCompiledTransform transform = new System.Xml.Xsl.XslCompiledTransform();
                        System.Xml.Xsl.XsltSettings settings = new System.Xml.Xsl.XsltSettings();
                        settings.EnableScript = true;
                        transform.Load(invoiceXsltReader, settings, null);
                        return transform;
                    }
                }
            }
            else
            {
                return null;
            }
        }

        private void DisplayUsage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("    AccountImportTool [Parameters] <filename>");
            Console.WriteLine("");
            Console.WriteLine("Parameters:");
            Console.WriteLine("--makeSample=<integer>      Create sample xml for an account based on the given account ID");
            Console.WriteLine("                            The sample xml is written into <filename>. You cannot use the sample");
            Console.WriteLine("                            as it is.  See documentation for the overall format of the xml file.");
            Console.WriteLine("--applyTemplates+           Apply templates. This is the default.");
            Console.WriteLine("--applyTemplates-           Do not apply templates");
            Console.WriteLine("--concurrentLimit=<integer> The maximum number of create/update accounts that will processed");
            Console.WriteLine("                            simultaneously. Must be between 1 and 64 inclusively.");
            Console.WriteLine("                            Default: 64");
            Console.WriteLine("--createOnly                If specified then it is expected that the input file specifies");
            Console.WriteLine("                            new unique account names (not existing ones).  If the account ");
            Console.WriteLine("                            already exists, an error is reported.");
            Console.WriteLine("                            Default: as if not specifed.");
            Console.WriteLine("--updateOnly                If specified then it is expected that the input file specifies existing accounts.");
            Console.WriteLine("                            If the account does not already exist, an error is reported.");
            Console.WriteLine("                            Default: as if not specifed.");
            Console.WriteLine("--timeout=<integer>         The polling wait time in milliseconds for a concurrent connection to become");
            Console.WriteLine("                            available.  After this period, a log message will be written and the wait will");
            Console.WriteLine("                            continue until one becomes free or we have waited <fatalTimeout>.");
            Console.WriteLine("                            Default: 30 seconds.");
            Console.WriteLine("--errorTimeout=<integer>    The time to wait in milliseconds for a concurrent connection before logging an error.");
            Console.WriteLine("                            The wait will still continue until one becomes free or we have waited <fatalTimeout>.");
            Console.WriteLine("                            Default: 2 minutes.");
            Console.WriteLine("--fatalTimeout=<integer>    The time to wait in milliseconds for a concurrent connection before failing.");
            Console.WriteLine("                            Default: 5 minutes.");
            Console.WriteLine("--xslt=<string>             This xslt transformation can be used if the input file needs");
            Console.WriteLine("                            to be transformed into the proper format before processing.");
            Console.WriteLine("                            Default: not used.");
            Console.WriteLine("--output=<string>           The directory where the output report file should be stored.");
            Console.WriteLine("                            Default: D:\\MetraTech\\Reports\\AccountImport");
            Console.WriteLine("");
            Console.WriteLine("Examples:");
            Console.WriteLine("    AccountImportTool --output=C:\\temp accountImport.xml");
            Console.WriteLine("    AccountImportTool --makeSample=124 sample.xml");
        }

        /// <summary>
        /// Resolves assemblies that cannot be found.  AccountImportTool uses the
        /// MetraTech.Account.ClientProxies library.  This library can be found under
        /// r:\extensions\account\bin but not o:\debug\bin.  This method is invoked
        /// when loading the library (from o:\debug\bin) fails.  It finds the library
        /// in r:\extensions\account\bin instead.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="args"></param>
        /// <returns></returns>
        private static Assembly AssemblyResolver(object sender, ResolveEventArgs args)
        {
            string assemblyName = args.Name;

            Assembly retval = null;

            string searchName = assemblyName.Substring(0, (assemblyName.IndexOf(',') == -1 ? assemblyName.Length : assemblyName.IndexOf(','))).ToUpper();

            if (!searchName.Contains(".DLL"))
            {
                searchName += ".DLL";
            }

            try
            {
                AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
                retval = Assembly.Load(nm);
            }
            catch (Exception)
            {
                try
                {
                    retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
                }
                catch (Exception)
                {
                    MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
                    MetraTech.Interop.RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

                    if (fileList.Count > 0)
                    {
                        AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
                        retval = Assembly.Load(nm2);
                    }
                }
            }

            return retval;
        }





        private static Logger logger = new Logger("[AccountImportTool]");

        string[] mArgs;
    }

    /// <summary>
    /// Maintains state of the account requests
    /// </summary>
    class AccountRequestStatus
    {
        /// <summary>
        /// the account being processed
        /// </summary>
        public MetraTech.DomainModel.BaseTypes.Account Account { get; set; }
        /// <summary>
        /// The async status
        /// </summary>
        public IAsyncResult AsyncResult { get; set; }
        /// <summary>
        /// 0=unprocessed
        /// 1=pending/sent
        /// 2=completed/success
        /// 3=error locally or during send
        /// 4=error remotely
        /// </summary>
        public int Status { get; set; }
        /// <summary>
        /// the error details
        /// </summary>
        public Exception Exception { get; set; }
        /// <summary>
        /// if it exists then it is an update
        /// </summary>
        public bool Exists { get; set; }
        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="account">the corresponding acount</param>
        public AccountRequestStatus(MetraTech.DomainModel.BaseTypes.Account account)
        {
            this.Account = account;
            this.Status = 0;
            this.Exists = false;
        }

    }

}

