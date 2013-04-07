using System;
using System.Globalization;
using System.Reflection;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    /// <summary>
    /// Implements a reference to a property. Used to simplify validation and renaming.
    /// </summary>
    public class PropertyReference
    {
        #region Properties
        /// <summary>
        /// The name of the property that's being referred to
        /// </summary>
        public string PropertyName
        {
            get { return (string)PropertyInfo.GetValue(ReflectionObject, null); }
        }

        /// <summary>
        /// The object that contains the property reference. Used in combination with ReflectionName for 
        /// refactoring via reflection
        /// </summary>
        private object ReflectionObject;

        private PropertyInfo PropertyInfo;

        /// <summary>
        /// The expected data type of the property
        /// </summary>
        public Type ExpectedType { get; set; }

        /// <summary>
        /// Indicates if the reference is required
        /// </summary>
        public bool Required { get; set; }

        /// <summary>
        /// The name that the user associates with the intent of the reference. Used in validation methods
        /// TODO: Localize
        /// </summary>
        public string UserName { get; set; }

        #endregion

        #region Constructor
        public PropertyReference(object reflectionObject, string reflectionName, Type expectedType, bool required)
        {
            ExpectedType = expectedType;
            Required = required;
            ReflectionObject = reflectionObject;

            PropertyInfo = ReflectionObject.GetType().GetProperty(reflectionName);
            if (PropertyInfo == null)
                throw new Exception("GetProperty() returned null");
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

            //If it's not specified (and not required per above) bail
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

        public void RenameActualReference(string newName)
        {
            PropertyInfo.SetValue(ReflectionObject, newName, null);
        }
        #endregion
    }
}
