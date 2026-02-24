# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "apps\\TtwGalleryApp\\CMakeFiles\\TtwGalleryApp_autogen.dir\\AutogenUsed.txt"
  "apps\\TtwGalleryApp\\CMakeFiles\\TtwGalleryApp_autogen.dir\\ParseCache.txt"
  "apps\\TtwGalleryApp\\TtwGalleryApp_autogen"
  "libs\\Ttw\\Core\\CMakeFiles\\TtwCore_autogen.dir\\AutogenUsed.txt"
  "libs\\Ttw\\Core\\CMakeFiles\\TtwCore_autogen.dir\\ParseCache.txt"
  "libs\\Ttw\\Core\\CMakeFiles\\TtwCore_qtprotoreg_autogen.dir\\AutogenUsed.txt"
  "libs\\Ttw\\Core\\CMakeFiles\\TtwCore_qtprotoreg_autogen.dir\\ParseCache.txt"
  "libs\\Ttw\\Core\\TtwCore_autogen"
  "libs\\Ttw\\Core\\TtwCore_qtprotoreg_autogen"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUI_autogen.dir\\AutogenUsed.txt"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUI_autogen.dir\\ParseCache.txt"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUIplugin_autogen.dir\\AutogenUsed.txt"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUIplugin_autogen.dir\\ParseCache.txt"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUIplugin_init_autogen.dir\\AutogenUsed.txt"
  "libs\\Ttw\\UI\\CMakeFiles\\TtwUIplugin_init_autogen.dir\\ParseCache.txt"
  "libs\\Ttw\\UI\\TtwUI_autogen"
  "libs\\Ttw\\UI\\TtwUIplugin_autogen"
  "libs\\Ttw\\UI\\TtwUIplugin_init_autogen"
  )
endif()
