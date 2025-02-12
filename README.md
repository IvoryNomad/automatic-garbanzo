# automatic-garbanzo
automatic-garbanzo is a simple script and set of instructions to enable
automatic Kerberos ticket renewal on macos.

## Prerequisites
- Ensure your local Kerberos setup allows ticket renewal
  ```ini
  # /etc/krb5.conf
  [libdefaults]
  renewable = true
  renew_lifetime = 5d
  ``` 
- Install kstart from [Homebrew](https://brew.sh/)
  ```shell-session
  $ brew install kstart
  ```

## Installation
- Clone this repository
  ```shell-session
  $ git clone https://github.com/IvoryNomad/automatic-garbanzo.git && cd automatic-garbanzo
  ```
- Copy the wrapper script into a local bin directory:
  ```shell-session
  $ mkdir -p "${HOME}"/.local/bin
  $ cp script/k5start-wrapper.sh "${HOME}"/.local/bin/k5start-wrapper.sh
  $ chmod +x "${HOME}"/.local/bin/k5start-wrapper.sh
  ```
- Copy the Launch Agent file into `~/Library/LaunchAgents/`
  Recommended: rename the Launch Agent file to reflect your KRB5 realm:
  ```shell-session
  $ mkdir -p "${HOME}"/Library/LaunchAgents
  $ export REALM_REV=$(klist | grep 'Principal:' | cut -d '@' -f 2 | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "\n")}' | tr '[:upper:]' '[:lower:]')
  $ envsubst < LaunchAgent/local.k5start.plist > "${HOME}"/Library/LaunchAgents/"${REALM_REV}".k5start.plist
  ```
- Load the Launch Agent:
  ```shell-session
  $ launchctl load ~/Library/LaunchAgents/"${REALM_REV}".k5start.plist
  ```
- validate:
  ```shell-session
  $ launchctl list "${REALM_REV}".k5start
  {
          "StandardOutPath" = "/tmp/k5start.out";
          "LimitLoadToSessionType" = "Aqua";
          "StandardErrorPath" = "/tmp/k5start.err";
          "Label" = "com.example.k5start";
          "OnDemand" = true;
          "LastExitStatus" = 0;
          "Program" = "/Users/user/.local/bin/k5start-wrapper.sh";
          "ProgramArguments" = (
                  "/Users/user/.local/bin/k5start-wrapper.sh";
          );
  };
  # Note: you should see your realm and username reflected in this output

  $ kdestroy
  
  $ kinit
  user@EXAMPLE.COM's password: 
  
  $ klist -f
  Credentials cache: API:1EF28287-52FD-4A77-94F9-763332FF2A22
          Principal: user@EXAMPLE.COM
  
    Issued                Expires             Flags    Principal
  Feb 10 11:13:03 2025  Feb 11 11:12:58 2025  FRIA   krbtgt/EXAMPLE.COM@EXAMPLE.COM
  ```
  The `R` flag shows that your tickets are renewable.

