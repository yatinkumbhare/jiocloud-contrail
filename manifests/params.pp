class contrail::params {
  $package_ensure = present
  $contrail_dep_packages = ['binutils','libdpkg-perl', 'make', 'patch', 'python-pip', 'python-pkg-resources', 'python-setuptools', 'libexpat1','python-crypto','python-netaddr','python-paramiko','contrail-fabric-utils']
}
