############################################################
# INTRODUZIONE AL TIDYVERSE
# Pipe nativo, pipe del tidyverse, select() e filter()
############################################################

### 1) CARICARE I PACCHETTI ----------------------------------

# dplyr contiene molte funzioni base del tidyverse per manipolare dati
#install.packages("tidyverse")
library(tidyverse)
library(palmerpenguins)

### 2) DATASET DI PARTENZA -----------------------------------

# Usiamo iris, già presente in R
data(iris)

dir.create("data")  # creiamo la cartella data se non esiste
#write.csv(iris, "data/iris.csv", row.names = FALSE)
rm(iris)  # rimuoviamo iris per poi ricaricarlo con read_cs
gc()
iris <- read.csv("data/iris.csv")

# Guardiamo il dataset
View(iris)
head(iris)
str(iris)


### 3) IDEA DI BASE DEL TIDYVERSE ----------------------------

# Nel tidyverse spesso lavoriamo in questo modo:
# dati |> funzione1() |> funzione2()
#
# cioè:
# prendo un oggetto
# poi lo trasformo passo dopo passo
# in una sequenza leggibile


### 4) PIPE NATIVO E PIPE DEL TIDYVERSE ----------------------

# PIPE NATIVO (base R, da R 4.1 in poi)
# Simbolo: |>

iris |>
  head()

# PIPE DEL TIDYVERSE / magrittr
# Simbolo: %>%
### commit github
iris %>%
  head()

# Nella maggior parte dei casi fanno la stessa cosa:
# passano l'oggetto di sinistra come primo argomento
# della funzione a destra.

# Esempio senza pipe
head(iris)

# Esempio con pipe nativo
iris |>
  head()

# Esempio con pipe tidyverse
iris %>%
  head()

# Per iniziare oggi possiamo far vedere entrambi,
# ma poi usare soprattutto il pipe del tidyverse
# perché si incontra spesso nei materiali didattici.


### 5) SELECT(): SCEGLIERE LE COLONNE ------------------------

# select() serve a tenere solo alcune colonne

iris |> 
  select(Sepal.Length, Species)

iris[, c("Sepal.Length", "Species")]
iris[, c(1, 5) ]
# Posso cambiare l'ordine delle colonne

iris_mod <- iris %>%
  select(Species, Petal.Length, Sepal.Length)

# Posso selezionare un intervallo di colonne
iris %>%
  select(Sepal.Length:Petal.Width)

# Posso escludere colonne con il segno -
iris %>%
  select(-Species)

# Posso rinominare al volo
iris %>%
  select(specie = Species, petalo = Petal.Length)

iris |> 
  select(Species, everything())

### 6) FILTER(): FILTRARE LE RIGHE ---------------------------

# filter() serve a tenere solo le righe che rispettano una condizione

# Solo Setosa
iris %>%
  filter(Species == "setosa")

#iris[iris$Species == "setosa", ] versione con R base

# Petali lunghi
iris %>%
  filter(Petal.Length > 5)

# Due condizioni insieme: AND
iris %>%
  filter(Species == "virginica", Petal.Length > 5)

# Stessa cosa scritta in modo esplicito
iris %>%
  filter(Species == "virginica" & Petal.Length > 5)

# Condizione OR
iris %>%
  filter(Species == "setosa" | Species == "versicolor")

iris |> 
  filter(Species == "setosa" | Species == "versicolor") |> ### seleziono solo le specie che mi interessano
  filter(Petal.Length > 1.5) ### seleziono solo i petali maggiori di 1.5


# Posso combinare filter() e select()
iris_mod <- iris %>%
  filter(Petal.Length > 5) %>%
  select(Species, Petal.Length)


iris_f <- iris |> 
  filter(Petal.Length > 5) |> 
  select(Species, Petal.Length)

### 7) DIFFERENZA CON R BASE ---------------------------------

# In base R:
iris[iris$Petal.Length > 5, c("Species", "Petal.Length", "Petal.Width")]

# In tidyverse:
iris %>%
  filter(Petal.Length > 5) %>%
  select(Species, Petal.Length, Petal.Width)

# Il secondo approccio spesso è più leggibile,
# soprattutto quando le operazioni diventano tante.


### 8) ALCUNE REGOLE IMPORTANTI ------------------------------

# 1. select() lavora sulle colonne
# 2. filter() lavora sulle righe
# 3. == significa "uguale a"
# 4. >, <, >=, <= confrontano valori numerici
# 5. & significa AND
# 6. | significa OR


