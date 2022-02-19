# dev-lab-aws

# VPN Client Auth
VPN Client auth is configured using mutual auth i.e. mTLS which requires certificates to be in ACM. Create a CA and Client cert following https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual and import into ACM. Set the ROOT_CA_ARN in variables with the arn of root CA in ACM.

Upload the configuration in S3 with certificates information so that next time onwards it works. 

>>>
of course this needs improvements.
>>>

# install openvpn
brew install --cask openvpn-connect

