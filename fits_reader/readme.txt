FITS FILE READER FOR PYTHON

Install Instructions
0.  Make sure you have:
    - python 2.7 32bit
    - numpy

1.  download and install pyfits
2.  download & install opencv

2.a win) use the superpack
    - unpack it to some $OPENCVPATH$
    - copy the python modules from $OPENCVPATH$\build\python to $PYTHONPATH$\Lib\site-packages
    - set system variables
        press win+pause, "extended system settings", "environment variables", under the section systemvariables:
        * click new, name: "OPENCV_DIR"; value: $OPENCVPATH$\build\x86\mingw
        * klick on path, edit, and add the following to the end:
          ;$OPENCV_DIR$\bin
      
      OR

        enter on commandline:
        setx -m OPENCV_DIR $OPENCVPATH$\build\x86\mingw
        setx -m path %path%;$OPENCVPATH$\build\x86\mingw\bin
   
    HINT:
    replace $OPENCVPATH$ and $PYTHONPATH$ with the folders you're using in your system:
    example:
    setx -m OPENCV_DIR D:\opencv\build\x86\mingw
    setx -m path %path%;D:\opencv\build\x86\mingw\bin
 
2.b linux) havent tried yet, probably use sources and compile..
    see here:
    http://opencv.itseez.com/doc/tutorials/introduction/linux_install/linux_install.html#linux-installation
   


-------------------
some links / dokus
-------------------

pyfits:
    http://www.stsci.edu/institute/software_hardware/pyfits/
    http://www.stsci.edu/institute/software_hardware/pyfits/Download

opencv:
-   manual for python interface
    http://opencv.itseez.com/index.html
-   download link
    http://sourceforge.net/projects/opencvlibrary/files/opencv-win/

other useful links:
-   fits library overview:
    http://fits.gsfc.nasa.gov/fits_libraries.html