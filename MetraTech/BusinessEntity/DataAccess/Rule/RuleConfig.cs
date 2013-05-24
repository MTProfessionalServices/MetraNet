using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Linq;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Exception;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Persistence;

namespace MetraTech.BusinessEntity.DataAccess.Rule
{
  /// <summary>
  /// </summary>
  public static class RuleConfig
  {
    #region Public Methods
    static RuleConfig()
    {
      entityRules = new Dictionary<string, Dictionary<CRUDEvent, List<RuleData>>>();

      // Get all the rule files
      List<string> ruleFiles = GetRuleFiles();

      foreach(string ruleFile in ruleFiles)
      {
        string entityName;
        Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent = GetRuleData(ruleFile, out entityName);

        if (String.IsNullOrEmpty(entityName))
        {
          logger.Warn(String.Format("Cannot get rule data from rule file '{0}'", ruleFile));
          continue;
        }
        
        if (entityRules.ContainsKey(entityName))
        {
          logger.Warn(String.Format("Found more than one rule file '{0}' for the same entity '{1}'", ruleFile, entityName));
          continue;
        }

        entityRules.Add(entityName, ruleDataByEvent);
      }
    }

    public static bool HasRules(string entityName, CRUDEvent crudEvent)
    {
      return GetRules(entityName, crudEvent).Count > 0;
    }

    public static List<RuleData> GetRules(string entityName)
    {
      var ruleDataList = new List<RuleData>();

      Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent;
      entityRules.TryGetValue(entityName, out ruleDataByEvent);

      if (ruleDataByEvent != null)
      {
        foreach(CRUDEvent crudEvent in ruleDataByEvent.Keys)
        {
          ruleDataList.AddRange(ruleDataByEvent[crudEvent]);
        }
      }

      return ruleDataList;
    }

    public static List<RuleData> GetRules(string entityName, CRUDEvent crudEvent)
    {
      var ruleDataList = new List<RuleData>();

      Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent;
      entityRules.TryGetValue(entityName, out ruleDataByEvent);

      if (ruleDataByEvent != null)
      {
        List<RuleData> rules;
        ruleDataByEvent.TryGetValue(crudEvent, out rules);
        if (rules != null)
        {
          ruleDataList = rules;
        }
      }

      return ruleDataList;
    }

    public static void ClearRules(string entityName)
    {
      string ruleFile;
      XElement entityElement = GetEntityElement(entityName, out ruleFile);
      if (entityElement != null)
      {
        File.Delete(ruleFile);
      }
    }

    /// <summary>
    ///   Deletes the rules found in assemblyNameWithPath from ruleDataEvent
    /// </summary>
    /// <param name="entityName"></param>
    /// <param name="assemblyNameWithPath"></param>
    /// <param name="ruleDataByEvent"></param>
    public static void DeleteRuleData(string entityName, 
                                      string assemblyNameWithPath,
                                      ref Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      Dictionary<CRUDEvent, List<RuleData>> deleteRulesByEvent =
        AppDomainHelper.GetRulesFromAssembly(entityName, assemblyNameWithPath);

      foreach (CRUDEvent crudEvent in ruleDataByEvent.Keys)
      {
        List<RuleData> ruleDataList;
        ruleDataByEvent.TryGetValue(crudEvent, out ruleDataList);
        if (ruleDataList != null)
        {
          List<RuleData> deleteRuleDataList;
          deleteRulesByEvent.TryGetValue(crudEvent, out deleteRuleDataList);
          if (deleteRuleDataList != null)
          {
            foreach(RuleData ruleData in deleteRuleDataList)
            {
              if (ruleDataList.Contains(ruleData))
              {
                ruleDataList.Remove(ruleData);
              }
            }
          }
        }
      }
    }

    public static void UpdateRuleData(string entityName, 
                                      string assemblyNameWithPath,
                                      ref Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      Dictionary<CRUDEvent, List<RuleData>> newRulesByEvent =
        AppDomainHelper.GetRulesFromAssembly(entityName, assemblyNameWithPath);

      foreach (CRUDEvent crudEvent in newRulesByEvent.Keys)
      {
        List<RuleData> ruleDataList;
        ruleDataByEvent.TryGetValue(crudEvent, out ruleDataList);
        if (ruleDataList == null)
        {
          ruleDataByEvent.Add(crudEvent, newRulesByEvent[crudEvent]);
        }
        else
        {
          var newRules = newRulesByEvent[crudEvent];
          foreach(RuleData ruleData in newRules)
          {
            // If the rule does not exist, add it
            if (!ruleDataList.Contains(ruleData))
            {
              ruleDataList.Add(ruleData);
            }
          }
        }
      }
    }

