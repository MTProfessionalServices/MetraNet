using System;
using System.Collections.Generic;
using System.Text;
using System.Globalization;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// </summary>
    public class UnitOfMeasureCategory : IExpressionEngineTreeNode
    {
        #region Properties
        public string Name { get; set; }
        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "UoM.{0}", Name); } }
        public List<UnitOfMeasure> Items { get; private set; }
        #endregion

        #region GUI Helper Properties (Remove in future)
        public string TreeNodeLabel { get { return Name; } }
        public string Image { get { return "UomCategory.png"; } }
        public string ToolTip { get { return null; } }
        #endregion

        #region Constructor
        public UnitOfMeasureCategory(string name)
        {
            Name = name;
            Items = new List<UnitOfMeasure>();
        }
        #endregion

        #region Methods
        public UnitOfMeasure AddUnitOfMeasure(string name, bool isMetric)
        {
            var uom = new UnitOfMeasure(this, name, isMetric);
            Items.Add(uom);
            return uom;
        }
        #endregion
    }
}
