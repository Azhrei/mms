# Added to /etc/ssh/sshd_config at container creation time.

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
	MaxSessions 1
	PasswordAuthentication no
	# Only allow remote ports to be forwarded to local ports on this host
	PermitOpen localhost:*
	PermitTTY yes
	PermitUserRC no
	# Already turned on, but just in case it's turned off in the main file
	PubkeyAuthentication yes
	X11Forwarding no
