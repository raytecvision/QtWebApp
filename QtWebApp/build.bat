@ECHO OFF
setlocal EnableDelayedExpansion

set project_path=QtWebApp
set install_path=C:\Raytec-Dev-3

REM **************************************************************************
REM **************************************************************************

set do_debug=0
set do_clean=0
set do_pause=1
set use_msvc=0

for %%x in (%*) do (
	IF "%%x"=="silent" ( set do_pause=0)
	IF "%%x"=="clean"  ( set do_clean=1)
	IF "%%x"=="debug"  ( set do_debug=1)
	IF "%%x"=="msvc" ( set use_msvc=1 )
)

for /d %%A in ("C:\Program Files (x86)\Windows Kits\10\bin\10.0."*) do (
	SET WINKITVER=%%~nxA
)
echo Windows Kit detected: %WINKITVER%

for /d %%A in ("C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\14."*) do (
	SET MSVCVER=%%~nxA
)
echo MSVC Version detected: %MSVCVER%

IF %use_msvc%==1 (
	set "INCLUDE=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\include;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\ucrt;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\shared;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\um;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\winrt;C:\Program Files (x86)\Windows Kits\10\include\%WINKITVER%\cppwinrt;"
	set "LIB=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x64;C:\Program Files (x86)\Windows Kits\10\lib\%WINKITVER%\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\lib\%WINKITVER%\um\x64;"
	set "LIBPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x64;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\lib\x86\store\references;C:\Program Files (x86)\Windows Kits\10\UnionMetadata\%WINKITVER%;C:\Program Files (x86)\Windows Kits\10\References\%WINKITVER%;"

	set "ADD_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\HostX64\x64;C:\Program Files (x86)\Windows Kits\10\bin\%WINKITVER%\x64;C:\Program Files (x86)\Windows Kits\10\bin\x64;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\bin;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\HostX64\x64;C:\Qt\Qt5.12.12\Tools\msvc2017_64\bin;C:\Qt\Qt5.12.12\5.12.12\msvc2017_64\bin;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Tools\MSVC\%MSVCVER%\bin\Hostx64\x64;C:\Qt\Qt5.12.12\Tools\QtCreator\bin\jom;"
)ELSE (
	set "ADD_PATH=C:\Qt\Qt5.5.1\Tools\mingw492_32\bin;C:\Qt\Qt5.5.1\5.5\mingw492_32\bin;"
)

set PATH=%PATH%;%ADD_PATH%

REM **************************************************************************
REM **************************************************************************

IF "%do_debug%"=="0" (
	IF %use_msvc%==1 (
		set make_path=build-%project_path%-Desktop_Qt_5_12_12_MSVC2017_64bit-Release
	) ELSE (
		set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Release
	)

	set make_tag=release
	set make_arguments=
) ELSE (
	IF %use_msvc%==1 (
		set make_path=build-%project_path%-Desktop_Qt_5_12_12_MSVC2017_64bit-Debug
	) ELSE (
		set make_path=build-%project_path%-Desktop_Qt_5_5_1_MinGW_32bit-Debug
	)

	set make_tag=debug
	set make_arguments="CONFIG+=debug"
)

REM **************************************************************************
REM **************************************************************************

cd ..\
IF "%do_clean%"=="1" ( 
	echo **************************************************************************
	echo *          %project_path% : CLEAR BUILD DIR AND INSTALLATION FILES
	echo **************************************************************************

	for /R %install_path%"\lib\"%make_tag% %%I in (Ray*.dll) do del "%%I"
	for /R %install_path%"\lib\"%make_tag% %%I in (libRay*.a) do del "%%I"

	rmdir /s /q %make_path% 
)


IF not exist %make_path%"\"  mkdir %make_path%  
cd %make_path% 


echo **************************************************************************
IF "%do_clean%"=="1" ( echo *         %project_path% : MAKE + CLEAN + BUILD 
)ELSE								 ( echo *         %project_path% : MAKE + BUILD 
)
echo **************************************************************************

IF %use_msvc%==1 (
	qmake ..\%project_path%\%project_path%.pro -r -spec win32-msvc %make_arguments%
) ELSE (
	qmake ..\%project_path%\%project_path%.pro -r -spec win32-g++ %make_arguments%
)

lrelease.exe ..\%project_path%\%project_path%.pro

IF "%do_clean%"=="1" (
	IF %use_msvc%==1 (
		jom clean
	) ELSE (
		mingw32-make clean
	)	
)
	
IF %use_msvc%==1 (
	jom -j%NUMBER_OF_PROCESSORS% install
) ELSE (
	mingw32-make -j%NUMBER_OF_PROCESSORS% install
)

cd ..\
cd %project_path%
IF "%do_pause%"=="1" ( pause )

endlocal