#' Title
#'
#' @param taxon
#' @param bbox
#' @param format
#' @param path
#'
#' @return
#' @export
#'
#' @examples

gbif_download_wrapper <- function(taxon, format = "DWCA", 
                               path = "./data/external/", ...) {
  require("rgbif")
  
  data_output <- vector(mode = "list")
  
  # Preparación de la lista de taxones y extracción del identificador del gbif
  # para su empleo en la query a la BBDD
  for (item in taxon) {
    taxon_char <- as.character(taxon)
    taxon_key <- name_backbone(item)
    
    # Se emplea la función `occ_download()` para generar una query a la base 
    # de datos 
    taxon_gbif_data <- occ_download(pred("taxonKey", taxon_key$usageKey),
                                    format = format, ...)
    
    # Se evalúa el estado de la query mediante `occ_download_meta()` y se
    # inicia la descarga cuando ésta ha terminado
    while (occ_download_meta(taxon_gbif_data)[[8]][1] != "SUCCEEDED"){
      message(occ_download_meta(taxon_gbif_data)[[8]][1]) # Mejorar mensaje
      Sys.sleep(30)
    }
    
    # Descarga de los datos de la query e importarlos en la sesión
    down_taxon_gbif_data <- occ_download_get(taxon_gbif_data, overwrite = TRUE,
                                             path = path)
    ## Crear archivo de texto con las citas
    ##browser()
    ##citation <- gbif_citation(down_taxon_gbif_data)
    ##cit_path <- sprintf("%s_gbif_occ_citation.txt", path)
    ##save(citation, file = cit_path)
    
    down_taxon_gbif_data <- occ_download_import(down_taxon_gbif_data)
    
    down_taxon_gbif_data <- down_taxon_gbif_data[order(down_taxon_gbif_data$phylum,
                                                       down_taxon_gbif_data$class,
                                                       down_taxon_gbif_data$order,
                                                       down_taxon_gbif_data$family,
                                                       down_taxon_gbif_data$genus,
                                                       down_taxon_gbif_data$species,
                                                       down_taxon_gbif_data$scientificName), ]
    
    # Obtener string del key de la descarga para cambiar el nombre del zip
    down_taxon_key <- as.character(occ_download_meta(taxon_gbif_data)[1])
    
    # Cambiar nombre del archivo comprimido en función del tipo de descarga
    if(format == "DWCA"){
      
      # En caso de descargar DWCA filtrar los siguientes campos
      col_list <- c("kingdom", "phylum", "class", "order", "family", "genus", 
                    "species", "infraspecificEpithet",  "scientificName", 
                    "acceptedScientificName","verbatimScientificName", "taxonomicStatus", "taxonRank",
                    "gbifID", "taxonKey", "acceptedTaxonKey", 
                    "basisOfRecord", "iucnRedListCategory", 
                    "institutionCode", "collectionCode", "datasetKey", "issue", 
                    "hasGeospatialIssues", "decimalLatitude", "decimalLongitude",
                    "coordinateUncertaintyInMeters", "coordinatePrecision",
                    "municipality","locality", "stateProvince", "day", "month", "year",
                    "recordedBy", "identifiedBy","mediaType", "license", 
                    "preparations", "occurrenceRemarks", "habitat", "typeStatus",
                    "identificationRemarks", "level2Name", "level3Name")
      
      # Buscar solución para Bug, revisa el subsetting
      if (length(taxon) == 1){
        data_output[[item]] <- down_taxon_gbif_data[col_list]
      } else {
        data_output[[item]] <- down_taxon_gbif_data[[item]][col_list]  
      }
      
      zip_name <- sprintf("%s%s_gbif_occ_DWCA.zip", path, item)  
      # Guardar resultados en un archivo CSV
      csv_path <- sprintf("%s%s_gbif_occ_DWCA.csv", path, item)  
      write.csv(down_taxon_gbif_data, csv_path)
        
    } else {
      # Crear lista con los resultados para devolverlo como output
      data_output[[item]] <- down_taxon_gbif_data
    }
  
    if (format == "SIMPLE_CSV"){
      zip_name <- sprintf("%s%s_gbif_occ_csv.zip", path, item)  
      csv_path <- sprintf("%s%s_gbif_occ_csv.csv", path, item)  
      write.csv(down_taxon_gbif_data, csv_path)
    }
    
    if (format == "SPECIES_LIST"){
      zip_name <- sprintf("%s%s_gbif_occ_splist.zip", path, item)
      csv_path <- sprintf("%s%s_gbif_occ_splist.csv", path, item)  
      write.csv(down_taxon_gbif_data, csv_path)
    }
    
    # Solucion renombrar archivo en caso especies, si aldividir el char mediante
    # espacios devuelve una lista con mas de 1 elemento, reemplaza el espacio por _
    if (length(strsplit(zip_name, " ")[[1]] > 1)) {
      zip_name <- gsub(" ", replacement = "_", x = zip_name)
      
    }
    
    file.rename(sprintf("%s%s.zip", path, down_taxon_key), zip_name)
  }
  
  return(data_output)
}