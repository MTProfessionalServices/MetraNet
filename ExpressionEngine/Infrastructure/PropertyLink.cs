using System;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    /// <summary>
    /// Please read the description in the parent class, ComponentLink. It explains how and why reflection is used.
    /// This subclass deals with links to properties within a property bag. It deals with the nuances of property data types
    /// and if they are compatable.
    /// </summary>
    public class PropertyLink : ComponentLink
    {
        #region Properties
        public Type ExpectedType { get; private set; }
        #endregion

        #region Constructor
        public PropertyLink(Type expectedType, object linkObject, string linkObjectPropertyName, bool isRequired, string userContext)
            : base(ComponentType.PropertyBagProperty, linkObject, linkObjectPropertyName, isRequired, userContext)
        {
            ExpectedType = expectedType;
        }
        #endregion

        #region Methods
        public override void Validate(IComponent associatedComponent, ValidationMessageCollection messages, Context context)
        {
            base.Validate(associatedComponent, messages, context);

            //Use reflection to get the full name
            var fullName = GetFullName();

            //Above validation checked the component type, so we can simply cast
            var component = context.GlobalComponentCollection.Get(fullName);
            if (component != null && component.ComponentType == ComponentType.PropertyBagProperty)
            {
                var property = (Property) component;
                //Check that the datatypes are compatible
                if (!property.Type.CanBeImplicitlyCastTo(ExpectedType))
                    messages.Error(associatedComponent, Localization.TypesNotCompatible, property.Type, ExpectedType);
            }
        }
        #endregion
    }
}
