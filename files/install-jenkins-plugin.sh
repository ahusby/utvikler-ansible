#!/usr/bin/env sh

function install_plugin {
	download_plugin "$1" "${2:-latest}"
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
	deps=$(unzip -p "/var/lib/jenkins/plugins/$1".jpi META-INF/MANIFEST.MF | tr -d '\r' | tr '\n' '|' | sed -e 's#| ##g' | tr '|' '\n' | grep "^Plugin-Dependencies: " | sed -e 's#^Plugin-Dependencies: ##')

	if [[ ! $deps ]]; then
		echo " -> $1 has no dependencies"
		return
	fi

	echo " -> $1 depends on $deps"

	IFS=',' read -r -a array <<< "$deps"
	for f in "${array[@]}"
	do
		plugin_name="$(cut -d':' -f1 - <<< "$f")"
		if [[ $f == *"resolution:=optional"* ]]; then
			echo " -> skipping optional dependency $plugin_name"
		else
			if ! test -f "/var/lib/jenkins/plugins/${plugin_name}.jpi"
			then
				echo " -> installing dependency ${plugin_name}"
				install_plugin "${plugin_name}"
			else
				echo " -> skipping dependency ${plugin_name} because /var/lib/jenkins/plugins/${plugin_name}.jpi exists"
			fi
		fi
	done
}

install_plugin "$1"
