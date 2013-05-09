using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Web;
using System.Web.Script;
using log4net;


namespace BaselineGUI
{
    public static class PrefRepo
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(PrefRepo));

        // This is intentionally null
        public static Preferences _active = null;
        public static Preferences active { get { return _active; } set { _active = value; RaiseActiveChange(); } }

        #region PreferencesRepository Methods

        // These defaults for various tests are loaded during init time
        // by the AppMethodFactory
        public static Dictionary<string, AMPreferences> amDefaults;

        // The default preferences file path
        public static string preferencesFile { get { return _preferencesFile; } set { _preferencesFile = value; RaiseModelChange(); } }
        static string _preferencesFile;

        // Callbacks when the model changes
        public static event EventHandler<EventArgs> OnModelChangeEvent = null;
        public static event EventHandler<EventArgs> OnPrefReloadEvent = null;

        static PrefRepo()
        {
            amDefaults = new Dictionary<string, AMPreferences>();
            preferencesFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), "PerfTool.json");

            log.Info("Static constructor exits");
        }

        public static void addAmDefault(AMPreferences p)
        {
            amDefaults.Add(p.name, p);
        }


        public static Preferences GetDefaultSettings()
        {
            Preferences NewSet = new Preferences();
            return NewSet;
        }

        public static Preferences Fetch(string pathConfig = null)
        {
            if (pathConfig == null)
                pathConfig = preferencesFile;

            return Preferences.Fetch( pathConfig);
        }

        public static void Store(Preferences newPref, string pathConfig = null)
        {
            log.Debug("Store entered");
            if (pathConfig == null)
                pathConfig = preferencesFile;

            newPref.Store(pathConfig);
            log.Debug("Store exits");
        }

        public static List<string> ListofPrefs(DirectoryInfo pathConfig)
        {
            List<string> ConfigFiles = new List<string>();
            foreach (var file in pathConfig.GetFiles())
            {
                if (file.FullName.EndsWith(".json"))
                {
                    ConfigFiles.Add(file.FullName);
                }
            }
            return ConfigFiles;

        }

        public static void SetConfigDir()
        {

        }

        #endregion

        private static void RaiseModelChange()
        {
            EventArgs d = new EventArgs();
            if (OnModelChangeEvent != null)
            {
                OnModelChangeEvent(null, d);
            }
        }

        private static void RaiseActiveChange()
        {
            EventArgs d = new EventArgs();
            if (OnPrefReloadEvent != null)
            {
                OnPrefReloadEvent(null, d);
            }
        }
    }




}
