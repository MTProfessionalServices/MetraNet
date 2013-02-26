using System;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.Expressions
{
    public class ExpressionParseResults
    {
        #region Properties
        /// <summary>
        /// TODO: FIRGURE OUT BEST WAY TO DETERMINE THIS>>> THINKING MESSAGES.NUMERRORS.COUNT
        /// </summary>
        public bool IsValid { get; set; }
        public ValidationMessageCollection  Messages {get; private set;}

        /// <summary>
        /// The MVM parse tree. Not currently supported.
        /// </summary>
        public object ParseTree { get; set; }

        /// <summary>
        /// The return type as determined by parsing. Not currently supported.
        /// </summary>
        public Type ReturnType { get; set; }

        /// <summary>
        /// The parameters
        /// </summary>
        public PropertyCollection Parameters { get; private set; }
        #endregion

        #region Constructor
        public ExpressionParseResults()
        {
            Messages = new ValidationMessageCollection();
            Parameters = new PropertyCollection(this);
            IsValid = false;
        }
        #endregion

        #region Methods

        /// <summary>
        /// Binds the parameters to what's available in the context. If the property isn't found, a validation message is added.
        /// TODO: need to detect type mismatches
        /// </summary>
        public void BindResultsToContext(Context context)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            foreach (var parameter in Parameters)
            {
                var property = context.GetRecursive(parameter.Name);
                if (property != null)
                {
                    parameter.Description = property.Description;
                    parameter.Type = property.Type.Copy();
                }
                else if (parameter.Direction == Direction.Input || parameter.Direction == Direction.InOut)
                {
                    parameter.Type = TypeFactory.CreateUnknown();
                    parameter.Description = null;

                    //Would be really nice to provide line/column number here. Need parse tree to do that
                    Messages.Error(string.Format(Localization.UnableToFindProperty, parameter.Name));
                }
            }
        }
        #endregion
    }
}
