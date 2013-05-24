using System;
using MetraTech.Basic;
using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.Core.Rule
{
  [AttributeUsage(AttributeTargets.Class)]
  public sealed class RuleInfoAttribute : Attribute
  {
    public string Name { get; set; }
    public string Description { get; set; }

    public Type[] EntityTypes { get; set; }
    public CRUDEvent[] Events { get; set; }

    #region Public Methods
    public RuleData GetRuleData(string entityName, string assemblyQualifiedTypeName)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(!String.IsNullOrEmpty(assemblyQualifiedTypeName), "assemblyQualifiedTypeName cannot be null or empty", SystemConfig.CallerInfo);

      RuleData ruleData = null;
      if (EntityTypes != null)
      {
        Check.Require(Events != null, "Events cannot be null", SystemConfig.CallerInfo);
        Check.Require(EntityTypes.Length == Events.Length, "Missing events", SystemConfig.CallerInfo);

        for (int i = 0; i < EntityTypes.Length; i++)
        {
          if (EntityTypes[i].FullName == entityName)
          {
            ruleData = new RuleData();
            ruleData.EntityName = entityName;
            ruleData.AssemblyQualifiedTypeName = assemblyQualifiedTypeName;
            ruleData.Name = Name;
            ruleData.Description = Description;
            ruleData.Event = Events[i];
            ruleData.Enabled = true;
            break;
          }
        }
      }
      return ruleData;
    }
    #endregion
  }
}
