library(tidyverse)
library(palmerpenguins)
library(patchwork)
library(gt)
library(plotly)



data(penguins)

glipse(penguins)

############################################################
# 1) RECAP DI GGPLOT
############################################################

# ggplot2 costruisce un grafico per strati/layer.
#
# La struttura minima è:
#
# ggplot(data = DATI, aes(x = VARIABILE_X, y = VARIABILE_Y)) +
#   geom_QUALCOSA()
#
# data = il dataset
# aes() = aesthetic mapping, cioè collegamento tra variabili e elementi grafici
# geom_*() = il tipo di geometria da disegnare

ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()


############################################################
# 2) COSA VUOL DIRE aes()
############################################################

# aes() significa "aesthetic mapping".
#
# Dentro aes() NON stiamo scegliendo semplicemente colori o forme.
# Stiamo dicendo a ggplot:
#
# "usa questa variabile del dataset per controllare
#  una proprietà visiva del grafico"
#
# Esempio:
# x = flipper_length_mm  -> la variabile flipper_length_mm controlla l'asse x
# y = body_mass_g        -> la variabile body_mass_g controlla l'asse y

ggplot(penguins,
       aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()


############################################################
# 3) AGGIUNGERE UNA VARIABILE AL COLORE
############################################################

# Qui color = species è DENTRO aes().
#
# Significa:
# "usa la variabile species per colorare i punti"
#
# Quindi il colore porta informazione biologica.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point()


############################################################
# 4) COLOR DENTRO aes() VS FUORI aes()
############################################################

# CASO A: color DENTRO aes()
#
# Il colore dipende da una variabile del dataset.
# ggplot crea automaticamente una legenda.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point()


# CASO B: color FUORI aes()
#
# Il colore è una scelta fissa.
# Tutti i punti saranno rossi.
# Non c'è legenda, perché il colore non rappresenta una variabile.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g)) +
  geom_point(color = "red")


# REGOLA CHIAVE:
#
# Dentro aes()  -> una variabile controlla un elemento grafico
# Fuori aes()   -> imposto manualmente un valore fisso


############################################################
# 5) ALTRI AESTHETICS: SHAPE, SIZE, ALPHA
############################################################

# shape dentro aes()
# La forma dei punti dipende da sex.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           shape = sex)) +
  geom_point()


# size dentro aes()
# La dimensione dei punti dipende da bill_length_mm.
# Attenzione: non sempre è una buona scelta comunicativa.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           size = bill_length_mm)) +
  geom_point(alpha = 0.7)


# alpha fuori aes()
# Qui alpha è fisso: tutti i punti sono semi-trasparenti.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point(alpha = 0.6)


############################################################
# 6) aes() GLOBALE E aes() LOCALE
############################################################

# Posso mettere aes() dentro ggplot().
# In quel caso vale per tutti i layer successivi.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)


# Posso anche mettere aes() dentro un singolo geom.
# In quel caso vale solo per quel layer.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g)) +
  geom_point(aes(color = species)) +
  geom_smooth(method = "lm", se = FALSE)


# Differenza importante:
# nel primo caso anche geom_smooth() usa color = species,
# quindi calcola una linea per ogni specie.
#
# nel secondo caso color = species è solo nei punti,
# quindi geom_smooth() calcola una sola linea generale.


############################################################
# 7) LAYER: AGGIUNGERE INFORMAZIONE POCO ALLA VOLTA
############################################################

# Layer 1: punti
# Layer 2: linea di regressione
# Layer 3: tema
# Layer 4: etichette

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Relationship differs among penguin species",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    color = "Species"
  ) +
  theme_minimal()


############################################################
# 8) BARPLOT: geom_bar() VS geom_col()
############################################################

# geom_bar() CONTA automaticamente le righe.
# Qui non serve calcolare prima n.

ggplot(penguins,
       aes(x = species)) +
  geom_bar()


# geom_col() invece usa valori già calcolati.
# Quindi prima dobbiamo fare una tabella riassuntiva.

species_count <- penguins |>
  count(species)

species_count

ggplot(species_count,
       aes(x = species, y = n)) +
  geom_col()


# REGOLA:
# geom_bar() -> conta righe
# geom_col() -> usa valori già presenti nel dataset


############################################################
# 9) BOXPLOT VS VIOLINPLOT
############################################################

# Boxplot:
# mostra mediana, quartili e outlier.
# È sintetico e robusto.

ggplot(penguins,
       aes(x = species, y = body_mass_g, fill = species)) +
  geom_boxplot()


