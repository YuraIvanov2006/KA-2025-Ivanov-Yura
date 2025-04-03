@echo off
D:
CD D:\PROJECT
echo Trying to compile EXE
CALL TESTS\EXE.BAT PROJ

CD D:\PROJECT\TESTS
TASM cmp.asm > NUL
TLINK cmp > NUL
del /q PROJ.EXE > NUL

COPY D:\PROJECT\PROJ.EXE . > NUL
DEL D:\RESULT.TXT > NUL

echo Testing...
echo ================================================

echo V2_01
CALL TESTONE V2_01

echo ================================================

:end
del PROJ.*
del CMP.OBJ
del CMP.EXE
del CMP.MAP

type D:\RESULT.TXT
