# ============================================================
# Git + GitHub da R/RStudio 
# ============================================================

# Inizializzare git nella cartella locale
# system("git init")

# 1) dire a Git chi sei (nome + email) -> serve per firmare/attribuire i commit
# 2) verificare che la configurazione sia stata salvata
# 3) creare un GitHub token (PAT) -> serve per autenticarsi su GitHub (push/pull)
# 4) salvare il token in modo sicuro sul computer (così non lo reinserisci ogni volta)
#
# Nota:
# - Esegui queste righe nella Console di RStudio (o in R).
# - Se sei su Windows e Git non è nel PATH, vedi la sezione "Windows users" più sotto.
# ============================================================




# --- 1) Imposta l'email usata da Git per i commit (metti la TUA email) ---
system('git config --global user.email "Your@Email.com"')

# --- 2) Imposta il nome usato da Git per i commit (metti il TUO nome e cognome) ---
system('git config --global user.name "YourName"')

# --- 3) Controlla che Git abbia salvato le impostazioni globali ---
# (stampa la lista delle configurazioni globali; cerca user.name e user.email)
system("git config --global --list")


# ============================================================
# Windows users (solo se i comandi sopra NON funzionano)
# ============================================================
# Problema tipico: R non trova "git" perché Git non è nel PATH di sistema.
# Soluzione: specifichiamo il percorso completo di git.exe e lo usiamo nei comandi.

# Esempio di percorso standard (può variare!):
# git <- '"C:/Program Files/Git/cmd/git.exe"'

# Imposta email:
# system(paste(git, 'config --global user.email "Your@Email.com"'))

# Imposta nome:
# system(paste(git, 'config --global user.name "YourName"'))

# Verifica:
# system(paste(git, "config --global --list"))


# ============================================================
# GitHub Token (PAT) + salvataggio credenziali
# ============================================================
# Per fare push/pull su GitHub NON si usa più la password dell’account.
# Si usa un Personal Access Token (PAT): una “password” generata da GitHub.
# se non funziona installare prima i pacchetti usethis e gitcreds:
# installa i pacchetti necessari (una sola volta)
# install.packages(c("usethis","gitcreds"))
# --- 4) Apri nel browser la pagina di GitHub per creare un token ---
# (ti si apre GitHub: crea un token, copialo subito perché poi non verrà mostrato di nuovo)
usethis::create_github_token()

# --- 5) Salva il token nel credential manager usato da Git sul tuo computer ---
# (quando chiede "Enter password or token:", incolla il token e premi invio)
gitcreds::gitcreds_set()


# --- 6)  Creare una repository su GitHub ---

# --- 7)  Collegare il repository locale al repository GitHub ---
usethis::use_git_config(user.name = "YourName", user.email = "youremail")

system("git remote add origin https://github.com/STUDENTE/nomecartella.git")

usethis::use_git_remote(name = "origin", url = "https://github.com/STUDENTE/nomecartella.git")

# Controlliamo che il collegamento esista

system("git remote -v")

# --- 8)  Collegare il repository deocente come upstream al proprio repository GitHub ---

system("git remote add upstream https://github.com/micdimu/DataManCons.git")

# Verifica dei remote

system("git remote -v")

# Ora dovrebbero comparire:
# origin    -> repository dello studente
# upstream  -> repository del docente


# --- 9)  Scaricare i contenuti dal repository del docente ---

system("git fetch upstream")

# Questo scarica i commit ma non modifica ancora i file

# --- 10)  Unire i file docente con i propri ---

system("git merge upstream/main")

# Ora i file del corso sono presenti nella cartella locale

# Controllare lo stato del repository

system("git status")

# --- 11)  RECAP ---

# Ogni volta che modifichiamo uno script R dobbiamo salvare
# le modifiche nel repository Git e poi inviarle su GitHub.
#
# Il flusso standard è sempre lo stesso:
#
# 1) STATUS  -> controllare cosa è cambiato
# 2) ADD     -> scegliere quali file vogliamo salvare
# 3) COMMIT  -> creare una "versione" del progetto
# 4) PUSH    -> inviare le modifiche su GitHub


### 1) CONTROLLARE COSA È CAMBIATO --------------------------

# Mostra i file modificati o nuovi nella cartella
system("git status")

# Questo passaggio è importante per evitare di caricare
# file non desiderati (dataset, file temporanei, ecc.)


### 2) AGGIUNGERE I FILE CHE VOGLIAMO SALVARE ----------------

# È buona pratica aggiungere solo i file di codice modificati

system("git add script_analisi.R")

# In alternativa possiamo aggiungere più file
# system("git add script_analisi.R grafico.R")


### 3) CREARE UN COMMIT -------------------------------------

# Il commit crea una nuova versione salvata del progetto
# Il messaggio deve spiegare cosa è stato modificato

system('git commit -m "nomescript.R"')


### 4) INVIARE LE MODIFICHE SU GITHUB -----------------------

# Questo comando invia il commit al repository GitHub

system("git push origin main")


############################################################
# RIASSUNTO DEL WORKFLOW
#
# modifico file
#       ↓
# git status
#       ↓
# git add script.R
#       ↓
# git commit -m "descrizione modifiche"
#       ↓
# git push origin main
#
############################################################


############################################################
# NOTA IMPORTANTE: perché evitare "git add ."
############################################################

# Il comando
# git add .
#
# aggiunge ALLA STAGING AREA tutti i file nuovi o modificati
# presenti nella cartella del progetto.
#
# Questo può essere rischioso perché può includere:
# - dataset di grandi dimensioni
# - file temporanei (.RData, .Rhistory)
# - file di output (figure, tabelle, risultati)
# - file di sistema di RStudio (.Rproj.user)
#
# Questi file non dovrebbero normalmente essere versionati
# su GitHub, perché Git è pensato principalmente per il CODICE,
# non per archiviare grandi quantità di dati.

# Per questo motivo è buona pratica:

# 1) controllare sempre prima lo stato del repository
system("git status")

# 2) aggiungere esplicitamente solo i file di codice necessari
# system("git add script_analisi.R")

# Il comando "git add ." può essere usato in sicurezza
# SOLO se è presente un file .gitignore configurato correttamente,
# che esclude file e cartelle non desiderati (dati, output, ecc.).

# Esempi comuni di file da ignorare in progetti R:
# .Rhistory
# .RData
# .Rproj.user/
# data/
# output/
# *.csv
# *.xlsx
# *.rds

# In sintesi:
# usare sempre "git status" per controllare i file
# e aggiungere solo ciò che vogliamo davvero tracciare.
############################################################

############################################################
# COME CREARE E CONFIGURARE UN FILE .gitignore
############################################################

# Il file .gitignore dice a Git quali file NON devono essere
# tracciati e quindi NON devono essere caricati su GitHub.

# 1) Creiamo un file chiamato ".gitignore" nella cartella del progetto

file.create(".gitignore")


# 2) Scriviamo dentro alcune regole comuni per progetti R

writeLines(c(
  ".Rhistory",
  ".RData",
  ".Rproj.user/",
  "data/",
  "output/",
  "*.csv",
  "*.xlsx",
  "*.rds"
), ".gitignore")


# 3) Controlliamo il contenuto del file

readLines(".gitignore")


# Ora Git ignorerà automaticamente questi file/cartelle,
# anche se usiamo "git add ."


############################################################
# NOTA IMPORTANTE
#
# Il file .gitignore deve essere creato PRIMA di fare git add .
# altrimenti Git potrebbe aver già tracciato quei file.
############################################################
