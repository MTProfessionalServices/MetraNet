using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using MetraTech.DataAccess;
using MetraTech.Xml;
using System.Xml;
using MetraTech.UsageServer;

namespace MetraTech.UsageServer
{
  //  Machine rules specify which event/adapter can run on which machine.
  // The implementation consists of
  // MachineRule - a single rule
  // MachineRules - a container of rules indexed by the event name
  // MachineRulesManager - a helper class used by Events.cs to write rules to the database
  
  /// <summary>
  /// MachineRule defines which events can run on which machines
  /// </summary>
  public class MachineRule
  {
    public string EventName { get; set; }
    public string MachineSpecifier{ get; set; }

    public const string ALL_SPECIFIER = "All";

    public MachineRule()
    {
    }

    public MachineRule(string eventName, string machineSpecifier)
    {
      this.EventName = eventName;
      this.MachineSpecifier = machineSpecifier;
    }

    /// <summary>
    /// Populate the rule from a given Xml node
    /// </summary>
    /// <param name="ruleNode"></param>
    /// <returns></returns>
    public static MachineRule ReadFromXml(XmlNode ruleNode)
    {
      string eventName = MTXmlDocument.GetNodeValueAsString(ruleNode, "Adapter");
      if (string.IsNullOrEmpty(eventName))
      {
        throw new Exception(string.Format("<Adapter> must be specified for machine rule in tag: {0}", ruleNode.InnerXml));
      }

      string machine = MTXmlDocument.GetNodeValueAsString(ruleNode, "RunOn");
      if (string.IsNullOrEmpty(machine))
      {
        throw new Exception(string.Format("<RunOn> must be specified for machine rule in tag: {0}", ruleNode.InnerXml));
      }

      return new MachineRule(eventName,machine);
    }

    /// <summary>
    /// Summary information on the rule in string form (useful for debugging and display)
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      return string.Format("MachineRule: {0} can run on {1}", (EventName == null) ? "NULL" : EventName, (MachineSpecifier == null) ? "NULL" : MachineSpecifier);
    }

    /// <summary>
    /// Override for the == operator to determine if the rules are the same; used by usm sync
    /// </summary>
    /// <param name="a"></param>
    /// <param name="b"></param>
    /// <returns></returns>
    public static bool operator ==(MachineRule a, MachineRule b)
    {
      // If both are null, or both are same instance, return true.
      if (System.Object.ReferenceEquals(a, b))
      {
        return true;
      }

      // If one is null, but not both, return false.
      if (((object)a == null) || ((object)b == null))
      {
        return false;
      }

      // Return true if the fields match:
      return a.EventName == b.EventName && a.MachineSpecifier == b.MachineSpecifier;
    }

    public static bool operator !=(MachineRule a, MachineRule b)
    {
      return !(a == b);
    }

    /// <summary>
    /// Override for the Equals operator, tailored for MachineRule (avoids compiler warnings)
    /// </summary>
    /// <param name="obj"></param>
    /// <returns></returns>
    public override bool Equals(System.Object obj)
    {
      // If parameter cannot be cast to ThreeDPoint return false:
      MachineRule a = obj as MachineRule;
      if ((object)a == null)
      {
        return false;
      }

      // Return true if the fields match:
      return (this == a);
    }

    /// <summary>
    /// Override for the Equals operator, tailored for MachineRule (avoids compiler warnings)
    /// </summary>
    public bool Equals(MachineRule a)
    {
      // Return true if the fields match:
      return (this == a);
    }

