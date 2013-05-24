
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using MetraTech.DataAccess;
using MetraTech.Xml;
using System.Xml;

namespace MetraTech.UsageServer
{
  /// <summary>
  /// Provides methods to read and write ConfigCrossServer data.
  /// </summary>
  public class ConfigCrossServerManager
  {
    /// <summary>
    /// Gets the cross-server configuration for the billing server.
    /// Attempts to read configuration from a single row in the
    /// database.  If unable to, attempts to read the values from
    /// the local usageServer.xml.  For any values still unable to
    /// be determined, uses default values.  
    /// 
    /// If the configuration was missing from the database, this method
    /// will initialize the database with the values obtained from usageServer.xml
    /// or default values.
    /// 
    /// This method logs any encountered errors.
    /// </summary>
    /// <returns></returns>
    public static ConfigCrossServer GetConfig()
    {
      return GetConfig(UsageServerCommon.UsageServerConfigFile);
    }

    /// <summary>
    /// If given the standard configuration file,
    /// attempts to read configuration from a single row in the
    /// database.  If unable to, attempts to read the values from
    /// the local usageServer.xml.  For any values still unable to
    /// be determined, uses default values. If the configuration was 
    /// missing from the database, this method
    /// will initialize the database with the values obtained from usageServer.xml
    /// or default values.
    /// 
    /// If given a non-standard configuration file, just reads from the
    /// file and not the database.  This is a testing-only path.
    /// </summary>
    /// <param name="configFile"></param>
    /// <returns></returns>
    public static ConfigCrossServer GetConfig(string configFile)
    {
      ConfigCrossServer config;
      bool isDatabaseMissingConfig = false;
      bool isSuccess = false;
      Logger logger = new Logger("[ConfigCrossServerManager]");

      // For unit testing purposes, GetConfig() can be called with a test
      // configuration file.  In this case, we do NOT read settings from
      // the database but just use the given file.
      if (configFile != UsageServerCommon.UsageServerConfigFile)
      {
        logger.LogDebug("Configuration being read from non-standard file: " + configFile +
                        ".  Skipping the reading of usage server settings from the database.");
        config = GetConfigFromXml(configFile);
        return config;
      }

      // Attempt to read configuration from the database.
      config = GetConfigFromDB(out isSuccess, out isDatabaseMissingConfig);

      if (isSuccess)
      {
        return config;
      }

      // Since we were unable to read the configuration from
      // the database, we are going to rely on the XML.
      logger.LogInfo("Since we were unable to read billing server configuration from t_billing_server_settings " +
                      "table, we will attempt to read configuration from usageServer.xml and initialize the " +
                      "settings in the database.");
      config = GetConfigFromXml(configFile);

      // If we known the configuration is missing from the database,
      // we initialize the database with the one we read from XML configuration.
      if (isDatabaseMissingConfig)
      {
        logger.LogInfo("Initializing the billing server settings in the database.");
        CreateConfigInDatabase(config);
      }

      logger.LogDebug("Read billing server configuration = " + config);

      return config;
    }

