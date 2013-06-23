using System;
using System.Windows.Forms;

namespace PropertyGui
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
            //Application.Run(new frmMain());

            //var form = new frmCompare(@"C:\ExpressionEngine\Data");

            var form = new frmLaunch(); 
            //var form = new Form1();
            Application.Run(form);
        }
    }
}
