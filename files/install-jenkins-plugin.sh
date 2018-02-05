#!/usr/bin/env sh

function install_plugin {
	download_plugin "$1" "$2"
	resolve_dependencies "$1"
}

function download_plugin {
	echo "Downloading $1 @ $2"

	local url=https://updates.jenkins.io/download/plugins/"$1"/"$2"/"$1".hpi
	if test x"$2" == "latest"
	then
		url=https://updates.jenkins.io/latest/"$1".hpi
	fi

	if ! curl -fsSL "$url" > /var/lib/jenkins/plugins/"$1".jpi
	then
		echo "Failed to download $1"
	fi
}

function resolve_dependencies {
	for f in $(unzip -p "/var/lib/jenkins/plugins/$1".jpi META-INF/MANIFEST.MF | tr -d '\r' | tr '\n' '|' | sed -e 's#| ##g' | tr '|' '\n' | grep "^Plugin-Dependencies: " | sed -e 's#^Plugin-Dependencies: ##' | tr ',' '\n' | grep -v 'resolution:=optional')
	do
		plugin_name=${f%:*}
		plugin_version=${f#*:}
		if ! test -f "/var/lib/jenkins/plugins/${plugin_name}.jpi"
		then
			echo "Download: ${plugin_name} @ ${plugin_version}"
			install_plugin "${plugin_name}" "${plugin_version}"
		else
			echo "Skipping ${plugin_name} because /var/lib/jenkins/plugins/${plugin_name}.jpi exists"
		fi
	done
}

install_plugin "$1" latest
