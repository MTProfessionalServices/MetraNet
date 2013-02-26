using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract]
    public class MoneyType : Type
    {
        #region Properties

        [DataMember]
        public string Currency { get; set; }
        public UnitOfMeasureMode UnitOfMeasure { get; set; }

        //[DataMember]
        //public string UnitsProperty { get; set; }
        //public UnitOfMeasureMode UnitOfMeasureMode { get; set; }


        #endregion
      
        #region Constructor
        public MoneyType():base(BaseType.Money)
        {
        }
        #endregion

        #region Methods

        public new MoneyType Copy()
        {
            var type = (MoneyType)base.Copy();
            InternalCopy(type);
            //type.UnitsProperty = UnitsProperty;
            return type;
        }
        #endregion
    }
}
