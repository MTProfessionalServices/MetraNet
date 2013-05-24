
import unittest
import clr
import os


clr.AddReference('AntiXssLibrary')
clr.AddReference('Microsoft.Data.Schema.ScriptDom')
clr.AddReference('Microsoft.Data.Schema.ScriptDom.Sql')
clr.AddReference('MetraTech.SecurityFramework')
import MetraTech.SecurityFramework.Common.Serialization.XmlSerializer

from System.IO import *
from MetraTech.SecurityFramework import *

class SpaHandler(ISecurityPolicyActionHandler, object):
    def Register(self):
        SecurityKernel.SecurityMonitor.ControlApi.AddPolicyActionHandler("MyApp", SecurityPolicyActionType.All,self)
 
    def Handle(self,policyAction,securityEvent):
        print 'GOT POLICY ACTION NOTIFICATION'
 
         
class AppTestBaseCommon(unittest.TestCase):
    basePath = os.path.dirname(os.path.abspath(__file__))
    parentPath = os.path.dirname(basePath)
    testDataPath = parentPath + "\\data\\"
        
    @classmethod
    def setUpClass(cls):
        try:
            cls._spaHandler = SpaHandler()
            sfPropsStoreLoc = Path.Combine(Directory.GetCurrentDirectory(), "framework\\MtSfConfigurationLoader.xml")
            xmlSerialazer = MetraTech.SecurityFramework.Common.Serialization.XmlSerializer()
        
            SecurityKernel.Initialize(xmlSerialazer, sfPropsStoreLoc)
            SecurityKernel.Start()
            #cls._spaHandler.Register()
        except SubsystemAccessException, x:
            print x
        except SubsystemApiAccessException, x:
            print x
        except TypeError, x:
            print x       

    @classmethod
    def tearDownClass(cls):
        try:
            SecurityKernel.Stop()
            SecurityKernel.Shutdown()
            cls._spaHandler = None
                    
        except SubsystemAccessException, x:
            print x
        except SubsystemApiAccessException, x:
            print x
        except TypeError, x:
            print x

       


 
 