To use such Isolation Frameworks as "FakeItEasy" or "Moq" class should be refactored to use Dependency Injection pattern.
See the example of refactoring DataExportReportManagementService class in Example_of_refactored_class folder.

To make "Moq" Unit Tests work run applyRefactoring.bat:
it will change and build DataExportReportManagementService class

Revert S:\MetraTech\Core\Services\DataExportReportManagementService.cs after observing example.