    /// <summary>
    /// Updates the billing server settings saved in the database with the given configuration 
    /// to the database. The row must already exist in the database before calling this
    /// method.  NOTE: we do NOT update the multicast settings.  A separate method
    /// handles that.  The reason why we don't update the multicast settings is that in the
    /// MetraControl user interface that uses this method (through a service), the multicast
    /// settings are not available through the user interface. NOTE: we do NOT update usageServer.xml
    /// </summary>
    /// <param name="config"></param>
    public static void SetConfig(ConfigCrossServer config)
    {
      Logger logger = new Logger("[ConfigCrossServerManager]");
      logger.LogDebug("Updating non-multicast billing server cross-server configuration in the database.");

      try
      {
        // Attempt to write configuration from the
        // database.
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__UPDATE_MOST_BILLING_SERVER_SETTINGS_"))
          {
            stmt.AddParam("%%GRACE_DAILY_IN_DAYS%%", config.gracePeriodDailyInDays);
            stmt.AddParam("%%GRACE_BIWEEKLY_IN_DAYS%%", config.gracePeriodBiWeeklyInDays);
            stmt.AddParam("%%GRACE_WEEKLY_IN_DAYS%%", config.gracePeriodWeeklyInDays);
            stmt.AddParam("%%GRACE_SEMIMONTHLY_IN_DAYS%%", config.gracePeriodSemiMonthlyInDays);
            stmt.AddParam("%%GRACE_MONTHLY_IN_DAYS%%", config.gracePeriodMonthlyInDays);
            stmt.AddParam("%%GRACE_QUARTERLY_IN_DAYS%%", config.gracePeriodQuarterlyInDays);
            stmt.AddParam("%%GRACE_SEMIANNUAL_IN_DAYS%%", config.gracePeriodSemiAnnuallyInDays);
            stmt.AddParam("%%GRACE_ANNUALLY_IN_DAYS%%", config.gracePeriodAnnuallyInDays);
            stmt.AddParam("%%IS_GRACE_DAILY_ENABLED%%", config.isGracePeriodDailyEnabled? 1:0);
            stmt.AddParam("%%IS_GRACE_BIWEEKLY_ENABLED%%", config.isGracePeriodBiWeeklyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_WEEKLY_ENABLED%%", config.isGracePeriodWeeklyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_SEMIMONTHLY_ENABLED%%", config.isGracePeriodSemiMonthlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_MONTHLY_ENABLED%%", config.isGracePeriodMonthlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_QUARTERLY_ENABLED%%", config.isGracePeriodQuarterlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_SEMIANNUAL_ENABLED%%", config.isGracePeriodSemiAnnuallyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_ANUALLY_ENABLED%%", config.isGracePeriodAnnuallyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_AUTO_RUN_EOP_ENABLED%%", config.isAutoRunEopOnSoftCloseEnabled ? 1 : 0);
            stmt.AddParam("%%IS_AUTO_SOFT_CLOSE_BG_ENABLED%%", config.isAutoSoftCloseBillGroupsEnabled ? 1 : 0);
            stmt.AddParam("%%IS_BLOCK_NEW_ACCOUNTS_ENABLED%%", config.isBlockNewAccountsWhenClosingEnabled ? 1 : 0);
            stmt.AddParam("%%IS_RUN_SCHEDULED_ADAPTERS_ENABLED%%", config.isRunScheduledAdaptersEnabled ? 1 : 0);

            if (stmt.ExecuteNonQuery() < 1)
            {
              throw new Exception("Unable to write the billing server configuration values to the database.");
            }
          }
        }


      }
      catch (Exception e)
      {
        logger.LogError("Unable to write the billing server configuration values to the database." + 
                        "Exception: " + e.Message + " Stack: " + e.StackTrace);
        throw;
      }
    }

    /// <summary>
    /// This method is invoked as part of USM synchronization (usm sync).  
    /// If the billing server settings in the database are uninitialized,
    /// they will be initialized using usageserver.xml.
    /// </summary>
    public static void Synchronize()
    {
      Logger logger = new Logger("[ConfigCrossServerManager]");
      logger.LogDebug("Synchronizing billing server multicast cross-server configuration in the database " + 
                      "with multicast configuration from XML.");

      // To synchronize, we just have to access billing server configuration.
      // If the database has no settings, we will get the settings from usageserver.xml.
      // If the database has settings, we do not use usageserver.xml

      GetConfig();
    }

