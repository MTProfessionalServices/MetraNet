
import pprint
import os

class TestResultReport:
    filename = 'TestResults'
	
    def __init__(self, testResult):
        self.result = testResult
        
    def Save(self, filename=None):
        if filename != None:
            self.filename = filename
        
        fstream = file(self.filename + '.report', 'w')
        
        errorCount = len(self.result.errors)
        failureCount = len(self.result.failures)
        fstream.write("REPORT SUMMARY: ====================================================\n\n")
        fstream.write("EXECUTED TEST COUNT: " + str(self.result.testsRun) + "\n")
        fstream.write("TESTS ERROR COUNT: " + str(errorCount) + "\n")
        fstream.write("TESTS FAILURE COUNT: " + str(failureCount) + "\n")
        
        fstream.write("\n\nTEST ERRORS: =======================================================\n\n")
        
        for i in range(errorCount):
            fstream.write("---------------------------------------------------------------------\n")
            fstream.write("ERROR NUMBER: " + str(i) + "\n")
            fstream.write("ERROR INFO:\n")
            einfo = self.result.errors[i][0]
            fstream.write("Module: " + einfo.__module__ + "\n")
            fstream.write("Class: " + einfo.__class__.__name__ + "\n")
            fstream.write("Method: " + einfo._testMethodName + "\n")
            fstream.write("\nERROR DATA:\n")
            fstream.write(self.result.errors[i][1])
            fstream.write("\n---------------------------------------------------------------------\n")
        
        fstream.write("\n\nTEST FAILURES: =====================================================\n\n")
       
        for i in range(failureCount):
            fstream.write("---------------------------------------------------------------------\n")
            fstream.write("FAILURE NUMBER: " + str(i) + "\n")
            fstream.write("FAILURE INFO:\n")
            finfo = self.result.failures[i][0]
            fstream.write("Module: " + finfo.__module__ + "\n")
            fstream.write("Class: " + finfo.__class__.__name__ + "\n")
            fstream.write("Method: " + finfo._testMethodName + "\n")
            fstream.write("\nFAILURE DATA:\n")
            fstream.write(self.result.failures[i][1])
            fstream.write("\n---------------------------------------------------------------------\n")        
        
        fstream.write("\n\nEND OF REPORT: =====================================================\n\n")
        fstream.flush()
        fstream.close()

 