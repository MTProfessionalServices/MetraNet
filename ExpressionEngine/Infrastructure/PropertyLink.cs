using System;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    public class PropertyLink : ComponentLink
    {
        #region Properties
        private Type ExpectedType;
        #endregion

        #region Constructor
        public PropertyLink(Type expectedType, object linkObject, string linkObjectPropertyName, bool isRequired, string userContext)
            : base(ComponentType.PropertyBagProperty, linkObject, linkObjectPropertyName, isRequired, userContext)
        {
            ExpectedType = expectedType;
        }
        #endregion

        #region Methods
        public override string GetValidationMessage(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");

            var errorMsg = base.GetValidationMessage(context);
            if (errorMsg != null)
                return errorMsg;

            var fullName = GetFullName();

            //Above validation checked the component type, so we can simply cast
            var property = (Property)context.GlobalComponentCollection.Get(fullName);

            //Check that the datatypes are compatible
            if (!property.Type.CanBeImplicitlyCastTo(ExpectedType))
               return string.Format(CultureInfo.CurrentCulture, "{0} is not compatible with {1}.", property.Type, ExpectedType);

            return null;
        }
        #endregion
    }
}
