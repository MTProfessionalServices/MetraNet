import unittest
import os
    
def load_tests(loader, tests, pattern):
    myDir = os.path.dirname(__file__)
    myTests = loader.discover(start_dir=myDir, pattern='TestSsEncoderEngine*.py')
    tests.addTests(myTests)
    return tests

