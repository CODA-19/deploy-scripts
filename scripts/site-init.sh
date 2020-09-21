#!/usr/bin/env bash

# Add deployment user

userdel -r coda19-deployment 2>/dev/null
useradd coda19-deployment --groups wheel --password '$6$.UqcnmIDvAfWwCdq$5Jy3dsTcljF7hxcUsBvV9kA3Wt0UvMJ03L9XQFqNBVru7PX4.hEiWtzKK2vwhpAWSPCMWLC4gDgO2NPDw8CFH/'

# Add deployment user private key

mkdir -p ~coda19-deployment/.ssh
cat << EOT> ~coda19-deployment/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDe+q8xQoLs4ElgScPLt33VS82aGNVHXnVJFP2l/SG5uf7LXVeaTR0Jg6/b9N5UPaEn9lx1sTDwrvOo9v3XGo0EDpJcOUbaS2otOq2w6U/R4EjW4YNZPDqicsURKnZCYKnY5t18R4Md9MqahOVbPolkY3PZpAX0uIut8ZCYNrf9Uq2E2/fuY2oHUm4+bOAM93XIIQD5Kb9BBsNvCILPeZW8nHBRGRHvBw4HT4qhdLRX6JHV9TidpjNyK7PsuUifxvlHi3KGGslnOsftmH28e1yQMgHwJ6iQq7duqd6YlDcd+M4FG+WKOgUpSmmhB+WvBCfX00XMwDIHOdpDvsJMGEiCkKI3kXBA5xKlS2vXK92tFTEe8fMwLQ/52sP7eV1vg/KBa0sdFkZkv+KXNz30FInrK8wloTAgzhEyelHIFt0lyHPODEZ70BnFBTFsyYMMwu7cb2EaP4lT/Kev8gXIIwvM1Wfq6Cd2Tly6uRLasaAtQvlkmekEoyA+C8F36FB083zFfauUjrlQif7wfLih0tjMiiuHDoEu9UfAuljpMjKTCqGXXhuGw7lKPtmdOXUgM1Z3maW0cZkyZ0Rk4iM1GLbqUAVmfk1ZDxxTeFAbzOL6mr+OZw1s8aTiQziWGV9lixNKI+IRelxN42UbL+fhdWcsqjnIjx0WQhirXI2y9hOL1w== info@valeria.science
EOT

chown -R coda19-deployment:coda19-deployment ~coda19-deployment/.ssh
chmod -R 0700 ~coda19-deployment/.ssh

# Open SSH from control plane only

#firewall-cmd --permanent --new-zone=coda19-hub
#firewall-cmd --permanent --zone=coda19-hub --add-source=132.203.231.0/25
#firewall-cmd --permanent --zone=coda19-hub --add-service=ssh
#firewall-cmd --reload
