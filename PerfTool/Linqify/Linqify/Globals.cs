using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Windows.Forms;
using System.IO;


namespace Linqify
{
   public static class Globals
    {
        public static SqlConnection conn;

        public static void openDbConnections()
        {
            string s = string.Format("server=localhost;user id=sa;password=MetraTech1;database=netmeter");
            conn = new SqlConnection(s);
            conn.Open();

        }


    }
}
