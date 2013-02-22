using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Database
{
    [DataContract]
    public class UniqueKey
    {
        #region Properties

        [DataMember] public string Name;

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
