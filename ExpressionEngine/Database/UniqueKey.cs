using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Database
{
    [DataContract (Namespace = "MetraTech")]
    public class UniqueKey
    {
        #region Properties

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public Collection<string> Columns { get; private set; }

        #endregion

        #region Constroctor

        public UniqueKey()
        {
            Columns = new Collection<string>();
        }

    #endregion
    }
}
