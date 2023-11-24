@ECHO off

git checkout Data/Scripts.rxdata

IF %1.==. GOTO No1
GOTO No2

:No1
git checkout kaividian-essentials
GOTO End1

:No2
git checkout %1

:End1
git pull
ruby scripts_combine.rb
game.rxproj