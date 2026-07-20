#!bash
# profiles/server.sh — headless-Server (z.B. Homelab: mgmt-LXC, dev1-LXC).
# Vom Loader NACH bash/core.sh gesourct. Bewusst schlank gehalten:
# alles hier muss ohne Desktop/X laufen. Maschinen-EINZIGARTIGES gehoert
# nicht hierher, sondern nach ~/.bash_personal.

# kein Tastatur-Remap, kein X — nichts weiter noetig.
# Praktische Kuerzel fuers Infra-Arbeiten (nur wenn Tool vorhanden):
_have tofu && ! _have tf && alias tf='tofu'

# Platz fuer weitere server-weite Defaults (umask, o.ae.) bei Bedarf.
