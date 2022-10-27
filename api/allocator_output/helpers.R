### hill params
get_hill_params <- function(InputCollect, OutputCollect, dt_hyppar, dt_coef, mediaSpendSortedFiltered, select_model) {
  hillHypParVec <- unlist(select(dt_hyppar, na.omit(str_extract(names(dt_hyppar), ".*_alphas|.*_gammas"))))
  alphas <- hillHypParVec[str_which(names(hillHypParVec), "_alphas")]
  gammas <- hillHypParVec[str_which(names(hillHypParVec), "_gammas")]
  startRW <- InputCollect$rollingWindowStartWhich
  endRW <- InputCollect$rollingWindowEndWhich
  chnAdstocked <- filter(
    OutputCollect$mediaVecCollect,
    .data$type == "adstockedMedia",
    .data$solID == select_model
  ) %>%
    select(all_of(mediaSpendSortedFiltered)) %>%
    slice(startRW:endRW)
  gammaTrans <- mapply(function(gamma, x) {
    round(quantile(seq(range(x)[1], range(x)[2], length.out = 100), gamma), 4)
  }, gamma = gammas, x = chnAdstocked)
  names(gammaTrans) <- names(gammas)
  coefs <- dt_coef$coef
  names(coefs) <- dt_coef$rn
  coefsFiltered <- coefs[mediaSpendSortedFiltered]
  return(list(
    alphas = alphas,
    gammaTrans = gammaTrans,
    coefsFiltered = coefsFiltered
  ))
}


get_adstock_params <- function(InputCollect, dt_hyppar) {
  if (InputCollect$adstock == "geometric") {
    getAdstockHypPar <- unlist(select(dt_hyppar, na.omit(str_extract(names(dt_hyppar), ".*_thetas"))))
  } else if (InputCollect$adstock %in% c("weibull_cdf", "weibull_pdf")) {
    getAdstockHypPar <- unlist(select(dt_hyppar, na.omit(str_extract(names(dt_hyppar), ".*_shapes|.*_scales"))))
  }
  return(getAdstockHypPar)
}


check_daterange <- function(date_min, date_max, dates) {
  if (!is.null(date_min)) {
    if (length(date_min) > 1) stop("Set a single date for 'date_min' parameter")
    if (date_min < min(dates)) {
      warning(sprintf(
        "Parameter 'date_min' not in your data's date range. Changed to '%s'", min(dates)
      ))
    }
  }
  if (!is.null(date_max)) {
    if (length(date_max) > 1) stop("Set a single date for 'date_max' parameter")
    if (date_max > max(dates)) {
      warning(sprintf(
        "Parameter 'date_max' not in your data's date range. Changed to '%s'", max(dates)
      ))
    }
  }
}



library('nloptr')



eval_f <- function(X) {
  
  # eval_list <- get("eval_list", pos = as.environment(-1))
  eval_list <- getOption("ROBYN_TEMP")
  # mm_lm_coefs <- eval_list[["mm_lm_coefs"]]
  coefsFiltered <- eval_list[["coefsFiltered"]]
  alphas <- eval_list[["alphas"]]
  gammaTrans <- eval_list[["gammaTrans"]]
  mediaSpendSortedFiltered <- eval_list[["mediaSpendSortedFiltered"]]
  # exposure_selectorSortedFiltered <- eval_list[["exposure_selectorSortedFiltered"]]
  # vmaxVec <- eval_list[["vmaxVec"]]
  # kmVec <- eval_list[["kmVec"]]
  
  fx_objective <- function(x, coeff, alpha, gammaTran
                           # , chnName, vmax, km, criteria
  ) {
    # Apply Michaelis Menten model to scale spend to exposure
    # if (criteria) {
    #   xScaled <- mic_men(x = x, Vmax = vmax, Km = km) # vmax * x / (km + x)
    # } else if (chnName %in% names(mm_lm_coefs)) {
    #   xScaled <- x * mm_lm_coefs[chnName]
    # } else {
    #   xScaled <- x
    # }
    
    # Adstock scales
    xAdstocked <- x
    # Hill transformation
    xOut <- coeff * sum((1 + gammaTran**alpha / xAdstocked**alpha)**-1)
    xOut
    return(xOut)
  }
  
  objective <- -sum(mapply(
    fx_objective,
    x = X,
    coeff = coefsFiltered,
    alpha = alphas,
    gammaTran = gammaTrans,
    # chnName = mediaSpendSortedFiltered,
    # vmax = vmaxVec,
    # km = kmVec,
    # criteria = exposure_selectorSortedFiltered,
    SIMPLIFY = TRUE
  ))
  
  # https://www.derivative-calculator.net/ on the objective function 1/(1+gamma^alpha / x^alpha)
  fx_gradient <- function(x, coeff, alpha, gammaTran
                          # , chnName, vmax, km, criteria
  ) {
    # Apply Michaelis Menten model to scale spend to exposure
    # if (criteria) {
    #   xScaled <- mic_men(x = x, Vmax = vmax, Km = km) # vmax * x / (km + x)
    # } else if (chnName %in% names(mm_lm_coefs)) {
    #   xScaled <- x * mm_lm_coefs[chnName]
    # } else {
    #   xScaled <- x
    # }
    
    # Adstock scales
    xAdstocked <- x
    xOut <- -coeff * sum((alpha * (gammaTran**alpha) * (xAdstocked**(alpha - 1))) / (xAdstocked**alpha + gammaTran**alpha)**2)
    return(xOut)
  }
  
  gradient <- c(mapply(
    fx_gradient,
    x = X,
    coeff = coefsFiltered,
    alpha = alphas,
    gammaTran = gammaTrans,
    # chnName = mediaSpendSortedFiltered,
    # vmax = vmaxVec,
    # km = kmVec,
    # criteria = exposure_selectorSortedFiltered,
    SIMPLIFY = TRUE
  ))
  
  fx_objective.chanel <- function(x, coeff, alpha, gammaTran
                                  # , chnName, vmax, km, criteria
  ) {
    # Apply Michaelis Menten model to scale spend to exposure
    # if (criteria) {
    #   xScaled <- mic_men(x = x, Vmax = vmax, Km = km) # vmax * x / (km + x)
    # } else if (chnName %in% names(mm_lm_coefs)) {
    #   xScaled <- x * mm_lm_coefs[chnName]
    # } else {
    #   xScaled <- x
    # }
    
    # Adstock scales
    xAdstocked <- x
    xOut <- -coeff * sum((1 + gammaTran**alpha / xAdstocked**alpha)**-1)
    return(xOut)
  }
  
  objective.channel <- mapply(
    fx_objective.chanel,
    x = X,
    coeff = coefsFiltered,
    alpha = alphas,
    gammaTran = gammaTrans,
    # chnName = mediaSpendSortedFiltered,
    # vmax = vmaxVec,
    # km = kmVec,
    # criteria = exposure_selectorSortedFiltered,
    SIMPLIFY = TRUE
  )
  
  optm <- list(objective = objective, gradient = gradient, objective.channel = objective.channel)
  return(optm)
}

eval_g_eq <- function(X) {
  eval_list <- getOption("ROBYN_TEMP")
  constr <- sum(X) - eval_list$expSpendUnitTotal
  grad <- rep(1, length(X))
  return(list(
    "constraints" = constr,
    "jacobian" = grad
  ))
}

eval_g_ineq <- function(X) {
  eval_list <- getOption("ROBYN_TEMP")
  constr <- sum(X) - eval_list$expSpendUnitTotal
  grad <- rep(1, length(X))
  return(list(
    "constraints" = constr,
    "jacobian" = grad
  ))
}