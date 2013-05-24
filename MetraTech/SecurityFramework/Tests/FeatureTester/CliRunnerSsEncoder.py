# VISUAL STUDIO CONFIG NOTE: DISABLE THESE OPTIONS IN VISUAL STUDIO
#
# Tools->Options->Debugging->General->Enable the exception assistant
# Tools->Options->Debugging->General->Enable Just My Code (Managed only)

import unittest
import os
import sys
import TestResultReport

def Prepare():
    myDir = os.path.dirname(os.path.abspath(__file__))
    sys.path.append(os.path.join(myDir,'framework'))
    myDir = os.path.join(myDir,'tests')
    suite = unittest.TestSuite()
    loader = unittest.TestLoader()
    tests = loader.discover(start_dir=myDir, pattern='SuiteSsEncoderAll_*.py')
    suite.addTests(tests)
    return suite
    
if __name__ == '__main__':
    runner = unittest.TextTestRunner(verbosity=2)
    testResult = runner.run (Prepare())
    report = TestResultReport.TestResultReport(testResult)
    report.Save('SsEncoder.TestResult')	



