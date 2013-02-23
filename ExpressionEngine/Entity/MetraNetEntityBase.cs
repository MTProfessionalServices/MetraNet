using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    public abstract class MetraNetEntityBase : Entity
    {
        #region Properties

        /// <summary>
        /// The extension that the Entity is associated with
        /// </summary>
        public string Extension { get; set; }
        #endregion

        #region Constructor
        public MetraNetEntityBase(string name, ComplexType complexType, string description) : base(name, complexType, null, true, description)
        {
        }
        #endregion

        #region Methods
        public void SaveInExtensionsDirectory(string extensionsDir)
        {
            var dirPath = string.Format(CultureInfo.InvariantCulture, @"{0}\Config\{1}s", extensionsDir, VectorType);
            Save(dirPath);
        }
        #endregion
    }
}
