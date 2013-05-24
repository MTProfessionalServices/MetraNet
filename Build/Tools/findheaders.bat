@echo off
gfind . -name "*.h" -print | sed -e "/include\/rw\//d"
