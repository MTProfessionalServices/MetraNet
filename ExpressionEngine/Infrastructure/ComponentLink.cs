using System;
using System.Globalization;
using System.Reflection;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// Implements a link to a component. Many objects use a string to refer to components via string that contains
    /// the component's FullName. This class faciliates generic validation and refactoring (renaming) of those references
    /// to other componet. Since the refrence is a simple string (a value type) this class had to use reflection to be able 
    /// to generically rename the string. Since reflection was required for renaming, reflection is also used to read the
    /// value of string during validation (one code path). This approch keeps the runtime simple (reference are just a string)
    /// and this class, and it's associated relatively expensive reflection, are only invode at design or vaidation time.
    /// 
    /// For validation need to think through;
    /// *PropertyBag: PropertyBagTypeName
    /// *Property:    Type
    /// 
    /// </summary>
    public class ComponentLink
    {
        #region Properties
        public ComponentType ComponentType { get; private set; }
        private object LinkObject;
        private PropertyInfo PropertyInfo;
        public string UserContext { get; private set; }
        public bool IsRequired { get; private set; }
        #endregion

        #region Constructor
        public ComponentLink(ComponentType type, object linkObject, string linkObjectPropertyName, bool isRequired, string userContext)
        {
            if (linkObject == null)
                throw new ArgumentException("linkObject is null");
            if (string.IsNullOrEmpty(linkObjectPropertyName))
                throw new ArgumentException("linkObjectPropertyName is null or empty");
            if (string.IsNullOrEmpty(userContext))
                throw new ArgumentException("userContext is null or empty");

            ComponentType = type;
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
        public void Validate(ValidationMessageCollection messages, Context context)
        {
            if (messages == null)
                throw new ArgumentException("messages is null");
            if (context == null)
                throw new ArgumentException("context is null");

            var errorMsg = GetValidateStr(context);
            if (errorMsg != null)
                messages.Error(errorMsg);
        }

        public string GetValidateStr(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");

            var fullName = (string)PropertyInfo.GetValue(LinkObject, null);
            if (string.IsNullOrEmpty(fullName))
            {
                if (IsRequired)
                    return string.Format(CultureInfo.CurrentCulture, "{0} is not specified.", UserContext);
                return null;
            }
       
            if (context.ComponentExists(ComponentType, fullName))
                return null;

            return string.Format(CultureInfo.CurrentCulture, "Invalid {0}: Unable to find {1}", UserContext, fullName);
        }

        public void Rename(string newName)
        {
            PropertyInfo.SetValue(LinkObject, newName, null);
        }
        #endregion
    }
}
