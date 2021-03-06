#-----------------------------------------------------------------------------
# OpenCV
#-----------------------------------------------------------------------------

if(MITK_USE_OpenCV)

  # Sanity checks
  if(DEFINED OpenCV_DIR AND NOT EXISTS ${OpenCV_DIR})
    message(FATAL_ERROR "OpenCV_DIR variable is defined but corresponds to non-existing directory")
  endif()

  set(proj OpenCV)
  set(proj_DEPENDENCIES)
  set(OpenCV_DEPENDS ${proj})

  if(NOT DEFINED OpenCV_DIR)

    set(additional_cmake_args
      -DBUILD_opencv_java:BOOL=OFF
      -DBUILD_opencv_ts:BOOL=OFF
      -DBUILD_PERF_TESTS:BOOL=OFF
    )

    if(MITK_USE_Python)
      set(CV_PACKAGE_PATH -DPYTHON_PACKAGES_PATH:PATH=${ep_prefix}/lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages)

      list(APPEND additional_cmake_args
         -DBUILD_opencv_python:BOOL=ON
         -DBUILD_opencv_python3:BOOL=ON
         #-DBUILD_NEW_PYTHON_SUPPORT:BOOL=ON
         -DPYTHON_DEBUG_LIBRARY:FILEPATH=${PYTHON_DEBUG_LIBRARY}
         -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE}
         -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}
         -DPYTHON_INCLUDE_DIR2:PATH=${PYTHON_INCLUDE_DIR2}
         -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY}
         ${CV_PACKAGE_PATH}
         #-DPYTHON_LIBRARIES=${PYTHON_LIBRARY}
         #-DPYTHON_DEBUG_LIBRARIES=${PYTHON_DEBUG_LIBRARIES}
          )
    else()
      list(APPEND additional_cmake_args
         -DBUILD_opencv_python:BOOL=OFF
         -DBUILD_opencv_python3:BOOL=OFF
         -DBUILD_opencv_python_bindings_generator:BOOL=OFF
         #-DBUILD_NEW_PYTHON_SUPPORT:BOOL=OFF
          )
    endif()

    # 12-05-02, muellerm, added QT usage by OpenCV if QT is used in MITK
    # 12-09-11, muellerm, removed automatic usage again, since this will struggle with the MITK Qt application object
    if(MITK_USE_Qt5)
      list(APPEND additional_cmake_args
           -DWITH_QT:BOOL=OFF
           -DWITH_QT_OPENGL:BOOL=OFF
           -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
          )
    endif()

    if(CTEST_USE_LAUNCHERS)
      list(APPEND additional_cmake_args
        "-DCMAKE_PROJECT_${proj}_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake"
      )
    endif()

    mitk_query_custom_ep_vars()

    set(opencv_url ${MITK_THIRDPARTY_DOWNLOAD_PREFIX_URL}/opencv-3.4.1.tar.gz)
    set(opencv_url_md5 a0b7a47899e67b3490ea31edc4f6e8e6)
    ExternalProject_Add(${proj}
      LIST_SEPARATOR ${sep}
      URL ${opencv_url}
      URL_MD5 ${opencv_url_md5}
      CMAKE_GENERATOR ${gen}
      CMAKE_GENERATOR_PLATFORM ${gen_platform}
      CMAKE_ARGS
        ${ep_common_args}
        -DBUILD_TESTS:BOOL=OFF
        -DBUILD_DOCS:BOOL=OFF
        -DBUILD_EXAMPLES:BOOL=OFF
        -DBUILD_DOXYGEN_DOCS:BOOL=OFF
        -DWITH_CUDA:BOOL=OFF
        -DWITH_VTK:BOOL=OFF
        -DENABLE_CXX11:BOOL=ON
        -DWITH_IPP:BOOL=OFF
        -DBUILD_IPP_IW:BOOL=OFF
        ${additional_cmake_args}
        ${${proj}_CUSTOM_CMAKE_ARGS}
      CMAKE_CACHE_ARGS
        ${ep_common_cache_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_ARGS}
      CMAKE_CACHE_DEFAULT_ARGS
        ${ep_common_cache_default_args}
        ${${proj}_CUSTOM_CMAKE_CACHE_DEFAULT_ARGS}
      DEPENDS ${proj_DEPENDENCIES}
    )

    set(OpenCV_DIR ${ep_prefix})
    mitkFunctionInstallExternalCMakeProject(${proj})

  else()

    mitkMacroEmptyExternalProject(${proj} "${proj_DEPENDENCIES}")

  endif()

endif()
