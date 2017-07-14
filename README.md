# EaseRedmine requirements check

Check destination system for (Easy)Redmine requirements.

## How to use ?

Deploy the (checkreq.sh) script to destination server and run:

    sh ./checkreq.sh



## How to test ?

We use [vagrant](https://www.vagrantup.com/) In Vagrantfile you can change the linux distro tested on.

```
vagrant ssh
sudo su
cd /vagrant/
./checkreq.sh
```
