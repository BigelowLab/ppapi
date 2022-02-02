#' Retrieve the local path to the Protected Planet resources
#'
#' @export
#' @param ... character, file/directory segments
#' @param root character, the root directory
pp_path <- function(..., root = rappdirs::user_data_dir("ppapi")){
  file.path(root, ...)
}

#' Retrieve the Protected Planet token
#' 
#' @export
#' @param path character, the user configuration directory
#' @return the token as character
pp_token <- function(path = rappdirs::user_config_dir("ppapi")){
  readLines(file.path(path[1], "ppapi.token"))
}

#' Write a token to the user configuration path
#' 
#' @export
#' @param x character, the token
#' @param path character, the user configuration directory
#' @param overwrite logical, if TRUE allow existing tokens to be overwritten
#' @return the token
write_pp_token <- function(x, 
                           path = rappdirs::user_config_dir("ppapi"),
                           overwrite = FALSE){
  filename <- file.path(path[1], "ppapi.token")
  if (file.exists(filename) && !overwrite){
    warning("token file already exists, set overwrite to FALSE to overwrite")
  } else {
    cat(x, sep = "\n", file = filename)
  }
  x
}

#' Append the token to a query
#' 
#' @export
#' @param x character, the query string
#' @param token character, the token
#' @return input x with token appended
append_token <- function(x,
                         token = pp_token()){
  sprintf("%s&token=%s", x, token)
}

#' Append the query elements
#' 
#' @export
#' @param x character, the query string
#' @param elems character, the elements as a named list
#' @return input x with token appended
append_query <- function(x,
                         elems){
  
  if (length(elems) == 0) return(x)
  nm <- names(elems)
  qry <- paste(nm, elems, sep = "=") |>
    paste(collapse = "&")
  paste0(x, qry)
}


#' Build a query
#' 
#' An example for a single protected area might look like 
#' \code{http://api.protectedplanet.net/v3/protected_areas/40366?with_geometry=true&token=0123456789}
#' where '0123456789' is replaced with a valid token.
#' 
#' @export
#' @param x character identifier (either iso3 for a country or wdpa_id for a protected area)
#' @param with_gemoetry logical to include boundary coordinates
#' @param base_url character, the base url
#' @param version character, the API version to query
#sqrt(' @param token character, the token
#' @return character url query
pp_url <- function(x = "40366",
                   with_geometry = TRUE,
                   base_url = "http://api.protectedplanet.net",
                   version = "v3",
                   space = c("countries", "protected_areas")[2],
                   token = pp_token()){
  
  query = list(with_geometry = tolower(as.character(with_geometry[1])))
  
  file.path(base_url[1], version[1], space[1], x[1]) |>
    paste0("?") |>
    append_query(query) |>
    append_token(token = token)
}

#' GET WPDA identified by ID
#' 
#' @export
#' @param x character, a wdpaid (numeric or charcater code)
#' @param form character, describes output format. One of 'list', 'tibble' or 'sf'
#' @return list, tibble, sf or NULL
pp_get_wdpaid <- function(x = "40366",
                   form = c("list", "tibble", "sf")[2]){
  
  uri <- pp_url(x)
  
  resp <- httr::GET(uri)
  
  if (httr::http_error(resp)){
    stop(sprintf("GET failed with status code: %i", resp$status_code))
  }
  
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json")
  }
  
  r <- httr::content(resp)[[1]]
  
  form <- tolower(form[1])
  
  if (form %in% c("tibble", "sf")){
    r <- wdpa_as_tibble(r)
    if (form == "sf"){
      r <- sf::st_as_sf(r, crs = 4326)
    }
  }
  r              
}
