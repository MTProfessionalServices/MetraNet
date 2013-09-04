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
    public class QuoteIndividualPrice
    {
        [Key]
        [Required]
        [DataMember]
        public Guid Id { get; set; }

        [Required]
        [DataMember]
        public int QuoteId { get; set; }

        [Required]
        [DataMember]
        public int AccountId { get; set; }

        [Required]
        [DataMember]
        public int ProductOfferingId { get; set; }

        [Required]
        [DataMember]
        public int PriceableItemInstanceId { get; set; }

        [Required]
        [DataMember]        
        public int ParameterTableId { get; set; }

        [NotMapped]
        public List<BaseRateSchedule> RateSchedules { get; set; }

        [Required]
        [DataMember]
        public string RateSchedulesXml
        {
            get { return RateSchedules == null ? null : RateSchedules.Serialize(); }
            set { RateSchedules = string.IsNullOrEmpty(value) ? null : SerializationHelper.Deserialize<List<BaseRateSchedule>>(value); }
        }
    }

}
