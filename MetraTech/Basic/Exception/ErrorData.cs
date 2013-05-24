using System;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class ErrorData
  {
    public int ErrorCode { get; set; }
    public ErrorType ErrorType { get; set; }
  }

  public enum ErrorType
  {
    EntityValidation,
    PropertyValidation,
    RelationshipValidation,
    QualifedNameValidation
  }
}
