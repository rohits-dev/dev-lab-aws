ldapsearch -H ldap://openldap -x -D "CN=admin,dc=cluster,dc=local" -b "dc=cluster,dc=local"  -w Not@SecurePassw0rd

ldapsearch -H ldap://openldap -x -D "cn=kafka,ou=users,dc=cluster,dc=local" -b "dc=cluster,dc=local"  -w kafka

ldapsearch -H ldap://openldap -x -D "cn=kafka,ou=users,dc=cluster,dc=local" -b "OU=Users,DC=cluster,DC=local"  -w kafka "(&(objectClass=inetOrgPerson)(objectClass=inetOrgPerson)(cn=kafka))"
