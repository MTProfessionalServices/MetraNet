using System;
using MetraTech.Basic;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Exception
{
  [Serializable]
  public class PropertyValidationErrorData : ErrorData
  {
    public string EntityTypeName;
    public string PropertyName;
  }
}
