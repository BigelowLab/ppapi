# List of 20
#  $ id                     : int 40366
#  $ name                   : chr "Kaniabizo"
#  $ original_name          : chr "Kaniabizo"
#  $ wdpa_id                : int 40366
#  $ geojson                :List of 3
#   ..$ type      : chr "Feature"
#   ..$ properties:List of 5
#   .. ..$ fill-opacity: num 0.7
#   .. ..$ stroke-width: num 0.05
#   .. ..$ stroke      : chr "#40541b"
#   .. ..$ fill        : chr "#83ad35"
#   .. ..$ marker-color: chr "#2B3146"
#   ..$ geometry  :List of 2
#   .. ..$ type       : chr "Polygon"
#   .. ..$ coordinates:List of 1
#   .. .. ..$ :List of 5
#   .. .. .. ..$ :List of 2
#   .. .. .. .. ..$ : num 29.8
#   .. .. .. .. ..$ : num -0.692
#   .. .. .. ..$ :List of 2
#   .. .. .. .. ..$ : num 29.8
#   .. .. .. .. ..$ : num -0.687
#   .. .. .. ..$ :List of 2
#   .. .. .. .. ..$ : num 29.8
#   .. .. .. .. ..$ : num -0.683
#   .. .. .. ..$ :List of 2
#   .. .. .. .. ..$ : num 29.8
#   .. .. .. .. ..$ : num -0.688
#   .. .. .. ..$ :List of 2
#   .. .. .. .. ..$ : num 29.8
#   .. .. .. .. ..$ : num -0.692
#  $ marine                 : logi FALSE
#  $ reported_marine_area   : chr "0.0"
#  $ reported_area          : chr "0.3933"
#  $ management_plan        : chr "Not Reported"
#  $ owner_type             : chr "Not Reported"
#  $ countries              :List of 1
#   ..$ :List of 3
#   .. ..$ name : chr "Uganda"
#   .. ..$ iso_3: chr "UGA"
#   .. ..$ id   : chr "UGA"
#  $ iucn_category          :List of 2
#   ..$ id  : int 8
#   ..$ name: chr "Not Reported"
#  $ designation            :List of 3
#   ..$ id          : int 13
#   ..$ name        : chr "Forest Reserve"
#   ..$ jurisdiction:List of 2
#   .. ..$ id  : int 1
#   .. ..$ name: chr "National"
#  $ no_take_status         :List of 3
#   ..$ id  : int 11282
#   ..$ name: chr "Not Applicable"
#   ..$ area: chr "0.0"
#  $ legal_status           :List of 2
#   ..$ id  : int 1
#   ..$ name: chr "Designated"
#  $ management_authority   :List of 2
#   ..$ id  : int 6
#   ..$ name: chr "Not Reported"
#  $ governance             :List of 2
#   ..$ id             : int 1
#   ..$ governance_type: chr "Governance by Government"
#  $ pame_evaluations       : list()
#  $ links                  :List of 1
#   ..$ protected_planet: chr "http://protectedplanet.net/40366"
#  $ legal_status_updated_at: chr "01/01/1998"

#' Extract sf geometry
#' 
#' @export
#' @param x list of the geojson section of a response
#' @return NULL or geometry
extract_geometry <- function(x){
  if ("geometry" %in% names(x)){
    r <- switch(tolower(x$geometry$type),
      "polygon" = {
        mat <- sapply(x$geometry$coordinates, unlist) |>
          matrix(ncol = 2, byrow = TRUE)
        sf::st_polygon(list(mat))
      },
      {
        warning("type not known:", x$geometry$type)
        NULL
      })
  } else {
    r <- NULL
  }
}

#' Convert a list of wdpa response items to tibble
#' 
#' @export
#' @param x list of wdpa items for one wdpa record
#' @param keep character, vector of columns to keep
#' @return tibble (one row)
wdpa_as_tibble <- function(x,
  keep = c("id", 
           "name", 
           "original_name", 
           "wdpa_id", 
           "marine", 
           "reported_marine_area", 
           "reported_area",
           "management_plan", 
           "owner_type", 
           "countries", 
           "iucn_category", 
           "designation", 
           "no_take_status", 
           "legal_status", 
           "management_authority", 
           "governance", 
           "legal_status_updated_at",
           "geometry")){
  nms <- names(x)
  if ("geojson" %in% nms){
    if ("geometry" %in% names(x$geojson)){
      x$geometry <- list(extract_geometry(x$geojson))
      x$geojson <- NULL
    }
  }
  if ("countries" %in% nms){
    countries <- sapply(x$countries, "[[", "iso_3")
    x$countries <- paste(countries, collapse = " ")
  }
  if ("iucn_category" %in% nms){
    x$iucn_category <- x$iucn_category$name
  }
  if ("designation" %in% nms){
    x$designation <- x$designation$name
  }
  if ("no_take_status" %in% nms){
    x$no_take_status <- x$no_take_status$name
  }
  if ("legal_status" %in% nms){
    x$legal_status <- x$legal_status$name
  }
  if ("management_authority" %in% nms){
    x$management_authority <- x$management_authority$name
  }
  if ("governance" %in% nms){
    x$governance <- x$governance$governance_type
  }
  dplyr::as_tibble(x[keep])
}

