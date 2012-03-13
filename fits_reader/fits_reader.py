"""
Fits file reader and extractor

version from 2012-03-12 23:50
@author: Rafael Kueng
"""

import numpy as np
import pyfits
import cv2 #using the new pure numpy python interface to opencv


def readfile():

    hdulist = pyfits.open('ib0r02010_drz.fits')

    print "\nThe file contains the following datasets, please select:\n(if unsure, use 1, resp the entry with name 'sci' and of type ImageHDU)\n"
    hdulist.info()
    sel = int(raw_input("\n>"))

    # output some useful information about the selected dataset
    header = hdulist[sel].header
    #print '\nYour selection has the following target:'
    #print header['targname']
    print '\nprinting out all the cards:'
    print header.ascardlist()


    # getting the data
    # TODO: some error correction if wrong selection done!!
    scidata = hdulist[sel].data
    print "\n\nGot data.."
    print "   - of shape:", np.shape(scidata)
    print "   - of type:", scidata.dtype.name


    #cleaning up
    hdulist.close()

    return scidata

def main():
    data = readfile()

    flags = 0 #cv2.CV_WINDOW_NORMAL | cv2.CV_WINDOW_KEEPRATIO | cv2.CV_GUI_EXPANDED
    cv2.namedWindow('FITS', flags)
    cv2.imshow('FITS', data)
    print "press space to save the file to out.jpg"
    ch = cv2.waitKey()
    if ch == ord(' '):
        # TODO: need to check if format is right, probably need to convert first using cvtColor...
        cv2.imwrite('out.jpg', data)
    #if ch == 27:
    #    break

if __name__ == '__main__':
    main()
else:
    mainclass()
