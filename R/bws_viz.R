#' Function for visualizing scaled documents
#'
#' Simple function for visualizing wordscores of scaled documents.
#' @param bws_df A dataframe returned by bwordscores function.
#' @param labels Custom labels for scaled documents visualized in graph. Default is NULL.
#' @param se Type of standard errors used in the graph: "mean_se" or "se_ws". Default is mean_se.
#' @keywords scaling wordscores bootstrapping visualizaiton
#' @export
#' @examples
#' bws_viz()

bws_viz <- function (bws_df, labels = NULL, se = "mean_se") {
  if (isFALSE("bws_df" %in% class(bws_df))) stop("The input must be a data.frame of class bws_df returned by bwordscores() function.")
  if (isFALSE(class(labels) %in% c("character", "NULL"))) stop("Not a valid format. Labels must be stored as a character vector with equal length to number of cases returned by bwordscores().")
  if (isFALSE(se %in% c("mean_se", "se_ws"))) stop("'se' does not have a valid value. It is ither 'mean_se' or 'se_ws'.")

if (!is.null(labels)) {
  bws_df$label <- labels
}

# filter and order the dataset
df_viz <- bws_df[, c("label", "mean_ws", "mean_se", "se_ws")] %>%
          .[order(.$mean_ws),]

# reorder factors
df_viz$label <- factor(df_viz$label, levels = df_viz$label[order(df_viz$mean_ws)])

if (se == "mean_se") {
  # visualize graph
  graph <- ggplot2::ggplot(df_viz, ggplot2::aes(x=mean_ws, y=label)) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin=mean_ws-mean_se, xmax=mean_ws+mean_se), width=.2, position=ggplot2::position_dodge(0.05), color = '#E69F00') +
    ggplot2::geom_point(color = '#999999', size = 2)+
    ggplot2::labs(x="Stabilized ws scores", y = "Documents")+
    ggplot2::theme_classic()
  return(graph)
} else {
  # visualize graph
  graph <- ggplot2::ggplot(df_viz, ggplot2::aes(x=mean_ws, y=label)) +
    ggplot2::geom_errorbar(ggplot2::aes(xmin=mean_ws-se_ws, xmax=mean_ws+se_ws), width=.2, position=ggplot2::position_dodge(0.05), color = '#E69F00') +
    ggplot2::geom_point(color = '#999999', size = 2)+
    ggplot2::labs(x="Stabilized ws scores", y = "Documents")+
    ggplot2::theme_classic()
  return(graph)
}

}
