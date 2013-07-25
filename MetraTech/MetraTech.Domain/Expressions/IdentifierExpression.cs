using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
    /// <summary>
    /// An Identifier expression contains a reference to a variable.
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    public class IdentifierExpression : Expression
    {
        /// <summary>
        /// The name of the variable
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        /// <summary>
        /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
        /// </summary>
        /// <param name="parameter">A parameter to be referenced by variable expressions</param>
        /// <returns>A linq expression</returns>
        public override System.Linq.Expressions.Expression ConvertToLinq(System.Linq.Expressions.Expression parameter)
        {
            // For now, any identifier expression is going to be assumed to be a reference to the expression argument
            // Eventually, three improvements need to be made: (a) we need to support declaration of variables in the language,
            // which would be tracked into a symbol table, and (b) we need to add support for multiple arguments, which would
            // also be added to the symbol table, and (c) this expression would have to be resolved as a lookup in the symbol
            // table to an appopriate value reference.
            return parameter;
        }

        /// <summary>
        /// Represents string interpretation of constant expression
        /// </summary>
        /// <returns>A string value</returns>
        public override string ToString()
        {
            return (Name ?? "NULL").ToString();
        }
    }
}
