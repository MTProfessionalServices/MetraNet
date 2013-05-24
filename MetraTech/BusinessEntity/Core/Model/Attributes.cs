using System;

namespace MetraTech.BusinessEntity.Core.Model
{
  [AttributeUsage(AttributeTargets.Class)]
  public sealed class ConfigDrivenAttribute : Attribute
  {
    public string HbmFile { get; set; }
  }
}
