import clr

clr.AddReference('MetraTech.SecurityFramework')

import pprint
import yaml
import AppTestBaseCommon
from MetraTech.SecurityFramework import *
from MetraTech.SecurityFramework.Core.Detector import *

       
class TestSsDetectorEngineSqlStd1(AppTestBaseCommon.AppTestBaseCommon):            
    def setUp(self):
        print ' '
    
    def tearDown(self):
        print ' '
       
    def testDefaultSqlInjectionDetectorAttacks(self):
        #Test SQL injection attacks:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Sql.Attacks.yaml')):
                try:
                    #testInputParam.DetectSql() <-- we'll support extension methods later (kcq)     
                    SecurityKernel.Detector.Api.Execute(DetectorEngineCategory.Sql.ToString() + '.Default', testData['payload']);
                    
                    print 'TEST FAILURE: SQL INJECTION NOT FOUND:'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except DetectorInputDataException, x:
                    print 'Injection found in ', x.Message, ' [test id:', testData['id'], ']'
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)		

    def testDefaultSqlInjectionDetectorNegatives(self):
        #Test for SQL false positives:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Sql.Negatives.yaml')):
                try:
                    #testInputParam.DetectSql() <-- we'll support extension methods later (kcq)       
                    SecurityKernel.Detector.Api.Execute(DetectorEngineCategory.Sql.ToString() + '.Default', testData['payload']);
                except DetectorInputDataException, x:
                    print 'TEST FAILURE: SQL INJECTION FOUND IN ', x.Message, ' [test id:', testData['id'], ']'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)   

#######################

if __name__ == '__main__':
    unittest.main()





