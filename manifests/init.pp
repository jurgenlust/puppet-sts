# Class: sts
#
# This module manages SpringSource Tool Suite
#
class sts {
	$sts_version = "2.9.2"
	$eclipse_release = "3.7"
	$eclipse_version = "${eclipse_release}.2"
	$sts_tarball = "/tmp/sts-${sts_version}.tar.gz"
	$flavor = $architecture ? {
		"amd64" => "-x86_64",
		default => "" 
	}
	$sts_install = "/opt"
	$sts_home = "${sts_install}/springsource/sts-${sts_version}.RELEASE"
	$sts_url = "http://download.springsource.com/release/STS/${sts_version}/dist/e${eclipse_release}/springsource-tool-suite-${sts_version}.RELEASE-e${eclipse_version}-linux-gtk${flavor}.tar.gz"
	$sts_symlink = "${sts_install}/sts"
	$sts_executable = "${sts_symlink}/STS"
	
	exec { "download-sts":
		command => "/usr/bin/wget -O ${sts_tarball} ${sts_url}",
		require => Package["wget"],
		creates => $sts_tarball,
		timeout => 1200,	
	}
	
	file { "${sts_tarball}" :
		require => Exec["download-sts"],
		ensure => file,
	}
	
	exec { "install-sts" :
		require => File["${sts_tarball}"],
		cwd => $sts_install,
		command => "/bin/tar -xa -f ${sts_tarball}",
		creates => $sts_home,
	}
	
	file { $sts_home :
		ensure => directory,
		require => Exec["install-sts"],
	}

	file { $sts_symlink :
		ensure => link,
		target => $sts_home,
		require => File[$sts_home],
	}
	
	file { "/usr/share/icons/sts.xpm":
		ensure => link,
		target => "${sts_home}/icon.xpm",
		require => File[$sts_home],	
	}
	
	file { "/usr/share/applications/sts.desktop" :
		require => File[$sts_symlink],
		content => template('workstation/sts.desktop.erb'),
	}	


}
