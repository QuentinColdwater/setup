set -ex
ufw enable # Turn on firewall
# Point to a fast ubuntu package repository
cat > /etc/apt/sources.list <<EOF
deb http://mirrors.tripadvisor.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.tripadvisor.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.tripadvisor.com/ubuntu/ xenial-backports main restricted universe multiverse
deb http://mirrors.tripadvisor.com/ubuntu/ xenial-security main restricted universe multiverse
EOF
apt-get update && apt-get -y upgrade
apt-get install -y chromium emacs git subversion jq nmap \
	# For docker install
	apt-transport-https ca-certificates \
	virtualbox apparmor-profiles apparmor-utils \
	# For dockerized vnc
	vinagre
# Lock down virtualbox.  Docker is apparmored by default.
cp virtualbox.apparmor /etc/apparmor.d/virtualbox
apparmor_parser /etc/apparmor.d/virtualbox
# Install docker
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys \
             58118E89F3A912897C070ADBF76221572C52609D
dapt=/etc/apt/sources.list.d/docker.list
rm -f $dapt
echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > $dapt
apt-get update && apt-get install -y docker.io
service docker stop # Stop local service -- essentially provides root access.
echo manual > /etc/init/docker.override # Stop on future boots, too.
# Get docker-machine.  If you change version, change sha256 digest, too.
machine_url=https://github.com/docker/machine/releases/download/v0.7.0
sha256sum=21e490d5cdfa0d21e543e06b73180614f72e6c18a940f476a64cf084cea23aa5
machine_url=${machine_url}/docker-machine-`uname -s`-`uname -m`
machine_target=/usr/local/bin/docker-machine
curl -L $machine_url > $machine_target 
if [ -z "`sha256sum $machine_target | grep $sha256sum`" ] ; then
    echo 'Bad checksum on docker-machine.  Moving to /tmp'
    mv $machine_target /tmp
    exit 1
fi
chmod +x $machine_target
machine_status="`docker-machine ls | grep '^default '`"
if [ -z $machine_status ] ; then
    # There's no local docker-machine box, yet... make one
    docker-machine create --driver virtualbox default
fi
if [ -z "`echo $machine_status | grep Running`" ] ; then
    docker-machine start
fi