    public static void SaveRuleData(string entityName, Dictionary<CRUDEvent, List<RuleData>> ruleDataByEvent)
    {
      XElement entityElement = CreateEntityElement(entityName, ruleDataByEvent);
      string ruleFile = GetRuleFile(entityName);
      using (var writer = new StreamWriter(new FileStream(ruleFile, FileMode.Create), Encoding.UTF8))
      {
        entityElement.Save(writer);
        writer.Flush();
      }
    }

    public static string GetRuleFile(string entityName)
    {
      string extensionName, entityGroupName;
      Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);

      string ruleDir = SystemConfig.GetRuleDir(extensionName, entityGroupName);

      return Path.Combine(ruleDir, entityName + ".xml");
    }

    public static List<string> GetRuleFiles()
    {
      var ruleFiles = new List<string>();

      Dictionary<string, List<string>> entityGroupsByExtension = SystemConfig.GetEntityGroupsByExtension();

      foreach (string extensionName in entityGroupsByExtension.Keys)
      {
        List<string> entityGroupNames = entityGroupsByExtension[extensionName];
        foreach (string entityGroupName in entityGroupNames)
        {
          string ruleDir = SystemConfig.GetRuleDir(extensionName, entityGroupName);
          if (Directory.Exists(ruleDir))
          {
            string[] files = Directory.GetFiles(ruleDir, extensionName + "." + entityGroupName + "*.xml");
            ruleFiles.AddRange(files.ToList());
          }
        }
      }

      return ruleFiles;
    }

    public static Dictionary<CRUDEvent, List<RuleData>> GetRulesByEvent(string entityName)
    {
      var rulesByEvent = new Dictionary<CRUDEvent, List<RuleData>>();

      List<RuleData> ruleDataList = GetRules(entityName);

      foreach (RuleData ruleData in ruleDataList)
      {
        List<RuleData> eventRuleDataList;
        rulesByEvent.TryGetValue(ruleData.Event, out eventRuleDataList);
        if (eventRuleDataList == null)
        {
          eventRuleDataList = new List<RuleData>();
          rulesByEvent.Add(ruleData.Event, eventRuleDataList);
        }

        eventRuleDataList.Add(ruleData);
      }

      return rulesByEvent;
    }
    #endregion

    #region Private Methods
    
    private static XElement CreateEntityElement(string entityName,
                                                Dictionary<CRUDEvent, List<RuleData>> rulesByEvent)
    {
      // Write out the xml based on newRulesByEvent
      XElement entityElement = new XElement("entity",
                               new XAttribute("name", entityName));

      foreach (CRUDEvent crudEvent in rulesByEvent.Keys)
      {
        XElement eventElement = new XElement("event", new XAttribute("name", crudEvent.ToString()));
        entityElement.Add(eventElement);

        List<RuleData> eventRules = rulesByEvent[crudEvent];
        foreach (RuleData ruleData in eventRules)
        {
          eventElement.Add(new XElement("rule",
                           new XAttribute("name", ruleData.Name),
                           new XAttribute("description", ruleData.Description),
                           new XAttribute("priority", ruleData.Priority),
                           new XAttribute("enabled", ruleData.Enabled),
                           new XAttribute("type", ruleData.AssemblyQualifiedTypeName)));

        }
      }

      return entityElement;
    }

