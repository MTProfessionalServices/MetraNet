using System;
using MetraTech.Basic;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Exception
{
  [Serializable]
  public class EntityValidationErrorData : ErrorData
  {
    public string EntityTypeName;
  }
}
