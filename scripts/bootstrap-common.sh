#!/usr/bin/env bash
#
# This part is the common steps for all bootstrap methods:
#   - minimal - when remote deployment is possible
#   - full    - when the site is bootrapping with local ansible deployment
#

# Add deployment user

userdel -r coda19-deployment 2>/dev/null
useradd coda19-deployment --groups wheel --password '$6$.UqcnmIDvAfWwCdq$5Jy3dsTcljF7hxcUsBvV9kA3Wt0UvMJ03L9XQFqNBVru7PX4.hEiWtzKK2vwhpAWSPCMWLC4gDgO2NPDw8CFH/'

# Create .ssh folder and public key

mkdir -p ~coda19-deployment/.ssh
cat << EOT> ~coda19-deployment/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFfxBJ0T+HcFUehscJygx2npYdToTrahgpDI0o6+1fUmxYW/DqOulhuApxY9S5/2Ht7+IZBIH9/H6OZ9kjig0Q4X2jDbd/Y3+oZINYRyPP92w/d1j0H4YemfJfHIDt7xTSIlwwlPb5wFBOe0FevFChbdrP50Gqm0+HqVZw78IZjwdULLaX0LQR1u0J20Zihro+CFwBnPNIWEktSUgWo5rlMCGakrO+tzcxoLDWCnu6i47iFoZWibpl2yO+zjkOeAT9OyRuZi2Mw8I3PPlCxDY3+9BEa/cnszRMatMAn/J4cu7NFfTK0ZABwZB/37Rk8t+2hIiwtPpHyM7elYId5vS2lbTAAGlLRW57pZFKRWwzBSJHOBL0tVaKHQnklPpOa5EQ7sswv/YcYFt9FGOEth7y7M6M0YVt5FgcYqV+jSFwTicyD+9VQhs677IbwPZfeYDqvImUJZAT+6C9kccd3MUMGhgytqFNmVxtmfsuirws9L+OuIUimBDALyDfbKYCi/5yFB6VZX3eC3U0xSN0cm6Bn+r+OEuIdSm+AZ8wPg6KAdd22fGaZDUMbSifbCtwzn98+E1vtU7W8VGV5AfxRUh/QsqnSxqpUQfYiUch+g54dZ5e29AHDYJb8bzWWr0pDjYePSAUzBblZiv+9GaMMfz7LNt6cnF3XAoxOiYkm8/rcw== info@valeria.science
EOT

# Set ownership and privileges
chown -R coda19-deployment:coda19-deployment ~coda19-deployment/.ssh

chmod 0700 ~coda19-deployment/.ssh
chmod 0644 ~coda19-deployment/.ssh/authorized_keys
