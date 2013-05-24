
import pprint
import yaml
import AppTestBaseCommon
from MetraTech.SecurityFramework import *

       
class TestSsEncoderEngineHtmlStd1(AppTestBaseCommon.AppTestBaseCommon):            
    def setUp(self):
        print ' '
    
    def tearDown(self):
        print ' '

    def testDefaultUrlEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Url.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Url + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])    
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultUrlEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Url.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Url + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])                  
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 
                   
    def testDefaultHtmlEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Html.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Html + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)        

    def testDefaultHtmlEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Html.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Html + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)    
                   
    def testDefaultHtmlAttributeEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.HtmlAttribute.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.HtmlAttribute + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultHtmlAttributeEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.HtmlAttribute.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.HtmlAttribute + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)   

    def testDefaultJavaScriptEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.JavaScript.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.JavaScript + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultJavaScriptEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.JavaScript.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.JavaScript + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 

    def testDefaultCssEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Css.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Css + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultCssEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Css.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Css + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 
            
    def testDefaultBase64EncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Base64.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Base64.ToString() + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultBase64EncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Base64.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Base64.ToString() + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)   

    def testDefaultXmlEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Xml.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Xml + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultXmlEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Xml.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Xml + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)   

    def testDefaultXmlAttributeEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.XmlAttribute.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.XmlAttribute + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultXmlAttributeEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.XmlAttribute.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.XmlAttribute + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)  

    def testDefaultLdapEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Ldap.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Ldap + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultLdapEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Ldap.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Ldap + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 

    def testDefaultVbScriptEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.VbScript.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.VbScript + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultVbScriptEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.VbScript.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.VbScript + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 

    def testDefaultGzipEncoderSingleCharacters(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Gzip.Character.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Gzip + '.Default',testData['payload']) 
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for character: ', testData['id'], ' => ', testData['payload'], ' => ', x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)         

    def testDefaultGzipEncoderStrings(self):
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Encoder.Gzip.Strings.yaml')):
                try:      
                    testResult = SecurityKernel.Encoder.Api.Encode(EncoderEngineCategory.Gzip + '.Default',testData['payload'])
                    
                    if testData['expect'] != testResult:
                        failures.append(testData['id'])
                except TypeError, x:
                    print 'Encoding problem for string: ', testData['id'], ' => ', testData['payload'], ' => ', x  
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures) 

                                                            
#######################

if __name__ == '__main__':
    unittest.main()




