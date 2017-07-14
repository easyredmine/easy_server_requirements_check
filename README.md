# EaseRedmine requirements check

Check destination system for (Easy)Redmine requirements.

## How to use ?

Run script directly from web:

    curl -sSL https://raw.githubusercontent.com/easyredmine/easy_server_requirements_check/master/easycheck.sh | bash -s

or deploy the (easycheck.sh) script somehow to destination server and run:

        sh ./easycheck.sh



## How to test ?

We use [vagrant](https://www.vagrantup.com/) In Vagrantfile you can change the linux distro tested.
On your machine run this commands:

```
vagrant ssh
sudo su
cd /vagrant/
./easycheck.sh
```
