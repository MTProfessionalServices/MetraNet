using System;
using System.Globalization;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    /// <summary>
    /// Refers to a property. Used to simplify validation
    /// </summary>
    public class PropertyReference
    {
        #region Properties
        /// <summary>
        /// The name of the property that's being referred to
        /// </summary>
        public string PropertyName { get; set; }

        /// <summary>
        /// The expected data type of the property
        /// </summary>
        public Type ExpectedType { get; set; }

        /// <summary>
        /// Indicates if the reference is required
        /// </summary>
        public bool Required { get; set; }
        #endregion

        #region Constructor
        public PropertyReference(string propertyName, Type expectedType, bool required)
        {
            PropertyName = propertyName;
            ExpectedType = expectedType;
            Required = required;
        }
        #endregion

        #region Methods
        public void Validate(string prefix, PropertyCollection properties,  ValidationMessageCollection messages)
        {
            if (properties == null)
                throw new ArgumentException("properties is null");
            if (messages == null)
                throw new ArgumentException("messages is null");

            if (Required && string.IsNullOrWhiteSpace(PropertyName))
            {
                messages.Error(string.Format(CultureInfo.CurrentCulture, "{0} is not specified", PropertyName));
                return;
            }

            if (string.IsNullOrEmpty(PropertyName))
                return;

            var property = properties.Get(PropertyName);

            //Check if the property was found
            if (property == null)
            {
                messages.Error(string.Format(CultureInfo.CurrentCulture, "Unable to find the '{0}' property.", PropertyName));
                return;
            }

            //Check that the datatypes are compatible
            if (!property.Type.CanBeImplicitlyCastTo(ExpectedType))
                messages.Error(string.Format(CultureInfo.CurrentCulture, "{0} is not compatible with {1}.",  property.Type, ExpectedType));
        }
        #endregion
    }
}
