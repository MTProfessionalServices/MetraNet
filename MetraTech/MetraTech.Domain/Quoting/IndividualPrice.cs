using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.ComponentModel.DataAnnotations;

namespace MetraTech.Domain.Quoting
{
    /// <summary>
    /// The IndividualPrice class represents a ICB price in MetraNet.
    /// </summary>
    [DataContract(Namespace = "MetraTech.MetraNet")]
    [Serializable]
    public class IndividualPrice
    {
        [Required]
        [DataMember]
        public ChargeType CurrentChargeType { get; set; }

        [DataMember]
        public List<ChargesRate> ChargesRates { get; set; }

        public IndividualPrice()
        {
                ChargesRates= new List<ChargesRate>();
        }
    }

    [DataContract(Namespace = "MetraTech.MetraNet")]
    [Serializable]
    public class ChargesRate
    {
        [DataMember]
        public decimal Price { get; set; }

        [DataMember]
        public decimal UnitValue { get; set; }

        [DataMember]
        public decimal UnitAmount { get; set; }

        [DataMember]
        public decimal BaseAmount { get; set; }
    }

}
