using System.Runtime.Serialization;
using MetraTech.Domain.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System;

namespace MetraTech.Domain.Quoting
{
    /// <summary>
    /// The QuoteIndividualPrice class represents a ICB price in MetraNet.
    /// </summary>
    [DataContract(Namespace = "MetraTech.MetraNet")]
    public class QuoteIndividualPrice : IndividualPrice
    {
        [Key]
        [Required]
        [DataMember]
        public Guid Id { get; set; }

        [Required]
        [DataMember]
        public int QuoteId { get; set; }
        
        public string CurrentChargeTypeString
        {
            get { return CurrentChargeType.ToString(); }
            set
            {
                ChargeType couponAmountType;
                if (Enum.TryParse(value, true, out couponAmountType))
                    CurrentChargeType = couponAmountType;
            }
        }
        
        public string ChargesRatesXml
        {
            get { return ChargesRates == null ? null : ChargesRates.Serialize(); }
            set { ChargesRates = string.IsNullOrEmpty(value) ? null : SerializationHelper.Deserialize<List<ChargesRate>>(value); }
        }
    }

}
