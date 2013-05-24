using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using MetraTech.DataAccess;
using MetraTech.Xml;
using System.Xml;
using MetraTech.UsageServer;
using MetraTech;

namespace MetraTech.UsageServer
{
  // Concurrency rules define which adapters can run at the same time as other adapters
  // The implementation consists of
  // ConcurrencyRule - a single rule
  // ConcurrencyRules - a container of rules indexed by the event name
  // ConcurrencyRulesManager - a helper class used by Events.cs to write rules to the database

  /// <summary>
  /// Concurrency rules define which adapters can run at the same time as other adapters
  /// </summary>
  public class ConcurrencyRule
  {
    public string EventName { get; set; }
    public string CanRunWith { get; set; }
    public bool CanRunWithAll { get; set; }

    public override string ToString()
    {
      return string.Format("Adapter Concurrency Rule: {0} can run with {1}", EventName,
                           CanRunWithAll ? "All" : CanRunWith);
    }
  }

  /// <summary>
  /// Container for concurrency rules; organizes rules as a collection for a given event name
  /// </summary>
  public class ConcurrencyRules : Dictionary<string, List<ConcurrencyRule>>
  {
    public string FilePath { get; set; }
    public MachineRule DefaultRule { get; set; }

    /// <summary>
    /// Reads the concurrency rules from the given file and adds them to the collection
    /// </summary>
    /// <param name="fileName"></param>
    public void ReadConcurrencyRulesFromFile(string fileName)
    {
      try
      {
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(fileName);

        //
        // reads in concurrency rules
        //
        foreach (XmlNode ruleNode in doc.SelectNodes("/xmlconfig/AdapterConcurrencyRules/Rule"))
        {
          try
          {
            AddRule(ReadConcurrencyRuleFromNode(ruleNode));
          }
          catch (Exception ex)
          {
            throw new Exception(string.Format("Unable to read/add concurrency rule for xml node: {1}", ruleNode.ToString(), ex.Message), ex);
          }

        }
      }
      catch(Exception ex)
      {
        throw new Exception(string.Format("Unable to read concurrency rule file {0}: {1}", fileName, ex.Message),ex);
      }
    }

    /// <summary>
    /// Adds the rule to the collection
    /// </summary>
    /// <param name="rule"></param>
    public void AddRule(ConcurrencyRule rule)
    {
      if (string.IsNullOrEmpty(rule.EventName))
        throw new Exception("Concurrency rule event name must be specified");

      if (!this.ContainsKey(rule.EventName))
        this[rule.EventName] = new List<ConcurrencyRule>();

      this[rule.EventName].Add(rule);
    }

    /// <summary>
    /// Parses the xml node for a single rule and returns the rule
    /// </summary>
    /// <param name="ruleNode"></param>
    /// <returns></returns>
    public ConcurrencyRule ReadConcurrencyRuleFromNode(XmlNode ruleNode)
    {
      ConcurrencyRule rule = new ConcurrencyRule();

      rule.EventName = MTXmlDocument.GetNodeValueAsString(ruleNode, "Adapter");
      if (ruleNode.SelectSingleNode("CanRunWithAll") != null)
        rule.CanRunWithAll = true;
      else
      {
        rule.CanRunWithAll = false;
        rule.CanRunWith = MTXmlDocument.GetNodeValueAsString(ruleNode, "CanRunWith", null);
      }

      return rule;
    }

  }
}

/// <summary>
/// Helper class for the reading and writing of rules to the database
/// Note that the implementation intentially relies on stored procedures
/// that should contain the knowledge of how to organize the rules in
/// the database for processing. This is to allow for future modifications
/// or enhancements to be done through modification of the database inserting,
/// instantiation and querying to be done without necessarily needing to modify
/// the code.
/// </summary>
public class ConcurrencyRulesManager
{
  public const string ALL_SPECIFIER_IN_DATABASE = "ALL";

