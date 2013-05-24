@echo off
rem rem rem rem rem rem rem rem rem rem rem rem rem rem
rem
rem  Simple app to start and stop service for testing
rem
rem rem rem rem rem rem rem rem rem rem rem rem rem rem

SET OP=%1

sc.exe %OP% metratech.fileservice
