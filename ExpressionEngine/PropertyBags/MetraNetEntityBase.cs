using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract]
    public abstract class MetraNetEntityBase : PropertyBag
    {
        #region Properties

        /// <summary>
        /// The extension that the PropertyBag is associated with
        /// </summary>
        public string Extension { get; set; }

        #endregion

        #region Constructor
        protected MetraNetEntityBase(string name, string propertyBagTypeName, string description)
            : base(name, propertyBagTypeName, PropertyBagMode.ExtensibleEntity, description)
        {
            ((PropertyBagType)Type).PropertyBagMode = PropertyBagMode.ExtensibleEntity;
        }
        #endregion

        #region Methods
        public string GetFileNameGivenExtensionsDirectory(string extensionsDir)
        {
            return IOHelper.GetMetraNetConfigPath(extensionsDir, Extension, ((PropertyBagType) Type).Name + "s");
         }

        public void SaveInExtensionsDirectory(string extensionsDir)
        {
            var file = GetFileNameGivenExtensionsDirectory(extensionsDir);
            Save(file);
        }
        #endregion
    }
}
