@echo off
sc stop farao
sc delete farao
sc create farao binPath= "C:\Ruby23-x64\bin\ruby C:\faraobot\farao_service.rb" type= own start= demand
sc start farao