  internal static void SetConcurrencyRulesInDatabase(IMTConnection conn, ConcurrencyRules rules, Logger logger)
  {
    //First, initialized/clear all the existing rules
    InitializeConcurrencyRulesInDatabase(conn);

    //Then, add each rule
    foreach (string eventName in rules.Keys)
    {
      foreach(ConcurrencyRule rule in rules[eventName])
        AddConcurrencyRuleToDatabase(conn, rule, logger);
    }

    //Finally, call stored procedure to instantiate the working set of rules
    FinalizeConcurrencyRulesInDatabase(conn);
  }

  private static void FinalizeConcurrencyRulesInDatabase(IMTConnection conn)
  {
    int status;
    using (IMTCallableStatement stmt = conn.CreateCallableStatement("AdapterConcurrencyFinalize"))
    {
      stmt.AddOutputParam("status", MTParameterType.Integer);
      stmt.ExecuteNonQuery();
      status = (int)stmt.GetOutputValue("status");
    }

    switch (status)
    {
      // success	
      case 0:
        //mLogger.LogDebug("Adapter concurrency rules were successfully finalized.");
        return;

      default:
        string msg = String.Format("Adapter concurrency rules could not be finalized: AdapterConcurrencyFinalize returned {0}", status);
        throw new UsageServerException(msg);
    }
  }

  /// <summary>
  /// Called to indicate the start of the setting of concurrency rules
  /// </summary>
  /// <param name="conn"></param>
  protected static void InitializeConcurrencyRulesInDatabase(IMTConnection conn)
  {
    int status;
    using (IMTCallableStatement stmt = conn.CreateCallableStatement("AdapterConcurrencyInitialize"))
    {
      stmt.AddOutputParam("status", MTParameterType.Integer);
      stmt.ExecuteNonQuery();
      status = (int)stmt.GetOutputValue("status");
    }

    switch (status)
    {
      // success	
      case 0:
        //mLogger.LogDebug("Adapter concurrency rules were successfully initialized.");
        return;

      default:
        string msg = String.Format("Adapter concurrency rules could not be initialized: AdapterConcurrencyInitialize returned {0}", status);
        throw new UsageServerException(msg);
    }
  }

  /// <summary>
  /// Called to add a rule to the database
  /// </summary>
  /// <param name="conn"></param>
  /// <param name="rule"></param>
  /// <param name="logger"></param>
  protected static void AddConcurrencyRuleToDatabase(IMTConnection conn, ConcurrencyRule rule, Logger logger)
  {
    string compatibleEventName;
    if (rule.CanRunWithAll)
      compatibleEventName = ALL_SPECIFIER_IN_DATABASE;
    else
      compatibleEventName = rule.CanRunWith;

    int status;
    using (IMTCallableStatement stmt = conn.CreateCallableStatement("AdapterConcurrencyAddRule"))
    {
      stmt.AddParam("eventname", MTParameterType.String, rule.EventName);
      stmt.AddParam("compatibleeventname", MTParameterType.String, compatibleEventName);
      stmt.AddOutputParam("status", MTParameterType.Integer);
      stmt.ExecuteNonQuery();
      status = (int)stmt.GetOutputValue("status");
    }

    switch (status)
    {
      // success	
      case 0:
        //mLogger.LogDebug("Added concurrency rule to database {0} Can Run With {1}", rule.EventName, compatibleEventName);
        return;
      case -1:
        string msg1 = String.Format("Adapter concurrency rule specifies an unknown event/adapter name {0}: Skipping {1}", rule.EventName, rule);
        logger.LogDebug(msg1);
        //throw new UsageServerException(msg1);
        break;
      case -2:
        string msg2 = String.Format("Adapter concurrency rule specifies an unknown compatible event/adapter name {0}: Skipping {1}", rule.CanRunWith, rule);
        logger.LogDebug(msg2);
        //throw new UsageServerException(msg2);
        break;
      default:
        string msg = String.Format("Adapter concurrency rule could not be added: AdapterConcurrencyAddRule returned unknown error code {0}", status);
        throw new UsageServerException(msg);
    }  

  }

}