# Violinplot:
# mostra la forma della distribuzione.
# È utile per vedere densità e asimmetrie.

ggplot(penguins,
       aes(x = species, y = body_mass_g, fill = species)) +
  geom_violin(trim = FALSE)


# Combinazione utile:
# violinplot + boxplot piccolo sopra

ggplot(penguins,
       aes(x = species, y = body_mass_g, fill = species)) +
  geom_violin(trim = FALSE, alpha = 0.6) +
  geom_boxplot(width = 0.15, alpha = 0.8)


############################################################
# 10) MIGLIORARE UN GRAFICO: SCALE, THEME, LEGEND
############################################################

# Le scale controllano come i dati vengono trasformati in colori,
# dimensioni, assi, ecc.
#
# theme() controlla l'aspetto non-dato:
# griglia, legenda, testo, margini, ecc.

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point(size = 2.4, alpha = 0.75) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Body mass increases with flipper length",
    subtitle = "Each point is one penguin",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    color = "Species"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )


############################################################
# 11) DUE GRAFICI SEPARATI + PATCHWORK
############################################################

# Primo grafico: bill length

p_bill_length <- ggplot(penguins,
                        aes(x = species,
                            y = bill_length_mm,
                            fill = species)) +
  geom_boxplot() +
  labs(
    title = "Bill length",
    x = "Species",
    y = "Bill length (mm)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# Secondo grafico: bill depth

p_bill_depth <- ggplot(penguins,
                       aes(x = species,
                           y = bill_depth_mm,
                           fill = species)) +
  geom_boxplot() +
  labs(
    title = "Bill depth",
    x = "Species",
    y = "Bill depth (mm)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# Uniamo i due grafici con patchwork

p_layout <- p_bill_length + p_bill_depth +
  plot_annotation(
    title = "Palmer penguins: overview",
    subtitle = "Bill length and depth by species"
  )

p_layout

## ggarrange è un'altra modalità per combinare grafici

ggarrange(
  p_bill_length,
  p_bill_depth,
  ncol = 2,
  nrow = 2,
  common.legend = TRUE,
  legend = "bottom"
)

## wrao_plots è una funzione di patchwork per combinare grafici in una lista

list(p_bill_length, p_bill_depth) |>
  wrap_plots(ncol = 2) +
  plot_annotation(
    title = "Palmer penguins: overview",
    subtitle = "Bill length and depth by species"
  )


# Questo approccio è utile quando i grafici sono molto diversi.
# Però stiamo ripetendo molto codice.


############################################################
# 12) STESSA IDEA CON pivot_longer() + facet_wrap()
############################################################

# Invece di creare due grafici separati,
# possiamo trasformare i dati in formato long.

penguins_bill_long <- penguins |>
  select(species, bill_length_mm, bill_depth_mm) |>
  pivot_longer(
    cols = c(bill_length_mm, bill_depth_mm),
    names_to = "trait",
    values_to = "value"
  )

penguins_bill_long

# Ora abbiamo:
# species -> specie
# trait   -> nome della variabile misurata
# value   -> valore numerico

ggplot(penguins_bill_long,
       aes(x = species, y = value, fill = species)) +
  geom_boxplot() +
  facet_wrap(~ trait, scales = "free_y") +
  labs(
    title = "Bill traits by species",
    subtitle = "Same plot structure applied to two variables",
    x = "Species",
    y = "Value"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


# DIFFERENZA DIDATTICA:
#
# patchwork:
# - costruisco più grafici separati
# - poi li monto insieme
# - molto flessibile per grafici diversi
#
# pivot_longer + facet_wrap:
# - cambio la forma dei dati
# - costruisco un solo grafico
# - ggplot crea automaticamente i pannelli
#
# soluzione alternativa
# loop o funzione per creare più grafici simili
# unirli tramite patchwork con la funzione patchwork::wrap_plots()
# - codice sintetico
# - costruisco una lista di grafici
# - more brain consuming


############################################################
# 13) FACET_WRAP: DIVIDERE LO STESSO GRAFICO PER GRUPPI
############################################################

# facet_wrap(~ island) significa:
# "crea un pannello separato per ogni isola"

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = species)) +
  geom_point(alpha = 0.7) +
  facet_wrap(~ island) +
  labs(
    title = "Relationship by island",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    color = "Species"
  ) +
  theme_minimal()


############################################################
# 14) FACET_GRID: DUE VARIABILI DI FACETING
############################################################

# facet_grid(sex ~ species) crea una griglia:
# righe = sex
# colonne = species

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g)) +
  geom_point(alpha = 0.7) +
  facet_grid(sex ~ species) +
  labs(
    title = "Body mass vs flipper length by sex and species",
    x = "Flipper length (mm)",
    y = "Body mass (g)"
  ) +
  theme_minimal()

