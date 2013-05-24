using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

#region Assembly Attribute
[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("MetraTech.Core.Services, PublicKey=" +
            "00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
            "bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
            "e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
            "66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
            "df27e798")]
[assembly: System.Runtime.CompilerServices.InternalsVisibleTo("MetraTech.ActivityServices.Services.Common, PublicKey=" +
            "00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
            "bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
            "e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
            "66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
            "df27e798")]

#endregion

namespace MetraTech.ActivityServices.Common
{
    [DataContract]
    [Serializable]
    public class PCIdentifier
    {
        public PCIdentifier(int pcID)
        {
            m_ID = pcID;
        }

        public PCIdentifier(string name)
        {
            m_Name = name;
        }

        public PCIdentifier(int pcID, string name)
        {
            m_ID = pcID;
            m_Name = name;
        }

        #region Public Properties
        public int? ID { get { return m_ID; } }

        public string Name { get { return m_Name; } }
        #endregion

        #region Private Members
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private int? m_ID = null;
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        private string m_Name = null;
        #endregion
    }
}
