#' Function for running guided bootstrapping on wordscores algorithm using quanteda package
#'
#' This function allows training multiple wordscores models and extract stabilized indexes for scaled documents.
#' @param text Vector of strings that is going to be scaled.
#' @param doc_id Vector of strings containing the labels for scaled documents.
#' @param l_scale Numeric vector for selecting documents that should be virtually placed on the left side of the scale. 'l_sacale' does not necessarily refer to ideological position, rather it denotes one of the virtual ends on the scale.
#' @param r_scale Numeric vector for selecting documents that should be virtually placed on the right side of the scale. 'r_sacale' does not necessarily refer to ideological position, rather it denotes one of the virtual ends on the scale.
#' @param l_score A number indicating virtual value for l_ side of the scale. It is one the Ys in quanteda's textmodel_wordscores function. Default is 1.
#' @param r_score A number indicating virtual value for r_ side of the scale. It is one the Ys in quanteda's textmodel_wordscores function. Default is 10.
#' @param remove_no Logical parameter for removing numbers. Default is FALSE.
#' @param remove_punct Logical parameter for removing punctuation. Default is FALSE.
#' @param tolower Logical parameter for transforming strings to lower case. Default is FALSE.
#' @param remove_sw specify language of stopwords by ISO 639-1 code. Default is NULL.
#' @param min_termfrq Minimum values of feature frequencies across all documents, below/above which features will be removed. Default is NULL.
#' @param max_termfrq Maximum values of feature frequencies across all documents, below/above which features will be removed. Default is NULL.
#' @keywords scaling wordscores bootstrapping
#' @export
#' @examples
#' bws()

bws <- function (text, doc_id = NULL, l_scale, r_scale, l_score = 1, r_score = 10, remove_no = FALSE, remove_punct = FALSE,
                           tolower = FALSE, remove_sw = NULL, min_termfrq = NULL, max_termfrq = NULL) {
  if (isFALSE(class(text) == "character")) stop("text input must be a character vector.")
  if (isFALSE(class(doc_id) %in% c("character", "NULL"))) stop("doc_id input must be a character vector.")
  if (isFALSE(class(l_scale) %in% c("numeric", "integer"))) stop("l_scale must be a numeric vector indiciating which documents should be used for scaling.")
  if (isFALSE(class(r_scale) %in% c("numeric", "integer"))) stop("r_scale must be a numeric vector indiciating which documents should be used for scaling.")
  if (isFALSE(class(l_score) == "numeric")) stop("l_score must be a number indicating virtual value for l_ side of the scale.")
  if (isFALSE(class(r_score) == "numeric")) stop("r_score must be a number indicating virtual value for r_ side of the scale.")
  if (isFALSE(class(remove_no) == "logical")) stop("'remove_no' input must be of class 'logical'.")
  if (isFALSE(class(remove_punct) == "logical")) stop("'remove_punct' input must be of class 'logical'.")
  if (isFALSE(class(tolower) == "logical")) stop("'tolower' input must be of class 'logical'.")
  if (isFALSE(class(remove_sw) %in% c("character", "NULL"))) stop("Code for stopwords must be a string. See quanteda's `?stopwords_getlanguages` for more information on supported languages.")
  if (isFALSE(class(min_termfrq) %in% c("numeric", "NULL"))) stop("min_termfrq must be of class 'numeric'.")
  if (isFALSE(class(max_termfrq) %in% c("numeric", "NULL"))) stop("max_termfrq must be of class 'numeric'.")

  # create pairs of documents for bootstrapping
  all_pairs <- expand.grid(l_scale = t(combn(l_scale,1))[,1], r_scale = t(combn(r_scale,1))[,1])

  # create dfm for bootstrapping
  cat("Creating DFM object...  ")
  if (is.null(remove_sw)) {
    dfm <- quanteda::tokens(text) %>%
           quanteda::dfm(tolower = tolower, remove_punct = remove_punct, remove_numbers = remove_no) %>%
           quanteda::dfm_trim(min_termfreq = min_termfrq, max_termfrq = max_termfrq)
  } else {
    dfm <- quanteda::tokens(text) %>%
           quanteda::dfm(tolower = tolower, remove_punct = remove_punct, remove_numbers = remove_no) %>%
           quanteda::dfm_trim(min_termfreq = min_termfrq, max_termfrq = max_termfrq) %>%
           quanteda::dfm_remove(quanteda::stopwords(remove_sw))
  }
  cat("Done!")

  # containers
  final1 <- c()
  final2 <- c()
  combinations <- c()

  # wordscores scaling
  for (n in 1:nrow(all_pairs)) {
    cat(paste0("\nScaling pair: ", n, "/", nrow(all_pairs)))
    # predict Wordscores for the unknown virgin texts.
    ref_scores <- 1:length(text)
        ref_scores[1:length(text)] <- NA
    ref_scores[c(all_pairs[n, 1], all_pairs[n, 2])] <- c(l_score, r_score)
    tmod_ws <- quanteda.textmodels::textmodel_wordscores(dfm, y = ref_scores, smooth = 1)
    pred_ws <- predict(tmod_ws, se.fit = TRUE, newdata = dfm)

    label <- names(pred_ws$fit)
    values <- unname(pred_ws$fit)
    se <- pred_ws$se.fit
    values[c(all_pairs[n, 1], all_pairs[n, 2])] <- "scaling"
    one_pair1 <- cbind(label, values)
    one_pair2 <- cbind(label, se)
    combinations <- c(combinations, paste0("i_",all_pairs[n, 1], "-", "i_", all_pairs[n, 2]))

    if (n == 1) {
      final1 <- one_pair1
      final2 <- one_pair2
    } else {
      final1 <- cbind(final1, one_pair1[,2])
      final2 <- cbind(final2, one_pair2[,2])
    }
    colnames(final1)[2:ncol(final1)] <- combinations
    colnames(final2)[2:ncol(final2)] <- combinations
  }

  # count means
  cat("\nSummarizing scores...  ")
  bs <- as.data.frame(final1)
  se <- as.data.frame(final2)
  for (n in 1:length(text)) {
    i <- which(bs[n, ] == "scaling")
    if (length(i) > 0) {
      values <- as.numeric(bs[n, -i])[-1]
      serror <- as.numeric(se[n, -i])[-1]
    } else {
      values <- as.numeric(bs[n, ])[-1]
      serror <- as.numeric(se[n, ])[-1]
    }

    mean_ws <- mean(values)
    mean_se <- mean(serror)
    se_ws <- sd(values)/sqrt(length(values))
    bs$mean_ws[n] <- mean_ws
    bs$mean_se[n] <- mean_se
    bs$se_ws[n] <- se_ws
  }
  if(!is.null(doc_id)) {
    bs$label <- doc_id
  }

  class(bs) <- append(class(bs), 'bws_df')
  cat("Done!\n")
  return(bs)
}
