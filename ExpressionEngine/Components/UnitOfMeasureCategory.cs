using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;
using System.IO;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class UnitOfMeasureCategory : IExpressionEngineTreeNode
    {
        #region Properties
        [DataMember]
        public string Name { get; set; }

        public string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "UoM.{0}", Name); } }       
        
        [DataMember]
        public Collection<UnitOfMeasure> Items { get; private set; }
        #endregion

        #region GUI Helper Properties (Remove in future)
        public string TreeNodeLabel { get { return Name; } }
        public string Image { get { return "UnitOfMeasureCategory.png"; } }
        public string ToolTip { get { return null; } }
        #endregion

        #region Constructor
        public UnitOfMeasureCategory(string name)
        {
            Name = name;
            Items = new Collection<UnitOfMeasure>();
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

        #region IO Methods

        public static UnitOfMeasureCategory CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString(xmlContent);
        }

        public static UnitOfMeasureCategory CreateFromString(string xmlContent)
        {
            return IOHelper.CreateFromString<UnitOfMeasureCategory>(xmlContent);
        }

        #endregion
    }
}