# come trattare gli NA in questo caso?


############################################################
# 15) ESEMPIO COMPLETO: BOXPLOT + MEDIE CALCOLATE
############################################################

# Obiettivo:
# confrontare più variabili morfologiche tra specie.
#
# Idea:
# 1. trasformiamo i dati grezzi in formato long
# 2. facciamo un boxplot per ogni variabile
# 3. calcoliamo la media per specie e variabile
# 4. aggiungiamo la media come testo sopra ogni boxplot


############################################################
# 15a) DATI GREZZI IN FORMATO LONG
############################################################

# Prima partiamo dai dati individuali.
# Ogni riga è un pinguino.
# Le variabili morfologiche sono in colonne diverse.

penguins_traits_long <- penguins |>
  select(
    species,
    bill_length_mm,
    bill_depth_mm,
    flipper_length_mm,
    body_mass_g
  ) |>
  pivot_longer(
    cols = c(
      bill_length_mm,
      bill_depth_mm,
      flipper_length_mm,
      body_mass_g
    ),
    names_to = "trait",
    values_to = "value"
  )

# Ora il dataset è in formato long:
# species = specie
# trait   = variabile morfologica
# value   = valore osservato

penguins_traits_long


############################################################
# 15b) CALCOLARE LE MEDIE DA DATI LONG
############################################################

# Calcoliamo la media per ogni combinazione:
# specie × variabile

penguins_trait_means <- penguins_traits_long |>
  group_by(species, trait) |>
  summarise(
    mean_value = mean(value, na.rm = TRUE),
    .groups = "drop"
  )

penguins_trait_means


############################################################
# 15c) BOXPLOT + MEDIA COME TESTO
############################################################

ggplot(
  data = penguins_traits_long,
  aes(x = species, y = value, fill = species)
) +
  # Boxplot sui dati grezzi
  geom_boxplot(alpha = 0.75, outlier.alpha = 0.4) +
  
  # Punto della media calcolata
  geom_point(
    data = penguins_trait_means,
    aes(x = species, y = mean_value),
    inherit.aes = FALSE,
    size = 2.5,
    shape = 21,
    fill = "white"
  ) +
  
  # Testo con il valore medio
  geom_text(
    data = penguins_trait_means,
    aes(
      x = species,
      y = mean_value*1.1, # posiziona il testo un po' sopra il punto della media
      label = round(mean_value, 1)
    ),
    inherit.aes = FALSE, # inherit.aes = FALSE significa: # questo layer NON deve ereditare automaticamente gli aes() del ggplot principale.   
    vjust = 0,
    hjust = 1,
    size = 6.5
  ) +
  
  # Un pannello per ogni variabile
  facet_wrap(~ trait, scales = "free_y") +
  
  # Scala colori
  scale_fill_brewer(palette = "Dark2") +
  
  # Titoli e assi
  labs(
    title = "Morphological traits by penguin species",
    subtitle = "Boxplots show individual variation; labels show species means",
    x = "Species",
    y = "Observed value",
    fill = "Species"
  ) +
  
  # Tema
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(angle = 30, hjust = 1),
    panel.grid.minor = element_blank()
  )

############################################################
# 16) ERRORI COMUNI DA MOSTRARE
############################################################

# Errore concettuale frequente:
# mettere un valore fisso dentro aes()

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g,
           color = "red")) +
  geom_point()

# Questo NON significa "punti rossi".
# Significa:
# "crea una variabile estetica chiamata red".
# Infatti compare una legenda inutile.

# Corretto:

ggplot(penguins,
       aes(x = flipper_length_mm,
           y = body_mass_g)) +
  geom_point(color = "red")


############################################################
# GT TABLE

library(ggpubr)

library(scales)
library(sf)
library(rnaturalearth)
library(leaflet)



############################################################
# 17) TABELLA RIASSUNTIVA SEMPLICE
############################################################

summary_species <- penguins |>
  group_by(species) |>
  summarise(
    n = n(),
    mean_body_mass = mean(body_mass_g, na.rm = T),
    sd_body_mass = sd(body_mass_g, na.rm = T),
    mean_flipper = mean(flipper_length_mm, na.rm = T),
    sd_flipper = sd(flipper_length_mm, na.rm = T),
    .groups = "drop"
  )

summary_species

summary_species |>
  gt()