    public static void CreateConfigInDatabase(ConfigCrossServer config)
    {
      Logger logger = new Logger("[ConfigCrossServerManager]");
      logger.LogDebug("Writing billing server cross-server configuration to the database.");

      try
      {
        // Attempt to write configuration from the
        // database.
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__INSERT_BILLING_SERVER_SETTINGS_"))
          {
            stmt.AddParam("%%GRACE_DAILY_IN_DAYS%%", config.gracePeriodDailyInDays);
            stmt.AddParam("%%GRACE_BIWEEKLY_IN_DAYS%%", config.gracePeriodBiWeeklyInDays);
            stmt.AddParam("%%GRACE_WEEKLY_IN_DAYS%%", config.gracePeriodWeeklyInDays);
            stmt.AddParam("%%GRACE_SEMIMONTHLY_IN_DAYS%%", config.gracePeriodSemiMonthlyInDays);
            stmt.AddParam("%%GRACE_MONTHLY_IN_DAYS%%", config.gracePeriodMonthlyInDays);
            stmt.AddParam("%%GRACE_QUARTERLY_IN_DAYS%%", config.gracePeriodQuarterlyInDays);
            stmt.AddParam("%%GRACE_SEMIANNUAL_IN_DAYS%%", config.gracePeriodSemiAnnuallyInDays);
            stmt.AddParam("%%GRACE_ANNUALLY_IN_DAYS%%", config.gracePeriodAnnuallyInDays);
            stmt.AddParam("%%IS_GRACE_DAILY_ENABLED%%", config.isGracePeriodDailyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_BIWEEKLY_ENABLED%%", config.isGracePeriodBiWeeklyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_WEEKLY_ENABLED%%", config.isGracePeriodWeeklyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_SEMIMONTHLY_ENABLED%%", config.isGracePeriodSemiMonthlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_MONTHLY_ENABLED%%", config.isGracePeriodMonthlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_QUARTERLY_ENABLED%%", config.isGracePeriodQuarterlyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_SEMIANNUAL_ENABLED%%", config.isGracePeriodSemiAnnuallyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_GRACE_ANUALLY_ENABLED%%", config.isGracePeriodAnnuallyEnabled ? 1 : 0);
            stmt.AddParam("%%IS_AUTO_RUN_EOP_ENABLED%%", config.isAutoRunEopOnSoftCloseEnabled ? 1 : 0);
            stmt.AddParam("%%IS_AUTO_SOFT_CLOSE_BG_ENABLED%%", config.isAutoSoftCloseBillGroupsEnabled ? 1 : 0);
            stmt.AddParam("%%IS_BLOCK_NEW_ACCOUNTS_ENABLED%%", config.isBlockNewAccountsWhenClosingEnabled ? 1 : 0);
            stmt.AddParam("%%IS_RUN_SCHEDULED_ADAPTERS_ENABLED%%", config.isRunScheduledAdaptersEnabled ? 1 : 0); 
            stmt.AddParam("%%MULTICAST_ADDRESS%%", config.multicastAddress);
            stmt.AddParam("%%MULTICAST_PORT%%", config.multicastPort);
            stmt.AddParam("%%MULTICAST_TIME_TO_LIVE%%", config.multicastTimeToLive);

            if (stmt.ExecuteNonQuery() != 1)
            {
              logger.LogError("Unable to write the billing server configuration values to the database.");
            }
          }
        }
      }
      catch (Exception e)
      {
        logger.LogError("Unable to write the billing server configuration values to the database." +
                        "Exception: " + e.Message + " Stack: " + e.StackTrace);
      }
    }

    /// <summary>
    /// Return a configuration loaded with the default values.
    /// </summary>
    /// <returns></returns>
    private static ConfigCrossServer SetConfigWithDefaults()
    {
      ConfigCrossServer config = new ConfigCrossServer();

      config.gracePeriodBiWeeklyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.gracePeriodDailyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.gracePeriodQuarterlyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.gracePeriodSemiAnnuallyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.gracePeriodSemiMonthlyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.gracePeriodWeeklyInDays = DEFAULT_GRACE_PERIOD_DAYS;
      config.isGracePeriodBiWeeklyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isGracePeriodDailyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isGracePeriodQuarterlyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isGracePeriodSemiAnnuallyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isGracePeriodSemiMonthlyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isGracePeriodWeeklyEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
      config.isAutoRunEopOnSoftCloseEnabled = DEFAULT_IS_AUTO_RUN_EOP_ON_SOFT_CLOSED_ENABLED;
      config.isAutoSoftCloseBillGroupsEnabled = DEFAULT_IS_AUTO_SOFT_CLOSE_BILL_GROUPS_ENABLED;
      config.isBlockNewAccountsWhenClosingEnabled = DEFAULT_IS_BLOCK_NEW_ACCOUNTS_WHEN_CLOSING_ENABLED;
      config.isRunScheduledAdaptersEnabled = DEFAULT_IS_RUN_SCHEDULED_ADAPTERS_ENABLED;
      config.multicastAddress = DEFAULT_MULTICAST_ADDRESS;
      config.multicastPort = DEFAULT_MULTICAST_PORT;
      config.multicastTimeToLive = DEFAULT_MULTICAST_TTL;

      return config;
    }

