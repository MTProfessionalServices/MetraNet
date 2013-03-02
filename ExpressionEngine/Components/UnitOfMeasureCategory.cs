using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;
using System.IO;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class UnitOfMeasureCategory : EnumCategory, IExpressionEngineTreeNode
    {
        #region Properties

        public override string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "UoM.{0}", Name); } }       
        
        //[DataMember]
        //public Collection<UnitOfMeasure> Items { get; private set; }
        #endregion

        #region GUI Helper Properties (Remove in future)
        public override string Image { get { return "UnitOfMeasureCategory.png"; } }
        #endregion

        #region Constructor
        public UnitOfMeasureCategory(EnumNamespace parent, string name, int id, string description) : base(parent, name, id, description)
        {
            IsUnitOfMeasure = true;
            //Items = new Collection<UnitOfMeasure>();
        }
        #endregion

        #region Methods
        public UnitOfMeasure AddUnitOfMeasure(string name, int id, bool isMetric)
        {
            var uom = new UnitOfMeasure(this, name, id, isMetric);
            Values.Add(uom);
            return uom;
        }
        #endregion

        #region IO Methods

        //public static UnitOfMeasureCategory CreateFromFile(string file)
        //{
        //    var xmlContent = File.ReadAllText(file);
        //    return CreateFromString(xmlContent);
        //}

        //public static UnitOfMeasureCategory CreateFromString(string xmlContent)
        //{
        //    return IOHelper.CreateFromString<UnitOfMeasureCategory>(xmlContent);
        //}

        #endregion
    }
}
