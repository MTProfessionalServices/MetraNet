using System;

namespace Core.Common
{
  [Serializable]
  public class Index : PivotTableProperty
  {
    public override string ExtensionName { get; set; }
    public override string EntityGroupName { get; set; }
    public override string EntityName { get; set; }
    public override string PropertyName { get; set; }
    public override Guid EntityInstanceId { get; set; }

    public override bool? BooleanValue { get; set; }
    public override DateTime? DateTimeValue { get; set; }
    public override decimal? DecimalValue { get; set; }
    public override double? DoubleValue { get; set; }
    public override Guid? GuidValue { get; set; }
    public override int? Int32Value { get; set; }
    public override Int64? Int64Value { get; set; }
    public override string StringValue { get; set; }
    public override int? EnumValue { get; set; }
  }
}

