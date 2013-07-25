using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
  /// <summary>
  /// A binary operator can be used to evaluate an expression that takes 2 input expressions
  /// (Order of values in this file is used as order of precedence)
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  public enum BinaryOperator
  {
    /// <summary>
    /// A logical operation that returns true if either operand is true
    /// </summary>
    [EnumMember]
    Or,
    /// <summary>
    /// A logical operation that returns true if both operands must be true
    /// </summary>
    [EnumMember]
    And,
    /// <summary>
    /// An inequality comparison that returns true if the operands have different values
    /// </summary>
    [EnumMember]
    NotEqual,
    /// <summary>
    /// An equality comparison that returns true if both operands have the same value
    /// </summary>
    [EnumMember]
    Equal,
    /// <summary>
    /// A comparison that returns true if the left operand is greater than or equal to the right one
    /// </summary>
    [EnumMember]
    GreaterThanOrEqual,
    /// <summary>
    /// A comparison that returns true if the left operand is less than or equal to the right one
    /// </summary>
    [EnumMember]
    LessThanOrEqual,
    /// <summary>
    /// A comparison that returns true if the left operand is greater than the right one
    /// </summary>
    [EnumMember]
    GreaterThan,
    /// <summary>
    /// A comparison that returns true if the left operand is less than the right one
    /// </summary>
    [EnumMember]
    LessThan,
    /// <summary>
    /// An operation that adds two operators
    /// </summary>
    [EnumMember]
    Add,
    /// <summary>
    /// An operation that substracts two operators
    /// </summary>
    [EnumMember]
    Subtract,
    /// <summary>
    /// An operation that multiplies two operators
    /// </summary>
    [EnumMember]
    Multiply,
    /// <summary>
    /// An operation that divides two operators
    /// </summary>
    [EnumMember]
    Divide,
    /// <summary>
    /// An operation that calculates the modulo of two operators
    /// </summary>
    [EnumMember]
    Modulo,
    /// <summary>
    /// An operation that calculates the power two operators
    /// </summary>
    [EnumMember]
    Power,
  }
}
