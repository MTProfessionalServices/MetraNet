using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract(Namespace = "MetraTech")]
    public class PropertyBagType : Type
    {
        #region Properties

        public string Name { get; set; }

        [DataMember]
        public PropertyBagMode PropertyBagMode { get; set; }

        /// <summary>
        /// Indicates if deemed a PropertyBag or ExtensibleEntity
        /// </summary>
        public bool IsEntity
        {
            get { return PropertyBagMode == PropertyBagMode.Entity || PropertyBagMode == PropertyBagMode.ExtensibleEntity; }
        }

        public bool IsAccountView { get { return Name == PropertyBagConstants.AccountView; } }
        public bool IsProductView { get { return Name == PropertyBagConstants.ProductView; } }
        public bool IsServiceDefinition { get { return Name == PropertyBagConstants.ServiceDefinition; } }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public override string CompatibleKey
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", BaseType, Name);
            }
        }

        #endregion

        #region Constructor
        public PropertyBagType(string propertyBagTypeName, PropertyBagMode propertyBagMode) : base(BaseType.PropertyBag)
        {
            Name = propertyBagTypeName;
            PropertyBagMode = propertyBagMode;
        }
        #endregion

        #region Methods
        //This isn't quite right
        public override string ToString(bool robust)
        {
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}: {1}", PropertyBagMode, Name);
            return PropertyBagMode.ToString();
        }

        public new PropertyBagType Copy()
        {
            var type = (PropertyBagType)TypeFactory.Create(BaseType);
            InternalCopy(type);
            type.Name = Name;
            type.PropertyBagMode = PropertyBagMode;
            return type;
        }

        #endregion

    }
}
