Volcano_Plot_GS <- function(degfile, label_features, gene_column = "gene", logfc_column = "avg_logFC",
                            pvalue_column = "p_val", padj_column = "p_val_adj",
                            label_padj = .05, point_alpha = 1, base_color = "gray",
                            sig_color = "black", gs_color = "purple", gs_size = 2,
                            logFCcollapse = NULL, pval_collapse = NULL){
  tryCatch({
    if(!is.null(logFCcollapse)){
      degfile$avg_logFC[degfile$avg_logFC < -logFCcollapse] <- -logFCcollapse
      degfile$avg_logFC[degfile$avg_logFC > logFCcollapse] <- logFCcollapse
    }
    if(!is.null(pval_collapse)){
      degfile$p_val[degfile$p_val < pval_collapse] <- pval_collapse
    }
    label_features <- label_features %>% tolower() %>% Hmisc::capitalize()
    missing.features <- label_features[!(label_features %in% degfile[[gene_column]])]
    label.data <- filter(degfile, degfile[[gene_column]] %in% label_features)
    sig.data <- filter(degfile, degfile[[padj_column]] < label_padj)
    p1 <- ggplot(data = degfile, aes(x = degfile[[logfc_column]], y = -log10(degfile[[pvalue_column]]))) +
      geom_point(alpha = point_alpha, color = base_color) +
      geom_point(alpha = point_alpha, data = sig.data, color = sig_color, aes(x = sig.data[[logfc_column]], y = -log10(sig.data[[pvalue_column]]))) +
      theme_classic() +
      geom_point(size = gs_size, color = gs_color, data = label.data, aes(x = label.data[[logfc_column]], y = -log10(label.data[[pvalue_column]]))) +
      ggrepel::geom_text_repel(segment.alpha = .5, color = gs_color, data = label.data, aes(x = label.data[[logfc_column]], y = -log10(label.data[[pvalue_column]]), label = label.data[[gene_column]])) +
      xlab("LogFC") +
      ylab("-Log10(p value)")
    if(length(missing.features) > 0){
      warning(paste0("missing feature: ",  missing.features, " "))
    }
    return(p1)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}
