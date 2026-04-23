library(tidyverse)
library(sf)
library(terra)
library(ggspatial)
library(leaflet)
library(tmap)
library(tidyterra)
library(patchwork)
library(ggnewscale)

############################################################
# 1) CARICARE IL CSV
############################################################

# File di partenza
file_csv <- "SpatData/esercitazione/sitiDN03.csv"

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

terra::vect(pts)
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
ext_poly
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
# MANTIENE TUTTE LE CELLE DENTRO L'EXTENT, ANCHE QUELLE VUOTE
dem_mask_ext <- mask(dem, ext_poly)

plot(dem_mask_ext)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

# mask sul crop è un po' ridondante, ma vediamo comunque
# è ridondante perché il crop ha già ritagliato al rettangolo, quindi il mask non toglie nulla
dem_cropmask_ext <- mask(dem_crop_ext, ext_poly)

plot(dem_cropmask_ext)

############################################################
# 7) CROP E MASK CON MINIMO POLIGONO CONVESSO
############################################################

# Prima facciamo crop usando il bounding box del convex hull
dem_crop_hull <- crop(dem, vect(pts_hull))

# Poi mask usando il convex hull vero e proprio
dem_mask_hull <- mask(dem, vect(pts_hull))

# Infine crop + mask insieme
dem_cropmask_hull <- mask(dem_crop_hull, vect(pts_hull))

# Visualizziamo
plot(dem_crop_hull)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

plot(dem_mask_hull)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

plot(dem_cropmask_hull)
plot(vect(pts_hull), add = TRUE, border = "darkgreen", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)


# crop e mask con un buffer intorno al extent
# il buffer aggiunge una zona di 100 km intorno all'extent, per includere un'area più ampia
buff_ext <- terra::buffer(ext_poly, width = 100000) 

dem_buff <- dem |> 
  crop(buff_ext) |> 
  mask(buff_ext)

plot(dem_buff)
plot(buff_ext, add = TRUE, border = "purple", lwd = 2)
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
ncell(dem_crop_ext) # pesa poco, è veloce, consigliato come primo step
ncell(dem_mask_hull) # pesa di più, se fatto da solo, e dunque conviene farlo a valle di un crop

# In generale, se il DEM è molto grande, conviene prima fare un crop con l'extent 
# per ridurre la dimensione del raster, e poi fare il mask con il convex hull per
# ottenere l'area di studio più precisa. 

# step in un unica pipeline
# DEM |> 
#   crop(ext_poly) |>
#   mask(vect(pts_hull))

############################################################
# 9) CALCOLARE VARIABILI TOPOGRAFICHE
############################################################

# Calcoliamo slope e aspect dal DEM ritagliato sul convex hull
# (di solito è la scelta più interessante)

slope <- terrain(dem_buff, v = "slope", unit = "degrees")
aspect <- terrain(dem_buff, v = "aspect", unit = "degrees")

plot(slope, main = "Slope")
plot(vect(pts_hull), add = TRUE, border = "black", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

plot(aspect, main = "Aspect")
plot(vect(pts_hull), add = TRUE, border = "black", lwd = 2)
plot(pts_vect, add = TRUE, col = "red", pch = 16)

############################################################
# 10) ESTRARRE QUOTA, SLOPE E ASPECT NEI PUNTI
############################################################

elev_pts <- terra::extract(dem_mask_hull, pts_vect)
slope_pts <- terra::extract(slope, pts_vect)
aspect_pts <- terra::extract(aspect, pts_vect)

# Aggiungiamo tutto ai punti
pts <- pts |> 
  add_column(
  elev = elev_pts$ITA_elv_msk,
  slope = slope_pts$slope,
  aspect = aspect_pts$aspect
  )


# 11 ho cambiato geom_raster con geom_spatraster, che è più efficiente per i raster di terra
# evita di dover trasformare il raster in data frame, e dunque è più veloce e leggero
############################################################
# 11a) MAPPA DEM
############################################################

pp_dem <- ggplot() +
  geom_spatraster(
    data = dem_buff, aes(fill = ITA_elv_msk)) +
  geom_sf(data = pts, aes(size = SR), color = "red") +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) +
  labs(
    title = "Sampling points on DEM",
    x = "Longitude",
    y = "Latitude",
    fill = "Elevation",
    size = "SR"
  ) +
  scale_fill_continuous(na.value = "transparent") +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true",
                         height = unit(1.5, "cm"),
                         width = unit(1, "cm"),
                         pad_x = unit(0.25, "cm"),
                         pad_y = unit(0.25, "cm")) +
  theme_void()

pp_dem

############################################################
# 11b) MAPPA SLOPE
############################################################

pp_slope <- ggplot() +
  geom_spatraster(
    data = slope, aes(fill = slope)) +
  geom_sf(data = pts, color = "red", size = 2) +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) + # i punti sotto il poligono, non si vedono bene
  # confronta con grafico sotto, dove i punti sono sopra il poligono, e dunque più visibili
  labs(
    title = "Slope",
    x = "Longitude",
    y = "Latitude",
    fill = "Slope (°)"
  ) +
  scale_fill_continuous(na.value = "transparent") +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true",
                         height = unit(1.5, "cm"),
                         width = unit(1, "cm"),
                         pad_x = unit(0.25, "cm"),
                         pad_y = unit(0.25, "cm")) +
  theme_void()

