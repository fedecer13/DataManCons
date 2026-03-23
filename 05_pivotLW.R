############################################################
# TIDYR – INTRODUZIONE A pivot_longer() e pivot_wider()
# Script introduttivo con esempio grafico
############################################################

library(tidyverse)
library(palmerpenguins)

data(penguins)

# Guardiamo rapidamente il dataset
glimpse(penguins)


############################################################
# 1) IDEA DI BASE
############################################################

# In generale:
#
# formato wide (largo):
# - una variabile distribuita su più colonne
#
# formato long (lungo):
# - una colonna contiene il nome della variabile
# - una colonna contiene il valore
#
# Spesso ggplot2 lavora molto bene con dati in formato long


############################################################
# 2) CREIAMO UN PICCOLO DATASET RIASSUNTIVO
############################################################

# Calcoliamo, per ogni specie, la media di due variabili
# in modo da avere un dataset semplice da trasformare

penguins_summary <- penguins |>
  group_by(species) |>
  summarise(
    mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
    mean_flipper_length = mean(flipper_length_mm, na.rm = TRUE)
  )

penguins_summary

# Questo è un classico formato WIDE:
# una riga per specie
# due misure in due colonne separate


############################################################
# 3) GRAFICO CON DATI IN FORMATO WIDE
############################################################

# Possiamo fare un grafico, ma dobbiamo scegliere
# una variabile per volta

ggplot(penguins_summary, aes(x = species, y = mean_bill_length)) +
  geom_col() +
  labs(
    title = "Mean bill length by species",
    y = "Bill length (mm)",
    x = "Species"
  )

# Se vogliamo rappresentare anche mean_flipper_length
# nello stesso schema, il formato wide è meno comodo


############################################################
# 4) PIVOT_LONGER
############################################################

# pivot_longer() trasforma più colonne in due colonne:
# - una con il nome della variabile
# - una con il valore

penguins_long <- penguins_summary |>
  pivot_longer(
    cols = c(mean_bill_length, mean_flipper_length),
    names_to = "measure",
    values_to = "value"
  )


penguins |>
  group_by(species) |>
  summarise(
    mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
    mean_bill_depth = mean(bill_depth_mm, na.rm = TRUE)
  ) |> 
  pivot_longer(
    cols = -species,
    names_to = "measure",
    values_to = "value"
  ) |> 
  ggplot(aes(x = species, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  labs(
    title = "Two measures in long format",
    x = "Species",
    y = "Value (mm)",
    fill = "Misurazioni"
  )

# Ora i dati sono in formato LONG:
# species = gruppo
# measure = nome della misura
# value = valore numerico


############################################################
# 5) GRAFICO CON DATI IN FORMATO LONG
############################################################

# Ora possiamo usare una sola struttura dati
# e distinguere le misure con il colore

ggplot(penguins_long, aes(x = species, y = value, fill = measure)) +
  geom_col(position = "dodge") +
  labs(
    title = "Two measures in long format",
    x = "Species",
    y = "Value (mm)",
    fill = "Misurazioni"
  )

# Questo è uno dei motivi per cui il formato long
# è spesso molto utile: rende i grafici più flessibili


############################################################
# 6) PIVOT_WIDER
############################################################

# pivot_wider() fa il contrario:
# trasforma il formato long di nuovo in wide

penguins_long |>
  pivot_wider(
    names_from = measure,
    values_from = value
  )

# Quindi:
# pivot_longer()  -> da wide a long
# pivot_wider()   -> da long a wide


############################################################
# 7) ESEMPIO ANCORA PIÙ INTUITIVO
############################################################

# Costruiamo un piccolo dataset "a mano"
# per vedere meglio cosa succede

dati_wide <- data.frame(
  species = c("Adelie", "Gentoo", "Chinstrap"),
  bill = c(38.8, 47.5, 48.8),
  flipper = c(190, 217, 196)
)

dati_wide

# Formato wide:
# una colonna per bill
# una colonna per flipper

dati_long <- dati_wide |>
  pivot_longer(
    cols = c(bill, flipper),
    names_to = "trait",
    values_to = "mean_value"
  )

dati_long

# Grafico del formato long
ggplot(dati_long, aes(x = species, y = mean_value, fill = trait)) +
  geom_col(position = "dodge") +
  labs(
    title = "Wide to long example",
    x = "Species",
    y = "Mean value",
    fill = "Trait"
  )


############################################################
# 8) PICCOLO PROMEMORIA FINALE
############################################################

# pivot_longer():
# - utile quando tante colonne rappresentano livelli
#   della stessa idea o misura
# - spesso prepara bene i dati per ggplot2
#
# pivot_wider():
# - utile quando vogliamo riportare i dati in formato tabellare largo
#
# Regola pratica:
# se i nomi delle colonne contengono valori di una variabile,
# spesso conviene usare pivot_longer()


############################################################
# 9) MINI ESERCIZI
############################################################

### ESERCIZIO 1
# Trasformare penguins_summary da wide a long

### ESERCIZIO 2
# Fare un grafico a barre del dataset long
# con species sull'asse x e value sull'asse y

### ESERCIZIO 3
# Trasformare di nuovo penguins_long in wide

### ESERCIZIO 4
# Creare un dataset riassuntivo con tre misure:
# mean_bill_length, mean_bill_depth, mean_body_mass
# e poi trasformarlo in long