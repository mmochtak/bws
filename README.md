# bws <img src="/man/bws.png" style="max-width:100%;" height="139" align="right">
*R package for bootstrapping wrodscores models for stabilized scores*

**bws** is a bootstrapping utility designed for stabilizing scaling scores across different reference documents. Build on top of the quanteda wordscores function, the package automatically scales multiple wordscores models using user-defined pairs of reference documents and averages the results as stabilized scaling scores.

## Overview
Testing has shown that choosing just one pair of documents for scaling using the wordscores algorithm produces a scale that is not stable and often varies across different pairs of documents. In many situations, the reference documents are selected arbitrarily, which raises the question of what happens if different pairs of documents are selected. Unsurprisingly, the scores change as well. To mitigate this effect, the package bootstraps the potential pairs of relevant documents and averages the results across multiple models, effectively stabilizing the scores across different settings. Apart from more robust results, the additional benefit of this approach is that we do not have to discard the reference documents or artificially rescale them as they are rotated using bootstrapping and their scores are stabilized through iterations in which they are not part of the reference pairs.

## Installation Instruction
Install the package from the GitHub repository:
```
devtools::install_github('mmochtak/bws')
```
## Version
0.0.1

## Usage
The package contains two general functions: *bws*; *bws_viz*

-	*bws* is a general function for guided bootstrapping of wordscores models using all combinations of potential pairs of provided reference documents. The main input is a string vector with documents/texts to be scaled. Additionally, a user can specify document IDs as well as use some of the basic cleaning functions for pre-processing the input documents. The most important arguments of the function are indexes of documents used for scaling (l_scale; r_scale). l_; r_ denote virtual left/right sides of the scale. The indexes are added as numeric vectors (via a simple c() function) l_score; r_score are values assigned to modeled scales.

-	*bws_viz* is a simple function visualizing stabilized scores and their standard errors. It takes the data.frame produced by bws() function and returns a simple ggplot . 

## Practical Example
First, load the bws package.

```
library(bws)
```

For the purpose of this example, we will use the corpus of inaugural speeches of the US president that comes with the *quanteda* package. We will subset the corpus to only speeches presented after 1900.

```
df <- data_corpus_inaugural %>% convert(to = "data.frame") %>% subset(., Year > 1900)
```

Let's clean the document IDs for the plot that will come later.

```
df$doc_id <- gsub("\\.txt", "", df$doc_id)
```

In the next step, we set the anchor documents which are used for creating pairs for running bootstrapped models. *l* and *r* denote virtual left and right sides of the scale. Both variables are simple numeric vectors with indexes of documents that fall under one of the categories and should be regarded as *anchor documents*. In other words, documents 28, 17, 9, and 10 are all used as anchor documents for the left side of the spectrum. On the other hand, documents number 1, 7, 30, and 27 define the anchors of the right side of the spectrum. This is just a mock-up example. The indexes do not have any specific policy or positional meaning. 

```
l <- c(28, 17, 9, 10)
r <- c(1, 7, 30, 27)
```

In order to run the bootstrapping algorithm, we simply call the *bws()* function. The number of bootstraps is defined by the number of all combinations of anchor documents. In our example, that's 4x4 combinations (16 in total). Many of the parameters are automatically inherited from the quanteda processing pipeline. See the information associated with each of them when calling the *bws()* function.

```
ws_df <- bws(text = df$text, doc_id = df$doc_id, l_scale = l, r_scale = r,
             l_score = 1, r_score = 10, remove_no = T, remove_punct = T, tolower = T, 
             remove_sw = "en", min_termfrq = 5)
```

Finally, to visualize the scores, call the *bws_viz()* function on the *ws_df* object.

```
bws_viz(ws_df)
```

## Final Remarks
For a more thorough theoretical overview, see the paper "Bias in the Eye of Beholder? 25 Years of Election Monitoring in Europe", Democratization, 29 (5): 899-917. If you use the package, please cite:
> Mochtak, Michal, Adam Drnovsky, and Christophe Lesschaeve (2022): "Bias in the Eye of Beholder? 25 Years of Election Monitoring in Europe". Democratization, 29 (5): 899-917. [link](https://www.tandfonline.com/doi/full/10.1080/13510347.2021.2019219)
