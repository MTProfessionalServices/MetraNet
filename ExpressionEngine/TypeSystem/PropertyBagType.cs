using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract]
    public class PropertyBagType : Type
    {
        #region Properties

        public string Name { get; set; }

        public bool IsAccountView { get { return Name == PropertyBagConstants.AccountView; } }
        public bool IsProductView { get { return Name == PropertyBagConstants.ProductView; } }
        public bool IsServiceDefinition { get { return Name == PropertyBagConstants.ServiceDefinition; } }

        public PropertyBagMode PropertyBagMode { get; set; }

        /// <summary>
        /// Indicates if the ComplexType is deemed an Entity
        /// </summary>
        [DataMember]
        public bool IsEntity { get; set; }
        //{
        //    get { return PropertyBagMode == PropertyBagMode.Entity || PropertyBagMode == PropertyBagMode.ExtensibleEntity; }
        //}





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
        public PropertyBagType(string propertyBagTypeName, bool isEntity) : base(BaseType.Entity)
        {
            Name = propertyBagTypeName;
            IsEntity = isEntity;
        }
        #endregion

        #region Methods
        //This isn't quite right
        public override string ToString(bool robust)
        {
            var type = IsEntity ? "Entity" : "PropertyBag";
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}: {1}", type, Name);
            return type;
        }

        public new PropertyBagType Copy()
        {
            var type = (PropertyBagType)TypeFactory.Create(BaseType);
            InternalCopy(type);
            type.Name = Name;
            type.IsEntity = IsEntity;
            return type;
        }

        #endregion

    }
}
