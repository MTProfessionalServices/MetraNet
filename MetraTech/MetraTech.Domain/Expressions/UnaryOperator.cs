using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
    /// <summary>
    /// A unary operator can be used to evaluate an expression that takes 1 input expressions
    /// (Order of values in this file is used as order of precedence)
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    public enum UnaryOperator
    {
        /// <summary>
        /// A logical operation that returns false if the operand is true, and true if the operand is false
        /// </summary>
        [EnumMember]
        Not,
        /// <summary>
        /// An arithmetic operation that returns the negative value of the expression
        /// </summary>
        [EnumMember]
        Minus
    }
}
