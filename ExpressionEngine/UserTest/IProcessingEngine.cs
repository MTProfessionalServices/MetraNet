using MetraTech.ExpressionEngine.Expressions;

namespace MetraTech.ExpressionEngine.UserTest
{
    /// <summary>
    /// I have no idea what this shold look like yet, we just need it.
    /// </summary>
    interface IProcessingEngine
    {
        ExpressionParseResults EvaluateExpression(Expression expression);
    }
}
