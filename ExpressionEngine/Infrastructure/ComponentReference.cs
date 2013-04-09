using System;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Components
{
    public class ComponentReference
    {
        #region Properties
        public ComponentType ComponentType { get; private set; }
        public string FullName { get; private set; }
        #endregion

        #region Constructor
        public ComponentReference(ComponentType componentType, string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
                throw new ArgumentException("fullName is null or empty");

            ComponentType = componentType;
            FullName = fullName;
        }
        #endregion

    }
}
