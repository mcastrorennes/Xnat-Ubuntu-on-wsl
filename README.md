# Xnat Ubuntu on WSL

Use this repository to quickly deploy an [XNAT](https://xnat.org/) instance on [docker](https://www.docker.com/).

Ir's based on [Adrian Pfleiderer's projet Xnat-ubuntu](hhttps://github.com/Pfleiderer-Adrian/Xnat-Ubuntu) which itself was a modified dockerized XNAT version from the [official dockerized XNAT Git-Repo](http://github.com/NrgXnat/xnat-docker-compose) with the following changes.

* this Xnat is modified and optimized for Ubuntu
* simple installation Script (work out of the box)
* installed OHIF Viewer & LDAP Plugin
* installed Docker-Pipeline-Engine
* installed Container Plugin + Workaround
* fixed Processing URL BUG
* some specific Ubuntu changes
* APItest Script and TestPipeline
* Access a web server which is running on WSL (Windows Subsystem for Linux) from the local network

This document contains the following sections:

* [System Overview](#markdown-header-System-Overview)
* [Prerequisites](#markdown-header-prerequisites)
* [Usage](#markdown-header-usage)
* [Enable WSL](#markdown-Enable-WSL)
* [Forward ports into WSL](#markdown-Forward-ports-into-WSL)
* [Configuration to access the web server from the local network](#markdown-Configuration-to-access-the-web-server-from-the-local-network)
* [Necessary Configurations](#markdown-Necessary-Configurations)
* [Environment variables](#markdown-header-environment-variables)
* [Start the system](#markdown-start-the-system)
* [Folder Overview](#markdown-header-Folder-Overview)
* [Pipeline Configurations](#markdown-Pipeline-Configurations)
* [Add a Pipeline to your XNAT System](#markdown-Add-a-Pipeline-to-your-XNAT-System)
* [Notes on using the Container Service](#markdown-header-notes-on-using-the-container-service)


## System Overview
A short environment overview with the different docker container and subsystems.

<img src="Images/ProjectOverviewXNAT.jpg" alt="HTML ERROR" width="500" height="300">

This repository contains files to bootstrap XNAT deployment. The build creates three containers:

- **[Tomcat](http://tomcat.apache.org/) + XNAT**: The XNAT web application
- [**Postgres**](https://www.postgresql.org/): The XNAT database
- [**nginx**](https://www.nginx.com/): Web proxy sitting in front of XNAT
  
## Prerequisites
* Windows Subsystem for Linux (WSL)
* Ubuntu 22.04.2 LTS release [download from Microsoft store](https://www.microsoft.com/p/ubuntu/9pdxgncfsczv)
  
Ubuntu on Windows is a variant of Ubuntu officially offered by Microsoft and Canonical, and which is deployed natively on Windows 10 or Windows 11 using the WSL subsystem.

## Usage
* Install Ubuntu on WSL on Windows 10\
In the ubuntu terminal: 
* download the installScript.sh file
* copy the file to your Ubuntu Server in your root directory (Command: cd /)
* execute the file with the command: sudo bash installScript.sh
* after the installation and several minutes, look at your URL http://127.0.0.1/
* now make the necessary configuration to access the web server from the local network
* now make the necessary configuration (processing url & admin password change)

## Enable WSL
Enable the WSL (Windows Subsystem for Linux) option in Windows Optional Features panel. Open PowerShell as Administrator and run:

```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

## Forward ports into WSL
Now, from an **Administrator Windows prompt** - that can be **cmd.exe** or **powershell.exe**, it doesn't matter, use the net shell "netsh" to add a portproxy rule. Again, change connectaddress to YOUR WSL2 ipaddress, which is an internal address to your machine.

```
New-NetFireWallRule -DisplayName 'WSL' -Direction Inbound -LocalPort "80" -Action Allow -Protocol TCP

New-NetFireWallRule -DisplayName 'WSL' -Direction Outbound -LocalPort "80" -Action Allow -Protocol TCP
```

## Configuration to access the web server from the local network
* check the ip of your ubuntu terminal
```
$ ip add | grep "eth0"
```
In my cese the reponse is 129.20.25.15

* Open PowerShell as Administrator and run:

```
> netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=443 connectaddress=172.29.34.5
```

Now you can access the web server from the local network, in my case http://129.20.25.15

## Necessary Configurations
* first change your admin password (default credentials -> Name: admin, PW: admin)
* change processing url to your side url under Administer -> Site Administration -> Pipeline Settings -> Processing Url
* change the side url to your side url under Administer -> Site Administration -> Site Setup -> Site Url

The default configuration is sufficient to run the deployment. The following files can be modified if you want to change the default configuration

  - **docker-compose.yml**: How the different containers are deployed. There is a section of build arguments (under `services → xnat-web → build → args`) to control some aspects of the build.
        * If you want to download a different version of XNAT, you can change the `XNAT_VERSION` variable to some other release.
        * The `TOMCAT_XNAT_FOLDER` build argument is set to `ROOT` by default; this means the XNAT will be available at `http://localhost`. If, instead, you wish it to be at `http://localhost/xnat` or, more generally, at `http://localhost/{something}`, you can set `TOMCAT_XNAT_FOLDER` to the value `something`.
        * If you need to control some arguments that get sent to tomcat on startup, you can modify the `CATALINA_OPTS` environment variable (under `services → xnat-web → environment`).
    - **xnat/Dockerfile**: Builds the xnat-web image from a tomcat docker image.


## Start the system
```
~/Xnat-Ubuntu$ sudo docker-compose up -d
```
(more information on: https://github.com/NrgXnat/xnat-docker-compose)

## Folder Overview
When you bring up XNAT with `docker-compose up`, several directories are created (if they don't exist already) to store the persistent data.

* **postgres-data** - Contains the XNAT database
* **xnat/plugins** - Initially contains nothing. However, you can customize your XNAT with plugins by placing jars into this directory and restarting XNAT.
* **xnat-data/archive** - Contains the XNAT archive
* **xnat-data/build** - Contains the XNAT build space. This is useful when running the container service plugin.
* **xnat-data/home/logs** - Contains the XNAT logs.

## Pipeline Configurations
### Add "Execute Pipeline"-Button on Options Menu in SessionData
* navigate: Administer -> Data Types -> 
* choose SessionData Element witch should have Execute option
* click on the Element and on Edit-Button
* scroll down to "Available Report Actions"
* one the last entry in this table write: Name->PipelineScreen_launch_pipeline, Display Name->Build, Secure Access->edit
* scroll down again and click on the "Submit"-Button

Now should appear a "Execute Pipeline"-Button when you open a Project with the specific SessionData Element. There you can execute a Pipeline for the Project Data if you have added a Pipeline.

### Add a Pipeline to your XNAT System
You can add a Sample Pipeline that is already installed with this installation.
* navigate: Administer -> Pipeline -> Add Pipeline
* choose the path: /data/xnat/pipeline/catalog/PipelineTest/SampleHelloWorldPipeline.xml
* Importend!! leave the Name Textfield empty. A Bug will accur with you choose a spezific name. 
* after confirm your settings you can add this pipeline to your project and test the pipeline engine

### Container Service
With this installation you can also add docker container as pipelines. Here a short example how it works with a external docker environment.

<img src="Images/ContainerServiceXNAT.jpg" alt="HTML ERROR" width="500" height="300">


## Special mention
* Sourcefiles from offical XNAT Repo: [github.com/NrgXnat/xnat-docker-compose](http://github.com/NrgXnat/xnat-docker-compose)  [@johnflavin](http://github.com/johnflavin)
* Fork for [Adrian Pfleiderer's projet Xnat-ubuntu](hhttps://github.com/Pfleiderer-Adrian/Xnat-Ubuntu)
