# == Class: contrail::install
#
# Install contrail packages
#
# === Parameters
#
# [*contrail_repo_type*]
#   Type of repos to be used - valid params - 
#    - contrail-ubuntu-package - destribute all packages as an ubuntu deb
#    - contrail-centos-repo
#    - contrail-ubuntu-storage-repo
#    - apt-repo
#
# [*package_ensure*]
#    Defaults to $contrail::params::package_ensure.
#
# === Examples
#
#  class { contrail::install
#    contrail_repo_type => 'apt-repo',
#  }
#
# === Authors
#
# Harish Kumar <hkumarmk@gmail.com>
#
# === Copyright
#
# Apache License, unless otherwise noted.
#

class contrail::install (
  $contrail_repo_type,
  $package_ensure = $contrail::params::package_ensure,
  $contrail_dep_packages = $contrail::params::contrail_dep_packages,
) inherits contrail::params {
  if($contrail_repo_type == "contrail-ubuntu-package") {
    $setup_script =  "./setup.sh && echo exec-contrail-setup-$contrail_repo_type-sh >> exec-contrail-setup-sh.out"
    $contrail_install_package_name = "contrail-install-packages"
  } elsif ($contrail_repo_type == "contrail-centos-repo") {
    $setup_script =  "./setup.sh && echo exec-contrail-setup-$contrail_repo_type-sh >> exec-contrail-setup-sh.out"
    $contrail_install_package_name = "contrail-install-packages"
  } elsif ($contrail_repo_type == "contrail-ubuntu-stroage-repo") {
    $setup_script =  "./setup_storage.sh && echo exec-contrail-setup-$contrail_repo_type-sh >> exec-contrail-setup-sh.out"
    $contrail_install_package_name = "contrail-storage"
  } elsif ($contrail_repo_type == 'apt-repo') {
    $contrail_install_package_name = undef
  }

  if $contrail_install_package_name {
    package {$contrail_install_package_name: 
      ensure => $package_ensure,
    }
  }
  
  if $contrail_repo_type == 'contrail-ubuntu-package' {
    ## Create directory structure
    $dirs =  ['/opt/contrail/contrail_install_repo','/opt/contrail/bin']
    file {$dirs:
      ensure 	=> directory,
      owner     => root,
      group     => root,
      mode      => 755,  
      require   => Package[$contrail_install_package_name],
    }
    
    ## Extract contrail packages to above set directory
    exec {'extract_contrail_pkgs_to_repo':
      command 	=> "tar zxf /opt/contrail/contrail_packages/contrail_packages.tgz",
      cwd 	=> '/opt/contrail/contrail_install_repo',
      subscribe   => Package[$contrail_install_package_name],
      refreshonly => true,
    }
    
    ## Install basic packages required to setup repo
#    $basic_contrail_packages = [ 'binutils_2.22-6ubuntu1.1_amd64.deb', 'dpkg-dev_1.16.1.2ubuntu7.2_all.deb', 'libdpkg-perl_1.16.1.2ubuntu7.2_all.deb', 'make_3.81-8.1ubuntu1.1_amd64.deb', 'patch_2.6.1-3_amd64.deb', 'python-pip_1.0-1build1_all.deb', 'python-pkg-resources_0.6.24-1ubuntu1_all.deb', 'python-setuptools_0.6.24-1ubuntu1_all.deb', 'libexpat1_2.1.0-4_amd64.deb' ]
    package {'dpkg-dev':
      ensure 	=> $package_ensure,   
    }

    ## Prepare local repo
    exec { 'prepare_local_repo': 
      command 	  => 'dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz',
      refreshonly => true,
      cwd         => '/opt/contrail/contrail_install_repo',
      subscribe   => Package[$contrail_install_package_name],
      require 	  => package['dpkg-dev']
    }

    ## Remove existing apt source files
    exec { 'rm_existing_apt_source':
      command => 'echo > /etc/apt/sources.list; rm -f /etc/apt/sources.list.d/*',
      refreshonly => true,
      subscribe   => Package[$contrail_install_package_name],
    }

    ## Setup local repository in apt-source.
    ::apt::source { contrail:
      location 	  => 'file:/opt/contrail/contrail_install_repo',
      repos 	  => './',
      include_src => false,
      release 	  => ' ',
    }	
    
    ## Install base contrail dependancy packages
    package {$contrail_dep_packages:
      ensure => $package_ensure,
    }

    ## Preseed java installation
    ## FIXME:Need to search for a way prefreably using puppet package to preseed a package installation.
    exec {'preseed_apt_source':
      command => "echo 'sun-java6-plugin shared/accepted-sun-dlj-v1-1 boolean true' | /usr/bin/debconf-set-selections; echo 'sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true' | /usr/bin/debconf-set-selections; echo 'sun-java6-jre shared/accepted-sun-dlj-v1-1 boolean true' | /usr/bin/debconf-set-selections",
      unless   => 'debconf-get-selections  | grep -P "sun-java6-plugin[\s\t]*shared/accepted-sun-dlj-v1-1[\s\t]*boolean[\s\t]*true"',	
    }

    
  }
  

#  exec { "exec-contrail-setup-$contrail_repo_type-sh" :
#    command => $setup_script,
#    cwd => "/opt/contrail/contrail_packages",
#    require => Package[$package_name],
#    unless  => "grep -qx exec-contrail-setup-$contrail_repo_type-sh /opt/contrail/contrail_packages/exec-contrail-setup-sh.out",
#    provider => shell,
#    logoutput => "true"
#  }



}