    /// <summary>
    /// Read configuration from the database.
    /// </summary>
    /// <param name="wasConfigReadFromDb">true if was successful read the configuration.</param>
    /// <param name="isDatabaseMissingConfig">true if we determined that the configuration row
    ///                                       is missing from the database.</param>
    /// <returns></returns>
    private static ConfigCrossServer GetConfigFromDB(out bool wasConfigReadFromDb,
                                                     out bool isDatabaseMissingConfig)
    {
      isDatabaseMissingConfig = false;
      wasConfigReadFromDb = false;
      ConfigCrossServer config = SetConfigWithDefaults();

      // Attempt to read configuration from the
      // database.

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\UsageServer"))
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer", "__GET_BILLING_SERVER_SETTINGS__"))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              if (reader.Read())
              {
                config.gracePeriodDailyInDays = reader.GetInt32("grace_daily_in_days");
                config.gracePeriodBiWeeklyInDays = reader.GetInt32("grace_biweekly_in_days");
                config.gracePeriodWeeklyInDays = reader.GetInt32("grace_weekly_in_days");
                config.gracePeriodSemiMonthlyInDays = reader.GetInt32("grace_semimonthly_in_days");
                config.gracePeriodMonthlyInDays = reader.GetInt32("grace_monthly_in_days");
                config.gracePeriodQuarterlyInDays = reader.GetInt32("grace_quarterly_in_days");
                config.gracePeriodSemiAnnuallyInDays = reader.GetInt32("grace_semiannual_in_days");
                config.gracePeriodAnnuallyInDays = reader.GetInt32("grace_annually_in_days");
                config.isGracePeriodDailyEnabled = (reader.GetInt32("is_grace_daily_enabled") != 0);
                config.isGracePeriodBiWeeklyEnabled = (reader.GetInt32("is_grace_biweekly_enabled") != 0);
                config.isGracePeriodWeeklyEnabled = (reader.GetInt32("is_grace_weekly_enabled") != 0);
                config.isGracePeriodSemiMonthlyEnabled = (reader.GetInt32("is_grace_semimonthly_enabled") != 0);
                config.isGracePeriodQuarterlyEnabled = (reader.GetInt32("is_grace_quarterly_enabled") != 0);
                config.isGracePeriodSemiAnnuallyEnabled = (reader.GetInt32("is_grace_semiannual_enabled") != 0);
                config.isGracePeriodAnnuallyEnabled = (reader.GetInt32("is_grace_anually_enabled") != 0);
                config.isGracePeriodMonthlyEnabled = (reader.GetInt32("is_grace_monthly_enabled") != 0);
                config.isAutoRunEopOnSoftCloseEnabled = (reader.GetInt32("is_auto_run_eop_enabled") != 0);
                config.isAutoSoftCloseBillGroupsEnabled = (reader.GetInt32("is_auto_soft_close_bg_enabled") != 0);
                config.isBlockNewAccountsWhenClosingEnabled = (reader.GetInt32("is_block_new_accounts_enabled") != 0);
                // SECENG: ESR-5055 Telus \ Bell 6.5: Unable to un-Select the "Run Scheduled Adapter" radio box within MetraControl
                // is_run_scheduled_adapters parameter was not readed properly
                config.isRunScheduledAdaptersEnabled = (reader.GetInt32("is_run_scheduled_adapters") != 0);
                config.multicastAddress = reader.GetString("multicast_address");
                config.multicastPort = reader.GetInt32("multicast_port");
                config.multicastTimeToLive = reader.GetInt32("multicast_time_to_live");
                wasConfigReadFromDb = true;
              }
              else
              {
                // There are no rows in the database
                Logger logger = new Logger("[ConfigCrossServerManager]");
                logger.LogInfo("Missing billing server configuration in t_billing_server_settings table.");
                isDatabaseMissingConfig = true;
              }
            }
          }
        }
      }
      catch (Exception e)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("An error occurred attempt to read billing server configuration from the " +
                        "database.  Exception: " + e.Message + " Stack: " + e.StackTrace);
        wasConfigReadFromDb = false;
      }

      return config;
    }

    /// <summary>
    /// Attempt to read configuration values from the given file.  
    /// For any values that could not
    /// be accessed, use a default value.
    /// </summary>
    /// <returns></returns>
    private static ConfigCrossServer GetConfigFromXml(string configFile)
    {
      Logger logger = new Logger("[ConfigCrossServerManager]");
      logger.LogDebug("Reading billing server cross-server configuration from XML.");

      ConfigCrossServer config = SetConfigWithDefaults();

      MTXmlDocument doc = new MTXmlDocument();

      // Open the XML file
      try
      {
        if (configFile == UsageServerCommon.UsageServerConfigFile)
          doc.LoadConfigFile(configFile);
        else
          doc.Load(configFile);
      }
      catch (Exception ex)
      {
        logger.LogError("Unable to load configuration file: " + configFile + 
                        " Exception: " + ex.Message + " Stack: " + ex.StackTrace);
        return config;
      }

      GetGracePeriodFromXml(doc, "Daily", out config.gracePeriodDailyInDays, out config.isGracePeriodDailyEnabled);
      GetGracePeriodFromXml(doc, "Weekly", out config.gracePeriodWeeklyInDays, out config.isGracePeriodWeeklyEnabled);
      GetGracePeriodFromXml(doc, "Bi-weekly", out config.gracePeriodBiWeeklyInDays, out config.isGracePeriodBiWeeklyEnabled);
      GetGracePeriodFromXml(doc, "Semi-monthly", out config.gracePeriodSemiMonthlyInDays, out config.isGracePeriodSemiMonthlyEnabled);
      GetGracePeriodFromXml(doc, "Monthly", out config.gracePeriodMonthlyInDays, out config.isGracePeriodMonthlyEnabled);
      GetGracePeriodFromXml(doc, "Quarterly", out config.gracePeriodQuarterlyInDays, out config.isGracePeriodQuarterlyEnabled);
      GetGracePeriodFromXml(doc, "Annually", out config.gracePeriodAnnuallyInDays, out config.isGracePeriodAnnuallyEnabled);
      GetGracePeriodFromXml(doc, "SemiAnnually", out config.gracePeriodSemiAnnuallyInDays, out config.isGracePeriodSemiAnnuallyEnabled);

      GetIsAutoRunEopOnSoftClosedEnabledFromXml(doc, out config.isAutoRunEopOnSoftCloseEnabled);
      GetIsAutoSoftCloseBillGroupsEnabledFromXml(doc, out config.isAutoSoftCloseBillGroupsEnabled);
      GetIsBlockNewAccountsWhenClosingEnabled(doc, out config.isBlockNewAccountsWhenClosingEnabled);
      GetIsRunScheduledAdaptersEnabled(doc, out config.isRunScheduledAdaptersEnabled);
       
      GetMulticastFromXml(doc, out config.multicastAddress, out config.multicastPort, out config.multicastTimeToLive);

      return config;
    }

    /// <summary>
    /// Get the grace period information from the XML file.  If an error occurs, log the
    /// error and set the grace period information to a default value.
    /// If the grace period is less than zero, throws NegativeValueException.
    /// </summary>
    /// <param name="doc">xml document being read</param>
    /// <param name="cycleType">string identifying period matching the name used in the xml file</param>
    /// <param name="days">number of days in grace period, guaranteed to >= 0</param>
    /// <param name="isEnabled">true if grace period is enabled</param>
    private static void GetGracePeriodFromXml(MTXmlDocument doc, string cycleType, out int days, out bool isEnabled)
    {
      // Default values
      days = DEFAULT_GRACE_PERIOD_DAYS;
      isEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;

      try
      {
        // Get node
        XmlNode cycleTypeNode = doc.SelectOnlyNode("/xmlconfig/Intervals/GracePeriods/" + cycleType);
        if (cycleTypeNode == null)
        {
          Logger logger = new Logger("[ConfigCrossServerManager]");
          logger.LogError("usageserver.xml is missing grace period " + cycleType + ".");
          return;
        }

        // Read days
        days = MTXmlDocument.GetNodeValueAsInt(cycleTypeNode);
        if (days < 0)
        {
          Logger logger = new Logger("[ConfigCrossServerManager]");
          logger.LogError("usageserver.xml contains a negative value for " + cycleType + ". Using default.");
          throw new NegativeValueException(cycleType, days);
        }

        // Get enabled item
        XmlNode enabledNode = cycleTypeNode.Attributes.GetNamedItem("enabled");
        if (enabledNode == null)
        {
          Logger logger = new Logger("[ConfigCrossServerManager]");
          logger.LogError("usageserver.xml is missing enabled attribute for grace period " + cycleType + ". Using default.");
          throw new InvalidConfigurationException("Missing enabled attribute for grace period " +
                                                  cycleType + " in usage server configuration.");
        }

        // Read enabled
        isEnabled = MTXmlDocument.GetNodeValueAsBool(enabledNode);
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("Unable to read configuration from usageserver.xml for " + cycleType +
                        ".");
        isEnabled = DEFAULT_GRACE_PERIOD_IS_ENABLED;
        days = DEFAULT_GRACE_PERIOD_DAYS;
        throw;
      }
    }

    /// <summary>
    /// Get the multicast values from the xml document.  
    /// If unable to get the multicast address, then generate a
    /// random address.  If unable to get the other values,
    /// use default values.
    /// </summary>
    /// <param name="doc">xml document to read</param>
    /// <param name="address">multicast address</param>
    /// <param name="port">multicast port</param>
    /// <param name="ttl">multicast ttl</param>
    private static void GetMulticastFromXml(MTXmlDocument doc, out string address, out int port, out int ttl)
    {
      // Get multicast address
      try
      {
        address = doc.GetNodeValueAsString("/xmlconfig/Multicast/Address"); ;
      }
      catch (Exception)
      {
        Random r = new Random();
        address = "224." + (r.Next(0, 255).ToString()) +
                     "." + (r.Next(0, 255).ToString()) +
                     "." + (r.Next(0, 255).ToString());
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogInfo("Multicast address not specified in UsageServer\\usageserver.xml. " +
                       "Randomly generated address = " + address);
      }

      // Get multicast port
      try
      {
        port = doc.GetNodeValueAsInt("/xmlconfig/Multicast/Port"); ;
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogInfo("Multicast port not specified UsageServer\\usageserver.xml. Using default value instead.");
        port = DEFAULT_MULTICAST_PORT;
      }

      // Get multicast ttl
      try
      {
        ttl = doc.GetNodeValueAsInt("/xmlconfig/Multicast/TTL"); ;
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogInfo("Multicast TTL not specified in UsageServer\\usageserver.xml. Using default value instead.");
        ttl = DEFAULT_MULTICAST_TTL;
      }
    }

    /// <summary>
    /// Read "automatically run EOP adapters on soft closed billing groups" from XML.
    /// </summary>
    /// <param name="doc"></param>
    /// <param name="isAutoRunEopOnSoftCloseEnabled"></param>
    private static void GetIsAutoRunEopOnSoftClosedEnabledFromXml(MTXmlDocument doc, out bool isAutoRunEopOnSoftCloseEnabled)
    {
      try
      {
        isAutoRunEopOnSoftCloseEnabled = doc.GetNodeValueAsBool("/xmlconfig/Service/SubmitEventsForExecution");
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("Unable to read SubmitEventsForExecution from UsageServer\\usageserver.xml. " +
                        "Using default value instead.");
        isAutoRunEopOnSoftCloseEnabled = DEFAULT_IS_AUTO_RUN_EOP_ON_SOFT_CLOSED_ENABLED;
      }
    }
    
    /// <summary>
    /// Read "automatically soft close the billing groups of expired usage intervals" from XML.
    /// </summary>
    /// <param name="doc"></param>
    /// <param name="isAutoSoftCloseBillGroupsEnabled"></param>
    private static void GetIsAutoSoftCloseBillGroupsEnabledFromXml(MTXmlDocument doc, out bool isAutoSoftCloseBillGroupsEnabled)
    {
      try
      {
        isAutoSoftCloseBillGroupsEnabled = doc.GetNodeValueAsBool("/xmlconfig/Service/SoftCloseIntervals");
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("Unable to read SoftCloseIntervals from UsageServer\\usageserver.xml. " +
                        "Using default value instead.");
        isAutoSoftCloseBillGroupsEnabled = DEFAULT_IS_AUTO_SOFT_CLOSE_BILL_GROUPS_ENABLED;
      }
    }

    /// <summary>
    /// Read setting for "when automatically closing intervals, block the intervals to new accounts"
    /// from the given XML document.
    /// </summary>
    /// <param name="doc"></param>
    /// <param name="isBlockIntervalsWhenClosingEnabled"></param>
    private static void GetIsBlockNewAccountsWhenClosingEnabled(MTXmlDocument doc, out bool isBlockIntervalsWhenClosingEnabled)
    {
      try
      {
        XmlNode softCloseIntervalsNode = doc.SelectOnlyNode("/xmlconfig/Service/SoftCloseIntervals");
        if (softCloseIntervalsNode == null)
        {
          Logger logger = new Logger("[ConfigCrossServerManager]");
          logger.LogError("Unable to read SoftCloseIntervals missing from UsageServer\\usageserver.xml. " +
                          "Using default value instead.");

          isBlockIntervalsWhenClosingEnabled = DEFAULT_IS_BLOCK_NEW_ACCOUNTS_WHEN_CLOSING_ENABLED;
          return;
        }

        XmlNode blockNewAccounts =
          softCloseIntervalsNode.Attributes.GetNamedItem("blockNewAccounts");

        if (blockNewAccounts == null)
        {
          Logger logger = new Logger("[ConfigCrossServerManager]");
          logger.LogError("Unable to read blockNewAccountsfrom UsageServer\\usageserver.xml. Using default value instead.");

          isBlockIntervalsWhenClosingEnabled = DEFAULT_IS_BLOCK_NEW_ACCOUNTS_WHEN_CLOSING_ENABLED;
        }

        isBlockIntervalsWhenClosingEnabled = MTXmlDocument.GetNodeValueAsBool(blockNewAccounts);
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("Unable to read SoftCloseIntervals from UsageServer\\usageserver.xml. " +
                        "Using default value instead.");
        isBlockIntervalsWhenClosingEnabled = DEFAULT_IS_BLOCK_NEW_ACCOUNTS_WHEN_CLOSING_ENABLED;
      }
    }

    /// <summary>
    /// Read "are scheduled adapters enabled" from the given xml document.
    /// </summary>
    /// <param name="doc"></param>
    /// <param name="isRunScheduledAdaptersEnabled"></param>
    private static void GetIsRunScheduledAdaptersEnabled(MTXmlDocument doc, out bool isRunScheduledAdaptersEnabled)
    {
      try
      {
        isRunScheduledAdaptersEnabled = doc.GetNodeValueAsBool("/xmlconfig/Service/InstantiateScheduledEvents");
      }
      catch (Exception)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("Unable to read InstantiateScheduledEvents from UsageServer\\usageserver.xml. " +
                        "Using default value instead.");
        isRunScheduledAdaptersEnabled = DEFAULT_IS_RUN_SCHEDULED_ADAPTERS_ENABLED;
      }

    }

    /// <summary>
    /// Validates a set of multicast settings.
    /// </summary>
    private void ValidateMulticastSettings(string address, int port, int ttl)
    {
      // Validate address
      if (address.Split('.').Length != 4 ||
          !address.Split('.')[0].Equals("224"))
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("The configuration value for multicast address is invalid: " + address +
                          ". The address must start with 224 and have 4 segments separated by periods.");
      }

      // Validate port
      if (port < 0 || port > 65535)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("The configuration value for multicast port is invalid: " + port);
      }

      // Validate TTL
      if (ttl < 0)
      {
        Logger logger = new Logger("[ConfigCrossServerManager]");
        logger.LogError("The configuration value for multicast time to live is illegal: " + ttl);
      }
    }

    private static string DEFAULT_MULTICAST_ADDRESS = "224.5.6.7";
    private static int DEFAULT_MULTICAST_PORT = 5001;
    private static int DEFAULT_MULTICAST_TTL = 2;
    private static int DEFAULT_GRACE_PERIOD_DAYS = 0;
    private static bool DEFAULT_GRACE_PERIOD_IS_ENABLED = true;
    private static bool DEFAULT_IS_AUTO_RUN_EOP_ON_SOFT_CLOSED_ENABLED = true;
    private static bool DEFAULT_IS_AUTO_SOFT_CLOSE_BILL_GROUPS_ENABLED = true;
    private static bool DEFAULT_IS_BLOCK_NEW_ACCOUNTS_WHEN_CLOSING_ENABLED= true;
    private static bool DEFAULT_IS_RUN_SCHEDULED_ADAPTERS_ENABLED = true;
  }
}
