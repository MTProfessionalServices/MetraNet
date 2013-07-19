using System;
using System.Linq;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
  /// <summary>
  /// An expression tree can be built to define a formula that is evaluated using an entity as its input
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  [KnownType(typeof(ConstantExpression))]
  [KnownType(typeof(BinaryExpression))]
  [KnownType(typeof(PropertyExpression))]
  public abstract class Expression
  {
    /// <summary>
    /// Resolves the value of an expression that does not have property expressions
    /// </summary>
    /// <returns>The result of the expression</returns>
    public TOutput Evaluate<TOutput>()
    {
      var linqExpression = ConvertToLinq(null);
      return System.Linq.Expressions.Expression.Lambda<Func<TOutput>>(linqExpression).Compile()();
    }

    /// <summary>
    /// Resolves the value of an expression
    /// </summary>
    /// <param name="input">An input object that will be used to resolve any parameter expressions</param>
    /// <returns>The value of the expression</returns>
    public TOutput Evaluate<TOutput, TInput>(TInput input)
    {
      var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(TInput), "x");
      var linqExpression = ConvertToLinq(parameterExpression);
      return System.Linq.Expressions.Expression.Lambda<Func<TInput,TOutput>>(linqExpression, new[] { parameterExpression }).Compile()(input);
    }

    /// <summary>
    /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
    /// </summary>
    /// <param name="parameter">A parameter to be referenced by any variable expressions</param>
    /// <returns>A linq expression</returns>
    public abstract System.Linq.Expressions.Expression ConvertToLinq(System.Linq.Expressions.Expression parameter);

    /// <summary>
    /// Determines the data type that an expression will return
    /// </summary>
    /// <param name="parameterType">The type of parameter to be passed to the expression</param>
    /// <returns>The data type of the result from evaluating the expression</returns>
    public Type ResolveType(Type parameterType)
    {
      var parameterExpression = System.Linq.Expressions.Expression.Parameter(parameterType, "x");
      var linqExpression = ConvertToLinq(parameterExpression);
      return linqExpression.Type;
    }

    /// <summary>
    /// Creates a Linq Predicate that can be applied to IQueryable objects
    /// </summary>
    /// <param name="queryable">The queryable object to be filtered by the predicate</param>
    /// <returns>An expression that can be used as the predicate of a Linq query</returns>
    public System.Linq.Expressions.Expression CreateLinqPredicate<T>(IQueryable<T> queryable) where T : class
    {
      if (queryable == null) throw new ArgumentNullException("queryable");
      Validate();
      var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(T), "x");
      var linqPredicateExpression = ConvertToLinq(parameterExpression);
      var whereLambdaExpression = System.Linq.Expressions.Expression.Lambda<Func<T, bool>>(linqPredicateExpression, new[] { parameterExpression });
      return System.Linq.Expressions.Expression.Call(typeof(Queryable), "Where", new[] { typeof(T) }, queryable.Expression, whereLambdaExpression);
    }

    /// <summary>
    /// 
    /// </summary>
    public virtual void  Validate(){}
  }
}
