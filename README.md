# EaseRedmine requirements check

Check destination system for (Easy)Redmine requirements.

Supported distributions:

  * Debian
  * Ubuntu
  * Centos
  * Fedora

What is checked ?

  * Root Access
  * Distro Type and Version
  * Curl tool presence
  * Availble RAM size
  * Availble Disk Space
  * Ruby language runtime presence and version
  * Conectivity to rubygems.org
  * Gem tool presence 
  * Bundler gem and command presence
  * compiler presence and version
  * mysql client development files
  * postgresql client presence
  * Imagick development files presence
  * RedmineInstaller tool presence


## How to use ?

deploy the [easycheck.sh](https://raw.githubusercontent.com/easyredmine/easy_server_requirements_check/master/easycheck.sh) script to destination server somehow and run:

        sh ./easycheck.sh


Here you can see the script in action:
![Screenshot](https://raw.githubusercontent.com/easyredmine/easy_server_requirements_check/master/easycheck.png)

## How to test ?

We use [vagrant](https://www.vagrantup.com/). In Vagrantfile you can change the linux distro tested.

On your machine please run this commands:

```
vagrant up
vagrant ssh
sudo su
cd /vagrant/
./easycheck.sh
```
