using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.DataAccess;

namespace MetraTech.Utils.DbInstallComments
{
    /// <summary>
    /// Writes SQL-queries to DB
    /// </summary>
    internal class CommentWriter
    {
        private string _sqlTableComments = String.Empty;
        private string _sqlViewComments = String.Empty;
        private ConnectionInfo _coreDbConnInfo = new ConnectionInfo(CommonSettings.Instance.NetMeterDb);
        private ConnectionInfo _stagingDbConnInfo = new ConnectionInfo(CommonSettings.Instance.NetMeterStageDb);

        /// <summary>
        /// Writes table/colums comment to CORE DB
        /// </summary>
        public void WriteCommentsToCoreDb()
        {
            WriteCommentsToDb(_coreDbConnInfo, false);
        }

        /// <summary>
        /// Writes comments for views to CORE DB
        /// </summary>
        public void WriteCommentsToCoreDbForView()
        {
            WriteCommentsToDb(_coreDbConnInfo, true);
        }

        /// <summary>
        /// Writes table/colums comment to staging DB
        /// </summary>
        public void WriteCommentsToStagingDb()
        {
            WriteCommentsToDb(_stagingDbConnInfo, false);
        }

        private void WriteCommentsToDb(ConnectionInfo connectionInfo, bool forView)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection(connectionInfo))
            {
                using (IMTStatement statement = conn.CreateStatement(!forView 
                                                                        ? GetTabbleComments(connectionInfo)
                                                                        : GetViewComments(connectionInfo)))
                {
                    statement.ExecuteNonQuery();
                }
            }
        }

        private string GetTabbleComments(ConnectionInfo connectionInfo)
        {
            if (String.IsNullOrEmpty(_sqlTableComments))
            {
               _sqlTableComments = File.ReadAllText(connectionInfo.IsSqlServer
                                                     ? CommonSettings.Instance.SqlServerCommentFileName
                                                     : CommonSettings.Instance.OracleCommentFileName);
            }

            return connectionInfo.IsSqlServer ? _sqlTableComments : ToDDL(_sqlTableComments);
        }

        private string GetViewComments(ConnectionInfo connectionInfo)
        {
            if (String.IsNullOrEmpty(_sqlViewComments))
            {
                _sqlViewComments = File.ReadAllText(connectionInfo.IsSqlServer
                                                      ? CommonSettings.Instance.SqlServerCommentForViewFileName
                                                      : CommonSettings.Instance.OracleCommentForViewFileName);
            }

            return connectionInfo.IsSqlServer ? _sqlViewComments : ToDDL(_sqlViewComments);
        }


        private string ToDDL(string allCommentsQuery)
        {
            var result = new StringBuilder();
            var strings = allCommentsQuery.Split(';');

            string previousString = String.Empty;

            for (int i = 0; i < strings.Length; i++)
            {
                string curString = strings[i].Trim();

                //Do we have the begining of the query from the previous iteration?
                if (previousString != String.Empty)
                {
                    curString = previousString + curString;
                    previousString = String.Empty;
                }

                //Does the next string continues the current command? NOTE: in case semicolon happens in description
                if (i + 1 < strings.Length)
                {
                    var nextString = strings[i + 1].Trim();
                    if (!nextString.StartsWith("COMMENT") && !String.IsNullOrEmpty(nextString))
                    {
                        previousString = String.Format("{0};", curString);
                        continue;
                    }
                }

                if (!String.IsNullOrWhiteSpace(curString))
                {
                    result.AppendLine(String.Format("EXECUTE IMMEDIATE '{0}';", curString.Replace("'", "''")));
                }
            }

            return String.Format("declare pragma autonomous_transaction;\n begin\n {0} end;", result);
        }
    }
}
