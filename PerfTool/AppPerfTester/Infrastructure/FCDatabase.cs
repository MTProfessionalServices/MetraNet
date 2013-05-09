using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Threading;
using System.Windows.Forms;
using System.IO;
using System.Data;


namespace BaselineGUI
{
    public class FCDatabase : FrameworkComponentBase, IFrameworkComponent
    {
        public FCDatabase()
        {
            name = "Database";
            fullName = "Database Connection";
            priority = 1;
        }

        public void Bringup()
        {
            bool success = false;
            //bringupModel.setState("database", BringupState.State.inProgress);
            try
            {
                AppDbPreferences pref = AppPreferences.db;
                string s = string.Format("server={0};user id={1};password={2};database={3}", pref.address, pref.userName, pref.password, pref.database);
                Framework.conn = new SqlConnection(s);
                Framework.conn.Open();
                if (Framework.conn.State == ConnectionState.Open)
                    success = true;
            }
            catch
            {
            }

            if (success)
            {
                bringupState.message = "Connected";
            }
            else
            {
                bringupState.message = "Connection failed";
            }
        }


        public SqlConnection getConnection(string databaseName = null)
        {
            AppDbPreferences pref = AppPreferences.db;
            string dbName = pref.database;
            if (databaseName != null)
                dbName = databaseName;

            try
            {
                SqlConnection conn;

                string s = string.Format("server={0};user id={1};password={2};database={3}", pref.address, pref.userName, pref.password, dbName);
                conn = new SqlConnection(s);
                conn.Open();
                if (conn.State == ConnectionState.Open)
                    return conn;
            }
            catch
            {
                return null;
            }
            return null;
        }


        public void Teardown()
        {
        }

    }
}
