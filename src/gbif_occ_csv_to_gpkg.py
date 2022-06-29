#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed May 26 19:20:46 2021

@author: javier

Convierte las ocurrencias del gbif incluidas en un archivo csv en una base de
datos SQlite
"""

import os
import geopandas as gpd
import pandas as pd

# Seth path to file
file_path = "./data/external/"
file_name = "Plantae_gbif_occ_csv.csv"

# Read data in pandas.DataFrame
tracheo_df = pd.read_csv(os.path.join(file_path, file_name), 
                         usecols = list(range(1, 45)))

# Create GeoDataFrame from DataFrame
tracheo_df = gpd.GeoDataFrame(tracheo_df, 
                              geometry = gpd.points_from_xy(tracheo_df.decimalLongitude,
                                                            tracheo_df.decimalLatitude))
# Set CRS and reproject to north europe H30
tracheo_df.set_crs("EPSG:4256")#.to_crs("EPSG:3042")

# Write to SQLITE
tracheo_df.to_file("./data/interim/plantae_anthos_occ.gpkg", 
                   driver = "GPKG",
                   layer = "plantae_anthos_occ")

