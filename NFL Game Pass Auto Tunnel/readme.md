# NFL GamePass AutoTunnel

A script that automates the NFL Game Pass SSH tunneling process, useful when traveling.

### Script Behavior
1. Download plink.exe (A windows SSH client).
2. Connect to home server.
3. Start a proxy server
4. Modify IE to use that proxy server.
5. Start Game Pass with enough time to log in.
6. Turn off the proxy and disconnect from home server.

### Troubleshooting
1. Video hangs after the script is done running
  * Just switch back to another game/show to force IE to refresh proxy config.
2. Script exits before gamepass login
  * Increase the gamepassWait variable value in the script

### Legal
I don't condone or endorse piracy, the script is simply to provide an easier way to establish a connection while traveling.