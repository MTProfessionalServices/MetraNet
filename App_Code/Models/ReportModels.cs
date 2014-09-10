using System;
using System.ComponentModel.DataAnnotations;

namespace ASP.Models
{
    #region Models

    public class RevRecModel
    {
        [Required]
        [Display(Name = "Currency")]
        public string Currency { get; set; }

        [Required]
        [Display(Name = "Revenue Part")]
        public string RevenuePart { get; set; }

        [Required]
        [Display(Name = "Amount1")]
        public double Amount1 { get; set; }

        [Required]
        [Display(Name = "Amount2")]
        public double Amount2 { get; set; }

        [Required]
        [Display(Name = "Amount3")]
        public double Amount3 { get; set; }

        [Required]
        [Display(Name = "Amount4")]
        public double Amount4 { get; set; }

        [Required]
        [Display(Name = "Amount5")]
        public double Amount5 { get; set; }

        [Required]
        [Display(Name = "Amount6")]
        public double Amount6 { get; set; }

        [Required]
        [Display(Name = "Amount7")]
        public double Amount7 { get; set; }

        [Required]
        [Display(Name = "Amount8")]
        public double Amount8 { get; set; }

        [Required]
        [Display(Name = "Amount9")]
        public double Amount9 { get; set; }

        [Required]
        [Display(Name = "Amount10")]
        public double Amount10 { get; set; }

        [Required]
        [Display(Name = "Amount11")]
        public double Amount11 { get; set; }

        [Required]
        [Display(Name = "Amount12")]
        public double Amount12 { get; set; }
    }

    public class SegregatedCharges
    {
      public string Currency { get; set; }
      public DateTime StartSubscriptionDate { get; set; }
      public DateTime EndSubscriptionDate { get; set; }
      
      public int ProrationDate { get; set; }
      public decimal ProrationAmount { get; set; }
    }

    #endregion

}
