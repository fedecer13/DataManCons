library(dplyr)
library(sf)
library(terra)
library(ggplot2)
library(ggspatial)
library(leaflet)
library(tmap)

############################################################
# 1) CARICARE IL CSV
############################################################

# File di partenza
file_csv <- "SpatData/esercitazione/MDM2.csv"

# Leggiamo il file
# Se x e y hanno la virgola decimale, la correggiamo
df <- read.csv(file_csv) |>
  select(siteID = 1, x = 2, y = 3, SR = 4) |>
  mutate(
    x = gsub(",", ".", x),
    y = gsub(",", ".", y)
  ) |>
  mutate(
    x = as.numeric(x),
    y = as.numeric(y),
    SR = as.numeric(SR)
  )

# Controllo rapido
head(df)
str(df)
summary(df)

############################################################
# 2) DA DATA FRAME A PUNTI SPAZIALI
############################################################

# Convertiamo il data frame in oggetto sf
# CRS 4326 = longitude / latitude
pts <- st_as_sf(df, coords = c("x", "y"), crs = 4326)

pts
plot(st_geometry(pts), pch = 16, col = "red")

############################################################
# 3) CALCOLARE L'EXTENT
############################################################

# L'extent è il rettangolo minimo che contiene tutti i punti
pts_vect <- vect(pts)
pts_ext <- ext(pts_vect)

pts_ext

# Possiamo trasformarlo in poligono per visualizzarlo
ext_poly <- as.polygons(pts_ext)
crs(ext_poly) <- crs(pts_vect)

plot(ext_poly, border = "blue", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

############################################################
# 4) CALCOLARE IL MINIMO POLIGONO CONVESSO
############################################################

# Minimum convex polygon / convex hull
pts_hull <- st_convex_hull(st_union(pts))

plot(st_geometry(pts_hull), border = "darkgreen", lwd = 2)
plot(st_geometry(pts), add = TRUE, col = "red", pch = 16)

# Confronto grafico extent vs convex hull
plot(ext_poly, border = "blue", lwd = 2)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

# Idea chiave:
# - extent = rettangolo
# - convex hull = poligono minimo convesso intorno ai punti

############################################################
# 5) CARICARE IL DEM
############################################################

dem <- rast("SpatData/raster/elevation/ITA_elv_msk.tif")

dem
plot(dem)

############################################################
# 6) CROP E MASK CON EXTENT
############################################################

# crop con extent = ritaglio rettangolare
dem_crop_ext <- crop(dem, pts_ext)

plot(dem_crop_ext)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

# mask con extent in pratica non cambia molto,
# perché l'extent è già un rettangolo pieno
dem_mask_ext <- mask(dem_crop_ext, ext_poly)

plot(dem_mask_ext)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

############################################################
# 7) CROP E MASK CON MINIMO POLIGONO CONVESSO
############################################################

# Prima facciamo crop usando il bounding box del convex hull
dem_crop_hull <- crop(dem, vect(pts_hull))

# Poi mask usando il convex hull vero e proprio
dem_mask_hull <- mask(dem_crop_hull, vect(pts_hull))

# Visualizziamo
plot(dem_crop_hull)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

plot(dem_mask_hull)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

############################################################
# 8) DIFFERENZE TRA EXTENT E CONVEX HULL
############################################################

# Extent:
# - semplice
# - veloce
# - sempre rettangolare
#
# Convex hull:
# - segue meglio la distribuzione dei punti
# - elimina aree esterne inutili
# - è spesso più realistico come area di studio

# Possiamo anche confrontare il numero di celle
ncell(dem_crop_ext)
ncell(dem_mask_hull)

############################################################
# 9) CALCOLARE VARIABILI TOPOGRAFICHE
############################################################

# Calcoliamo slope e aspect dal DEM ritagliato sul convex hull
# (di solito è la scelta più interessante)

slope <- terrain(dem_mask_hull, v = "slope", unit = "degrees")
aspect <- terrain(dem_mask_hull, v = "aspect", unit = "degrees")

plot(slope, main = "Slope")
plot(vect(pts_hull), add = TRUE, border = "black", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

plot(aspect, main = "Aspect")
plot(vect(pts_hull), add = TRUE, border = "black", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

############################################################
# 10) ESTRARRE QUOTA, SLOPE E ASPECT NEI PUNTI
############################################################

elev_pts <- extract(dem_mask_hull, pts_vect)
slope_pts <- extract(slope, pts_vect)
aspect_pts <- extract(aspect, pts_vect)

# Aggiungiamo tutto ai punti
pts$elev <- elev_pts[, 2]
pts$slope <- slope_pts[, 2]
pts$aspect <- aspect_pts[, 2]

head(pts)

############################################################
# 11) MAPPA STATICA CON GGPLOT2
############################################################

# Convertiamo raster in data frame per ggplot
dem_df <- as.data.frame(dem_mask_hull, xy = TRUE, na.rm = TRUE)
slope_df <- as.data.frame(slope, xy = TRUE, na.rm = TRUE)
aspect_df <- as.data.frame(aspect, xy = TRUE, na.rm = TRUE)

# Controlliamo i nomi delle colonne
names(dem_df)
names(slope_df)
names(aspect_df)

# ATTENZIONE:
# Sostituisci il nome della colonna raster se diverso.
# Qui uso il secondo nome trovato nel data frame.

dem_value_col <- names(dem_df)[3]
slope_value_col <- names(slope_df)[3]
aspect_value_col <- names(aspect_df)[3]

############################################################
# 11a) MAPPA DEM
############################################################

ggplot() +
  geom_raster(
    data = dem_df,
    aes(x = x, y = y, fill = .data[[dem_value_col]])
  ) +
  geom_sf(data = pts, aes(size = SR), color = "red") +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) +
  labs(
    title = "Sampling points on DEM",
    x = "Longitude",
    y = "Latitude",
    fill = "Elevation",
    size = "SR"
  ) +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true") +
  theme_minimal()

############################################################
# 11b) MAPPA SLOPE
############################################################

ggplot() +
  geom_raster(
    data = slope_df,
    aes(x = x, y = y, fill = .data[[slope_value_col]])
  ) +
  geom_sf(data = pts, color = "blue", size = 2) +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) +
  labs(
    title = "Slope",
    x = "Longitude",
    y = "Latitude",
    fill = "Slope (°)"
  ) +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true") +
  theme_minimal()

############################################################
# 11c) MAPPA ASPECT
############################################################

ggplot() +
  geom_raster(
    data = aspect_df,
    aes(x = x, y = y, fill = .data[[aspect_value_col]])
  ) +
  geom_sf(data = pts, color = "yellow", size = 2) +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) +
  labs(
    title = "Aspect",
    x = "Longitude",
    y = "Latitude",
    fill = "Aspect (°)"
  ) +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true") +
  theme_minimal()

