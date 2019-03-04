# mp2rage
SPM implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts


## Requirements
SPM12 : https://www.fil.ion.ucl.ac.uk/spm/software/spm12/


## Installation
Clone the repo : `git clone https://github.com/benoitberanger/mp2rage`,
or use direct download link [>> here <<](https://github.com/benoitberanger/mp2rage/archive/master.zip),
then place freshly downloaded/cloned directory in `spm12/toolbox/`, such as `spm12/toolbox/mp2rage`.
You can also use a symlink, such as `ln -s path/to/mp2rage path/to/spm12/toolbox/mp2rage`

That's all.

If you already started SPM in your MATLAB session, don't forget to refresh SPM paths with `spm_jobman('initcfg');`.


## How it works
This repo is an extension of _spm12_, thus it is meant to be used with spm job manager.

You can use the Batch Editor and open tab SPM > Tools > MP2RAGE > Remove background : ![rmbg](https://github.com/benoitberanger/mp2rage/blob/master/example/rmbg_gui.png)

To determine which regularization factor to use, you can use the job SPM > Tools > MP2RAGE > Interactive remove background
This will display the original UNI image and the denoised version and a popup where you can enter the regularization level and check the result immediatly.