    private static XElement GetEntityElement(string entityName, out string ruleFile)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);

      XElement entityElement = null;

      ruleFile = GetRuleFile(entityName);
      if (!File.Exists(ruleFile))
      {
        logger.Debug(String.Format("Cannot find rule file for entity '{0}'", entityName));
        return entityElement;
      }

      entityElement = XElement.Load(ruleFile);

      Check.Require(entityElement.Attribute("name") != null,
                    String.Format("Cannot find 'name' attribute for 'entity' element in file '{0}'", ruleFile),
                    SystemConfig.CallerInfo);

      Check.Require(entityElement.Attribute("name").Value == entityName,
                    String.Format("The value of the 'name' attribute '{0}' does not match the entity name '{1}' in file '{2}'",
                                   entityElement.Attribute("name").Value, entityName, ruleFile),
                    SystemConfig.CallerInfo);

      return entityElement;
    }

    private static Dictionary<CRUDEvent, List<RuleData>> GetRuleData(string ruleFile, out string entityName)
    {
      entityName = null;
      var ruleDataByEvent = new Dictionary<CRUDEvent, List<RuleData>>();

      if (!File.Exists(ruleFile))
      {
        return ruleDataByEvent;
      }

      XElement entityElement = XElement.Load(ruleFile);

      Check.Require(entityElement.Attribute("name") != null && !String.IsNullOrEmpty(entityElement.Attribute("name").Value),
                    String.Format("Empty or missing 'name' attribute for 'entity' element in file '{0}'", ruleFile));

      entityName = entityElement.Attribute("name").Value;

      if (!MetadataRepository.Instance.HasEntity(entityName))
      {
        logger.Warn(String.Format("Cannot find entity '{0}' specified in rule file '{1}'", entityName, ruleFile));
        entityName = null;
        return ruleDataByEvent;
      }

      try
      {
        logger.Debug(String.Format("Getting RuleData for entity '{0}' from file '{1}'", entityName, ruleFile));

        foreach (XElement eventElement in entityElement.Elements("event"))
        {
          Check.Require(eventElement.Attribute("name") != null && !String.IsNullOrEmpty(eventElement.Attribute("name").Value),
                        String.Format("Empty or missing 'name' attribute for 'event' element in file '{0}'", ruleFile));

          var crudEvent = (CRUDEvent)Enum.Parse(typeof(CRUDEvent), eventElement.Attribute("name").Value, true);

          List<RuleData> eventRules;
          GetRulesForEvent(eventElement, entityName, out eventRules);
          ruleDataByEvent.Add(crudEvent, eventRules);
        }
      }
      catch (System.Exception e)
      {
        string message = String.Format("Cannot read rules for entity '{0}' from file '{1}'", entityName, ruleFile);
        throw new RuleException(message, e);
      }

      return ruleDataByEvent;
    }

    private static List<ErrorObject> GetRulesForEvent(XElement eventElement, string entityName, out List<RuleData> ruleDataList)
    {
      Check.Require(eventElement != null, "eventElement cannot be null", SystemConfig.CallerInfo);

      string eventName = eventElement.Attribute("name").Value;

      Check.Require(!String.IsNullOrEmpty(eventName), "eventName cannot be null", SystemConfig.CallerInfo);
      var crudEvent = (CRUDEvent) Enum.Parse(typeof (CRUDEvent), eventName); 

      ruleDataList = new List<RuleData>();
      var errors = new List<ErrorObject>();

      try
      {
        List<XElement> rules = eventElement.Descendants("rule").ToList();
        foreach (XElement rule in rules)
        {
          var ruleData = new RuleData()
                           {
                             EntityName = entityName,
                             Event = crudEvent,
                             Name = rule.Attribute("name").Value,
                             Description = rule.Attribute("description").Value,
                             Priority = Convert.ToInt32(rule.Attribute("priority").Value),
                             Enabled = Convert.ToBoolean(rule.Attribute("enabled").Value),
                             AssemblyQualifiedTypeName = rule.Attribute("type").Value
                           };

          errors.AddRange(ruleData.Validate());
          ruleDataList.Add(ruleData);
        }
      }
      catch (System.Exception e)
      {
        errors.Add(new ErrorObject(String.Format("Error getting rule data for entity '{0}' : '{1}'", entityName, e.Message)));
      }

      // Sort by priority
      ruleDataList.Sort(new RuleDataPrioritySorter());

      return errors;
    }
    #endregion

    #region Data

    private static Dictionary<string, Dictionary<CRUDEvent, List<RuleData>> >entityRules;
    private static readonly ILog logger = LogManager.GetLogger("RuleConfig");
    #endregion
  }
}