############################################################
# 18) GT TABLE CON CIFRE DECIMALI E NOMI PIÙ LEGGIBILI
############################################################

summary_species |>
  gt() |>
  fmt_number(
    columns = c(mean_body_mass, sd_body_mass,
                mean_flipper, sd_flipper),
    decimals = 1
  ) |>
  cols_label(
    species = "Species",
    n = "N",
    mean_body_mass = "Mean body mass (g)",
    sd_body_mass = "SD body mass",
    mean_flipper = "Mean flipper length (mm)",
    sd_flipper = "SD flipper length"
  )


############################################################
# 19) GT TABLE CON TITOLO E STILE
############################################################

summary_species |>
  gt() |>
  tab_header(
    title = "Summary of Palmer penguins by species",
    subtitle = "Body mass and flipper length"
  ) |>
  fmt_number(
    columns = c(mean_body_mass, sd_body_mass,
                mean_flipper, sd_flipper),
    decimals = 1
  ) |>
  cols_label(
    species = "Species",
    n = "N",
    mean_body_mass = "Mean body mass (g)",
    sd_body_mass = "SD body mass",
    mean_flipper = "Mean flipper length (mm)",
    sd_flipper = "SD flipper length"
  ) |>
  tab_options(
    table.font.size = 13,
    heading.title.font.size = 16,
    heading.subtitle.font.size = 12
  )


############################################################
# 20) GT TABLE CON COLORI
############################################################

summary_species |>
  gt() |>
  tab_header(
    title = "Summary of Palmer penguins by species",
    subtitle = "Higher mean body mass is highlighted"
  ) |>
  fmt_number(
    columns = c(mean_body_mass, sd_body_mass,
                mean_flipper, sd_flipper),
    decimals = 1
  ) |>
  cols_label(
    species = "Species",
    n = "N",
    mean_body_mass = "Mean body mass (g)",
    sd_body_mass = "SD body mass",
    mean_flipper = "Mean flipper length (mm)",
    sd_flipper = "SD flipper length"
  ) |>
  data_color(
    columns = mean_body_mass,
    palette = "Blues"
  )


############################################################
# 21) TABELLA PIÙ COMPLESSA: SPECIE × ISOLA
############################################################

summary_species_island <- penguins |>
  group_by(species, island) |>
  summarise(
    n = n(),
    mean_body_mass = mean(body_mass_g, na.rm = T),
    mean_flipper = mean(flipper_length_mm, na.rm = T),
    .groups = "drop"
  )

summary_species_island |>
  gt(groupname_col = "species") |>
  tab_header(
    title = "Penguins summary by species and island"
  ) |>
  fmt_number(
    columns = c(mean_body_mass, mean_flipper),
    decimals = 1
  ) |>
  cols_label(
    island = "Island",
    n = "N",
    mean_body_mass = "Mean body mass (g)",
    mean_flipper = "Mean flipper length (mm)"
  ) |>
  data_color(
    columns = mean_body_mass,
    palette = "Greens"
  ) |> 
  data_color(
    columns = mean_flipper,
    palette = "Greens"
  )


############################################################
# 22) ESPORTARE TABELLE
############################################################

gt_table <- summary_species |>
  gt() |>
  tab_header(
    title = "Summary of Palmer penguins by species"
  ) |>
  fmt_number(
    columns = c(mean_body_mass, sd_body_mass,
                mean_flipper, sd_flipper),
    decimals = 1
  )

if (!dir.exists("output/table")) {
  dir.create("output/table")
}

# Salvare una tabella gt come HTML
gtsave(gt_table, "output/table/penguins_summary_table.html")

# Salvare una tabella gt come immagine 
gtsave(
  data = gt_table,
  filename = "output/table/penguins_summary_table.png"
)

# Salvare una tabella gt come PDF  
gtsave(
  data = gt_table,
  filename = "output/table/penguins_summary_table.pdf"
)


############################################################
# 23) VISUALIZZAZIONE INTERATTIVA CON PLOTLY
############################################################

# plotly trasforma un ggplot in un grafico interattivo

p_interactive <- ggplot(penguins,
                        aes(x = flipper_length_mm,
                            y = body_mass_g,
                            color = species,
                            text = paste(
                              "Species:", species,
                              "<br>Island:", island,
                              "<br>Sex:", sex,
                              "<br>Body mass:", body_mass_g
                            ))) +
  geom_point(size = 2.5, alpha = 0.8) +
  labs(
    title = "Interactive scatterplot",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    color = "Species"
  ) +
  theme_minimal()

ggplotly(p_interactive, tooltip = "text")

