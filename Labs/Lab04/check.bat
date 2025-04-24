@echo on
echo Checking TASM installation...
echo Current directory:
cd
echo.

echo Checking PATH:
set PATH
echo.

echo Checking TASM directory contents:
dir C:\TASM\*.* /w
echo.

echo Checking current directory contents:
dir *.* /w
echo.

pause 