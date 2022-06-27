# Kaividian's Pokémon Essentials

A modified version of Essentials v21.1.

This version of Essentials is modified and maintained by Kaividian for use in his and and his friends unified fan-game projects.

### Extracting and reintegrating scripts

This repo contains two script files in the main folder:

* scripts_extract.rb - Run this to extract all scripts from Scripts.rxdata into individual .rb files (any existing individual .rb files are deleted).
  * Scripts.rxdata is backed up to ScriptsBackup.rxdata, and is then replaced with a version that reads the individual .rb files and does nothing else.
* scripts_combine.rb - Run this to reintegrate all the individual .rb files back into Scripts.rxdata.
  * The individual .rb files are left where they are, but they no longer do anything.

You will need Ruby installed to run these scripts. The intention is to replace these with something more user-friendly.

## Files not in the repo

The .gitignore file lists the files that will not be included in this repo. These are:

* The Audio/, Graphics/ and Plugins/ folders and everything in them.
* Everything in the Data/ folder, except for:
  * The Data/Scripts/ folder and everything in there.
  * Scripts.rxdata (a special version that just loads the individual script files).
  * messages_core.dat, which contains common messages and is useful for translation projects.
* A few files in the main project folder (two of the Game.xxx files, and the RGSS dll file).
* Temporary files.
