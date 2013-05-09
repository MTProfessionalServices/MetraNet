using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace WizardTest.Model
{
  public class PIModel
    {
      #region Singleton implementation

      private PIModel()
      {
      }

      private static PIModel _instance;

      public static PIModel Instance
      {
        get { return _instance ?? (_instance = new PIModel()); }
      }

      #endregion

      
      public ServiceDefinitionModel ServiceDefinition { get; set; }

      public ExtensionModel ExtensionModel { get; set; }
      

      public void SerializePIModel()
      {
        XmlSerializer serializer = new XmlSerializer(typeof(PIModel));
        TextWriter textWriter = new StreamWriter(String.Format(@"C:\{0}.xml", PIModel.Instance.ExtensionModel.Name));
        serializer.Serialize(textWriter, PIModel.Instance);
        textWriter.Close();
        
      }
    }
}
