using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Windows.Forms;
using System.IO;
using log4net;

namespace BaselineGUI
{
    public static class UserInterface
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(UserInterface));

        public static FormPreferences formPreferences = null;
        public static FormBringup formBringup = null;
        public static FormMain formMain = null;


        static UserInterface()
        {
        }

        public static void init()
        {
        }


        public static void getPreferences()
        {
            formPreferences = new FormPreferences();
            formPreferences.pushModelToControl();
            formPreferences.ShowDialog();
            formPreferences = null;
        }

        public static void bringup()
        {
            formBringup = new FormBringup();
            formBringup.Show();
            Application.Run(formBringup);
            formBringup.Close();
            formBringup = null;
        }

        public static void runApplication()
        {
            log.Info("entering runApplication");
            formMain = new FormMain();
            log.Info("FormMain created");
            formMain.Show();
            log.Info("form shown");

            Application.Run(formMain);
            formMain.Close();
        }

        public static void pushControlToModel()
        {
            if (formPreferences != null)
                formPreferences.pushControlToModel();
        }

        public static void pushModelToControl()
        {
            if (formPreferences != null)
                formPreferences.pushModelToControl();
        }

    }
}
