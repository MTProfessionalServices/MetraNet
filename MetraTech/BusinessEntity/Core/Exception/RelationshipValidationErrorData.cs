using System;
using MetraTech.Basic;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Exception
{
  [Serializable]
  public class RelationshipValidationErrorData : ErrorData
  {
    public string SourceEntityTypeName;
    public string TargetEntityTypeName;
  }
}
