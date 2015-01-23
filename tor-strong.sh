#!/bin/bash
if [ $USER != root ]; then
echo "Error: you must be root"
exit 1
fi
trap "rm -f /run/tor-strong.pid; exit" INT TERM EXIT
echo $BASHPID > /run/tor-strong.pid
lock="/run/tor.lock"
case "$1" in
	install)
		mkdir -p /var/cache/polipo
		mkdir -p /var/lib/tor
		mkdir -p /var/log/polipo
		mkdir -p /var/log/tor
		echo "deb http://deb.torproject.org/torproject.org/ sid main" > /etc/apt/sources.list.d/tor.list
		echo "deb-src http://deb.torproject.org/torproject.org/ sid main" >> /etc/apt/sources.list.d/tor.list
		gpg --keyserver keys.gnupg.net --recv 886DDD89
		gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
		apt update
		apt -y install deb.torproject.org-keyring
		apt update
		apt -y install polipo privoxy tor tor-arm dnsmasq
		# torrc
		echo "## SocksPort para trafico generico" > /etc/tor/torrc
		echo "SocksPort 9050 IsolateDestAddr IsolateDestPort" >> /etc/tor/torrc
		echo "## SocksPort para el navegador" >> /etc/tor/torrc
		echo "SocksPort 9151" >> /etc/tor/torrc
		echo "RunAsDaemon 1" >> /etc/tor/torrc
		echo "DataDirectory /var/lib/tor" >> /etc/tor/torrc
		echo "CookieAuthentication 1" >> /etc/tor/torrc
		echo "LearnCircuitBuildTimeout 1" >> /etc/tor/torrc
		echo "EnforceDistinctSubnets 1" >> /etc/tor/torrc
		echo "WarnUnsafeSocks 1" >> /etc/tor/torrc
		echo "SafeSocks 1" >> /etc/tor/torrc
		echo "DownloadExtraInfo 0" >> /etc/tor/torrc
		echo "OptimisticData auto" >> /etc/tor/torrc
		echo "UseMicrodescriptors auto" >> /etc/tor/torrc
		echo "UseNTorHandshake auto" >> /etc/tor/torrc
		echo "NumCPUs 0" >> /etc/tor/torrc
		echo "ServerDNSDetectHijacking 1" >> /etc/tor/torrc
		echo "ServerDNSRandomizeCase 1" >> /etc/tor/torrc
		echo "PIDFile /run/tor/tor.pid" >> /etc/tor/torrc
		echo "AvoidDiskWrites 1" >> /etc/tor/torrc
		echo "VirtualAddrNetworkIPv4 10.192.0.0/10" >> /etc/tor/torrc
		echo "DNSPort 9053" >> /etc/tor/torrc
		echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
		echo "AutomapHostsSuffixes .exit,.onion" >> /etc/tor/torrc
		echo "TransPort 9040" >> /etc/tor/torrc
		echo "User debian-tor" >> /etc/tor/torrc
		echo "DisableDebuggerAttachment 0" >> /etc/tor/torrc
		echo "ControlSocket /run/tor/control" >> /etc/tor/torrc
		echo "ControlSocketsGroupWritable 1" >> /etc/tor/torrc
		echo "CookieAuthFileGroupReadable 1" >> /etc/tor/torrc
		echo "CookieAuthFile /run/tor/control.authcookie" >> /etc/tor/torrc
		echo "Log notice file /var/log/tor/log" >> /etc/tor/torrc
		# polipo
		echo "logSyslog = true" > /etc/polipo/config
		echo "logFile = /var/log/polipo/polipo.log" >> /etc/polipo/config
		echo "socksParentProxy = localhost:9151" >> /etc/polipo/config
		echo "socksProxyType = socks5" >> /etc/polipo/config
		echo 'proxyAddress = "127.0.0.1"' >> /etc/polipo/config
		echo "proxyPort = 8123" >> /etc/polipo/config
		echo "allowedClients = 127.0.0.1" >> /etc/polipo/config
		echo "allowedPorts = 1-65535" >> /etc/polipo/config
		echo 'diskCacheRoot = "/var/cache/polipo/"' >> /etc/polipo/config
		echo "cacheIsShared = false" >> /etc/polipo/config
		echo 'localDocumentRoot = ""' >> /etc/polipo/config
		echo 'proxyName = "localhost"' >> /etc/polipo/config
		echo "disableLocalInterface = true" >> /etc/polipo/config
		echo "disableConfiguration = true" >> /etc/polipo/config
		echo "dnsUseGethostbyname = yes" >> /etc/polipo/config
		echo "dnsQueryIPv6 = no" >> /etc/polipo/config
		echo "disableVia = true" >> /etc/polipo/config
		echo "#censoredHeaders = from,accept-language,x-pad,link" >> /etc/polipo/config
		echo "#censorReferer = maybe" >> /etc/polipo/config
		echo "maxConnectionAge = 5m" >> /etc/polipo/config
		echo "maxConnectionRequests = 120" >> /etc/polipo/config
		echo "serverMaxSlots = 8" >> /etc/polipo/config
		echo "serverSlots = 2" >> /etc/polipo/config
		echo "tunnelAllowedPorts = 1-65535" >> /etc/polipo/config
		echo "pidFile = /run/polipo.pid" >> /etc/polipo/config
		# privoxy
		echo "user-manual /usr/share/doc/privoxy/user-manual" > /etc/privoxy/config
		echo "confdir /etc/privoxy" >> /etc/privoxy/config
		echo "logdir /var/log/privoxy" >> /etc/privoxy/config
		echo "actionsfile match-all.action" >> /etc/privoxy/config
		echo "actionsfile default.action" >> /etc/privoxy/config
		echo "actionsfile user.action" >> /etc/privoxy/config
		echo "filterfile default.filter" >> /etc/privoxy/config
		echo "filterfile user.filter" >> /etc/privoxy/config
		echo "logfile logfile" >> /etc/privoxy/config
		echo "hostname privoxy" >> /etc/privoxy/config
		echo "listen-address  :8118" >> /etc/privoxy/config
		echo "toggle  1" >> /etc/privoxy/config
		echo "enable-remote-toggle  0" >> /etc/privoxy/config
		echo "enable-remote-http-toggle  0" >> /etc/privoxy/config
		echo "enable-edit-actions 0" >> /etc/privoxy/config
		echo "enforce-blocks 0" >> /etc/privoxy/config
		echo "buffer-limit 4096" >> /etc/privoxy/config
		echo "enable-proxy-authentication-forwarding 0" >> /etc/privoxy/config
		echo "forward   /               127.0.0.1:8123" >> /etc/privoxy/config
		echo "forward         192.168.*.*/     ." >> /etc/privoxy/config
		echo "forward            10.*.*.*/     ." >> /etc/privoxy/config
		echo "forward           127.*.*.*/     ." >> /etc/privoxy/config
		echo "forwarded-connect-retries  0" >> /etc/privoxy/config
		echo "accept-intercepted-requests 0" >> /etc/privoxy/config
		echo "allow-cgi-request-crunching 0" >> /etc/privoxy/config
		echo "split-large-forms 0" >> /etc/privoxy/config
		echo "keep-alive-timeout 5" >> /etc/privoxy/config
		echo "tolerate-pipelining 1" >> /etc/privoxy/config
		echo "socket-timeout 300" >> /etc/privoxy/config
		# dnsmasq
		echo "port=53" > /etc/dnsmasq.conf
		echo "domain-needed" >> /etc/dnsmasq.conf
		echo "bogus-priv" >> /etc/dnsmasq.conf
		echo "user=dnsmasq" >> /etc/dnsmasq.conf
		echo "group=dnsmasq" >> /etc/dnsmasq.conf
		echo "no-resolv" >> /etc/dnsmasq.conf
		echo "server=127.0.0.1#9053" >> /etc/dnsmasq.conf
		echo "server=208.67.222.222" >> /etc/dnsmasq.conf
		# cleaning up
		adduser --system --no-create-home debian-tor debian-tor
		chown debian-tor:debian-tor /var/log/tor /var/lib/tor
		chmod 600 /var/lib/tor /var/log/tor
		chmod u+x /var/lib/tor /var/log/tor
		chgrp debian-tor /etc/tor/ /etc/tor/*
		chmod g+rw /etc/tor/ /etc/tor/*
		rm -f /usr/share/tor/tor-service-defaults-torrc
		ln -s /etc/tor/torrc /usr/share/tor/tor-service-defaults-torrc
		echo "Finished, it's recommended to restart..."
		;;

	start)
		if [[ -f $lock ]]; then
			echo "Tor it's already running."
		else
			touch $lock
			mkdir /run/tor
			chown debian-tor:debian-tor /run/tor
			chgrp debian-tor /run/tor
			chmod 700 /run/tor
			service tor start
			service polipo start
			service privoxy start
			service dnsmasq restart
			echo "Wait while TOR starts will be notified upon completion of the task."
			sleep 30
			echo "Start completed. Enter the following PROXY settings in your browser: localhost port 8118 (9151 for socks) and localhost port 9050 to others apps that use socks."
		fi
		;;

	stop)
	    	if [[ -f $lock ]]; then
			service privoxy stop
			service polipo stop
			service tor stop
			service dnsmasq restart
			rm -f /run/tor/tor.pid
			rm -f /run/polipo.pid
			rm -f /run/privoxy.pid
			rm -f $lock
			echo "Finished."
		else
			echo "Tor not's running."
		fi
		;;

	*)
		echo "Usage: $0 {install|start|stop}"
		;;
esac
rm -f /run/tor-strong.pid
trap - INT TERM EXIT
exit 0
