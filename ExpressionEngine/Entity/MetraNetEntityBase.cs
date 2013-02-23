using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
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
        public void SaveToExtensionPath(string extensionPath)
        {
          

        }
        #endregion
    }
}
