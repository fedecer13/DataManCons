library(sf)             # dati vettoriali
library(terra)          # dati raster
library(geodata)        # download dati geografici semplici
library(tidyverse)
library(rnaturalearth)


# I dati spaziali si dividono molto spesso in due grandi famiglie:
#
# 1. dati vettoriali
#    - punti
#    - linee
#    - poligoni
#
# 2. dati raster
#    - una griglia di celle
#    - ogni cella ha un valore
#
# Esempi:
# vettoriale -> località, fiumi, confini, aree protette
# raster     -> elevazione, temperatura, precipitazione, NDVI


############################################################
# 1) PRIMO ESEMPIO: DATI VETTORIALI
############################################################

# Creiamo 3 punti con coordinate longitude / latitude
# Immaginiamoli come siti di campionamento

sites_df <- data.frame(
  site = c("A", "B", "C"),
  lon = c(13.40, 13.55, 13.30),
  lat = c(42.35, 42.45, 42.25)
)

sites_df

# Convertiamo il data frame in oggetto spaziale sf

sites_sf <- st_as_sf(sites_df, 
                     coords = c("lon", "lat"), 
                     crs = 4326)

sites_sf

# Cosa vuol dire crs = 4326?
# È il sistema di riferimento geografico più comune
# longitude / latitude in gradi (WGS84)

# Plottiamo i punti
geom_sites <- st_geometry(sites_sf)
plot(geom_sites, pch = 16, col = "red")

sites_sf |>
  st_coordinates()

# Qui abbiamo un esempio di vettoriale:
# ogni osservazione è un punto nello spazio


############################################################
# 2) POLIGONI: UN ALTRO TIPO DI VETTORIALE
############################################################

# Scarichiamo un confine amministrativo semplice: Italia
italy <- ne_countries(country = "Italy", returnclass = "sf")

italy

# Plot del poligono
plot(st_geometry(italy), col = "lightyellow", border = "grey40")
plot(st_geometry(sites_sf), add = TRUE, pch = 16, col = "red")

# Qui vediamo due layer vettoriali:
# - il poligono dell'Italia
# - i nostri punti


############################################################
# 3) RASTER: COS'È?
############################################################

# Un raster è una griglia.
# Ogni cella della griglia contiene un valore.
# Ad esempio: elevazione, temperatura, pioggia...

# Scarichiamo un DEM molto semplice per l'Italia
if(!dir.exists("SpatData/raster")){
  dir.create("SpatData/raster", recursive = TRUE)
} 

if(!file.exists("SpatData/raster/ITA_elv_msk.tif")){
dem <- geodata::elevation_30s(country = "ITA", path = "SpatData/raster")
} else {
  dem <- terra::rast("SpatData/raster/ITA_elv_msk.tif")
}

dem

# Plot del raster
plot(dem)

# Qui ogni pixel/cella ha un valore di elevazione


############################################################
# 4) RASTER + VETTORIALE INSIEME
############################################################

# Sovrapponiamo il confine e i punti al DEM
plot(dem)
plot(vect(italy), add = TRUE, border = "black", lwd = 1)
plot(vect(sites_sf), add = TRUE, col = "red", pch = 16)

# Questa è una delle idee fondamentali delle analisi spaziali:
# combinare layer diversi nello stesso spazio


############################################################
# 5) TAGLIA UNA PICCOLA AREA
############################################################

# Creiamo un piccolo "extent" attorno ai nostri punti
e <- ext(13.1, 13.7, 42.1, 42.6)

dem_crop <- crop(dem, e)

plot(dem_crop)
plot(vect(sites_sf), add = TRUE, col = "blue", pch = 16)

# crop() serve a ritagliare un raster su una zona di interesse


############################################################
# 6) ESEMPIO ECOLOGICO SEMPLICE:
# ESTRARE IL VALORE DI ELEVAZIONE NEI PUNTI
############################################################

# Una domanda molto naturale è:
# qual è l'elevazione nei nostri siti?

elev_sites <- terra::extract(dem, vect(sites_sf))

elev_sites

# Uniamo i risultati ai siti
sites_with_elev <- cbind(sites_sf, elev_sites)

sites_with_elev

# Ora ogni sito ha anche un valore di elevazione associato


############################################################
# 7) VISUALIZZAZIONE PIÙ LEGGIBILE CON ggplot2
############################################################

# Per usare ggplot2 con un raster, convertiamolo in data frame
dem_df <- as.data.frame(dem_crop, xy = TRUE, na.rm = TRUE)

head(dem_df)

# Il nome della colonna raster dipende dal file scaricato
names(dem_df)

# Facciamo una mappa semplice
ggplot() +
  geom_raster(data = dem_df,
              aes(x = x, y = y, fill = ITA_elv_msk)) +
  geom_sf(data = sites_sf, color = "red", size = 2) +
  labs(
    title = "Sampling sites on a DEM",
    x = "Longitude",
    y = "Latitude",
    fill = "Elevation"
  ) +
  theme_minimal()

# Se il nome della colonna non fosse ITA_elv,
# sostituirlo con il nome reale trovato in names(dem_df)


############################################################
# 8) CONCETTO CHIAVE: VETTORIALE VS RASTER
############################################################

# VETTORIALE:
# - oggetti discreti
# - punti, linee, poligoni
# - esempio: siti, fiumi, confini
#
# RASTER:
# - spazio continuo diviso in celle
# - ogni cella ha un valore
# - esempio: elevazione, temperatura


############################################################
# 9) PICCOLO ESEMPIO "SPECIE"
############################################################

# Immaginiamo che i nostri tre punti siano tre osservazioni
# di una specie

species_sites <- data.frame(
  species = c("Plantago", "Plantago", "Plantago"),
  lon = c(13.40, 13.55, 13.30),
  lat = c(42.35, 42.45, 42.25)
)

species_sf <- st_as_sf(species_sites, coords = c("lon", "lat"), crs = 4326)

plot(dem_crop)
plot(vect(species_sf), add = TRUE, col = "darkgreen", pch = 16)

# Ora la domanda ecologica potrebbe essere:
# "a quale elevazione si trovano le osservazioni della specie?"

terra::extract(dem, vect(species_sf))


############################################################
# 10) PROMEMORIA FINALE
############################################################

# sf    -> dati vettoriali
# terra -> dati raster
#
# st_as_sf() -> converte un data frame in punti spaziali
# plot()     -> visualizza layer
# crop()     -> ritaglia un raster
# extract()  -> estrae valori raster in punti
#
# Idea centrale:
# i punti dicono DOVE abbiamo osservazioni
# il raster descrive COM'È l'ambiente in quello spazio

