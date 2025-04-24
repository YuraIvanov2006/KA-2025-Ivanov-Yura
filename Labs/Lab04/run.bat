@echo on
echo Setting up environment...
set PATH=C:\TASM;%PATH%
echo Current PATH is: %PATH%
echo.

echo Assembling with TASM...
TASM task01a.asm
if errorlevel 1 goto error

echo Linking with TLINK...
TLINK task01a.obj
if errorlevel 1 goto error

echo Running program...
task01a.exe
goto end

:error
echo Error occurred! Check if TASM is properly installed in C:\TASM
echo Required files: TASM.EXE, TLINK.EXE, TASM.MSG
dir C:\TASM\*.* /w

:end
pause 