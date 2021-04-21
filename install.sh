#!/usr/bin/bash


# Disabling yggdrasil in case it's already launched
check() {
    systemctl stop yggdrasil.service
    systemctl disable yggdrasil.service
}

# Installation
install() {
    # Add the repository
    gpg fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
    gpg export 569130E8CA20FBC4CB3FDE555898470A764B32C9 | apt-key add -
    printf 'deb http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' | tee /etc/apt/sources.list.d/yggdrasil.list
    
    # Refresh package lists and install
    apt update
    apt install yggdrasil -y
}

# Enable and start the service
service_on() {
    systemctl enable yggdrasil
    systemctl start yggdrasil
}

# Generating and writing new config file
configs() {
    printf "\n[ Generating new configs ]\n"

    yggdrasil -genconf -json > /etc/yggdrasil.conf
    systemctl reload yggdrasil
    systemctl restart yggdrasil
    
    printf "\n[ New configs generated, see below ]\n"

    cat /etc/yggdrasil.conf

    printf "\n\n" 
}

# Pull docker image from dockerhub
docker_node_pull() {   
    printf "\n[ Pulling docker image with emdedded yggdrasil ]\n"

    docker pull luzifer/yggdrasil

    printf "\n[ Docker image pulled ]\n"
}

# Launch the container
docker_node_launch() {
    docker run --rm -ti --net=host --cap-add=NET_ADMIN --device=/dev/net/tun -v $(pwd):/config luzifer/yggdrasil
}

# Separate different stages of the script
separate() {
    printf "\n#####################################################################################\n"
    printf "#####################################################################################\n"
    printf "#####################################################################################\n"
}

# Launching the complete process
printf "\n#####################################################################################\n"

printf "\n[ Disabling potentially pre-launched yggdrasil ]\n\n"
check
printf "\n[ Done ]\n"

separate

printf "\n[ Install start ]\n\n"
install
printf "\n[ Install complete ]\n"

separate

printf "\n[ Pull docker image with pre-installed yggdrasil? ] [ choose number ]\n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) docker_node_pull; break;;
        No ) printf "\n[ Docker image not pulled ]\n"; break;;
    esac
done

separate

printf "\n[ Launching the service ]\n\n"
service_on
printf "\n[ Service is up ]\n"

separate

printf "\n[ Generate new configs? ] [ choose number ]\n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) configs; break;;
        No ) printf "\n[ New configs not generated ]\n"; break;;
    esac
done

separate

if [[ "$(docker images -q luzifer/yggdrasil)" ]]; then
printf "\n[ Launch docker container? ] [ choose number ]\n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) docker_node_launch; break;;
        No ) printf "\n[ Container not launched ]\n"; break;;
    esac
done

else
printf "\n[ Docker image is not present, so no container is launched ]\n\n"
fi

separate


printf "\n[ All done ]\n\n"