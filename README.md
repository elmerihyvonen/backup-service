# Backup-kontti

* Tietokantojen varmuuskopiointia varten toteutettu docker kontti, joka suorittaa samassa verkossa (backup bridge) olevien mirth konttien varmuuskopioinnin ajastetusti Cron Job:ina. 
* Kontti alustaa käynnistyessään varmuuskopioinnissa tarvittavat yhteydet aws_config.txt ja mysql_config.txt tiedostojen perusteella.

### MySQL tietokannat

* Kantojen dumppaaminen edellyttää, että tietokannat ovat samassa docker network:issä. mysqldump komennon --host parametrina voidaan käyttää docker networkin ip-osoitetta tai network aliasta (esim. servicen nimeä mirthdb tai db).
* Varmuuskopioitavien tietokantojen login-path tiedot (host, user, password) annetaan backup-kontille .csv tiedostona josta luodaan kontille docker secret.
* Backup konttiin luodaan Cron scheduled job, joka suorittaa halutulla ajastuksella mysql_config.txt tiedostossa listattujen kantojen varmuuskopionnin. Käytännössä tämä tapahtuu suorittamalla dump.sh skriptiä, joka suorittaa mysqldump komennon kannoille. 
* Dumpin perään suoritetaan automaattisesti backup/ volumeen muodostuneiden .sql tiedostojen tar paketointi volumeen tar/ ja tämän jälkeen siirto Contabo S3 Object Storageen. Siirto tehdään aws s3 move komennolla iteroimalla tar/ kansion tiedostot silmukassa läpi.

### home/docker-user .yml + .env tiedostojen varmuuskopiointi

* .yml + .env tiedostojen varmuuskopiointi suoritetaan erillisillä konttipalvelimelle ajastettavilla skripteillä. Skriptit on toteutettu valmiiksi ja ne löytyvät YML-ENV-Scripts/ hakemistosta. 
* Skripti etsii /home/docker-user/ alta *.yml ja .env tiedostoja ja mikäli niitä löytyy niin luodaan tar pallo joka nimetään <hakemiston_nimi_docker-userin_alla>.<timestamp>.tar .
* tar pallot luodaan backup kontille mountattuun tar/ volumeen jolloin ne päätyvät samaan paikkaan kuin tietokantojen dumpeista luodut tar pallot. Kaikki varmuuskopiot siirtyvät object storageen cronin ajaessa tietokantojen varmuuskopiot.

### SETUP

1. Kloonaa repo ympäristöösi.
2. Siirrä YML-ENV-Scripts/ skriptit kotihakemistoosi ympäristössä.
3. Luo kotihakemistoosi kansio aws_config.txt ja mysql_config.txt tiedostoille. Docker secretit määritetään composessa näiden tiedostojen perusteella. Katso esimerkki tiedostoista secrettest/aws_config.txt ja secrettest/mysql_config.txt. Määritä tiedostoihin siis haluttu contabo s3 object storage ja dumpattavien kantojen tiedot. 
4. Koita nostaa backup kontti pystyyn: 
```Shell
sudo docker-compose up --build
```
5. Mikäli kontti käynnistyi tarkista muodostuiko backup-bridge verkko ja ovatko kontit tuossa verkossa: 
```Shell
sudo docker network ls
sudo docker network inspect backup-bridge
```
6. Mikäli kontit ovat tuossa verkossa ja compose tiedoston service-namet näkyvät listauksessa network aliaksina pitäisi dumpit onnistua verkon yli kontin nimellä:

```
elmeri@Contabo4:~/db-backupcontainer$ sudo docker network inspect backup-bridge
[
    {
        "Name": "backup-bridge",
        "Id": "462224264c7040d20e6e22b0bc11aa03383ab493f76f65fe6f01789452b71c                                       f0",
        "Created": "2022-07-18T13:29:35.271548181+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.21.0.0/16",
                    "Gateway": "172.21.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "99970efe8eb839f0a4be2196e40628e40e6f8d58e3b8522a859de5c35f63d4df": {
                "Name": "db_testi_mysql",
                "EndpointID": "b15522463f1e9b886fc3a6cfe5c948a20c3f414dc0de81                                       a023d4bd265b912280",
                "MacAddress": "02:42:ac:15:00:03",
                "IPv4Address": "172.21.0.3/16",
                "IPv6Address": ""
            },
            "d0536ccfebb5efbf57243a3ebd9d395a3e75be4f3a853efe867b81ec12467a85": {
                "Name": "backup",
                "EndpointID": "81eb205c70b07f93881b4b5ed5b66bba6b70c4736f50bd                                       decefa5ccfec90f1b7",
                "MacAddress": "02:42:ac:15:00:04",
                "IPv4Address": "172.21.0.4/16",
                "IPv6Address": ""
            },
            "dd3f1aa38e58d89b4d50a64324c1b9499ff49d1c0cbcc9d4feccb95af7f6ea10": {
                "Name": "mirthdb_mysql",
                "EndpointID": "470b9d65a564ced1c1636e3727c16e4656810090708bf5                                       c1cc6730d393b28343",
                "MacAddress": "02:42:ac:15:00:02",
                "IPv4Address": "172.21.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "backup-bridge",
            "com.docker.compose.project": "mirthdb",
            "com.docker.compose.version": "1.25.0"
        }
    }
]
```

8. Huomioithan myös, että kannat jotka haluat varmuuskopioitavaksi tulee liittää samaan verkkoon backup kontin kanssa. Onnistuu esimerkiksi composesta:

```YAML
networks:
  default:
    name: backup-bridge
```

9. Ja kantoihin pitää luoda mysql_config.txt tiedostoissa annetut käyttäjät:

```SQL
CREATE USER 'testuser'@'%' IDENTIFIED BY 'password';
GRANT ALL ON *.* TO 'testuser'@'%';
FLUSH PRIVILEGES;
```"# backup-service" 
