# Backup service

![Architecture](https://github.com/elmerihyvonen/ImageService/blob/IS2/IS2.png?raw=true)
Kokonaiskuva projektista [IS2](https://github.com/elmerihyvonen/ImageService/tree/IS2). Havainnollistaa samalla backup servicen toimintaa.



* Tietokantojen varmuuskopiointia varten toteutettu docker image (mysql-8:debian), joka suorittaa samassa docker verkossa (backup bridge) olevien tietokantojen varmuuskopioinnin ajastetusti Linux Cron Job:ina. 
* Kontti hakee käynnistyessään tarvittavat konffat aws_config.txt ja mysql_config.txt (Docker secrets)
* mysqldump komennon --host parametrina voidaan käyttää docker networkin ip-osoitetta tai network aliasta (esim. servicen nimeä db)
* Konttiin luodaan Cron scheduled job, joka suorittaa halutulla ajastuksella mysql_config.txt tiedostossa listattujen kantojen varmuuskopionnin. Käytännössä tämä tapahtuu suorittamalla dump.sh skriptiä. 
* Skriptin perään suoritetaan automaattisesti /backup volumeen muodostuneiden .sql tiedostojen tar-paketointi volumeen /tar
* Tarball siirretään varmuuskopioinnin valmistuttua Object Storageen (Contabo - S3 compatible)

### SETUP

1. Kloonaa repo ympäristöösi.
2. Rakenna docker image
```Shell
cd context/
sudo docker image build .
```
3. Määritä object storage ja varmuuskopioitavat MySQL-kannat. Luo tiedostot: secrettest/aws_config.txt (AWS Access Key, AWS Secret Access Key) ja secrettest/mysql_config.txt (host,user,pass\n). 
4. Voit muuttaa varmuuskopioinnin ajastusta: /context/dumpcron (0 0 * * 3,6 root /opt/dump.sh)
5. Koita nostaa kontti pystyyn: 
```Shell
sudo docker-compose up --build
```
6. Mikäli kontti käynnistyi tarkista muodostuiko backup-bridge verkko 
```Shell
sudo docker network ls
sudo docker network inspect backup-bridge
```
7. Liitä mysql-kontit backup-bridge verkkoon
```Shell
sudo docker network connect backup-bridge CONTAINER
```

