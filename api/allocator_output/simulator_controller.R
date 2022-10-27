library(plumber)
### load object for API call
library(plumber)
library(dplyr)
library(Robyn)
library(stringr)
library(symengine)
library(nloptr)
library(dplyr)



# build the model and return REST API
source("allocator.R")
source("helpers.R")

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}


#* @apiTitle Robyn Hackaton infraprice.io team
#* @apiDescription Api build from Robyn Object to simulate difference scenarios
#* @get /robyn_scenarios_endpoint
robyn_scenarios_endpoint <-
  function(expected_spend,
           expected_spend_days,
           facebook_S_low,
           facebook_S_high,
           ooh_S_low,
           ooh_S_high,
           print_S_low,
           print_S_high,
           search_S_low,
           search_S_high,
           tv_S_low,
           tv_S_high,
           scenario) {
    expected_spend = as.numeric(expected_spend)
    expected_spend_days = as.numeric(expected_spend_days)
    facebook_S_low  = as.numeric(facebook_S_low)
    facebook_S_high = as.numeric(facebook_S_high)
    ooh_S_low = as.numeric(ooh_S_low)
    ooh_S_high = as.numeric(ooh_S_high)
    print_S_low = as.numeric(print_S_low)
    print_S_high = as.numeric(print_S_high)
    search_S_low = as.numeric(search_S_low)
    search_S_high = as.numeric(search_S_high)
    tv_S_low = as.numeric(tv_S_low)
    tv_S_high = as.numeric(tv_S_high)
    scenario = as.character(scenario) ## "max_response_expected_spend" new spend or "max_historical_response" same spend
    
    AllocatorCollect2 <- robyn_allocator(
      InputCollect = InputCollect,
      OutputCollect = OutputCollect,
      select_model = select_model,
      scenario = scenario,
      channel_constr_low = c(
        facebook_S_low,
        ooh_S_low,
        print_S_low,
        search_S_low,
        tv_S_low
      ),
      channel_constr_up = c(
        facebook_S_high,
        ooh_S_high,
        print_S_high,
        search_S_high,
        tv_S_high
      ),
      expected_spend = expected_spend,
      # Total spend to be simulated
      expected_spend_days = expected_spend_days,
      # Duration of expected_spend in days
      export = TRUE
    )
    
    output.mmm <- AllocatorCollect2$dt_optimOut
    ### Select table and building aggreated metrics
    dfe <-
      output.mmm %>% select(initSpendUnit , optmSpendUnit, initRoiUnit, optmRoiUnit)
    dfe$initNmV <- dfe$initSpendUnit * dfe$initRoiUnit
    dfe$optmNmV <- dfe$optmSpendUnit * dfe$optmRoiUnit
    dfe$initCiR <- dfe$initSpendUnit / dfe$initNmV * 100
    dfe$optmCiR <- dfe$optmSpendUnit / dfe$optmNmV * 100
    dfe$initROAS <- dfe$initNmV / dfe$initSpendUnit
    dfe$optmROAS <- dfe$optmNmV / dfe$optmSpendUnit
    
    
    ## Set local data & params values
    if (TRUE) {
      dt_mod <- InputCollect$dt_mod
      paid_media_vars <- InputCollect$paid_media_vars
      paid_media_spends <- InputCollect$paid_media_spends
      startRW <- InputCollect$rollingWindowStartWhich
      endRW <- InputCollect$rollingWindowEndWhich
      adstock <- InputCollect$adstock
      media_order <- order(paid_media_spends)
      mediaVarSorted <- paid_media_vars[media_order]
      mediaSpendSorted <- paid_media_spends[media_order]
    }
    
    
    
    # Channels contrains
    channel_constr_low = c(facebook_S_low,
                           ooh_S_low,
                           print_S_low,
                           search_S_low,
                           tv_S_low)
    channel_constr_up = c(facebook_S_high,
                          ooh_S_high,
                          print_S_high,
                          search_S_high,
                          tv_S_high)
    
    if (length(channel_constr_low) == 1) {
      channel_constr_low <-
        rep(channel_constr_low, length(paid_media_spends))
    }
    if (length(channel_constr_up) == 1) {
      channel_constr_up <-
        rep(channel_constr_up, length(paid_media_spends))
    }
    names(channel_constr_low) <- paid_media_spends
    names(channel_constr_up) <- paid_media_spends
    channel_constr_low <- channel_constr_low[media_order]
    channel_constr_up <- channel_constr_up[media_order]
    
    # Hyper-parameters and results
    dt_hyppar <-
      filter(OutputCollect$resultHypParam, .data$solID == select_model)
    dt_bestCoef <-
      filter(
        OutputCollect$xDecompAgg,
        .data$solID == select_model,
        .data$rn %in% paid_media_spends
      )
    
    ## Sort table and get filter for channels mmm coef reduced to 0
    dt_coef <- select(dt_bestCoef, .data$rn, .data$coef)
    get_rn_order <- order(dt_bestCoef$rn)
    dt_coefSorted <- dt_coef[get_rn_order,]
    dt_bestCoef <- dt_bestCoef[get_rn_order,]
    coefSelectorSorted <- dt_coefSorted$coef > 0
    names(coefSelectorSorted) <- dt_coefSorted$rn
    
    ## Filter and sort all variables by name that is essential for the apply function later
    if (!all(coefSelectorSorted)) {
      chn_coef0 <-
        setdiff(names(coefSelectorSorted), mediaSpendSorted[coefSelectorSorted])
      message(
        "Excluded in optimiser because their coefficients are 0: ",
        paste(chn_coef0, collapse = ", ")
      )
    } else {
      chn_coef0 <- "None"
    }
    mediaSpendSortedFiltered <- mediaSpendSorted[coefSelectorSorted]
    dt_hyppar <-
      select(dt_hyppar, hyper_names(adstock, mediaSpendSortedFiltered)) %>%
      select(sort(colnames(.)))
    dt_bestCoef <-
      dt_bestCoef[dt_bestCoef$rn %in% mediaSpendSortedFiltered,]
    channelConstrLowSorted <-
      channel_constr_low[mediaSpendSortedFiltered]
    channelConstrUpSorted <-
      channel_constr_up[mediaSpendSortedFiltered]
    
    
    ## Get adstock parameters for each channel
    getAdstockHypPar <- get_adstock_params(InputCollect, dt_hyppar)
    
    
    
    hills <- get_hill_params(
      InputCollect,
      OutputCollect,
      dt_hyppar,
      dt_coef,
      mediaSpendSortedFiltered,
      select_model
    )
    
    alphas <- hills$alphas
    gammaTrans <- hills$gammaTrans
    coefsFiltered <- hills$coefsFiltered
    
    
    
    # Spend values based on date range set
    dt_optimCost <- slice(dt_mod, startRW:endRW)
    df_date <- dt_optimCost$ds
    date_min <- min(dt_optimCost$ds)
    date_max <- max(dt_optimCost$ds)
    
    check_daterange(date_min, date_max, dt_optimCost$ds)
    if (is.null(date_min))
      date_min <- min(dt_optimCost$ds)
    if (is.null(date_max))
      date_max <- max(dt_optimCost$ds)
    if (date_min < min(dt_optimCost$ds))
      date_min <- min(dt_optimCost$ds)
    if (date_max > max(dt_optimCost$ds))
      date_max <- max(dt_optimCost$ds)
    histFiltered <-
      filter(dt_optimCost, .data$ds >= date_min & .data$ds <= date_max)
    nPeriod <- nrow(histFiltered)
    message(
      sprintf(
        "Date Window: %s:%s (%s %ss)",
        date_min,
        date_max,
        nPeriod,
        InputCollect$intervalType
      )
    )
    
    histSpendB <-
      select(histFiltered, any_of(mediaSpendSortedFiltered))
    histSpendTotal <- sum(histSpendB)
    histSpend <-
      unlist(summarise_all(select(
        histFiltered, any_of(mediaSpendSortedFiltered)
      ), sum))
    histSpendUnit <-
      unlist(summarise_all(histSpendB, function(x)
        sum(x) / sum(x > 0)))
    histSpendUnit[is.nan(histSpendUnit)] <- 0
    histSpendUnitTotal <- sum(histSpendUnit, na.rm = TRUE)
    histSpendShare <- histSpendUnit / histSpendUnitTotal
    
    
    json_file = ('/Robyn_202210031118_init/RobynModel-1_179_10.json')
    
    # Response values based on date range -> mean spend
    noSpendMedia <- histResponseUnitModel <- NULL
    for (i in seq_along(mediaSpendSortedFiltered)) {
      if (histSpendUnit[i] > 0) {
        val <- robyn_response(
          json_file = json_file,
          robyn_object = robyn_object,
          select_build = select_build,
          media_metric = mediaSpendSortedFiltered[i],
          select_model = select_model,
          metric_value = histSpendUnit[i],
          dt_hyppar = OutputCollect$resultHypParam,
          dt_coef = OutputCollect$xDecompAgg,
          InputCollect = InputCollect,
          OutputCollect = OutputCollect,
          #quiet = quiet
        )$response
      } else {
        val <- 0
        noSpendMedia <- c(noSpendMedia, mediaSpendSortedFiltered[i])
      }
      histResponseUnitModel <- c(histResponseUnitModel, val)
    }
    names(histResponseUnitModel) <- mediaSpendSortedFiltered
    if (!is.null(noSpendMedia)) {
      message("Media variables with 0 spending during this date window: ",
              v2t(noSpendMedia))
    }
    
    
    scenario = as.character(scenario)
    
    if ("max_historical_response" %in% scenario) {
      expected_spend <- histSpendTotal
      expSpendUnitTotal <- histSpendUnitTotal
    } else {
      expSpendUnitTotal <-
        expected_spend / (expected_spend_days / InputCollect$dayInterval)
    }
    
    # Gather all values that will be used internally on optim (nloptr)
    eval_list <- list(
      coefsFiltered = coefsFiltered,
      alphas = alphas,
      gammaTrans = gammaTrans,
      mediaSpendSortedFiltered = mediaSpendSortedFiltered,
      expSpendUnitTotal = expSpendUnitTotal
    )
    
    options("ROBYN_TEMP" = eval_list)
    
    
    
    x0 <- lb <- histSpendUnit * channelConstrLowSorted
    ub <- histSpendUnit * channelConstrUpSorted
    
    optim_algo = "SLSQP_AUGLAG"
    
    ## Set optim options
    if (optim_algo == "MMA_AUGLAG") {
      local_opts <- list("algorithm" = "NLOPT_LD_MMA",
                         "xtol_rel" = 1.0e-10)
    } else if (optim_algo == "SLSQP_AUGLAG") {
      local_opts <- list("algorithm" = "NLOPT_LD_SLSQP",
                         "xtol_rel" = 1.0e-10)
    }
    
    constr_mode = "eq"
    maxeval = 100000
    
    ## Run optim
    nlsMod <- nloptr::nloptr(
      x0 = x0,
      eval_f = eval_f,
      eval_g_eq = if (constr_mode == "eq")
        eval_g_eq
      else
        NULL,
      eval_g_ineq = if (constr_mode == "ineq")
        eval_g_ineq
      else
        NULL,
      lb = lb,
      ub = ub,
      opts = list(
        "algorithm" = "NLOPT_LD_AUGLAG",
        "xtol_rel" = 1.0e-10,
        "maxeval" = maxeval,
        "local_opts" = local_opts
      )
    )
    
    ## Collect output
    dt_optimOut <- data.frame(
      solID = select_model,
      dep_var_type = InputCollect$dep_var_type,
      channels = mediaSpendSortedFiltered,
      date_min = date_min,
      date_max = date_max,
      periods = sprintf("%s %ss", nPeriod, InputCollect$intervalType),
      constr_low = channelConstrLowSorted,
      constr_up = channelConstrUpSorted,
      # Initial
      histSpend = histSpend,
      histSpendTotal = histSpendTotal,
      initSpendUnitTotal = histSpendUnitTotal,
      initSpendUnit = histSpendUnit,
      initSpendShare = histSpendShare,
      initResponseUnit = histResponseUnitModel,
      initResponseUnitTotal = sum(histResponseUnitModel),
      initRoiUnit = histResponseUnitModel / histSpendUnit,
      # Expected
      expSpendTotal = expected_spend,
      expSpendUnitTotal = expSpendUnitTotal,
      expSpendUnitDelta = expSpendUnitTotal / histSpendUnitTotal - 1,
      # Optimized
      optmSpendUnit = nlsMod$solution,
      optmSpendUnitDelta = (nlsMod$solution / histSpendUnit - 1),
      optmSpendUnitTotal = sum(nlsMod$solution),
      optmSpendUnitTotalDelta = sum(nlsMod$solution) / histSpendUnitTotal - 1,
      optmSpendShareUnit = nlsMod$solution / sum(nlsMod$solution),
      optmResponseUnit = -eval_f(nlsMod$solution)[["objective.channel"]],
      optmResponseUnitTotal = sum(-eval_f(nlsMod$solution)[["objective.channel"]]),
      optmRoiUnit = -eval_f(nlsMod$solution)[["objective.channel"]] / nlsMod$solution,
      optmResponseUnitLift = (-eval_f(nlsMod$solution)[["objective.channel"]] / histResponseUnitModel) - 1
    ) %>%
      mutate(
        optmResponseUnitTotalLift = (.data$optmResponseUnitTotal / .data$initResponseUnitTotal) - 1
      )
    .Options$ROBYN_TEMP <- NULL # Clean auxiliary method
    
    
    outputs <- list()
    
    subtitle <- sprintf(
      paste0(
        "Total spend increase: %s%%",
        "\nTotal response increase: %s%% with optimised spend allocation"
      ),
      round(mean(dt_optimOut$optmSpendUnitTotalDelta) * 100, 1),
      round(mean(
        dt_optimOut$optmResponseUnitTotalLift
      ) * 100, 1)
    )
    
    
    plotDT_scurveMeanResponse <- filter(
      OutputCollect$xDecompAgg,
      .data$solID == select_model,
      .data$rn %in% InputCollect$paid_media_spends
    )
    
    
    rsq_train_plot <- round(plotDT_scurveMeanResponse$rsq_train[1], 4)
    nrmse_plot <- round(plotDT_scurveMeanResponse$nrmse[1], 4)
    decomp_rssd_plot <-
      round(plotDT_scurveMeanResponse$decomp.rssd[1], 4)
    mape_lift_plot <- ifelse(
      !is.null(InputCollect$calibration_input),
      round(plotDT_scurveMeanResponse$mape[1], 4),
      NA
    )
    errors <- paste0(
      "R2 train: ",
      rsq_train_plot,
      ", NRMSE = ",
      nrmse_plot,
      ", DECOMP.RSSD = ",
      decomp_rssd_plot,
      ifelse(
        !is.na(mape_lift_plot),
        paste0(", MAPE = ", mape_lift_plot),
        ""
      )
    )
    
    
    plotDT_resp <-
      select(dt_optimOut,
             .data$channels,
             .data$initResponseUnit,
             .data$optmResponseUnit) %>%
      mutate(channels = as.factor(.data$channels))
    names(plotDT_resp) <-
      c("channel", "Initial Mean Response", "Optimised Mean Response")
    plotDT_resp <-
      tidyr::gather(plotDT_resp, "variable", "response",-.data$channel)
    
    
    
    plotDT_share <-
      select(dt_optimOut,
             .data$channels,
             .data$initSpendShare,
             .data$optmSpendShareUnit) %>%
      mutate(channels = as.factor(.data$channels))
    names(plotDT_share) <-
      c("channel",
        "Initial Avg. Spend Share",
        "Optimised Avg. Spend Share")
    plotDT_share <-
      tidyr::gather(plotDT_share, "variable", "spend_share",-.data$channel)
    
    
    
    plotDT_saturation <- OutputCollect$mediaVecCollect %>%
      filter(.data$solID == select_model,
             .data$type == "saturatedSpendReversed") %>%
      select(.data$ds, all_of(InputCollect$paid_media_spends)) %>%
      tidyr::gather("channel", "spend",-.data$ds)
    
    
    
    plotDT_decomp <- OutputCollect$mediaVecCollect %>%
      filter(.data$solID == select_model, .data$type == "decompMedia") %>%
      select(.data$ds, all_of(InputCollect$paid_media_spends)) %>%
      tidyr::gather("channel", "response",-.data$ds)
    
    
    plotDT_scurve <-
      data.frame(plotDT_saturation, response = plotDT_decomp$response) %>%
      filter(.data$spend >= 0) %>%
      as_tibble()
    
    
    
    robyn_plot_object <-
      list(dfe, plotDT_scurve, plotDT_share, plotDT_resp, dt_optimOut)
    print(robyn_plot_object)
    
  }
