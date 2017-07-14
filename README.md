# EaseRedmine requirements check

Check destination system for (Easy)Redmine requirements.

Supported distributions:

  * Debian
  * Ubuntu
  * Centos
  * Fedora

## How to use ?

deploy the [easycheck.sh](https://raw.githubusercontent.com/easyredmine/easy_server_requirements_check/master/easycheck.sh) script to destination server somehow and run:

        sh ./easycheck.sh


[](https://raw.githubusercontent.com/easyredmine/easy_server_requirements_check/master/easycheck.png)

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