    /// <summary>
    /// Override for the GetHashCode operator, tailored for MachineRule (avoids compiler warnings)
    /// </summary>
    public override int GetHashCode()
    {
      int hash = 17;
      if (EventName != null)
        hash = hash * 23 + EventName.GetHashCode();
      if (MachineSpecifier != null)
        hash = hash * 23 + MachineSpecifier.GetHashCode();

      return hash;
    }
  }

  /// <summary>
  /// Variation to handle reading of default rule from the xml file
  /// </summary>
  public class MachineDefaultRule : MachineRule
  {
    /// <summary>
    /// Populate the default rule from a given Xml node
    /// </summary>
    /// <param name="ruleNode"></param>
    /// <returns></returns>
    public static new MachineRule ReadFromXml(XmlNode ruleNode)
    {
      string eventName = ALL_SPECIFIER;

      string machine = MTXmlDocument.GetNodeValueAsString(ruleNode, "RunOn");
      if (string.IsNullOrEmpty(machine))
      {
        throw new Exception(string.Format("<RunOn> must be specified for machine rule in tag: {0}", ruleNode.InnerXml));
      }

      return new MachineRule(eventName, machine);
    }  
  }

  /// <summary>
  /// Collection of machine rules that can be referenced by event name
  /// </summary>
  public class MachineRules : Dictionary<string, List<MachineRule>>
  {
    public string FilePath { get; set; }
    public string Extension { get; set; }
    public MachineRule DefaultRule { get; set; }

    /// <summary>
    /// Adds a rule to the collection, creating the appropriate entries as needed
    /// </summary>
    /// <param name="machineRule"></param>
    public void AddRule(MachineRule machineRule)
    {
      if (string.IsNullOrEmpty(machineRule.EventName))
        throw new Exception("Machine rule event name must be specified");

      if (!this.ContainsKey(machineRule.EventName))
        this[machineRule.EventName] = new List<MachineRule>();

      this[machineRule.EventName].Add(machineRule);
    }

    /// <summary>
    /// Helper method to get the list of machine rules for a given event
    /// If the event has no rules in this collection, the default rule is 
    /// returned.
    /// </summary>
    /// <param name="eventName"></param>
    /// <returns></returns>
    public List<MachineRule> GetMachineRulesForEvent(string eventName)
    {
      List<MachineRule> results;
      if (!this.TryGetValue(eventName, out results))
      {
        //No machine rules are specified for this event in this collection
        //Return the default rule instead
        results = new List<MachineRule>();
        if (DefaultRule != null)
        {
          MachineRule defaultRule = new MachineRule(eventName, DefaultRule.MachineSpecifier);
          results.Add(defaultRule);
        }
      }

      return results;
    }

    /// <summary>
    /// Helper method for Events.cs which uses ArrayLists
    /// </summary>
    /// <param name="eventName"></param>
    /// <returns>The rules for a given event converted to an ArrayList</returns>
    public ArrayList GetMachineRulesAsArrayListForEvent(string eventName)
    {
      List<MachineRule> temp = GetMachineRulesForEvent(eventName);
      //Looked for a better way to convert without success; may update this
      ArrayList result = new ArrayList(temp.Count);
      foreach (MachineRule rule in temp)
        result.Add(rule);

      return result;
    }

    /// <summary>
    /// Adds the machine rules contained in the specified file to the current collection
    /// </summary>
    /// <param name="fileName"></param>
    public void ReadMachineRulesFromFile(string fileName)
    {
      try
      {
        MTXmlDocument doc = new MTXmlDocument();
        doc.Load(fileName);

        //reads the default rule if it exists
        XmlNode defaultruleNode = doc.SelectSingleNode("/xmlconfig/AdapterMachineRules/DefaultRule");
        XmlNodeList defaultruleNodes = doc.SelectNodes("/xmlconfig/AdapterMachineRules/DefaultRule");
        if (defaultruleNodes.Count>0)
        {
          if (defaultruleNodes.Count>1)
            throw new Exception(String.Format("The file contains more than 1 default rule"));
          else
            this.DefaultRule = MachineDefaultRule.ReadFromXml(defaultruleNodes[0]);
        }

        //
        // reads in machine rules
        //
        foreach (XmlNode ruleNode in doc.SelectNodes("/xmlconfig/AdapterMachineRules/Rule"))
        {
          AddRule(MachineRule.ReadFromXml(ruleNode));
        }
      }
      catch(Exception ex)
      {
        throw new Exception(string.Format("Unable to read machine rules file {0}: {1}", fileName, ex.Message), ex);
      }
    }

    /// <summary>
    /// Returns a default set of rules to be used in the absence of any other machine rules
    /// Current default is that any adapter can run on any machine
    /// </summary>
    /// <returns></returns>
    public static MachineRules GetDefaultMachineRules()
    {
      MachineRules result = new MachineRules();
      result.DefaultRule = new MachineRule(MachineRule.ALL_SPECIFIER, MachineRule.ALL_SPECIFIER);

      return result;
    }
  }
}

/// <summary>
/// Helper methods for Events.cs to read/write machine rules from the database
/// </summary>
public class MachineRuleManager
{

  /// <summary>
  /// Given a collection of events, writes the machine rules for the event to the database
  /// </summary>
  /// <param name="conn"></param>
  /// <param name="newEvents"></param>
  public static void AddMachineRulesToDatabase(IMTConnection conn, ArrayList newEvents)
  {
    string insertMachineRuleQuery = "insert into t_recevent_machine (id_event, tx_canrunonmachine) values (?, ?)";

    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(insertMachineRuleQuery))
    {
      // iterates over each event to be added
      foreach (RecurringEvent recurringEvent in newEvents)
      {
        // iterates over each machinerule of the event to be added
        foreach (MachineRule rule in recurringEvent.MachineRules)
          AddMachineRuleToDatabase(stmt, recurringEvent, rule);
      }
    }
  }

  /// <summary>
  /// Writes the single machine rule for the event to the database
  /// Note that the statement must be prepared ahead of time and passed
  /// to this method
  /// </summary>
  /// <param name="stmt"></param>
  /// <param name="recurringEvent"></param>
  /// <param name="rule"></param>
  protected static void AddMachineRuleToDatabase(IMTPreparedStatement stmt, RecurringEvent recurringEvent,
                             MachineRule rule)
  {
    stmt.ClearParams();
    stmt.AddParam(MTParameterType.Integer, recurringEvent.EventID);
    stmt.AddParam(MTParameterType.String, rule.MachineSpecifier);

    stmt.ExecuteNonQuery();
  }

  /// <summary>
  /// Reads the existing machine rules from the database
  /// </summary>
  /// <param name="conn"></param>
  /// <returns></returns>
  public static MachineRules ReadMachineRulesFromDatabase(IMTConnection conn)
  {
    //
    // read the dependencies that the database currently knows about.
    //
    using (IMTStatement stmt =
        conn.CreateStatement(
            "select re.id_event, re.tx_name, rem.tx_canrunonmachine from t_recevent_machine rem " +
            "inner join t_recevent re on re.id_event = rem.id_event " +
            "where re.dt_deactivated is null"))
    {
      MachineRules rules = new MachineRules();
      
      using (IMTDataReader reader = stmt.ExecuteReader())
      {
        while (reader.Read())
        {
          int eventID = reader.GetInt32(0);
          string eventName = reader.GetString(1);
          string machine = reader.GetString(2);

          rules.AddRule(new MachineRule(eventName,machine));
        }
      }

      return rules;
    }
  }
}