pp_slope

############################################################
# 11c) MAPPA ASPECT
############################################################

pp_asp <- ggplot() +
  geom_spatraster(
    data = aspect, aes(fill = aspect)) +
  geom_sf(data = pts_hull, fill = NA, color = "black", linewidth = 0.8) +
  geom_sf(data = pts, color = "red", size = 2) + # i punti sopra il poligono, per essere ben visibili
  # confronta con grafico sopra, dove i punti sono sotto il poligono, e dunque meno visibili
  labs(
    title = "Aspect",
    x = "Longitude",
    y = "Latitude",
    fill = "Aspect (°)"
  ) +
  scale_fill_viridis_c(na.value = "transparent") +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true",
                         height = unit(1.5, "cm"),
                         width = unit(1, "cm"),
                         pad_x = unit(0.25, "cm"),
                         pad_y = unit(0.25, "cm")) +
  theme_void()

pp_asp

############################################################
# 11d) mettere i grafici insieme con patchwork
############################################################

pp_dem + pp_slope + pp_asp


if(!dir.exists("output/figure")) {
  dir.create("output/figure", recursive = TRUE)
}
# esporta il grafico combinato in alta risoluzione
ggsave("output/figure/mappe_topografiche.jpeg", width = 420, height = 220, dpi = 300, units = "mm")


############################################################
# 11e) mappa con dem in trasparenza e sotto l'hillshade
############################################################

aspect_rad <- terrain(dem_buff, v = "aspect", unit = "radians") # aspect in radianti per hillshade
slope_rad <- terrain(dem_buff, v = "slope", unit = "radians") # aspect in radianti per hillshade
 
hillshade <- shade(slope_rad, aspect_rad)

pp_hillshade <- ggplot() +
   geom_spatraster(
     data = hillshade, aes(fill = hillshade), alpha = 1) +
   scale_fill_gradient(low = "black", high = "white", na.value = "transparent") +
   new_scale_colour() +
  geom_spatraster(
    data = dem_buff, aes(fill = ITA_elv_msk), alpha = 0.7) + # aggiunge il DEM in trasparenza sopra l'hillshade
  geom_sf(data = pts_hull |> st_buffer(dist = 10000), fill = "white", alpha = .1, color = "darkgray", linewidth = 0.1) +
  geom_sf(data = pts, color = "red", size = 2) +
  labs(
    title = "Hillshade with DEM overlay",
    x = "Longitude",
    y = "Latitude",
    fill = "Elevation"
  ) +
  scale_fill_viridis_c(na.value = "transparent") +
  annotation_scale(location = "bl") +
  annotation_north_arrow(location = "tr", which_north = "true",
                         height = unit(1.5, "cm"),
                         width = unit(1, "cm"),
                         pad_x = unit(0.25, "cm"),
                         pad_y = unit(0.25, "cm")) +
  theme_void()

pp_hillshade

ggsave("output/figure/figure_01.jpeg", width = 270, height = 220, dpi = 300, units = "mm")

############################################################
# 12) RELAZIONE QUOTA ~ SR
############################################################

ggplot(pts, aes(x = elev, y = SR)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = F) + # aggiunge una linea di regressione lineare
  # non è detto che la relazione sia lineare, ma è un buon punto di partenza per esplorare
  # non è un modllo definitivo, ma serve per visualizzare la tendenza generale
  # non è richiesto per l'esame, ma è un modo semplice per esplorare la relazione tra quota e ricchezza
  labs(
    title = "Species richness vs elevation",
    x = "Elevation (m) a.s.l.",
    y = "Species richness"
  ) +
  theme_minimal()

############################################################
# 12b) RELAZIONE QUOTA ~ SR SLOPE e ASPECT in tre pannelli
############################################################
# si potrebbe fare un loop
# oppure fare tre grafici e metterli insieme con patchwork 
# oppure pivot_longer per mettere tutto in un unico grafico con facet_wrap

# vediamo la versione più elegante con pivot_longer e facet_wrap

pts_long <- pts |> 
  pivot_longer(
    cols = c(elev, slope, aspect),
    names_to = "variable",
    values_to = "value"
  )


ggplot(pts_long, aes(x = value, y = SR)) +
  geom_point(size = 2) +
  geom_smooth(method = "lm", se = F) +
  facet_wrap(~ variable, scales = "free_x") + # crea un pannello per
  # ogni variabile, con scale indipendenti
  labs(
    title = "Species richness vs topographic variables",
    x = "Value",
    y = "Species richness"
  ) +
  theme_minimal()

############################################################
# 13) MAPPA INTERATTIVA CON LEAFLET
############################################################

# Leaflet lavora bene con raster proiettati in WGS84 / lon-lat
# Se il DEM è molto pesante, conviene lavorare sul DEM già ritagliato

pal_dem <- colorNumeric("viridis", values(dem_buff), na.color = NA)

leaflet() |>
  addTiles() |>
  addRasterImage(
    dem_buff,
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