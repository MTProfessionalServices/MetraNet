using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Reflection;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Rule;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  /// <summary>
  /// </summary>
  public class TypeLoader : MarshalByRefObject
  {
    public string GetPropertyTypeName(string assemblyName, string classNameWithNamespace, string propertyName)
    {
      Check.Require(!String.IsNullOrEmpty(assemblyName), "assemblyName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(classNameWithNamespace), "classNameWithNamespace cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty", SystemConfig.CallerInfo);

      string propertyTypeName = String.Empty;

      Assembly assembly = Assembly.Load(assemblyName);

      Type type = assembly.GetType(classNameWithNamespace, true);
      PropertyInfo propertyInfo = type.GetProperty(propertyName);

      if (propertyInfo == null)
      {
        string errorMessage = String.Format("The specified property name '{0}' cannot be found for class '{1}' in assembly '{2}'", propertyName, classNameWithNamespace, assemblyName);
        throw new MetadataException(errorMessage, SystemConfig.CallerInfo);
      }

      propertyTypeName = propertyInfo.PropertyType.FullName;

      return propertyTypeName;
    }

    public Dictionary<CRUDEvent, List<RuleData>> GetRulesFromAssembly(string entityName, string assemblyNameWithPath)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(assemblyNameWithPath), "assemblyNameWithPath cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(File.Exists(assemblyNameWithPath), String.Format("Cannot find file '{0}'", assemblyNameWithPath), SystemConfig.CallerInfo);

      var rulesByEvent = new Dictionary<CRUDEvent, List<RuleData>>();

      Assembly assembly = Assembly.Load(Path.GetFileNameWithoutExtension(assemblyNameWithPath));
      Check.Require(assembly != null, String.Format("Cannot load assembly '{0}'", assemblyNameWithPath));

      foreach(Type type in assembly.GetTypes())
      {
        object[] attributes = type.GetCustomAttributes(typeof(RuleInfoAttribute), false);
        if (attributes == null || attributes.Length == 0) continue;

        RuleInfoAttribute ruleInfoAttribute = attributes.Cast<RuleInfoAttribute>().Single();

        if (ruleInfoAttribute != null)
        {
          RuleData ruleData = ruleInfoAttribute.GetRuleData(entityName, type.GetAssemblyQualifiedName());

          if (ruleData == null) continue;

          List<RuleData> ruleDataList;
          rulesByEvent.TryGetValue(ruleData.Event, out ruleDataList);
          if (ruleDataList == null)
          {
            ruleDataList = new List<RuleData>();
            rulesByEvent.Add(ruleData.Event, ruleDataList);
          }

          ruleDataList.Add(ruleData);
        }
      }

      return rulesByEvent;
    }

    public bool ValidateComputationTypeName(string computationTypeName, out List<ErrorObject> errors)
    {
      bool isValid = true;
      errors = new List<ErrorObject>();
      Check.Require(!String.IsNullOrEmpty(computationTypeName), 
                    "computationTypeName cannot be null or empty");

      Type type = Type.GetType(computationTypeName, true);
      if (!type.IsSubclassOf(typeof(ComputedProperty)))
      {
        string message = String.Format("Computation type '{0}' must derive from '{1}'.", 
                                       computationTypeName, typeof(ComputedProperty).FullName);
        errors.Add(new ErrorObject(message));
        isValid = false;
      }

      return isValid;
    }

    public string GetComputationTypeName(string entityName, string propertyName, string assemblyNameWithPath)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(assemblyNameWithPath), "assemblyNameWithPath cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(File.Exists(assemblyNameWithPath), String.Format("Cannot find file '{0}'", assemblyNameWithPath), SystemConfig.CallerInfo);

      string computationTypeName = String.Empty;

      Assembly assembly = Assembly.Load(Path.GetFileNameWithoutExtension(assemblyNameWithPath));
      Check.Require(assembly != null, String.Format("Cannot load assembly '{0}'", assemblyNameWithPath));

      foreach (Type type in assembly.GetTypes())
      {
        object[] attributes = type.GetCustomAttributes(typeof(ComputedPropertyInfoAttribute), false);
        if (attributes == null || attributes.Length == 0) continue;

        ComputedPropertyInfoAttribute computedPropertyInfoAttribute = 
          attributes.Cast<ComputedPropertyInfoAttribute>().Single();

        if (computedPropertyInfoAttribute != null && 
            computedPropertyInfoAttribute.EntityName == entityName &&
            computedPropertyInfoAttribute.PropertyName == propertyName)
        {
          computationTypeName = type.GetAssemblyQualifiedName();
          break;
        }
      }

      return computationTypeName;
    }
    #region Private Methods
   
    #endregion
    #region Data
    #endregion
  }
}
