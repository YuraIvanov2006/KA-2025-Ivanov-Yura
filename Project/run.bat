@echo on
echo Compiling and running PROJ...
echo ----------------------------

echo Compiling with TASM...
TASM PROJ.asm
if errorlevel 1 goto error

echo Linking with TLINK...
TLINK PROJ.obj
if errorlevel 1 goto error

echo Running program...
PROJ.exe
goto end

:error
echo Error during compilation or linking!

:end
echo ----------------------------
echo Done. 