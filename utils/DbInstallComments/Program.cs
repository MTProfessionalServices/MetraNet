using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Serialization;

namespace MetraTech.Utils.DbInstallComments
{
    class Program
    {
        private static ILogger _log = new Logger("[DbInstallComments]");
        static int Main(string[] args)
        {
            _log.LogInfo(Localization.InitWritingCommentToDB, args);
            int errorCode = 0;
            string errorMessage;

            try
            {
                errorCode = CommonSettings.CreateInstance(args, out errorMessage);
                if (errorCode == 0)
                {
                    CommentWriter writer = new CommentWriter();

                    // writes comments to CORE DB
                    WriteCommentsToDb(writer.WriteCommentsToCoreDb
                                    , Localization.tables, Localization.CoreDB);
                    
                    // writes comments to CORE DB for view
                    WriteCommentsToDb(writer.WriteCommentsToCoreDbForView
									, Localization.views, Localization.CoreDB);
                    
                    // writes comments to staging DB
                    WriteCommentsToDb(writer.WriteCommentsToStagingDb
									, Localization.tables, Localization.StagingDb);
                    
                }
                else
                {
                    Console.WriteLine(errorMessage);
                    _log.LogError(errorMessage);
                }
                
                _log.LogInfo(String.Format(Localization.FinishedWithCode, errorCode));
                return errorCode;
            }
            catch (Exception ex)
            {
                _log.LogException(Localization.InstallationTableCommentsFinishedWithException, ex);
                throw;
            }
        }

        private static void LogInfo(string message)
        {
            Console.WriteLine(message);
            _log.LogInfo(message);
        }

        private delegate void WriteToDbDelegate();
        private static void WriteCommentsToDb(WriteToDbDelegate writeToDb, string oblectName, string dbName)
        {
             try
             {
				 LogInfo(String.Format(Localization.StartingToWriteCommentsToDb, dbName, oblectName));
				 writeToDb();
				 LogInfo(String.Format(Localization.FinishedWritingCommentsToDb, dbName, oblectName));
             }
             catch (System.Data.SqlClient.SqlException ex)
             {
                // some tables do not exist in CORE and in staging DBs
                if (ex.Message.Contains("Extended properties are not permitted on"))
                {
					_log.LogInfo(String.Format(Localization.SomeDbObjectsDoNotExistInDb, oblectName, dbName, ex.Message));
                }	
				else if (ex.Message.Contains("Property 'MS_Description' already exists for"))
				{
					// CORE-5198
					_log.LogWarning(String.Format(Localization.DescriptionsAlreadySetForDbObjects, oblectName, dbName, ex.Message));
				}
                else throw;
             }
             catch (Oracle.DataAccess.Client.OracleException ex)
             {
                 // some tables do not exist in CORE and in staging DBs
                 if (ex.Message.Contains("ORA-00942: table or view does not exist"))
                 {
                     _log.LogInfo(String.Format(Localization.SomeDbObjectsDoNotExistInDb_Ora, oblectName, dbName, ex.Message));
                 }
                 else throw;
             }
        }
    }
}
