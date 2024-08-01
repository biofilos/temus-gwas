# Manhattan viewer

This is the first draft of an application to visualise Regenie results in an interactive dashboard.

## Installation
This application can be installed with pip, by using the provided `.whl` file, by executing the command `pip install dist/view_manhattan-0.1.0-py3-none-any.whl`

# Usage
After running the command `view-manhattan <directory with regenie files>`, open a web browser on [localhost:8050](http://localhost:8050). A Web interface will show the manhattan plot for the first population in the file set. Different populations can be selected, as well as different phenotypes. At the bottom of the page, a table with the variants above the -Log10(pvalue) threshold will be displayed.