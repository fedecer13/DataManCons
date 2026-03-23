############################################################
# arrange(), group_by(), summarise(), count(), across()
############################################################

library(tidyverse)
library(palmerpenguins)

data(penguins)

# Guardiamo rapidamente il dataset
glimpse(penguins)


############################################################
# 1) ARRANGE
############################################################

# arrange() serve per ordinare le righe

peng_arr <- penguins |>
  arrange(body_mass_g)

penguins |>
  arrange(desc(body_mass_g)) |>
  head()


############################################################
# 2) GROUP BY + SUMMARISE
############################################################

# group_by() definisce i gruppi
# summarise() calcola un riassunto per ciascun gruppo

# Esempio 1: peso medio per specie
penguins |>
  #filter(!is.na(body_mass_g)) |> 
  group_by(species) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = TRUE)
  )

# Esempio 2: più statistiche per specie
penguins |>
  group_by(species) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    sd_mass = sd(body_mass_g, na.rm = TRUE),
    n = n()
  )

# Esempio 3: riassunto per specie e isola
penguins |>
  group_by(species, island) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    n = n()
  )

############################################################
# 3) COUNT
############################################################

# count() è una scorciatoia molto utile per contare osservazioni

penguins |>
  count(species)

penguins |>
  count(species, island)


############################################################
# 4) TANTE VARIABILI STESSA FUNZIONE
############################################################

# Immaginiamo di voler calcolare la media di più variabili
# numeriche per ciascuna specie

# Possiamo farlo "a mano", scrivendo una riga per ogni colonna

penguins |>
  group_by(species) |>
  summarise(
   mean_bill_length = mean(bill_length_mm,na.rm = TRUE),
   mean_bill_depth = mean(bill_depth_mm,na.rm = TRUE),
   mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE),
   mean_body_mass = mean(body_mass_g, na.rm = TRUE)
  )

# Questo approccio funziona bene con poche colonne,
# ma diventa lungo e ripetitivo quando le colonne aumentano


############################################################
# 5) ACROSS
############################################################

# across() serve per applicare la stessa funzione
# a più colonne contemporaneamente

# Esempio 1: stessa cosa di prima, ma più compatta
penguins |>
  group_by(species) |>
  summarise(
    across(
      c(bill_length_mm, 
      bill_depth_mm, 
      flipper_length_mm, 
      body_mass_g),
      mean,
      na.rm = TRUE
    )
  )

# Esempio 2: rinominare le nuove colonne in modo più chiaro
penguins |>
  group_by(species) |>
  summarise(
    across(
      c(bill_length_mm, bill_depth_mm, flipper_length_mm, body_mass_g),
      mean,
      na.rm = TRUE,
      .names = "mean_{.col}"
    )
  )

# Esempio 3: più funzioni sulle stesse colonne
penguins |>
  group_by(species) |>
  summarise(
    across(
      c(bill_length_mm, body_mass_g),
      list(mean = mean, sd = sd),
      na.rm = TRUE
    )
  )

# Esempio 4: tutte le colonne numeriche
penguins |> 
  select(where(is.numeric))


penguins |>
  mutate(year = as.factor(year)) |> 
  group_by(species) |>
  summarise(
    across(
      where(is.numeric),
      mean,
      na.rm = TRUE,
      .names = "mean_{.col}"
    )
  )

# Esempio 5: combinare across() con n()
penguins |>
  group_by(species) |>
  summarise(
    n = n(),
    across(
      where(is.numeric),
      mean,
      na.rm = TRUE,
      .names = "mean_{.col}"
    )
  )


############################################################
# 6) ESEMPIO DIDATTICO
############################################################

# Versione manuale
penguins |>
  group_by(species) |>
  summarise(
    mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
    mean_body_mass = mean(body_mass_g, na.rm = TRUE)
  )

# Versione con across()
penguins |>
  group_by(species) |>
  summarise(
    across(
      c(bill_length_mm, body_mass_g),
      mean,
      na.rm = TRUE,
      .names = "mean_{.col}"
    )
  )

# across() è particolarmente utile quando:
# - le colonne sono molte
# - la funzione è la stessa
# - vogliamo evitare codice ripetitivo


############################################################
# ESERCIZI
############################################################

# Usare sempre il dataset penguins
# e il pipe nativo |>


### ESERCIZIO 1
# Ordinare il dataset in ordine crescente di bill_length_mm


### ESERCIZIO 2
# Ordinare il dataset in ordine decrescente di flipper_length_mm


### ESERCIZIO 3
# Calcolare il peso medio (body_mass_g) per specie


### ESERCIZIO 4
# Calcolare media e deviazione standard di body_mass_g per specie


### ESERCIZIO 5
# Contare quante osservazioni ci sono per ciascuna specie


### ESERCIZIO 6
# Contare quante osservazioni ci sono per specie e isola


### ESERCIZIO 7
# Calcolare, in modo manuale, la media di:
# bill_length_mm, bill_depth_mm e body_mass_g
# per ciascuna specie


### ESERCIZIO 8
# Usare across() per calcolare la media di:
# bill_length_mm, bill_depth_mm e body_mass_g
# per ciascuna specie


### ESERCIZIO 9
# Usare across() per calcolare la media
# di tutte le colonne numeriche per specie


### ESERCIZIO 10
# Usare across() per calcolare media e sd
# di bill_length_mm e flipper_length_mm per specie


### ESERCIZIO 11
# Calcolare il numero di osservazioni e la media di body_mass_g
# per specie e isola


### ESERCIZIO 12
# Calcolare il numero di osservazioni e la media
# di tutte le colonne numeriche per specie


### ESERCIZIO 13
# Calcolare la media di tutte le colonne numeriche
# per specie e isola


### ESERCIZIO 14
# Ordinare il risultato dell'esercizio precedente
# in ordine decrescente di mean_body_mass_g
# (suggerimento: usare .names in across())


### ESERCIZIO 15
# Creare una tabella riassuntiva per specie con:
# - n
# - media di bill_length_mm
# - media di bill_depth_mm
# - media di flipper_length_mm
# - media di body_mass_g

############################################################
# PROMEMORIA FINALE
############################################################

# arrange()   -> ordina le righe
# group_by()  -> definisce i gruppi
# summarise() -> riassume i gruppi
# count()     -> conta osservazioni
# across()    -> applica la stessa funzione a più colonne