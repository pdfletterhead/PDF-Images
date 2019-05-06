# PDF Images with cli for Mac

We have created a fork of PDF Images from http://sourceforge.net/projects/pdf-images/ to add use from command line. PDF-Images is a Cocoa port of the pdfimages from the Poppler project. Popplers itself is based on the XPDF source code.

We needed the functionality of pdfimages from Popplerbecause we needed an command line method to export objects with transparency from InDesign CS4 to a PNG bitmap. We export single image objects from InDesign to a PDF with Acrobat version 8. We then use the PDF-Images app to extract the images. If there is only one image, this has no alpha channel, else we use convert to combine these images to a new bitmap with an alpha channel.


## Installation

It is possible to use Homebrew for installation since `pdfimages` is available in `poppler` package.

```
brew install poppler
```

## Usage

PDF-Images for Cocoa with cli

```
Usage: pdfimages [options]

Without options the drag'n'drop GUI is started.

  -h             : print usage information
  -i <filePath>  : path to PDF to use as input
  -j             : write JPEG images as JPEG files
  -p             : run in GUI despite other options

```
