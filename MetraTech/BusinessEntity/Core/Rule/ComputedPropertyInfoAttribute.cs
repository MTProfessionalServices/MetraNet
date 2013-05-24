using System;
using MetraTech.Basic;
using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.Core.Rule
{
  [AttributeUsage(AttributeTargets.Class)]
  public sealed class ComputedPropertyInfoAttribute : Attribute
  {
    public string Name { get; set; }
    public string Description { get; set; }

    public string EntityName { get; set; }
    public string PropertyName { get; set; }

    #region Public Methods
   
    #endregion
  }
}