### 9) MINI ESEMPI RAPIDI -----------------------------------

# Tenere solo Species e Sepal.Width
iris %>%
  select(Species, Sepal.Width)

# Tenere solo i fiori con Sepal.Length maggiore di 7
iris %>%
  filter(Sepal.Length > 7)

# Tenere solo versicolor e vedere due colonne
iris %>%
  filter(Species == "versicolor") %>%
  select(Petal.Length, Petal.Width)

# Escludere la colonna Species
iris %>%
  select(-Species)


# Per vedere bene le variabili disponibili
glimpse(penguins)
data(penguins)
?glimpse ## ask for help

View(penguins)
head(penguins)
str(penguins)

############################################################
# ESERCIZI
############################################################

data("penguins")

### ESERCIZIO 1
# Seleziona solo le colonne:
# species, island, bill_length_mm, body_mass_g

penguins |> 
  select(species, island, bill_length_mm, body_mass_g)


### ESERCIZIO 2
# Mostra solo i pinguini dell'isola Dream
# e tieni solo le colonne species e sex

penguins |> 
  filter(island == "Dream") |> 
  select(species, sex)

# penguins |> 
#   select(species, sex) |> 
#   filter(island == "Dream") ### non funziona... perchè? 

# perché filter() cerca la colonna island che non c'è più dopo select()



### ESERCIZIO 3
# Mostra solo i pinguini con body_mass_g maggiore di 5000
# e tieni solo species, island e body_mass_g

penguins |> 
  filter(body_mass_g > 5000) |> 
  select(species, island, body_mass_g)


### ESERCIZIO 4
# Mostra solo i pinguini della specie Adelie
# che si trovano sull'isola Torgersen

penguins |> 
  filter(species == "Adelie", island == "Torgersen") |> 
  select(species, island)

### ESERCIZIO 5
# Mostra solo i pinguini che NON appartengono alla specie Adelie
# e tieni solo species, bill_length_mm e bill_depth_mm

penguins_mod <- penguins |> 
  filter(species != "Adelie") |> 
  select(species, bill_length_mm, bill_depth_mm) |> 
  mutate(species = droplevels(species))

# posso anche selezionare solo le specie che mi interessano invece di escludere Adelie
penguins |> 
  filter( species == "Gentoo" | species == "Chinstrap") 

# posso farlo anche con %in% che è più comodo quando le specie sono tante
# %in% è un operatore che verifica se un valore è presente in un vettore
penguins |> 
  filter(species %in%  c("Chinstrap", "Gentoo")) 

### ESERCIZIO 6
# Mostra solo i pinguini con flipper_length_mm > 200
# e body_mass_g < 5000


### ESERCIZIO 7
# Mostra solo i pinguini che appartengono
# alle specie Adelie oppure Gentoo
# e tieni solo species, island, body_mass_g


### ESERCIZIO 8
# Mostra solo i pinguini dell'isola Biscoe
# con body_mass_g > 4500
# e tieni solo species, island, body_mass_g, sex


### ESERCIZIO 9
# Seleziona tutte le colonne tranne year e sex
# poi filtra solo i pinguini della specie Chinstrap


### ESERCIZIO 10
# Mostra solo i pinguini con bill_length_mm > 45
# e flipper_length_mm > 210
# poi tieni solo species, bill_length_mm, flipper_length_mm


### ESERCIZIO 11
# Mostra solo i pinguini con sex mancante (NA)
# e tieni solo species, island, sex


### ESERCIZIO 12
# Mostra solo i pinguini con body_mass_g mancante (NA)
# oppure bill_length_mm mancante (NA)


### ESERCIZIO 13
# Mostra solo i pinguini che:
# - stanno su Dream oppure Torgersen
# - NON sono Gentoo
# poi tieni solo species, island, bill_length_mm


### ESERCIZIO 14
# Mostra solo i pinguini con:
# - body_mass_g compreso tra 4000 e 5000
# - flipper_length_mm maggiore di 190
# poi tieni solo species, island, flipper_length_mm, body_mass_g


### ESERCIZIO 15
# Mostra solo i pinguini che soddisfano una di queste due condizioni:
# - specie Gentoo e body_mass_g > 5500
# OPPURE
# - specie Adelie e flipper_length_mm < 190
# poi tieni solo species, island, flipper_length_mm, body_mass_g
