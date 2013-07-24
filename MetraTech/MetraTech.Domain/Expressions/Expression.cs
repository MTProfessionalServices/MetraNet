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
    [KnownType(typeof(PropertyExpression))]
    [KnownType(typeof(IdentifierExpression))]
    [KnownType(typeof(BinaryExpression))]
    [KnownType(typeof(UnaryExpression))]
    public abstract class Expression
    {
        /// <summary>
        /// Resolves the value of an expression that does not have property expressions
        /// </summary>
        /// <returns>The result of the expression</returns>
        public TResult Evaluate<TResult>()
        {
            var linqExpression = ConvertToLinq(null);
            return System.Linq.Expressions.Expression.Lambda<Func<TResult>>(linqExpression).Compile()();
        }

        /// <summary>
        /// Resolves the value of an expression
        /// </summary>
        /// <param name="nameInput1">The name of the argument</param>
        /// <param name="input1">An input object that will be used to resolve any parameter expressions</param>
        /// <returns>The value of the expression</returns>
        public TResult Evaluate<TResult, T1>(string nameInput1, T1 input1)
        {
            var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(T1), nameInput1);
            var linqExpression = ConvertToLinq(parameterExpression);
            return System.Linq.Expressions.Expression.Lambda<Func<T1, TResult>>(linqExpression, new[] { parameterExpression }).Compile()(input1);
        }

        /// <summary>
        /// Resolves the value of an expression
        /// </summary>
        /// <param name="nameInput1">The name of the argument</param>
        /// <param name="input1">An input object that will be used to resolve any parameter expressions</param>
        /// <param name="nameInput2">The name of the argument</param>
        /// <param name="input2">An input object that will be used to resolve any parameter expressions</param>
        /// <returns>The value of the expression</returns>
        public TResult Evaluate<TResult, T1, T2>(string nameInput1, T1 input1, string nameInput2, T2 input2)
        {
            var parameterExpression1 = System.Linq.Expressions.Expression.Parameter(typeof(T1), nameInput1);
            var parameterExpression2 = System.Linq.Expressions.Expression.Parameter(typeof(T2), nameInput2);
            var linqExpression = ConvertToLinq(parameterExpression1, parameterExpression2);
            return System.Linq.Expressions.Expression.Lambda<Func<T1, T2, TResult>>(linqExpression, new[] { parameterExpression1, parameterExpression2 }).Compile()(input1, input2);
        }

        /// <summary>
        /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
        /// </summary>
        /// <param name="parameters">Parameters to be referenced by any variable expressions</param>
        /// <returns>A linq expression</returns>
        public abstract System.Linq.Expressions.Expression ConvertToLinq(params System.Linq.Expressions.ParameterExpression[] parameters);

        /// <summary>
        /// Determines the data type that an expression will return
        /// </summary>
        /// <param name="nameInput1">The name of the argument of the expression</param>
        /// <param name="typeInput1">The type of parameter to be passed to the expression</param>
        /// <returns>The data type of the result from evaluating the expression</returns>
        public Type ResolveType(string nameInput1, Type typeInput1)
        {
            var parameterExpression1 = System.Linq.Expressions.Expression.Parameter(typeInput1, nameInput1);
            var linqExpression = ConvertToLinq(parameterExpression1);
            return linqExpression.Type;
        }

        /// <summary>
        /// Determines the data type that an expression will return
        /// </summary>
        /// <param name="nameInput1">The name of the argument of the expression</param>
        /// <param name="typeInput1">The type of parameter to be passed to the expression</param>
        /// <param name="nameInput2">The name of the argument of the expression</param>
        /// <param name="typeInput2">The type of parameter to be passed to the expression</param>
        /// <returns>The data type of the result from evaluating the expression</returns>
        public Type ResolveType(string nameInput1, Type typeInput1, string nameInput2, Type typeInput2)
        {
            var parameterExpression1 = System.Linq.Expressions.Expression.Parameter(typeInput1, nameInput1);
            var parameterExpression2 = System.Linq.Expressions.Expression.Parameter(typeInput2, nameInput2);
            var linqExpression = ConvertToLinq(parameterExpression1, parameterExpression2);
            return linqExpression.Type;
        }

        /// <summary>
        /// Creates a Linq Predicate that can be applied to IQueryable objects
        /// </summary>
        /// <param name="inputName">The name of the input variable referenced in the expression</param>
        /// <param name="queryable">The queryable object to be filtered by the predicate</param>
        /// <returns>An expression that can be used as the predicate of a Linq query</returns>
        public System.Linq.Expressions.Expression CreateLinqPredicate<T>(string inputName, IQueryable<T> queryable) where T : class
        {
            if (queryable == null) throw new ArgumentNullException("queryable");
            Validate();
            var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(T), inputName);
            var linqPredicateExpression = ConvertToLinq(parameterExpression);
            var whereLambdaExpression = System.Linq.Expressions.Expression.Lambda<Func<T, bool>>(linqPredicateExpression, new[] { parameterExpression });
            return System.Linq.Expressions.Expression.Call(typeof(Queryable), "Where", new[] { typeof(T) }, queryable.Expression, whereLambdaExpression);
        }

        /// <summary>
        /// 
        /// </summary>
        public virtual void Validate() { }
    }
}
