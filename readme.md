## Example Usage

```

- name: Execute Bulk SQL
  oracle_sqlplus:
    dbUser: 'username'
    dbPass: 'password'
    dbConnectStr: 'hostname.local:2484/service_name'
    bulkLoadPath: 'c:\stormSQL\SQL'
  register: result

- debug:
    msg: "{{ result }}"
	
- name: Execute Single SQL
  oracle_sqlplus:
    dbUser: 'username'
    dbPass: 'password'
    dbConnectStr: 'hostname.local:2484/service_name'
    singleSQLPath: 'c:\stormSQL\SQL\sqlfile.sql'
	extraArgs: "somevalue someothervalue"
  register: result

- debug:
    msg: "{{ result }}"

```

## Options

```
module: oracle_sqlplus
version_added: "1.0"
short_description: Oracle SQL Plus wrapper
description:
    - Oracle SQL Plus wrapper
options:
  dbUser:
    description:
      - Username of the schema
    required: true
  dbPass:
    description:
      - Password of the schema.
    required: true
  dbConnectStr:
    description:
      - Connection string in the following format "hostname.local:2484/service_name"
    required: true
  bulkLoadPath:
    description:
      - Path to a folder containing multiple parameterless scripts to be executed
    required: false
  singleSQLPath:
    description:
      - Path to an sql file to be executed
    required: false
  extraArgs:
    description:
      - Add arguments to an sql script
    required: false
```