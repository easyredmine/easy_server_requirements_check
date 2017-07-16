# EaseRedmine requirements check

Bash shell script that Check destination system for (Easy)Redmine requirements.

### Supported distributions:

  * [Debian](https://www.debian.org/)
  * [Ubuntu](https://www.ubuntu.com/)
  * [Centos](https://www.centos.org/) & [RedHat](https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux)
  * [Fedora](https://getfedora.org/)
  
    > Please feel free to send us pull request for another distribution (Suse, Arch, Windows etc.  would be nice ;)


### What is checked ?

  * [Root Access](http://www.linfo.org/root.html)
  * [Distro Type and Version](https://en.wikipedia.org/wiki/Linux_distribution)
  * [Curl tool](https://curl.haxx.se/) presence
  * Availble RAM size
  * Availble Disk Space
  * [Ruby language](https://www.ruby-lang.org) runtime presence and version
  * Conectivity to [rubygems.org](http://rubygems.org)
  * [Gem tool](http://guides.rubygems.org/command-reference/#gem-install) presence 
  * [Bundler gem and command](http://bundler.io/) presence
  * [compiler](https://gcc.gnu.org/) presence and version
  * [mysql client](https://dev.mysql.com/doc/refman/5.7/en/c-api.html) development files
  * [postgresql client](https://www.postgresql.org/docs/9.3/static/app-psql.html) presence
  * [Imagick](https://www.imagemagick.org) development files presence
  * [Redmine-Installer](https://github.com/easyredmine/redmine-installer) tool presence


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
