using System;
using System.ComponentModel;
using System.Reflection;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// Implements a link to a component. Many objects use a string to refer to components via a string that contains
    /// the component's FullName. This class faciliates generic validation and refactoring (renaming) of those references.
    /// Since the reference is a simple string (a value type) this class uses reflection to be able 
    /// to generically rename the string. Since reflection was required for renaming, reflection is also used to read the
    /// value of string during validation (one code path). This approach keeps the runtime simple (references are just a string)
    /// and this class, and it's associated relatively expensive reflection, are only invoked at design or vaidation time.
    /// 
    /// For validation need to think through;
    /// *PropertyBag: PropertyBagTypeName
    /// *Property:    Type
    /// 
    /// </summary>
    public class ComponentLink
    {
        #region Properties
        /// <summary>
        /// Compared to the acitual component type during validation
        /// </summary>
        public ComponentType ExpectedComponentType { get; private set; }

        /// <summary>
        /// The object that contains the link; used to perform reflection. See description at top.
        /// </summary>
        private object LinkObject;

        /// <summary>
        /// The field that contains the link to the component; uses reflection. See description at top.
        /// </summary>
        private PropertyInfo PropertyInfo;

        /// <summary>
        /// The name that the user assoicates with the link. Typically the label in the UI. Used to generate validation messages
        /// </summary>
        public string UserContext { get; private set; }

        /// <summary>
        /// Determines if the link is required. If so, existance of the component is check at validation time
        /// </summary>
        public bool IsRequired { get; private set; }
        #endregion

        #region Constructor
        public ComponentLink(ComponentType expectedType, object linkObject, string linkObjectPropertyName, bool isRequired, string userContext)
        {
            //Check parameters
            if (linkObject == null)
                throw new ArgumentException("linkObject is null");
            if (string.IsNullOrEmpty(linkObjectPropertyName))
                throw new ArgumentException("linkObjectPropertyName is null or empty");
            if (string.IsNullOrEmpty(userContext))
                throw new ArgumentException("userContext is null or empty");

            //Store parameters
            ExpectedComponentType = expectedType;
            LinkObject = linkObject;
            IsRequired = isRequired;
            UserContext = userContext;

            //Get the property info via reflection
            PropertyInfo = linkObject.GetType().GetProperty(linkObjectPropertyName);
            if (PropertyInfo == null)
                throw new Exception("GetProperty() returned null; LinkObjectPropertyName=" + linkObjectPropertyName);
            if (PropertyInfo.PropertyType != typeof (string))
                throw new Exception("reflected property isn't a string.");
        }
        #endregion

        #region Methods
        public virtual void Validate(IComponent associatedComponent, ValidationMessageCollection messages, Context context)
        {
            if (associatedComponent == null)
                throw new ArgumentException("associatedComponent is null");
            if (messages == null)
                throw new ArgumentException("messages is null");
            if (context == null)
                throw new ArgumentException("context is null");
           
            var fullName = GetFullName();
            if (string.IsNullOrEmpty(fullName))
            {
                if (IsRequired)
                    messages.Error(Localization.ComponentNotSpecified, UserContext);
                return;
            }

            var component = context.GlobalComponentCollection.Get(fullName);
            if (component == null)
                messages.Error(associatedComponent, Localization.UnableToFindComponent, UserContext, fullName);
            else if (component.ComponentType != ExpectedComponentType)
                messages.Error(associatedComponent, Localization.ComponentNotOfExpectedType, UserContext, ComponentHelper.GetUserName(ExpectedComponentType), component.ComponentType);
        }

        public IComponent GetComponent(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");

            var component = context.GlobalComponentCollection.Get(GetFullName());
            if (component == null)
                return null;

            if (component is PropertyBag)
            {
                var propertyBag = (PropertyBag) component;
                var typeName = ((PropertyBagType) propertyBag.Type).Name;
                if (typeName == PropertyBagConstants.ServiceDefinition)
                {
                    if (ExpectedComponentType == ComponentType.ServiceDefinition)
                        return component;
                    return null;
                }
            }

            return component;
        }


        public string GetFullName()
        {
           return (string)PropertyInfo.GetValue(LinkObject, null);
        }

        public void SetFullName(string newName)
        {
            PropertyInfo.SetValue(LinkObject, newName, null);
        }
        #endregion
    }
}
