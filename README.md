# Multi-view face detection trained on AFLW dataset.

This repo has the auxiliary Matlab and C++ code in order to replicate the face detection experiments in our paper.
**If you use this code for your own research, you must reference our journal paper**:
  
   * **BAdaCost: Multi-class Boosting with Costs.**
   Antonio Fernández-Baldera, José M. Buenaposada, and Luis Baumela.
   Pattern Recognition, Elsevier. In press, 2018.
   [DOI:10.1016/j.patcog.2018.02.022](https://doi.org/10.1016/j.patcog.2018.02.022)

## Requirements

* Clone [toolbox.badacost.public](https://github.com/jmbuena/toolbox.badacost.public) repo, with our modified version of Piotr Dollar toolbox with the BAdaCost algorithm with cost-sensitive trees. Go to its directory and execute Matlab. Then  from Matlab prompt, execute addpath(createpath(PATH_TO_TOOLBOX)) and then toolboxCompile. 
* Clone toolbox.badacost.faces.public, a set of tools and code to perform the faces detection experiments with the AFLW, AFW, PASCAL faces and FDDB datasets.

* We train our detector with face images from the Annotated Facial Landmarks in the Wild dataset. Thus, from the [AFLW site](https://lrs.icg.tugraz.at/research/aflw/) you have to download:
  * aflw-images-0.tar.gz, 
  * aflw-images-2.tar.gz and 
  * aflw-images-3.tar.gz
  
  by decompressing the tar.gz files we will get the following directory structure:

  
  ```
    aflw
	`-- data
		`-- flickr
		   |-- 0
		   |-- 2
		   `-- 3
	
  ```

  The path to the flicker folder in the example, with the AFLW training images (dirs 0, 2, 3) will be refered as *AFLW_PATH* from now on.

* The negative face images are obtained from the PASCAL VOC 2007 dataset. 
  Therefore we need to dowload the following files from the [PASCAL VOC site](http://host.robots.ox.ac.uk/pascal/VOC/):
  * VOCtest_06-Nov-2007.tar
  * VOCtestnoimgs_06-Nov-2007.tar
  * VOCtrainval_06-Nov-2007.tar
  
  by decompressing the tar files we will get the following directory structure:

  
  ```
	  pascal_voc
		`-- 2007
		    `-- VOCdevkit
			`-- VOC2007
			   |-- Annotations
			   `-- JPEGImages
  ```

  The path to the pascal_voc/2007/VOCdevkit/VOC2007 folder in the example, with the JPEGImages and Annotations subdirs will be refered as *PASCAL_VOC2007_PATH* from now on.



* The PASCAL Faces dataset, is extracted from different face images in the PASCAL VOC datasets.
  Therefore we need to dowload the following files from the [PASCAL VOC site](http://host.robots.ox.ac.uk/pascal/VOC/):
  * To be uncompressed in directory pascal_voc/2007:
     * VOCtrainval_06-Nov-2007.tar
     * VOCdevkit_08-Jun-2007.tar
     * VOCtest_06-Nov-2007.tar
     * VOCtestnoimgs_06-Nov-2007.tar
  * To be uncompressed in directory pascal_voc/2008:
     * VOCtrainval_14-Jul-2008.tar
     * VOCdevkit_14-Apr-2008.tar
     * VOC2008_test.tar
  * To be uncompressed in directory pascal_voc/2009_test:
     * InWGD4LN.tar
  * To be uncompressed in directory pascal_voc/2010_test:
     * VOC2010_test.tar
  * Untar the following files in the directory PASCAL_VOC/2011_test and
    then move 2011_test/Test/VOCdevkit to 2011_test/VOCdevkit
     * VO2011_test.tar
  * Untar the following files in the directory PASCAL_VOC/2012:
    * VOCdevkit_18-May-2011.tar
    * VOCtrainval_11-May-2012.tar

  by decompressing the tar files we will get the following directory structure:

  
  ```
     pascal_voc
	|
	|-- 2007
	|   `-- VOCdevkit
	|       `-- VOC2007
	|          |-- Annotations
	|          `-- JPEGImages
	|-- 2008_test
	|   `-- VOCdevkit
	|       `-- VOC2008
	|           |-- Annotations
	|           `-- JPEGImages
	|-- 2009_test
	|   `-- VOCdevkit
	|       `-- VOC2009
	|           |-- Annotations
	|           `-- JPEGImages
	|-- 2010_test
	|   `-- VOCdevkit
	|       `-- VOC2010
	|           |-- Annotations
	|           `-- JPEGImages
	|-- 2011_test
	|   `-- VOCdevkit
	|       `-- VOC2011
	|           |-- Annotations
	|           `-- JPEGImages
	`-- 2012
	    `-- VOCdevkit
		`-- VOC2012
		    |-- Annotations
		    `-- JPEGImages
  ```

  The path to the pascal_voc folder in the example, with the JPEGImages and Annotations subdirs will be refered as *PASCAL_VOC_PATH* from now on.

* The AFW dataset, which is in the file AFW.zip, can be downloaded from the [AFW site](https://www.ics.uci.edu/~xzhu/face/). Decompress all the images in the .zip in a single directory and se the variable AFW_PATH in the main.m script to this directory.


* Download the FDDB dataset and prepare data for P.Dollar toolbox by running
   the script:

   fddb2PiotrFormatMulticlass.m 

