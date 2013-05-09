using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace Linqify
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            Globals.openDbConnections();

            List<string> list = Config.getUsings();
            foreach (string s in list)
            {
                Console.WriteLine(s);
            }

            foreach (string s in Config.getTableNames())
            {
                Console.WriteLine(s);
                List<List<string>> indices = Config.getIndicesForTable(s);
                foreach (List<string> idx in indices)
                {
                    string cols = string.Join(",", idx);
                    Console.WriteLine("  Index {0}", cols);
                }
            }


            Application.Run(new FormMain());
        }
    }
}
