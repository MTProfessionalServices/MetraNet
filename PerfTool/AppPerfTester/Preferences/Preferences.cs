using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using log4net;

namespace BaselineGUI
{
  public class Preferences
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(PrefRepo));

    public Dictionary<string, AMPreferences> amPrefs { set; get; }
    public Dictionary<string, ProductOfferPreferences> poPrefs { set; get; }

    public AppDbPreferences database { set; get; }
    public AppFolderPreferences folders { set; get; }
    public ActivityServicePreferences actSvcs { set; get; }
    public RunLimitPreferences runLmt { set; get; }
    public ReportsPreferences rpt { set; get; }
    public StressPreferences stress { set; get; }
    public SecurityPreferences Security { set; get; }

    public Preferences()
    {
      amPrefs = new Dictionary<string, AMPreferences>();
      poPrefs = new Dictionary<string, ProductOfferPreferences>();

      database = new AppDbPreferences();
      folders = new AppFolderPreferences();
      actSvcs = new ActivityServicePreferences();
      runLmt = new RunLimitPreferences();
      rpt = new ReportsPreferences();
      stress = new StressPreferences();
      Security = new SecurityPreferences();

      setToDefaults();
    }

    public void setToDefaults()
    {
      foreach (AMPreferences p in amPrefs.Values)
      {
        p.setToDefaults();
      }
      database.setToDefaults();
      folders.setToDefaults();
      actSvcs.setToDefaults();
      runLmt.setToDefaults();
      rpt.setToDefaults();
      stress.setToDefaults();
    }


    public AMPreferences findAMPreferences(string key)
    {
      if (!amPrefs.ContainsKey(key))
      {
        AMPreferences pref = new AMPreferences();
        pref.name = key;
        pref.setToDefaults();
        amPrefs.Add(key, pref);
      }

      return amPrefs[key];
    }

    public ProductOfferPreferences findPoPreferences(string key)
    {
      if (!poPrefs.ContainsKey(key))
      {
        ProductOfferPreferences pref = new ProductOfferPreferences();
        pref.name = key;
        pref.setToDefaults();
        poPrefs.Add(key, pref);
      }

      return poPrefs[key];
    }

    #region Load/Store

    public static Preferences Fetch(string pathConfig)
    {
      string sJSON = "";
      Preferences NewSet = new Preferences();
      System.Web.Script.Serialization.JavaScriptSerializer oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
      sJSON = File.ReadAllText(pathConfig);
      NewSet = oSerializer.Deserialize<Preferences>(sJSON);
      return NewSet;
    }

    public void Store(string pathConfig)
    {
      log.Debug("Store entered");

      log.DebugFormat("Saving to file {0}", pathConfig);

      System.Web.Script.Serialization.JavaScriptSerializer oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
      string sJSON = oSerializer.Serialize(this);

      JsonPrettyPrinterPlus.JsonPrettyPrinterInternals.JsonPPStrategyContext context = new JsonPrettyPrinterPlus.JsonPrettyPrinterInternals.JsonPPStrategyContext();
      JsonPrettyPrinterPlus.JsonPrettyPrinter jpp = new JsonPrettyPrinterPlus.JsonPrettyPrinter(context);
      string pretty = jpp.PrettyPrint(sJSON);

      File.WriteAllText(pathConfig, pretty);
      log.Debug("Store exits");
    }

    #endregion

  }
}
