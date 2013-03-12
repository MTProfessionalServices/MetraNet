using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract (Namespace = "MetraTech")]
    public abstract class MetraNetEntityBase : PropertyBag
    {
        #region Properties

        /// <summary>
        /// The extension that the PropertyBag is associated with
        /// </summary>
        public string Extension { get; set; }

        public virtual string SubDirectoryName { get { return ((PropertyBagType)Type).Name + "s"; } }

        #endregion

        #region Constructor
        protected MetraNetEntityBase(string _namespace, string name, string propertyBagTypeName, string description)
            : base(_namespace, name, propertyBagTypeName, PropertyBagMode.ExtensibleEntity, description)
        {
            ((PropertyBagType)Type).PropertyBagMode = PropertyBagMode.ExtensibleEntity;
        }
        #endregion

        #region Methods

     
        public string GetFileNameGivenExtensionsDirectory(string extensionsDir)
        {
            var dirPath = IOHelper.GetMetraNetConfigPath(extensionsDir, Extension, SubDirectoryName);
            return string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, Name);
        }

        public void SaveInExtensionsDirectory(string extensionsDir)
        {
            var file = GetFileNameGivenExtensionsDirectory(extensionsDir);
            Save(file);
        }
        #endregion
    }
}
