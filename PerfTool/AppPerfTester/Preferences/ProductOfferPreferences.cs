using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace BaselineGUI
{
    public class ProductOfferPreferences : IPrefComp
    {
        public string name { set; get; }

        public bool staticEnabled { set; get; }
        public bool mutableEnabled { set; get; }

        public ProductOfferPreferences Clone()
        {
            ProductOfferPreferences p = new ProductOfferPreferences();
            p.name = name;
            p.staticEnabled = this.staticEnabled;
            p.mutableEnabled = this.mutableEnabled;
            return p;
        }

        public void setToDefaults()
        {
            staticEnabled = false;
            mutableEnabled = false;
        }
    }
}
