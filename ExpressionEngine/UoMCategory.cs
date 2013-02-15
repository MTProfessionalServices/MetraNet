using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// </summary>
    public class UoMCategory : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string Image { get { return "UomCategory.png"; } }
        public string ToolTip { get { return null; } }
        public string ToExpression { get { return string.Format("UoM.{0}", Name); } }
        public List<Uom> Items = new List<Uom>();
        #endregion

        #region Constructor
        public UoMCategory(string name)
        {
            Name = name;
        }
        #endregion

        #region Methods
        public Uom AddUom(string name)
        {
            var uom = new Uom(this, name);
            Items.Add(uom);
            return uom;
        }
        #endregion
    }
}
