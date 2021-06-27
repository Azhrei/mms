# vi:syntax=sshdconfig:

# Added to /etc/ssh/sshd_config at container creation time.

# For some reason, the address family must be forced to ip4 or the
# X11 forwarding doesn't work.  It appears to having something do
# do with the lookup of xauth data in ~/.Xauthority, but I haven't
# completely narrowed it down.
AddressFamily inet

GatewayPorts yes
PermitUserEnvironment yes
LoginGraceTime 30

Match User maptool
	# This is the player name assigned by the GM
	AcceptEnv REMOTE
	AllowAgentForwarding no
	AllowStreamLocalForwarding no
	AllowTcpForwarding yes
	AuthenticationMethods publickey
	ClientAliveCountMax 3
	ClientAliveInterval 60
	KbdInteractiveAuthentication no
	# Only 1 session maximum (for testing); all others are tunneling only
	#MaxSessions 1
	PasswordAuthentication no
	# Only allow remote ports to be forwarded to local ports on this host
	PermitOpen localhost:*
	PermitTTY yes
	# Not needed as it applies only to tun(4) devices.
	#PermitTunnel yes
	PermitUserRC no
	# Already turned on, but just in case it's turned off in the main file
	PubkeyAuthentication yes
	# I'm not sure this will stay here, but it may be needed...
	X11Forwarding yes
