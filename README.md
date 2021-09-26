# bws <img src="/man/bws.png" style="max-width:100%;" height="139" align="right">
*R package for bootstrapping wrodscores models for stabilized scores*

**bws** is a bootstrapping utility designed for stabilizing scaling scores across different reference documents. Build on top of quanteda wordscores function, the package automatically scales multiple wordscores models using user-defined pairs of reference documents and average the results as stabilized scaling scores.

## Overview
Testing has shown that choosing just one pair of documents for scaling using wordscores algorithm produces a scale that is not stable and often vary across different pairs of documents. In many situations, the reference documents are selected purely arbitrary which rises a relevant question what happens if different pairs of documents are selected. Unsurprisingly, the scores change as well. To mitigate this effect, the package bootstrap the potential pairs of relevant documents and average the results across multiple models, effectively stabilizing the scores across different settings. Apart from more robust results, the additional benefit of this approach is that we do not have to discard the reference documents or artificially rescaled them as they are rotated using bootstrapping and their scores are stabilized through iterations in which they are not part of the reference pairs.

## Installation Instruction
Install the package from the GitHub repository:
```
devtools::install_github('mmochtak/bws')
```
## Version
0.0.1

## Usage
The package contains two general functions: *bws*; *bws_viz*

-	*bws* is a general function for guided boostrapping of wordscores models using all combination of potential pairs of provided reference documents. The main input is a string vector with documents/texts to be scaled. Additionally, a user can specify document IDs as well as use some of the basic cleaning functions for pre-processing the input documents. The most important arguments of the function are indexes of documents used for scaling (l_scale; r_scale). l_; r_ denote virtual left/right sides of the scale. The indexes are added as numeric vectors (via a simple c() function) l_score; r_score are values assigned to modeled scales.

-	*bws_viz* is a simple function visualizing stabilized scores and their standard errors. It takes the data.frame produced by bws() function and returns a simple ggplot. 

## Practical Example
Coming soon

## Final Remarks
A paper properly explaining this package will come soon (it is on my to do list).