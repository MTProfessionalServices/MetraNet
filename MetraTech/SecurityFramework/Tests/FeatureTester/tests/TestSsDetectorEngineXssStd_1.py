import clr

clr.AddReference('MetraTech.SecurityFramework')

import pprint
import yaml
import AppTestBaseCommon
from MetraTech.SecurityFramework import *
from MetraTech.SecurityFramework.Core.Detector import *
from MetraTech.SecurityFramework.Core.Detector import *
       
class TestSsDetectorEngineXssStd1(AppTestBaseCommon.AppTestBaseCommon):            
    def setUp(self):
        print ' '
    
    def tearDown(self):
        print ' '
       
    def testXssInjectionDetectorDangerTags(self):
        #Test Xss injection attacks:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'XSS.DangerTags.yaml')):
                try:
                    #print '-------------------------------'
                    #testInputParam.DetectXss() <-- we'll support extension methods later (kcq)       
                    #processorEngine = SecurityKernel.Processor.Api.Execute(ProcessorEngineCategory.Xss.ToString() + '.XssDetector', testData['payload']);
                    processorEngine = SecurityKernel.Processor.Api.GetDefaultEngine(ProcessorEngineCategory.Xss.ToString())          
                    processorEngine.Execute(testData['payload'])
                    
                    print 'TEST FAILURE: Xss INJECTION NOT FOUND:'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except DetectorInputDataException, x:
                    print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message 
                except ProcessorException, x:
                    if (x.Errors is not None and x.Errors.Count > 0) :
                         #print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message, 'Reason : ', x.Errors[0].Reason
						 print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message
						 #print testData
                    else :
                         print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message
                   
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)		
			
			
    def testXssInjectionDetectorEncoded(self):
        #Test Xss injection attacks:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'XSS.Encoded.yaml')):
                try:
                    #print '-------------------------------'
                    #testInputParam.DetectXss() <-- we'll support extension methods later (kcq)       
                    #processorEngine = SecurityKernel.Processor.Api.Execute(ProcessorEngineCategory.Xss.ToString() + '.XssDetector', testData['payload']);
                    processorEngine = SecurityKernel.Processor.Api.GetDefaultEngine(ProcessorEngineCategory.Xss.ToString())          
                    processorEngine.Execute(testData['payload'])
                    
                    print 'TEST FAILURE: Xss INJECTION NOT FOUND:'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except DetectorInputDataException, x:
                    print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message 
                except ProcessorException, x:
                    if (x.Errors is not None and x.Errors.Count > 0) :
                         #print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message, 'Reason : ', x.Errors[0].Reason
						 print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message
						 #print testData
                    else :
                         print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message
                   
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)		
			
			
    def testXssInjectionDetectorNotEncoded(self):
        #Test Xss injection attacks:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'XSS.NotEncoded.yaml')):
                try:
                    #print '-------------------------------'
                    #testInputParam.DetectXss() <-- we'll support extension methods later (kcq)       
                    #processorEngine = SecurityKernel.Processor.Api.Execute(ProcessorEngineCategory.Xss.ToString() + '.XssDetector', testData['payload']);
                    processorEngine = SecurityKernel.Processor.Api.GetDefaultEngine(ProcessorEngineCategory.Xss.ToString())          
                    processorEngine.Execute(testData['payload'])
                    
                    print 'TEST FAILURE: Xss INJECTION NOT FOUND:'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except DetectorInputDataException, x:
                    print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message 
                except ProcessorException, x:
                    if (x.Errors is not None and x.Errors.Count > 0) :
                         #print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message, 'Reason : ', x.Errors[0].Reason
						 print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message
						 #print testData
                    else :
                         print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message
                   
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)		
			
    def testXssInjectionDetectorAll(self):
        #Test Xss injection attacks:
        failures = []
        try:
            for testData in yaml.load_all(open(self.testDataPath + 'Test.Xss.Attacks.yaml')):
                try:
                    #print '-------------------------------'
                    #testInputParam.DetectXss() <-- we'll support extension methods later (kcq)       
                    #processorEngine = SecurityKernel.Processor.Api.Execute(ProcessorEngineCategory.Xss.ToString() + '.XssDetector', testData['payload']);
                    processorEngine = SecurityKernel.Processor.Api.GetDefaultEngine(ProcessorEngineCategory.Xss.ToString())          
                    processorEngine.Execute(testData['payload'])
                    
                    print 'TEST FAILURE: Xss INJECTION NOT FOUND:'
                    pprint.pprint(testData)
                    #self.assertTrue(False,testData['id'])
                    failures.append(testData['id'])
                except DetectorInputDataException, x:
                    print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message 
                except ProcessorException, x:
                    if (x.Errors is not None and x.Errors.Count > 0) :
                         #print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message, 'Reason : ', x.Errors[0].Reason
						 print 'Injection found in ', ' [test id:', testData['id'], '] Inner Mess in ProcessorException : ', x.Errors[0].Message
						 #print testData
                    else :
                         print 'Injection found in ', ' [test id:', testData['id'], '] Mess : ', x.Message
                   
                except TypeError, x:
                    print x
        except TypeError, x:
            print x
        if len(failures) > 0:
            self.assertTrue(False,failures)		



#    def testDefaultXssInjectionDetectorNegatives(self):
#        #Test for Xss false positives:
#        failures = []
#        try:
#            for testData in yaml.load_all(open(self.testDataPath + 'Test.Xss.Negatives.yaml')):
#                try:
#                    #testInputParam.DetectXss() <-- we'll support extension methods later (kcq)       
#                    SecurityKernel.Detector.Api.Execute(DetectorEngineCategory.Xss.ToString() + '.V2', testData['payload']);
#                except DetectorInputDataException, x:
#                    print 'TEST FAILURE: Xss INJECTION FOUND IN ', x.Message, ' [test id:', testData['id'], ']'
#                    pprint.pprint(testData)
#                    #self.assertTrue(False,testData['id'])
#                    failures.append(testData['id'])
#                except TypeError, x:
#                    print x
#        except TypeError, x:
#            print x
#        if len(failures) > 0:
#            self.assertTrue(False,failures)   

#######################

if __name__ == '__main__':
    unittest.main()





