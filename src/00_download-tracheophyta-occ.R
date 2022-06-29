library(rgbif)
library(raster)
library(rgdal)
library(dplyr)
source("./src/R/gbif_download_wrapper.R")

# Delimitar área de interes
#extent <- readOGR("./data/interim/xativa_extent.gpkg", "xativa_extent")
#extent <- spocc::bbox2wkt(extent@bbox)

#taxon_list <- c("Animalia", "Chromista", "Fungi", "Plantae")

# Descargar ocurrencias y listado de ocurrencias del BDBCV a través del gbif
gbif_data <- gbif_download_wrapper(taxon = "Limonium dufourii",
                                   path = "./data/external/",
                                   format = "DWCA",
                                   pred("institutionCode", "BDBCV"))
                                   #pred_within(extent))

# Crear tabla con listado de especies y número de ocurrencias
gbif_splist <- group_by(gbif_data,phylum, class, order, family, genus,
                        species, scientificName, acceptedScientificName,
                        verbatimScientificName, taxonRank, taxonomicStatus)

gbif_splist <- count(gbif_data, phylum, class, order, family, genus,
                     species, scientificName, acceptedScientificName,
                     verbatimScientificName, taxonRank, taxonomicStatus)

write.csv(gbif_splist, "./data/interim/plantae_bdbcv_splist.csv")