############################################################
# 12) RELAZIONE QUOTA ~ SR
############################################################

ggplot(pts, aes(x = elev, y = SR)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Species richness vs elevation",
    x = "Elevation",
    y = "Species richness"
  ) +
  theme_minimal()

############################################################
# 13) MAPPA INTERATTIVA CON LEAFLET
############################################################

# Leaflet lavora bene con raster proiettati in WGS84 / lon-lat
# Se il DEM è molto pesante, conviene lavorare sul DEM già ritagliato

pal_dem <- colorNumeric("terrain", values(dem_mask_hull), na.color = NA)

leaflet() |>
  addTiles() |>
  addRasterImage(
    dem_mask_hull,
    colors = pal_dem,
    opacity = 0.7
  ) |>
  addPolygons(
    data = st_as_sf(pts_hull),
    fill = FALSE,
    color = "black",
    weight = 2
  ) |>
  addCircleMarkers(
    data = pts,
    radius = 5,
    color = "red",
    stroke = TRUE,
    fillOpacity = 0.9,
    popup = ~paste0(
      "<b>siteID:</b> ", siteID,
      "<br><b>SR:</b> ", SR,
      "<br><b>Elevation:</b> ", round(elev, 1),
      "<br><b>Slope:</b> ", round(slope, 1),
      "<br><b>Aspect:</b> ", round(aspect, 1)
    )
  ) |>
  addLegend(
    pal = pal_dem,
    values = values(dem_mask_hull),
    title = "Elevation"
  )

############################################################
# 14) RIASSUNTO CONCETTUALE
############################################################

# extent:
# rettangolo minimo che contiene tutti i punti

# convex hull:
# minimo poligono convesso che contiene tutti i punti

# crop:
# ritaglia un raster

# mask:
# tiene solo la parte del raster dentro un poligono

# terrain():
# calcola variabili topografiche da un DEM
# es. slope, aspect

# extract():
# estrae valori raster nei punti

# leaflet:
# permette visualizzazione interattiva