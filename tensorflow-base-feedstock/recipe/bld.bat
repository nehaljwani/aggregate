cd tensorflow\contrib\cmake

mkdir build
cd build

cmake .. ^
 -G"%CMAKE_GENERATOR%" ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DSWIG_EXECUTABLE=%LIBRARY_BIN%\swig.exe ^
 -DPYTHON_EXECUTABLE=%PREFIX%\python.exe ^
 -DPYTHON_LIBRARIES=%PREFIX%\python%CONDA_PY%.lib ^
 -Dtensorflow_BUILD_PYTHON_TESTS=ON ^
 -Dtensorflow_ENABLE_HDFS_SUPPORT=ON ^
 -Dtensorflow_BUILD_SHARED_LIB=ON
IF %ERRORLEVEL% NEQ 0 exit 1

MSBuild.exe /p:Configuration=Release tf_python_build_pip_package.vcxproj
IF %ERRORLEVEL% NEQ 0 exit 1

FOR /F "delims=" %%i IN ('dir /s /b tf_python\dist\*.whl') DO set tflow_wheel=%%i

pip install --no-deps %tflow_wheel%
IF %ERRORLEVEL% NEQ 0 exit 1

ctest -C Release --output-on-failure
IF %ERRORLEVEL% NEQ 0 exit 1
