
#' Susceptible-Exposed-Infectious-Removed (SEIR) model framework
#'
#' This function is originally used by specific disease models in EPIRICE to
#'  model disease severity of several rice diseases.  Given proper values it can
#'  be used with other pathosystems as well.
#'
#' @param wth a data frame of weather on a daily time-step containing data with
#'  the following field names.
#'   \tabular{rl}{
#'   **YYYYMMDD**:\tab Date as Year Month Day (ISO8601).\cr
#'   **DOY**:\tab  Consecutive day of year, commonly called "Julian date".\cr
#'   **TEMP**:\tab Mean daily temperature (°C).\cr
#'   **TMIN**:\tab Minimum daily temperature (°C).\cr
#'   **TMAX**:\tab Maximum daily temperature (°C).\cr
#'   **TDEW**:\tab Mean daily dew point temperature (°C).\cr
#'   **RHUM**:\tab Mean daily temperature (°C).\cr
#'   **RAIN**:\tab Mean daily rainfall (mm).\cr
#'   }
#' @param emergence expected date of plant emergence entered in `YYYY-MM-DD`
#' format. From Table 1 Savary \emph{et al.} 2012.
#' @param onset expected number of days until the onset of disease after
#' emergence date. From Table 1 Savary \emph{et al.} 2012.
#' @param duration simulation duration (growing season length). From Table 1
#'  Savary \emph{et al.} 2012.
#' @param rhlim threshold to decide whether leaves are wet or not (usually
#' 90 %). From Table 1 Savary \emph{et al.} 2012.
#' @param rainlim threshold to decide whether leaves are wet or not. From Table
#'  1 Savary \emph{et al.} 2012.
#' @param wetness_type simulate RHmax or rain threshold (0) or leaf wetness
#'  duration (1). From Table 1 Savary \emph{et al.} 2012.
#' @param H0 initial number of plant's healthy sites. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param I0 initial number of infective sites. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param RcA crop age curve for pathogen optimum. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param RcT temperature curve for pathogen optimum. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param RcW relative curve for pathogen optimum. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param RcOpt potential basic infection rate corrected for removals. From
#'  Table 1 Savary \emph{et al.} 2012.
#' @param i duration of infectious period. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param p duration of latent period. From Table 1 Savary \emph{et al.} 2012.
#' @param Sx maximum number of sites. From Table 1 Savary \emph{et al.} 2012.
#' @param a aggregation coefficient. From Table 1 Savary \emph{et al.} 2012.
#' @param RRS relative rate of physiological senescence. From Table 1 Savary
#'  \emph{et al.} 2012.
#' @param RRG relative rate of growth. From Table 1 Savary \emph{et al.} 2012.
#'
#' @references Savary, S., Nelson, A., Willocquet, L., Pangga, I., and Aunario,
#' J. Modeling and mapping potential epidemics of rice diseases globally. Crop
#' Protection, Volume 34, 2012, Pages 6-17, ISSN 0261-2194 DOI:
#' <http://dx.doi.org/10.1016/j.cropro.2011.11.009>.
#'
#' @examples
#' \donttest{
#' # get weather for IRRI Zeigler Experiment Station in wet season 2000
#' wth <- get_wth(
#'   lonlat = c(121.25562, 14.6774),
#'   dates = c("2000-06-30", "2000-12-31")
#' )
#'
#' # provide suitable values for brown spot severity
#' RcA <-
#'   cbind(0:6 * 20, c(0.35, 0.35, 0.35, 0.47, 0.59, 0.71, 1.0))
#' RcT <-
#'   cbind(15 + (0:5) * 5, c(0, 0.06, 1.0, 0.85, 0.16, 0))
#' RcW <- cbind(0:8 * 3,
#'              c(0, 0.12, 0.20, 0.38, 0.46, 0.60, 0.73, 0.87, 1.0))
#' emergence <- "2000-07-15"
#'
#' (SEIR(
#'   wth = wth,
#'   emergence = emergence,
#'   onset = 20,
#'   duration = 120,
#'   RcA = RcA,
#'   RcT = RcT,
#'   RcW = RcW,
#'   RcOpt = 0.61,
#'   p =  6,
#'   i = 19,
#'   H0 = 600,
#'   a = 1,
#'   Sx = 100000,
#'   RRS = 0.01,
#'   RRG = 0.1
#' ))
#' }
#' @details \code{SEIR} is called by the following specific disease modelling
#'  functions:
#' * \code{\link{predict_bacterial_blight}},
#' * \code{\link{predict_brown_spot}},
#' * \code{\link{predict_leaf_blast}},
#' * \code{\link{predict_sheath_blight}},
#' * \code{\link{predict_tungro}}
#'
#' @author Serge Savary, Ireneo Pangga, Robert Hijmans, Jorrel Khalil Aunario,
#' Adam H. Sparks, Aji Sukarta
#'
#' @return A \code{\link[data.table]{data.table}} containing the following
#'  columns
#'   \tabular{rl}{
#'   **simday**:\tab Zero indexed day of simulation that was run.\cr
#'   **dates**:\tab  Date of simulation.\cr
#'   **sites**:\tab Total number of sites present on day "x".\cr
#'   **latent**:\tab Number of latent sites present on day "x".\cr
#'   **infectious**:\tab Number of infectious sites present on day "x".\cr
#'   **removed**:\tab Number of removed sites present on day "x".\cr
#'   **senesced**:\tab Number of senesced sites present on day "x".\cr
#'   **rateinf**:\tab Rate of infection. \cr
#'   **rtransfer**:\tab Rate of transfer from latent to infectious sites. \cr
#'   **rgrowth**:\tab Rate of growth of healthy sites. \cr
#'   **rsenesced**:\tab Rate of senescence of healthy sites. \cr
#'   **diseased**:\tab Number of diseased (latent + infectious + removed)
#'    sites. \cr
#'   **severity**:\tab Disease severity or incidence (for tungro).\cr
#'   **lat**:\tab Latitude value as provided by `wth` object.\cr
#'   **lon**:\tab Longitude value as provided by `wth` object.\cr
#'   }
#'
#' @export
#'
SEIR <-
  function(wth,
           emergence,
           onset,
           duration,
           rhlim = 90,
           rainlim = 5,
           wetness_type = 0,
           H0,
           I0 = 1,
           RcA,
           RcT,
           RcW,
           RcOpt,
           p,
           i,
           Sx,
           a,
           RRS,
           RRG) {
    # CRAN NOTE avoidance
    infday <- DOY <- YYYYMMDD <- lat <- # nocov start
    lon <- LAT <- LON <- NULL #nocov end

    # set date formats
    emergence <- as.Date(emergence)

    # create vector of dates
    dates <- seq(emergence - 1, emergence + duration, 1)

    # convert emergence date into Julian date, sequential day in year
    emergence_doy <- as.numeric(strftime(emergence, format = "%j"))

    # check that the dates roughly align
    if (!(emergence >= wth[1, YYYYMMDD]) |
        (max(dates) > max(wth[, YYYYMMDD]))) {
      stop("Incomplete weather data or dates do not align")
    }

    # subset weather data where date is greater than emergence minus one and
    # less than duration
    wth <- wth[DOY >= emergence_doy - 1, ]
    wth <- wth[DOY <= emergence_doy + duration, ]

    if (wetness_type == 1) {
      W <- .leaf_wet(wth, simple = TRUE)
    }

    # outputvars
    cofr <-
      rc <-
      RHCoef <- latency <- infectious <- severity <- rsenesced <-
      rgrowth <-
      rtransfer <- infection <- diseased <- senesced <- removed <-
      now_infectious <- now_latent <- sites <- total_sites <-
      rep(0, times = duration + 1)

    for (day in 0:duration) {
      # State calculations
      cs_1 <- day + 1
      if (day == 0) {
        # start crop growth
        sites[cs_1] <- H0
        rsenesced[cs_1] <- RRS * sites[cs_1]
      } else {
        if (day > i) {
          removed_today <- infectious[infday + 2]
        } else {
          removed_today <- 0
        }

        sites[cs_1] <-
          sites[day] + rgrowth[day] - infection[day] -
          rsenesced[day]
        rsenesced[cs_1] <- removed_today + RRS * sites[cs_1]
        senesced[cs_1] <- senesced[day] + rsenesced[day]

        latency[cs_1] <- infection[day]
        latday <- day - p + 1
        latday <- max(0, latday)
        now_latent[day + 1] <- sum(latency[latday:day + 1])

        infectious[day + 1] <- rtransfer[day]
        infday <- day - i + 1
        infday <- max(0, infday)
        now_infectious[day + 1] <- sum(infectious[infday:day + 1])
      }

      cs_2 <- day + 1
      if (sites[cs_2] < 0) {
        sites[cs_2] <- 0
        break
      }

      if (wetness_type == 0) {
        if (wth$RHUM[cs_2] == rhlim |
            wth$RAIN[cs_2] >= rainlim) {
          RHCoef[cs_2] <- 1
        }
      } else {
        RHCoef[cs_2] <- afgen(RcW, W[day + 1])
      }

      cs_6 <- day + 1
      cs_3 <- cs_6
      rc[cs_6] <- RcOpt * afgen(RcA, day) *
        afgen(RcT, wth$TEMP[day + 1]) * RHCoef[cs_3]
      cs_4 <- day + 1
      diseased[cs_3] <- sum(infectious) +
        now_latent[cs_4] + removed[cs_4]
      cs_5 <- day + 1
      removed[cs_4] <- sum(infectious) - now_infectious[cs_5]

      cofr[cs_5] <- 1 - (diseased[cs_5] /
                              (sites[cs_5] + diseased[cs_5]))

      if (day == onset) {
        # initialisation of the disease
        infection[cs_5] <- I0
      } else if (day > onset) {
        infection[cs_5] <- now_infectious[cs_5] *
          rc[cs_5] * (cofr[cs_5] ^ a)
      } else {
        infection[cs_5] <- 0
      }

      if (day >=  p) {
        rtransfer[cs_5] <- latency[latday + 1]
      } else {
        rtransfer[cs_5] <- 0
      }

      total_sites[cs_5] <- diseased[cs_5] + sites[cs_5]
      rgrowth[cs_5] <- RRG * sites[cs_5] *
        (1 - (total_sites[cs_5] / Sx))
      severity[cs_5] <- (diseased[cs_5] - removed[cs_5]) /
        (total_sites[cs_5] - removed[cs_5]) * 100
    } # end loop

    res <-
      data.table(
        cbind(
          0:duration,
          sites,
          now_latent,
          now_infectious,
          removed,
          senesced,
          infection,
          rtransfer,
          rgrowth,
          rsenesced,
          diseased,
          severity
        )
      )

    res[, dates := dates[1:(day + 1)]]

    setnames(
      res,
      c(
        "simday",
        "sites",
        "latent",
        "infectious",
        "removed",
        "senesced",
        "rateinf",
        "rtransfer",
        "rgrowth",
        "rsenesced",
        "diseased",
        "severity",
        "dates"
      )
    )

    setcolorder(res, c("simday", "dates"))

    res[, lat := rep_len(wth[, LAT], .N)]
    res[, lon := rep_len(wth[, LON], .N)]

    return(res[])
  }
