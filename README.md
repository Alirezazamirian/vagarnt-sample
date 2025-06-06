## Vgarant sample config for deploying various OS
The project currently is on Dev mode but can be used hence.

## Installation
First of all install vagrant compatible with your OS using the link below :

https://developer.hashicorp.com/vagrant/downloads

## Usage
1.change the setting.yaml file as you wish located at each dir.

2.use the command ``` vagrant up ``` where the Vagarant file is located.

## NOTE
#### Tested with Vagrant version 2.4.2
if vagrant faced with conflicting packages of Ruby, needs to do the following action :

set the variable : VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1
then install the plugins using the command ``` vagrant plugin install <plugin-name> ```.

